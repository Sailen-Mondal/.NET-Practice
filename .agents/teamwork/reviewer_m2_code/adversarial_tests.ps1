Add-Type -AssemblyName System.Net.Http
$ErrorActionPreference = "Stop"

Write-Host "=== ADVERSARIAL STRESS TEST SUITE (Reviewer 1) ==="
$passed = 0
$failed = 0

function Test-Case($name, $scriptBlock) {
    try {
        & $scriptBlock
        Write-Host "[PASS] $name" -ForegroundColor Green
        $global:passed++
    } catch {
        Write-Host "[FAIL] $name : $($_.Exception.Message)" -ForegroundColor Red
        $global:failed++
    }
}

# 1. Invalid Login Credentials
Test-Case "Login with invalid credentials returns 200 with error message" {
    $cookies = [System.Net.CookieContainer]::new()
    $handler = [System.Net.Http.HttpClientHandler]::new()
    $handler.CookieContainer = $cookies
    $handler.AllowAutoRedirect = $false
    $client = [System.Net.Http.HttpClient]::new($handler)

    $getResp = $client.GetAsync('http://localhost:9979/Account/Login').Result
    $html = $getResp.Content.ReadAsStringAsync().Result
    $m = [regex]::Match($html, '__RequestVerificationToken.*?value="([^"]+)"')
    if (-not $m.Success) { $m = [regex]::Match($html, 'value="([^"]+)".*?__RequestVerificationToken') }
    $token = $m.Groups[1].Value

    $dict = [System.Collections.Generic.Dictionary[string,string]]::new()
    $dict['__RequestVerificationToken'] = $token
    $dict['UsernameOrEmail'] = 'nonexistent_user'
    $dict['Password'] = 'WrongPassword999!'
    $content = [System.Net.Http.FormUrlEncodedContent]::new($dict)

    $postResp = $client.PostAsync('http://localhost:9979/Account/Login', $content).Result
    if ([int]$postResp.StatusCode -ne 200) { throw "Expected status 200, got $([int]$postResp.StatusCode)" }
    $postHtml = $postResp.Content.ReadAsStringAsync().Result
    if ($postHtml -notmatch "Invalid username/email or password") {
        throw "Missing error message 'Invalid username/email or password'"
    }
}

# 2. Open Redirect Prevention on Login
Test-Case "Login with external returnUrl does not redirect to external host" {
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

    $dict = [System.Collections.Generic.Dictionary[string,string]]::new()
    $dict['__RequestVerificationToken'] = $token
    $dict['UsernameOrEmail'] = 'admin'
    $dict['Password'] = 'Admin@123'
    $dict['ReturnUrl'] = 'https://evil.com'
    $content = [System.Net.Http.FormUrlEncodedContent]::new($dict)

    $postResp = $client.PostAsync('http://localhost:9979/Account/Login', $content).Result
    if ([int]$postResp.StatusCode -ne 302) { throw "Expected 302 redirect, got $([int]$postResp.StatusCode)" }
    $loc = $postResp.Headers.Location.ToString()
    if ($loc -match "evil\.com") { throw "VULNERABILITY: Redirected to external URL $loc" }
    if ($loc -notmatch "/Admin/Dashboard") { throw "Expected redirect to /Admin/Dashboard, got $loc" }
}

# 3. Registration with Password Mismatch
Test-Case "Register with password mismatch returns 200 with validation error" {
    $cookies = [System.Net.CookieContainer]::new()
    $handler = [System.Net.Http.HttpClientHandler]::new()
    $handler.CookieContainer = $cookies
    $handler.AllowAutoRedirect = $false
    $client = [System.Net.Http.HttpClient]::new($handler)

    $getResp = $client.GetAsync('http://localhost:9979/Account/Register').Result
    $html = $getResp.Content.ReadAsStringAsync().Result
    $m = [regex]::Match($html, '__RequestVerificationToken.*?value="([^"]+)"')
    if (-not $m.Success) { $m = [regex]::Match($html, 'value="([^"]+)".*?__RequestVerificationToken') }
    $token = $m.Groups[1].Value

    $dict = [System.Collections.Generic.Dictionary[string,string]]::new()
    $dict['__RequestVerificationToken'] = $token
    $dict['FullName'] = 'Priya Patel'
    $dict['Username'] = 'priya_patel'
    $dict['Email'] = 'priya.patel@example.com'
    $dict['Password'] = 'Password@123'
    $dict['ConfirmPassword'] = 'DifferentPassword@456'
    $content = [System.Net.Http.FormUrlEncodedContent]::new($dict)

    $postResp = $client.PostAsync('http://localhost:9979/Account/Register', $content).Result
    if ([int]$postResp.StatusCode -ne 200) { throw "Expected 200, got $([int]$postResp.StatusCode)" }
    $postHtml = $postResp.Content.ReadAsStringAsync().Result
    if ($postHtml -notmatch "Passwords do not match") {
        throw "Missing error message 'Passwords do not match'"
    }
}

