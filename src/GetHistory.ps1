#╔════════════════════════════════════════════════════════════════════════════════╗
#║                                                                                ║
#║   GetHistory.ps1                                                               ║
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

function Clear-PsHistory {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $false)]
        [switch]$Backup
    )

    try {
        [string]$HistPath = "{0}\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt" -f "$ENV:APPDATA"
        if (-not (Test-Path -Path "$HistPath")) { throw "cannot find history file" }

        if ($Backup) {
            [string]$HistPathBackupDir = Join-Path "$ENV:Sandbox" "PsHistory"
            [string]$StrDate = (get-date).GetDateTimeFormats()[9].Replace('/', '_').Replace(' ', '_').Replace(':', '-') -as [string]
            [string]$Filename = "ConsoleHost_history_{0}.txt" -f $StrDate
            [string]$HistPathBackup = Join-Path "$HistPathBackupDir" "$Filename"
            if (-not (Test-Path -Path "$HistPathBackupDir")) { New-Item -Path "$HistPathBackupDir" -ItemType Directory -Force | Out-Null }

            Write-Host "Backup History File to `"$HistPathBackup`""
            Copy-Item "$HistPath" "$HistPathBackup" -Force -Verbose
        }

        Write-Host "Deleting file content in `"$HistPath`""
        Remove-Item -Path "$HistPath" -Force -ErrorAction Ignore | Out-Null
        New-Item -Path "$HistPath" -ItemType File -Value "" -Force -ErrorAction Ignore | Out-Null

    } catch {
        Write-Error "$_"
    }

}

function Show-PsHistory {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $false)]
        [switch]$Backup
    )

    try {
        [string]$HistPath = "{0}\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt" -f "$ENV:APPDATA"
        if (-not (Test-Path -Path "$HistPath")) { throw "cannot find history file" }

        [string]$ToOpen = $HistPath
        if ($Backup) {
            [string]$HistPathBackupDir = Join-Path "$ENV:Sandbox" "PsHistory"
            [string]$StrDate = (get-date).GetDateTimeFormats()[9].Replace('/', '_').Replace(' ', '_').Replace(':', '-') -as [string]
            [string]$Filename = "ConsoleHost_history_{0}.txt" -f $StrDate
            [string]$HistPathBackup = Join-Path "$HistPathBackupDir" "$Filename"
            if (-not (Test-Path -Path "$HistPathBackupDir")) { New-Item -Path "$HistPathBackupDir" -ItemType Directory -Force | Out-Null }

            Write-Host "Backup History File to `"$HistPathBackup`""
            Copy-Item "$HistPath" "$HistPathBackup" -Force -Verbose
            [string]$ToOpen = $HistPathBackup
        }

        Write-Host "Opening file `"$ToOpen`""
        Invoke-Sublime "$ToOpen"


    } catch {
        Write-Error "$_"
    }

}


New-Alias -Name gethomepath -Value Get-HomePath -Scope Global -ErrorAction Ignore
New-Alias -Name clearhistory -Value Clear-PsHistory -Scope Global -ErrorAction Ignore
New-Alias -Name showhistory -Value Show-PsHistory -Scope Global -ErrorAction Ignore

