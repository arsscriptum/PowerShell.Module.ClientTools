#╔════════════════════════════════════════════════════════════════════════════════╗
#║                                                                                ║
#║   RemoteDesktop.ps1                                                            ║
#║                                                                                ║
#╟────────────────────────────────────────────────────────────────────────────────╢
#║   Guillaume Plante <codegp@icloud.com>                                         ║
#║   Code licensed under the GNU GPL v3.0. See the LICENSE file for details.      ║
#╚════════════════════════════════════════════════════════════════════════════════╝



function Enable-RemoteDesktop {
    # Enable Remote Desktop by modifying the registry key
    Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value 0

    # Allow Remote Desktop through the Windows Firewall
    Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

    # Get the current status of Network Level Authentication (optional)
    $nlaStatus = Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name "UserAuthentication"

    # Enable Network Level Authentication for additional security (recommended)
    if ($nlaStatus.UserAuthentication -ne 1) {
        Write-Host "Enabling Network Level Authentication for additional security..."
        Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name "UserAuthentication" -Value 1
    }

    Write-Host "Remote Desktop has been enabled and allowed through the firewall."
    Write-Host "Ensure your user account has permission to connect remotely."
}

# Example usage:
# Enable-RemoteDesktop
