#╔════════════════════════════════════════════════════════════════════════════════╗
#║                                                                                ║
#║   make.ps1                                                            ║
#║                                                                                ║
#╟────────────────────────────────────────────────────────────────────────────────╢
#║   Guillaume Plante <codegp@icloud.com>                                         ║
#║   Code licensed under the GNU GPL v3.0. See the LICENSE file for details.      ║
#╚════════════════════════════════════════════════════════════════════════════════╝


[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory = $False,position=0)]
    [ValidateSet('min', 'all', 'doc','deploy')]
    [string]$Type='min'
)

function Update-VersionNumber {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $false, HelpMessage = "Which part of the version to increment: Major, Minor, or Patch.")]
        [ValidateSet("Major", "Minor", "Patch")]
        [string]$Part = "Patch"
    )

    $versionFile = Join-Path (Get-Location) 'Version.nfo'

    if (-not (Test-Path $versionFile)) {
        throw "Version file not found: $versionFile"
    }

    $version = Get-Content $versionFile -ErrorAction Stop | Select-Object -First 1
    if ($version -notmatch '^\d+\.\d+\.\d+$') {
        throw "Invalid version format in $versionFile. Expected format: Major.Minor.Patch (e.g., 1.0.3)"
    }

    $parts = $version -split '\.'
    $major = [int]$parts[0]
    $minor = [int]$parts[1]
    $patch = [int]$parts[2]

    switch ($Part.ToLower()) {
        "major" {
            $major++
            $minor = 0
            $patch = 0
        }
        "minor" {
            $minor++
            $patch = 0
        }
        "patch" {
            $patch++
        }
    }

    $newVersion = [Version]::new($major, $minor, $patch)
    $newVersionStr = $newVersion.ToString()
    Set-Content -Path $versionFile -Value $newVersionStr -Encoding UTF8
    Write-Host "Updated version: $version → $newVersionStr" -ForegroundColor Green
    $newVersionStr
}


function Update-ModuleVersionFile {
    [CmdletBinding(SupportsShouldProcess)]
    param()

    $CurrentPath        = (Get-Location).ProviderPath
    $SrcPath            = Join-Path $CurrentPath 'src'
    $VersionFilePath    = Join-Path $CurrentPath 'Version.nfo'
    $TemplateFilePath   = Join-Path $CurrentPath 'ModuleVersion.tpl'
    $OutputFilePath     = Join-Path $SrcPath 'ModuleVersion.ps1'

    # Validate file existence
    foreach ($file in @($VersionFilePath, $TemplateFilePath)) {
        if (-not (Test-Path $file)) {
            throw "Required file not found: $file"
        }
    }

    # Read version
    [Version]$Version = Get-Content -Path $VersionFilePath -ErrorAction Stop | Select-Object -First 1
    if (-not ($Version)) {
        throw "Version file is empty or invalid: $VersionFilePath"
    }

    # Read and replace template content
    $Template = Get-Content -Path $TemplateFilePath -Raw -ErrorAction Stop
    $UpdatedContent = $Template -replace '___MODULE_VERSION_STRING____', $Version.ToString()

    # Write to output file
    Set-Content -Path $OutputFilePath -Value $UpdatedContent -Encoding UTF8 -Force
    Write-Host "Updated module version written to: $OutputFilePath" -ForegroundColor Green
    $OutputFilePath
}

$CurrentPath        = (Get-Location).ProviderPath
$VersionFilePath    = Join-Path $CurrentPath 'Version.nfo'
$VersionFileTmpPath    = Join-Path $CurrentPath 'Version.tmp'
$newVersion = Update-VersionNumber
Copy-Item $VersionFilePath $VersionFileTmpPath -Force
$OutputFilePath = Update-ModuleVersionFile
. "$OutputFilePath"

$ModuleVersion = Get-ClientToolsModuleVersion

Set-ClientToolsAutoUpdateOverride -Enable $True

if($Type -eq 'min'){
  make -NoUpdateVersion    
}elseif($Type -eq 'all'){
  makeall -NoUpdateVersion
}elseif($Type -eq 'doc'){
    make -Documentation -NoUpdateVersion
}elseif($Type -eq 'deploy'){
    make -Publish -PowerShellGallery -Deploy -NoUpdateVersion
}else{
    Write-Host "Error" -f DarkRed
}

Set-ClientToolsAutoUpdateOverride -Enable $False



Write-Host "Updated module version $newVersion" -ForegroundColor Green

Copy-Item $VersionFileTmpPath $VersionFilePath -Force
Remove-Item $VersionFileTmpPath -Force 