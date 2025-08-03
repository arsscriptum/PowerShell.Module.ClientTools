
function Get-PowerTimeouts {
    [CmdletBinding(SupportsShouldProcess)]
    param()

    $map = @{
        "VIDEOIDLE" = "Display Timeout (monitor-timeout-ac)"
        "DISKIDLE" = "Disk Timeout (disk-timeout-ac)"
        "STANDBYIDLE" = "Sleep Timeout (standby-timeout-ac)"
        "HIBERNATEIDLE" = "Hibernate Timeout (hibernate-timeout-ac)"
    }

    $scheme = (powercfg /getactivescheme) -replace '.*GUID: ([^ ]+).*', '$1'
    $output = powercfg /query $scheme

    foreach ($key in $map.Keys) {
        $setting = $output -split "`r?`n" | Select-String -Context 0, 3 -Pattern $key
        if ($setting) {
            $valueLine = $setting.Context.PostContext | Where-Object { $_ -match "Power Setting Index: (.+)" }
            if ($valueLine) {
                $seconds = [convert]::ToInt32(($valueLine -replace '.*: ', '').Trim(), 16)
                $minutes = [math]::Round($seconds / 60, 1)
                Write-Host "$($map[$key]): $minutes min ($seconds sec)"
            }
        }
    }
}

function Set-PowerTimeouts {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $false)]
        [int]$Value = 0
    )
    $map2 = @{
        "-monitor-timeout-ac" = "Never turn off screen (AC)"
        "-disk-timeout-ac" = "Never turn off hard disks (AC)"
        "-standby-timeout-ac" = "Never sleep (AC)"
        "-hibernate-timeout-ac" = "Disable hibernate (AC)"
    }
    $pexe = (get-command -Name "powercfg.exe" -CommandType Application).Source

    foreach ($key in $map.Keys) {
        $val = $map2[$key]
        Write-Host "Setting Value for $val -> $Value --> " -f DarkBlue -n
        $cmdres = Start-Process -FilePath "$pexe" -ArgumentList "-change", "$key", "$Value" -NoNewWindow -Wait -Passthru
        $ecode = $cmdres.ExitCode
        $pcpu = $cmdres.CPU -as [string]
        if ($ecode -eq 0) {
            Write-Host "SUCCESS after $pcpu" -f DarkGreen
        } else {
            Write-Host "FAILED" -f DarkRed
        }
    }
}

