function Test-Port {
    <#    
.SYNOPSIS    
    Tests port on computer.  
    
.DESCRIPTION  
    Tests port on computer. 
     
.PARAMETER computer  
    Name of server to test the port connection on.
      
.PARAMETER port  
    Port to test 
       
.PARAMETER tcp  
    Use tcp port 
      
.PARAMETER udp  
    Use udp port  
     
.PARAMETER UDPTimeOut 
    Sets a timeout for UDP port query. (In milliseconds, Default is 1000)  
      
.PARAMETER TCPTimeOut 
    Sets a timeout for TCP port query. (In milliseconds, Default is 1000)
                 
.EXAMPLE    
    Test-Port -computer 'server' -port 80  
    Checks port 80 on server 'server' to see if it is listening  
    
.EXAMPLE    
    'server' | Test-Port -port 80  
    Checks port 80 on server 'server' to see if it is listening 
      
.EXAMPLE    
    Test-Port -computer @("server1","server2") -port 80  
    Checks port 80 on server1 and server2 to see if it is listening  
         
#>
    [CmdletBinding(
        DefaultParameterSetName = '',
        ConfirmImpact = 'low'
    )]
    param(
        [Parameter(
            Mandatory = $True,
            Position = 0,
            ParameterSetName = '',
            ValueFromPipeline = $True)]
        [array]$computer,
        [Parameter(
            Position = 1,
            Mandatory = $True,
            ParameterSetName = '')]
        [array]$port,
        [Parameter(
            Mandatory = $False,
            ParameterSetName = '')]
        [int]$TCPtimeout = 1000,
        [Parameter(
            Mandatory = $False,
            ParameterSetName = '')]
        [int]$UDPtimeout = 1000,
        [Parameter(
            Mandatory = $False,
            ParameterSetName = '')]
        [switch]$TCP,
        [Parameter(
            Mandatory = $False,
            ParameterSetName = '')]
        [switch]$UDP
    )
    begin {
        if (!$tcp -and !$udp) { $tcp = $True }
        #Typically you never do this, but in this case I felt it was for the benefit of the function  
        #as any errors will be noted in the output of the report          
        $ErrorActionPreference = "SilentlyContinue"
        $report = @()
    }
    process {
        foreach ($c in $computer) {
            foreach ($p in $port) {
                if ($tcp) {
                    #Create temporary holder   
                    $temp = "" | Select Server, Port, TypePort, Open, Notes
                    #Create object for connecting to port on computer  
                    $tcpobject = new-Object system.Net.Sockets.TcpClient
                    #Connect to remote machine's port                
                    $connect = $tcpobject.BeginConnect($c, $p, $null, $null)
                    #Configure a timeout before quitting  
                    $wait = $connect.AsyncWaitHandle.WaitOne($TCPtimeout, $false)
                    #If timeout  
                    if (!$wait) {
                        #Close connection  
                        $tcpobject.Close()
                        Write-Verbose "Connection Timeout"
                        #Build report  
                        $temp.Server = $c
                        $temp.Port = $p
                        $temp.TypePort = "TCP"
                        $temp.Open = $False
                        $temp.Notes = "Connection to Port Timed Out"
                    } else {
                        $error.Clear()
                        $tcpobject.EndConnect($connect) | out-Null
                        #If error  
                        if ($error[0]) {
                            #Begin making error more readable in report  
                            [string]$string = ($error[0].exception).message
                            $message = (($string.Split(":")[1]).Replace('"', "")).TrimStart()
                            $failed = $true
                        }
                        #Close connection      
                        $tcpobject.Close()
                        #If unable to query port to due failure  
                        if ($failed) {
                            #Build report  
                            $temp.Server = $c
                            $temp.Port = $p
                            $temp.TypePort = "TCP"
                            $temp.Open = $False
                            $temp.Notes = "$message"
                        } else {
                            #Build report  
                            $temp.Server = $c
                            $temp.Port = $p
                            $temp.TypePort = "TCP"
                            $temp.Open = $True
                            $temp.Notes = ""
                        }
                    }
                    #Reset failed value  
                    $failed = $Null
                    #Merge temp array with report              
                    $report += $temp
                }
                if ($udp) {
                    #Create temporary holder   
                    $temp = "" | Select Server, Port, TypePort, Open, Notes
                    #Create object for connecting to port on computer  
                    $udpobject = new-Object system.Net.Sockets.Udpclient
                    #Set a timeout on receiving message 
                    $udpobject.client.ReceiveTimeout = $UDPTimeout
                    #Connect to remote machine's port                
                    Write-Verbose "Making UDP connection to remote server"
                    $udpobject.Connect("$c", $p)
                    #Sends a message to the host to which you have connected. 
                    Write-Verbose "Sending message to remote host"
                    $a = new-object system.text.asciiencoding
                    $byte = $a.GetBytes("$(Get-Date)")
                    [void]$udpobject.Send($byte, $byte.Length)
                    #IPEndPoint object will allow us to read datagrams sent from any source.  
                    Write-Verbose "Creating remote endpoint"
                    $remoteendpoint = New-Object system.net.ipendpoint ([system.net.ipaddress]::Any, 0)
                    try {
                        #Blocks until a message returns on this socket from a remote host. 
                        Write-Verbose "Waiting for message return"
                        $receivebytes = $udpobject.Receive([ref]$remoteendpoint)
                        [string]$returndata = $a.GetString($receivebytes)
                        if ($returndata) {
                            Write-Verbose "Connection Successful"
                            #Build report  
                            $temp.Server = $c
                            $temp.Port = $p
                            $temp.TypePort = "UDP"
                            $temp.Open = $True
                            $temp.Notes = $returndata
                            $udpobject.Close()
                        }
                    } catch {
                        if ($Error[0].ToString() -match "\bRespond after a period of time\b") {
                            #Close connection  
                            $udpobject.Close()
                            #Make sure that the host is online and not a false positive that it is open 
                            if (Test-Connection -comp $c -Count 1 -Quiet) {
                                Write-Verbose "Connection Open"
                                #Build report  
                                $temp.Server = $c
                                $temp.Port = $p
                                $temp.TypePort = "UDP"
                                $temp.Open = $True
                                $temp.Notes = ""
                            } else {
                                <# 
                                It is possible that the host is not online or that the host is online,  
                                but ICMP is blocked by a firewall and this port is actually open. 
                                #>
                                Write-Verbose "Host maybe unavailable"
                                #Build report  
                                $temp.Server = $c
                                $temp.Port = $p
                                $temp.TypePort = "UDP"
                                $temp.Open = $False
                                $temp.Notes = "Unable to verify if port is open or if host is unavailable."
                            }
                        } elseif ($Error[0].ToString() -match "forcibly closed by the remote host") {
                            #Close connection  
                            $udpobject.Close()
                            Write-Verbose "Connection Timeout"
                            #Build report  
                            $temp.Server = $c
                            $temp.Port = $p
                            $temp.TypePort = "UDP"
                            $temp.Open = $False
                            $temp.Notes = "Connection to Port Timed Out"
                        } else {
                            $udpobject.Close()
                        }
                    }
                    #Merge temp array with report              
                    $report += $temp
                }
            }
        }
    }
    end {
        #Generate Report  
        $report
    }
}

