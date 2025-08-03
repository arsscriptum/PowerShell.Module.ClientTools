function Search-Pattern {
    <#
    .SYNOPSIS
            Cmdlet to find in files (grep)
    .DESCRIPTION
            Cmdlet to find in files (grep)
    .PARAMETER Pattern
            What to look for in the files
    .PARAMETER Extension
            File Extension, just the Extension, no *
    .PARAMETER Path
            Path for search
    .PARAMETER Exclude
            Exclude string array
    .PARAMETER Short
            Output short file names
    .PARAMETER List
            Output as list of psobjects
    .PARAMETER Recurse
            Recurse in subdirectories
    .EXAMPLE
        Search-Pattern -Pattern 'g.png' -Extension "txt"
        Search-Pattern -Pattern 'g.png' -Exclude @("_site","jekyll-metadata","bower_components","jekyll-cache")
#>


    [CmdletBinding(SupportsShouldProcess)]
    param
    (
        [Parameter(Position = 0, Mandatory = $true, HelpMessage = "Pattern to search for")]
        [Object]$Pattern,

        [Parameter(Mandatory = $false, HelpMessage = "File filter")]
        [Alias('f')]
        [string]$Filter = '*.*',

        [Parameter(Mandatory = $false, HelpMessage = "Path for search")]
        [Alias('p')]
        [string]$Path,

        [Parameter(Mandatory = $false, HelpMessage = "Exclude string array")]
        [Alias('x')]
        [string[]]$Exclude,

        [Parameter(Mandatory = $false, HelpMessage = "Output short file names")]
        [Alias('s')]
        [switch]$Short,

        [Parameter(Mandatory = $false, HelpMessage = "Output as list of psobjects")]
        [Alias('l')]
        [switch]$List,

        [Parameter(Mandatory = $false, HelpMessage = "do not truncate lines")]
        [switch]$NoTruncate,

        [Parameter(Mandatory = $false, HelpMessage = "Recurse in subdirectories")]
        [Alias('r')]
        [switch]$Recurse = $true

    )
    try {


        $EA = $ErrorActionPreference
        $ErrorActionPreference = "Stop"
        [System.Collections.ArrayList]$Results = [System.Collections.ArrayList]::new()
        [Microsoft.PowerShell.Commands.MatchInfo[]]$SearchList;
        [string]$CurrentPath = (Get-Location).Path
        if ([string]::IsNullOrEmpty($Path)) {
            $Path = $CurrentPath
        }

        Write-Verbose "Search-Pattern (my grep): looking for a string in files. Path: $Path"
        Write-Verbose "  Pattern: $Pattern"
        Write-Verbose "  Short: $Short"
        Write-Verbose "  Recurse: $Recurse"
        Write-Verbose "  Using Extension filter: $Filter"


        if ($Exclude.Count -gt 0) {
            [string]$exclude_string = ''
            foreach ($toexclude in $Exclude) {
                $exclude_string += "$toexclude|"
            }
            $exclude_string = $exclude_string.Trim('|')
            Write-Verbose "  Excluding this string in names: $exclude_string"
            $SearchList = Get-ChildItem -Path $Path -File -Filter $Filter -Recurse:$Recurse | where FullName -NotMatch "$exclude_string" | Select-String -Pattern $Pattern -CaseSensitive
        }
        else {
            $SearchList = Get-ChildItem -Path $Path -File -Filter $Filter -Recurse:$Recurse | Select-String -Pattern $Pattern -CaseSensitive
        }

        foreach ($match in $SearchList) {
            $Path = $match.Path
            $Path = $Path.Replace($CurrentPath, '.')
            if ($Short) {
                $Path = $match.FileName
            }
            $SearchPattern = $Pattern.Replace('\', '')
            $Line = $match.Line.Trim()
            $Index = $Line.IndexOf($SearchPattern)
            if ($Index -eq -1) { $Index = 0 }
            $LineNumber = $match.LineNumber
            $Length = $Line.Length

            [int]$MaxLen = 80
            if ($List) { $MaxLen = 1024 }
            if ($NoTruncate) { $MaxLen = 1024 }

            if ($Length -gt $MaxLen) {
                if ($Index -gt $MaxLen) {
                    try {
                        $Line = $Line.substring($Index - 2, $SearchPattern.Length + 15)
                    } catch {
                        $Line = $Line.substring(0, $MaxLen)
                    }
                } else {
                    $Line = $Line.substring(0, $MaxLen)
                }
            }
            $o = [pscustomobject]@{
                Path = $Path
                LineNumber = $LineNumber
                Index = $Index
                Line = $Line
            }
            if ($List) {
                [void]$Results.Add($o)
            } else {
                Write-Output "$Path`:$LineNumber,$Index`t$Line"
            }
        }
        $ErrorActionPreference = $EA
        if ($List) {
            $Results
        }
    } catch {
        Write-Error $_
    }
}

New-alias -Name grep -Value Search-Pattern -Scope 'Global' -ErrorAction 'Ignore'
