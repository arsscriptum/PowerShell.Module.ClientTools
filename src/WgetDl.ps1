#╔════════════════════════════════════════════════════════════════════════════════╗
#║                                                                                ║
#║   StartXServer.ps1                                                            ║
#║                                                                                ║
#╟────────────────────────────────────────────────────────────────────────────────╢
#║   Guillaume Plante <codegp@icloud.com>                                         ║
#║   Code licensed under the GNU GPL v3.0. See the LICENSE file for details.      ║
#╚════════════════════════════════════════════════════════════════════════════════╝

function Invoke-WGetDownloadFile {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $True, Position = 0)]
        [string]$Url,
        [Parameter(Mandatory = $False)]
        [string]$OutFile,
        [Parameter(Mandatory = $False)]
        [switch]$ShowProgress
    )

    begin {
        [string]$WGetExePath = (Get-Command "wget.exe" -ErrorAction Ignore).Source
        [string]$CurrentPath = (Resolve-Path -Path "$PWD").Path
        try {
            [uri]$RemoteUri = $Url
            if (($RemoteUri.PathAndQuery -eq $Null) -or ($RemoteUri.Scheme -eq $Null)) {
                throw "invalid url"
            }
            [string]$RemoteFilename = $RemoteUri.Segments[$RemoteUri.Segments.Count - 1]
            [string]$DestinationFile = ""
            if ([string]::IsNullOrEmpty($OutFile)) {
                $DestinationFile = Join-Path $CurrentPath $RemoteFilename
            } else {
                $DestinationFile = $OutFile
            }
            if (Test-Path $DestinationFile) {
                throw "file already exists!"
            }
        } catch {
            write-error $_
        }
    }
    process {
        try {
            $redirects = 5
            $numtries = 5
            $verb = 'GET'
            $timeout = 10
            $WGetArgs = @()
            $WGetArgs += '-c'
            $WGetArgs += "--tries=$numtries"
            $WGetArgs += '--header="Accept-Encoding: gzip,deflate"'
            $WGetArgs += '--server-response'
            $WGetArgs += '--max-redirect'
            $WGetArgs += "$redirects"
            $WGetArgs += "--timeout=$timeout"
            $WGetArgs += '--no-check-certificate'
            if ($ShowProgress) {
                $WGetArgs += '--show-progress'
            }
            $WGetArgs += '-O'
            $WGetArgs += "$DestinationFile"
            $WGetArgs += "$Url"
            Start-Process $WGetExePath -ArgumentList $WGetArgs -NoNewWindow -Wait
        } catch {
            write-error $_
        }
    }
}


function Invoke-Aria2DownloadFile {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $True, Position = 0)]
        [string]$Url,
        [Parameter(Mandatory = $False)]
        [string]$OutFile,
        [Parameter(Mandatory = $False)]
        [ValidateRange(1, 32)]
        [int]$ParallelConnections = 16,
        [Parameter(Mandatory = $False)]
        [ValidateRange(1, 32)]
        [int]$ParallelSegments = 16,
        [Parameter(Mandatory = $False)]
        [ValidateSet("1K", "256K", "1M", "32M")]
        [string]$SegmentSize = '1M'
    )

    begin {
        [string]$Aria2ExePath = (Get-Command "aria2c.exe" -ErrorAction Ignore).Source
        [string]$CurrentPath = (Resolve-Path -Path "$PWD").Path
        try {
            [uri]$RemoteUri = $Url
            if (($RemoteUri.PathAndQuery -eq $Null) -or ($RemoteUri.Scheme -eq $Null)) {
                throw "invalid url"
            }
            [string]$RemoteFilename = $RemoteUri.Segments[$RemoteUri.Segments.Count - 1]
            [string]$DestinationFile = ""
            if ([string]::IsNullOrEmpty($OutFile)) {
                $DestinationFile = Join-Path $CurrentPath $RemoteFilename
            } else {
                $DestinationFile = $OutFile
            }
            if (Test-Path $DestinationFile) {
                throw "file already exists!"
            }
        } catch {
            write-error $_
        }
    }

    process {
        try {
            $Aria2Args = @()
            $LogFile = "$ENV:Temp\aria.log"
            $Aria2Args += "-s"
            $Aria2Args += "$ParallelConnections"
            $Aria2Args += "-x"
            $Aria2Args += "$ParallelSegments"
            $Aria2Args += "-k"
            $Aria2Args += "$SegmentSize"
            $Aria2Args += "--log=$LogFile"
            $Aria2Args += '-c'
            #$Aria2Args += '--file-allocation=none'
            $Aria2Args += '-d'
            $Aria2Args += "`"$CurrentPath`""
            $Aria2Args += "$Url"
            $strargs = ""
            $Aria2Args | % { $strargs += "$_ " }
            Write-Verbose "$Aria2ExePath $strargs"
            Start-Process $Aria2ExePath -ArgumentList $Aria2Args -NoNewWindow -Wait
        } catch {
            write-error $_
        }
    }
}

New-Alias -Name aria2dl -Value Invoke-Aria2DownloadFile -Scope Global -Force -ErrorAction Ignore | Out-Null

New-Alias -Name wgetdl -Value Invoke-WGetDownloadFile -Scope Global -Force -ErrorAction Ignore | Out-Null

function Test-Aria2DownloadFile {
    [CmdletBinding(SupportsShouldProcess)]
    param()

    begin {
        #[string]$DownloadUrl = "http://mini:81/localservers/test.dat"
        [string]$DownloadUrl = "https://download.qt.io/official_releases/qt/6.8/6.8.2/single/qt-everywhere-src-6.8.2.zip"
    }
    process {
        try {
            Remove-Item "$PWD\test.dat" -Force -EA Ignore
            Invoke-Aria2DownloadFile $DownloadUrl
        } catch {
            write-error $_
        }
    }
}

function Test-WGetDownloadFile {
    [CmdletBinding(SupportsShouldProcess)]
    param()

    begin {
        #[string]$DownloadUrl = "http://mini:81/localservers/test.dat"
        [string]$DownloadUrl = "https://download.qt.io/official_releases/qt/6.8/6.8.2/single/qt-everywhere-src-6.8.2.zip"
    }
    process {
        try {
            Remove-Item "$PWD\test.dat" -Force -EA Ignore
            Invoke-WGetDownloadFile $DownloadUrl -SegmentSize "32M"
        } catch {
            write-error $_
        }
    }
}
