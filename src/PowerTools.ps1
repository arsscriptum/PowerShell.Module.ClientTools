
#╔════════════════════════════════════════════════════════════════════════════════╗
#║                                                                                ║
#║   powertools.ps1                                                               ║
#║                                                                                ║
#╟────────────────────────────────────────────────────────────────────────────────╢
#║   Guillaume Plante <codegp@icloud.com>                                         ║
#║   Code licensed under the GNU GPL v3.0. See the LICENSE file for details.      ║
#╚════════════════════════════════════════════════════════════════════════════════╝



function Get-PowerCfgLanguage {
    $output = powercfg /query

    if ($output -match "Index actuel du param.*courant altern") {
        return "fr"
    }
    elseif ($output -match "Power Setting Index") {
        return "en"
    }
    else {
        return "unknown"
    }
}


function Get-PowerTimeouts {
    [CmdletBinding(SupportsShouldProcess)]
    param()

    begin {
        [string]$Language = Get-PowerCfgLanguage
        Write-Verbose "Starting localized action with language: $Language"
    }

    process {
        switch ($Language) {
            'en' {
                $pattern = "Current AC Power Setting Index: (.+)"
            }
            'fr' {
                $pattern = "Index actuel du par.*courant altern"
            }
        }

        $map = @{
            "VIDEOIDLE" = "Display Timeout (monitor-timeout-ac)"
            "DISKIDLE" = "Disk Timeout (disk-timeout-ac)"
            "STANDBYIDLE" = "Sleep Timeout (standby-timeout-ac)"
            "HIBERNATEIDLE" = "Hibernate Timeout (hibernate-timeout-ac)"
        }
        $pexe = (get-command -Name "powercfg.exe" -CommandType Application).Source

        $schemetmp = & "$pexe" '/query'
        $scheme = $schemetmp.Split(':')[1].Split('(')[0].Trim()
        $output = & "$pexe" '/query' "$scheme"

        foreach ($key in $map.Keys) {
            $found = $True
            [uint32]$seconds = 0
            [uint32]$minutes = 0
            $desc = $map[$key]
            Write-Host "[Get-PowerTimeouts] " -f DarkRed -n
            $setting = $output -split "`r?`n" | Select-String -Context 0, 6 -Pattern $key
            if ($setting) {
                $valueLine = $setting.Context.PostContext | Where-Object { $_ -match $pattern }
                if ($valueLine) {
                    [uint32]$seconds = [convert]::ToInt32(($valueLine -replace '.*: ', '').Trim(), 16) -as [uint32]
                    [uint32]$minutes = [math]::Round($seconds / 60, 1) -as [uint32]
                    $logstr = "{0:d4}s`t({1:d2} min)`t{2}" -f $seconds, $minutes, $desc
                }else{
                    $found = $false
                }
            } else {
                $found = $false
            }
            if($found){
                Write-Host "$logstr" -f DarkYellow
            }else{
                $logstr = " n/a`t{2}" -f $minutes, $seconds, $desc
                Write-Host "$logstr" -f DarkRed
            }
        }

    }
    end {
        Write-Verbose "Finished localized action."
    }
}



