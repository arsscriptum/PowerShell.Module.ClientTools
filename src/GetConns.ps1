#╔════════════════════════════════════════════════════════════════════════════════╗
#║                                                                                ║
#║   GetConns.ps1                                                                 ║
#║                                                                                ║
#╟────────────────────────────────────────────────────────────────────────────────╢
#║   Guillaume Plante <codegp@icloud.com>                                         ║
#║   Code licensed under the GNU GPL v3.0. See the LICENSE file for details.      ║
#╚════════════════════════════════════════════════════════════════════════════════╝



function Get-NetStatExe {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    try {
        $Cmd = Get-Command 'netstat.exe' -ErrorAction Ignore
        if ($Cmd -ne $Null) {
            $NetStatPath = $Cmd.Source
            return $NetStatPath
        }

        $NetStatPath = "$ENV:windir\system32\netstat.exe"
        if (Test-Path $NetStatPath) {
            return $NetStatPath
        }

        $File = Get-ChildItem -Path "$ENV:windir\system32" -Depth 1 -Filter "netstat.exe" -ErrorAction Ignore
        if ($File -ne $Null) {
            $NetStatPath = $File.FullName
            return $NetStatPath
        }
        return $Null
    } catch {
        Write-Error $_
    }
}

function Invoke-FilterRemoteAddresses {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [pscustomobject]$InputObject
    )

    process {
        # Ensure the input has a ForeignAddress property
        if ($InputObject.PSObject.Properties['ForeignAddress']) {
            $foreignAddress = $InputObject.ForeignAddress

            # Filter out local/private addresses
            if (
                $foreignAddress -notmatch '^(127\.0\.0\.1|0\.0\.0\.0)$' -and
                $foreignAddress -notmatch '^10\.' -and
                $foreignAddress -notmatch '^192\.168\.' -and
                $foreignAddress -notmatch '^172\.(1[6-9]|2[0-9]|3[0-1])\.'
            ) {
                # Output the object if it doesn't match local/private IPs
                $InputObject
            }
        }
    }
}


#===============================================================================
# 
#===============================================================================

