#╔════════════════════════════════════════════════════════════════════════════════╗
#║                                                                                ║
#║   deploy.ps1                                                                     ║
#║                                                                                ║
#╟────────────────────────────────────────────────────────────────────────────────╢
#║   Guillaume Plante <codegp@icloud.com>                                         ║
#║   Code licensed under the GNU GPL v3.0. See the LICENSE file for details.      ║
#╚════════════════════════════════════════════════════════════════════════════════╝

# Resolve paths
$CurrentPath = (Resolve-Path ".").Path
$OutPath     = (Resolve-Path "./out").Path
$TargetPath  = (Resolve-Path "../CTLive").Path

Write-Host "Current Path : $CurrentPath"
Write-Host "Out Path     : $OutPath"
Write-Host "Target Path  : $TargetPath"

# Copy *.psd1 and *.psm1 from ./out to ../CTLive
$moduleFiles = Get-ChildItem -Path $OutPath -Include *.psd1, *.psm1 -File
foreach ($file in $moduleFiles) {
    $dest = Join-Path $TargetPath $file.Name
    Write-Host "Copying $($file.Name) to $TargetPath"
    Copy-Item -Path $file.FullName -Destination $dest -Force
}

# Copy Version.nfo from current path to ../CTLive
$versionFile = Join-Path $CurrentPath "Version.nfo"
if (Test-Path $versionFile) {
    $dest = Join-Path $TargetPath "Version.nfo"
    Write-Host "Copying Version.nfo to $TargetPath"
    Copy-Item -Path $versionFile -Destination $dest -Force
} else {
    Write-Warning "Version.nfo not found in $CurrentPath"
}

# Run gpush in ../CTLive
Push-Location $TargetPath
try {
    Write-Host "Running gpush in $TargetPath..."
    gpush
}
finally {
    Pop-Location
}
