
<#
#̷𝓍   𝓖𝓾𝓲𝓵𝓵𝓪𝓾𝓶𝓮 𝓟𝓵𝓪𝓷𝓽𝓮
#̷𝓍   𝓛𝓾𝓶𝓲𝓷𝓪𝓽𝓸𝓻 𝓣𝓮𝓬𝓱𝓷𝓸𝓵𝓸𝓰𝔂 𝓖𝓻𝓸𝓾𝓹
#̷𝓍   𝚐𝚞𝚒𝚕𝚕𝚊𝚞𝚖𝚎.𝚙𝚕𝚊𝚗𝚝𝚎@𝚕𝚞𝚖𝚒𝚗𝚊𝚝𝚘𝚛.𝚌𝚘𝚖
#>



function Publish-RegistryChanges ## NOEXPORT
{

    <#
    .SYNOPSIS
        Simulates like the Windows UI : sends a WM_SETTINGCHANGE broadcast to all Windows notifying them of the change to settings so they can refresh their config and you can do it too!
    .DESCRIPTION
        Simulates like the Windows UI : sends a WM_SETTINGCHANGE broadcast to all Windows notifying them of the change to settings so they can refresh their config and you can do it too!
        
    .PARAMETER Timeout 
       Timeout
    .PARAMETER Flags
        SMTO_ABORTIFHUNG 0x0002
        The function returns without waiting for the time-out period to elapse if the receiving thread appears to not respond or "hangs."
        SMTO_BLOCK 0x0001
        Prevents the calling thread from processing any other requests until the function returns.
        SMTO_NORMAL0x0000
        The calling thread is not prevented from processing other requests while waiting for the function to return.
        SMTO_NOTIMEOUTIFNOTHUNG 0x0008
        The function does not enforce the time-out period as long as the receiving thread is processing messages.
        SMTO_ERRORONEXIT 0x0020
        The function should return 0 if the receiving window is destroyed or its owning thread dies while the message is being processed.
    #>

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $false, Position = 0)]
        [int]$Timeout = 1000,
        [Parameter(Mandatory = $false, Position = 1)]
        [int]$Flags = 2 # SMTO_ABORTIFHUNG: return if receiving thread does not respond (hangs)
    )
    $TypeAdded = $True
    try {
        [WinAPI.RegAnnounce]$test
    } catch {
        $TypeAdded = $False
        Write-Verbose "WinAPI.RegAnnounce not declared..."
    }
    $Result = $true
    $funcDef = @'

        [DllImport("user32.dll", SetLastError = true, CharSet=CharSet.Auto)]

         public static extern IntPtr SendMessageTimeout (
            IntPtr     hWnd,
            uint       msg,
            UIntPtr    wParam,
            string     lParam,
            uint       fuFlags,
            uint       uTimeout,
        out UIntPtr    lpdwResult
         );

'@

    if ($TypeAdded -eq $False) {
        Write-Verbose "ADDING WinAPI.RegAnnounce"
        $funcRef = add-type -Namespace WinAPI -Name RegAnnounce -MemberDefinition $funcDef
    }

    try {
        $HWND_BROADCAST = [intPtr]0xFFFF
        $WM_SETTINGCHANGE = 0x001A # Same as WM_WININICHANGE
        $fuFlags = $Flags
        $timeOutMs = $Timeout # Timeout in milli seconds
        $res = [uIntPtr]::Zero

        # If the function succeeds, this value is non-zero.
        $funcVal = [WinAPI.RegAnnounce]::SendMessageTimeout($HWND_BROADCAST, $WM_SETTINGCHANGE, [UIntPtr]::Zero, "Environment", $fuFlags, $timeOutMs, [ref]$res);

        if ($funcVal -eq 0) {
            throw "SendMessageTimeout did not succeed, res= $res"
        }
        else {
            write-Verbose "Message sent"
            return $True
        }
    }
    catch {
        $Result = $False
        Write-Error $_
    }
    return $Result
}

function Publish-SettingsUpdated {
    $cmdFile = (getcmd 'RefreshEnv.cmd').Source
    & "$cmdFile"
    Publish-RegistryChanges
}


