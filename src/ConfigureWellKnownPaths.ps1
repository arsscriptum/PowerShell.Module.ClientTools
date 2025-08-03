﻿#╔════════════════════════════════════════════════════════════════════════════════╗
#║                                                                                ║
#║   ConfigureWellKnownPaths.ps1                                                  ║
#║                                                                                ║
#╟────────────────────────────────────────────────────────────────────────────────╢
#║   Guillaume Plante <codegp@icloud.com>                                         ║
#║   Code licensed under the GNU GPL v3.0. See the LICENSE file for details.      ║
#╚════════════════════════════════════════════════════════════════════════════════╝



function Set-EnvironmentVariable {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Name,
        [Parameter(Mandatory = $false)]
        [string]$Value = $Null,
        [Parameter(Mandatory = $false)]
        [ValidateSet('User', 'Machine', 'Session', 'UserSession')]
        [string]$Scope = 'UserSession'
    )
    switch ($Scope.ToLower())
    {
        { 'session', 'usersession' -eq $_ }
        {
            $CurrentSetting = (Get-ChildItem -Path env: -Recurse | % -Process { if ($_.Name -eq $Name) { $_.Value } })

            if (($CurrentSetting -eq $null) -or ($CurrentSetting -ne $null -and $CurrentSetting.Value -ne $Value)) {
                Write-Verbose "Environment Setting $Name is not set or has a different value, changing to $Value"
                $TempPSDrive = $(get-date -Format "temp\hhh-\mmmm-\sss")
                new-psdrive -Name $TempPSDrive -PSProvider Environment -Root env: | Out-null
                $NewValPath = ("$TempPSDrive" + ":\$Name")
                Remove-Item -Path $NewValPath -Force -ErrorAction Ignore | Out-null
                if ($Value -ne $Null) {
                    New-Item -Path $NewValPath -Value $Value -Force -ErrorAction Ignore | Out-null
                }
                Remove-PSDrive $TempPSDrive -Force | Out-null
            }
        }
        { 'user', 'usersession' -eq $_ }
        {
            Write-Verbose "Setting $Name --> $Value [User]"
            [System.Environment]::SetEnvironmentVariable($Name, $Value, [System.EnvironmentVariableTarget]::User)
        }
        { 'machine' -eq $_ }
        {
            Write-Verbose "Setting $Name --> $Value [Machine]"
            [System.Environment]::SetEnvironmentVariable($Name, $Value, [System.EnvironmentVariableTarget]::Machine)
        }
    }
    Publish-RegistryChanges
}




function Publish-RegistryChanges {
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
    $cmdFile = Join-Path "$PSScriptRoot" 'RefreshEnv.cmd'
    if (Test-Path $cmdFile) {
        & "$cmdFile"
    }
    Publish-RegistryChanges
}



