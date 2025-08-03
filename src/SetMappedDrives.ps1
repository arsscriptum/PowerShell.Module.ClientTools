#╔════════════════════════════════════════════════════════════════════════════════╗
#║                                                                                ║
#║   SetMappedDrives.ps1                                                          ║
#║                                                                                ║
#╟────────────────────────────────────────────────────────────────────────────────╢
#║   Guillaume Plante <codegp@icloud.com>                                         ║
#║   Code licensed under the GNU GPL v3.0. See the LICENSE file for details.      ║
#╚════════════════════════════════════════════════════════════════════════════════╝


[hashtable]$Script:NetworkDrivesMap = [ordered]@{
    "H" = "\\10.0.0.111\mini-myhome";
    "K" = "\\10.0.0.111\mini-scripts";
    "G" = "\\10.0.0.111\mini-dev";
    "W" = "\\10.0.0.111\mini-www";
    "P" = "\\10.0.0.111\mini-backup";
    "U" = "\\10.0.0.111\mini-datassd";
    "S" = "\\10.0.0.111\mini-external";
    "T" = "\\10.0.0.111\mini-ffox";
    "Q" = "\\10.0.0.111\mini-qbittorrentvpn";
    "Z" = "\\10.0.0.111\mini-services";
}






function Test-AreNetworkDrivesMapped {
    [CmdletBinding(SupportsShouldProcess)]
    param()


    try {


        $AllMapped = $True
        foreach ($Key in $Script:NetworkDrivesMap.Keys) {
            $drv = Get-PSDrive -Name $Key -ErrorAction Ignore
            if (!($drv)) {
                Write-Verbose "$Key not mapped"
                $AllMapped = $False
            }
        }
        return $AllMapped

    } catch {
        Write-Error "$_"
    }

}


function Register-NetworkDrive {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Position = 0, Mandatory = $true)]
        [ValidateSet('A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z')]
        [string]$Name,
        [Parameter(Position = 1, Mandatory = $true)]
        [string]$ServerPath,
        [Parameter(Position = 2, Mandatory = $true)]
        [pscredential]$Credentials
    )
    begin {
        [string]$DriveLetter = "{0}:\" -f $Name
    }
    process {
        try {
            Write-Verbose "[Register-NetworkDrive] Get-PSDrive -Name `"$Name`""
            $Temp = Get-PSDrive -Name $Name -ErrorAction Ignore
            if ($Temp -ne $Null) { throw "Drive Already Mapped: `"$Name`"" }
            Write-Verbose "[Register-NetworkDrive] New-PSDrive -Name `"$Name`""
            $u = $Credentials.UserName
            $p = $Credentials.GetNetworkCredential().Password
            Write-Host "[Register-NetworkDrive] " -f DarkCyan -n

            Write-Host "Please wait while mapping drive `"$Name`" ( $DriveLetter ) to $ServerPath... Creds [$u`:$p]" -f White
            $Res = New-PSDrive -Name $Name -Root "$ServerPath" -PSProvider "FileSystem" -Credential $Credentials -Scope Global -Persist -ErrorAction Stop
            Start-Sleep -Milliseconds 500
            Write-Verbose "[Register-NetworkDrive] Push-Location Test `"$DriveLetter`""
            Push-Location $DriveLetter -ErrorAction Stop
            Pop-Location
        } catch {
            Write-Host "[Register-NetworkDrive] ERROR: " -f DarkRed -n
            Write-Host "$_" -f DarkYellow
        }
    }
}


function Unregister-NetworkDrive {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Position = 0, Mandatory = $true)]
        [ValidateSet('A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z')]
        [string]$Name
    )
    begin {
        [string]$DriveLetter = "{0}:\" -f $Name
    }
    process {
        try {
            Write-Verbose "[Unregister-NetworkDrive] Push-Location Test `"$DriveLetter`""
            Push-Location $DriveLetter -ErrorAction Ignore
            Pop-Location
            Write-Verbose "[Unregister-NetworkDrive] Get-PSDrive -Name `"$Name`""
            $Temp = Get-PSDrive -Name $Name -ErrorAction Ignore
            if ($Temp -eq $Null) { throw "Drive Not Mapped: `"$Name`"" }
            Write-Host "[Unregister-NetworkDrive] " -f DarkBlue -n
            Write-Host "Remove-PSDrive -Name `"$Name`""
            $Temp | Remove-PSDrive -Force -ErrorAction Ignore
        } catch {
            Write-Host "[Unregister-NetworkDrive] ERROR: " -f DarkRed -n
            Write-Host "$_" -f DarkYellow
        }
    }
}

function Test-TemporaryDriveExist {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Position = 0, Mandatory = $true)]
        [ValidateSet('A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z')]
        [string]$Name
    )
    begin {
        [string]$DriveLetter = "{0}:\" -f $Name
    }
    process {
        try {
            [Boolean]$RetVal = $True
            try {
                $Temp = Get-PSDrive -Name $Name -ErrorAction Stop
                if ($Temp -eq $Null) { throw "null" }
            } catch {
                $RetVal = $False
            }

            return $RetVal

        } catch {

        }
    }
}




