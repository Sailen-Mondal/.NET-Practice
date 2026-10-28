$res = Invoke-WebRequest -Uri "http://localhost:8188/Default.aspx" -UseBasicParsing
$html = $res.Content

# Find all Crystal Report viewer related elements and buttons
$crvMatches = [regex]::Matches($html, 'id="[^"]*CrystalReportViewer1[^"]*"')
Write-Host "Found $($crvMatches.Count) viewer ID references."

# Check for navigation or postback buttons in viewer
$buttons = [regex]::Matches($html, '<input[^>]+type="image"[^>]*>')
Write-Host "Image buttons count: $($buttons.Count)"
foreach ($b in $buttons) {
    Write-Host "Button: $($b.Value)"
}

# Check viewer state hidden fields
$hidden = [regex]::Matches($html, '<input[^>]+type="hidden"[^>]+name="([^"]*CrystalReportViewer[^"]*)"[^>]*value="([^"]*)"')
foreach ($h in $hidden) {
    Write-Host "Hidden field: $($h.Groups[1].Value) = $($h.Groups[2].Value)"
}

# Check for __doPostBack targets
$scripts = [regex]::Matches($html, '__doPostBack\([^)]+\)')
Write-Host "doPostBack occurrences: $($scripts.Count)"
foreach ($s in ($scripts | Select-Object -First 10)) {
    Write-Host "Postback: $($s.Value)"
}
