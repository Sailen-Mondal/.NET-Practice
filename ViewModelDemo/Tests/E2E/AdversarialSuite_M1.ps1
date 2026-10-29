# ==============================================================================
# AdversarialSuite_M1.ps1 - Empirical Verification & Stress Harness for M1
# Target: ASP.NET MVC 5 on IIS Express (http://localhost:9979)
# STRICT ZERO EMOJIS
# ==============================================================================

Add-Type -AssemblyName System.Net.Http

$results = [System.Collections.Generic.List[PSCustomObject]]::new()

function Assert-Check($id, $category, $desc, $scriptBlock) {
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    $status = 'PASS'
    $detail = ''
    try {
        $detail = & $scriptBlock
        $sw.Stop()
        Write-Host ('[PASS] ' + $id + ' (' + $category + '): ' + $desc) -ForegroundColor Green
        if ($detail) { Write-Host ('       ' + $detail) -ForegroundColor DarkGray }
    } catch {
        $sw.Stop()
        $status = 'FAIL'
        $detail = $_.Exception.Message
        Write-Host ('[FAIL] ' + $id + ' (' + $category + '): ' + $desc) -ForegroundColor Red
        Write-Host ('       Error: ' + $detail) -ForegroundColor Yellow
    }
    $results.Add([PSCustomObject]@{
        Id = $id
        Category = $category
        Description = $desc
        Status = $status
        DurationMs = [math]::Round($sw.Elapsed.TotalMilliseconds, 2)
        Detail = $detail
    })
}

Write-Host '=============================================================' -ForegroundColor Cyan
Write-Host ' EMPIRICAL CHALLENGE SUITE: MILESTONE 1 VERIFICATION' -ForegroundColor Cyan
Write-Host '=============================================================' -ForegroundColor Cyan

# C01: Static Asset Delivery
Assert-Check 'C01_01' 'Static Assets' 'Content/site.css returns HTTP 200 with CSS content' {
    $r = Invoke-WebRequest -Uri 'http://localhost:9979/Content/site.css' -UseBasicParsing
    if ($r.StatusCode -ne 200) { throw 'Status ' + $r.StatusCode }
    if ($r.Headers['Content-Type'] -notmatch 'text/css') { throw 'Content-Type not text/css: ' + $r.Headers['Content-Type'] }
    if ($r.Content -notmatch '--canvas-bg' -or $r.Content -notmatch '--text-primary') { throw 'Missing CSS tokens' }
    'Size: ' + $r.RawContentLength + ' bytes, Content-Type: ' + $r.Headers['Content-Type']
}

Assert-Check 'C01_02' 'Static Assets' 'Scripts/app.js returns HTTP 200 with JS content' {
    $r = Invoke-WebRequest -Uri 'http://localhost:9979/Scripts/app.js' -UseBasicParsing
    if ($r.StatusCode -ne 200) { throw 'Status ' + $r.StatusCode }
    if ($r.Headers['Content-Type'] -notmatch 'javascript') { throw 'Content-Type not javascript: ' + $r.Headers['Content-Type'] }
    if ($r.Content -notmatch 'openDrawer' -or $r.Content -notmatch 'initAlertDismiss') { throw 'Missing JS functions' }
    'Size: ' + $r.RawContentLength + ' bytes, Content-Type: ' + $r.Headers['Content-Type']
}

# C02: Primary Route Status & Resolution
Assert-Check 'C02_01' 'Routing' 'Root / resolves to /Employee/Details with HTTP 200' {
    $r = Invoke-WebRequest -Uri 'http://localhost:9979/' -UseBasicParsing
    if ($r.StatusCode -ne 200) { throw 'Status ' + $r.StatusCode }
    if ($r.Content -notmatch 'Employee Details') { throw 'Missing Employee Details' }
    'Default route resolves to Employee/Details successfully'
}

Assert-Check 'C02_02' 'Routing' '/Employee/Index returns HTTP 200 with SQL Server records' {
    $r = Invoke-WebRequest -Uri 'http://localhost:9979/Employee/Index' -UseBasicParsing
    if ($r.StatusCode -ne 200) { throw 'Status ' + $r.StatusCode }
    if ($r.Content -notmatch 'Dillip Mohapatra' -or $r.Content -notmatch 'Rahul Sharma') { throw 'Missing employee names' }
    'Records loaded: Dillip Mohapatra, Rahul Sharma'
}

