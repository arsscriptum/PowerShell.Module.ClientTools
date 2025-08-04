
#╔════════════════════════════════════════════════════════════════════════════════╗
#║                                                                                ║
#║   History.ps1                                                                  ║
#║   ps history search                                                            ║
#║                                                                                ║
#╟────────────────────────────────────────────────────────────────────────────────╢
#║   Guillaume Plante <codegp@icloud.com>                                         ║
#║   Code licensed under the GNU GPL v3.0. See the LICENSE file for details.      ║
#╚════════════════════════════════════════════════════════════════════════════════╝

function Out-SplitMatchLine {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    param(
        [Parameter(Position = 0, Mandatory = $True, ValueFromPipeline = $True)]
        [Microsoft.PowerShell.Commands.MatchInfo]$MatchInfo,
        [Parameter(Mandatory = $False, ValueFromPipeline = $False)]
        [switch]$AsObject,
        [Parameter(Mandatory = $False, ValueFromPipeline = $False)]
        [switch]$Raw
    )

    # Ensure there's at least one match
    if ($MatchInfo.Matches.Count -eq 0) {
        Write-Error "No matches found in the provided MatchInfo object."
        return
    }

    # Process each match
    foreach ($match in $MatchInfo.Matches) {
        $line = $MatchInfo.Line
        if ($Raw) {
            $preMatch = $line.substring(0, $match.Index)
            $matchValue = $match.Value
            $postMatch = $line.substring($match.Index + $match.Length)
        } else {

            $linelen = $line.Length
            if ($linelen -gt 80) {
                $preMatch = $line.substring(0, $match.Index)
                $preMatchLen = $preMatch.Length
                if ($preMatchLen -gt 80) { $preMatch = $preMatch.substring($preMatchLen - 80) }
                $matchValue = $match.Value
                $postMatch = $line.substring($match.Index + $match.Length)
                $postMatchLen = $postMatch.Length
                if ($postMatchLen -gt 80) { $postMatch = $postMatch.substring($postMatchLen - 80) }
            } else {
                $preMatch = $line.substring(0, $match.Index)
                $matchValue = $match.Value
                $postMatch = $line.substring($match.Index + $match.Length)
            }
        }
        if ($AsObject) {
            [pscustomobject]$obj = [pscustomobject]@{
                pre = "$preMatch"
                match = "$matchValue"
                post = "$postMatch"
            }
            return $obj
        }
        Write-Host "$preMatch" -NoNewline -Foreground DarkYellow
        Write-Host "$matchValue" -NoNewline -Foreground DarkRed
        Write-Host "$postMatch" -Foreground DarkYellow
    }
}


function Search-StringInFile {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Position = 0, Mandatory = $True, ValueFromPipeline = $True)]
        [string]$InputString,
        [Parameter(Mandatory = $True, ValueFromPipeline = $False)]
        [string]$SearchString,
        [Parameter(Mandatory = $False, ValueFromPipeline = $False)]
        [switch]$Colorize,
        [Parameter(Mandatory = $False, ValueFromPipeline = $False)]
        [switch]$AsObject,
        [Parameter(Mandatory = $False, ValueFromPipeline = $False)]
        [switch]$Raw
    )

    # Validate the file path
    if (-not (Test-Path -Path $FilePath -PathType Leaf)) {
        Write-Error "The specified file does not exist: $FilePath"
        return
    }

    # Define the output file path
    $OutputFile = Join-Path -Path $ENV:TEMP -ChildPath "search.txt"

    try {
        # Search for the string in the file
        [Microsoft.PowerShell.Commands.MatchInfo[]]$AllMatches = Select-String -Path $FilePath -Pattern $SearchString -Raw | Select-String -Pattern $SearchString
        $NumMatches = $AllMatches.Count
        if ($NumMatches -gt 0) {
            foreach ($match in $AllMatches) {
                if ($AsObject) {
                    $match | Out-SplitMatchLine -AsObject -Raw:$Raw
                }
                elseif ($Colorize) {
                    $match | Out-SplitMatchLine -Raw:$Raw
                } else {
                    $match
                }

            }
        } else {
            Write-Host "No occurrences of '$SearchString' found in $FilePath." -ForegroundColor Cyan
        }
    } catch {
        Write-Error "An error occurred: $_"
    }
}


function Get-FileInfoWithTimeSpan {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $True, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$Path
    )

    # Check if the path exists
    if (-not (Test-Path -Path $Path)) {
        Write-Error "The specified path does not exist: $Path"
        return
    }

    # Check if the path is a directory
    if (-not (Get-Item -Path $Path).PSIsContainer) {
        Write-Error "The specified path is not a directory: $Path"
        return
    }

    # Get the list of files and calculate the timespan
    $List = Get-ChildItem -Path $Path -File | ForEach-Object {
        [pscustomobject]@{
            FileName = $_.Name
            FullPath = $_.FullName
            LastWrite = $_.LastWriteTime
            TimeSpan = [datetime]::Now - $_.LastWriteTime
        }
    } | sort -Property TimeSpan

    $ListCount = $List.Count
    Write-Verbose "Found $ListCount items"
    return $List
}

function Search-PsHistory {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Position = 0, Mandatory = $True, ValueFromPipeline = $True)]
        [string]$InputString,
        [Parameter(Mandatory = $False, ValueFromPipeline = $False)]
        [switch]$Backup,
        [Parameter(Mandatory = $False, ValueFromPipeline = $False)]
        [switch]$NoColor,
        [Parameter(Mandatory = $False, ValueFromPipeline = $False)]
        [switch]$AsObject,
        [Parameter(Mandatory = $False, ValueFromPipeline = $False)]
        [switch]$Raw
    )

    try {
        $Path = (Resolve-Path -Path "$ENV:APPDATA\Microsoft\Windows\PowerShell\PSReadLine" -ErrorAction Stop).Path
        $List = Get-FileInfoWithTimeSpan -Path $Path
        $ListCount = $List.Count
        if ($ListCount -eq 0) { throw "no files in history directory" }
        if ($Backup) {
            $BackupPath = Join-Path $Path 'Backup'
            New-Item -Path "$BackupPath" -Force -ErrorAction Ignore -ItemType Directory | Out-Null
            $timestamp = Get-Date -Format "MMdd-HHmmss"
            $BackupFilename = Join-Path $BackupPath "ConsoleHost_history_backup_$timestamp.txt"
            Write-Host "[Export-PsHistory] " -f DarkRed -NoNewline
            Write-Host "Creating Backup of history file to $BackupFilename" -f DarkYellow
            Copy-Item -Path ($List[0].FullPath) -Destination $BackupFilename -Force
        }

        $Filepath = $List[0].FullPath
        $Colorize = ($NoColor -eq $False)
        if ($AsObject) {
            $Filepath | Search-StringInFile -SearchString $InputString -AsObject -Raw:$Raw
        } else {
            $Filepath | Search-StringInFile -SearchString $InputString -Colorize:$Colorize -Raw:$Raw
        }


    } catch {
        Write-Host "[Export-PsHistory] " -f DarkRed -NoNewline
        Write-Host "$_" -f DarkYellow
        return
    }
}



