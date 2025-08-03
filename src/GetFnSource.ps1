#╔════════════════════════════════════════════════════════════════════════════════╗
#║                                                                                ║
#║   Get-FunctionSource.ps1                                                            ║
#║                                                                                ║
#╟────────────────────────────────────────────────────────────────────────────────╢
#║   Guillaume Plante <codegp@icloud.com>                                         ║
#║   Code licensed under the GNU GPL v3.0. See the LICENSE file for details.      ║
#╚════════════════════════════════════════════════════════════════════════════════╝

function Get-FunctionSource {

    [CmdletBinding(SupportsShouldProcess)]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0, HelpMessage = "Function Name")]
        [string]$Name
    )
    $IsFunction = $True
    $CmdType = Get-Command $Name
    if ($CmdType -eq $Null) { return }
    $CmdType = (Get-Command $Name).CommandType
    $Script = ""
    try {
        $Script = (Get-Item function:$Name -ErrorAction Stop).ScriptBlock
    }
    catch {
        $IsFunction = $False
    }

    write-host -n -f DarkYellow "Command Type  : ";
    write-host -f DarkRed "$CmdType";

    if (($IsFunction -eq $False) -or ($CmdType -eq 'Alias')) {
        $AliasInfo = (Get-Alias $Name).DisplayName
        write-host -n -f DarkYellow "Alias Info : ";
        write-host -f DarkRed "$AliasInfo";
        $AliasDesc = (Get-Alias $Name).Description
        write-host -n -f DarkYellow "Alias Desc : ";
        write-host -f DarkRed "$AliasDesc";
    } else {
        write-host -n -f DarkYellow "Function Name : ";
        write-host -f DarkRed "$Name";
    }

    return $Script

}
