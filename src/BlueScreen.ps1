
<#
#̷𝓍   𝓖𝓾𝓲𝓵𝓵𝓪𝓾𝓶𝓮 𝓟𝓵𝓪𝓷𝓽𝓮
#̷𝓍   𝓛𝓾𝓶𝓲𝓷𝓪𝓽𝓸𝓻 𝓣𝓮𝓬𝓱𝓷𝓸𝓵𝓸𝓰𝔂 𝓖𝓻𝓸𝓾𝓹
#̷𝓍   𝚐𝚞𝚒𝚕𝚕𝚊𝚞𝚖𝚎.𝚙𝚕𝚊𝚗𝚝𝚎@𝚕𝚞𝚖𝚒𝚗𝚊𝚝𝚘𝚛.𝚌𝚘𝚖
#>


function Show-BlueScreen {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $false)]
        [switch]$Red
    )
    Register-Assemblies
    # ====================================================================================
    # ====================================================================================
    $BlueColor = [System.Drawing.Color]::FromArgb(17, 114, 169)
    $RedColor = [System.Drawing.Color]::FromArgb(225, 25, 25)

    $SsBackColor = $BlueColor
    if ($Red) {
        $SsBackColor = $RedColor
    }

    $SsFont1 = "Segoe Script"
    $SsFont2 = "Cascadia Code SemiBold"
    $SsFont3 = "Ink Free"
    $SsFont4 = "Fixedsys"
    $SsFont5 = "Terminal"
    $SsFont6 = "Segoe UI"

    $SmileyFont = $SsFont6
    $GeneralFont = $SsFont6
    $SpecificFont = $SsFont6
    # ====================================================================================
    # ====================================================================================

    $screen = [System.Windows.Forms.Screen]::PrimaryScreen

    $screenSaver = New-Object System.Windows.Forms.Form
    $screenSaver.Bounds = $screen.Bounds

    $screenSaver.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::None

    $screenSaver.add_Load({
            [System.Windows.Forms.Cursor]::Hide()
            $this.TopMost = $true
        })

    $screenSaver.add_MouseClick({
            [System.Windows.Forms.Application]::Exit()
        })
    $screenSaver.add_KeyPress({
            [System.Windows.Forms.Application]::Exit()
        })

    $smiley = New-Object System.Windows.Forms.Label
    $general = New-Object System.Windows.Forms.Label
    $specific = New-Object System.Windows.Forms.Label

    $smiley.Text = ":("
    $general.Text = "Your PC ran into a problem that it couldn't handle, and now it needs to restart."
    $specific.Text = "You can search for the error online: HAL_INITIALIZATION_FAILED"

    $general.AutoSize = $false
    $specific.AutoSize = $false

    $screenSaver.BackColor = $SsBackColor
    $screenSaver.TopMost = $true

    $smiley.ForeColor = [System.Drawing.Color]::White
    $general.ForeColor = [System.Drawing.Color]::White
    $specific.ForeColor = [System.Drawing.Color]::White

    $smiley.Font = New-Object System.Drawing.Font -ArgumentList "$SmileyFont", 100
    $general.Font = New-Object System.Drawing.Font -ArgumentList "$GeneralFont", 22
    $specific.Font = New-Object System.Drawing.Font -ArgumentList "$SpecificFont", 15

    $Bounds = $screenSaver.Bounds

    $smiley.Size = New-Object System.Drawing.Size -ArgumentList ($Bounds.Right - $Bounds.Left), (($Bounds.Bottom - $Bounds.Top) / 6)
    $smiley.Location = new-object System.Drawing.Point -ArgumentList (($Bounds.Right - $Bounds.Left) / 4), (($Bounds.Bottom - $Bounds.Top) / 3)

    $general.Size = new-object System.Drawing.Size -ArgumentList (($Bounds.Right - $Bounds.Left) / 2), (($Bounds.Bottom - $Bounds.Top) / 8)
    $general.Location = New-Object System.Drawing.Point -ArgumentList (($Bounds.Right - $Bounds.Left) / 4), ($smiley.Location.Y + ($Bounds.Bottom - $Bounds.Top) / 6)

    $specific.Size = new-object System.Drawing.Size -ArgumentList (($Bounds.Right - $Bounds.Left) / 2), (($Bounds.Bottom - $Bounds.Top) / 6)
    $specific.Location = new-object System.Drawing.Point -ArgumentList (($Bounds.Right - $Bounds.Left) / 4), ($general.Location.Y + ($Bounds.Bottom - $Bounds.Top) / 8)

    $screenSaver.Controls.Add($smiley);
    $screenSaver.Controls.Add($general);
    $screenSaver.Controls.Add($specific);

    $screenSaver.ShowDialog()

}