function Test-RegistryValue
{
    <#
    .Synopsis
    Check if a value exists in the Registry
    .Description
    Check if a value exists in the Registry
    .Parameter Path
    Value registry path
    .Parameter Entry
    The entry to validate
    .Inputs
    None
    .Outputs
    None
    .Example
    Test-RegistryValue "$ENV:OrganizationHKCU\terminal" "CurrentProjectPath" 
    >> TRUE

#>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [ValidateScript({
                $Exists = (gi $_ -ErrorAction Ignore)
                if ($Exists -ne $Null) {
                    $type = (gi $_).PSProvider.Name
                    if (($type) -ne 'Registry') {
                        throw "`"$_`" not a registry PATH. Its a $type"
                    }
                }
                return $true
            })]
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Path,
        [Parameter(Mandatory = $true, Position = 1)]
        [Alias('Entry')]
        [ValidateNotNullOrEmpty()] $Name
    )

    if (-not (Test-Path $Path)) {
        Write-Verbose "[Test-RegistryValue] Test-Path -Path `"$Path`" ==> RETURNED FALSE"
        return $false
    }
    $props = Get-ItemProperty -Path "$Path" -ErrorAction Ignore
    if ($props -eq $Null) { return $False }
    $value = $props.$Name
    if ($null -eq $value -or $value.Length -eq 0) { return $false }

    return $true

}



function Get-RegistryValue
{
    <#
    .Synopsis
    Check if a value exists in the Registry
    .Description
    Check if a value exists in the Registry
    .Parameter Path
    Value registry path
    .Parameter Entry
    The entry to validate
    .Inputs
    None
    .Outputs
    None
    .Example
    Get-RegistryValue "$ENV:OrganizationHKCU\terminal" "CurrentProjectPath" 
    Get-RegistryValue "$ENV:OrganizationHKLM\PowershellToolsSuite\GitHubAPI" "AccessToken"
    >> TRUE

#>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [ValidateScript({
                $Exists = (gi $_ -ErrorAction Ignore)
                if ($Exists -ne $Null) {
                    $type = (gi $_).PSProvider.Name
                    if (($type) -ne 'Registry') {
                        throw "`"$_`" not a registry PATH. Its a $type"
                    }
                }
                return $true
            })]
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Path,
        [Parameter(Mandatory = $true, Position = 1)]
        [Alias('Entry')]
        [string]$Name
    )

    if (-not (Test-RegistryValue $Path $Name)) {
        return $null
    }
    try {
        $Result = (Get-ItemProperty -Path $Path | Select-Object -ExpandProperty $Name)
        return $Result
    }

    catch {
        return $null
    }

}


function Get-RegistryValue_Deprecated
{
    [CmdletBinding(DefaultParameterSetName = 'HKLM')]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string[]]
        $Key,

        [Parameter()]
        [string]
        $ValueName,

        [Parameter(Mandatory = $true, ParameterSetName = 'HKU')]
        [string]
        $SecurityIdentifier
    )

    process
    {
        foreach ($k in $Key)
        {
            if ((Get-WmiObject -Class Win32_ComputerSystem).SystemType -match 'x64')
            {
                $RegView = [Microsoft.Win32.RegistryView]::Registry64
            }
            else
            {
                $RegView = [Microsoft.Win32.RegistryView]::Registry32
            }

            if ($PSCmdlet.ParameterSetName -eq 'HKLM')
            {
                $basekey = [Microsoft.Win32.RegistryKey]::OpenBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $RegView)
                $keyname = $k
                $subKey = $basekey.OpenSubKey($k)
            }
            else
            {
                $basekey = [Microsoft.Win32.RegistryKey]::OpenBaseKey([Microsoft.Win32.RegistryHive]::Users, $RegView)
                $keyname = "$($SecurityIdentifier)\$($k)"
                $subKey = $basekey.OpenSubKey("$($SecurityIdentifier)\$($k)")
            }

            if ($subKey)
            {
                foreach ($value in ($subKey.GetValueNames()))
                {
                    if ($PSBoundParameters.ContainsKey('ValueName'))
                    {
                        if ($value -eq $ValueName)
                        {
                            $props = @{
                                Key = "$($PSCmdlet.ParameterSetName)\$($keyname)"
                                ValueName = $value
                                Value = ($subKey.GetValue($value, $NULL, [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames))
                            }

                            New-Object -TypeName psobject -Property $props
                        }
                    }
                    else
                    {
                        $props = @{
                            Key = "$($PSCmdlet.ParameterSetName)\$($keyname)"
                            ValueName = $value
                            Value = ($subKey.GetValue($value, $NULL, [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames))
                        }

                        New-Object -TypeName psobject -Property $props
                    }
                }
            }

            $basekey.Close()
        }
    }
}




function Remove-RegistryValue
{
    <#
    .Synopsis
    Add a value in the registry, if it exists, it will replace
    .Description
    Add a value in the registry, if it exists, it will replace
    .Parameter Path
    Path
    .Parameter Name
    Name
    .Parameter Value
    Value 
    .Inputs
    None
    .Outputs
    SUCCESS(true) or FAILURE(false)
    .Example
    Set-RegistryValue "$ENV:OrganizationHKLM\reddit-pwsh-script" "ATestingToken" "blabla"
    >> TRUE

#>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [ValidateScript({
                $Exists = (gi $_ -ErrorAction Ignore)
                if ($Exists -ne $Null) {
                    $type = (gi $_).PSProvider.Name
                    if (($type) -ne 'Registry') {
                        throw "`"$_`" not a registry PATH. Its a $type"
                    }
                }
                return $true
            })]
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Path,
        [Parameter(Mandatory = $true, Position = 1)]
        [Alias('Entry')]
        [string]$Name,
        [Parameter(Mandatory = $false)]
        [switch]$Publish
    )


    try {
        if (Test-RegistryValue -Path $Path -Entry $Name -ErrorAction Ignore) {
            Remove-ItemProperty -Path $Path -Name $Name -Force -ErrorAction ignore | Out-null
        }
        $Result = $True
        if ($Publish) { $Result = Publish-RegistryChanges }
        return $Result
    }

    catch {
        $Result = $False
        Show-ExceptionDetails $_
    }
    return $Result
}


