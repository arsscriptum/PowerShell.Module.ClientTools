#╔════════════════════════════════════════════════════════════════════════════════╗
#║                                                                                ║
#║   makedoc.ps1                                                                     ║
#║                                                                                ║
#╟────────────────────────────────────────────────────────────────────────────────╢
#║   Guillaume Plante <codegp@icloud.com>                                         ║
#║   Code licensed under the GNU GPL v3.0. See the LICENSE file for details.      ║
#╚════════════════════════════════════════════════════════════════════════════════╝



function Get-FunctionDocUrl($Name){
    $Url = "https://github.com/arsscriptum/PowerShell.Module.ClientTools/blob/master/doc/{0}.md" -f $Name
    [string]$res = " - [{0}]({1})`n" -f $Name, $Url
    $res
}
$FunctionsBlockWebsite = Get-FunctionList .\src\ | Where Base -match "\b(?:BlockWebsite)\b" | Select -ExpandProperty Name
$FunctionsCheckAndGet = Get-FunctionList .\src\ | Where Base -match "\b(?:CheckAndGet)\b" | Select -ExpandProperty Name
$FunctionsConfig = Get-FunctionList .\src\ | Where Base -match "\b(?:Config)\b" | Select -ExpandProperty Name
$FunctionsConfigureWellKnownPaths = Get-FunctionList .\src\ | Where Base -match "\b(?:ConfigureWellKnownPaths)\b" | Select -ExpandProperty Name
$FunctionsConfigureWindowsTerminal = Get-FunctionList .\src\ | Where Base -match "\b(?:ConfigureWindowsTerminal)\b" | Select -ExpandProperty Name
$FunctionsControlMouse = Get-FunctionList .\src\ | Where Base -match "\b(?:ControlMouse)\b" | Select -ExpandProperty Name
$FunctionsCredential = Get-FunctionList .\src\ | Where Base -match "\b(?:Credential)\b" | Select -ExpandProperty Name
$FunctionsCustomPathFunctions = Get-FunctionList .\src\ | Where Base -match "\b(?:CustomPathFunctions)\b" | Select -ExpandProperty Name
$FunctionsDecode = Get-FunctionList .\src\ | Where Base -match "\b(?:Decode)\b" | Select -ExpandProperty Name
$FunctionsEncode = Get-FunctionList .\src\ | Where Base -match "\b(?:Encode)\b" | Select -ExpandProperty Name
$FunctionsException = Get-FunctionList .\src\ | Where Base -match "\b(?:Exception)\b" | Select -ExpandProperty Name
$FunctionsExportConnectionsData = Get-FunctionList .\src\ | Where Base -match "\b(?:ExportConnectionsData)\b" | Select -ExpandProperty Name
$FunctionsExportSystemInfo = Get-FunctionList .\src\ | Where Base -match "\b(?:ExportSystemInfo)\b" | Select -ExpandProperty Name
$FunctionsGetConns = Get-FunctionList .\src\ | Where Base -match "\b(?:GetConns)\b" | Select -ExpandProperty Name
$FunctionsGetCurrentContext = Get-FunctionList .\src\ | Where Base -match "\b(?:GetCurrentContext)\b" | Select -ExpandProperty Name
$FunctionsGetEnvPath = Get-FunctionList .\src\ | Where Base -match "\b(?:GetEnvPath)\b" | Select -ExpandProperty Name
$FunctionsGetFnSource = Get-FunctionList .\src\ | Where Base -match "\b(?:GetFnSource)\b" | Select -ExpandProperty Name
$FunctionsGetHistory = Get-FunctionList .\src\ | Where Base -match "\b(?:GetHistory)\b" | Select -ExpandProperty Name
$FunctionsGetLoggedInUsers = Get-FunctionList .\src\ | Where Base -match "\b(?:GetLoggedInUsers)\b" | Select -ExpandProperty Name
$FunctionsGetTerminalStartingDirectory = Get-FunctionList .\src\ | Where Base -match "\b(?:GetTerminalStartingDirectory)\b" | Select -ExpandProperty Name
$FunctionsHelpers = Get-FunctionList .\src\ | Where Base -match "\b(?:Helpers)\b" | Select -ExpandProperty Name
$FunctionsHistory = Get-FunctionList .\src\ | Where Base -match "\b(?:History)\b" | Select -ExpandProperty Name
$FunctionsInitialize = Get-FunctionList .\src\ | Where Base -match "\b(?:Initialize)\b" | Select -ExpandProperty Name
$FunctionsModulesPathFunctions = Get-FunctionList .\src\ | Where Base -match "\b(?:ModulesPathFunctions)\b" | Select -ExpandProperty Name
$FunctionsModuleUpdater = Get-FunctionList .\src\ | Where Base -match "\b(?:ModuleUpdater)\b" | Select -ExpandProperty Name
$FunctionsNamedPipe = Get-FunctionList .\src\ | Where Base -match "\b(?:NamedPipe)\b" | Select -ExpandProperty Name
$FunctionsProcessData = Get-FunctionList .\src\ | Where Base -match "\b(?:ProcessData)\b" | Select -ExpandProperty Name
$Functionsprocesslist = Get-FunctionList .\src\ | Where Base -match "\b(?:processlist)\b" | Select -ExpandProperty Name
$FunctionsPrompt = Get-FunctionList .\src\ | Where Base -match "\b(?:Prompt)\b" | Select -ExpandProperty Name
$FunctionsRecord = Get-FunctionList .\src\ | Where Base -match "\b(?:Record)\b" | Select -ExpandProperty Name
$FunctionsRegistry = Get-FunctionList .\src\ | Where Base -match "\b(?:Registry)\b" | Select -ExpandProperty Name
$FunctionsRemoteDesktop = Get-FunctionList .\src\ | Where Base -match "\b(?:RemoteDesktop)\b" | Select -ExpandProperty Name
$FunctionsRestartScript = Get-FunctionList .\src\ | Where Base -match "\b(?:RestartScript)\b" | Select -ExpandProperty Name
$FunctionsSaveEditProfile = Get-FunctionList .\src\ | Where Base -match "\b(?:SaveEditProfile)\b" | Select -ExpandProperty Name
$FunctionsSearchPattern = Get-FunctionList .\src\ | Where Base -match "\b(?:SearchPattern)\b" | Select -ExpandProperty Name
$FunctionsSelectUser = Get-FunctionList .\src\ | Where Base -match "\b(?:SelectUser)\b" | Select -ExpandProperty Name
$FunctionsSetFirewallConfig = Get-FunctionList .\src\ | Where Base -match "\b(?:SetFirewallConfig)\b" | Select -ExpandProperty Name
$FunctionsSetMappedDrives = Get-FunctionList .\src\ | Where Base -match "\b(?:SetMappedDrives)\b" | Select -ExpandProperty Name
$FunctionsSubl = Get-FunctionList .\src\ | Where Base -match "\b(?:Subl)\b" | Select -ExpandProperty Name
$FunctionsTestPorts = Get-FunctionList .\src\ | Where Base -match "\b(?:TestPorts)\b" | Select -ExpandProperty Name
$FunctionsUnlockScripts = Get-FunctionList .\src\ | Where Base -match "\b(?:UnlockScripts)\b" | Select -ExpandProperty Name
$FunctionsUpdateLoginScripts = Get-FunctionList .\src\ | Where Base -match "\b(?:UpdateLoginScripts)\b" | Select -ExpandProperty Name
$FunctionsWgetDl = Get-FunctionList .\src\ | Where Base -match "\b(?:WgetDl)\b" | Select -ExpandProperty Name
$FunctionsWinUpdateNotify = Get-FunctionList .\src\ | Where Base -match "\b(?:WinUpdateNotify)\b" | Select -ExpandProperty Name
$FunctionsWriteUtils = Get-FunctionList .\src\ | Where Base -match "\b(?:WriteUtils)\b" | Select -ExpandProperty Name
$FunctionsBlockWebsiteText = ForEach($fn in $FunctionsBlockWebsite){
    $DocUrl= Get-FunctionDocUrl $fn
    $DocUrl
}
$FunctionsCheckAndGetText = ForEach($fn in $FunctionsCheckAndGet){
    $DocUrl= Get-FunctionDocUrl $fn
    $DocUrl
}
$FunctionsConfigText = ForEach($fn in $FunctionsConfig){
    $DocUrl= Get-FunctionDocUrl $fn
    $DocUrl
}
$FunctionsConfigureWellKnownPathsText = ForEach($fn in $FunctionsConfigureWellKnownPaths){
    $DocUrl= Get-FunctionDocUrl $fn
    $DocUrl
}
$FunctionsConfigureWindowsTerminalText = ForEach($fn in $FunctionsConfigureWindowsTerminal){
    $DocUrl= Get-FunctionDocUrl $fn
    $DocUrl
}
$FunctionsControlMouseText = ForEach($fn in $FunctionsControlMouse){
    $DocUrl= Get-FunctionDocUrl $fn
    $DocUrl
}
$FunctionsCredentialText = ForEach($fn in $FunctionsCredential){
    $DocUrl= Get-FunctionDocUrl $fn
    $DocUrl
}
$FunctionsCustomPathFunctionsText = ForEach($fn in $FunctionsCustomPathFunctions){
    $DocUrl= Get-FunctionDocUrl $fn
    $DocUrl
}
$FunctionsDecodeText = ForEach($fn in $FunctionsDecode){
    $DocUrl= Get-FunctionDocUrl $fn
    $DocUrl
}
$FunctionsEncodeText = ForEach($fn in $FunctionsEncode){
    $DocUrl= Get-FunctionDocUrl $fn
    $DocUrl
}
$FunctionsExceptionText = ForEach($fn in $FunctionsException){
    $DocUrl= Get-FunctionDocUrl $fn
    $DocUrl
}
$FunctionsExportConnectionsDataText = ForEach($fn in $FunctionsExportConnectionsData){
    $DocUrl= Get-FunctionDocUrl $fn
    $DocUrl
}
$FunctionsExportSystemInfoText = ForEach($fn in $FunctionsExportSystemInfo){
    $DocUrl= Get-FunctionDocUrl $fn
    $DocUrl
}
$FunctionsGetConnsText = ForEach($fn in $FunctionsGetConns){
    $DocUrl= Get-FunctionDocUrl $fn
    $DocUrl
}
$FunctionsGetCurrentContextText = ForEach($fn in $FunctionsGetCurrentContext){
    $DocUrl= Get-FunctionDocUrl $fn
    $DocUrl
}
$FunctionsGetEnvPathText = ForEach($fn in $FunctionsGetEnvPath){
    $DocUrl= Get-FunctionDocUrl $fn
    $DocUrl
}
$FunctionsGetFnSourceText = ForEach($fn in $FunctionsGetFnSource){
    $DocUrl= Get-FunctionDocUrl $fn
    $DocUrl
}
$FunctionsGetHistoryText = ForEach($fn in $FunctionsGetHistory){
    $DocUrl= Get-FunctionDocUrl $fn
    $DocUrl
}
$FunctionsGetLoggedInUsersText = ForEach($fn in $FunctionsGetLoggedInUsers){
    $DocUrl= Get-FunctionDocUrl $fn
    $DocUrl
}
$FunctionsGetTerminalStartingDirectoryText = ForEach($fn in $FunctionsGetTerminalStartingDirectory){
    $DocUrl= Get-FunctionDocUrl $fn
    $DocUrl
}
$FunctionsHelpersText = ForEach($fn in $FunctionsHelpers){
    $DocUrl= Get-FunctionDocUrl $fn
    $DocUrl
}
$FunctionsHistoryText = ForEach($fn in $FunctionsHistory){
    $DocUrl= Get-FunctionDocUrl $fn
    $DocUrl
}
$FunctionsInitializeText = ForEach($fn in $FunctionsInitialize){
    $DocUrl= Get-FunctionDocUrl $fn
    $DocUrl
}
$FunctionsModulesPathFunctionsText = ForEach($fn in $FunctionsModulesPathFunctions){
    $DocUrl= Get-FunctionDocUrl $fn
    $DocUrl
}
$FunctionsModuleUpdaterText = ForEach($fn in $FunctionsModuleUpdater){
    $DocUrl= Get-FunctionDocUrl $fn
    $DocUrl
}
$FunctionsNamedPipeText = ForEach($fn in $FunctionsNamedPipe){
    $DocUrl= Get-FunctionDocUrl $fn
    $DocUrl
}
$FunctionsProcessDataText = ForEach($fn in $FunctionsProcessData){
    $DocUrl= Get-FunctionDocUrl $fn
    $DocUrl
}
$FunctionsprocesslistText = ForEach($fn in $Functionsprocesslist){
    $DocUrl= Get-FunctionDocUrl $fn
    $DocUrl
}
$FunctionsPromptText = ForEach($fn in $FunctionsPrompt){
    $DocUrl= Get-FunctionDocUrl $fn
    $DocUrl
}
$FunctionsRecordText = ForEach($fn in $FunctionsRecord){
    $DocUrl= Get-FunctionDocUrl $fn
    $DocUrl
}
$FunctionsRegistryText = ForEach($fn in $FunctionsRegistry){
    $DocUrl= Get-FunctionDocUrl $fn
    $DocUrl
}
$FunctionsRemoteDesktopText = ForEach($fn in $FunctionsRemoteDesktop){
    $DocUrl= Get-FunctionDocUrl $fn
    $DocUrl
}
$FunctionsRestartScriptText = ForEach($fn in $FunctionsRestartScript){
    $DocUrl= Get-FunctionDocUrl $fn
    $DocUrl
}
$FunctionsSaveEditProfileText = ForEach($fn in $FunctionsSaveEditProfile){
    $DocUrl= Get-FunctionDocUrl $fn
    $DocUrl
}
$FunctionsSearchPatternText = ForEach($fn in $FunctionsSearchPattern){
    $DocUrl= Get-FunctionDocUrl $fn
    $DocUrl
}
$FunctionsSelectUserText = ForEach($fn in $FunctionsSelectUser){
    $DocUrl= Get-FunctionDocUrl $fn
    $DocUrl
}
$FunctionsSetFirewallConfigText = ForEach($fn in $FunctionsSetFirewallConfig){
    $DocUrl= Get-FunctionDocUrl $fn
    $DocUrl
}
$FunctionsSetMappedDrivesText = ForEach($fn in $FunctionsSetMappedDrives){
    $DocUrl= Get-FunctionDocUrl $fn
    $DocUrl
}
$FunctionsSublText = ForEach($fn in $FunctionsSubl){
    $DocUrl= Get-FunctionDocUrl $fn
    $DocUrl
}
$FunctionsTestPortsText = ForEach($fn in $FunctionsTestPorts){
    $DocUrl= Get-FunctionDocUrl $fn
    $DocUrl
}
$FunctionsUnlockScriptsText = ForEach($fn in $FunctionsUnlockScripts){
    $DocUrl= Get-FunctionDocUrl $fn
    $DocUrl
}
$FunctionsUpdateLoginScriptsText = ForEach($fn in $FunctionsUpdateLoginScripts){
    $DocUrl= Get-FunctionDocUrl $fn
    $DocUrl
}
$FunctionsWgetDlText = ForEach($fn in $FunctionsWgetDl){
    $DocUrl= Get-FunctionDocUrl $fn
    $DocUrl
}
$FunctionsWinUpdateNotifyText = ForEach($fn in $FunctionsWinUpdateNotify){
    $DocUrl= Get-FunctionDocUrl $fn
    $DocUrl
}
$FunctionsWriteUtilsText = ForEach($fn in $FunctionsWriteUtils){
    $DocUrl= Get-FunctionDocUrl $fn
    $DocUrl
}

