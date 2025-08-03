#╔════════════════════════════════════════════════════════════════════════════════╗
#║                                                                                ║
#║   moduleupdater.ps1                                                            ║
#║                                                                                ║
#╟────────────────────────────────────────────────────────────────────────────────╢
#║   Guillaume Plante <codegp@icloud.com>                                         ║
#║   Code licensed under the GNU GPL v3.0. See the LICENSE file for details.      ║
#╚════════════════════════════════════════════════════════════════════════════════╝



function Get-ClientToolsVersionPath {
    $ModPath = (Get-ClientToolsModuleInformation).ModuleInstallPath
    $VersionPath = Join-Path $ModPath 'version'
    return $VersionPath
}


function New-ClientToolsModuleVersionFile {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $false)]
        [switch]$Force
    )
    $ClientToolsVersionPath = Get-ClientToolsVersionPath
    $JsonPath = (Join-Path $ClientToolsVersionPath "clienttools.json")
    
    $ModuleName = (Get-ClientToolsModuleInformation).ModuleName
    $psm1path = (Get-ClientToolsModuleInformation).ModulePath
    $psd1path = $psm1path.Replace('.psm1','.psd1')
    $UpdateUrl = "https://arsscriptum.github.io/{0}" -f $ModuleName
    if ( (!(Test-Path "$JsonPath")) -Or ($Force)) {
        [PsCustomObject]$o = [PsCustomObject]@{
           CurrentVersion = "1.0.0"
           LastUpdate = "1754183026"
           UpdateUrl = "$UpdateUrl"
           VersionUrl = "$UpdateUrl/version.txt"
           AutoUpdate = $False
           LocalPSM1 = "$psm1path"
           LocalPSD1 = "$psd1path"
        }
        $NewFileJsonData = $o | ConvertTo-Json 
        New-Item -Path "$JsonPath" -ItemType File -Force -EA Stop -Value $NewFileJsonData | Out-Null
    }
    
}



function Test-ClientToolsUpdated {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $false)]
        [switch]$Force
    )
    $ClientToolsVersionPath = Get-ClientToolsVersionPath
    $JsonPath = (Join-Path $ClientToolsVersionPath "clienttools.json")

    if (!(Test-Path "$JsonPath")) {
        Write-Verbose "no such file $JsonPath... "
        New-ClientToolsModuleVersionFile
    }

    $Data = Get-Content "$JsonPath" | ConvertFrom-Json

    $Data.CurrentVersion

    $Data.UpdateUrl

}

