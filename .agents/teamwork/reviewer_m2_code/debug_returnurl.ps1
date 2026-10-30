Add-Type -AssemblyName System.Net.Http

$cookies = [System.Net.CookieContainer]::new()
$handler = [System.Net.Http.HttpClientHandler]::new()
$handler.CookieContainer = $cookies
$handler.AllowAutoRedirect = $false
$client = [System.Net.Http.HttpClient]::new($handler)

$getResp = $client.GetAsync('http://localhost:9979/Account/Login?returnUrl=https://evil.com').Result
$html = $getResp.Content.ReadAsStringAsync().Result
$m = [regex]::Match($html, '__RequestVerificationToken.*?value="([^"]+)"')
if (-not $m.Success) { $m = [regex]::Match($html, 'value="([^"]+)".*?__RequestVerificationToken') }
$token = $m.Groups[1].Value
Write-Host "Extracted token: $token"

$dict = [System.Collections.Generic.Dictionary[string,string]]::new()
$dict['__RequestVerificationToken'] = $token
$dict['UsernameOrEmail'] = 'admin'
$dict['Password'] = 'Admin@123'
$dict['ReturnUrl'] = 'https://evil.com'
$content = [System.Net.Http.FormUrlEncodedContent]::new($dict)

$postResp = $client.PostAsync('http://localhost:9979/Account/Login?ReturnUrl=https%3A%2F%2Fevil.com', $content).Result
Write-Host "Status: $([int]$postResp.StatusCode)"
Write-Host "Redirect Location: $($postResp.Headers.Location)"
$body = $postResp.Content.ReadAsStringAsync().Result
$lines = $body -split "`n"
$lines | Where-Object { $_ -match "Exception" -or $_ -match "Error" } | Select-Object -First 10 | ForEach-Object { Write-Host "Line: $($_.Trim())" }
