#╔════════════════════════════════════════════════════════════════════════════════╗
#║                                                                                ║
#║   ConfigureWindowsTerminal.ps1                                                 ║
#║   configure the windows terminal settings.json                                 ║
#║                                                                                ║
#╟────────────────────────────────────────────────────────────────────────────────╢
#║   Guillaume Plante <codegp@icloud.com>                                         ║
#║   Code licensed under the GNU GPL v3.0. See the LICENSE file for details.      ║
#╚════════════════════════════════════════════════════════════════════════════════╝


function Get-WindowsTerminalConfigPath {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    try {
        $Path = "$ENV:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
        $Settings = "settings.json"

        if (-not (Test-Path -Path "$Path" -PathType Container)) { throw "no such directory" }

        $Fullname = Join-Path $Path $Settings

        if (-not (Test-Path -Path "$Fullname" -PathType Leaf)) { throw "no such directory" }
        $Fullname
    } catch {
        Write-Error "$_"
    }
}


function Get-WindowsTerminalProfilePath {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    try {
        $Path = "$env:ProfilePath\wt"
        $Settings = "settings.json"

        if (-not (Test-Path -Path "$Path" -PathType Container)) { throw "no such directory $Path" }

        $Fullname = Join-Path $Path $Settings
        $Fullname
    } catch {
        Write-Error "$_"
    }
}


function Edit-TerminalConfig {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    try {
        $Path = Get-WindowsTerminalConfigPath
        Invoke-Sublime -Paths $Path


    } catch {
        Write-Error "$_"
    }
}



function Save-TerminalConfig {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    try {
        $Path = Get-WindowsTerminalConfigPath
        $WtPath = Get-WindowsTerminalProfilePath
        Copy-Item -Path "$Path" -Destination "$WtPath" -Verbose -Force

        Push-ProfilePath
        git add 'wt/settings.json'
        git commit 'wt/settings.json' -m "update wt settings"
        git push
    } catch {
        Write-Error "$_"
    }
}
