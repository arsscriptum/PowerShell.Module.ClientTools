#╔════════════════════════════════════════════════════════════════════════════════╗
#║                                                                                ║
#║   moduleupdater.ps1                                                            ║
#║                                                                                ║
#╟────────────────────────────────────────────────────────────────────────────────╢
#║   Guillaume Plante <codegp@icloud.com>                                         ║
#║   Code licensed under the GNU GPL v3.0. See the LICENSE file for details.      ║
#╚════════════════════════════════════════════════════════════════════════════════╝



function Get-ClientToolsModuleVersionPath {
    $ModPath = (Get-ClientToolsModuleInformation).ModuleInstallPath
    $VersionPath = Join-Path $ModPath 'version'
    return $VersionPath
}


function New-ClientToolsModuleVersionFile {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $false)]
        [bool]$AutoUpdateFlag,
        [Parameter(Mandatory = $false)]
        [switch]$Force
    )
    $ClientToolsVersionPath = Get-ClientToolsModuleVersionPath
    $JsonPath = (Join-Path $ClientToolsVersionPath "clienttools.json")
    $CurrDate = Get-Date -UFormat "%s"
    $ModuleName = (Get-ClientToolsModuleInformation).ModuleName.Name
    $ModuleInstallPath = (Get-ClientToolsModuleInformation).ModuleInstallPath
    $ModulePath = (Get-ClientToolsModuleInformation).ModulePath

    $psm1path = (Join-Path "$ModuleInstallPath" "$ModuleName") + '.psm1'
    $psd1path =  (Join-Path "$ModuleInstallPath" "$ModuleName") + '.psd1'

    $ValidFiles = ((Test-Path "$psm1path") -And (Test-Path "$psd1path"))
    if(!$ValidFiles){
        Write-Error "Missing Module File"
    }


    $UpdateUrl = "https://arsscriptum.github.io/{0}" -f $ModuleName
    $VersionUrl = "https://arsscriptum.github.io/{0}/{1}" -f $ModuleName, "Version.nfo"
    $CurrVersion = Get-ClientToolsModuleVersion
    if ((!(Test-Path "$JsonPath")) -or ($Force)) {
        [pscustomobject]$o = [pscustomobject]@{
            CurrentVersion = "$CurrVersion"
            LastUpdate = "$CurrDate"
            UpdateUrl = "$UpdateUrl"
            VersionUrl = "$VersionUrl"
            ModuleName = "$ModuleName"
            AutoUpdate = $AutoUpdateFlag
            LocalPSM1 = "$psm1path"
            LocalPSD1 = "$psd1path"
        }
        $NewFileJsonData = $o | ConvertTo-Json
        New-Item -Path "$JsonPath" -ItemType File -Force -EA Stop -Value $NewFileJsonData | Out-Null
    }

}



function Invoke-ClientToolsAutoUpdate {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $false)]
        [switch]$Force
    )
    $ClientToolsVersionPath = Get-ClientToolsModuleVersionPath
    $JsonPath = Join-Path $ClientToolsVersionPath "clienttools.json"

    if (!(Test-Path $JsonPath)) {
        Write-Verbose "No such file $JsonPath... creating default version file."
        New-ClientToolsModuleVersionFile
    }

    [version]$CurrVersion = Get-ClientToolsModuleVersion

    $Data = Get-Content $JsonPath | ConvertFrom-Json
    if ($Data.AutoUpdate) {
        try {
            [version]$LatestVersion = Invoke-RestMethod -Uri "$($Data.VersionUrl)"
        } catch {
            Write-Warning "Cannot Update -> No Version at $LatestVersion"
            return
        }
        Write-Verbose "CurrVersion    $CurrVersion"
        Write-Verbose "LatestVersion  $LatestVersion"
        $UpdateRequired = (($LatestVersion -gt $CurrVersion) -Or ($Force))
        if($UpdateRequired) {
            Write-Verbose "Should Update -> Yes"

            $psm1path = $Data.LocalPSM1
            $psd1path = $Data.LocalPSD1
            $Psd1Url = "{0}/{1}.psd1" -f $Data.UpdateUrl, $Data.ModuleName
            $Psm1Url = "{0}/{1}.psm1" -f $Data.UpdateUrl, $Data.ModuleName

            Write-Verbose "Downloading $Psd1Url -> $psd1path"
            Invoke-WebRequest -Uri $Psd1Url -OutFile $psd1path -UseBasicParsing -ErrorAction Stop

            Write-Verbose "Downloading $Psm1Url -> $psm1path"
            Invoke-WebRequest -Uri $Psm1Url -OutFile $psm1path -UseBasicParsing -ErrorAction Stop

            # Update the version in the local json
            $Data.CurrentVersion = $LatestVersion.ToString()
            $Data | ConvertTo-Json -Depth 4 | Set-Content -Path $JsonPath -Encoding UTF8

            Write-ClientToolsHost "Module successfully updated to version $LatestVersion"
        }
        else {
            Write-Verbose "Should Update -> No"
            Write-ClientToolsHost "No Update Required. Current Version is $CurrVersion"
            if ($NoUpdate) {
                return $false
            }
        }
    }
}