function Disable-SleepAndDisplayOff {
    [CmdletBinding(SupportsShouldProcess)]
    param()

    Write-Host "Disable Sleep and Display Off for All Power Plans (GLOBALLY)" -f DarkRed
    $pexe = (get-command -Name "powercfg.exe" -CommandType Application).Source
    foreach ($scheme in (powercfg /L | Select-String -Pattern "GUID" | ForEach-Object {
                ($_ -split ':')[1].Trim() -replace '\s\(.*', ''
            })) {
        Write-Host "Diable Sleep for $scheme" -f DarkCyan -n
        $cmdres = Start-Process -FilePath "$pexe" -ArgumentList "/SETACVALUEINDEX", "$scheme", "SUB_SLEEP", "STANDBYIDLE", "0" -NoNewWindow -Wait -Passthru
        $ecode = $cmdres.ExitCode
        $pcpu = $cmdres.CPU -as [string]
        if ($ecode -eq 0) {
            Write-Host "SUCCESS after $pcpu" -f DarkGreen
        } else {
            Write-Host "FAILED" -f DarkRed
        }

        Write-Host "Disable Display Off for $scheme " -f DarkCyan -n
        $cmdres = Start-Process -FilePath "$pexe" -ArgumentList "/SETACVALUEINDEX", "$scheme", "SUB_VIDEO", "VIDEOIDLE", "0" -NoNewWindow -Wait -Passthru
        $ecode = $cmdres.ExitCode
        $pcpu = $cmdres.CPU -as [string]
        if ($ecode -eq 0) {
            Write-Host "SUCCESS after $pcpu" -f DarkGreen
        } else {
            Write-Host "FAILED" -f DarkRed
        }

        Write-Host "Disable Sleep on Lid Close for $scheme " -f DarkCyan -n
        $cmdres = Start-Process -FilePath "$pexe" -ArgumentList "/SETACVALUEINDEX", "$scheme", "SUB_BUTTONS", "LIDACTION", "0" -NoNewWindow -Wait -Passthru
        $ecode = $cmdres.ExitCode
        $pcpu = $cmdres.CPU -as [string]
        if ($ecode -eq 0) {
            Write-Host "SUCCESS after $pcpu" -f DarkGreen
        } else {
            Write-Host "FAILED" -f DarkRed
        }

        Write-Host "Disable required password after stanbyidle for $scheme " -f DarkCyan -n
        $cmdres = Start-Process -FilePath "$pexe" -ArgumentList "/SETACVALUEINDEX", "$scheme", "SUB_NONE", "STANDBYIDLE", "0" -NoNewWindow -Wait -Passthru
        $ecode = $cmdres.ExitCode
        $pcpu = $cmdres.CPU -as [string]
        if ($ecode -eq 0) {
            Write-Host "SUCCESS after $pcpu" -f DarkGreen
        } else {
            Write-Host "FAILED" -f DarkRed
        }

        Write-Host "Disable required password after sleep for $scheme " -f DarkCyan -n
        $cmdres = Start-Process -FilePath "$pexe" -ArgumentList "/SETACVALUEINDEX", "$scheme", "SUB_NONE", "CONSOLELOCK", "0" -NoNewWindow -Wait -Passthru
        $ecode = $cmdres.ExitCode
        $pcpu = $cmdres.CPU -as [string]
        if ($ecode -eq 0) {
            Write-Host "SUCCESS after $pcpu" -f DarkGreen
        } else {
            Write-Host "FAILED" -f DarkRed
        }



        Write-Host "Disable the sleep button for $scheme " -f DarkCyan -n
        $cmdres = Start-Process -FilePath "$pexe" -ArgumentList "/SETACVALUEINDEX", "$scheme", "SUB_BUTTONS", "sButtonAction", "0" -NoNewWindow -Wait -Passthru
        $ecode = $cmdres.ExitCode
        $pcpu = $cmdres.CPU -as [string]
        if ($ecode -eq 0) {
            Write-Host "SUCCESS after $pcpu" -f DarkGreen
        } else {
            Write-Host "FAILED" -f DarkRed
        }

        Write-Host "SETACTIVE $scheme -> " -f DarkCyan -n
        $cmdres = Start-Process -FilePath "$pexe" -ArgumentList "/SETACTIVE", "$scheme" -NoNewWindow -Wait -Passthru
        $ecode = $cmdres.ExitCode
        $pcpu = $cmdres.CPU -as [string]
        if ($ecode -eq 0) {
            Write-Host "SUCCESS after $pcpu" -f DarkGreen
        } else {
            Write-Host "FAILED" -f DarkRed
        }
    }

}




function Disable-Hibernate {
    [CmdletBinding(SupportsShouldProcess)]
    param()

    Write-Host " Disable Hibernate " -f DarkCyan -n
    $pexe = (get-command -Name "powercfg.exe" -CommandType Application).Source
    $cmdres = Start-Process -FilePath "$pexe" -ArgumentList "-h", "off" -NoNewWindow -Wait -Passthru
    $ecode = $cmdres.ExitCode
    $pcpu = $cmdres.CPU -as [string]
    if ($ecode -eq 0) {
        Write-Host "SUCCESS after $pcpu" -f DarkGreen
    } else {
        Write-Host "FAILED" -f DarkRed
    }
}


function Disable-LockScreenTimeout {
    [CmdletBinding(SupportsShouldProcess)]
    param()

    Write-Host "Disable Lock Screen Timeout (for current user)" -f DarkCyan
    # Set screen saver timeout to 0 (disabled)
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "ScreenSaveTimeOut" -Value "0"
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "ScreenSaverIsSecure" -Value "0"
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "ScreenSaveActive" -Value "0"
}


function Disable-InactivityLock {
    [CmdletBinding(SupportsShouldProcess)]
    param()

    Write-Host "Prevent Inactivity Lock (local policy)" -f DarkCyan
    # Set idle time before requiring logon to 0
    New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "InactivityTimeoutSecs" -PropertyType DWord -Value 0 -Force

}


function Disable-AllPowerValues {
    [CmdletBinding(SupportsShouldProcess)]
    param()


    Get-PowerTimeouts

    Disable-InactivityLock
    Disable-Hibernate
    Disable-LockScreenTimeout
    Disable-SleepAndDisplayOff
    Set-PowerTimeouts


    Get-PowerTimeouts
}