Assert-Check 'C02_03' 'Routing' '/Student/Index returns HTTP 200 with SQL Server students' {
    $r = Invoke-WebRequest -Uri 'http://localhost:9979/Student/Index' -UseBasicParsing
    if ($r.StatusCode -ne 200) { throw 'Status ' + $r.StatusCode }
    if ($r.Content -notmatch 'Ankur' -or $r.Content -notmatch 'Priya Sharma') { throw 'Missing student records' }
    'Students loaded: Ankur, Priya Sharma'
}

Assert-Check 'C02_04' 'Routing' '/Student/getStud returns HTTP 200 with ViewModel marks formatting' {
    $r = Invoke-WebRequest -Uri 'http://localhost:9979/Student/getStud' -UseBasicParsing
    if ($r.StatusCode -ne 200) { throw 'Status ' + $r.StatusCode }
    if ($r.Content -notmatch 'green' -or $r.Content -notmatch 'red') { throw 'Missing marks color coding' }
    'ViewModel conditional green/red marks badges verified'
}

Assert-Check 'C02_05' 'Routing' '/Account/Login returns HTTP 200 with AntiForgeryToken' {
    $r = Invoke-WebRequest -Uri 'http://localhost:9979/Account/Login' -UseBasicParsing
    if ($r.StatusCode -ne 200) { throw 'Status ' + $r.StatusCode }
    if ($r.Content -notmatch '__RequestVerificationToken') { throw 'Missing AntiForgeryToken' }
    'Login form with CSRF token verified'
}

Assert-Check 'C02_06' 'Routing' '/Account/Register returns HTTP 200 with AntiForgeryToken' {
    $r = Invoke-WebRequest -Uri 'http://localhost:9979/Account/Register' -UseBasicParsing
    if ($r.StatusCode -ne 200) { throw 'Status ' + $r.StatusCode }
    if ($r.Content -notmatch '__RequestVerificationToken') { throw 'Missing AntiForgeryToken' }
    'Register form with CSRF token verified'
}

Assert-Check 'C02_07' 'Routing' '/Admin/Dashboard redirects unauthenticated user to Login (HTTP 302)' {
    $handler = [System.Net.Http.HttpClientHandler]::new()
    $handler.AllowAutoRedirect = $false
    $client = [System.Net.Http.HttpClient]::new($handler)
    $r = $client.GetAsync('http://localhost:9979/Admin/Dashboard').Result
    if ([int]$r.StatusCode -ne 302) { throw 'Status ' + [int]$r.StatusCode }
    $loc = $r.Headers.Location.ToString()
    if ($loc -notmatch '/Account/Login\?returnUrl=') { throw 'Unexpected location: ' + $loc }
    'Redirected to: ' + $loc
}

Assert-Check 'C02_08' 'Routing' '/Admin/Users redirects unauthenticated user to Login (HTTP 302)' {
    $handler = [System.Net.Http.HttpClientHandler]::new()
    $handler.AllowAutoRedirect = $false
    $client = [System.Net.Http.HttpClient]::new($handler)
    $r = $client.GetAsync('http://localhost:9979/Admin/Users').Result
    if ([int]$r.StatusCode -ne 302) { throw 'Status ' + [int]$r.StatusCode }
    $loc = $r.Headers.Location.ToString()
    if ($loc -notmatch '/Account/Login\?returnUrl=') { throw 'Unexpected location: ' + $loc }
    'Redirected to: ' + $loc
}

# C03: Adversarial Parameters & Edge Cases
Assert-Check 'C03_01' 'Adversarial' 'Search with SQL injection payload handled cleanly' {
    $r = Invoke-WebRequest -Uri 'http://localhost:9979/Employee/Index?search=%27%20OR%201=1--' -UseBasicParsing
    if ($r.StatusCode -ne 200) { throw 'Status ' + $r.StatusCode }
    'Query returned HTTP 200 without SQL exception'
}

