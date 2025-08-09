




function New-PsModuleUpload {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $true, position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,
        [Parameter(Position = 1, Mandatory = $true)]
        [pscredential]$Credentials,
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$Path = "$ENV:Temp",
        [Parameter(Mandatory = $false)]
        [switch]$Publish,
        [Parameter(Mandatory = $false)]
        [switch]$Cleanup
    )
    try {
        $RepositoryName = "MiniPsRepo"
        $Me = "$ENV:USERNAME"
        $WhoamiCmd = Get-Command -Name "whoami.exe" -CommandType Application -ErrorAction Ignore
        if ($WhoamiCmd) {
            $Me = & "$WhoamiCmd"
        }

        $ModulePath = Join-Path "$Path" "$Name"

        New-Item -ItemType Directory -Path $ModulePath -Force | Out-Null

        $TmpContent = @"
function Get-{0} {{ "Hello from {0}Repo!" }}
Export-ModuleMember -Function Get-{0}  
"@ -f $Name

        $ModuleCodeFileName = "{0}.psm1" -f $Name
        $ManifestFileName = "{0}.psd1" -f $Name
        $ModuleCodeFilePath = Join-Path "$ModulePath" "$ModuleCodeFileName"
        $ManifestFilePath = Join-Path "$ModulePath" "$ManifestFileName"
        $TmpContent | Set-Content -Path $ModuleCodeFilePath


        Write-Verbose "Name                $Name"
        Write-Verbose "Path                $Path"
        Write-Verbose "ModulePath          $ModulePath"
        Write-Verbose "ModuleCodeFileName  $ModuleCodeFileName"
        Write-Verbose "ManifestFileName    $ManifestFileName"
        Write-Verbose "ModuleCodeFilePath  $ModuleCodeFilePath"
        Write-Verbose "ManifestFilePath    $ManifestFilePath"
        Write-Verbose "Repository          $RepositoryName"

        New-ModuleManifest -Path $ManifestFilePath -RootModule $ModuleCodeFileName -ModuleVersion '1.0.0' -Author "$Me" -Description 'Test module'

        Write-Host "Sanity Check" -f DarkCyan
        Write-Host "============`n`n" -f DarkGray
        $ManifestFileItem = Get-Item -Path "$ManifestFilePath" -ErrorAction Ignore
        $ModuleFileItem = Get-Item -Path "$ModuleCodeFilePath" -ErrorAction Ignore
        if ($ManifestFileItem) {
            Write-Host "✅ $ManifestFileName ($($ManifestFileItem.Length) bytes)"
            Write-Verbose "========================================"
            Write-Verbose "content of $ManifestFilePath"
            $cnt = Get-Content -Path $ManifestFilePath | Out-String
            Write-Verbose "========================================`n$cnt`n`n========================================`n`n"
        } else {
            Write-ERror "Missing `"$ManifestFilePath`""
        }
        if ($ModuleFileItem) {
            Write-Host "✅ $ModuleCodeFileName ($($ModuleFileItem.Length) bytes)"
            Write-Verbose "========================================"
            Write-Verbose "content of $ModuleCodeFilePath"
            $cnt = Get-Content -Path $ModuleCodeFilePath | Out-String
            Write-Verbose "========================================`n$cnt`n`n========================================`n`n"
            
            Write-Verbose ""
        } else {
            Write-ERror "Missing `"$ModuleCodeFilePath`""
        }

        if ($Publish) {
            # Publish to your Samba repo
            Publish-Module -Path $ModulePath -Credential $Credentials -Repository "$RepositoryName" -Verbose
        }

        if ($Cleanup) {
            Remove-Item -Path "$ManifestFilePath" -ErrorAction Ignore -Force | Out-String
            Remove-Item -Path "$ModuleCodeFilePath" -ErrorAction Ignore -Force | Out-String
            Remove-Item -Path "$ModulePath" -ErrorAction Ignore -Force | Out-String
        }


        $RevVal = $True

    } catch {
        Write-Warning "$_"
        $RevVal = $False
    }
    return $RevVal
}


function Test-NewPsModuleUpload {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    try {
    
[string]$userName = 'gp'
[string]$userPassword = 'secret'

# Convert to SecureString
[securestring]$secStringPassword = ConvertTo-SecureString $userPassword -AsPlainText -Force
[pscredential]$credObject = New-Object System.Management.Automation.PSCredential ($userName, $secStringPassword)


$ModuleName = "HelloMini"
Test-NewPsModuleUpload -Name $ModuleName -Credentials $credObject -Publish:$Publish -Cleanup:$Cleanup

    } catch {
        Write-Error "$_"
    }
}

