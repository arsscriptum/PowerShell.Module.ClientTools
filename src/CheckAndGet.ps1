
#╔════════════════════════════════════════════════════════════════════════════════╗
#║                                                                                ║
#║   History.ps1                                                                  ║
#║   ps history search                                                            ║
#║                                                                                ║
#╟────────────────────────────────────────────────────────────────────────────────╢
#║   Guillaume Plante <codegp@icloud.com>                                         ║
#║   Code licensed under the GNU GPL v3.0. See the LICENSE file for details.      ║
#╚════════════════════════════════════════════════════════════════════════════════╝



function Invoke-GetVersionString {

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $true, position = 0)]
        [string]$Url,
        [Parameter(Mandatory = $false, position = 1)]
        [ValidateSet("curl", "wget", "rest", "web")]
        [string]$Mode = "curl"
    )
    try {

        $QueryStr = "nocache=$(Get-Random)"
        # Create UriCreationOptions instance
        $options = [System.UriCreationOptions]::new()
        $options.DangerousDisablePathAndQueryCanonicalization = $true

        [uri]$RequestUri = [System.Uri]::new($Url)

        [string]$NewUri = $Url
        if ([string]::IsNullOrEmpty($RequestUri.Query)) {
            $NewUri = $RequestUri.AbsoluteUri + '?' + $QueryStr
        } else {
            $NewUri = $RequestUri.AbsoluteUri + '&' + $QueryStr
        }
        [uri]$RequestUri = [System.Uri]::new($RequestUri.AbsoluteUri, [ref]$options)

        $headers = @{
            "Cache-Control" = "no-cache"
            "Pragma" = "no-cache"
            "Expires" = "0"
        }
        [regex]$pattern_version = [regex]::new('(?<fullver>(?<major>\d+)+\.(?<minor>\d+)+\.(?<build>\d+))',[System.Text.RegularExpressions.RegexOptions]::Singleline)
        [string]$LatestVersionUrl = $NewUri

        Write-Verbose "LatestVersionUrl $LatestVersionUrl"
        $ExtCmdExe = ''
        [string]$VersionObj = [version]::new()
        switch ($Mode) {
            "curl" {
                try {
                    $ExtCmd = get-command 'curl.exe' -ErrorAction Stop
                } catch {
                    choco install curl -y -f | Out-Null
                    $ExtCmd = get-command 'curl.exe' -ErrorAction Stop
                }
                $ExtCmdExe = $ExtCmd.Source


                [string]$tmpVersionValue = & "$ExtCmdExe" "$LatestVersionUrl" '-s' "-H" "Cache-Control: no-cache" '-H' "Pragma: no-cache" '-H' "Expires: 0"
                [System.Text.RegularExpressions.MatchCollection]$MatchObj = $pattern_version.Matches($tmpVersionValue)

                if ($MatchObj.Success) {
                    $VersionObj = [version]::new($MatchObj.Value)
                    Write-Verbose "Latest version with `"$ExtCmdExe`" $($VersionObj.ToString())"
                }
                break
            }
            "wget" {
                try {
                    $ExtCmd = get-command 'wget.exe' -ErrorAction Stop
                } catch {
                    choco install curl -y -f | Out-Null
                    $ExtCmd = get-command 'wget.exe' -ErrorAction Stop
                }
                $ExtCmdExe = $ExtCmd.Source
                [string]$tmpVersionValue = & "$ExtCmdExe" '-qO' '-' "$LatestVersionUrl"
                [System.Text.RegularExpressions.MatchCollection]$MatchObj = $pattern_version.Matches($tmpVersionValue)
                if ($MatchObj.Success) {
                    $VersionObj = [version]::new($MatchObj.Value)
                    Write-Verbose "Latest version with `"$ExtCmdExe`" $($VersionObj.ToString())"
                }
                break
            }
            "web" {
                try {
                    $Req = Invoke-WebRequest  -Uri $LatestVersionUrl -MaximumRedirection 0 -ErrorVariable ErrVal -ErrorAction Stop -Headers $headers -UseBasicParsing
                    if($Req.StatusCode -ne 200){ throw $_ }
                    [System.Text.RegularExpressions.MatchCollection]$MatchObj = $pattern_version.Matches($Req.Content)
                    if ($MatchObj.Success) {
                        $VersionObj = [version]::new($MatchObj.Value)
                        Write-Verbose "Latest version with `"Invoke-WebRequest`" $($VersionObj.ToString())"
                    }
                    
                } catch {
                    if ($ErrVal.Message.Contains('302 (Found)')) {
                        [string]$tmpVersionValue = (Invoke-WebRequest -UseBasicParsing -Uri $LatestVersionUrl -MaximumRedirection 2 -ErrorAction Stop -Headers $headers | Select -ExpandProperty Content)
                        [System.Text.RegularExpressions.MatchCollection]$MatchObj = $pattern_version.Matches($tmpVersionValue)
                        if ($MatchObj.Success) {
                            $VersionObj = [version]::new($MatchObj.Value)
                            Write-Verbose "Latest version with `"Invoke-WebRequest`" $($VersionObj.ToString())"
                        }
                    }else{
                        throw $_
                    }
                }
                break
            }
            "rest" {
                try {
                    [string]$tmpVersionValue = Invoke-RestMethod -Uri "$LatestVersionUrl" -Headers $headers
                    [System.Text.RegularExpressions.MatchCollection]$MatchObj = $pattern_version.Matches($tmpVersionValue)
                    if ($MatchObj.Success) {
                        $VersionObj = [version]::new($MatchObj.Value)
                        Write-Verbose "Latest version with `"$ExtCmdExe`" $($VersionObj.ToString())"
                    }else{
                        throw $_
                    }
                } catch {
                    throw $_
                }
                break

            }

            default {
                Write-Error "Unknown mode: $Mode"
            }
        }

        $VersionString = "$($VersionObj.ToString())"
        $VersionString

    } catch {
        Show-ExceptionDetails $_ -ShowStack
    }

}

function Get-LocalCurrentVersionString {

    [CmdletBinding(SupportsShouldProcess)]
    param()

    process {
        try {
            $RegPath = "$ENV:OrganizationHKCU\winagent"
            $RegValueName = 'CurrentVersion'

            $CurrentVersionString = Get-RegistryValue -Path $RegPath -Name $RegValueName
            if([string]::IsNullOrEmpty($CurrentVersionString)){
                return "0.0.1"
            }
            $CurrentVersionString

        } catch {
            Write-Error "$_"
        }
    }
}


function Test-LatestVersion {

    [CmdletBinding(SupportsShouldProcess)]
    param()

    process {
        try {

            $CurrentVersionString = Get-LocalCurrentVersionString
            $LatestVersionString = Get-LatestVersionString

            [version]$CurrentVersion = $CurrentVersionString
            [version]$LatestVersion = $LatestVersionString

            Write-Host "[Test-LatestVersion] Current $CurrentVersionString"
            Write-Host "[Test-LatestVersion] Latest $LatestVersionString"

            [bool]$IsNewVersionReady = ($LatestVersion -gt $CurrentVersionString)
            Write-Host "[Test-LatestVersion] IsNewVersionReady $IsNewVersionReady"
            return $IsNewVersionReady

        } catch {
            Write-Error "$_"
        }
    }
}


function Get-OnlineVersionIRestM {

    [CmdletBinding(SupportsShouldProcess)]
    param()

    process {
        try {
            [string]$LatestVersionUrl = "https://raw.githubusercontent.com/arsscriptum/winclient-psprofile/refs/heads/master/version.nfo"
            [version]$ver = Invoke-GetVersionString $LatestVersionUrl "rest"
            Write-Verbose "$($ver.ToString())"

            $ver.ToString()
        } catch {
            Write-Error "$_"
        }
    }
}
function Get-OnlineVersionCurl {

    [CmdletBinding(SupportsShouldProcess)]
    param()

    process {
        try {
           [string]$LatestVersionUrl = "https://raw.githubusercontent.com/arsscriptum/winclient-psprofile/refs/heads/master/version.nfo"
            [version]$ver = Invoke-GetVersionString $LatestVersionUrl "curl"
            Write-Verbose "$($ver.ToString())"

            $ver.ToString()
        } catch {
            Write-Error "$_"
        }
    }
}

function Get-OnlineVersionWGet {

    [CmdletBinding(SupportsShouldProcess)]
    param()

    process {
        try {
            [string]$LatestVersionUrl = "https://raw.githubusercontent.com/arsscriptum/winclient-psprofile/refs/heads/master/version.nfo"
            [version]$ver = Invoke-GetVersionString $LatestVersionUrl "wget"
            Write-Verbose "$($ver.ToString())"

            $ver.ToString()
        } catch {
            Write-Error "$_"
        }
    }
}

function Get-OnlineVersionIWebR {

    [CmdletBinding(SupportsShouldProcess)]
    param()

    process {
        try {
            [string]$LatestVersionUrl = "https://github.com/arsscriptum/winclient-psprofile/raw/refs/heads/master/version.nfo"
            [version]$ver1 = Invoke-GetVersionString $LatestVersionUrl "web"

            [string]$LatestVersionUrl = "https://raw.githubusercontent.com/arsscriptum/winclient-psprofile/refs/heads/master/version.nfo"
            [version]$ver2 = Invoke-GetVersionString $LatestVersionUrl "web"

            [version]$ver = if($ver2 -gt $ver1){$ver2}else{$ver1}

            Write-Verbose "$($ver.ToString())"

            $ver.ToString()
            
        } catch {
            Write-Error "$_"
        }
    }
}

function Update-LocalVersionValue {

    [CmdletBinding(SupportsShouldProcess)]
    param()

    process {
        try {
            $RegPath = "$ENV:OrganizationHKCU\winagent"
            $RegValueName = 'CurrentVersion'
            $NewVersionString = Get-LatestVersionString

            Write-Host "New Version is set to $NewVersionString"
            Set-RegistryValue -Path $RegPath -Name $RegValueName -Value "$NewVersionString"

        } catch {
            Write-Error "$_"
        }
    }
}

function Get-LatestScriptsVersion {

    [CmdletBinding(SupportsShouldProcess)]
    param()

    process {
        try {
            $RegPath = "$ENV:OrganizationHKCU\winagent"
            $RegValueName = 'CurrentVersion'
            $Url = "https://github.com/arsscriptum/winclient-psprofile/archive/refs/heads/master.zip"
            $TempPath = "$ENV:Temp\winclient-psprofile"
            $TempFilePath = "$ENV:Temp\winclient-psprofile\master.zip"
            Remove-Item -Path $TempPath -Recurse -Force -ErrorAction Ignore | Out-Null
            New-Item -Path $TempPath -ItemType Directory -Force -ErrorAction Ignore | Out-Null

            $Res = Invoke-WebRequest -UseBasicParsing -Uri "$Url" -SkipCertificateCheck -OutFile "$TempFilePath" -Passthru
            if ($Res.StatusCode -ne 200) {
                throw "failure when downloading file"
            }

            expand-Archive "$TempFilePath" -DestinationPath "$TempPath"

            $TmpRootPath = Join-Path "$TempPath" "winclient-psprofile-master"
            
            try {
                $DataPath = Join-Path "$TmpRootPath" "data"
                Write-Host "$DataPath" -f DarkYellow
                Start-DecodeFiles $DataPath

                
                Update-LocalVersionValue
            } catch {
                Write-Host "[ERROR] " -f DarkRed
                Write-Host "Error while decoding files! $_" -f DarkYellow
                Start-Sleep 3
                throw $_
            }



        } catch {
            throw $_
        }
    }
}



function Get-LatestVersionString {

    [CmdletBinding(SupportsShouldProcess)]
    param()

    process {
        try {
            [version]$ltmpVer1 = Get-OnlineVersionIWebR
            [version]$ltmpVer2 = Get-OnlineVersionIRestM
            [version]$lVer1 = if ($ltmpVer1 -gt $ltmpVer2) { $ltmpVer1 } else { $ltmpVer2 }

            [version]$ltmpVer1 = Get-OnlineVersionCurl
            [version]$ltmpVer2 = Get-OnlineVersionWGet
            [version]$lVer2 = if ($ltmpVer1 -gt $ltmpVer2) { $ltmpVer1 } else { $ltmpVer2 }

            [version]$LatestVersion = if ($lVer1 -gt $lVer2) { $lVer1 } else { $lVer2 }

            $LatestVersion.ToString()
        } catch {
            Write-Error "$_"
        }
    }
}


function Update-LocalVersionValue {

    [CmdletBinding(SupportsShouldProcess)]
    param()

    process {
        try {
            $RegPath = "$ENV:OrganizationHKCU\winagent"
            $RegValueName = 'CurrentVersion'
            $NewVersionString = Get-LatestVersionString

            Write-Host "New Version is set to $NewVersionString"
            Set-RegistryValue -Path $RegPath -Name $RegValueName -Value "$NewVersionString"

        } catch {
            Write-Error "$_"
        }
    }
}

function Invoke-ValidateScriptsVersion {

    [CmdletBinding(SupportsShouldProcess)]
    param()

    process {
        $ReloadProfile = $False
        try {
            if (Test-LatestVersion) {
                try{
                  Get-LatestScriptsVersion
                  update-loginScripts
                  $path = "$ENV:LoginScripts\Microsoft.PowerShell_profile.ps1"
                  if(Test-Path "$path"){
                    Move-Item "$path" "$Profile"
                  }
                  Remove-Item "$path" -Force | Out-Null
                  $ReloadProfile = $True
                }catch{
                  $ReloadProfile = $False
                }
            }

        } catch {
            Write-Error "$_"
        }

        if($ReloadProfile){
            . "$PROFILE"
        }
    }
}

set-alias -Name DoScriptsCheck -Value 'Invoke-ValidateScriptsVersion' -Option AllScope -Force -ErrorAction Ignore
