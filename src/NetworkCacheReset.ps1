

function Clear-ChromeCache {
    [CmdletBinding(SupportsShouldProcess)]
    param()

    Write-Host "🧹 Clearing Chrome DNS and cache..." -ForegroundColor Cyan
    $chromeCache = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache"
    if (Test-Path $chromeCache) {
        try {
            Remove-Item "$chromeCache\*" -Recurse -Force -ErrorAction Stop
            Write-Host "✅ Chrome cache cleared."
        } catch {
            Write-Warning "Could not clear Chrome cache: $_"
        }
    } else {
        Write-Host "ℹ️ Chrome cache path not found."
    }
}

function Invoke-FlushDNS {
    [CmdletBinding(SupportsShouldProcess)]
    param()

    Write-Host "🔄 Flushing DNS cache..." -ForegroundColor Cyan
    ipconfig /flushdns | Out-Null
    Write-Host "✅ DNS cache flushed."
}

function Reset-Netstack {
    [CmdletBinding(SupportsShouldProcess)]
    param()

    Write-Host "🧰 Resetting Winsock and IP stack..." -ForegroundColor Cyan
    netsh winsock reset | Out-Null
    netsh int ip reset | Out-Null
    Write-Host "✅ Network stack reset complete."
}

function Invoke-NetworkCacheReset {
    [CmdletBinding(SupportsShouldProcess)]
    param()

    Write-Host "`n🚀 Running full cleanup and fix for Desjardins access..." -ForegroundColor Yellow
    Invoke-FlushDNS
    Clear-ChromeCache
    Reset-Netstack
    Write-Host "`n✅ All done. Try logging in again." -ForegroundColor Green

}

