#╔════════════════════════════════════════════════════════════════════════════════╗
#║                                                                                ║
#║   UpdateLoginScripts.ps1                                                       ║
#║                                                                                ║
#╟────────────────────────────────────────────────────────────────────────────────╢
#║   Guillaume Plante <codegp@icloud.com>                                         ║
#║   Code licensed under the GNU GPL v3.0. See the LICENSE file for details.      ║
#╚════════════════════════════════════════════════════════════════════════════════╝



function Update-UnlockScripts {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $True, Position = 0)]
        [string]$Path,
        [Parameter(Mandatory = $False, Position = 1)]
        [string]$Filter = "*.ps1"
    )

    # Ensure the registry path exists
    if (-not (Test-Path $Path)) {
        throw "missing path"
    }

    $StreamExe = (get-command 'streams64.exe').Source
    # Get all script files (*.ps1) in the specified folder
    $scriptFiles = Get-ChildItem -Path $Path -Filter "$Filter" | select -ExpandProperty FullName | % {
        $fn = $_
        Write-Host "Unlocking `"$fn`" " -f DarkYellow -NoNewline
        try {
            Remove-Item -Path "$fn" -Stream "Zone.Identifier" -ErrorAction Stop
            Write-Host " ✅ " -f DarkGreen
        } catch {
            Write-Host " ❌ Failed (already unlocked?)" -f DarkRed
            Write-Host "$_" -f DarkGray
        }
        Write-Host "UnStreaming `"$fn`" " -f DarkYellow -NoNewline
        $Out = & "$StreamExe" '-nobanner' "$fn"
        Write-Host " ✅ ok" -f DarkGreen
    }

}
