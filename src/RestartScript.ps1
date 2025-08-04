

$Script = @"
    Add-Type -AssemblyName 'PresentationFramework'
    Add-Type -AssemblyName 'PresentationCore'
    Add-Type -AssemblyName 'WindowsBase'
    Add-Type -AssemblyName 'System.Windows.Forms'


    `$BlueColor = [System.Drawing.Color]::FromArgb(17, 114, 169)
    `$RedColor = [System.Drawing.Color]::FromArgb(225, 25, 25)
    `$GreenColor = [System.Drawing.Color]::FromArgb(25, 225, 25)
    `$YellowColor = [System.Drawing.Color]::Yellow
    `$SsBackColor = `${2}Color    
    
    `$SsFont1  = 'Segoe Script'
    `$SsFont2  = 'Cascadia Code SemiBold'
    `$SsFont3  = 'Ink Free'
    `$SsFont4  = 'Fixedsys'
    `$SsFont5  = 'Terminal'
    `$SsFont6  = 'Segoe UI'

    `$SmileyFont = `$SsFont6
    `$GeneralFont = `$SsFont6
    `$SpecificFont= `$SsFont6
    # ====================================================================================
    # ====================================================================================

    `$screen = [System.Windows.Forms.Screen]::PrimaryScreen
    
    `$screenSaver = New-Object System.Windows.Forms.Form
    `$screenSaver.Bounds = `$screen.Bounds

    `$screenSaver.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::None

    `$screenSaver.add_Load({{
            [System.Windows.Forms.Cursor]::Hide()
            `$this.TopMost = `$true
    }})

    `$screenSaver.add_MouseClick({{
        [System.Windows.Forms.Application]::Exit()
    }})
    `$screenSaver.add_KeyPress({{
        [System.Windows.Forms.Application]::Exit()
    }})

    `$smiley = New-Object System.Windows.Forms.Label
    `$general = New-Object System.Windows.Forms.Label
    `$specific = New-Object System.Windows.Forms.Label

    `$smiley.Text = ':('
    `$general.Text = {0}
    `$specific.Text = {1}

    `$general.AutoSize = `$false
    `$specific.AutoSize = `$false

    `$screenSaver.BackColor = `$SsBackColor
    `$screenSaver.TopMost = `$true

    `$smiley.ForeColor = [System.Drawing.Color]::{3}
    `$general.ForeColor = [System.Drawing.Color]::{3}
    `$specific.ForeColor = [System.Drawing.Color]::{3}       
    
    `$smiley.Font = New-Object System.Drawing.Font -ArgumentList '`$SmileyFont', 100
    `$general.Font = New-Object System.Drawing.Font -ArgumentList '`$GeneralFont', 22
    `$specific.Font = New-Object System.Drawing.Font -ArgumentList '`$SpecificFont', 15

    `$Bounds = `$screenSaver.Bounds

    `$smiley.Size = New-Object System.Drawing.Size -ArgumentList (`$Bounds.Right - `$Bounds.Left), ((`$Bounds.Bottom - `$Bounds.Top) / 6)
    `$smiley.Location = new-object System.Drawing.Point -ArgumentList ((`$Bounds.Right - `$Bounds.Left) / 4), ((`$Bounds.Bottom - `$Bounds.Top) / 3)

    `$general.Size = new-object System.Drawing.Size -ArgumentList ((`$Bounds.Right - `$Bounds.Left) / 2), ((`$Bounds.Bottom - `$Bounds.Top) / 8)
    `$general.Location = New-Object System.Drawing.Point -ArgumentList ((`$Bounds.Right - `$Bounds.Left) / 4), (`$smiley.Location.Y + (`$Bounds.Bottom - `$Bounds.Top) / 6)

    `$specific.Size = new-object System.Drawing.Size -ArgumentList ((`$Bounds.Right - `$Bounds.Left) / 2), ((`$Bounds.Bottom - `$Bounds.Top) / 6)
    `$specific.Location = new-object System.Drawing.Point -ArgumentList ((`$Bounds.Right - `$Bounds.Left) / 4), (`$general.Location.Y + (`$Bounds.Bottom - `$Bounds.Top) / 8)
            
    `$screenSaver.Controls.Add(`$smiley);
    `$screenSaver.Controls.Add(`$general);
    `$screenSaver.Controls.Add(`$specific);

    `$screenSaver.ShowDialog()
    
"@


function Invoke-RestartWithMessage {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $false)]
        [string]$GeneralMessage,
        [Parameter(Mandatory = $false)]
        [Alias('m')]
        [string]$SpecificMessage,
        [Parameter(Mandatory = $false)]
        [ValidateSet('Blue', 'Yellow', 'Red')]
        [string]$Color = 'Blue',
        [Parameter(Mandatory = $false)]
        [ValidateSet('Blue', 'Yellow', 'Red', 'White')]
        [string]$TextColor = 'White',
        [Parameter(Mandatory = $false)]
        [ValidateRange(5, 500)]
        [Alias('w')]
        [int]$WaitFor = 5,
        [Parameter(Mandatory = $false)]
        [Alias('v')]
        [switch]$UseVbs,
        [Parameter(Mandatory = $false)]
        [Alias('t')]
        [switch]$Test,
        [Parameter(Mandatory = $false)]
        [Alias('s')]
        [switch]$Shutdown
    )
    try {


        [string]$GeneralMsg = '"Your PC ran into a problem that it couldnt handle, and now it needs to restart."'
        [string]$SpecificMsg = '"You can search for the error online: HAL_INITIALIZATION_FAILED"'
        if (![string]::IsNullOrEmpty($GeneralMessage)) {
            $GeneralMsg = "`"$GeneralMessage`""
        }
        if (![string]::IsNullOrEmpty($SpecificMessage)) {
            $SpecificMsg = "`"$SpecificMessage`""
        }
        [string]$ScriptString = $Script -f $GeneralMsg, $SpecificMsg, $Color, $TextColor

        [string]$ScriptBase64 = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($ScriptString))
        [bool]$DryRun = $False
        if ($Test) {
            $DryRun = $True
        }
        # Example Usage
        $selectedUser = Select-LoggedInUser
        Write-Host "You selected: $selectedUser"

        [string]$TaskName = "RestartWithMessage"

        try {
            Write-Host "Unregister task $TaskName" -NoNewline -f DarkYellow
            Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction Stop
            Remove-SchedTasks -TaskName $TaskName
            Write-Host "Success" -f DarkGreen
        } catch {
            Write-Host "Failed" -f DarkRed
        }



        [string]$folder = Invoke-EnsureSharedScriptFolder
        [string]$VBSFile = Join-Path "$folder" "hidden_powershell.vbs"

        [string]$VBSContent = @"
Set objShell = CreateObject("WScript.Shell")
objShell.Run "powershell.exe -ExecutionPolicy Bypass -EncodedCommand $ScriptBase64", 0, False
"@

        try {
            Show-Countdown $WaitFor

        } catch {
            Write-Host " Show-Countdown $WaitFor Failed. Waiting for $WaitFor secs" -f DarkRed
            Start-Sleep $WaitFor
        }
        if ($UseVbs) {
            New-Item -Path "$VBSFile" -ItemType File -Value "$VBSContent" -Force | Out-Null

            Write-Host "Create a Scheduled Task to Run the VBS Script"
            $WScriptCmd = Get-Command -Name "wscript.exe" -CommandType Application -ErrorAction Stop
            $WScriptBin = $WScriptCmd.Source
            $Action = New-ScheduledTaskAction -Execute "$WScriptBin" -Argument "$VBSFile"
        } else {

            [string]$ArgumentString = "-ExecutionPolicy Bypass -EncodedCommand {0}" -f $ScriptBase64
            Write-host "Create Scheduled Task with Base64 Encoded Command"
            $Action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -EncodedCommand $ScriptBase64"
        }
        $Trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).AddSeconds(5)
        $Principal = New-ScheduledTaskPrincipal -UserId "$selectedUser" -LogonType Interactive -RunLevel Highest
        $Task = New-ScheduledTask -Action $Action -Trigger $Trigger -Principal $Principal


        if ($True) {
            write-host "Register and Run Task"
            Register-ScheduledTask -TaskName $TaskName -InputObject $Task | Out-Null
            Add-SchedTasks -TaskName $TaskName
            Start-ScheduledTask -TaskName $TaskName

            write-host "Cleanup: Remove the task after execution"
            Start-Sleep -Seconds 10


            try {
                Write-Host "Unregister task $TaskName" -NoNewline -f DarkYellow
                Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction Stop
                Remove-SchedTasks -TaskName $TaskName
                Write-Host "Success" -f DarkGreen
            } catch {
                Write-Host "Failed" -f DarkRed
            }
        }
        if (!$DryRun) {
            if ($Shutdown) {
                Stop-Computer -Confirm:$false -Force
            } else {
                Restart-Computer -Force
            }
        }

    } catch {
        write-error "$_"
    }

}
New-alias -Name sysrestart -Value Invoke-RestartWithMessage -Scope 'Global' -ErrorAction 'Ignore'