function Set-PowerTimeouts {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $false)]
        [int]$Value = 0
    )
    $map = @{
        "-monitor-timeout-ac" = "Never turn off screen (AC)"
        "-disk-timeout-ac" = "Never turn off hard disks (AC)"
        "-standby-timeout-ac" = "Never sleep (AC)"
        "-hibernate-timeout-ac" = "Disable hibernate (AC)"
    }
    $pexe = (get-command -Name "powercfg.exe" -CommandType Application).Source

    foreach ($key in $map.Keys) {
        $val = $map[$key]
        Write-Host "Setting Value for $val -> $Value --> " -f DarkBlue -n
        $cmdres = Start-Process -FilePath "$pexe" -ArgumentList "-change", "$key", "$Value" -NoNewWindow -Wait -Passthru
        $ecode = $cmdres.ExitCode
        $pcpu = $cmdres.CPU -as [string]
        if ($ecode -eq 0) {
            Write-Host "SUCCESS after $pcpu" -f DarkGreen
        } else {
            Write-Host "FAILED. Returned `"$errmsg`"" -f DarkRed
        }
    }
}

function Disable-SleepAndDisplayOff {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    $outfile_std = Join-Path "$ENV:Temp" "stdout.txt"
    $outfile_err = Join-Path "$ENV:Temp" "stderr.txt"
    Invoke-TouchFile $outfile_std
    Invoke-TouchFile $outfile_err
    Write-Host "Disable Sleep and Display Off for All Power Plans (GLOBALLY)" -f DarkRed
    $pexe = (get-command -Name "powercfg.exe" -CommandType Application).Source
    foreach ($scheme in (powercfg /L | Select-String -Pattern "GUID" | ForEach-Object {
                ($_ -split ':')[1].Trim() -replace '\s\(.*', ''
            })) {

        Write-Host "PROCESSING SCHEME $scheme" -f DarkYellow

        Write-Host " -> Disable Sleep for $scheme" -f DarkCyan -n
        $cmdres = Start-Process -FilePath "$pexe" -ArgumentList "/SETACVALUEINDEX", "$scheme", "SUB_SLEEP", "STANDBYIDLE", "0" -NoNewWindow -Wait -Passthru -RedirectStandardError $outfile_err -RedirectStandardOutput $outfile_std
        $ecode = $cmdres.ExitCode
        $pcpu = $cmdres.CPU -as [string]
        if ($ecode -eq 0) {
            Write-Host "SUCCESS after $pcpu" -f DarkGreen
        } else {
            Write-Host "FAILED. Returned `"$errmsg`"" -f DarkRed
        }

        Write-Host " -> Disable Display Off for $scheme " -f DarkCyan -n
        $cmdres = Start-Process -FilePath "$pexe" -ArgumentList "/SETACVALUEINDEX", "$scheme", "SUB_VIDEO", "VIDEOIDLE", "0" -NoNewWindow -Wait -Passthru -RedirectStandardError $outfile_err -RedirectStandardOutput $outfile_std
        $ecode = $cmdres.ExitCode
        $pcpu = $cmdres.CPU -as [string]
        if ($ecode -eq 0) {
            Write-Host "SUCCESS after $pcpu" -f DarkGreen
        } else {
            Write-Host "FAILED. Returned `"$errmsg`"" -f DarkRed
        }

        Write-Host " -> Disable Sleep on Lid Close for $scheme " -f DarkCyan -n
        $cmdres = Start-Process -FilePath "$pexe" -ArgumentList "/SETACVALUEINDEX", "$scheme", "SUB_BUTTONS", "LIDACTION", "0" -NoNewWindow -Wait -Passthru -RedirectStandardError $outfile_err -RedirectStandardOutput $outfile_std
        $ecode = $cmdres.ExitCode
        $pcpu = $cmdres.CPU -as [string]
        if ($ecode -eq 0) {
            Write-Host "SUCCESS after $pcpu" -f DarkGreen
        } else {
            Write-Host "FAILED. Returned `"$errmsg`"" -f DarkRed
        }

        Write-Host " -> Disable required password after stanbyidle for $scheme " -f DarkCyan -n
        $cmdres = Start-Process -FilePath "$pexe" -ArgumentList "/SETACVALUEINDEX", "$scheme", "SUB_NONE", "STANDBYIDLE", "0" -NoNewWindow -Wait -Passthru -RedirectStandardError $outfile_err -RedirectStandardOutput $outfile_std
        $ecode = $cmdres.ExitCode
        $pcpu = $cmdres.CPU -as [string]
        if ($ecode -eq 0) {
            Write-Host "SUCCESS after $pcpu" -f DarkGreen
        } else {
            Write-Host "FAILED. Returned `"$errmsg`"" -f DarkRed
        }

        Write-Host " -> Disable required password after sleep for $scheme " -f DarkCyan -n
        $cmdres = Start-Process -FilePath "$pexe" -ArgumentList "/SETACVALUEINDEX", "$scheme", "SUB_NONE", "CONSOLELOCK", "0" -NoNewWindow -Wait -Passthru -RedirectStandardError $outfile_err -RedirectStandardOutput $outfile_std
        $ecode = $cmdres.ExitCode
        $pcpu = $cmdres.CPU -as [string]
        if ($ecode -eq 0) {
            Write-Host "SUCCESS after $pcpu" -f DarkGreen
        } else {
            Write-Host "FAILED. Returned `"$errmsg`"" -f DarkRed
        }



        Write-Host " -> Disable the sleep button for $scheme " -f DarkCyan -n
        $cmdres = Start-Process -FilePath "$pexe" -ArgumentList "/SETACVALUEINDEX", "$scheme", "SUB_BUTTONS", "sButtonAction", "0" -NoNewWindow -Wait -Passthru -RedirectStandardError $outfile_err -RedirectStandardOutput $outfile_std
        $ecode = $cmdres.ExitCode
        $pcpu = $cmdres.CPU -as [string]
        if ($ecode -eq 0) {
            Write-Host "SUCCESS after $pcpu" -f DarkGreen
        } else {
            $errmsg = Get-Content $outfile_err -Raw
            Write-Host "FAILED. Returned `"$errmsg`"" -f DarkRed
        }

        Write-Host " -> SETACTIVE $scheme -> " -f DarkCyan -n
        $cmdres = Start-Process -FilePath "$pexe" -ArgumentList "/SETACTIVE", "$scheme" -NoNewWindow -Wait -Passthru -RedirectStandardError $outfile_err -RedirectStandardOutput $outfile_std
        $ecode = $cmdres.ExitCode
        $pcpu = $cmdres.CPU -as [string]
        if ($ecode -eq 0) {
            Write-Host "SUCCESS after $pcpu" -f DarkGreen
        } else {
            Write-Host "FAILED. Returned `"$errmsg`"" -f DarkRed
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
        Write-Host "FAILED. Returned `"$errmsg`"" -f DarkRed
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