function Find-EntriesMatchingName {
    <#
    .Synopsis
       Check in a registry path and subpaths for all entries that have the property name matching $MatchString, and return those entries.
    .Description
     
    .Parameter Path
       The registry path to search in

    .Parameter MatchString
       The registry enttry name to search for. Example Value 'Open' will find all matching open

    .OUTPUTS
       Retunr the values that would be deleted or were deleted...

    .Example
        ### Look for values and SIMULATE deletion. Use WhatIf to validae all entries that will be deleted.
        Find-EntriesMatchingName  -Path "HKCU:\SOFTWARE\_gp\DevelopmentSandbox\TestSettings" -WhatIf 

        Find-EntriesMatchingName  -Path "HKCU:\SOFTWARE\_gp\DevelopmentSandbox\TestSettings" -MatchString 'Open'
#>

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [ValidateScript({
                $Exists = (gi $_ -ErrorAction Ignore)
                if ($Exists -ne $Null) {
                    $type = (gi $_).PSProvider.Name
                    if (($type) -ne 'Registry') {
                        throw "`"$_`" not a registry PATH. Its a $type"
                    }
                }
                return $true
            })]
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Path,
        [Parameter(Mandatory = $false)]
        [string]$MatchString = 'Open',
        [Parameter(Mandatory = $false)]
        [switch]$Recurse
    )

    $FoundEntries = [System.Collections.ArrayList]::new()
    # Get all the registry child entries that have at least One property mathing our string...
    $ChildEntries = Get-ChildItem -Path $Path -Recurse:$Recurse | Where-Object { ($_.Property -match $MatchString) } | select Name

    $TotalChildPaths = $ChildEntries.Count
    Write-Verbose "Found entries in $TotalChildPaths child paths. Recurse $Recurse"
    foreach ($child in $ChildEntries) {
        $regpath = "Registry::$($child.Name)"
        # get all the properties in the registry path
        $regdata = get-item $regpath;
        # split them so we can loop in properties
        $regprops = ($regdata | Select-Object -ExpandProperty Property).Split(' ')
        foreach ($propname in $regprops) {
            # if the property name matches the MatchString, remove it!
            if ($propname -imatch $MatchString) {
                Write-Verbose "Would remove $regpath // $propname"
                $prop_data = Get-ItemProperty $regpath -Name $propname -ErrorAction Ignore
                $prop_value = $null
                if ($prop_data -ne $Null) {
                    $prop_value = $prop_data | Select -ExpandProperty $propname
                }
                $obj = [pscustomobject]@{
                    Path = $regpath
                    Name = $propname
                    Value = $prop_value
                }
                [void]$FoundEntries.Add($obj)
            }

        }

    }
    $FoundEntries
}



function New-RegistryValue
{
    <#
    .Synopsis
    Create FULL Registry Path and add value
    .Description
    Add a value in the registry, if it exists, it will replace
    .Parameter Path
    Path
    .Parameter Name
    Name
    .Parameter Value
    Value 
    .Inputs
    None
    .Outputs
    SUCCESS(true) or FAILURE(false)
    .Example
    New-RegistryValue "$ENV:OrganizationHKCU\terminal" "CurrentProjectPath" "D:\Development\CodeCastor\network\netlib" "String" -publish
    >> TRUE

#>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [ValidateScript({
                $Exists = (gi $_ -ErrorAction Ignore)
                if ($Exists -ne $Null) {
                    $type = (gi $_).PSProvider.Name
                    if (($type) -ne 'Registry') {
                        throw "`"$_`" not a registry PATH. Its a $type"
                    }
                }
                return $true
            })]
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$Path,
        [Parameter(Mandatory = $true, Position = 1)]
        [Alias('Entry')]
        [ValidateNotNullOrEmpty()] $Name,
        [Parameter(Mandatory = $true, Position = 2)]
        [ValidateNotNullOrEmpty()] $Value,
        [Parameter(Mandatory = $true, Position = 3)]
        [Alias('Type')]
        [ValidateSet("String", "ExpandString", "Binary", "DWord", "MultiString", "QWord", "Unknown")]
        [ValidateNotNullOrEmpty()] $Kind,
        [Parameter(Mandatory = $false)]
        [switch]$Publish
    )
    [bool]$Force = $True
    try {
        Write-Verbose "[New-RegistryValue] Test-Path -Path `"$Path`""
        if (Test-Path -Path $Path) {
            Write-Verbose "[New-RegistryValue] Test-RegistryValue -Path `"$Path`" -Entry `"$Name`""
            if (Test-RegistryValue -Path $Path -Entry $Name) {
                if ($Force) {
                    Write-Verbose "[New-RegistryValue] Remove-ItemProperty -Path $Path -Name $Name -Force"
                    Remove-ItemProperty -Path $Path -Name $Name -Force -ErrorAction ignore | Out-null
                } else {
                    throw "Value already exists: $Path $Name. use -Force to overwrite"
                }
            }
        }
        else {
            Write-Verbose "[New-RegistryValue] New-Item -Path $Path -Force"
            New-Item -Path $Path -Force | Out-null
        }

        Write-Verbose "[New-RegistryValue] New-ItemProperty -Path $Path -Name $Name -Value $Value"

        New-ItemProperty -Path $Path -Name $Name -Value $Value -PropertyType $Type | Out-null
        $Result = $True
        if ($Publish) { $Result = Publish-RegistryChanges }
        return $Result
    }


    catch {
        $Result = $False
        Show-ExceptionDetails $_ -ShowStack
    }
    return $Result
}


