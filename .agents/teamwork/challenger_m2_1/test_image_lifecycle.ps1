$url = "http://localhost:8188/Default.aspx"
$s = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$res = Invoke-WebRequest -Uri $url -WebSession $s -UseBasicParsing

$matches = [regex]::Matches($res.Content, 'CrystalImageHandler\.aspx\?dynamicimage=([^"''\s<>]+)')
Write-Host "Found $($matches.Count) images"
$imgRelUrl = $matches[0].Value
$imgFullUrl = "http://localhost:8188/$imgRelUrl"
Write-Host "Testing Image URL: $imgFullUrl"

# First request with session:
$r1 = Invoke-WebRequest -Uri $imgFullUrl -WebSession $s -UseBasicParsing
Write-Host "Request 1 (with session): StatusCode = $($r1.StatusCode), Bytes = $($r1.Content.Length)"

# Second request to SAME URL with session:
try {
    $r2 = Invoke-WebRequest -Uri $imgFullUrl -WebSession $s -UseBasicParsing
    Write-Host "Request 2 (same URL with session): StatusCode = $($r2.StatusCode)"
} catch {
    Write-Host "Request 2 (same URL with session) FAILED: $($_.Exception.Message)"
}

# Third request with fresh session:
try {
    $s2 = New-Object Microsoft.PowerShell.Commands.WebRequestSession
    $r3 = Invoke-WebRequest -Uri $imgFullUrl -WebSession $s2 -UseBasicParsing
    Write-Host "Request 3 (new session): StatusCode = $($r3.StatusCode)"
} catch {
    Write-Host "Request 3 (new session) FAILED: $($_.Exception.Message)"
}
