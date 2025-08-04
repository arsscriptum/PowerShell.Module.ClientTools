#╔════════════════════════════════════════════════════════════════════════════════╗
#║                                                                                ║
#║   initialize.ps1                                                               ║
#║                                                                                ║
#╟────────────────────────────────────────────────────────────────────────────────╢
#║   Guillaume Plante <codegp@icloud.com>                                         ║
#║   Code licensed under the GNU GPL v3.0. See the LICENSE file for details.      ║
#╚════════════════════════════════════════════════════════════════════════════════╝



function New-DelayedScheduledTask {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Position = 0, Mandatory = $true, HelpMessage = "Full path to the script to execute.")]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $_ -PathType Leaf })]
        [string]$ScriptPath,
        [Parameter(Mandatory = $false, HelpMessage = "Name of the scheduled task.")]
        [ValidateNotNullOrEmpty()]
        [string]$TaskName,
        [Parameter(Mandatory = $false, HelpMessage = "Delay in seconds before execution.")]
        [ValidateRange(5, 3600)]
        [int]$Seconds = 20,
        [Parameter(Mandatory = $false, HelpMessage = "use profile or not.")]
        [switch]$UseProfile,
        [Parameter(Mandatory = $false, HelpMessage = "Target user for the task.")]
        [ArgumentCompleter({
                param($command, $parameter, $wordToComplete, $commandAst, $fakeBoundParams)
                try {
                    Get-LoggedInUsers | Where-Object { $_ -like "$wordToComplete*" }
                } catch {
                    @()
                }
            })]
        [string]$User
    )

    try {
        # Derive task name from script basename if not provided
        if (-not $TaskName) {
            $TaskName = "$(Split-Path -Path $ScriptPath -LeafBase)-task"
            Write-Verbose "Auto-generated task name: $TaskName"
        }

        if (-not $User) {
            $User = Get-LoggedInUsers | Select-Object -First 1
            if (-not $User) {
                throw "No logged-in users found and no user specified."
            }
        }


        $ScriptPathFull = (Resolve-Path -Path $ScriptPath).Path

        Write-Host "Creating task '$TaskName' to run '$ScriptPathFull' in $Seconds seconds..." -ForegroundColor Cyan
        if ($UseProfile) {
            $ar = "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$ScriptPathFull`""
        } else {
            $ar = "-ExecutionPolicy Bypass -WindowStyle Hidden -NoProfile -File `"$ScriptPathFull`""
        }
        $UseVbs = $True

        if ($UseVbs) {
            [string]$VBSFile = (Join-Path "$env:TEMP" "$(((New-guid).guid).Substring(0,5))") + '.vbs'
            [string]$VBSContent = @"
Set objShell = CreateObject("WScript.Shell")
objShell.Run "pwsh.exe $ar", 0, False
"@
            $VBSContent | Set-Content -Path $VBSFile -Encoding ASCII
            Write-Host "Create a Scheduled Task to Run the VBS Script"
            $Action = New-ScheduledTaskAction -Execute "wscript.exe" -Argument `"$VBSFile`"
        }
        else {
            $Action = New-ScheduledTaskAction -Execute "pwsh.exe" -Argument $ar
        }
        $Trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).AddSeconds($Seconds)
        $Principal = New-ScheduledTaskPrincipal -UserId "$env:USERNAME" -RunLevel Highest -LogonType Interactive

        Register-ScheduledTask -TaskName $TaskName -Action $Action -Trigger $Trigger -Principal $Principal -Force

        Write-Host "✅ Task '$TaskName' scheduled to run in $Seconds seconds." -ForegroundColor Green
    }
    catch {
        Write-Error "❌ Failed to create task '$TaskName'. $_"
    }
}

