#╔════════════════════════════════════════════════════════════════════════════════╗
#║                                                                                ║
#║   GetTerminalStartingDirectory.ps1                                             ║
#║                                                                                ║
#╟────────────────────────────────────────────────────────────────────────────────╢
#║   Guillaume Plante <codegp@icloud.com>                                         ║
#║   Code licensed under the GNU GPL v3.0. See the LICENSE file for details.      ║
#╚════════════════════════════════════════════════════════════════════════════════╝


function Get-TerminalStartingDirectory {
    [CmdletBinding(SupportsShouldProcess)]
    param
    (
        [Parameter(Mandatory = $false)]
        [Alias('s', 'set')]
        [switch]$SetLocation
    )
    $RegPath = "$ENV:OrganizationHKCU\windows.terminal"
    $RegKeyName = 'StartingDirectory'
    $RegKey = (Get-ItemProperty -Path $RegPath -Name $RegKeyName -ErrorAction ignore)

    if ($RegKey -ne $null) {
        $StartingDirectory = $RegKey.StartingDirectory
    } else {
        $StartingDirectory = $Home
    }
    if ($SetLocation) { Set-Location $StartingDirectory -ErrorAction Ignore; }
    return $StartingDirectory
}


