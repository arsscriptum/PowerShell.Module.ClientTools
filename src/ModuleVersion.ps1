#╔════════════════════════════════════════════════════════════════════════════════╗
#║                                                                                ║
#║   moduleupdater.ps1                                                            ║
#║                                                                                ║
#╟────────────────────────────────────────────────────────────────────────────────╢
#║   Guillaume Plante <codegp@icloud.com>                                         ║
#║   Code licensed under the GNU GPL v3.0. See the LICENSE file for details.      ║
#╚════════════════════════════════════════════════════════════════════════════════╝



function Get-ClientToolsModuleVersion {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $false)]
        [switch]$Latest
    )

    if($Latest){
        $ClientToolsVersionPath = Get-ClientToolsModuleVersionPath
        $JsonPath = Join-Path $ClientToolsVersionPath "clienttools.json"

        if (!(Test-Path $JsonPath)) {
            Write-Error "module not initialized! no file $JsonPath"
            return $Null
        }

        [version]$CurrVersion = Get-ClientToolsModuleVersion

        $Data = Get-Content $JsonPath | ConvertFrom-Json
        [version]$LatestVersion = Invoke-RestMethod -Uri "$($Data.VersionUrl)"
        return $LatestVersion.ToString()
    }

    $Version = "1.4.16"
    return $Version
}

