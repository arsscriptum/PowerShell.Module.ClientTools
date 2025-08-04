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
        [Parameter(Position=0,Mandatory = $true, HelpMessage = "Full path to the script to execute.")]
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
        if($UseProfile){
            $ar="-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$ScriptPathFull`""
        }else{
            $ar="-ExecutionPolicy Bypass -WindowStyle Hidden -NoProfile -File `"$ScriptPathFull`""
        }
        $Action = New-ScheduledTaskAction -Execute "pwsh.exe" -Argument $ar
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
        [Parameter(Position=0,Mandatory = $true, HelpMessage = "Path to the script to encode and execute.")]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $_ -PathType Leaf })]
        [string]$ScriptPath,
        [Parameter(Mandatory = $false, HelpMessage = "Name of the scheduled task.")]
        [ValidateNotNullOrEmpty()]
        [string]$TaskName,
        [Parameter(Mandatory = $false, HelpMessage = "Run delay in seconds.")]
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

        Write-Host "Target user: $User" -ForegroundColor Cyan

        $ScriptContent = Get-Content -Path $ScriptPath -Raw
        $Bytes = [System.Text.Encoding]::Unicode.GetBytes($ScriptContent)
        $EncodedCommand = [Convert]::ToBase64String($Bytes)
        if($UseProfile){
            $ar="-ExecutionPolicy Bypass -WindowStyle Hidden -EncodedCommand $EncodedCommand"
        }else{
            $ar="-ExecutionPolicy Bypass -WindowStyle Hidden -NoProfile -EncodedCommand $EncodedCommand"
        }
        $Action = New-ScheduledTaskAction -Execute "pwsh.exe" -Argument $ar
        $Trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).AddSeconds($Seconds)
        $Principal = New-ScheduledTaskPrincipal -UserId "$User" -RunLevel Highest -LogonType Interactive

        Register-ScheduledTask -TaskName $TaskName -Action $Action -Trigger $Trigger -Principal $Principal -Force

        Write-Host "✅ Task '$TaskName' scheduled for user $User in $Seconds seconds." -ForegroundColor Green
    }
    catch {
        Write-Error "❌ Error creating scheduled task: $_"
    }
}



#New-EncodedScheduledTask -ScriptPath "d:\VideoMessage.ps1" -Seconds 30
