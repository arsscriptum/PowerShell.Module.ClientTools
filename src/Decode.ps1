

function Invoke-AutoUpdateProgress_FileUtils {
    [int32]$PercentComplete = (($Script:StepNumber / $Script:TotalSteps) * 100)
    if ($PercentComplete -gt 100) { $PercentComplete = 100 }
    Write-Progress -Activity $Script:ProgressTitle -Status $Script:ProgressMessage -PercentComplete $PercentComplete
    if ($Script:StepNumber -lt $Script:TotalSteps) { $Script:StepNumber++ }
}

function Get-ScriptEncodeAppCredentials {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    $ErrorOccured = $false

    try {
        $cmd = Get-Command 'Get-AppCredentials' -ErrorAction Stop
        $Data = & $cmd -Id 'scripts-encode'
        if ($Data -eq $Null) {
           Write-Warning "You are missing the scripts-encode App Credentials registration..."
        }  
        return $Data
    }catch {
        Write-Warning "You are missing the function Get-AppCredentials load the Core module..."
        $ErrorOccured = $true
    }

    return $Null
}


function Invoke-CombineSplitFiles {

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        [int]$TotalSize,
        [Parameter(Mandatory = $false)]
        [string]$OutFilePath
    )
    $SyncStopWatch = [System.Diagnostics.Stopwatch]::StartNew()
    $Script:ProgressTitle = "Combine Split Files"
    $TotalTicks = 0
    $Basename = ''
    Write-Verbose "Path is $Path"
    $Files = (gci $Path -File).Name
    foreach ($f in $Files) {
        if ($f.Contains('01.cpp')) {
            $Basename = $f.TrimEnd('01.cpp')

        }
    }
    Write-Verbose "Basename is $Basename"
    $Files = (gci $Path -File).FullName
    $FilesCount = $Files.Count
    $Path = $Path.TrimEnd('\')
    $Position = 0
    $Script:StepNumber = 1
    $Script:TotalSteps = $Files.Count
    [byte[]]$NewOutArray = [byte[]]::new($TotalSize)
    Write-Verbose " + CREATING $OutFilePath"
    for ($x = 1; $x -le $FilesCount; $x++) {
        $DataFileName = "{0}\{1}{2,2:00}{3}" -f ($Path, $Basename, $x, '.cpp')
        Write-Verbose "Working on $DataFileName"
        if (-not (Test-Path -Path "$DataFileName")) {
            Write-Verbose "ERROR NO SUCH FILE $DataFileName"
            continue;
        }
        $ReadBytes = get-content -LiteralPath $DataFileName
        $ReadBytesCount = $ReadBytes.Length
        Write-Verbose "ReadBytesCount $ReadBytesCount"
        [byte[]]$outArray = [convert]::FromBase64String($ReadBytes);
        $outArraySize = $outArray.Length
        Write-Verbose "   >>> WRITING $outArraySize bytes (pos $Position)"
        $outArray.CopyTo($NewOutArray, $Position)
        $Position += $outArraySize
        [timespan]$ts = $SyncStopWatch.Elapsed
        $TotalTicks += $ts.Ticks
        $Script:ProgressMessage = "Combine {0} of {1} files" -f $Script:StepNumber, $Script:TotalSteps
        Invoke-AutoUpdateProgress_FileUtils
        $Script:StepNumber++
    }


    [io.file]::WriteAllBytes($OutFilePath, $NewOutArray)
    Write-Host "Wrote All Bytes to $OutFilePath"
}





function Merge-DataFile {

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$DataPath,
        [Parameter(Position = 1, Mandatory = $true)]
        [string]$DestinationPath
    )

    begin {
        if (Test-Path -Path "$DestinationPath" -PathType Leaf) {
            throw "file `"$DestinationPath`" exists"
        }
        $Null = New-Item -Path "$DestinationPath" -ItemType File -Force -ErrorAction Ignore
        $Null = Remove-Item -Path "$DestinationPath" -Force -ErrorAction Ignore
        $ArchiveDataPath = Join-Path $DataPath '.dat'
        $ArchiveDataFile = Join-Path $ArchiveDataPath 'validate'

        if (-not (Test-Path -Path "$ArchiveDataFile" -PathType Leaf)) {
            throw "file `"$ArchiveDataFile`" missing"
        }

        [string]$FileContent = Get-Content -Path "$ArchiveDataFile" -Raw
        if ($FileContent.IndexOf('|') -eq -1) {
            throw "invalid file content"
        }
        [uint32]$FileLength = $FileContent.Split('|')[0]
        [string]$HashCheck = $FileContent.Split('|')[1]
    }
    process {
        try {
            Invoke-CombineSplitFiles -Path "$DataPath" -OutFilePath "$DestinationPath" -TotalSize $FileLength
            $Hash = (Get-FileHash $DestinationPath -Algorithm SHA1).Hash
            Write-Verbose "Original Hash $HashCheck"
            Write-Verbose "Combined Hash $Hash"
            if ($Hash -ne $HashCheck) { throw "error" }
        } catch {
            Write-Error "$_"
        }
    }
}


