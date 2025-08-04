#╔════════════════════════════════════════════════════════════════════════════════╗
#║                                                                                ║
#║   Prompt.ps1                                                                   ║
#║                                                                                ║
#╟────────────────────────────────────────────────────────────────────────────────╢
#║   Guillaume Plante <codegp@icloud.com>                                         ║
#║   Code licensed under the GNU GPL v3.0. See the LICENSE file for details.      ║
#╚════════════════════════════════════════════════════════════════════════════════╝



function Show-PromptNoPath {
    [CmdletBinding(SupportsShouldProcess)]
    param()

    $currentpath = (Get-Location).Path
    $IsAdmin = Invoke-IsAdministrator
    if ($PSVersionTable.PSVersion.Major -eq 5) {
        Write-Host ("ˡᵉᵍᵃᶜʸ⁵") -NoNewline -ForegroundColor DarkCyan
        if ($IsAdmin) { write-host "ᵃᵈᵐⁱⁿ" -f Darkred -NoNewline }
    } else {
        Write-Host ("ᶜᵒʳᵉ⁷") -NoNewline -ForegroundColor DarkCyan
        #Write-Host ("cͨoͦrͬeͤ7") -nonewline -foregroundcolor DarkCyan
        if ($IsAdmin) { write-host "ᵃᵈᵐⁱⁿ" -f Darkred -NoNewline }
    }

    Write-Host (" >") -NoNewline -ForegroundColor DarkGray
    return " "
}


function Invoke-IsAdministrator {
    [CmdletBinding(SupportsShouldProcess)]
    param()

    $user = [Security.Principal.WindowsIdentity]::GetCurrent();
    (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}


function Show-SystemInfo {
    [CmdletBinding(SupportsShouldProcess)]
    param()

    ProfileInfo
}

function Invoke-IsAdministrator {
    [CmdletBinding(SupportsShouldProcess)]
    param()

    $user = [Security.Principal.WindowsIdentity]::GetCurrent();
    (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

function Show-Header {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    $m = $PSVersionTable.PSVersion.Major
    try {
        if ($m -gt 5) {
            Write-Host "`n`n`n"
            Write-Host "                                                  PЯӨGЯΛMMIПG ƬΣЯMIПΛᄂ" -f DarkRed
            Write-Host "                                     ░b░a░s░h░|░ ░p░o░w░e░r░s░h░e░l░l░ ░|░ ░d░o░s░ ░ " -f DarkRed
            Write-Host "`n`n`n"
        } else {
            Write-Host "Window Terminal - PowerShell - Dos - VS"
        }
    } catch [Exception]{
        $Msg = "LOADER Error: $($PSItem.ToString())"
        Write-Error $Msg
    }
}



function Show-Prompt {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    
    $currentpath = (Get-Location).Path
    $IsAdmin = Invoke-IsAdministrator
    if ($PSVersionTable.PSVersion.Major -eq 5) {
        Write-Host ("ˡᵉᵍᵃᶜʸ⁵") -NoNewline -ForegroundColor DarkCyan
        if ($IsAdmin) { write-host "ᵃᵈᵐⁱⁿ" -f Darkred -NoNewline }
    } else {



        if ($IsAdmin) {
            Write-Host ("ᶜᵒʳᵉ⁷") -NoNewline -ForegroundColor DarkYellow
            write-host " < ᵃᵈᵐⁱⁿ > " -f Darkred -NoNewline
        } else {
            Write-Host ("ᶜᵒʳᵉ⁷") -NoNewline -ForegroundColor DarkCyan
        }
    }

    Write-Host ("$currentpath>") -NoNewline -ForegroundColor DarkGray
    return " "
}


function Set-SmallPrompt {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    try {
        #Write-Host "New-Alias 'prompt' Show-PromptNoPath -force -Scope Global -option allscope" -f Darkred
        New-Alias 'prompt' Show-PromptNoPath -Force -Scope Global -Option allscope
    } catch {
        write-Warning -Message "$_"
    }
}
function Reset-Prompt {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    try {
        #Write-Host "New-Alias 'prompt' Show-Prompt -force -Scope Global -option allscope" -f Darkred
        New-Alias 'prompt' Show-Prompt -Force -Scope Global -Option allscope
    } catch {
        write-Warning -Message "$_"
    }
}




function Start-Explorer {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    $xplorer = 'C:\Windows\explorer.exe'
    $localpath = (Get-Location).Path
    & $xplorer $localpath
}
