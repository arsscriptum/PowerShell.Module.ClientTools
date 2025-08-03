#╔════════════════════════════════════════════════════════════════════════════════╗
#║                                                                                ║
#║   UpdateLoginScripts.ps1                                                       ║
#║                                                                                ║
#╟────────────────────────────────────────────────────────────────────────────────╢
#║   Guillaume Plante <codegp@icloud.com>                                         ║
#║   Code licensed under the GNU GPL v3.0. See the LICENSE file for details.      ║
#╚════════════════════════════════════════════════════════════════════════════════╝



function Update-LoginScripts {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $false, Position = 0)]
        [string]$scriptFolder = "C:\Programs\Scripts\Login"
    )
    $registryPath = "HKCU:\Software\arsscriptum\ProxyAssistant"
    $registryKey = "PowerShellScripts"


    # Ensure the registry path exists
    if (-not (Test-Path $registryPath)) {
        New-Item -Path $registryPath -Force | Out-Null
    }

    # Get all script files (*.ps1) in the specified folder
    $scriptFiles = Get-ChildItem -Path $scriptFolder -Filter "*.ps1" | ForEach-Object { $_.FullName }

    # Set the registry key as REG_MULTI_SZ (array of strings)
    Set-ItemProperty -Path $registryPath -Name $registryKey -Value $scriptFiles -Type MultiString

}
