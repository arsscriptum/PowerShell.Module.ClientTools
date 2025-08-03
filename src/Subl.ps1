#╔════════════════════════════════════════════════════════════════════════════════╗
#║                                                                                ║
#║   ExportNetConnections.ps1                                                     ║
#║                                                                                ║
#╟────────────────────────────────────────────────────────────────────────────────╢
#║   Guillaume Plante <codegp@icloud.com>                                         ║
#║   Code licensed under the GNU GPL v3.0. See the LICENSE file for details.      ║
#╚════════════════════════════════════════════════════════════════════════════════╝

function Invoke-SublimeText {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $false)]
        [string]$Path
    )

    try {
        [string]$SublPath = "C:\Program Files\Sublime Text\sublime_text.exe"
        [string]$InstallPath = "C:\Program Files\Sublime Text"
        if ([string]::IsNullOrEmpty($Path)) {
            & "$SublPath"
            return;
        }
        if (-not (Test-Path -Path "$Path")) { New-Item -Path "$Path" -ItemType File -Force | Out-Null }

        & "$SublPath" "$Path"

    } catch {
        Write-Error "$_"
    }

}

New-Alias -Name subl -Value Invoke-SublimeText -Scope Global -ErrorAction Ignore

