
#╔════════════════════════════════════════════════════════════════════════════════╗
#║                                                                                ║
#║   convverter.ps1                                                               ║
#║                                                                                ║
#╟────────────────────────────────────────────────────────────────────────────────╢
#║   Guillaume Plante <codegp@icloud.com>                                         ║
#║   Code licensed under the GNU GPL v3.0. See the LICENSE file for details.      ║
#╚════════════════════════════════════════════════════════════════════════════════╝





function Convert-ToPrettyName {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0, HelpMessage = "FILE PATH")]
        [string]$InputName
    )

    process {

        # Remove file extension if present
        $BaseName = [System.IO.Path]::GetFileNameWithoutExtension($InputName)

        # Split on any non-alphanumeric character
        $Parts = $BaseName -split '[^a-zA-Z0-9]+'

        # Capitalize each word and join them
        $PrettyName = ($Parts | Where-Object { $_ -ne "" } | ForEach-Object {
                $_.Substring(0, 1).ToUpper() + $_.Substring(1).ToLower()
            }) -join ""

        return $PrettyName
    }
}