#╔════════════════════════════════════════════════════════════════════════════════╗
#║                                                                                ║
#║   ScheduledTaskDetails.ps1                                                     ║
#║   Get Details of Scheduled Tasks                                               ║
#║                                                                                ║
#╟────────────────────────────────────────────────────────────────────────────────╢
#║   Guillaume Plante <codegp@icloud.com>                                         ║
#║   Code licensed under the GNU GPL v3.0. See the LICENSE file for details.      ║
#╚════════════════════════════════════════════════════════════════════════════════╝

function Get-ScheduledTaskDetails {
    [CmdletBinding(DefaultParameterSetName = 'TaskName')]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = 'TaskName', HelpMessage = 'TaskName')]
        [string]$TaskName,

        [Parameter(Mandatory = $true, ParameterSetName = 'TaskPath', HelpMessage = 'TaskPath')]
        [string]$TaskPath
    )

    # Retrieve task data based on parameter set
    if ($PSCmdlet.ParameterSetName -eq 'TaskName') {
        $AllTaskData = Get-ScheduledTask -TaskName $TaskName -ErrorAction Stop
        $DetailsTaskData = schtasks /Query /TN $TaskName /V /FO CSV | ConvertFrom-Csv
    } 
    else {
        $AllTaskData = Get-ScheduledTask -TaskPath $TaskPath -ErrorAction Stop
        $Name = $AllTaskData.TaskName
        $DetailsTaskData = schtasks /Query /TN $Name /V /FO CSV | ConvertFrom-Csv
    }

    $UserData = $AllTaskData.Principal
    foreach ($prop in $UserData.PSObject.Properties) {
        $pname = "User_{0}" -f $prop.Name.Replace(' ','-')
        $AllTaskData | Add-Member -NotePropertyName $pname -NotePropertyValue $prop.Value -Force
    }
    $Settings = $AllTaskData.Settings
    foreach ($prop in $Settings.PSObject.Properties) {
        $pname = "Settings_{0}" -f $prop.Name.Replace(' ','-')
        $AllTaskData | Add-Member -NotePropertyName $pname -NotePropertyValue $prop.Value -Force
    }
    $Triggers = $AllTaskData.Triggers
    $AllTaskData | Add-Member -NotePropertyName "Triggers_StartBoundary" -NotePropertyValue $Triggers.StartBoundary -Force
    $AllTaskData | Add-Member -NotePropertyName "Triggers_EndBoundary" -NotePropertyValue $Triggers.EndBoundary -Force
    $AllTaskData | Add-Member -NotePropertyName "Triggers_Enabled" -NotePropertyValue $Triggers.Enabled -Force
    $AllTaskData | Add-Member -NotePropertyName "Triggers_DaysOfWeek" -NotePropertyValue $Triggers.DaysOfWeek -Force
    
    $Actions = $AllTaskData.Actions
    $AllTaskData | Add-Member -NotePropertyName "Actions_Execute" -NotePropertyValue $Actions.Execute -Force
    $AllTaskData | Add-Member -NotePropertyName "Actions_Arguments" -NotePropertyValue $Actions.Arguments -Force
    
    # Merge properties from $DetailsTaskData into $AllTaskData
    foreach ($prop in $DetailsTaskData.PSObject.Properties) {
        $pname = "General_{0}" -f $prop.Name.Replace(' ','')
        $AllTaskData | Add-Member -NotePropertyName $pname -NotePropertyValue $prop.Value -Force
    }

    return $AllTaskData
}
