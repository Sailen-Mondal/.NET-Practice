$res = Invoke-WebRequest -Uri "http://localhost:8188/Default.aspx" -UseBasicParsing
$html = $res.Content
Write-Host "Length: $($html.Length)"
$matches = [regex]::Matches($html, '<div class=[^>]+>')
foreach ($m in $matches) {
    if ($m.Value -match "profile") {
        Write-Host "DIV MATCH: $($m.Value)"
    }
}
$cardsDbl = [regex]::Matches($html, '<div class="profile-card">').Count
$cardsSgl = [regex]::Matches($html, "<div class='profile-card'>").Count
Write-Host "Count with double quotes: $cardsDbl"
Write-Host "Count with single quotes: $cardsSgl"