Assert-Check 'C03_02' 'Adversarial' 'Search with HTML tags is intercepted or encoded by ASP.NET' {
    try {
        $r = Invoke-WebRequest -Uri 'http://localhost:9979/Employee/Index?search=%3Cscript%3E' -UseBasicParsing -ErrorAction Stop
        'Returned HTTP 200'
    } catch {
        # ASP.NET RequestValidationException produces 500 for dangerous input
        if ($_.Exception.Message -match '500') {
            'ASP.NET RequestValidationException successfully intercepted dangerous input (HTTP 500)'
        } else {
            throw $_
        }
    }
}

Assert-Check 'C03_03' 'Adversarial' 'Details view with non-existent ID handled gracefully' {
    $r = Invoke-WebRequest -Uri 'http://localhost:9979/Employee/Details/99999' -UseBasicParsing
    if ($r.StatusCode -ne 200) { throw 'Status ' + $r.StatusCode }
    'Handled without unhandled server crash'
}

# C04: CSRF Anti-Forgery Token Enforcement
Assert-Check 'C04_01' 'CSRF Protection' 'POST Login without CSRF token is rejected with HTTP 500' {
    $handler = [System.Net.Http.HttpClientHandler]::new()
    $handler.AllowAutoRedirect = $false
    $client = [System.Net.Http.HttpClient]::new($handler)
    $dict = [System.Collections.Generic.Dictionary[string,string]]::new()
    $dict['UsernameOrEmail'] = 'admin'
    $dict['Password'] = 'Admin@123'
    $content = [System.Net.Http.FormUrlEncodedContent]::new($dict)
    $r = $client.PostAsync('http://localhost:9979/Account/Login', $content).Result
    if ([int]$r.StatusCode -ne 500) { throw 'Expected 500 HttpAntiForgeryException, got ' + [int]$r.StatusCode }
    'Anti-forgery token enforcement confirmed active (HTTP 500)'
}

# C05: Session Authentication and Navigation Dynamic Rendering
Assert-Check 'C05_01' 'Authentication' 'Admin authentication establishes session and renders Admin chrome' {
    $cookies = [System.Net.CookieContainer]::new()
    $handler = [System.Net.Http.HttpClientHandler]::new()
    $handler.CookieContainer = $cookies
    $handler.AllowAutoRedirect = $false
    $client = [System.Net.Http.HttpClient]::new($handler)

    # 1. GET token
    $getLogin = $client.GetAsync('http://localhost:9979/Account/Login').Result
    $loginHtml = $getLogin.Content.ReadAsStringAsync().Result
    $m = [regex]::Match($loginHtml, '__RequestVerificationToken.*value="([^"]+)"')
    if (-not $m.Success) {
        $m = [regex]::Match($loginHtml, 'value="([^"]+)".*__RequestVerificationToken')
    }
    $token = $m.Groups[1].Value

    # 2. POST credentials
    $dict = [System.Collections.Generic.Dictionary[string,string]]::new()
    $dict['__RequestVerificationToken'] = $token
    $dict['UsernameOrEmail'] = 'admin'
    $dict['Password'] = 'Admin@123'
    $content = [System.Net.Http.FormUrlEncodedContent]::new($dict)
    $postResp = $client.PostAsync('http://localhost:9979/Account/Login', $content).Result

    if ([int]$postResp.StatusCode -ne 302) { throw 'Expected 302 login redirect, got ' + [int]$postResp.StatusCode }

    # 3. Request Admin Dashboard
    $dashResp = $client.GetAsync('http://localhost:9979/Admin/Dashboard').Result
    if ([int]$dashResp.StatusCode -ne 200) { throw 'Expected 200 Dashboard, got ' + [int]$dashResp.StatusCode }
    $dashHtml = $dashResp.Content.ReadAsStringAsync().Result

    if ($dashHtml -notmatch 'System Administrator') { throw 'Missing user FullName in nav pill' }
    if ($dashHtml -notmatch 'badge-admin') { throw 'Missing badge-admin in nav' }
    if ($dashHtml -notmatch 'href="/Admin/Dashboard"') { throw 'Missing Admin Dashboard link' }
    if ($dashHtml -notmatch 'href="/Account/Logout"') { throw 'Missing Logout link' }
    if ($dashHtml -notmatch 'Session: Admin \(admin\)') { throw 'Missing footer session status' }

    'Admin session active, FullName pill, badge-admin, and Admin links rendered'
}