[string]$LastUpdate = (Get-Date).GetDateTimeFormats()[5]
$Text = @"


## Functions - BlockWebsite
$FunctionsBlockWebsiteText


## Functions - CheckAndGet
$FunctionsCheckAndGetText


## Functions - Config
$FunctionsConfigText


## Functions - ConfigureWellKnownPaths
$FunctionsConfigureWellKnownPathsText


## Functions - ConfigureWindowsTerminal
$FunctionsConfigureWindowsTerminalText


## Functions - ControlMouse
$FunctionsControlMouseText


## Functions - Credential
$FunctionsCredentialText


## Functions - CustomPathFunctions
$FunctionsCustomPathFunctionsText


## Functions - Decode
$FunctionsDecodeText


## Functions - Encode
$FunctionsEncodeText


## Functions - Exception
$FunctionsExceptionText


## Functions - ExportConnectionsData
$FunctionsExportConnectionsDataText


## Functions - ExportSystemInfo
$FunctionsExportSystemInfoText


## Functions - GetConns
$FunctionsGetConnsText


## Functions - GetCurrentContext
$FunctionsGetCurrentContextText


## Functions - GetEnvPath
$FunctionsGetEnvPathText


## Functions - GetFnSource
$FunctionsGetFnSourceText


## Functions - GetHistory
$FunctionsGetHistoryText