function Export-DataFiles {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Position = 0, Mandatory = $true)]
        [ValidateScript({ if (Test-Path $_ -PathType Leaf) { $true } else { throw "Path $_ is not valid. Should be a compressed archive" } })]
        [string]$Path,

        [Parameter(Position = 1, Mandatory = $true)]
        [ValidateScript({ if (Test-Path $_ -PathType Container) { $true } else { throw "Path $_ is not valid. Should be a directory" } })]
        [string]$DestinationPath,

        [Parameter(Position = 2, Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Key
    )

    try {
        # Read the encrypted file
        $FileBytes = [System.IO.File]::ReadAllBytes($Path)
        Write-Host " ✔️ Extract the IV (first 16 bytes) and encrypted data"
        # 
        $IV = $FileBytes[0..15]
        $EncryptedBytes = $FileBytes[16..($FileBytes.Length - 1)]

        # Convert the key into a byte array
        $KeyBytes = [System.Text.Encoding]::UTF8.GetBytes($Key)

        # Ensure key is 32 bytes for AES-256
        if ($KeyBytes.Length -lt 32) {
            $KeyBytes = $KeyBytes + (New-Object byte[] (32 - $KeyBytes.Length))
        } elseif ($KeyBytes.Length -gt 32) {
            $KeyBytes = $KeyBytes[0..31]
        }

        # Initialize AES-256 decryption
        $Aes = [System.Security.Cryptography.AesManaged]::new()
        $Aes.Key = $KeyBytes
        $Aes.IV = $IV
        $Aes.Mode = [System.Security.Cryptography.CipherMode]::CBC
        $Aes.Padding = [System.Security.Cryptography.PaddingMode]::PKCS7

        $Decryptor = $Aes.CreateDecryptor()
        $DecryptedBytes = $Decryptor.TransformFinalBlock($EncryptedBytes, 0, $EncryptedBytes.Length)

        # Generate a temporary archive file
        $TempArchive = [System.IO.Path]::GetTempFileName() + ".zip"
        [System.IO.File]::WriteAllBytes($TempArchive, $DecryptedBytes)

        Write-Host " ✔️ Extract the archive..."
        Expand-Archive -Path $TempArchive -DestinationPath $DestinationPath -Force

        # Cleanup temporary archive
        Remove-Item -Path $TempArchive -Force

        Write-Host " ✔️ Decryption and extraction complete."
        Write-Host " ✔️ Files extracted to: $DestinationPath"
    }
    catch {
        Show-ExceptionDetails ($_) -ShowStack
    }
}

function Invoke-DecodeFiles {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Position = 0, Mandatory = $true)]
        [ValidateScript({ if (Test-Path $_ -PathType Container) { $true } else { throw "Path $_ is not valid. Should be a compressed archive" } })]
        [string]$Path,

        [Parameter(Position = 1, Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$DestinationPath,


        [Parameter(Position = 1, Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Key
    )

    $RootPath = (Resolve-Path -Path "$PSScriptRoot\..").Path
    $TmpPath = Join-Path $RootPath '_tmp'
    $TmpArchiveFilePath = Join-Path $TmpPath 'archive.enc'
    Remove-Item -Path $TmpArchiveFilePath -Recurse -Force -ErrorAction Ignore | Out-Null
    Merge-DataFile -DataPath $Path -DestinationPath $TmpArchiveFilePath
    Export-DataFiles "$TmpArchiveFilePath" -DestinationPath "$DestinationPath" -Key "$Key"

    Write-Host "Cleaning temporary folder..."
    $TmpPath = Join-Path $RootPath '_tmp'
    Remove-Item -Path $TmpPath -Recurse -Force -ErrorAction Ignore | Out-Null
}


function Start-DecodeFiles {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$Path,        
        [Parameter(Mandatory = $False)]
        [string]$OptionalPassword
    )

    $Data = Get-ScriptEncodeAppCredentials
    if ($Data -eq $Null) {
        Write-Error "Missing App Rgistration Data"
    }
    $GlobalScriptsDirectory = $Data.UserName
    $DataClearPath = $GlobalScriptsDirectory
    New-Item -Path $DataClearPath -ItemType Directory -Force -ErrorAction Ignore | Out-Null
    if ($OptionalPassword) {
        $Password = $OptionalPassword
    } else {
        $Password = $Data.GetNetworkCredential().Password
    }
    
    Invoke-DecodeFiles -Path "$Path" -DestinationPath "$DataClearPath" -Key "$Password"
}