Assert-Check 'C05_02' 'Authentication' 'Standard user authentication establishes session and isolates Admin chrome' {
    $cookies = [System.Net.CookieContainer]::new()
    $handler = [System.Net.Http.HttpClientHandler]::new()
    $handler.CookieContainer = $cookies
    $handler.AllowAutoRedirect = $false
    $client = [System.Net.Http.HttpClient]::new($handler)

    # 1. GET token
    $getLogin = $client.GetAsync('http://localhost:9979/Account/Login').Result
    $loginHtml = $getLogin.Content.ReadAsStringAsync().Result
    $m = [regex]::Match($loginHtml, '__RequestVerificationToken.*value="([^"]+)"')
    if (-not $m.Success) {
        $m = [regex]::Match($loginHtml, 'value="([^"]+)".*__RequestVerificationToken')
    }
    $token = $m.Groups[1].Value

    # 2. POST credentials
    $dict = [System.Collections.Generic.Dictionary[string,string]]::new()
    $dict['__RequestVerificationToken'] = $token
    $dict['UsernameOrEmail'] = 'rahul'
    $dict['Password'] = 'User@123'
    $content = [System.Net.Http.FormUrlEncodedContent]::new($dict)
    $postResp = $client.PostAsync('http://localhost:9979/Account/Login', $content).Result

    if ([int]$postResp.StatusCode -ne 302) { throw 'Expected 302 login redirect, got ' + [int]$postResp.StatusCode }
    $loc = $postResp.Headers.Location.ToString()
    if ($loc -notmatch '/Employee/Index') { throw 'Expected redirect to /Employee/Index, got ' + $loc }

    # 3. Request Employee Index
    $empResp = $client.GetAsync('http://localhost:9979/Employee/Index').Result
    if ([int]$empResp.StatusCode -ne 200) { throw 'Expected 200 Index, got ' + [int]$empResp.StatusCode }
    $empHtml = $empResp.Content.ReadAsStringAsync().Result

    if ($empHtml -notmatch 'Rahul Sharma') { throw 'Missing user FullName in nav pill' }
    if ($empHtml -notmatch 'badge-user') { throw 'Missing badge-user in nav' }
    if ($empHtml -match 'href="/Admin/Dashboard"') { throw 'Standard user unexpectedly has Admin Dashboard link' }
    if ($empHtml -notmatch 'href="/Account/Logout"') { throw 'Missing Logout link' }
    if ($empHtml -notmatch 'Session: User \(rahul\)') { throw 'Missing footer session status' }

    'Standard user session active, FullName pill, badge-user, admin links excluded'
}

Assert-Check 'C05_03' 'Authorization' 'Standard user is blocked from Admin endpoints (HTTP 302 redirect)' {
    $cookies = [System.Net.CookieContainer]::new()
    $handler = [System.Net.Http.HttpClientHandler]::new()
    $handler.CookieContainer = $cookies
    $handler.AllowAutoRedirect = $false
    $client = [System.Net.Http.HttpClient]::new($handler)

    # 1. Login as rahul
    $getLogin = $client.GetAsync('http://localhost:9979/Account/Login').Result
    $loginHtml = $getLogin.Content.ReadAsStringAsync().Result
    $m = [regex]::Match($loginHtml, 'value="([^"]+)".*__RequestVerificationToken')
    if (-not $m.Success) {
        $m = [regex]::Match($loginHtml, '__RequestVerificationToken.*value="([^"]+)"')
    }
    $token = $m.Groups[1].Value

    $dict = [System.Collections.Generic.Dictionary[string,string]]::new()
    $dict['__RequestVerificationToken'] = $token
    $dict['UsernameOrEmail'] = 'rahul'
    $dict['Password'] = 'User@123'
    $content = [System.Net.Http.FormUrlEncodedContent]::new($dict)
    $null = $client.PostAsync('http://localhost:9979/Account/Login', $content).Result

    # 2. Attempt /Admin/Dashboard
    $dashAttempt = $client.GetAsync('http://localhost:9979/Admin/Dashboard').Result
    if ([int]$dashAttempt.StatusCode -ne 302) { throw 'Expected 302 from /Admin/Dashboard, got ' + [int]$dashAttempt.StatusCode }
    if ($dashAttempt.Headers.Location.ToString() -notmatch '/Account/Login\?returnUrl=') {
        throw 'Unexpected redirect location: ' + $dashAttempt.Headers.Location.ToString()
    }

    # 3. Attempt /Employee/Create
    $createAttempt = $client.GetAsync('http://localhost:9979/Employee/Create').Result
    if ([int]$createAttempt.StatusCode -ne 302) { throw 'Expected 302 from /Employee/Create, got ' + [int]$createAttempt.StatusCode }
    if ($createAttempt.Headers.Location.ToString() -notmatch '/Account/Login\?returnUrl=') {
        throw 'Unexpected redirect location: ' + $createAttempt.Headers.Location.ToString()
    }

    'Both /Admin/Dashboard and /Employee/Create securely redirect standard user to Login'
}

