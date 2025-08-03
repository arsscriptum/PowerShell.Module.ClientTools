#╔════════════════════════════════════════════════════════════════════════════════╗
#║                                                                                ║
#║   ExportSystemInfo.ps1                                                         ║
#║                                                                                ║
#╟────────────────────────────────────────────────────────────────────────────────╢
#║   Guillaume Plante <codegp@icloud.com>                                         ║
#║   Code licensed under the GNU GPL v3.0. See the LICENSE file for details.      ║
#╚════════════════════════════════════════════════════════════════════════════════╝






function Export-SystemInfo {
    param(
        [string]$OutputFile = "SystemInfo.txt",
        [switch]$Json,
        [switch]$Csv,
        [switch]$Disk,
        [switch]$Stdout
    )

    # Collect basic system hardware information
    $systemInfo = @{
        CPU = (Get-CimInstance Win32_Processor | Select-Object Name, NumberOfCores, MaxClockSpeed)
        Memory = (Get-CimInstance Win32_PhysicalMemory | Select-Object Capacity, Manufacturer, Speed)
        DiskDrives = (Get-CimInstance Win32_DiskDrive | Select-Object Model, Size, MediaType)
        Network = (Get-CimInstance Win32_NetworkAdapter | Where-Object { $_.NetEnabled -eq $true } | Select-Object Name, MACAddress, Speed)
        BIOS = (Get-CimInstance Win32_BIOS | Select-Object Manufacturer, Version, SerialNumber)
        OS = (Get-CimInstance Win32_OperatingSystem | Select-Object Caption, OSArchitecture, Version, BuildNumber)
        VideoCard = (Get-CimInstance Win32_VideoController | Select-Object Name, DriverVersion, VideoProcessor, AdapterRAM)
    }

    # Add advanced disk details if -disk switch is used
    if ($Disk) {
        $systemInfo.DiskDrives = Get-CimInstance Win32_DiskDrive | Select-Object Model, Size, MediaType, SerialNumber, FirmwareRevision, InterfaceType
    }

    # Handle stdout output with color formatting
    if ($Stdout) {
        foreach ($key in $systemInfo.Keys) {
            Write-Host "$key`:" -ForegroundColor DarkRed
            foreach ($item in $systemInfo[$key]) {
                foreach ($property in $item.PSObject.Properties) {
                    Write-Host "    $($property.Name):" -ForegroundColor DarkYellow -NoNewline
                    Write-Host " $($property.Value)" -ForegroundColor DarkCyan
                }
            }
        }
        return
    }

    # Handle output format
    if ($Json) {
        # Convert to JSON and export to file
        $systemInfo | ConvertTo-Json -Depth 3 | Out-File -FilePath $OutputFile
        Write-Host "System information exported as JSON to $OutputFile"
    }
    elseif ($Csv) {
        # Convert to CSV and export to file
        $csvData = foreach ($key in $systemInfo.Keys) {
            $systemInfo[$key] | Select-Object -Property * | Export-Csv -NoTypeInformation -Append -Path $OutputFile
        }
        Write-Host "System information exported as CSV to $OutputFile"
    }
    else {
        # Default to plain text
        $systemInfo | Out-File -FilePath $OutputFile
        Write-Host "System information exported as plain text to $OutputFile"
    }
}

# Example usage:
# Export-SystemInfo -json -OutputFile "SystemInfo.json"
# Export-SystemInfo -csv -OutputFile "SystemInfo.csv"
# Export-SystemInfo -disk -OutputFile "SystemInfoDisk.txt"
# Export-SystemInfo -stdout

