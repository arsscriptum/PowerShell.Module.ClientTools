#╔════════════════════════════════════════════════════════════════════════════════╗
#║                                                                                ║
#║   config.ps1                                                                   ║
#║                                                                                ║
#╟────────────────────────────────────────────────────────────────────────────────╢
#║   Guillaume Plante <codegp@icloud.com>                                         ║
#║   Code licensed under the GNU GPL v3.0. See the LICENSE file for details.      ║
#╚════════════════════════════════════════════════════════════════════════════════╝



function Get-ClientToolsUserCredentialID { 
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, HelpMessage="Overwrite if present")]
        [String]$Id
    )

    $DefaultUser = Get-ClientToolsDefaultUsername
    $Credz = "ClientTools_MODULE_USER_$DefaultUser"

    $DevAccount = Get-ClientToolsDevAccountOverride
    if($DevAccount){ return "ClientTools_MODULE_USER_$DevAccount" }
    
    return $Credz
}

function Get-ClientToolsAppCredentialID { 
    [CmdletBinding(SupportsShouldProcess)]
    param()
    $DefaultUser = Get-ClientToolsDefaultUsername
    $Credz = "ClientTools_MODULE_APP_$DefaultUser"

    $DevAccount = Get-ClientToolsDevAccountOverride
    if($DevAccount){ return "ClientTools_MODULE_APP_$DevAccount" }
    
    return $Credz
}

function Get-ClientToolsDevAccountOverride { 
    [CmdletBinding(SupportsShouldProcess)]
    param()

    $RegPath = Get-ClientToolsModuleRegistryPath
    if( $RegPath -eq "" ) { throw "not in module"; return ;}
    $DevAccount = ''
    $DevAccountOverride = Test-RegistryValue -Path "$RegPath" -Entry 'override_dev_account'
    if($DevAccountOverride){
        $DevAccount = Get-RegistryValue -Path "$RegPath" -Entry 'override_dev_account'
    }
    
    return $DevAccount
}

function Set-ClientToolsDevAccountOverride { 
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, HelpMessage="Overwrite if present")]
        [String]$Id
    )

    $RegPath = Get-ClientToolsModuleRegistryPath
    if( $RegPath -eq "" ) { throw "not in module"; return ;}
    New-RegistryValue -Path "$RegPath" -Entry 'override_dev_account' -Value "$Id" 'String'
    Set-RegistryValue -Path "$RegPath" -Entry 'override_dev_account' -Value "$Id"
    
    return $DevAccount
}

function Get-ClientToolsModuleUserAgent { 
    [CmdletBinding(SupportsShouldProcess)]
    param ()
    $ModuleName = ($ExecutionContext.SessionState).Module
    $Agent = "User-Agent $ModuleName. Custom Module."
   
    return $Agent
}


function Set-ClientToolsDefaultUsername {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, HelpMessage="Git Username")]
        [String]$User      
    )
    $RegPath = Get-ClientToolsModuleRegistryPath
    $ok = Set-RegistryValue  "$RegPath" "default_username" "$User"
    [environment]::SetEnvironmentVariable('DEFAULT_ClientTools_USERNAME',"$User",'User')
    return $ok
}

<#
    ClientToolsDefaultUsername
    New-ItemProperty -Path "$ENV:OrganizationHKCU\ClientTools.com" -Name 'default_username' -Value 'codecastor'
 #>
function Get-ClientToolsDefaultUsername {
    [CmdletBinding(SupportsShouldProcess)]
    param ()
    $RegPath = Get-ClientToolsModuleRegistryPath
    $User = (Get-ItemProperty -Path "$RegPath" -Name 'default_username' -ErrorAction Ignore).default_username
    if( $User -ne $null ) { return $User  }
    if( $Env:DEFAULT_ClientTools_USERNAME -ne $null ) { return $Env:DEFAULT_ClientTools_USERNAME ; }
    return $null
}


