#╔════════════════════════════════════════════════════════════════════════════════╗
#║                                                                                ║
#║   GetCurrentContext.ps1                                                        ║
#║                                                                                ║
#╟────────────────────────────────────────────────────────────────────────────────╢
#║   Guillaume Plante <codegp@icloud.com>                                         ║
#║   Code licensed under the GNU GPL v3.0. See the LICENSE file for details.      ║
#╚════════════════════════════════════════════════════════════════════════════════╝



function Get-CurrentContext {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal ([Security.Principal.WindowsIdentity]::GetCurrent())
    $env:principalName = $currentPrincipal.Identities.Name
    if (!$currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        return $false
    }
    return $true

}

New-alias -Name isadmin -Value Get-CurrentContext -Scope 'Global' -ErrorAction 'Ignore'
