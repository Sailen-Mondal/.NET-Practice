$r = Invoke-WebRequest -Uri "http://localhost:8188/Default.aspx" -UseBasicParsing
$m = [regex]::Matches($r.Content, '<div class=[^>]+profile-card[^>]*>')
foreach ($match in $m) {
    Write-Host "Match: $($match.Value)"
}
