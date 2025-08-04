#╔════════════════════════════════════════════════════════════════════════════════╗
#║                                                                                ║
#║   Get-LoggedInUsers.ps1                                                        ║
#║                                                                                ║
#╟────────────────────────────────────────────────────────────────────────────────╢
#║   Guillaume Plante <codegp@icloud.com>                                         ║
#║   Code licensed under the GNU GPL v3.0. See the LICENSE file for details.      ║
#╚════════════════════════════════════════════════════════════════════════════════╝



function Get-LoggedInUsers {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    
    try {
        $PsLoggedonCmd = Get-Command "PsLoggedon64.exe" -ErrorAction Ignore
        if ($Null -eq $PsLoggedonCmd) {
            throw "no PsLoggedonCmd"
        }
        $PsLoggedonExe = $PsLoggedonCmd.Source


        [string[]]$Out = & "$PsLoggedonExe" '-l' '-x' '-nobanner'
        [string[]]$Users = $Out | select -Skip 1 | foreach { $_.Trim() }
        $Users -as [string[]]
    } catch {
        write-error "$_"
    }

}
