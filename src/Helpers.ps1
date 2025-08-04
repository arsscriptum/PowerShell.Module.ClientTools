#╔════════════════════════════════════════════════════════════════════════════════╗
#║                                                                                ║
#║   helpers.ps1                                                                  ║
#║                                                                                ║
#╟────────────────────────────────────────────────────────────────────────────────╢
#║   Guillaume Plante <codegp@icloud.com>                                         ║
#║   Code licensed under the GNU GPL v3.0. See the LICENSE file for details.      ║
#╚════════════════════════════════════════════════════════════════════════════════╝


function Write-ProgressHelper{
    [CmdletBinding()]
    param()
    try{
        if($Script:TotalSteps -eq 0){return}
        Write-Progress -Activity $Script:ProgressTitle -Status $Script:ProgressMessage -PercentComplete (($Script:StepNumber /  $Script:TotalSteps) * 100)
    }catch{
        Write-Host "⌛ StepNumber $Script:StepNumber" -f DarkYellow
        Write-Host "⌛ ScriptSteps $Script:TotalSteps" -f DarkYellow
        $val = (($Script:StepNumber / $Script:TotalSteps) * 100)
        Write-Host "⌛ PercentComplete $val" -f DarkYellow
        Show-ExceptionDetails $_ -ShowStack
    }
}

function Write-ClientToolsHost{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,Position=0)][Alias('m')]
        [String]$Message
    ) 
    Write-Host "[PowerShell.Module.ClientTools] " -f DarkRed -n
    Write-Host "$Message" -f DarkYellow
}



function Test-Function{                     ############### NOEXPORT
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true,Position=0)][Alias('n')][String]$Name,
        [Parameter(Mandatory=$true,Position=1)][Alias('m')][String]$Module
    )     
    $Res = $True
    try{
        Write-Verbose "Test $Name [$Module]"
        if(-not(Get-Command "$Name" -ErrorAction Ignore)) { throw "missing function $Name, from module $Module" }    
    }catch{
        Write-Host "[Missing Dependency] " -n -f DarkRed
        Write-Host "$_"  -f DarkYellow
        $Res = $False
    }
    return $Res
} 

function Test-Dependencies{                     ############### NOEXPORT
    [CmdletBinding(SupportsShouldProcess)]
    param()        
    $Res = $True
    try{
        $CoreFuncs = @('Set-RegistryValue','New-RegistryValue','Register-AppCredentials','Decrypt-String')
        ForEach($f in $CoreFuncs){
            if(-not(Test-Function -n "$f" -m "PowerShell.Module.OpenAI")){ $Res = $False ; break; }
        }
    }catch{
        Write-Error "$_"
        $Res = $False
    }
    return $Res
} 


<#
    .SYNOPSIS
        FROM C-time converter function
    .DESCRIPTION
        Simple function to convert FROM Unix/Ctime into EPOCH / "friendly" time
#> 
function ConvertFrom-Ctime {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, Mandatory=$true,  HelpMessage="ctime")]
        [Int64]$Ctime
    )

    [datetime]$epoch = '1970-01-01 00:00:00'    
    [datetime]$result = $epoch.AddSeconds($Ctime)
    return $result
}

<#
    .SYNOPSIS
        INTO C-time converter function
    .DESCRIPTION
        Simple function to convert into FROM EPOCH / "friendly" into Unix/Ctime, which the Inventory Service uses.
#> 
function ConvertTo-CTime {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, Mandatory=$true,  HelpMessage="InputEpoch")]
        [datetime]$InputEpoch
    )

    [datetime]$Epoch = '1970-01-01 00:00:00'
    [int64]$Ctime = 0

    $Ctime = (New-TimeSpan -Start $Epoch -End $InputEpoch).TotalSeconds
    return $Ctime
}

function ConvertFrom-UnixTime{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]
        [Int64]$UnixTime
    )
    begin {
        $epoch = [DateTime]::SpecifyKind('1970-01-01', 'Local')
    }
    process {
        $epoch.AddSeconds($UnixTime)
    }
}

function ConvertTo-UnixTime {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]
        [DateTime]$DateTime
    )
    begin {
        $epoch = [DateTime]::SpecifyKind('1970-01-01', 'Local')
    }
    process {
        [Int64]($DateTime - $epoch).TotalSeconds
    }
}

function Get-UnixTime {
    $Now = Get-Date
    return ConvertTo-UnixTime $Now
}


function Get-DateString([switch]$Verbose){

    if($Verbose){
        return ((Get-Date).GetDateTimeFormats()[8]).Replace(' ','_').ToString()
    }

    $curdate = $(get-date -Format "yyyy-MM-dd_\hhh-\mmmm-\sss")
    return $curdate 
}


function Get-DateForFileName([switch]$Minimal){   
  $sd = (Get-Date).GetDateTimeFormats()[14]
  $sd = $sd.Split('.')[0]
  $sd = $sd.replace(':','-');
  if($Minimal){
    $sd = $sd.replace('-','');
  }
  return $sd
}
