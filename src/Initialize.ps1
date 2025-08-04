#╔════════════════════════════════════════════════════════════════════════════════╗
#║                                                                                ║
#║   initialize.ps1                                                               ║
#║                                                                                ║
#╟────────────────────────────────────────────────────────────────────────────────╢
#║   Guillaume Plante <codegp@icloud.com>                                         ║
#║   Code licensed under the GNU GPL v3.0. See the LICENSE file for details.      ║
#╚════════════════════════════════════════════════════════════════════════════════╝


function Uninitialize-ClientToolsModule {
    [CmdletBinding(SupportsShouldProcess)]
    param()
} 


function Initialize-ClientToolsModule {
    [CmdletBinding(SupportsShouldProcess)]
    param() 

    
}

function AutoInitialize-ClientToolsModule {
    [CmdletBinding(SupportsShouldProcess)]
    param() 

    New-ClientToolsModuleVersionFile -AutoUpdateFlag $True -Force
}
