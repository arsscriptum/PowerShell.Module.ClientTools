#╔════════════════════════════════════════════════════════════════════════════════╗
#║                                                                                ║
#║   ConvertTo-ScriptVariable.ps1                                                 ║
#║                                                                                ║
#╟────────────────────────────────────────────────────────────────────────────────╢
#║   Guillaume Plante <codegp@icloud.com>                                         ║
#║   Code licensed under the GNU GPL v3.0. See the LICENSE file for details.      ║
#╚════════════════════════════════════════════════════════════════════════════════╝


function ConvertTo-ScriptVariable {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateScript({ Test-Path $_ -PathType Leaf })]
        [string]$Path,
        [Parameter(Mandatory = $false)]
        [switch]$DoubleBrackets,
        [Parameter(Mandatory = $false)]
        [switch]$Check,
        [Parameter(Mandatory = $false)]
        [switch]$Test,
        [Parameter(Mandatory = $false)]
        [switch]$RunCode
    )

    process {
        try {
            $resolvedPath = Resolve-Path $Path
            $scriptContent = Get-Content -Path $resolvedPath -Raw
            $scriptName = [System.IO.Path]::GetFileNameWithoutExtension($resolvedPath).Replace('-', '').Replace('_', '')
            $VariableName = "`${0}Content" -f $scriptName
            # Escape characters
            $escaped = $scriptContent `
                 -replace '"', '`"' `
                 -replace '\$', '`$'

            if($DoubleBrackets){
               $escaped = $escaped `
                 -replace '\{', '{{' `
                 -replace '\}', '}}' 
            }

           $ExecutionCode = @"
`$TmpScriptFile = (Join-Path `"`$ENV:Temp`" `"`$(((new-guid).guid).Substring(0,5))`") + '.ps1'
`$ScriptString = $VariableName.Replace('{{','{').Replace('}}','}')
`$ScriptString | Set-Content `$TmpScriptFile
New-EncodedScheduledTask -ScriptPath `"`$TmpScriptFile`" -Seconds 10
"@ 
            $StrVar = "$VariableName = @`"`n$escaped`n`"@`n"
            
            

            if (($Check) -Or ($Test)) {
                # Build the variable content
                iex $StrVar

                # Attempt to compile it
                try {
                    [scriptblock]$sb = [scriptblock]::Create((iex $VariableName))
                } catch {
                    Write-Host "=========================================" -ForegroundColor DarkYellow
                    Write-Host "Syntax Error in Encoded Script!" -ForegroundColor DarkRed
                    Write-Host "=========================================" -ForegroundColor DarkYellow
                    Write-Host "Details`n $_ `n" -ForegroundColor DarkCyan
                    Write-Host "Script Code" -ForegroundColor Blue
                    Format-WithLineNumbers -Script $scriptContent
                    return
                }

                if ($Test) {
                    invoke-Command -ScriptBlock $sb
                }
            }

            # Output result


            if($RunCode){
                $ResturnedString = "$StrVar`n$ExecutionCode`n"
                [scriptblock]$retsb = [scriptblock]::Create($ResturnedString)
                return $retsb
            }
            $ResturnedString = "$StrVar`n"
            [scriptblock]$retsb = [scriptblock]::Create($ResturnedString)
            return $retsb
        } catch {
            Write-Error "Error processing file '$Path': $_"
        }
    }
}