function Update-ModulesShortcuts {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $false, ValueFromPipeline = $true, HelpMessage = "Overwrite if present", Position = 0)]
        [switch]$Test
    )
    $TestOnly = $False
    if (($PSBoundParameters.ContainsKey('WhatIf')) -or ($PSBoundParameters.ContainsKey('Test'))) {
        Write-Host '[SetEnv] ' -f DarkRed -NoNewline
        Write-Host "TEST ONLY" -f Yellow
        $TestOnly = $True
    }

    $FnDefinitions = [System.Collections.Generic.List[string]]::new()
    $AliasDefinitions = [System.Collections.Generic.List[string]]::new()
    pushd "C:\Users\$ENV:USERNAME\Documents\PowerShell\Module-Development"
    $mods = (gci . -Directory)
    foreach ($m in $mods) {
        $name = $m.Name; $shortname = $name.substring(18);
        $shortname; $fullpath = $m.FullName;
        $fullpath;
        $envval = "Mod$shortname";
        $log = 'Set-EnvironmentVariable -Name $envval -Value $fullpath -Scope "User"';
        if (-not $TestOnly) {
            Set-EnvironmentVariable -Name $envval -Value $fullpath -Scope User
            Write-Host -n -f DarkRed '[SetEnv] '
        } else {
            Write-Host -n -f Blue '[TEST] '
        };
        Write-Host -f DarkYellow $log

        $AliasDefinitions.Add("New-Alias $envval -Value `"Push-$envval`" -Description `"Push-location `$env:$envval`" -Scope Global -Force -ErrorAction Stop -Option ReadOnly,AllScope")
        $FnDefinitions.Add("function Push-$envval {  Write-Host `"Pushd => `$env:$envval`" ; Push-location `$env:$envval; }")
    }

    $ProfilePath = (Get-Item -Path "$Profile").DirectoryName
    $ProfileRepositoryPath = Join-Path $ProfilePath "Profile"
    $PrivateScriptsPath = Join-Path $ProfileRepositoryPath "private"
    $ModulesPathFunctions = Join-Path $PrivateScriptsPath "ModulesPathFunctions.ps1"
    $ModulesPathAliases = Join-Path $PrivateScriptsPath "ModulesPathAliases.ps1"

    Write-FileHeader -FileName "ModulesPathFunctions.ps1" -Description "Generated PowerShell Script with function to move in module path" | Set-Content -Path $ModulesPathFunctions -Force
    Add-Content -Path $ModulesPathFunctions -Value $FnDefinitions -Force
    Write-Host "[Update-WellKnownPath] Generated $ModulesPathFunctions"
    Write-FileHeader -FileName "ModulesPathAliases.ps1" -Description "Generated PowerShell Script with function to move in module path" | Set-Content -Path $ModulesPathAliases -Force
    Add-Content -Path $ModulesPathAliases -Value $AliasDefinitions -Force
    Write-Host "[Update-WellKnownPath] Generated $ModulesPathAliases"
}


function Get-DocumentsPath {
    [CmdletBinding(SupportsShouldProcess)]
    param()

    Write-Verbose "[Get-DocumentsPath] Method 1: Using [System.Environment]::GetFolderPath"

    $path = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::MyDocuments)
    if (Test-Path $path) {
        Write-Verbose "[Get-DocumentsPath] Method 1: found `"$path`""
        return $path
    }

    Write-Verbose "[Get-DocumentsPath] Method 2: Using $HOME environment variable"
    $path = Join-Path $HOME "Documents"
    if (Test-Path $path) {
        Write-Verbose "[Get-DocumentsPath] Method 2: found `"$path`""
        return $path
    }

    Write-Verbose "[Get-DocumentsPath] Method 3: Using Shell.SpecialFolder via COM Object"
    try {
        $shell = New-Object -ComObject Shell.Application
        $path = $shell.Namespace(16).Self.Path # 16 corresponds to MyDocuments
        if (Test-Path $path) {
            Write-Verbose "[Get-DocumentsPath] Method 3: found `"$path`""
            return $path
        }
    } catch {
        # Handle COM failure gracefully
    }

    Write-Verbose "[Get-DocumentsPath] Method 4: Using [Environment]::ExpandEnvironmentVariables"
    $path = [Environment]::ExpandEnvironmentVariables("%USERPROFILE%\Documents")
    if (Test-Path $path) {
        Write-Verbose "[Get-DocumentsPath] Method 4: found `"$path`""
        return $path
    }

    # If all methods fail
    #throw "Unable to determine the Documents path."
    return $Null
}


