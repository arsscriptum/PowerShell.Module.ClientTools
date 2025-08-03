#╔════════════════════════════════════════════════════════════════════════════════╗
#║                                                                                ║
#║   make.ps1                                                                     ║
#║                                                                                ║
#╟────────────────────────────────────────────────────────────────────────────────╢
#║   Guillaume Plante <codegp@icloud.com>                                         ║
#║   Code licensed under the GNU GPL v3.0. See the LICENSE file for details.      ║
#╚════════════════════════════════════════════════════════════════════════════════╝




$FunctionsAuth = Get-FunctionList .\src\ | Where Base -match "\b(?:AuthToken|Initialize)\b" | Select -ExpandProperty Name
$FunctionsRequestTextCompletion = Get-FunctionList .\src\ | Where Base -match "\b(?:TextCompletion)\b" | Select -ExpandProperty Name
$FunctionsRequestCodeCompletion = Get-FunctionList .\src\ | Where Base -match "\b(?:CodeCompletion)\b" | Select -ExpandProperty Name
$FunctionsModels = Get-FunctionList .\src\ | Where Base -match "\b(?:Model)\b" | Select -ExpandProperty Name

function Get-FunctionDocUrl($Name){
    $Url = "https://github.com/arsscriptum/PowerShell.Module.OpenAI/blob/master/doc/{0}.md" -f $Name
    [string]$res = " - [{0}]({1})`n" -f $Name, $Url
    $res
}

$FunctionsAuthText = ForEach($fn in $FunctionsAuth){
    $DocUrl= Get-FunctionDocUrl $fn
    $DocUrl
}

$FunctionsRequestTextCompletionText = ForEach($fn in $FunctionsRequestTextCompletion){
    $DocUrl= Get-FunctionDocUrl $fn
    $DocUrl
}

$FunctionsRequestCodeCompletionsText = ForEach($fn in $FunctionsRequestCodeCompletion){
    $DocUrl= Get-FunctionDocUrl $fn
    $DocUrl
}

$FunctionsModelsText = ForEach($fn in $FunctionsModels){
    $DocUrl= Get-FunctionDocUrl $fn
    $DocUrl
}

[string]$LastUpdate = (Get-Date).GetDateTimeFormats()[5]
$Text = @"

## Functions - Init and Authentication
$FunctionsAuthText

## Functions - Request Text Completion
$FunctionsRequestTextCompletionText

## Functions - Request Code Completion
$FunctionsRequestCodeCompletionsText

## Functions - Open AI Models data requests
$FunctionsModelsText

## Last Update

$LastUpdate
"@

$cnt = Get-Content "$PSScriptRoot\README.tpl"

$cnt = $cnt.Replace('__FUNCTIONS_DOCUMENTATION__',$Text)
$cnt
Set-Content "$PSScriptRoot\README.md" -Value $cnt