#╔════════════════════════════════════════════════════════════════════════════════╗
#║                                                                                ║
#║   Touch.ps1                                                                    ║
#║                                                                                ║
#╟────────────────────────────────────────────────────────────────────────────────╢
#║   Guillaume Plante <codegp@icloud.com>                                         ║
#║   Code licensed under the GNU GPL v3.0. See the LICENSE file for details.      ║
#╚════════════════════════════════════════════════════════════════════════════════╝

function Invoke-TouchFile {

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $true)]
        [string]$Path,
        [Parameter(Mandatory = $False)]
        [switch]$Force,
        [Parameter(Mandatory = $False)]
        [switch]$DumpSignature
    )

    try {
        Write-Verbose "Touch File at Path `"$Path`""

        if (Test-Path -Path "$Path" -PathType Container) {
            Write-Verbose "Its a Directory!"
            throw "path is not a file, it's a container! cannot continue!"
        }

        $fi1 = $Null
        $fi2 = $Null
        if ($DumpSignature) {
            $fi1 = Get-Item -Path "$Path"
        }

        Write-Verbose "Force Option Specified!"
        if (-not (Test-Path -Path "$Path" -PathType Leaf)) {
            Write-Verbose "Does not exists! Creating the file..."

            if ($Force) {
                New-Item -Path "$Path" -ItemType File -Value "" -Force -ErrorAction Stop | Out-Null
            } else {

                try {
                    Set-Content -Path "$Path" -Value "" -ErrorAction Stop
                } catch {
                    throw "failed to create file!"
                }
            }
        } else {
            Write-Verbose "The file does exists."
            $NewAccessTime = Get-Date
            $NewAccessTimeTicks = $NewAccessTime.Ticks
            $NewAccessTimeTicksUtc = $NewAccessTime.ToUniversalTime().Ticks

            [System.IO.File]::SetLastAccessTime("$Path", $NewAccessTimeTicks)
            [System.IO.File]::SetLastAccessTimeUtc("$Path", $NewAccessTimeTicksUtc)

            if ($DumpSignature) {
                $fi2 = Get-Item -Path "$Path"
                Write-FileInfoSignature -FileInfoA $fi1 -FileInfoB $fi2
            }
        }
    } catch {

        Write-Error "$_"
    }


}
