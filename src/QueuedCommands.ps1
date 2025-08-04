#╔════════════════════════════════════════════════════════════════════════════════╗
#║                                                                                ║
#║   UpdateLoginScripts.ps1                                                       ║
#║                                                                                ║
#╟────────────────────────────────────────────────────────────────────────────────╢
#║   Guillaume Plante <codegp@icloud.com>                                         ║
#║   Code licensed under the GNU GPL v3.0. See the LICENSE file for details.      ║
#╚════════════════════════════════════════════════════════════════════════════════╝


function New-QueuedCommand {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$ExeName,
        [Parameter(Mandatory = $false, Position = 1)]
        [string[]]$ArgumentList,
        [Parameter(Mandatory = $false)]
        [uint32]$Delay = 30,
        [Parameter(Mandatory = $false)]
        [switch]$Wait
    )
    [decimal]$Now = (get-date -UFormat "%s") -as [decimal]
    [decimal]$WhenTime = $Now + $Delay

    $RegKeyRoot = "HKCU:\Software\arsscriptum\PowerShell.Module.ClientTools\QueuedCommands"
    $registryPath = "$RegKeyRoot\$Now"

    # Ensure the registry path exists
    if (-not (Test-Path $registryPath)) {
        New-Item -Path $registryPath -Force | Out-Null
    }

    # Get all script files (*.ps1) in the specified folder
    $scriptFiles = Get-ChildItem -Path $scriptFolder -Filter "*.ps1" | ForEach-Object { $_.FullName }


    $WaitForExit = 0
    if($Wait){
        $WaitForExit = 1
    }
    # Set the registry key as REG_MULTI_SZ (array of strings)
    Set-ItemProperty -Path $registryPath -Name "wait" -Value $WaitForExit -Type DWORD
    Set-ItemProperty -Path $registryPath -Name "when" -Value $WhenTime -Type DWORD
    Set-ItemProperty -Path $registryPath -Name "exename" -Value $ExeName -Type String
    Set-ItemProperty -Path $registryPath -Name "argumentlist" -Value $ArgumentList -Type MultiString
}

function Read-QueuedCommandsLogFile {
    [CmdletBinding(SupportsShouldProcess)]
    param()

    
    $LogFile = "$ENV:Temp\QueuedCommands.log"
    get-content "$LogFile" | Select -Last 10

}

function Test-ProcessQueuedCommands {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $false)]
        [switch]$DryRun
    )

    $LogFile = "$ENV:Temp\QueuedCommands.log"
    $LogDate = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
    if (!(Test-Path $LogFile)) {
        "============ LOG STARTED on $LogDate ============" | Out-File -FilePath $LogFile -Encoding UTF8
    }

    function Write-Log {
        [CmdletBinding(SupportsShouldProcess)]
        param([string]$Message)
        $ts = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
        "[Test-ProcessQueuedCommands] $ts - $Message" | Out-File -FilePath $LogFile -Append -Encoding UTF8
        Write-Host "[Test-ProcessQueuedCommands] $ts - $Message"
    }

    Write-Log "DryRun: Simulating Executing queued commands"
    $ExecuteCommand = $False
  


    $RegKeyRoot = "HKCU:\Software\arsscriptum\PowerShell.Module.ClientTools\QueuedCommands"
    if (-not (Test-Path $RegKeyRoot)) {
        Write-Log "Registry path '$RegKeyRoot' does not exist. Exiting."
        return
    }

    [decimal]$Now = (get-date -UFormat "%s") -as [decimal]

    $QueuedCmds = Get-ChildItem -Path $RegKeyRoot
    $QueuedCmdsCount = $QueuedCmds.Count
    Write-Log "Currently $QueuedCmdsCount Active Queued Commands"
    foreach ($command in $QueuedCmds) {
        try {
            $shouldwait = $command.GetValue('wait')
            $whenval = $command.GetValue('when')
            $exeName = $command.GetValue('exename')
            $argList = $command.GetValue('argumentlist')
            $Diff = $Now - $whenval
            Write-Log "Now $Now whenval $whenval. Diff $Diff"
            if ($Diff -gt 0) {
                if ($ExecuteCommand) {
                    Write-Log "Executing queued command '$exeName $argList' scheduled for $Diff seconds ago"
                    $psi = New-Object System.Diagnostics.ProcessStartInfo
                    $psi.FileName = $exeName
                    $psi.Arguments = $argList -join ' '
                    $psi.UseShellExecute = $false
                    $psi.RedirectStandardOutput = $true
                    $psi.RedirectStandardError = $true

                    $proc = [System.Diagnostics.Process]::Start($psi)
                    $stdout = $proc.StandardOutput.ReadToEnd()
                    $stderr = $proc.StandardError.ReadToEnd()
                    if($shouldwait){
                        $proc.WaitForExit()
                        Write-Log "Command exit code: $($proc.ExitCode)"
                        if ($stdout) { Write-Log "STDOUT:`n$stdout" }
                        if ($stderr) { Write-Log "STDERR:`n$stderr" }
                    }
                    
                    # Remove registry key after execution
                    Remove-Item -Path $command.PSPath -Force -Recurse
                    Write-Log "Deleted registry key: $($command.PSChildName)"
                }else{
                    Write-Log "Would be executing queued command '$exeName $argList' scheduled for $Diff seconds ago"
                }
            } else {
                $DiffAbs = [math]::Abs($Diff)
                Write-Log "Command '$exeName $argList' is scheduled to run in $DiffAbs seconds - not time yet."
            }
        } catch {
            Write-Log "ERROR processing command $($command.PSChildName): $_"
        }
    }
}


function Clear-QueuedCommands {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param()

    $RegKeyRoot = "HKCU:\Software\arsscriptum\PowerShell.Module.ClientTools\QueuedCommands"

    if (-not (Test-Path $RegKeyRoot)) {
        Write-Host "No queued commands found." -ForegroundColor Yellow
        return
    }

    try {
        $QueuedItems = Get-ChildItem -Path $RegKeyRoot

        if ($QueuedItems.Count -eq 0) {
            Write-Host "No queued commands to clear." -ForegroundColor Yellow
            return
        }

        foreach ($item in $QueuedItems) {
            if ($PSCmdlet.ShouldProcess($item.PSChildName, "Remove queued command")) {
                Remove-Item -Path $item.PSPath -Recurse -Force -ErrorAction Stop
                Write-Host "Removed queued command: $($item.PSChildName)" -ForegroundColor Green
            }
        }
    }
    catch {
        Write-Host "Failed to remove queued commands: $_" -ForegroundColor Red
    }
}