function Set-ClientToolsServer {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, HelpMessage="Git Server")]
        [String]$Hostname      
    )
    $RegPath = Get-ClientToolsModuleRegistryPath
    $ok = Set-RegistryValue  "$RegPath" "hostname" "$Hostname"
    [environment]::SetEnvironmentVariable('DEFAULT_ClientTools_SERVER',"$Hostname",'User')
    return $ok
}


function Get-ClientToolsServer {      
    [CmdletBinding(SupportsShouldProcess)]
    param ()$Script:MyInvocation.MyCommand.Name
    $RegPath = Get-ClientToolsModuleRegistryPath
    $Server = (Get-ItemProperty -Path "$RegPath" -Name 'hostname' -ErrorAction Ignore).hostname
    if( $Server -ne $null ) { return $Server }
     
    if( $Env:DEFAULT_ClientTools_SERVER -ne $null ) { return $Env:DEFAULT_ClientTools_SERVER  }
    return $null
}


function Test-ClientToolsModuleConfig { 
    $ClientToolsModuleInformation    = Get-ClientToolsModuleInformation;
    $hash = @{ ClientToolsServer               = Get-ClientToolsServer;
    ClientToolsDefaultUsername      = Get-ClientToolsDefaultUsername;
    ClientToolsModuleUserAgent      = Get-ClientToolsModuleUserAgent;
    ClientToolsDevAccountOverride   = Get-ClientToolsDevAccountOverride;
    ClientToolsUserCredentialID     = Get-ClientToolsUserCredentialID;
    ClientToolsAppCredentialID      = Get-ClientToolsAppCredentialID;
    RegistryRoot               = $ClientToolsModuleInformation.RegistryRoot;
    ModuleSystemPath           = $ClientToolsModuleInformation.ModuleSystemPath;
    ModuleInstallPath          = $ClientToolsModuleInformation.ModuleInstallPath;
    ModuleName                 = $ClientToolsModuleInformation.ModuleName;
    ScriptName                 = $ClientToolsModuleInformation.ScriptName;
    ModulePath                 = $ClientToolsModuleInformation.ModulePath; } 

    Write-Host "---------------------------------------------------------------------" -f DarkRed
    $hash.GetEnumerator() | ForEach-Object {
        $k = $($_.Key) ; $kl = $k.Length ; if($kl -lt 30){ $diff =30 - $kl ; for($i=0;$i -lt $diff ; $i++) { $k += ' '; }}
        Write-Host "$k" -n -f DarkRed
        Write-Host "$($_.Value)" -f DarkYellow
    }
    Write-Host "---------------------------------------------------------------------" -f DarkRed
}

function Get-ClientToolsModuleRegistryPath { 
    [CmdletBinding(SupportsShouldProcess)]
    param ()
    if( $ExecutionContext -eq $null ) { throw "not in module"; return "" ; }
    $ModuleName = ($ExecutionContext.SessionState).Module
    if(-not($ModuleName)){$ModuleName = "PowerShell.Module.ClientTools"}
    $Path = "$ENV:OrganizationHKCU\$ModuleName"
   
    return $Path
}

function Get-ClientToolsModuleInformation {
    [CmdletBinding()]
    param ()
    try{
        if( $ExecutionContext -eq $null ) { throw "not in module"; return "" ; }
        $ModuleName = $ExecutionContext.SessionState.Module
        $ModuleScriptPath = $Script:MyInvocation.MyCommand.Path
        $ModuleInstallPath = (Get-Item "$ModuleScriptPath").DirectoryName
        $CurrentScriptName = $MyInvocation.MyCommand.Name
        $RegistryPath = "$ENV:OrganizationHKCU\$ModuleName"
        $ModuleSystemPath = (Resolve-Path "$ModuleInstallPath\..").Path
        $ModuleInformation = @{
            ModuleName        = $ModuleName
            ModulePath        = $ModuleScriptPath
            ScriptName        = $CurrentScriptName
            RegistryRoot      = $RegistryPath
            ModuleSystemPath  = $ModuleSystemPath
            ModuleInstallPath = $ModuleInstallPath
        }
        return $ModuleInformation        
    }catch{
        Show-ExceptionDetails $_ -ShowStack
    }
}