function Register-NetworkDrivesMapping {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $False)]
        [switch]$Quiet,
        [Parameter(Mandatory = $False)]
        [switch]$Test
    )

    [Boolean]$ShouldPrint = !$Quiet
    [Boolean]$ShouldDoIt = !$Test

    function CustomLog ([string]$LogMsg) {
        if ($ShouldPrint) {
            Write-Host "[Set-MappedDrive] " -n -f DarkYellow
            Write-Host "$LogMsg"
        } else {
            Write-Verbose "$LogMsg"
        }
    }

    try {

        [string]$userName = 'gp'
        [string]$userPassword = 'secret'

        # Convert to SecureString
        [securestring]$secStringPassword = ConvertTo-SecureString $userPassword -AsPlainText -Force
        [pscredential]$credObject = New-Object System.Management.Automation.PSCredential ($userName, $secStringPassword)

        CustomLog ("Mapping $Num Drives...`n`n")
        [bool]$DoSleep = $True

        foreach ($Key in $Script:NetworkDrivesMap.Keys) {
            if ($ShouldPrint) {
                Write-Host "[Set-MappedDrive] " -n -f DarkCyan
                Write-Host "$Key"
            }

            if ($ShouldDoIt) {
                try {
                    if (!(Test-TemporaryDriveExist -Name $Key)) {
                        Register-NetworkDrive -Name $Key -ServerPath "$($Script:NetworkDrivesMap[$Key])" -Credentials $credObject
                        $DoSleep = $True
                    } else {
                        Write-Host "[Set-MappedDrive] " -n -f DarkRed
                        Write-Host "Already registered" -f DarkYellow
                        $DoSleep = $False
                    }


                } catch {
                    Write-Warning "Error on registration of drive $Key $_"
                }
            }

            if ($DoSleep) {
                Start-Sleep 1
            }

        }


    } catch {
        Write-Error "$_"
    }

}


function Unregister-NetworkDrivesMapping {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $False)]
        [switch]$Quiet,
        [Parameter(Mandatory = $False)]
        [switch]$Test
    )

    [Boolean]$ShouldPrint = !$Quiet
    [Boolean]$ShouldDoIt = !$Test

    function CustomLog ([string]$LogMsg) {
        if ($ShouldPrint) {
            Write-Host "[Set-MappedDrive] " -n -f Blue
            Write-Host "$LogMsg"
        } else {
            Write-Verbose "$LogMsg"
        }
    }

    try {


        CustomLog ("Unmapping $Num Drives...")

        foreach ($Key in $Script:NetworkDrivesMap.Keys) {
            if ($ShouldPrint) {
                Write-Host "[Set-MappedDrive] " -n -f Magenta
                Write-Host "$Key"
            } else {
                Write-Verbose "Mapping $Key -> $($Script:NetworkDrivesMap[$Key])"
            }

            if ($ShouldDoIt) {
                Unregister-NetworkDrive -Name $Key
            } else {
                Write-Warning "Would call Unregister-NetworkDrive -Name $Key"
            }

            Start-Sleep 1
        }

    } catch {
        Write-Error "$_"
    }

}




function Invoke-RemapDrives {
    [CmdletBinding(SupportsShouldProcess)]
    param()

    try {
        # Clear all mapped drives
        Write-Host "Removing all existing mapped drives..." -ForegroundColor Yellow



        # List of drives to map
        $drives = @(
            @{ Letter = "H:"; Path = "\\10.0.0.111\mini-myhome" },
            @{ Letter = "K:"; Path = "\\10.0.0.111\mini-scripts" },
            @{ Letter = "G:"; Path = "\\10.0.0.111\mini-dev" },
            @{ Letter = "W:"; Path = "\\10.0.0.111\mini-www" },
            @{ Letter = "P:"; Path = "\\10.0.0.111\mini-backup" },
            @{ Letter = "U:"; Path = "\\10.0.0.111\mini-datassd" },
            @{ Letter = "S:"; Path = "\\10.0.0.111\mini-external" },
            @{ Letter = "T:"; Path = "\\10.0.0.111\mini-ffox" },
            @{ Letter = "Q:"; Path = "\\10.0.0.111\mini-qbittorrentvpn" }
            @{ Letter = "Z:"; Path = "\\10.0.0.111\mini-services" }
        )
        $NetExe = (Get-Command "net.exe").Source
        $Credz = Get-AppCredentials -Id "mini.samba.shares"
        $SmbUser = $Credz.UserName
        $SmbPasswd = $Credz.GetNetworkCredential().Password
        $UserOpt = '/USER:{0}' -f $SmbUser
        $PersistOpt = "/persistent:yes"


        Write-Host "Remove All Drives..." -f Red
        & "$NetExe" "use" "*" "/delete" "/yes"
        Write-Host "Wait for a moment to ensure drives are removed" -f DarkCyan
        Start-Sleep -Seconds 2

        Write-Host "Remap All Drives. SmbUser $SmbUser SmbPasswd $SmbPasswd"
        # Remap all drives
        foreach ($drive in $drives) {
            $letter = $drive.Letter
            $path = $drive.Path

            Write-Host "Mapping $letter to $path..." -ForegroundColor Green
            Write-Host "`"$NetExe`" `"use`" `"$letter`" `"$path`" `"$PersistOpt`" `"$UserOpt`" `"$SmbPasswd`""
            & "$NetExe" "use" "$letter" "$path" "$PersistOpt" "$UserOpt" "$SmbPasswd"
        }

        # Confirm the remapped drives
        Write-Host "`nRemapping completed. Here are the current mapped drives:" -ForegroundColor Cyan
        & "$NetExe" "use"


    } catch {
        Write-Error "$_"
    }

}


