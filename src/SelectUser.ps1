function Select-LoggedInUser {
    # Get logged-in users
    [string[]]$users = Get-LoggedInUsers

    # Ensure we have users to display
    if (-not $users) {
        Write-Host "No logged-in users found." -ForegroundColor Red
        return $null
    }

    # Display user list with numbering
    Write-Host "
Please select the userid:
"
    for ($i = 0; $i -lt $users.Count; $i++) {
        Write-Host "$($i + 1). $($users[$i])"
    }

    # Get user input
    $selection = $null
    do {
        $selection = Read-Host "
Answer (Enter a number between 1 and $($users.Count))"

        # Validate input
        if ($selection -match '^\d+$' -and [int]$selection -ge 1 -and [int]$selection -le $users.Count) {
            $selectedUser = $users[[int]$selection - 1]
            return $selectedUser
        } else {
            Write-Host "Invalid selection. Please enter a valid number." -ForegroundColor Red
        }
    } while ($true)
}
