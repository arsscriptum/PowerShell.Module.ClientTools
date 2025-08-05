#╔════════════════════════════════════════════════════════════════════════════════╗
#║                                                                                ║
#║   DirectorySize.ps1                                                               ║
#║                                                                                ║
#╟────────────────────────────────────────────────────────────────────────────────╢
#║   Guillaume Plante <codegp@icloud.com>                                         ║
#║   Code licensed under the GNU GPL v3.0. See the LICENSE file for details.      ║
#╚════════════════════════════════════════════════════════════════════════════════╝

function Get-FolderSize {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0, HelpMessage = "dir name")]
        [string]$Path
    )
    process {
        if (-not (Test-Path $Path)) {
            Write-Error "Folder not found: $Path"
            return
        }

        $TotalBytes = (Get-ChildItem -Path $Path -Recurse -Force -ErrorAction SilentlyContinue |
            Where-Object { -not $_.PSIsContainer } |
            Measure-Object -Property Length -Sum).Sum

        [pscustomobject]@{
            Path = $Path
            SizeBytes = $TotalBytes
            SizeMB = "{0:N2}" -f ($TotalBytes / 1MB)
            SizeGB = "{0:N2}" -f ($TotalBytes / 1GB)
        }
    }
}

function Get-FirstLevelFolderSizes {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0, HelpMessage = "dir name")]
        [ValidateScript({ Test-Path $_ -PathType 'Container' })]
        [string]$Path,

        [Parameter(Mandatory = $false, HelpMessage = "Show total size at the end")]
        [switch]$ShowTotal
    )
    process {
        $Results = @()
        $TotalBytes = 0

        Get-ChildItem -Path $Path -Directory -Force | ForEach-Object {
            $Subfolder = $_.FullName
            $Size = (Get-ChildItem -Path $Subfolder -Recurse -Force -ErrorAction SilentlyContinue |
                Where-Object { -not $_.PSIsContainer } |
                Measure-Object -Property Length -Sum).Sum

            $TotalBytes += $Size

            $Results += [pscustomobject]@{
                FolderName = $_.Name
                SizeMB = "{0:N2}" -f ($Size / 1MB)
                SizeGB = "{0:N2}" -f ($Size / 1GB)
            }
        }

        $Results | Sort-Object { [decimal]$_.SizeMB } -Descending | Format-Table -AutoSize

        if ($ShowTotal) {
            Write-Host "`nTotal size of all first-level folders:" -ForegroundColor Cyan
            Write-Host ("{0:N2} MB ({1:N2} GB)" -f ($TotalBytes / 1MB), ($TotalBytes / 1GB)) -ForegroundColor Green
        }
    }
}