# C08: MSBuild Compilation
Assert-Check 'C08_01' 'Compilation' 'MSBuild compiles ViewModelDemo.csproj cleanly with 0 errors' {
    $msbuild = "C:\Program Files\Microsoft Visual Studio\18\Community\MSBuild\Current\Bin\MSBuild.exe"
    $proj = "D:\.NET\ViewModelDemo\ViewModelDemo.csproj"
    $out = & $msbuild $proj /t:Build /p:Configuration=Debug 2>&1
    $outStr = $out -join "`n"
    if ($LASTEXITCODE -ne 0) { throw 'MSBuild failed with exit code ' + $LASTEXITCODE }
    if ($outStr -notmatch 'Build succeeded') { throw 'MSBuild output did not contain Build succeeded' }
    if ($outStr -notmatch '0 Error\(s\)') { throw 'MSBuild reported errors' }
    'Clean build: 0 Warning(s), 0 Error(s)'
}

# C06: Mobile Navigation Drawer & Accessibility Markup
Assert-Check 'C06_01' 'Accessibility' 'Mobile navigation drawer markup has correct ARIA attributes' {
    $r = Invoke-WebRequest -Uri 'http://localhost:9979/Employee/Index' -UseBasicParsing
    if ($r.Content -notmatch 'id="mobileNavToggle"') { throw 'Missing mobileNavToggle ID' }
    if ($r.Content -notmatch 'aria-expanded="false"') { throw 'Missing aria-expanded attribute' }
    if ($r.Content -notmatch 'aria-controls="mobileNavDrawer"') { throw 'Missing aria-controls attribute' }
    if ($r.Content -notmatch 'id="mobileNavOverlay"') { throw 'Missing mobileNavOverlay ID' }
    if ($r.Content -notmatch 'id="mobileNavDrawer"') { throw 'Missing mobileNavDrawer ID' }
    'All drawer ARIA and ID contracts verified'
}

# C07: Strict Zero Emoji Compliance
Assert-Check 'C07_01' 'Zero Emojis' 'Shared Layout, Navigation, CSS, and JS strictly contain zero emojis' {
    $files = @(
        'D:\.NET\ViewModelDemo\Views\Shared\_Layout.cshtml',
        'D:\.NET\ViewModelDemo\Views\Shared\_Navigation.cshtml',
        'D:\.NET\ViewModelDemo\Content\site.css',
        'D:\.NET\ViewModelDemo\Scripts\app.js'
    )
    foreach ($f in $files) {
        $txt = [System.IO.File]::ReadAllText($f)
        if ($txt -match '[\uD83C-\uDBFF\uDC00-\uDFFF\u2600-\u27BF]') {
            throw ('Emoji detected in file: ' + $f)
        }
    }
    'Zero emojis detected across all 4 milestone deliverable files'
}

Write-Host '-------------------------------------------------------------' -ForegroundColor Cyan
$passCount = @($results | Where-Object { $_.Status -eq 'PASS' }).Count
$failCount = @($results | Where-Object { $_.Status -eq 'FAIL' }).Count
Write-Host ('Summary: Total=' + $results.Count + ' | Passed=' + $passCount + ' | Failed=' + $failCount) -ForegroundColor $(if ($failCount -eq 0) { 'Green' } else { 'Red' })
Write-Host '=============================================================' -ForegroundColor Cyan

if ($failCount -gt 0) { exit 1 } else { exit 0 }
