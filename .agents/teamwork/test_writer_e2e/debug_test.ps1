$s = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$url = 'http://localhost:8188/Default.aspx'
$r0 = Invoke-WebRequest -Uri $url -WebSession $s -UseBasicParsing
$vs = [regex]::Match($r0.Content, 'id="__VIEWSTATE"\s+value="([^"]*)"').Groups[1].Value
$res = Invoke-WebRequest -Uri $url -Method Post -Body @{'__VIEWSTATE'=$vs; 'btnSearch'='Search'; 'txtFirstName'='Rahul'} -WebSession $s -UseBasicParsing
$matches = [regex]::Matches($res.Content, '<div class="profile-name">([^<]+)</div>')
Write-Host "Match count: $($matches.Count)"
foreach ($m in $matches) {
    Write-Host "Item: [$($m.Groups[1].Value)]"
}
