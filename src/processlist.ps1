#╔════════════════════════════════════════════════════════════════════════════════╗
#║                                                                                ║
#║   GetProcessList.ps1                                                           ║
#║                                                                                ║
#╟────────────────────────────────────────────────────────────────────────────────╢
#║   Guillaume Plante <codegp@icloud.com>                                         ║
#║   Code licensed under the GNU GPL v3.0. See the LICENSE file for details.      ║
#╚════════════════════════════════════════════════════════════════════════════════╝


function Get-ProcessList {
    [CmdletBinding(SupportsShouldProcess)]
    param()

    try {
        [string]$PsListExe = (Get-Command 'pslist.exe').Source

        [string[]]$Output = & "$PsListExe" '-nobanner'
        $Num = $Output.Count
        $DataNum = $Num - 3
        $ComIndex = 2
        $processList = @()
        [string[]]$lines = $Output | Select -Last $DataNum

        foreach ($line in $lines) {
            # Use regex to capture each column by whitespace
            if ($line -match '^(?<Name>\S+)\s+(?<Pid>\d+)\s+(?<Pri>\d+)\s+(?<Thd>\d+)\s+(?<Hnd>\d+)\s+(?<Priv>\d+)\s+(?<CPU>[\d:]+.\d+)\s+(?<Elapsed>[\d:]+.\d+)$') {
                $process = [pscustomobject]@{
                    Name = $matches['Name']
                    Pid = [int]$matches['Pid']
                    Pri = [int]$matches['Pri']
                    Thd = [int]$matches['Thd']
                    Hnd = [int]$matches['Hnd']
                    Priv = [int]$matches['Priv']
                    CPUTime = $matches['CPU']
                    ElapsedTime = $matches['Elapsed']
                }
                $processList += $process
            }
        }

        return $processList

    } catch {
        Write-Error "$_"
    }

}


