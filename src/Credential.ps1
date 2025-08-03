
<#
#̷𝓍   𝓖𝓾𝓲𝓵𝓵𝓪𝓾𝓶𝓮 𝓟𝓵𝓪𝓷𝓽𝓮
#̷𝓍   𝓛𝓾𝓶𝓲𝓷𝓪𝓽𝓸𝓻 𝓣𝓮𝓬𝓱𝓷𝓸𝓵𝓸𝓰𝔂 𝓖𝓻𝓸𝓾𝓹
#̷𝓍   𝚐𝚞𝚒𝚕𝚕𝚊𝚞𝚖𝚎.𝚙𝚕𝚊𝚗𝚝𝚎@𝚕𝚞𝚖𝚒𝚗𝚊𝚝𝚘𝚛.𝚌𝚘𝚖
#>



function Get-CoreModuleRegistryPath {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    if ($ExecutionContext -eq $null) { throw "not in module"; return ""; }
    $ModuleName = ($ExecutionContext.SessionState).Module
    $Path = "$ENV:OrganizationHKCU\$ModuleName"

    return $Path
}
function Get-CredentialsRegistryPath {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $false)]
        [switch]$GlobalScope
    )
    if ($ExecutionContext -eq $null) { throw "not in module"; return ""; }
    $ModuleName = ($ExecutionContext.SessionState).Module
    $CoreModuleRegistryPath = "$ENV:OrganizationHKCU\$ModuleName"
    if ($GlobalScope) {
        $CoreModuleRegistryPath = "$ENV:OrganizationHKLM\$ModuleName"
    }
    $CoreModuleRegistryPath = "$ENV:OrganizationHKCU\$ModuleName"
    $Path = "$CoreModuleRegistryPath\Credentials"

    return $Path
}

function Show-RegisteredCredentials {
    <#
    .SYNOPSIS
            Cmdlet to register new credentials in the DB

    .PARAMETER Id
            Application Id

#>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $false)]
        [string]$Filter,
        [Alias("global", "allusers")]
        [Parameter(Mandatory = $false)]
        [switch]$GlobalScope
    )
    $RegKeyCredsManagerRoot = (Get-CredentialsRegistryPath -GlobalScope:$GlobalScope)
    $RegKeyRoot = "$RegKeyCredsManagerRoot\$Id\credentials"
    if ($GlobalScope) {
        if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')) {
            Write-Host "GlobalScope Requires Admin privilege"
            return $false
        }
    }

    $Entries = [System.Collections.ArrayList]::new()
    $ItemProperties = Get-ItemProperty $RegKeyCredsManagerRoot
    $List = (Get-Item $RegKeyCredsManagerRoot).Property
    foreach ($id in $List) {
        $UnixTime = $ItemProperties. "$id"
        $epoch = [datetime]::SpecifyKind('1970-01-01', 'Utc')
        $RegisteredDate = $epoch.AddSeconds($UnixTime)
        $c = Get-AppCredentials -Id $id -GlobalScope:$GlobalScope
        $Entry = [pscustomobject]@{
            Id = $id
            UnixTime = $UnixTime
            RegisteredDate = $RegisteredDate
            Credentials = $c
        }
        $Entries.Add($Entry)
    }
    return $Entries
}

function Remove-AppCredentials {
    <#
    .SYNOPSIS
            Cmdlet to register new credentials in the DB

    .PARAMETER Id
            Application Id

#>

    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $True, Position = 0)]
        [string]$Id,
        [Alias("global", "allusers")]
        [Parameter(Mandatory = $false)]
        [switch]$GlobalScope
    )
    $RegKeyCredsManagerRoot = (Get-CredentialsRegistryPath -GlobalScope:$GlobalScope)
    $RegKeyRoot = "$RegKeyCredsManagerRoot\$Id"
    if ($GlobalScope) {
        if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')) {
            Write-Host "GlobalScope Requires Admin privilege"
            return $false
        }
    }
    Remove-Item $RegKeyRoot -Force -Recurse -ErrorAction Ignore
}

