#╔════════════════════════════════════════════════════════════════════════════════╗
#║                                                                                ║
#║   initialize.ps1                                                               ║
#║                                                                                ║
#╟────────────────────────────────────────────────────────────────────────────────╢
#║   Guillaume Plante <codegp@icloud.com>                                         ║
#║   Code licensed under the GNU GPL v3.0. See the LICENSE file for details.      ║
#╚════════════════════════════════════════════════════════════════════════════════╝


function Uninitialize-ClientToolsModule{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true,Position=0)][String]$Password
    ) 
    $TestMode = $False

    if ( ($PSBoundParameters.ContainsKey('WhatIf') -Or($PSBoundParameters.ContainsKey('Test')))) {
        Write-Host '[Uninitialize-ClientToolsModule] ' -f DarkRed -NoNewLine
        Write-Host "TEST ONLY" -f DarkYellow            
        $TestMode = $True

        Register-AppCredentials -Id (Get-ClientToolsUserCredentialID) -Username '_' -Password '_' -WhatIf
        Register-AppCredentials -Id (Get-ClientToolsAppCredentialID) -Username '_' -Password '_' -WhatIf
        return
    }

    Register-AppCredentials -Id (Get-ClientToolsUserCredentialID) -Username '_' -Password '_'
    Register-AppCredentials -Id (Get-ClientToolsAppCredentialID) -Username '_' -Password '_'
} 



function Initialize-ClientToolsModule{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true,Position=0)][String]$Username,
        [Parameter(Mandatory=$true,Position=1)][String]$OrgId,
        [Parameter(Mandatory=$true,Position=2)][String]$ApiKey
    ) 

    Register-AppCredentials -Id (Get-ClientToolsUserCredentialID) -Username $Username -Password '_'
    Register-AppCredentials -Id (Get-ClientToolsAppCredentialID) -Username $OrgId -Password $ApiKey


}
