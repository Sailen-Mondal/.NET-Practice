$sess = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$r1 = Invoke-WebRequest -Uri 'http://localhost:9979/Account/Logout' -WebSession $sess -MaximumRedirection 0 -ErrorAction SilentlyContinue
Write-Output ("Logout Status: " + $r1.StatusCode)
Write-Output ("Location: " + $r1.Headers["Location"])

$r2 = Invoke-WebRequest -Uri ('http://localhost:9979' + $r1.Headers["Location"]) -WebSession $sess -UseBasicParsing
$foundInfo = $r2.Content -match 'alert-info'
$foundMsg = $r2.Content -match 'You have been logged out safely'
Write-Output ("Found alert-info: " + $foundInfo)
Write-Output ("Found msg text: " + $foundMsg)
Write-Output ("Cookies count: " + $sess.Cookies.Count)
foreach ($c in $sess.Cookies.GetCookies([Uri]'http://localhost:9979')) {
    Write-Output ("Cookie: " + $c.Name + " = " + $c.Value)
}
