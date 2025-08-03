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
        [bool]$AutoUpdateFlag,
        [Parameter(Mandatory = $false)]
        [switch]$Force
    )
    $ClientToolsVersionPath = Get-ClientToolsVersionPath
    $JsonPath = (Join-Path $ClientToolsVersionPath "clienttools.json")
    $CurrDate = Get-Date -UFormat "%s"
    $ModuleName = (Get-ClientToolsModuleInformation).ModuleName
    $psm1path = (Get-ClientToolsModuleInformation).ModulePath
    $psd1path = $psm1path.Replace('.psm1', '.psd1')
    $UpdateUrl = "https://arsscriptum.github.io/{0}" -f $ModuleName
    $VersionUrl = "https://arsscriptum.github.io/{0}/{1}" -f $ModuleName, "Version.nfo"
    if ((!(Test-Path "$JsonPath")) -or ($Force)) {
        [pscustomobject]$o = [pscustomobject]@{
            CurrentVersion = "1.0.0"
            LastUpdate = "CurrDate"
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
        [switch]$NoUpdate
    )
    $ClientToolsVersionPath = Get-ClientToolsVersionPath
    $JsonPath = Join-Path $ClientToolsVersionPath "clienttools.json"

    if (!(Test-Path $JsonPath)) {
        Write-Verbose "No such file $JsonPath... creating default version file."
        New-ClientToolsModuleVersionFile
    }

    $Data = Get-Content $JsonPath | ConvertFrom-Json
    if ($Data.AutoUpdate) {
        [version]$CurrVersion = $Data.CurrentVersion
        try {
            [version]$LatestVersion = Invoke-RestMethod -Uri "$($Data.VersionUrl)"
        } catch {
            Write-Warning "Cannot Update -> No Version at $LatestVersion"
            return
        }
        Write-Verbose "CurrVersion    $CurrVersion"
        Write-Verbose "LatestVersion  $LatestVersion"

        if ($LatestVersion -gt $CurrVersion) {
            Write-Verbose "Should Update -> Yes"

            if ($NoUpdate) {
                return $true
            }

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
            Import-Module "$($Data.ModuleName)" -Force
        }
        else {
            Write-Verbose "Should Update -> No"
            Write-ClientToolsHost "No Update Required"
            if ($NoUpdate) {
                return $false
            }
        }
    }
}
