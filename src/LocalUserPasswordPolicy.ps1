#╔════════════════════════════════════════════════════════════════════════════════╗
#║                                                                                ║
#║   LocalUserPasswordPolicy.ps1                                                  ║
#║   Get Details of Scheduled Tasks                                               ║
#║                                                                                ║
#╟────────────────────────────────────────────────────────────────────────────────╢
#║   Guillaume Plante <codegp@icloud.com>                                         ║
#║   Code licensed under the GNU GPL v3.0. See the LICENSE file for details.      ║
#╚════════════════════════════════════════════════════════════════════════════════╝


function Get-LoggedInUsers {
    [CmdletBinding(SupportsShouldProcess)]
    param()

    try {
        $PsLoggedonCmd = Get-Command "PsLoggedon64.exe" -CommandType Application -ErrorAction Ignore
        if ($PsLoggedonCmd -eq $Null) {
            $PsLoggedonExe = Find-Program "PsLoggedon64.exe" -PathOnly
            if ($PsLoggedonExe -eq $Null) {
                throw "`"PsLoggedon64.exe`" application not found!"
            }
        } else {
            $PsLoggedonExe = $PsLoggedonCmd.Path
        }

        [string[]]$rawusers = & "$PsLoggedonExe" '-l' '-x' '-nobanner'| select -Skip 1
        ForEach($rawusr in $rawusers){
             $fullusername = $rawusr.Trim()

        }
        [string[]]$Users = $Out | select -Skip 1 | foreach { $_.Trim() }
        $Users -as [string[]]
    } catch {
        write-error "$_"
    }



}


function Invoke-DisconnectLocalUser {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [Parameter(Mandatory = $true, HelpMessage = "Username of the local user")]
        [ValidateNotNullOrEmpty()]
        [string]$Username
    )
    try{
    $userptr = Get-LocalUser -Name $Username -ErrorAction Ignore
    if($userptr -eq $Null){
        throw "can't resolve user `"$Username`""
    }
    $user_enabled = $userptr.Enabled
    if($user_enabled -ne $True){
        throw "user `"$Username`" is not active"
    }


    Write-Verbose "Found user: $Username"
    if ($LogoffUser) {
        Write-Verbose "Searching for active sessions for $Username..."
        $sessions = query session 2>$null | ForEach-Object {
            $parts = ($_ -replace '\s{2,}', '|').Split('|')
            if ($parts.Count -ge 3) {
                [PSCustomObject]@{
                    SessionName = $parts[0].Trim()
                    Username    = $parts[1].Trim()
                    ID          = $parts[2].Trim()
                }
            }
        } | Where-Object { $_.Username -ieq $Username }

        foreach ($session in $sessions) {
            Write-Host "🔒 Logging off session ID $($session.ID) for user $Username"
            logoff $session.ID /V
        }

        if (-not $sessions) {
            Write-Host "ℹ️ No active sessions found for $Username"
        }
    }

    }catch{

    }
}


function Set-LocalUserPasswordPolicy {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [Parameter(Mandatory = $true, HelpMessage = "Username of the local user")]
        [ValidateNotNullOrEmpty()]
        [string]$Username,

        [Parameter(HelpMessage = "Force password change at next logon")]
        [bool]$ExpireAtNextLogon,

        [Parameter(HelpMessage = "Allow user to change password")]
        [bool]$UserCanChangePassword,

        [Parameter(HelpMessage = "Password never expires")]
        [bool]$PasswordNeverExpires,

        [Parameter(HelpMessage = "Informational expiration date (e.g., next month)")]
        [DateTime]$PasswordExpiresOn,

        [Parameter(HelpMessage = "Force logoff of all active sessions for the user")]
        [switch]$LogoffUser
    )

    $user = Get-LocalUser -Name $Username -ErrorAction Stop
    Write-Verbose "Found user: $Username"

    if ($PSBoundParameters.ContainsKey('ExpireAtNextLogon')) {
        Write-Verbose "Setting 'ExpireAtNextLogon' to $ExpireAtNextLogon"
        $option = if ($ExpireAtNextLogon) { "yes" } else { "no" }
        net user $Username /logonpasswordchg:$option | Out-Null
    }

    if ($PSBoundParameters.ContainsKey('PasswordNeverExpires')) {
        Write-Verbose "Setting 'PasswordNeverExpires' to $PasswordNeverExpires"
        $expires = if ($PasswordNeverExpires) { "FALSE" } else { "TRUE" }
        wmic useraccount where "name='$Username'" set PasswordExpires=$expires | Out-Null
    }

    if ($PSBoundParameters.ContainsKey('UserCanChangePassword')) {
        Write-Verbose "Setting 'UserCanChangePassword' to $UserCanChangePassword"
        $changeable = if ($UserCanChangePassword) { "TRUE" } else { "FALSE" }
        wmic useraccount where "name='$Username'" set PasswordChangeable=$changeable | Out-Null
    }

    if ($PSBoundParameters.ContainsKey('PasswordExpiresOn')) {
        Write-Warning "❗ 'PasswordExpiresOn' is informational only. Local accounts do not support setting exact expiration dates."
    }

    if ($LogoffUser) {
        Write-Verbose "Searching for active sessions for $Username..."
        $sessions = query session 2>$null | ForEach-Object {
            $parts = ($_ -replace '\s{2,}', '|').Split('|')
            if ($parts.Count -ge 3) {
                [PSCustomObject]@{
                    SessionName = $parts[0].Trim()
                    Username    = $parts[1].Trim()
                    ID          = $parts[2].Trim()
                }
            }
        } | Where-Object { $_.Username -ieq $Username }

        foreach ($session in $sessions) {
            Write-Host "🔒 Logging off session ID $($session.ID) for user $Username"
            logoff $session.ID /V
        }

        if (-not $sessions) {
            Write-Host "ℹ️ No active sessions found for $Username"
        }
    }

    Write-Host "✅ Password policy updated for user '$Username'"
}


function Test-SetLocalUserPasswordPolicyy {

    # Force user to change password on next login, allow password change, and make password expire monthly
    Set-LocalUserPasswordPolicy -Username "francine" -ExpireAtNextLogon $true -UserCanChangePassword $true -PasswordNeverExpires $false

    # Set password never expires and prevent user from changing it
    Set-LocalUserPasswordPolicy -Username "francine" -ExpireAtNextLogon $false -UserCanChangePassword $false -PasswordNeverExpires $true

    # Informational expiration date (e.g., next month)
    Set-LocalUserPasswordPolicy -Username "francine" -PasswordExpiresOn (Get-Date).AddMonths(1)

} 