# 4. Registration with Invalid Username Characters
Test-Case "Register with invalid username characters returns 200 with regex error" {
    $cookies = [System.Net.CookieContainer]::new()
    $handler = [System.Net.Http.HttpClientHandler]::new()
    $handler.CookieContainer = $cookies
    $handler.AllowAutoRedirect = $false
    $client = [System.Net.Http.HttpClient]::new($handler)

    $getResp = $client.GetAsync('http://localhost:9979/Account/Register').Result
    $html = $getResp.Content.ReadAsStringAsync().Result
    $m = [regex]::Match($html, '__RequestVerificationToken.*?value="([^"]+)"')
    if (-not $m.Success) { $m = [regex]::Match($html, 'value="([^"]+)".*?__RequestVerificationToken') }
    $token = $m.Groups[1].Value

    $dict = [System.Collections.Generic.Dictionary[string,string]]::new()
    $dict['__RequestVerificationToken'] = $token
    $dict['FullName'] = 'Test User'
    $dict['Username'] = 'user!@#$%'
    $dict['Email'] = 'test.user@example.com'
    $dict['Password'] = 'Password@123'
    $dict['ConfirmPassword'] = 'Password@123'
    $content = [System.Net.Http.FormUrlEncodedContent]::new($dict)

    $postResp = $client.PostAsync('http://localhost:9979/Account/Register', $content).Result
    if ([int]$postResp.StatusCode -ne 200) { throw "Expected 200, got $([int]$postResp.StatusCode)" }
    $postHtml = $postResp.Content.ReadAsStringAsync().Result
    if ($postHtml -notmatch "Username can only contain letters, numbers, and underscores") {
        throw "Missing regex error message"
    }
}

# 5. Non-Admin Access to Admin Dashboard
Test-Case "Standard user accessing Admin/Dashboard is redirected with error" {
    $cookies = [System.Net.CookieContainer]::new()
    $handler = [System.Net.Http.HttpClientHandler]::new()
    $handler.CookieContainer = $cookies
    $handler.AllowAutoRedirect = $false
    $client = [System.Net.Http.HttpClient]::new($handler)

    # Login as rahul (standard user)
    $getResp = $client.GetAsync('http://localhost:9979/Account/Login').Result
    $html = $getResp.Content.ReadAsStringAsync().Result
    $m = [regex]::Match($html, '__RequestVerificationToken.*?value="([^"]+)"')
    if (-not $m.Success) { $m = [regex]::Match($html, 'value="([^"]+)".*?__RequestVerificationToken') }
    $token = $m.Groups[1].Value

    $dict = [System.Collections.Generic.Dictionary[string,string]]::new()
    $dict['__RequestVerificationToken'] = $token
    $dict['UsernameOrEmail'] = 'rahul'
    $dict['Password'] = 'User@123'
    $content = [System.Net.Http.FormUrlEncodedContent]::new($dict)
    $loginResp = $client.PostAsync('http://localhost:9979/Account/Login', $content).Result
    if ([int]$loginResp.StatusCode -ne 302) { throw "Login failed" }

    # Attempt to access Admin/Dashboard
    $dashResp = $client.GetAsync('http://localhost:9979/Admin/Dashboard').Result
    if ([int]$dashResp.StatusCode -ne 302) { throw "Expected 302 redirect, got $([int]$dashResp.StatusCode)" }
    $loc = $dashResp.Headers.Location.ToString()
    if ($loc -notmatch '/Account/Login') { throw "Expected redirect to /Account/Login, got $loc" }
}

# 6. Non-Admin Access to Admin Users Directory
Test-Case "Standard user accessing Admin/Users is redirected with error" {
    $cookies = [System.Net.CookieContainer]::new()
    $handler = [System.Net.Http.HttpClientHandler]::new()
    $handler.CookieContainer = $cookies
    $handler.AllowAutoRedirect = $false
    $client = [System.Net.Http.HttpClient]::new($handler)

    # Login as rahul (standard user)
    $getResp = $client.GetAsync('http://localhost:9979/Account/Login').Result
    $html = $getResp.Content.ReadAsStringAsync().Result
    $m = [regex]::Match($html, '__RequestVerificationToken.*?value="([^"]+)"')
    if (-not $m.Success) { $m = [regex]::Match($html, 'value="([^"]+)".*?__RequestVerificationToken') }
    $token = $m.Groups[1].Value

    $dict = [System.Collections.Generic.Dictionary[string,string]]::new()
    $dict['__RequestVerificationToken'] = $token
    $dict['UsernameOrEmail'] = 'rahul'
    $dict['Password'] = 'User@123'
    $content = [System.Net.Http.FormUrlEncodedContent]::new($dict)
    $loginResp = $client.PostAsync('http://localhost:9979/Account/Login', $content).Result
    if ([int]$loginResp.StatusCode -ne 302) { throw "Login failed" }

    # Attempt to access Admin/Users
    $usersResp = $client.GetAsync('http://localhost:9979/Admin/Users').Result
    if ([int]$usersResp.StatusCode -ne 302) { throw "Expected 302 redirect, got $([int]$usersResp.StatusCode)" }
    $loc = $usersResp.Headers.Location.ToString()
    if ($loc -notmatch '/Account/Login') { throw "Expected redirect to /Account/Login, got $loc" }
}

Write-Host "`nTotal Tests: $($passed + $failed) | Passed: $passed | Failed: $failed"
if ($failed -gt 0) { exit 1 }