## Functions - GetLoggedInUsers
$FunctionsGetLoggedInUsersText


## Functions - GetTerminalStartingDirectory
$FunctionsGetTerminalStartingDirectoryText


## Functions - Helpers
$FunctionsHelpersText


## Functions - History
$FunctionsHistoryText


## Functions - Initialize
$FunctionsInitializeText


## Functions - ModulesPathFunctions
$FunctionsModulesPathFunctionsText


## Functions - ModuleUpdater
$FunctionsModuleUpdaterText


## Functions - NamedPipe
$FunctionsNamedPipeText


## Functions - ProcessData
$FunctionsProcessDataText


## Functions - processlist
$FunctionsprocesslistText


## Functions - Prompt
$FunctionsPromptText


## Functions - Record
$FunctionsRecordText


## Functions - Registry
$FunctionsRegistryText


## Functions - RemoteDesktop
$FunctionsRemoteDesktopText


## Functions - RestartScript
$FunctionsRestartScriptText


## Functions - SaveEditProfile
$FunctionsSaveEditProfileText


## Functions - SearchPattern
$FunctionsSearchPatternText


## Functions - SelectUser
$FunctionsSelectUserText


## Functions - SetFirewallConfig
$FunctionsSetFirewallConfigText


## Functions - SetMappedDrives
$FunctionsSetMappedDrivesText


## Functions - Subl
$FunctionsSublText


## Functions - TestPorts
$FunctionsTestPortsText


## Functions - UnlockScripts
$FunctionsUnlockScriptsText


## Functions - UpdateLoginScripts
$FunctionsUpdateLoginScriptsText


## Functions - WgetDl
$FunctionsWgetDlText


## Functions - WinUpdateNotify
$FunctionsWinUpdateNotifyText


## Functions - WriteUtils
$FunctionsWriteUtilsText

## Last Update

$LastUpdate
"@

$cnt = Get-Content "$PSScriptRoot\README.tpl"

$cnt = $cnt.Replace('__FUNCTIONS_DOCUMENTATION__',$Text)
$cnt
Set-Content "$PSScriptRoot\README.md" -Value $cnt