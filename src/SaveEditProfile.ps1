#╔════════════════════════════════════════════════════════════════════════════════╗
#║                                                                                ║
#║   SaveEditProfile.ps1                                                          ║
#║                                                                                ║
#╟────────────────────────────────────────────────────────────────────────────────╢
#║   Guillaume Plante <codegp@icloud.com>                                         ║
#║   Code licensed under the GNU GPL v3.0. See the LICENSE file for details.      ║
#╚════════════════════════════════════════════════════════════════════════════════╝


function Get-GitExecutablePath {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    $GitPath = (get-command "git.exe" -ErrorAction Ignore).Source

    if (($GitPath -ne $null) -and (Test-Path -Path $GitPath)) {
        return $GitPath
    }
    $GitPath = (Get-ItemProperty -Path "HKLM:\SOFTWARE\GitForWindows" -Name 'InstallPath' -ErrorAction Ignore).InstallPath
    if ($GitPath -ne $null) { $GitPath = $GitPath + '\bin\git.exe' }
    if (Test-Path -Path $GitPath) {
        return $GitPath
    }
    $GitPath = (Get-ItemProperty -Path "$ENV:OrganizationHKCU\Git" -Name 'InstallPath' -ErrorAction Ignore).InstallPath
    if ($GitPath -ne $null) { $GitPath = $GitPath + '\bin\git.exe' }
    if (($GitPath -ne $null) -and (Test-Path -Path $GitPath)) {
        return $GitPath
    }
}

function Save-Profile {

    $ProfileFileName = (Get-Item "$Profile").Name
    $ProfileFileFullPath = (Get-Item "$Profile").FullName
    $ProfilePath = (Get-Item -Path "$Profile").DirectoryName
    $ProfileRepositoryPath = Join-Path $ProfilePath "Profile"
    $SavedProfileFilePath = Join-Path $ProfileRepositoryPath "$ProfileFileName"

    Write-Host "[Save-Profile] Copying profile file in profile repository"
    Copy-Item "$ProfileFileFullPath" "$SavedProfileFilePath" -Verbose -Force

    $Msg = 'Latest Profile, commited on ' + (Get-Date).GetDateTimeFormats()[6]
    $GitExe = Get-GitExecutablePath

    Write-Host "Go in $ProfileRepositoryPath"
    pushd "$ProfileRepositoryPath"

    & "$GitExe" add *
    & "$GitExe" commit -a -m "$Msg"
    & "$GitExe" push

    popd
}


function Edit-Profile {
    [CmdletBinding(SupportsShouldProcess)]
    param
    (
        [Parameter(Mandatory = $false)]
        [Alias('a')]
        [switch]$EditDependencies

    )
    Write-Host "EDITING PROFILE ==> $Profile" -f Blue
    Write-Host "Use 'Save-Profile' to copy to the profile repository path and save" -f DarkYellow
    Write-Host "use the -EditDependencies options to edit dependencies" -f DarkYellow
    Invoke-Sublime $Profile
    if ($EditDependencies -eq $True) {
        $Directory = (Get-Item -Path $Profile).DirectoryName
        $Directory = Join-Path $Directory 'inc'
        $Dependencies = (gci $Directory -File -Filter '*.ps1').FullName
        foreach ($Dep in $Dependencies) {
            Write-Host "EDITING DEPEMDENCY ==> $Dep" -f Cyan
            Invoke-Notepad $Dep
        }
    }

}



function Reload-Profile {
    $Path = (Get-Item $Profile).DirectoryName
    $aliases = (Get-AliasList $Path).Name
    foreach ($a in $aliases) {
        Remove-Alias $a -Force -ErrorAction ignore
    }
    . "$Profile"
}

function Sync-Profile {
    $PwshCoreProfile = $Profile
    $WindPwshProfile = Get-Variable -Name WindowsPwshProfile -ValueOnly -Scope Global -ErrorAction Ignore
    if ($WindPwshProfile -eq $null) {
        $WindPwshProfile = "C:\Users\$ENV:USERNAME\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
        Set-Variable -Name WindowsPwshProfile -Value $WindPwshProfile -Scope Global -Option allscope, readonly -ErrorAction Ignore
    }

    $PwshCoreProfileLastUpdate = (Get-Item $PwshCoreProfile).LastWriteTime
    $WindPwshProfileLastUpdate = (Get-Item $WindPwshProfile).LastWriteTime
    $Profiles = @{}
    $LatestDate = $null
    $LatestFile = ''
    $OlderFile = ''
    $Profiles.Add($PwshCoreProfileLastUpdate, $PwshCoreProfile)
    $Profiles.Add($WindPwshProfileLastUpdate, $WindPwshProfile)
    $Profiles.Keys | ForEach-Object {
        if (($_ -ne $null) -and (($LatestDate -eq $null) -or ($_ -gt $LatestDate))) {
            $LatestDate = $_
            $LatestFile = $Profiles[$_]
        }
    }
    Write-Host "===============================================================================" -f DarkRed
    Write-Host "POWERSHELL PROFILE SYNCHRONIZATION" -f DarkYellow;
    Write-Host "===============================================================================" -f DarkRed
    Write-Host ("Most Recent`t") -NoNewline -ForegroundColor DarkYellow

    if ($LatestFile -eq $PwshCoreProfile) {
        $Diff = $LatestDate - $WindPwshProfileLastUpdate
        Write-Host ("ᶜᵒʳᵉ⁷`t`t+ $Diff") -ForegroundColor DarkCyan
        Write-Host ("copying ᶜᵒʳᵉ⁷ => ˡᵉᵍᵃᶜʸ⁵") -ForegroundColor DarkCyan
        $OlderFile = $WindPwshProfile

    } else {
        $Diff = $LatestDate - $PwshCoreProfileLastUpdate
        Write-Host ("ˡᵉᵍᵃᶜʸ⁵`t`t+ $Diff") -ForegroundColor DarkCyan
        Write-Host ("copying ˡᵉᵍᵃᶜʸ⁵ => ᶜᵒʳᵉ⁷ ") -ForegroundColor DarkCyan
        $OlderFile = $PwshCoreProfile
    }

    $OlderFileBAK = $OlderFile + '.BAK'
    Copy-Item $OlderFile $OlderFileBAK
    Copy-Item $LatestFile $OlderFile

    Write-Host "[$OlderFile] backup==> $OlderFileBAK" -f Darkgray;
    Write-Host "[$LatestFile] copy==> $OlderFile" -f Darkgray;
}

