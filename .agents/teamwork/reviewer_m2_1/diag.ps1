$html = (Invoke-WebRequest -Uri "http://localhost:8188/Default.aspx" -UseBasicParsing).Content

Write-Host "Total length: $($html.Length)"

$matchDbl = [regex]::Matches($html, '<div class="profile-card">')
Write-Host "Matches with double quotes: $($matchDbl.Count)"

$matchSgl = [regex]::Matches($html, "<div class='profile-card'>")
Write-Host "Matches with single quotes: $($matchSgl.Count)"

$matchAny = [regex]::Matches($html, 'profile-card')
Write-Host "Matches with profile-card: $($matchAny.Count)"

$lines = $html -split "`n" | Where-Object { $_ -match "profile-card" }
foreach ($line in $lines) {
    Write-Host "Line: $line"
}
