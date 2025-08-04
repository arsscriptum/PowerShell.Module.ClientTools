#╔════════════════════════════════════════════════════════════════════════════════╗
#║                                                                                ║
#║   OpenPage.ps1                                                                 ║
#║                                                                                ║
#╟────────────────────────────────────────────────────────────────────────────────╢
#║   Guillaume Plante <codegp@icloud.com>                                         ║
#║   Code licensed under the GNU GPL v3.0. See the LICENSE file for details.      ║
#╚════════════════════════════════════════════════════════════════════════════════╝





function Save-CurrentPidToTempFile {
    [CmdletBinding()]
    param ()

    $processIdFile = Join-Path -Path $ENV:TEMP -ChildPath "OpenPage.pid"
    try {
        $PID | Out-File -FilePath $processIdFile -Encoding ASCII -Force
        Write-Host "Saved current PID $PID to '$processIdFile'" -ForegroundColor Green
    } catch {
        Write-Error "Failed to save PID: $_"
    }
}


function Stop-PidFromTempFile {
    [CmdletBinding(SupportsShouldProcess)]
    param ()

    $processIdFile = Join-Path -Path $ENV:TEMP -ChildPath "OpenPage.pid"
    if (!(Test-Path $processIdFile)) {
        Write-Warning "PID file not found: $processIdFile"
        return
    }

    try {
        $processIdToKill = Get-Content -Path $processIdFile -Raw | ForEach-Object { $_.Trim() } | Where-Object { $_ -match '^\d+$' }
        if (-not $processIdToKill) {
            Write-Warning "No valid PID found in file"
            return
        }

        $proc = Get-Process -Id $processIdToKill -ErrorAction SilentlyContinue
        if ($proc) {
            if ($PSCmdlet.ShouldProcess("PID $processIdToKill", "Stop-Process")) {
                Stop-Process -Id $processIdToKill -Force
                Write-Host "Process $processIdToKill stopped." -ForegroundColor Yellow
            }
        } else {
            Write-Warning "No process found with PID $processIdToKill"
        }
    } catch {
        Write-Error "Failed to stop process: $_"
    }
}


function New-OpenPageTask {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(position=0,Mandatory = $true)]
        [string]$Url,
        [Parameter(Mandatory = $false)]
        [ValidateRange(5, 120)]
        [int]$Delay = 15
    )
    try {

        $Script = @"

function Open-CustomPage {{
    [CmdletBinding(SupportsShouldProcess)]
    param()

    `$processIdFile = Join-Path -Path `$ENV:TEMP -ChildPath `"OpenPage.pid`"
    try {{
        `$PID | Out-File -FilePath `$processIdFile -Encoding ASCII -Force
        Write-Host `"Saved current PID `$PID to '`$processIdFile'`" -ForegroundColor Green
    }} catch {{
        Write-Verbose `"Failed to save PID: `$_`"
    }}

    `$url = `"{0}`"
    `$chromePath = `"`${{env:ProgramFiles}}\Google\Chrome\Application\`$browserName`"
    if (Test-Path `$chromePath) {{
        Add-Content -Path `"`$ENV:Temp\task_record.log`" -Value `"OPEN CUSTOM PAGE `$url using `$chromePath`"
        Start-Process -FilePath `$chromePath -ArgumentList `"--new-window`", `"`$url`"
    }} else {{
        Add-Content -Path `"`$ENV:Temp\task_record.log`" -Value `"OPEN CUSTOM PAGE `$url using Start-Process`"
        Start-Process `$url
    }}

}}
Open-CustomPage


