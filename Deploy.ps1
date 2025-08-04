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


Write-Host "Current Path : $CurrentPath"
Write-Host "Out Path     : $OutPath"
Write-Host "Target Path  : $TargetPath"

[version]$CurrVersionStruct = Get-ClientToolsModuleVersion
[string]$CurrVersion = $CurrVersionStruct.ToString()

$srcpsd1path = Join-Path $OutPath "PowerShell.Module.ClientTools.psd1"
$srcpsm1path = Join-Path $OutPath "PowerShell.Module.ClientTools.psm1"


$dstpsd1path = Join-Path $TargetPath "PowerShell.Module.ClientTools.psd1"
$dstpsm1path = Join-Path $TargetPath "PowerShell.Module.ClientTools.psm1"

$psd1VersionBefore = get-content $dstpsd1path | Select-String "ModuleVersion " -Raw
if([string]::IsNullOrEmpty($psd1VersionBefore)){
   write-warning "NoVersion in PSd1"
}else{
    $psd1VersionBefore = $psd1VersionBefore.Split('=')[1].Replace("'",'').Trim()
}


$newVersionFile = Join-Path $TargetPath "Version.nfo"
Write-Host "Current  Version : $CurrVersion"
Write-Host "Updating Version File : $newVersionFile"
Set-Content -Path "$newVersionFile" -Value "$CurrVersion" -Force

Write-Host "Updating Module File : $dstpsm1path"
Copy-Item -Path "$srcpsm1path" -Destination "$dstpsm1path" -Force
Write-Host "Updating Manifest File : $dstpsd1path"
Copy-Item -Path "$srcpsd1path" -Destination "$dstpsd1path" -Force

$psd1VersionAfter = get-content $dstpsd1path | Select-String "ModuleVersion " -Raw
if([string]::IsNullOrEmpty($psd1VersionAfter)){
   write-warning "NoVersion in PSd1"
}else{
    $psd1VersionAfter = $psd1VersionAfter.Split('=')[1].Replace("'",'').Trim()
}

Write-Host "Original Manifest Version : $psd1VersionBefore"
Write-Host "Updated  Manifest Version : $psd1VersionAfter"

# Run gpush in ../CTLive
Push-Location $TargetPath
try {
    Write-Host "Running gpush in $TargetPath..."
    gpush
}
finally {
    Pop-Location
}