<#
.SYNOPSIS 
 Deletes a registry key recursively

.DESCRIPTION
 This function will delete the specified registry key and all its values and subkeys

.INPUTS
 None. You cannot pipe objects to Delete-RegistryKeyTree.

.EXAMPLE
 Delete-RegistryKeyTree -Hive HKCR -Key "CLSID\squid" -User $env:USERNAME

.OUTPUTS
 System.String

.NOTES
 Name:    Delete-RegistryKeyTree
#>
function Delete-RegistryKeyTree {
    [CmdletBinding(SupportsShouldProcess = $false)]
    param([Parameter(Mandatory = $true, ValueFromPipeline = $false)][ValidateSet("HKCR", "HKLM", "HKCU", "HKU", "HKCC")] [string]$Hive,
        [Parameter(Mandatory = $true, ValueFromPipeline = $false)][ValidateNotNullOrEmpty()] [string]$Key,
        [Parameter(Mandatory = $true, ValueFromPipeline = $false)][ValidateNotNullOrEmpty()] [string]$User)

    process {
        switch ($Hive) {
            "HKCR" { $rootKey = [Microsoft.Win32.RegistryHive]::ClassesRoot; break }
            "HKLM" { $rootKey = [Microsoft.Win32.RegistryHive]::LocalMachine; break }
            "HKCU" { $rootKey = [Microsoft.Win32.RegistryHive]::CurrentUser; break }
            "HKU" { $rootKey = [Microsoft.Win32.RegistryHive]::Users; break }
            "HKCC" { $rootKey = [Microsoft.Win32.RegistryHive]::CurrentConfig; break }
        }

        Get-UserConfirmationRegDel "Delete Registry Tree `"$Key`""

        $Reg = [Microsoft.Win32.RegistryKey]::OpenBaseKey($rootKey, [Microsoft.Win32.RegistryView]::Default)
        $RegKey = $Reg.OpenSubKey($Key, [Microsoft.Win32.RegistryKeyPermissionCheck]::ReadWriteSubTree, [System.Security.AccessControl.RegistryRights]::FullControl)
        if ($RegKey -eq $null) { Write-Warning "Registry key is already deleted." }
        else {
            Write-Verbose "Deleting key $Key"
            Take-Ownership -Path "Registry::$Hive\$Key" -User $User -Recurse
            Write-Verbose "Resetting permissions on $Key"
            $ACL = New-Object System.Security.AccessControl.RegistrySecurity
            $ACL.SetAccessRuleProtection($false, $false)
            $FSR = New-Object System.Security.AccessControl.RegistryAccessRule ($User, [System.Security.AccessControl.RegistryRights]::FullControl, ([System.Security.AccessControl.InheritanceFlags]::ContainerInherit -bor [System.Security.AccessControl.InheritanceFlags]::ObjectInherit), [System.Security.AccessControl.PropagationFlags]::None, [System.Security.AccessControl.AccessControlType]::Allow)
            $ACL.ResetAccessRule($FSR)
            $RegKey.Close()
            $RegKey = $Reg.OpenSubKey($Key, [Microsoft.Win32.RegistryKeyPermissionCheck]::ReadWriteSubTree, [System.Security.AccessControl.RegistryRights]::ChangePermissions)
            $RegKey.SetAccessControl($ACL)
            $RegKey.Close()
            $Reg.Close()
            Write-Verbose "Deleting $Key"
            $result = & cmd /c "reg delete $Hive\$Key /f"
            Write-Verbose $result[0]
        }
    }
}
function Get-UserConfirmationRegDel {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$Msg
    )
    Write-Host "===============================" -f DarkRed
    Write-Host "[IMPORTANT TRANSACTION PENDING] " -f DarkYellow -n
    Write-Host "$Msg" -f DarkRed
    Write-Host "===============================" -f DarkRed
    Write-Host "ARE YOU SURE ?" -n -f DarkRed
    $a = Read-Host "?"
    if ($a -eq 'y') { return }
    throw "CONFIRMATION REQUIRED"
}

function Set-RegistryValue2 {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [ValidateScript({
                $Exists = (gi $_ -ErrorAction Ignore)
                if ($Exists -ne $Null) {
                    $type = (gi $_).PSProvider.Name
                    if (($type) -ne 'Registry') {
                        throw "`"$_`" not a registry PATH. Its a $type"
                    }
                    $hive = $_.substring(0, ($_.IndexOf(':')))
                    $Hives = @("HKCR", "HKLM", "HKCU", "HKU", "HKCC")
                    if ($Hives.Contains($hive) -eq $False) {
                        throw "`"$_`" not a registry HIVE."
                    }
                }
                return $true
            })]
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$Path,
        [Parameter(Mandatory = $true, Position = 1)]
        [string]$Name,
        [Parameter(Mandatory = $true, Position = 2)]
        [string]$Value,
        [Parameter(Mandatory = $true, Position = 3)]
        [Alias('Type')]
        [ValidateSet("String", "ExpandString", "Binary", "DWord", "MultiString", "QWord")]
        [string]$Kind
    )

    $i = $Path.IndexOf(':')
    $Hive = $Path.substring(0, $i)
    $Key = $Path.substring($i + 2, $Path.Length - $i - 2)
    switch ($Hive) {
        "HKCR" { $rootKey = [Microsoft.Win32.RegistryHive]::ClassesRoot; break }
        "HKLM" { $rootKey = [Microsoft.Win32.RegistryHive]::LocalMachine; break }
        "HKCU" { $rootKey = [Microsoft.Win32.RegistryHive]::CurrentUser; break }
        "HKU" { $rootKey = [Microsoft.Win32.RegistryHive]::Users; break }
        "HKCC" { $rootKey = [Microsoft.Win32.RegistryHive]::CurrentConfig; break }
    }

    Write-Verbose "Opening Base Key `"$rootKey`""
    $Reg = [Microsoft.Win32.RegistryKey]::OpenBaseKey($rootKey, [Microsoft.Win32.RegistryView]::Registry64)

    if ($Reg -eq $null) { throw "cannot open base key  `"$rootKey`"" }
    Write-Verbose "Opening sub Key `"$Key`""
    $RegKey = $Reg.OpenSubKey($Key, $True)
    if ($RegKey -eq $null) { throw "cannot open sub key  `"$Key`"" }
    Write-Verbose "SetValue sub Key `"$Name`" $Value"
    $RegKey.SetValue($Name, $Value, [Microsoft.Win32.RegistryValueKind]::$Kind)
    $RegKey.Close()
    $Reg.Dispose()
}


function Set-RegistryValue
{
    <#
    .Synopsis
    Add a value in the registry, if it exists, it will replace
    .Description
    Add a value in the registry, if it exists, it will replace
    .Parameter Path
    Path
    .Parameter Name
    Name
    .Parameter Value
    Value 
    .Inputs
    None
    .Outputs
    SUCCESS(true) or FAILURE(false)
    .Example
    Set-RegistryValue "$ENV:OrganizationHKLM\reddit-pwsh-script" "ATestingToken" "blabla"
    >> TRUE

#>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [ValidateScript({
                $Exists = (gi $_ -ErrorAction Ignore)
                if ($Exists -ne $Null) {
                    $type = (gi $_).PSProvider.Name
                    if (($type) -ne 'Registry') {
                        throw "`"$_`" not a registry PATH. Its a $type"
                    }
                }
                return $true
            })]
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Path,
        [Parameter(Mandatory = $true, Position = 1)]
        [Alias('Entry')]
        [string]$Name,
        [Parameter(Mandatory = $true, Position = 2)]
        [string]$Value,
        [Parameter(Mandatory = $false, Position = 3)]
        [ValidateSet("String", "ExpandString", "Binary", "DWord", "MultiString", "QWord")]
        [Alias('Type')]
        [string]$Kind,
        [Parameter(Mandatory = $false)]
        [switch]$Publish
    )
    [bool]$Force = $True
    if (-not (Test-Path $Path)) {
        if ($Force) {
            New-Item -Path $Path -ItemType directory -Force -ErrorAction ignore | Out-null
        }

    }

    try {
        if (Test-RegistryValue -Path $Path -Entry $Name) {
            Remove-ItemProperty -Path $Path -Name $Name -Force -ErrorAction ignore | Out-null
        }
        $props = Get-ItemProperty -Path "$Path" -Name $Name -ErrorAction Ignore
        if ($Null -eq $props) {
            if ($Force) {
                New-ItemProperty -Path $Path -Name $Name -Value $Value -PropertyType $Kind -Force | Out-null
            } else {
                throw "No such property: Name `"$Name`" -Value `"$Value`" kind `"$Kind`" . Use -Force to create"
            }
        }
        Set-ItemProperty -Path $Path -Name $Name -Value $Value -Force | Out-null
        $Result = $True

        if ($Publish) { $Result = Publish-RegistryChanges }
    }

    catch {
        $Result = $False
        Show-ExceptionDetails $_
    }
    return $Result
}
