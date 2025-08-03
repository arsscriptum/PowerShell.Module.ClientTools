#╔════════════════════════════════════════════════════════════════════════════════╗
#║                                                                                ║
#║   ExportNetConnections.ps1                                                     ║
#║                                                                                ║
#╟────────────────────────────────────────────────────────────────────────────────╢
#║   Guillaume Plante <codegp@icloud.com>                                         ║
#║   Code licensed under the GNU GPL v3.0. See the LICENSE file for details.      ║
#╚════════════════════════════════════════════════════════════════════════════════╝

function Get-HomePath {
    [CmdletBinding(SupportsShouldProcess)]
    param()

    [string]$HomePath = "{0}\{1}" -f "$ENV:HOMEDRIVE", "$ENV:HOMEPATH"
    return $HomePath
}

function Get-LogsPath {
    [CmdletBinding(SupportsShouldProcess)]
    param()

    [string]$LogsPath = Join-Path ([environment]::GetFolderPath("mydocuments")) "ConnectionsLogs"
    if (-not (Test-Path -Path "$LogsPath" -PathType Container)) {
        new-item -Path "$LogsPath" -ItemType Directory -Force -ErrorAction Ignore | Out-Null
    }
    return $LogsPath
}


function Export-NetConnections {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $false)]
        [switch]$OpenDirectory
    )

    try {
        [string]$StrDate = (get-date).GetDateTimeFormats()[9].Replace('/', '_').Replace(' ', '_').Replace(':', '-') -as [string]
        [string]$LogsPath = Join-Path (Get-LogsPath) $StrDate
        if (-not (Test-Path -Path "$LogsPath")) { New-Item -Path "$LogsPath" -ItemType Directory -Force | Out-Null }

        Get-ActiveConnectionsListening | ConvertTo-Json | Set-Content (Join-Path $LogsPath "ActiveConnectionsListening.json")
        Get-ActiveConnectionsEstablished | ConvertTo-Json | Set-Content (Join-Path $LogsPath "ActiveConnectionsEstablished.json")
        Get-ActiveConnectionsOnly | ConvertTo-Json | Set-Content (Join-Path $LogsPath "ActiveConnectionsOnly.json")
        Get-ActiveConnectionsNetstat | ConvertTo-Json | Set-Content (Join-Path $LogsPath "ActiveConnectionsNetstat.json")
        Get-ActiveConnectionsTcpConView | ConvertTo-Json | Set-Content (Join-Path $LogsPath "ActiveConnectionsTcpConView.json")
        Get-ActiveConnectionsWithLocalPort | ConvertTo-Json | Set-Content (Join-Path $LogsPath "ActiveConnectionsWithLocalPort.json")

        if ($OpenDirectory) {
            $ExplorerPath = (Get-Command 'explorer.exe').Source
            & "$ExplorerPath" "$LogsPath"
        }


    } catch {
        Write-Error "$_"
    }

}

New-Alias -Name connsexport -Value Export-NetConnections -Scope Global -ErrorAction Ignore