function Register-AppCredentials {
    <#
    .SYNOPSIS
            Cmdlet to register new credentials in the DB

    .PARAMETER Id
            Application Id

#>

    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $True, Position = 0)]
        [string]$Id,
        [Parameter(Mandatory = $false)]
        [Alias('u')]
        [string]$Username,
        [Parameter(Mandatory = $false)]
        [Alias('p')]
        [string]$Password,
        [Alias("global", "allusers")]
        [Parameter(Mandatory = $false)]
        [switch]$GlobalScope
    )
    $RegKeyCredsManagerRoot = (Get-CredentialsRegistryPath -GlobalScope:$GlobalScope)
    $RegKeyRoot = "$RegKeyCredsManagerRoot\$Id\credentials"
    if ($GlobalScope) {
        if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')) {
            Write-Host "GlobalScope Requires Admin privilege"
            return $false
        }

    }

    [pscredential]$Credentials = $Null
    if (($PSBoundParameters.ContainsKey('Username')) -and ($PSBoundParameters.ContainsKey('Password'))) {

        # Convert to SecureString
        [securestring]$SecPassword = ConvertTo-SecureString $Password -AsPlainText -Force
        [pscredential]$Credentials = New-Object System.Management.Automation.PSCredential ($Username, $SecPassword)
    } else {
        [pscredential]$Credentials = Get-Credential
    }

    $Username = $Credentials.UserName
    $EncodedPassword = ConvertFrom-SecureString $Credentials.Password

    $Now = Get-Date
    $epoch = [datetime]::SpecifyKind('1970-01-01', 'Utc')
    $epoch = [int64]($Now.ToUniversalTime() - $epoch).TotalSeconds
    New-RegistryValue -Path $RegKeyCredsManagerRoot -Name "$Id" -Type "DWORD" -Value $epoch
    $r1 = New-RegistryValue -Path $RegKeyRoot -Name "username" -Value $Username -Type "String"
    $r2 = New-RegistryValue -Path $RegKeyRoot -Name "password" -Value $EncodedPassword -Type "String"

    return ($r1 -and $r2)
}

function Get-AppCredentials {
    <#
    .SYNOPSIS
            Cmdlet to register new credentials in the DB

    .PARAMETER Id
            Application Id

#>

    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $True, Position = 0)]
        [string]$Id,
        [Alias("global", "allusers")]
        [Parameter(Mandatory = $false)]
        [switch]$GlobalScope
    )
    try {
        $RegKeyCredsManagerRoot = (Get-CredentialsRegistryPath -GlobalScope:$GlobalScope)
        $RegKeyRoot = "$RegKeyCredsManagerRoot\$Id\credentials"
        if ($GlobalScope) {
            if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')) {
                Write-Host "GlobalScope Requires Admin privilege"
                return $false
            }
            $RegKeyRoot = "$ENV:OrganizationHKLM\$Id\credentials"
            if (-not (Test-Path $RegKeyRoot)) {
                return $null
            }
        }
        if (-not (Test-Path $RegKeyRoot)) {
            return $null
        }
        $Username = Get-RegistryValue $RegKeyRoot "username"
        $Passwd = Get-RegistryValue $RegKeyRoot "password"
        try {
            $Password = ConvertTo-SecureString $Passwd -ErrorAction Stop
        } catch {
            Write-Warning "The Decryption Failed! The Secure Key is linked to the user account and the Computer name, if either changed, it broke the encrypted values"
            throw ($_)
        }
        $Credentials = New-Object System.Management.Automation.PSCredential $Username, $Password

        return $Credentials
    } catch {
        Write-Error "$_"
    }
}

function Get-ElevatedCredential {
    <#
    .SYNOPSIS
            Cmdlet to get recorder elevated privilege
    .DESCRIPTION
            Cmdlet to get recorder elevated privilege, record it using the -Reset parameter

    .PARAMETER Reset
             Reset the elevated privilege user/password

#>

    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $false)]
        [Alias("r")]
        [switch]$Reset,
        [Alias("global", "allusers")]
        [Parameter(Mandatory = $false)]
        [switch]$GlobalScope
    )
    $AppName = "DevApp"
    if ($Reset.IsPresent) {
        Write-Output "Setting credentials"
        $Set = Register-AppCredentials $AppName -GlobalScope:$GlobalScope
        if ($Set -eq $false) {
            Write-Error "Problem recording credentials"
            return $null
        }
    }

    $Creds = Get-AppCredentials $AppName -GlobalScope:$GlobalScope
    if ($Creds -ne $null) {
        return $Creds
    }
    Write-Error "No elevated credentials were registered. (use Reset param)"
    return $null
}

