#╔════════════════════════════════════════════════════════════════════════════════╗
#║                                                                                ║
#║   make.ps1                                                                     ║
#║                                                                                ║
#╟────────────────────────────────────────────────────────────────────────────────╢
#║   Guillaume Plante <codegp@icloud.com>                                         ║
#║   Code licensed under the GNU GPL v3.0. See the LICENSE file for details.      ║
#╚════════════════════════════════════════════════════════════════════════════════╝




$FunctionsAuth = Get-FunctionList .\src\ | Where Base -match "\b(?:Initialize)\b" | Select -ExpandProperty Name
$FunctionsAutoUpdate = Get-FunctionList .\src\ | Where Base -match "\b(?:ModuleUpdater)\b" | Select -ExpandProperty Name
$FunctionsHelpers = Get-FunctionList .\src\ | Where Base -match "\b(?:Helpers)\b" | Select -ExpandProperty Name
$FunctionsConfig = Get-FunctionList .\src\ | Where Base -match "\b(?:Config)\b" | Select -ExpandProperty Name

function Get-FunctionDocUrl($Name){
    $Url = "https://github.com/arsscriptum/PowerShell.Module.ClientTools/blob/master/doc/{0}.md" -f $Name
    [string]$res = " - [{0}]({1})`n" -f $Name, $Url
    $res
}

$FunctionsAuthText = ForEach($fn in $FunctionsAuth){
    $DocUrl= Get-FunctionDocUrl $fn
    $DocUrl
}

$FunctionsAutoUpdateText = ForEach($fn in $FunctionsAutoUpdate){
    $DocUrl= Get-FunctionDocUrl $fn
    $DocUrl
}
$FunctionsHelpersText = ForEach($fn in $FunctionsHelpers){
    $DocUrl= Get-FunctionDocUrl $fn
    $DocUrl
}

$FunctionsConfigText = ForEach($fn in $FunctionsConfig){
    $DocUrl= Get-FunctionDocUrl $fn
    $DocUrl
}

[string]$LastUpdate = (Get-Date).GetDateTimeFormats()[5]
$Text = @"

## Functions - Initialization
$FunctionsAuthText

## Functions - AutoUpdate
$FunctionsAutoUpdateText

## Functions - Config
$FunctionsConfigText



## Functions - Helpers
$FunctionsHelpersText


## Last Update

$LastUpdate
"@

$cnt = Get-Content "$PSScriptRoot\README.tpl"

$cnt = $cnt.Replace('__FUNCTIONS_DOCUMENTATION__',$Text)
$cnt
Set-Content "$PSScriptRoot\README.md" -Value $cnt