"@

        $UseVbs = $True
        $LogFile = "$ENV:Temp\task_record.log"
        $LogDate = (get-date).GetDateTimeFormats()[20] -as [string]
        if(!(Test-Path "$LogFile")){
            New-Item -Path "$LogFile" -Force -ItemType File -Value "============ LOG STARTED on $LogDate ============`n" | out-null
        }
        [string]$ScriptString = $Script -f $Url

        [string]$ScriptBase64 = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($ScriptString))
        $now = [datetime]::Now.AddSeconds($Delay)
        # Example Usage
        $selectedUser = Select-LoggedInUser
        Write-Host "You selected: $selectedUser"

        #[string]$TaskName = "OpenPage-" + "$(((New-guid).guid).Substring(0,5))"
        [string]$TaskName = "OpenPage"

        try {
            Write-Host "Unregister task $TaskName" -NoNewline -f DarkYellow
            Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction Stop
            Write-Host "Success" -f DarkGreen
        } catch {
            Write-Host "Failed" -f DarkRed
        }

        [string]$VBSFile = (Join-Path "$env:TEMP"  "$(((New-guid).guid).Substring(0,5))") + '.vbs'
        [string]$VBSContent = @"
Set objShell = CreateObject("WScript.Shell")
objShell.Run "powershell.exe -ExecutionPolicy Bypass -EncodedCommand $ScriptBase64", 0, False
"@

        [string]$ArgumentString = "-WindowStyle Hidden -ExecutionPolicy Bypass -EncodedCommand {0}" -f $ScriptBase64
        Write-host "Create Scheduled Task with Base64 Encoded Command"

        $VBSContent | Set-Content -Path $VBSFile -Encoding ASCII
        [int]$rc = 15
        Write-Host "Create a Scheduled Task to Run the VBS Script"
        $Action = New-ScheduledTaskAction -Execute "wscript.exe" -Argument `"$VBSFile`"

        $Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -RestartCount $rc -RestartInterval $ts -MultipleInstances IgnoreNew
        $Trigger = New-ScheduledTaskTrigger -At $now -Once:$false
        $Principal = New-ScheduledTaskPrincipal -UserId "$selectedUser" -LogonType Interactive -RunLevel Highest
        $Task = New-ScheduledTask -Action $Action -Trigger $Trigger -Principal $Principal -Settings $Settings

        write-host "Register and Run Task"
        Register-ScheduledTask -TaskName $TaskName -InputObject $Task | Out-Null
        Start-ScheduledTask -TaskName $TaskName

        Write-Host "In $Delay seconds... $ENV:Temp\task_record.log"

    } catch {
        write-error "$_"
    }

}

function Invoke-OpenPageSecurityAdvisory {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    try {
        $Url = "https://www.cyber.gc.ca/fr/alertes-avis/al25-009-vulnerabilite-touchant-microsoft-sharepoint-server-cve-2025-53770"
        New-OpenPageTask $Url
    } catch {
        write-error "$_"
    }

}

function Invoke-OpenPageDesjardins {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    try {
        $Url = "https://accesdc.mouv.desjardins.com/accueil"
        New-OpenPageTask $Url
    } catch {
        write-error "$_"
    }

}

function Stop-OpenPageTask {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    try {
        [string]$TaskName = "OpenPage"
        [int]$NumPowershell = (tasklist | Select-String "powershell" -Raw | measure).Count
        try {
            Stop-ScheduledTask -TaskName $TaskName -ErrorAction Stop
            Write-Host "Unregister task $TaskName" -NoNewline -f DarkYellow
            Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction Stop
            Write-Host "Success" -f DarkGreen
        } catch {
            Write-Host "Failed" -f DarkRed
        }
        Stop-PidFromTempFile

    } catch {
        write-error "$_"
    }

}

function Stop-PowerShellProcesses {
    [CmdletBinding(SupportsShouldProcess)]
    param()

    try {
        [string[]]$Res = & "C:\Windows\system32\taskkill.exe" "/IM" "powershell.exe" "/F" 2> "$ENV:Temp\killres.txt"
        $Killed = $Res.Count
        Write-Host "NumPowershell $NumPowershell Killed $Killed"
    } catch {
        write-error "$_"
    }

}