#New-DelayedScheduledTask -TaskName "RunMyScript" -ScriptPath "C:\Scripts\Test.ps1" -Seconds 30
function New-EncodedScheduledTask {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Position = 0, Mandatory = $true, HelpMessage = "Path to the script to encode and execute.")]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $_ -PathType Leaf })]
        [string]$ScriptPath,
        [Parameter(Mandatory = $false, HelpMessage = "Name of the scheduled task.")]
        [ValidateNotNullOrEmpty()]
        [string]$TaskName,
        [Parameter(Mandatory = $false, HelpMessage = "Run delay in seconds.")]
        [ValidateRange(5, 3600)]
        [int]$When = 20,
        [Parameter(Mandatory = $false, HelpMessage = "Repeat interval in seconds.")]
        [ValidateRange(0, 3600)]
        [int]$RepeatInterval = 0,
        [Parameter(Mandatory = $false, HelpMessage = "use profile or not.")]
        [switch]$UseProfile,
        [Parameter(Mandatory = $false, HelpMessage = "Target user for the task.")]
        [ArgumentCompleter({
                param($command, $parameter, $wordToComplete, $commandAst, $fakeBoundParams)
                try {
                    Get-LoggedInUsers | Where-Object { $_ -like "$wordToComplete*" }
                } catch {
                    @()
                }
            })]
        [string]$User
    )

    try {
        # Derive task name from script basename if not provided
        if (-not $TaskName) {
            $TaskName = "$(Split-Path -Path $ScriptPath -LeafBase)-task"
            Write-Verbose "Auto-generated task name: $TaskName"
        }

        if (-not $User) {
            $User = Get-LoggedInUsers | Select-Object -First 1
            if (-not $User) {
                throw "No logged-in users found and no user specified."
            }
        }

        Write-Host "Target user: $User" -ForegroundColor Cyan

        $ScriptContent = Get-Content -Path $ScriptPath -Raw
        $Bytes = [System.Text.Encoding]::Unicode.GetBytes($ScriptContent)
        $EncodedCommand = [Convert]::ToBase64String($Bytes)
        if ($UseProfile) {
            $ar = "-ExecutionPolicy Bypass -WindowStyle Hidden -EncodedCommand $EncodedCommand"
        } else {
            $ar = "-ExecutionPolicy Bypass -WindowStyle Hidden -NoProfile -EncodedCommand $EncodedCommand"
        }
        $UseVbs = $True

        if ($UseVbs) {
            [string]$VBSFile = (Join-Path "$env:TEMP" "$(((New-guid).guid).Substring(0,5))") + '.vbs'
            [string]$VBSContent = @"
Set objShell = CreateObject("WScript.Shell")
objShell.Run "pwsh.exe $ar", 0, False
"@
            $VBSContent | Set-Content -Path $VBSFile -Encoding ASCII
            Write-Host "Create a Scheduled Task to Run the VBS Script"
            $Action = New-ScheduledTaskAction -Execute "wscript.exe" -Argument `"$VBSFile`"
        }
        else {
            $Action = New-ScheduledTaskAction -Execute "pwsh.exe" -Argument $ar
        }
        $Trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).AddSeconds($When)
        if ($RepeatInterval -gt 0) {
            $Trigger.RepetitionInterval = New-TimeSpan -Seconds $RepeatInterval
            $Trigger.RepetitionDuration = [timespan]::FromDays(1)
        }
        $Principal = New-ScheduledTaskPrincipal -UserId "$User" -RunLevel Highest -LogonType Interactive

        Register-ScheduledTask -TaskName $TaskName -Action $Action -Trigger $Trigger -Principal $Principal -Force

        Write-Host "✅ Task '$TaskName' scheduled for user $User in $When seconds." -ForegroundColor Green
    }
    catch {
        Write-Error "❌ Error creating scheduled task: $_"
    }
}

function Open-QueuedCommandLogs {
    [CmdletBinding(SupportsShouldProcess)]
    param()

    $baretailExe = "C:\Programs\BareTail\baretail.exe"
    $LogFile = "$ENV:Temp\QueuedCommands.log"
    & "$baretailExe" "$LogFile"

}

function Stop-QueuedCommandProcessor {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    try {
        # Derive task name from script basename if not provided
        $TaskName = "QueuedCommandsProcessor"
        Write-Host "Check for created processors..." -f DarkGray
        try {
            Stop-ScheduledTask -TaskName $TaskName -ErrorAction Stop
            Write-Host "Unregister task $TaskName" -NoNewline -f DarkYellow
            Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction Stop
            Write-Host "Success" -f DarkGreen
        } catch {
            Write-Host "No Running Command Processor. OK!" -f DarkGray
        }

    } catch {
        Write-Error "❌ Error creating scheduled task: $_"
    }
}



function Start-QueuedCommandProcessor {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $false, HelpMessage = "Run delay in seconds.")]
        [ValidateRange(5, 3600)]
        [int]$When = 20,
        [Parameter(Mandatory = $false, HelpMessage = "Repeat interval in seconds.")]
        [ValidateRange(60, 3600)]
        [int]$RepeatInterval = 60
    )


    $ScriptContent = @"