function Get-CustomPathValues {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    $DocumentsPath = Get-DocumentsPath
    $CustomPaths = [ordered]@{}
    $CustomPaths.Add("MyDocuments", "$DocumentsPath")
    $CustomPaths.Add("DejaToolsRootDirectory", "D:\Dev\DejaInsight")
    $CustomPaths.Add("DevelopmentRoot", "D:\Dev")
    $CustomPaths.Add("ScriptsRoot", "D:\Scripts")
    $CustomPaths.Add("ToolsRoot", "D:\Programs\SystemTools")
    $CustomPaths.Add("wwwroot", "D:\www")
    $CustomPaths.Add("wwwroot2", "W:\")
    $CustomPaths.Add("siteroot", "W:\arsscriptum.github.io")
    $CustomPaths.Add("RedditSupport", "D:\Scripts\PowerShell.RedditSupport")
    $CustomPaths.Add("moddev", "C:\Users\$ENV:USERNAME\Documents\PowerShell\Module-Development")
    $CustomPaths.Add("MyCode", "D:\Code")
    $CustomPaths.Add("ProfilePath", "C:\Users\$ENV:USERNAME\Documents\PowerShell\Profile")
    $CustomPaths.Add("Sandbox", "D:\Code\Sandbox")
    $CustomPaths.Add("PowerShellSandbox", "D:\Tmp\Sandbox\WindowsSandbox")
    $CustomPaths.Add("ScriptsSandbox", "D:\Tmp\Sandbox\WindowsSandbox")
    $CustomPaths.Add("CodeSandbox", "D:\Tmp\Sandbox\WindowsSandbox")
    $CustomPaths.Add("WinSandbox", "D:\Tmp\Sandbox\WindowsSandbox")
    $CustomPaths.Add("CodeTemplates", "D:\Code\TEMPLATES")
    $CustomPaths.Add("Templates", "D:\Code\TEMPLATES")
    return $CustomPaths

}




function Update-WellKnownPaths {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $false)]
        [switch]$NoProgress
    )
    try {
        $FnDefinitions = [System.Collections.Generic.List[string]]::new()
        $AliasDefinitions = [System.Collections.Generic.List[string]]::new()
        $CustomPaths = Get-CustomPathValues
        $CustomPaths.GetEnumerator() | % {
            $VarName = $($_.Name);
            $VarPath = $($_.Value);
            Write-Host "[Update-WellKnownPath] name: $VarName path: $VarPath"
            Set-EnvironmentVariable -Name $VarName -Value $VarPath -Scope 'UserSession' | Out-Null

            $AliasName = $VarName.ToLower().Replace("templates", "tpl").Replace("root", "").Replace("sandbox", "sb").Replace("directory", "").Replace("development", "dev").Replace("my", "").Replace("powershell", "ps")
            $AliasDefinitions.Add("New-Alias $AliasName -Value `"Push-$VarName`" -Description `"Push-location `$env:$VarName`" -Scope Global -Force -ErrorAction Stop -Option ReadOnly,AllScope")
            $FnDefinitions.Add("function Push-$VarName {  Write-Host `"Pushd => `$env:$VarName`" ; Push-location `$env:$VarName; }")
        }

        $ProfilePath = (Get-Item -Path "$Profile").DirectoryName
        $ProfileRepositoryPath = Join-Path $ProfilePath "Profile"
        $PrivateScriptsPath = Join-Path $ProfileRepositoryPath "private"
        $CustomPathFunctions = Join-Path $PrivateScriptsPath "CustomPathFunctions.ps1"
        $CustomPathAliases = Join-Path $PrivateScriptsPath "CustomPathAliases.ps1"

        Write-FileHeader -FileName "CustomPathFunctions.ps1" -Description "Generated PowerShell Script with function to move in custom path" | Set-Content -Path $CustomPathFunctions -Force
        Add-Content -Path $CustomPathFunctions -Value $FnDefinitions -Force
        Write-Host "[Update-WellKnownPath] Generated $CustomPathFunctions"
        Write-FileHeader -FileName "CustomPathAliases.ps1" -Description "Generated PowerShell Script with function to move in custom path" | Set-Content -Path $CustomPathAliases -Force
        Add-Content -Path $CustomPathAliases -Value $AliasDefinitions -Force
        Write-Host "[Update-WellKnownPath] Generated $CustomPathAliases"
    } catch {
        Write-Error "$_"
    }
}