function Get-LocalOpenPorts {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $false)]
        [ValidateSet('TCP', 'UDP')]
        [string]$Protocol = "TCP",
        [Parameter(Mandatory = $false)]
        [switch]$CommandLine,
        [Parameter(Mandatory = $false)]
        [switch]$ResolveHosts,
        [Parameter(Mandatory = $false)]
        [switch]$Quiet
    )
    try {
        $EnableLogs = $True
        if ($Quiet) {
            $EnableLogs = $False
        }
        $NetStatExe = Get-NetStatExe
        Write-Verbose "[Get-LocalOpenPorts] NetStatExe -> $NetStatExe"

        Write-Verbose "[Get-LocalOpenPorts] calling $NetStatExe -a -n -p `"$Protocol`" -o"
        $Data = & "$NetStatExe" '-a' '-n' '-p' "$Protocol" '-o'
        $TitleLineIndex = 0
        $ProtoIndex = 0
        $LocalAddressIndex = 0
        $ForeignAddressIndex = 0
        $StateIndex = 0
        $pdIndex = 0
        Write-Verbose "[Get-LocalOpenPorts] parsing output..."
        $DataCount = $Data.Count
        for ($i = 0; $i -lt $DataCount; $i++) {
            $Line = $Data[$i]

            if (($Line.Contains("Proto")) -and ($Line.Contains("State")) -and ($Line.Contains("PID"))) {
                $TitleLineIndex = $i
                $ProtoIndex = $Line.IndexOf("Proto")
                $LocalAddressIndex = $Line.IndexOf("Local")
                $ForeignAddressIndex = $Line.IndexOf("Foreign")
                $StateIndex = $Line.IndexOf("State")
                $pdIndex = $Line.IndexOf("PID")
                break;
            }
        }
        $ProcessIdToCmdLine = @{}
        [System.Collections.ArrayList]$OpenPorts = [System.Collections.ArrayList]::new()
        for ($i = $TitleLineIndex + 1; $i -lt $DataCount; $i++) {
            $Line = $Data[$i]
            $LineLen = $Line.Length
            $Proto = $Line.substring($ProtoIndex, ($LocalAddressIndex - $ProtoIndex))
            $LocalAddressPort = $Line.substring($LocalAddressIndex, ($ForeignAddressIndex - $LocalAddressIndex))
            $ForeignAddressPort = $Line.substring($ForeignAddressIndex, ($StateIndex - $ForeignAddressIndex))
            $LocalAddress = $LocalAddressPort.Split(":")[0]
            $LocalPort = $LocalAddressPort.Split(":")[1]
            $ForeignAddress = $ForeignAddressPort.Split(":")[0]
            $ForeignPort = $ForeignAddressPort.Split(":")[1]

            $State = $Line.substring($StateIndex, ($pdIndex - $StateIndex))
            $ProcessId = $Line.substring($pdIndex, ($LineLen - $pdIndex))
            $ProcessName = Get-Process -Id $ProcessId | Select -ExpandProperty Name


            [pscustomobject]$o = [pscustomobject]@{
                Proto = $Proto
                LocalAddress = $LocalAddress
                LocalPort = $LocalPort
                ForeignAddress = $ForeignAddress
                ForeignPort = $ForeignPort
                State = $State
                ProcessId = $ProcessId
                ProcessName = $ProcessName
            }

            if ($CommandLine) {

                if ($ProcessIdToCmdLine[$ProcessId] -eq $Null) {
                    if ($EnableLogs) {
                        Write-Host "[Get-LocalOpenPorts] Get command line for pid $ProcessId with Get-CimInstance"
                    }
                    $CmdLine = (Get-CimInstance Win32_Process -Filter "ProcessId = '$ProcessId'" | select CommandLine).CommandLine
                    $o | Add-Member -MemberType NoteProperty -Name 'CmdLine' -Value $CmdLine -Force
                    $ProcessIdToCmdLine[$ProcessId] = "$CmdLine"
                }
            }

            [void]$OpenPorts.Add($o)
        }
        if ($ResolveHosts) {
            [string[]]$RemoteAddressesToTest = $OpenPorts | Invoke-FilterRemoteAddresses | select -ExpandProperty ForeignAddress -Unique
            [int]$Count = $RemoteAddressesToTest.Count
            Write-Verbose "[Get-LocalOpenPorts] ResolveHosts -> $Count to resolve..."
            foreach ($fa in $RemoteAddressesToTest) {

                Write-Verbose "[Get-LocalOpenPorts] ResolveHosts -> Resolve-DnsName `"$fa`""
                # PTR (Pointer Record): Used for reverse DNS lookups to map an IP address back to a domain name.
                if ($EnableLogs) {
                    Write-Host "[Get-LocalOpenPorts] ResolveHosts -> Resolve-DnsName `"$fa`""
                }
                try {
                    $nameHost = Resolve-DnsName -Name $fa -Type PTR -ErrorAction Stop -QuickTimeout | select -ExpandProperty NameHost
                    foreach ($p in $OpenPorts) {
                        if ($p.ForeignAddress -eq $fa) {
                            Write-Verbose "[Get-LocalOpenPorts] set ForeignHostname to $nameHost for local $($p.LocalPort) $($p.ForeignAddress) $($p.ForeignPort) "
                            $p | Add-Member -MemberType NoteProperty -Name 'ForeignHostname' -Value $nameHost -Force
                        }
                    }
                } catch {
                    if ($p.ForeignAddress -eq $fa) {
                        Write-Verbose "[Get-LocalOpenPorts] set ForeignHostname to $nameHost for local $($p.LocalPort) $($p.ForeignAddress) $($p.ForeignPort) "
                        $p | Add-Member -MemberType NoteProperty -Name 'ForeignHostname' -Value 'n/a' -Force
                    }
                }
            }
        }
        $OpenPorts
    } catch {
        Show-ExceptionDetails $_ -ShowStack
    }
}

<#

#>
#===============================================================================
# 
#===============================================================================
function Get-ExternalPortState {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $True, Position = 0)]
        [int]$Port
    )
    try {

        $ExternalAddress = Get-ExternalIpAddress

        $MyHeaders = @{
            "authority" = "ports.yougetsignal.com"
            "method" = "POST"
            "path" = "/check-port.php"
            "scheme" = "https"
            "cache-control" = "no-cache"
            "origin" = "https://www.yougetsignal.com"
            "referer" = "https://www.yougetsignal.com/"
            "x-requested-with" = "XMLHttpRequest"
        }
        $Url = "https://ports.yougetsignal.com/check-port.php"
        $BodyStr = "remoteAddress={0}&portNumber={1}" -f $ExternalAddress, $Port
        $CntType = "application/x-www-form-urlencoded; charset=UTF-8"
        $Res = Invoke-WebRequest -UseBasicParsing -Uri "$Url" -Method "POST" -Headers $MyHeaders -ContentType "$CntType" -Body "$BodyStr"

        $cnt = $Res.Content

        $Tag = "$Port</a> is"
        $TagLen = $Tag.Length
        $i = $cnt.IndexOf($Tag) + $TagLen
        $i2 = $cnt.IndexOf('</p>', $i)
        $State = $cnt.substring($i, $i2 - $i).Trim().Trim('.')
        $State
    } catch {
        Write-Error $_
    }
}


#===============================================================================
# 
#===============================================================================
function Get-ExternalPortStateReport {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $True, Position = 0)]
        [int]$Port,
        [Parameter(Mandatory = $false)]
        [ValidateSet('TCP', 'UDP', 'BOTH')]
        [string]$Protocol = "TCP"
    )
    try {
        $Url = "https://www.speedguide.net/portscan.php?tcp={0}&udp={1}&port={2}" -f $ScanTcp, $ScanUdp, $Port
        $ScanTCP = 1
        $ScanUDP = 0
        switch ($Protocol) {
            'TCP' {
                $Url = "https://www.speedguide.net/portscan.php?port={0}" -f $Port
                $ScanTCP = 1
                $ScanUDP = 0
            }
            'UDP' {
                $Url = "https://www.speedguide.net/portscan.php?port={0}&udp=1" -f $Port
                $ScanTCP = 0
                $ScanUDP = 1
            }
            'BOTH' {
                $Url = "https://www.speedguide.net/portscan.php?port={0}&udp=1&tcp=1" -f $Port
                $ScanTCP = 1
                $ScanUDP = 1
            }
        }


        Write-Verbose "Getting `"$Url`""
        $Res = Invoke-WebRequest -UseBasicParsing -Uri "$Url" -Method "GET" -Headers @{ "Cache-Control" = "no-cache" }
        $Cnt = $Res.Content

        $Tag = "title=`"port details`">$Port"
        $i = $Cnt.IndexOf($Tag)
        $i = $Cnt.LastIndexOf('<table', $i)
        $i2 = $Cnt.IndexOf('</table>', $i) + 8
        $TableInfo = $Cnt.substring($i, $i2 - $i)
        $PageHtml = '<HTML><HEAD><TITLE>SCAN OF {0}</TITLE></HEAD><BODY BGCOLOR="FFFFFF"><HR>{1}<HR></BODY></HTML>' -f $Port, $TableInfo
        $Filename = (New-Guid).GUID
        $TmpFile = "$ENV:Temp\$Filename.html"
        Set-Content -Path "$TmpFile" -Value "$PageHtml"
        start "$TmpFile"
        Start-Sleep 2
        Remove-Item "$TmpFile" -Force | Out-Null

    } catch {
        Write-Error $_
    }
}


#===============================================================================
# 
#===============================================================================
function Test-ExternalPort {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $True, Position = 0)]
        [int]$Port
    )
    try {
        $Res = Get-ExternalPortState $Port
        $State = $Res.Split(' ')[0]
        $IsOpen = $State -match "open"

        $IsOpen
    } catch {
        Write-Error $_
    }
}

function Invoke-TcpConView {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $False)]
        [switch]$CommandLine,
        [Parameter(Mandatory = $False)]
        [switch]$EnableLogs
    )
    try {
        $ProcessIdToCmdLine = @{}
        # Define the path to tcpvcon64.exe
        $tcpvconPath = 'C:\ProgramData\chocolatey\bin\tcpvcon64.exe'

        # Run tcpvcon64.exe and capture the output
        $tcpvconOutput = & $tcpvconPath -accepteula -nobanner -n -a -c

        # Define the CSV header for parsing tcpvcon64.exe output


        # Parse tcpvcon64.exe output using ConvertFrom-Csv
        $tcpvconConnections = $tcpvconOutput | ConvertFrom-Csv -Header Protocol, ProcessName, ProcessId, State, LocalAddress, RemoteAddress -Delimiter ','
        [System.Collections.ArrayList]$ConnList = [System.Collections.ArrayList]::new()


        if ($CommandLine) {
            foreach ($conn in $tcpvconConnections) {
                $ProcessId = $conn.ProcessId
                Write-Verbose "CommandLine -> ProcessId $ProcessId"
                if ($ProcessIdToCmdLine[$ProcessId] -eq $Null) {
                    if ($EnableLogs) {
                        Write-Host "[Invoke-TcpConView] Get command line for pid $ProcessId with Get-CimInstance"
                    }
                    $CmdLine = (Get-CimInstance Win32_Process -Filter "ProcessId = '$ProcessId'" | select CommandLine).CommandLine
                    if ([string]::IsNullOrEmpty($CmdLine)) {
                        $CmdLine = 'n/a'
                    }

                    [pscustomobject]$o = [pscustomobject]@{
                        Protocol = $conn.Protocol
                        ProcessName = $conn.ProcessName
                        ProcessId = $conn.ProcessId
                        State = $conn.State
                        LocalAddress = $conn.LocalAddress
                        RemoteAddress = $conn.RemoteAddress
                        CommandLine = $CmdLine
                    }
                    [void]$ConnList.Add($o)
                    $ProcessIdToCmdLine[$ProcessId] = "$CmdLine"
                }
            }
        } else {
            $ConnList = $tcpvconConnections
        }

        $ConnList
    } catch {
        Write-Error $_
    }
}


function Get-ActiveConnectionsNetstat {
    # Define the path to tcpvcon64.exe
    $netstatPath = "C:\Windows\system32\netstat.exe"
    $netstatOutput = & "$netstatPath" '-ano' | Select-String -Pattern '^\s*(TCP|UDP)' -NoEmphasis
    # Filter lines starting with TCP or UDP

    # Parse netstat output to extract protocol, local address, foreign address, state, and PID
    $netstatConnections = foreach ($line in $netstatOutput) {
        $newline = $line.Line.Trim()
        $parts = $newline -split '\s+'


        # Extract the local address and port
        if ($parts[1].Contains(':')) {
            $localAddress = $parts[1].substring(0, $parts[1].LastIndexOf(':'))
            $localPort = $parts[1].substring($parts[1].LastIndexOf(':') + 1)
        } else {
            $localAddress = $parts[1]
            $localPort = '*'
        }
        if ($parts[2].Contains(':')) {
            $remoteAddress = $parts[2].substring(0, $parts[2].LastIndexOf(':'))
            $remotePort = $parts[2].substring($parts[2].LastIndexOf(':') + 1)
        } else {
            $remoteAddress = $parts[2]
            $remotePort = '*'
        }


        if ($parts.Count -gt 4) {
            $state = $parts[3]
            $processid = $parts[4]
        } else {
            $state = "*"
            $processid = $parts[3]
        }
        # Create a PSCustomObject for the netstat output
        [pscustomobject]@{
            Protocol = $parts[0]
            LocalAddress = $localAddress
            LocalPort = $localPort
            RemoteAddress = $remoteAddress
            RemotePort = $remotePort
            State = $state
            ProcessId = $processid
        }
    }
    $netstatConnections
}


function Get-ActiveConnectionsWithLocalPort {

    $tcpvconConnections = Invoke-TcpConView

    $netstatConnections = Get-ActiveConnectionsNetstat

    # Cross-reference tcpvcon64.exe and netstat results
    $result = foreach ($conn in $tcpvconConnections) {
        # Find matching netstat entry by Protocol, LocalAddress, and ProcessId
        $matchingNetstat = $netstatConnections | Where-Object {
            $_.State -eq $conn.State -and
            $_.LocalAddress -eq $conn.LocalAddress -and
            $_.ProcessId -eq $conn.ProcessId
        }

        # Add LocalPort to the tcpvcon64 connection if a match is found
        if ($matchingNetstat) {
            # Clone the original connection and add the LocalPort
            [pscustomobject]@{
                Protocol = $conn.Protocol
                ProcessName = $conn.ProcessName
                ProcessId = $conn.ProcessId
                State = $conn.State
                LocalAddress = $conn.LocalAddress
                LocalPort = $matchingNetstat.LocalPort
                RemoteAddress = $conn.RemoteAddress
                RemotePort = $matchingNetstat.RemotePort
            }
        }
    }

    # Return the final list with the LocalPort included
    return $result
}

function Get-V6ConnectionsOnly {
    Invoke-TcpConView | ? Protocol -Match 'V6'
}

function Get-ActiveConnectionsOnly {
    Invoke-TcpConView | ? State -Match "ESTABLISHED|LISTENING"
}

function Get-ActiveConnectionsListening {
    Invoke-TcpConView | ? State -Match "LISTENING"
}

function Get-ActiveConnectionsEstablished {
    Invoke-TcpConView | ? State -Match "ESTABLISHED"
}


function Get-ConnectionDoc {

    $doc = @"

aliases

conlisteningGet --> ActiveConnectionsListening
conestablished --> Get-ActiveConnectionsEstablished
conactive --> Get-ActiveConnectionsOnly
constat --> Get-ActiveConnectionsNetstat
conview --> Invoke-TcpConView
conviewports --> Get-ActiveConnectionsWithLocalPort
viewconnections --> Get-ActiveConnectionsWithLocalPort
 
funcs

Get-ActiveConnectionsListening
Get-ActiveConnectionsEstablished
Get-ActiveConnectionsOnly
Get-ActiveConnectionsNetstat
Invoke-TcpConView
Get-ActiveConnectionsWithLocalPort 
Get-ActiveConnectionsWithLocalPort

"@
    Write-Host "`n$doc`n" -f DarkYellow

}



New-Alias -Name conlistening -Value Get-ActiveConnectionsListening -Scope 'Global' -ErrorAction 'Ignore'
New-Alias -Name conestablished -Value Get-ActiveConnectionsEstablished -Scope 'Global' -ErrorAction 'Ignore'
New-Alias -Name conactive -Value Get-ActiveConnectionsOnly -Scope 'Global' -ErrorAction 'Ignore'
New-Alias -Name constat -Value Get-ActiveConnectionsNetstat -Scope 'Global' -ErrorAction 'Ignore'
New-Alias -Name conview -Value Invoke-TcpConView -Scope 'Global' -ErrorAction 'Ignore'
New-Alias -Name conviewports -Value Get-ActiveConnectionsWithLocalPort -Scope 'Global' -ErrorAction 'Ignore'
New-Alias -Name viewconnections -Value Get-ActiveConnectionsWithLocalPort -Scope 'Global' -ErrorAction 'Ignore'



New-Alias -Name conndoc -Value Get-ConnectionDoc -Scope 'Global' -ErrorAction 'Ignore'