function Invoke-ProcessQueuedCommands {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = `$false)]
        [switch]`$DryRun
    )
    `$ExecuteCommand = `$True
    if (`$DryRun) {
        Write-Host `"[Invoke-ProcessQueuedCommands] DryRun: Simulating Executing queued commands`" -f DarkYellow
        `$ExecuteCommand = `$False
    } else {
        Write-Host `"[Invoke-ProcessQueuedCommands] Executing queued commands`" -f DarkRed
    }

    `$LogFile = `"`$ENV:Temp\QueuedCommands.log`"
    `$LogDate = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
    if (!(Test-Path `$LogFile)) {
        `"============ LOG STARTED on `$LogDate ============`" | Out-File -FilePath `$LogFile -Encoding UTF8
    }

    function Write-Log {
        [CmdletBinding(SupportsShouldProcess)]
        param([string]`$Message)
        `$ts = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
        `"`$ts - `$Message`" | Out-File -FilePath `$LogFile -Append -Encoding UTF8
        Write-Verbose `"`$ts - `$Message`"
    }

    `$RegKeyRoot = `"HKCU:\Software\arsscriptum\PowerShell.Module.ClientTools\QueuedCommands`"
    if (-not (Test-Path `$RegKeyRoot)) {
        Write-Log `"Registry path '`$RegKeyRoot' does not exist. Exiting.`"
        return
    }

    [decimal]`$Now = (get-date -UFormat `"%s`") -as [decimal]

    `$QueuedCmds = Get-ChildItem -Path `$RegKeyRoot
    foreach (`$command in `$QueuedCmds) {
        try {
            `$shouldwait = `$command.GetValue('wait')
            `$whenval = `$command.GetValue('when')
            `$exeName = `$command.GetValue('exename')
            `$argList = `$command.GetValue('argumentlist')
            `$Diff = `$Now - `$whenval
            Write-Verbose `"Now `$Now whenval `$whenval. Diff `$Diff`"
            if (`$Diff -gt 0) {
                if (`$ExecuteCommand) {
                    Write-Log `"Executing queued command '`$exeName `$argList' scheduled for `$Diff seconds ago`"
                    `$psi = New-Object System.Diagnostics.ProcessStartInfo
                    `$psi.FileName = `$exeName
                    `$psi.Arguments = `$argList -join ' '
                    `$psi.UseShellExecute = `$false
                    `$psi.RedirectStandardOutput = `$true
                    `$psi.RedirectStandardError = `$true

                    `$proc = [System.Diagnostics.Process]::Start(`$psi)
                    `$stdout = `$proc.StandardOutput.ReadToEnd()
                    `$stderr = `$proc.StandardError.ReadToEnd()
                    if(`$shouldwait){
                        `$proc.WaitForExit()
                        Write-Log `"Command exit code: `$(`$proc.ExitCode)`"
                        if (`$stdout) { Write-Log `"STDOUT:`n`$stdout`" }
                        if (`$stderr) { Write-Log `"STDERR:`n`$stderr`" }
                    }

                    # Remove registry key after execution
                    Remove-Item -Path `$command.PSPath -Force -Recurse
                    Write-Log `"Deleted registry key: `$(`$command.PSChildName)`"
                }else{
                    Write-Log `"Would be executing queued command '`$exeName `$argList' scheduled for `$Diff seconds ago`"
                }
            } else {
                `$DiffAbs = [math]::Abs(`$Diff)
                Write-Log `"Command '`$exeName `$argList' is scheduled to run in `$DiffAbs seconds - not time yet.`"
            }
        } catch {
            Write-Log `"ERROR processing command `$(`$command.PSChildName): `$_`"
        }
    }
}

Invoke-ProcessQueuedCommands
"@

    try {
        # Derive task name from script basename if not provided
        $TaskName = "QueuedCommandsProcessor"

        [int]$RepeatInterval = 60 # Must be at least 60 seconds

        if ($RepeatInterval -lt 60) {
            throw "Repeat interval must be at least 60 seconds. Windows Task Scheduler does not support shorter intervals."
        }


        Write-Host "Check for created processors..." -f DarkGray
        try {
            Stop-ScheduledTask -TaskName $TaskName -ErrorAction Stop
            Write-Host "Unregister task $TaskName" -NoNewline -f DarkYellow
            Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction Stop
            Write-Host "Success" -f DarkGreen
        } catch {
            Write-Host "No Running Command Processor. OK!" -f DarkGray
        }

        $User = Get-LoggedInUsers | Select-Object -First 1
        Write-Host "Target user: $User" -ForegroundColor Cyan

        $Bytes = [System.Text.Encoding]::Unicode.GetBytes($ScriptContent)
        $EncodedCommand = [Convert]::ToBase64String($Bytes)
        if ($UseProfile) {
            $ar = "-ExecutionPolicy Bypass -WindowStyle Hidden -EncodedCommand $EncodedCommand"
        } else {
            $ar = "-ExecutionPolicy Bypass -WindowStyle Hidden -NoProfile -EncodedCommand $EncodedCommand"
        }

        $UseVbs = $True

        if ($UseVbs) {
            [string]$VBSFile = (Join-Path "$env:TEMP" "$(((New-guid).guid).Substring(0,5))") + '.vbs'
            [string]$VBSContent = @"
Set objShell = CreateObject("WScript.Shell")
objShell.Run "pwsh.exe $ar", 0, False
"@
            $VBSContent | Set-Content -Path $VBSFile -Encoding ASCII
            Write-Host "Create a Scheduled Task to Run the VBS Script"
            $Action = New-ScheduledTaskAction -Execute "wscript.exe" -Argument `"$VBSFile`"
        }
        else {
            $Action = New-ScheduledTaskAction -Execute "pwsh.exe" -Argument $ar
        }

        $Trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).AddSeconds($When)
        if ($RepeatInterval -gt 0) {
            $Trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).AddSeconds($When) -RepetitionDuration ([timespan]::FromDays(1)) -RepetitionInterval (New-TimeSpan -Seconds $RepeatInterval)
        }
        $Principal = New-ScheduledTaskPrincipal -UserId "$User" -RunLevel Highest -LogonType Interactive

        Register-ScheduledTask -TaskName $TaskName -Action $Action -Trigger $Trigger -Principal $Principal -Force

        Write-Host "✅ Task '$TaskName' scheduled for user $User in $When seconds." -ForegroundColor Green
    }
    catch {
        Write-Error "❌ Error creating scheduled task: $_"
    }
}



