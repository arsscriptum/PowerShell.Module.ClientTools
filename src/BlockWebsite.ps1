#╔════════════════════════════════════════════════════════════════════════════════╗
#║                                                                                ║
#║   BlockWebsite.ps1                                                             ║
#║                                                                                ║
#╟────────────────────────────────────────────────────────────────────────────────╢
#║   Guillaume Plante <codegp@icloud.com>                                         ║
#║   Code licensed under the GNU GPL v3.0. See the LICENSE file for details.      ║
#╚════════════════════════════════════════════════════════════════════════════════╝



function Block-BraveWebsite {
    param(
        [Parameter(Mandatory = $true)]
        [string]$WebsiteUrl
    )

    # Ensure the script is running as Administrator
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
        Write-Host "This script needs to run as Administrator!" -ForegroundColor Red
        return
    }

    $bravePolicyKey = "HKLM:\Software\Policies\BraveSoftware\Brave\URLBlocklist"

    # Create the registry path if it doesn't exist
    if (-not (Test-Path $bravePolicyKey)) {
        New-Item -Path "HKLM:\Software\Policies\BraveSoftware\Brave" -Name "URLBlocklist" | Out-Null
    }

    # Add the website to the block list
    try {
        $existingBlocklist = Get-ItemProperty -Path $bravePolicyKey | Select-Object -ExpandProperty "*"
        if ($existingBlocklist -notcontains $WebsiteUrl) {
            New-ItemProperty -Path $bravePolicyKey -Name ($existingBlocklist.Length) -Value $WebsiteUrl -PropertyType String | Out-Null
            Write-Host "Website $WebsiteUrl has been blocked successfully in Brave." -ForegroundColor Green
        } else {
            Write-Host "The website $WebsiteUrl is already blocked." -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "Failed to block the website. Error: $_" -ForegroundColor Red
    }
}
