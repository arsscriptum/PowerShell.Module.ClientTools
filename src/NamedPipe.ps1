#╔════════════════════════════════════════════════════════════════════════════════╗
#║                                                                                ║
#║   NamedPipe.ps1                                                                ║
#║   Functions to control Named Pipes                                             ║
#║                                                                                ║
#╟────────────────────────────────────────────────────────────────────────────────╢
#║   Guillaume Plante <codegp@icloud.com>                                         ║
#║   Code licensed under the GNU GPL v3.0. See the LICENSE file for details.      ║
#╚════════════════════════════════════════════════════════════════════════════════╝


function New-NamedPipeServer {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $False, Position = 0)]
        [string]$PipeId = "testpipe"
    )
    try {
        [string]$namedpipePath = "\\.\pipe\{0}" -f $PipeId
        Write-Verbose "[Send-NamedPipeData] Message: $Message"
        Write-Verbose "PipeId       $PipeId"
        Write-Verbose "full path    $namedpipePath"

        # Create the named pipe server
        $pipeServer = [System.IO.Pipes.NamedPipeServerStream]::new($namedpipePath, [System.IO.Pipes.PipeDirection]::In)
        Write-Verbose "Named pipe server created: $namedpipePath"

        # Wait for client connection
        $pipeServer.WaitForConnection()
        Write-Verbose "Client connected to the named pipe."

        # Read data from the pipe
        $reader = [System.IO.StreamReader]::new($pipeServer)
        $data = $reader.ReadToEnd()

        # Clean up
        $reader.Close()
        $pipeServer.Close()
        Write-Verbose "Received data: $data"
        $data

    } catch {
        Show-ExceptionDetails ($_) -ShowStack
    }
}


function New-NamedPipeServerAsync {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $False, Position = 0)]
        [string]$PipeId = "testpipe"
    )
    try {
        [string]$namedPipeId = $PipeId
        [string]$namedpipePath = "\\.\pipe\{0}" -f $PipeId
        if ([string]::IsNullOrEmpty($PipeId)) {
            [string]$namedPipeId = "{0}\{1}\{2}" -f (Get-Process -Id $PID).Name, $PID.ToString(), ((Get-Date).ToString("HHmmss"))
            [string]$namedpipePath = "\\.\pipe\{0}" -f $namedPipeId
        }

        # Create the named pipe server
        $pipeServer = [System.IO.Pipes.NamedPipeServerStream]::new($namedpipePath, [System.IO.Pipes.PipeDirection]::In)
        $res = [pscustomobject]@{
            Pipe = $pipeServer
            Id = $namedPipeId
            Path = $namedpipePath
            Async = $pipeServer.IsAsync
            Connected = $pipeServer.IsConnected
        }
        return $res
    } catch {
        Show-ExceptionDetails ($_) -ShowStack
    }
}


function Start-NamedPipeServerJob {
    param(
        [Parameter(Mandatory = $True)]
        [System.IO.Pipes.NamedPipeServerStream]$PipeServer
    )

    # Start a background job to handle pipe connections
    $job = Start-Job -ScriptBlock {
        param($server)

        try {
            # Wait for a client to connect
            $server.WaitForConnection()
            Write-Host "Client connected to the pipe."

            # Read data from the client
            $reader = [System.IO.StreamReader]::new($server)
            $data = $reader.ReadToEnd()

            # Log received data
            Write-Host "Received data: $data"

            # Clean up
            $reader.Close()
            $server.Close()

            return $data
        } catch {
            Write-Error "An error occurred in the pipe server job: $_"
        }
    } -ArgumentList $PipeServer

    # Return the job object for monitoring
    return $job
}


function New-NamedPipeClient {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $False)]
        [string]$PipeId,
        [Parameter(Mandatory = $False, HelpMessage = "Connection Timeout in milliseconds")]
        [ValidateRange(1, 60000)]
        [int]$ConnectTimeout = 4000,
        [Parameter(Mandatory = $False, HelpMessage = "Quiet mode")]
        [switch]$Quiet
    )
    try {
        [string]$namedPipeId = $PipeId
        [string]$namedpipePath = "\\.\pipe\{0}" -f $PipeId
        if ([string]::IsNullOrEmpty($PipeId)) {
            [string]$namedPipeId = "{0}\{1}\{2}" -f (Get-Process -Id $PID).Name, $PID.ToString(), ((Get-Date).ToString("HHmmss"))
            [string]$namedpipePath = "\\.\pipe\{0}" -f $namedPipeId
        }

        Write-Verbose "[Send-NamedPipeData] Message: $Message"
        Write-Verbose "PipeId       $PipeId"
        Write-Verbose "full path    $namedpipePath"
        # Connect to the named pipe server
        $pipeClient = [System.IO.Pipes.NamedPipeClientStream]::new('.', $namedpipePath, [System.IO.Pipes.PipeDirection]::Out)

        Write-Verbose "connecting..."
        # Connect asynchronously with a timeout
        $connectTask = $pipeClient.ConnectAsync($ConnectTimeout)

        if (-not $connectTask.Wait($ConnectTimeout)) {
            throw "Connection to named pipe '$pipeFullName' timed out after $ConnectTimeout milliseconds."
        }
        if (-not ($pipeClient.IsConnected -and $pipeClient.IsAsync)) {
            throw "pipe not connected"
        }

        Write-Verbose "Connected to named pipe: $pipeFullName"
        $res = [pscustomobject]@{
            Pipe = $pipeClient
            Id = $namedPipeId
            Path = $namedpipePath
            Async = $pipeClient.IsAsync
            Connected = $pipeClient.IsConnected
        }
        return $res
    } catch {
        if ($Quiet) {
            return $Null
        }
        Show-ExceptionDetails ($_) -ShowStack
    }

}



function Send-NamedPipeData {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $True, Position = 0)]
        [string]$Message,
        [Parameter(Mandatory = $True)]
        [System.IO.Pipes.NamedPipeClientStream]$NamedPipe
    )
    try {
        [string]$namedpipePath = "\\.\pipe\{0}" -f $PipeId
        Write-Verbose "[Send-NamedPipeData] Message: $Message"
        Write-Verbose "PipeId       $PipeId"
        Write-Verbose "full path    $namedpipePath"
        # Connect to the named pipe server
        $pipeClient = [System.IO.Pipes.NamedPipeClientStream]::new('.', $namedpipePath, [System.IO.Pipes.PipeDirection]::Out)

        Write-Verbose "connecting..."
        # Connect asynchronously with a timeout
        $connectTask = $pipeClient.ConnectAsync($ConnectTimeout)

        if (-not $connectTask.Wait($ConnectTimeout)) {
            throw "Connection to named pipe '$pipeFullName' timed out after $ConnectTimeout milliseconds."
        }
        if (-not ($pipeClient.IsConnected -and $pipeClient.IsAsync)) {
            throw "pipe not connected"
        }



        Write-Verbose "Connected to named pipe: $pipeFullName"

        Write-Host "Connected to named pipe: $pipeFullName"

        # Write data to the pipe
        $writer = [System.IO.StreamWriter]::new($pipeClient)
        $writer.AutoFlush = $true
        $writer.WriteLine($Message)

        # Clean up
        $writer.Close()
        $pipeClient.Close()
        Write-Host "Data sent: $Message"

    } catch {
        Show-ExceptionDetails ($_) -ShowStack
    }
}
