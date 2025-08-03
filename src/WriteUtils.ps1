
function Write-ConsoleExtended {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $True, Position = 0, HelpMessage = "Message to be printed")]
        [Alias('m')]
        [string]$Message,
        [Parameter(Mandatory = $False, HelpMessage = "Cursor X position where message is to be printed")]
        [Alias('x')]
        [int]$PosX = -1,
        [Parameter(Mandatory = $False, HelpMessage = "Cursor Y position where message is to be printed")]
        [Alias('y')]
        [int]$PosY = -1,
        [Parameter(Mandatory = $False, HelpMessage = "Foreground color for the message")]
        [Alias('f')]
        [System.ConsoleColor]$ForegroundColor = [System.Console]::ForegroundColor,
        [Parameter(Mandatory = $False, HelpMessage = "Background color for the message")]
        [Alias('b')]
        [System.ConsoleColor]$BackgroundColor = [System.Console]::BackgroundColor,
        [Parameter(Mandatory = $False, HelpMessage = "Clear whatever is typed on this line currently")]
        [Alias('c')]
        [switch]$Clear,
        [Parameter(Mandatory = $False, HelpMessage = "After printing the message, return the cursor back to its initial position.")]
        [Alias('n')]
        [switch]$NoNewline
    )
    try {
        $fg_color = [System.Console]::ForegroundColor
        $bg_color = [System.Console]::BackgroundColor
        $cursor_top = [System.Console]::get_CursorTop()
        $cursor_left = [System.Console]::get_CursorLeft()

        $new_cursor_x = $cursor_left
        if ($PosX -ge 0) { $new_cursor_x = $PosX }

        $new_cursor_y = $cursor_top
        if ($PosY -ge 0) { $new_cursor_y = $PosY }

        if ($Clear) {
            [int]$len = ([System.Console]::WindowWidth - 1)

            [string]$empty = [string]::new([char]32, $len)

            [System.Console]::SetCursorPosition(0, $new_cursor_y)
            [System.Console]::Write($empty)
        }
        [System.Console]::ForegroundColor = $ForegroundColor
        [System.Console]::BackgroundColor = $BackgroundColor

        [System.Console]::SetCursorPosition($new_cursor_x, $new_cursor_y)


        [System.Console]::Write($Message)
        if ($NoNewline) {
            [System.Console]::SetCursorPosition($cursor_left, $cursor_top)
        }


        [System.Console]::ForegroundColor = $fg_color
        [System.Console]::BackgroundColor = $bg_color
    } catch {
        throw $_
    }
}


function Show-Countdown {
    param(
        [int]$Seconds
    )
    try {
        # Constants
        $barLength = 30 # Progress bar length
        $startTime = Get-Date
        $endTime = $startTime.AddSeconds($Seconds)
        $LeftBorder = 2
        $LeftBorder1 = $LeftBorder + 1
        # Get initial cursor position
        $cursorX = 5
        $cursorX1 = 8
        $cursorX2 = 15
        $cursorY = [System.Console]::CursorTop
        $cursorY1 = $cursorY + 1
        $cursorY2 = $cursorY + 2
        # Display initial static text
        Write-ConsoleExtended -Message "Time Remaining: " -PosX (5 + $cursorX + ($LeftBorder - 1) + $barLength) -PosY $cursorY -NoNewline
        Write-ConsoleExtended -Message "[" -PosX ($cursorX + $LeftBorder) -PosY $cursorY -NoNewline
        Write-ConsoleExtended -Message "]" -PosX ($cursorX + $LeftBorder + $barLength) -PosY $cursorY -NoNewline

        # Loop to update progress bar
        for ($elapsed = 0; $elapsed -le $Seconds; $elapsed++) {
            $remaining = $Seconds - $elapsed

            # Determine progress and color
            $progress = [math]::Round(($elapsed / $Seconds) * $barLength)
            $bar = "█" * $progress + " " * ($barLength - $progress)

            # Choose color based on remaining time
            if ($remaining -gt 30) {
                $color = "Green"
            } elseif ($remaining -le 30 -and $remaining -gt 10) {
                $color = "DarkYellow"
            } else {
                $color = "DarkRed"
            }
            Write-ConsoleExtended -Message "TIMER [" -PosX ($cursorX + ($LeftBorder - 7)) -PosY $cursorY -NoNewline -Clear


            # Update countdown time


            # Update progress bar
            Write-ConsoleExtended -Message "$bar" -PosX ($cursorX + $LeftBorder) -PosY $cursorY -ForegroundColor $color -NoNewline
            Write-ConsoleExtended -Message "]" -PosX ($cursorX + $LeftBorder + $barLength) -PosY $cursorY -NoNewline
            Write-ConsoleExtended -Message "$remaining sec " -PosX (5 + $cursorX + $LeftBorder + $barLength) -PosY $cursorY -ForegroundColor $color -NoNewline
            # Sleep for 1 second
            Start-Sleep -Seconds 1
        }

        # Final message
        Write-ConsoleExtended -Message "Time's up!" -PosX $LeftBorder -PosY $cursorY -ForegroundColor DarkRed -Clear
    } catch {
        throw $_
    }
}
