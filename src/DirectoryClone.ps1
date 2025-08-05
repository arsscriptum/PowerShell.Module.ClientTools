#╔════════════════════════════════════════════════════════════════════════════════╗
#║                                                                                ║
#║   DirectorySize.ps1                                                               ║
#║                                                                                ║
#╟────────────────────────────────────────────────────────────────────────────────╢
#║   Guillaume Plante <codegp@icloud.com>                                         ║
#║   Code licensed under the GNU GPL v3.0. See the LICENSE file for details.      ║
#╚════════════════════════════════════════════════════════════════════════════════╝


function Copy-FilteredUserProfile {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateScript({ Test-Path $_ })]
        [string]$SourceDir,
        [Parameter(Mandatory = $true)]
        [string]$DestinationDir,
        [Parameter(Mandatory = $true)]
        [string]$Username,
        [Parameter(Mandatory = $False)]
        [switch]$DryRun
    )

    [uint32]$FileCount = 0
    [uint32]$DirectoryCount = 0
    [uint32]$FileExcluded = 0
    [uint32]$DirectoryExcluded = 0
    # Check admin rights
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Error "This function must be run as Administrator."
        return
    }

    # Filters
    [System.Collections.ArrayList]$DirectoryFiltersList = [System.Collections.ArrayList]::new()
    [void]$DirectoryFiltersList.AddRange(@("AppData","Saved Games", ".git", "temp", "Downloads", "Games", "Searches", "Contacts"))

    [System.Collections.ArrayList]$FilenameFiltersList = [System.Collections.ArrayList]::new()
    [void]$FilenameFiltersList.AddRange(@("test.ps1", ".gitconfig"))

    # Ensure destination exists
    New-Item -Path $DestinationDir -ItemType Directory -Force | Out-Null

    # Normalize filter sets to HashSets (faster)
    $DirFiltersSet = [System.Collections.Generic.HashSet[string]]::new([string[]]$DirectoryFiltersList)
    $FileFiltersSet = [System.Collections.Generic.HashSet[string]]::new([string[]]$FilenameFiltersList)
    $stopwatch_total = [System.Diagnostics.Stopwatch]::new()
    $stopwatch_total.Start()
    $stopwatch = [System.Diagnostics.Stopwatch]::new()
    $stopwatch.Start()
    # Copy items
    Get-ChildItem -Path $SourceDir -Recurse -Force | ForEach-Object {
        $RelativePath = $_.FullName.Substring($SourceDir.Length).TrimStart('\')
        $DestPath = Join-Path $DestinationDir $RelativePath

        if ($_.PSIsContainer) {
            if ($DirFiltersSet.Contains($_.Name)) {
                Write-Verbose "Skipping directory $($_.FullName)"
                $DirectoryExcluded++
                return
            }

            # Create directory
            if ($DryRun) {
                Write-Host "[Dry Run] Create Directory `"$DestPath`"" -f DarkCyan
                $DirectoryCount++
            } else {
                Write-Host "[ Clone ] Create Directory `"$DestPath`"" -f DarkYellow
                $DirRes = New-Item -ItemType Directory -Path $DestPath -Force -ErrorAction Stop
                $DirectoryCount++
            }

        }
        else {
            if ($FileFiltersSet.Contains($_.Name)) {
                Write-Verbose "Skipping file $($_.FullName)"
                $FileExcluded++
                return
            }

            $ParentDest = Split-Path $DestPath -Parent
            if (-not (Test-Path $ParentDest)) {

                if ($DryRun) {
                    Write-Host "[Dry Run] Create Directory `"$ParentDest`"" -f DarkCyan
                    $DirectoryCount++
                } else {
                    Write-Host "[ Clone ] Create Directory `"$ParentDest`"" -f DarkYellow
                    $DirRes = New-Item -ItemType Directory -Path $ParentDest -Force -ErrorAction Stop
                    $DirectoryCount++
                }
            }

            if ($DryRun) {
                Write-Host "[Dry Run] File Copy `"$($_.FullName)`" --> `"$DestPath`"" -f DarkCyan
                $FileCount++
            } else {
                Write-Host "[ Clone ] File Copy `"$($_.FullName)`" --> `"$DestPath`"" -f DarkYellow
                $CopyRes = Copy-Item -Path $_.FullName -Destination $DestPath -Force -ErrorAction Stop
                $FileCount++
            }

        }
    }

    $CopySecElapsed = [math]::Round($stopwatch.Elapsed.TotalSeconds, 2)

    $stopwatch.Reset(); $stopwatch.Start()

    if ($DryRun) {
        Write-Host "[Dry Run] icacls `$DestinationDir /grant `"`$Username:(OI)(CI)F`" /T /C" -f Blue
        Write-Host "[Dry Run] takeown /f `$DestinationDir /r /d y" -f Blue
    } else {

        # Take ownership and give full control to user
        Write-Host "Setting ownership and permissions for '$Username' on '$DestinationDir'" -ForegroundColor Cyan
        $icaclsexe = (get-command -Name "icacls.exe" -CommandType Application).Source
        $takeownexe = (get-command -Name "takeown.exe" -CommandType Application).Source

        Write-Host "Running icacls.exe for $DestinationDir" -ForegroundColor Cyan

        $outfile_std = (New-TemporaryFile).FullName
        $outfile_err = (New-TemporaryFile).FullName
        $UserRightsArg = '{0}:(OI)(CI)F' -f $Username
        $cmdres = Start-Process -FilePath "$icaclsexe" -ArgumentList "$DestinationDir", "/grant", "$UserRightsArg", "/T", "/C" -NoNewWindow -Wait -Passthru -RedirectStandardError $outfile_err -RedirectStandardOutput $outfile_std
        $ecode = $cmdres.ExitCode
        $pcpu = $cmdres.CPU -as [string]
        if ($ecode -eq 0) {
            Write-Host "SUCCESS after $pcpu" -f DarkGreen
            $StdOutStrings = Get-Content -Path "$outfile_std" -Raw
            Write-Host "$StdOutStrings" -f DarkYellow
        } else {
            Write-Host "FAILED. Returned `"$errmsg`"" -f DarkRed
            $ErrStrings = Get-Content -Path "$outfile_err" -Raw
            Write-Host "$ErrStrings" -f DarkYellow
        }
        $outfile_std = (New-TemporaryFile).FullName
        $outfile_err = (New-TemporaryFile).FullName

        write-Host "Running takeown.exe for $DestinationDir" -ForegroundColor Cyan
        $cmdres = Start-Process -FilePath "$takeownexe" -ArgumentList "/f", "$DestinationDir", "/r", "/d", "y" -NoNewWindow -Wait -Passthru -RedirectStandardError $outfile_err -RedirectStandardOutput $outfile_std
        $ecode = $cmdres.ExitCode
        $pcpu = $cmdres.CPU -as [string]
        if ($ecode -eq 0) {
            Write-Host "SUCCESS after $pcpu" -f DarkGreen
            $StdOutStrings = Get-Content -Path "$outfile_std" -Raw
            Write-Host "$StdOutStrings" -f DarkYellow
        } else {
            Write-Host "FAILED. Returned `"$errmsg`"" -f DarkRed
            $ErrStrings = Get-Content -Path "$outfile_err" -Raw
            Write-Host "$ErrStrings" -f DarkYellow
        }

    }

    $TotalSecElapsed = [math]::Round($stopwatch_total.Elapsed.TotalSeconds, 2)
    $IaclsSecElapsed = [math]::Round($stopwatch.Elapsed.TotalSeconds, 2)

    if ($DryRun) {
        Write-Host "✅ DRYRUN - Simulating copy to $DestinationDir with ownership set to $Username." -ForegroundColor Blue
        Write-Host "  Would have created $DirectoryCount directories. $DirectoryExcluded files were excluded as per filter list."
        Write-Host "  Would have copied $FileCount files. $FileExcluded files were excluded as per filter list."

    } else {
        Write-Host "✅ Profile copied to $DestinationDir with ownership set to $Username." -ForegroundColor Green
        Write-Host " created $DirectoryCount directories. $DirectoryExcluded files were excluded as per filter list."
        Write-Host "  copied $FileCount files. $FileExcluded files were excluded as per filter list."
        Write-Host " $TotalSecElapsed seconds elapsed in total. Copy $CopySecElapsed secs and iacls/takeown $IaclsSecElapsed secs"
    }
}


function Invoke-UserHomeClone {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $False)]
        [switch]$DryRun
    )


    Copy-FilteredUserProfile -SourceDir "C:\Users\radic" -DestinationDir "C:\Users\guillaume" -Username "guillaume" -DryRun:$DryRun
}

