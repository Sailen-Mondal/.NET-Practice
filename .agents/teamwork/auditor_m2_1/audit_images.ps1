$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$res = Invoke-WebRequest -Uri "http://localhost:8188/Default.aspx" -WebSession $session -UseBasicParsing
Write-Host "Initial Page Status: $($res.StatusCode)"

# Extract all CrystalImageHandler image URLs
$pattern = 'src=["''](CrystalImageHandler\.aspx\?[^"'']+)["'']'
$matches = [regex]::Matches($res.Content, $pattern)
Write-Host "Found $($matches.Count) CrystalImageHandler URLs"

$idx = 0
foreach ($m in $matches) {
    $idx++
    $imgUrl = "http://localhost:8188/" + $m.Groups[1].Value
    # decode HTML entities if any
    $imgUrl = [System.Web.HttpUtility]::HtmlDecode($imgUrl)
    Write-Host "[$idx] Fetching: $imgUrl"
    $imgRes = Invoke-WebRequest -Uri $imgUrl -WebSession $session -UseBasicParsing
    
    $magic = [System.BitConverter]::ToString($imgRes.Content[0..3])
    $isPng = ($magic -eq "89-50-4E-47")
    Write-Host "    Status: $($imgRes.StatusCode), Content-Type: $($imgRes.Headers['Content-Type']), Length: $($imgRes.Content.Length) bytes, Magic: $magic (IsPNG: $isPng)"
}
