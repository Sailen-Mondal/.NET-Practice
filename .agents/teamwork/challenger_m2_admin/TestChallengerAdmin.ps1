# ==============================================================================
# TestChallengerAdmin.ps1 - Challenger 2 Adversarial Test Suite
# Target: ASP.NET MVC 5 on IIS Express (http://localhost:9979)
# Scope: Admin Dashboard (/Admin/Dashboard), Admin Users (/Admin/Users),
#        Responsive Layouts, Security & Access Control, Zero Emojis
# STRICT ZERO EMOJIS - Clean Minimalist Terminal Formatting
# ==============================================================================

[CmdletBinding()]
param(
    [string]$BaseUrl = "http://localhost:9979",
    [switch]$VerboseOutput
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Dot-source test harness
$harnessPath = "D:\.NET\ViewModelDemo\Tests\E2E\TestHarness.ps1"
if (-not (Test-Path $harnessPath)) {
    throw "TestHarness.ps1 not found at $harnessPath"
}
. $harnessPath

# Test Tracking
$Script:ChallengerTests = [System.Collections.Generic.List[PSObject]]::new()
$Script:PassedCount = 0
$Script:FailedCount = 0

function Register-ChallengerTest {
    param(
        [string]$Id,
        [string]$Category,
        [string]$Description,
        [scriptblock]$Action
    )
    $Script:ChallengerTests.Add([PSCustomObject]@{
        Id          = $Id
        Category    = $Category
        Description = $Description
        Action      = $Action
    })
}

# ==============================================================================
# GROUP 1: ADMIN DASHBOARD ACCESS CONTROL & SECURITY
# ==============================================================================

Register-ChallengerTest "CH_ADM_01" "Access Control" "Unauthenticated guest GET /Admin/Dashboard returns 302 redirect to /Account/Login with returnUrl" {
    $session = New-E2ESession -BaseUrl $BaseUrl
    $resp = Invoke-E2EGet -Session $session -Path "/Admin/Dashboard" -FollowRedirects $false
    Assert-True ($resp.StatusCode -eq 302) "Expected status code 302, got $($resp.StatusCode)"
    Assert-True ($resp.Location -match '/Account/Login') "Location header does not point to /Account/Login: $($resp.Location)"
    Assert-True ($resp.Location -match 'returnUrl=.*Admin.*Dashboard') "Location header missing returnUrl parameter for Admin/Dashboard: $($resp.Location)"
}

Register-ChallengerTest "CH_ADM_02" "Access Control" "Unauthenticated redirect destination renders login page with access restricted error alert" {
    $session = New-E2ESession -BaseUrl $BaseUrl
    $loginPage = Invoke-E2EGet -Session $session -Path "/Admin/Dashboard" -FollowRedirects $true
    Assert-True ($loginPage.StatusCode -eq 200) "Expected status code 200 after redirect, got $($loginPage.StatusCode)"
    Assert-True ($loginPage.Content -match 'Access restricted') "Expected 'Access restricted' warning message in HTML"
    Assert-True ($loginPage.Content -match 'alert-danger|alert') "Expected alert container in HTML"
}

Register-ChallengerTest "CH_ADM_03" "Access Control" "Standard authenticated user (Role == 'User') GET /Admin/Dashboard returns 302 redirect" {
    $session = New-E2ESession -BaseUrl $BaseUrl
    $loginResp = Invoke-E2ELogin -Session $session -UsernameOrEmail "rahul" -Password "User@123"
    Assert-True ($loginResp.StatusCode -eq 302) "Standard user login failed"

    $resp = Invoke-E2EGet -Session $session -Path "/Admin/Dashboard" -FollowRedirects $false
    Assert-True ($resp.StatusCode -eq 302) "Expected status code 302 for non-admin user, got $($resp.StatusCode)"
    Assert-True ($resp.Location -match '/Account/Login') "Expected redirect to Login page, got $($resp.Location)"
}

Register-ChallengerTest "CH_ADM_04" "Access Control" "Standard user redirect destination renders access denied alert" {
    $session = New-E2ESession -BaseUrl $BaseUrl
    $loginResp = Invoke-E2ELogin -Session $session -UsernameOrEmail "rahul" -Password "User@123"
    Assert-True ($loginResp.StatusCode -eq 302) "Standard user login failed"

    $followed = Invoke-E2EGet -Session $session -Path "/Admin/Dashboard" -FollowRedirects $true
    Assert-True ($followed.StatusCode -eq 200) "Expected 200 following redirect, got $($followed.StatusCode)"
    Assert-True ($followed.Content -match 'Access restricted\. Please log in with an Administrator account\.') "Expected exact admin privilege denial alert"
}

Register-ChallengerTest "CH_ADM_05" "Access Control" "Authenticated Admin (Role == 'Admin') GET /Admin/Dashboard returns 200 OK" {
    $session = New-E2ESession -BaseUrl $BaseUrl
    $loginResp = Invoke-E2ELogin -Session $session -UsernameOrEmail "admin" -Password "Admin@123"
    Assert-True ($loginResp.StatusCode -eq 302) "Admin login failed"

    $resp = Invoke-E2EGet -Session $session -Path "/Admin/Dashboard" -FollowRedirects $false
    Assert-True ($resp.StatusCode -eq 200) "Expected status code 200 for Admin, got $($resp.StatusCode)"
    Assert-True ($resp.Content -match 'Administrator Dashboard') "Page missing 'Administrator Dashboard' heading"
}

Register-ChallengerTest "CH_ADM_06" "Access Control" "Session tampering: Corrupt or forged cookie GET /Admin/Dashboard gracefully redirects to Login" {
    $session = New-E2ESession -BaseUrl $BaseUrl
    $cookie = New-Object System.Net.Cookie("ASP.NET_SessionId", "FORGED_INVALID_SESSION_TOKEN_1234567890", "/", "localhost")
    $session.WebSession.Cookies.Add($cookie)
    $resp = Invoke-E2EGet -Session $session -Path "/Admin/Dashboard" -FollowRedirects $false
    Assert-True ($resp.StatusCode -eq 302) "Tampered session should redirect (302), got $($resp.StatusCode)"
    Assert-True ($resp.Location -match '/Account/Login') "Tampered session should redirect to /Account/Login"
}

# ==============================================================================
# GROUP 2: ADMIN DASHBOARD 4 KPI METRIC CARDS
# ==============================================================================

Register-ChallengerTest "CH_METRIC_01" "KPI Metrics" "Verify .metrics-grid container and exactly 4 .metric-card components" {
    $session = New-E2ESession -BaseUrl $BaseUrl
    $loginResp = Invoke-E2ELogin -Session $session -UsernameOrEmail "admin" -Password "Admin@123"
    $resp = Invoke-E2EGet -Session $session -Path "/Admin/Dashboard"
    
    Assert-True ($resp.Content -match 'class="metrics-grid"') "Missing .metrics-grid container"
    $metricCardMatches = [regex]::Matches($resp.Content, 'class="metric-card"')
    Assert-True ($metricCardMatches.Count -eq 4) "Expected exactly 4 .metric-card elements, found $($metricCardMatches.Count)"
}

Register-ChallengerTest "CH_METRIC_02" "KPI Metrics" "KPI 1: Total Employees card has label, icon, numeric value, and metadata" {
    $session = New-E2ESession -BaseUrl $BaseUrl
    Invoke-E2ELogin -Session $session -UsernameOrEmail "admin" -Password "Admin@123" | Out-Null
    $resp = Invoke-E2EGet -Session $session -Path "/Admin/Dashboard"

    Assert-True ($resp.Content -match 'Total Employees') "Missing 'Total Employees' label"
    Assert-True ($resp.Content -match '<div class="metric-value">\s*\d+\s*</div>') "Missing numeric metric-value for Total Employees"
    Assert-True ($resp.Content -match 'Active workforce records in database') "Missing metadata description for Total Employees"
}

Register-ChallengerTest "CH_METRIC_03" "KPI Metrics" "KPI 2: Registered Users card has label, icon, numeric value, and metadata" {
    $session = New-E2ESession -BaseUrl $BaseUrl
    Invoke-E2ELogin -Session $session -UsernameOrEmail "admin" -Password "Admin@123" | Out-Null
    $resp = Invoke-E2EGet -Session $session -Path "/Admin/Dashboard"

    Assert-True ($resp.Content -match 'Registered Users') "Missing 'Registered Users' label"
    Assert-True ($resp.Content -match '<div class="metric-value">\s*\d+\s*</div>') "Missing numeric metric-value for Registered Users"
    Assert-True ($resp.Content -match 'System user accounts with login access') "Missing metadata description for Registered Users"
}

Register-ChallengerTest "CH_METRIC_04" "KPI Metrics" "KPI 3: Monthly Payroll card has label, icon, Rs. formatted value, and metadata" {
    $session = New-E2ESession -BaseUrl $BaseUrl
    Invoke-E2ELogin -Session $session -UsernameOrEmail "admin" -Password "Admin@123" | Out-Null
    $resp = Invoke-E2EGet -Session $session -Path "/Admin/Dashboard"

    Assert-True ($resp.Content -match 'Monthly Payroll') "Missing 'Monthly Payroll' label"
    Assert-True ($resp.Content -match '<div class="metric-value">\s*Rs\.\s*[\d,]+(\.\d{2})?\s*</div>') "Monthly Payroll value missing 'Rs.' currency format"
    Assert-True ($resp.Content -match 'Aggregated monthly compensation outlay') "Missing metadata description for Monthly Payroll"
}

Register-ChallengerTest "CH_METRIC_05" "KPI Metrics" "KPI 4: Average Salary card has label, icon, Rs. formatted value, and metadata" {
    $session = New-E2ESession -BaseUrl $BaseUrl
    Invoke-E2ELogin -Session $session -UsernameOrEmail "admin" -Password "Admin@123" | Out-Null
    $resp = Invoke-E2EGet -Session $session -Path "/Admin/Dashboard"

    Assert-True ($resp.Content -match 'Average Salary') "Missing 'Average Salary' label"
    Assert-True ($resp.Content -match '<div class="metric-value">\s*Rs\.\s*[\d,]+(\.\d{2})?\s*</div>') "Average Salary value missing 'Rs.' currency format"
    Assert-True ($resp.Content -match 'Mean compensation per employee') "Missing metadata description for Average Salary"
}

# ==============================================================================
# GROUP 3: ADMIN DASHBOARD DEPARTMENT DISTRIBUTION
# ==============================================================================

Register-ChallengerTest "CH_DEPT_01" "Department Distribution" "Verify 'Workforce by Department' card header and department count badge" {
    $session = New-E2ESession -BaseUrl $BaseUrl
    Invoke-E2ELogin -Session $session -UsernameOrEmail "admin" -Password "Admin@123" | Out-Null
    $resp = Invoke-E2EGet -Session $session -Path "/Admin/Dashboard"

    Assert-True ($resp.Content -match 'Workforce by Department') "Missing 'Workforce by Department' heading"
    Assert-True ($resp.Content -match '\d+ Departments') "Missing department count badge"
}

Register-ChallengerTest "CH_DEPT_02" "Department Distribution" "Verify department summary tag pills with dot indicator and counts" {
    $session = New-E2ESession -BaseUrl $BaseUrl
    Invoke-E2ELogin -Session $session -UsernameOrEmail "admin" -Password "Admin@123" | Out-Null
    $resp = Invoke-E2EGet -Session $session -Path "/Admin/Dashboard"

    Assert-True ($resp.Content -match 'class="tag"') "Missing .tag pills"
    Assert-True ($resp.Content -match 'IT|HR|Engineering|Finance') "No standard department name found in pills"
    Assert-True ($resp.Content -match 'employee\(s\)?|employees?') "Missing employee count label in department pill"
}

Register-ChallengerTest "CH_DEPT_03" "Department Distribution" "Verify proportional visual progress bar tracks and percentage values" {
    $session = New-E2ESession -BaseUrl $BaseUrl
    Invoke-E2ELogin -Session $session -UsernameOrEmail "admin" -Password "Admin@123" | Out-Null
    $resp = Invoke-E2EGet -Session $session -Path "/Admin/Dashboard"

    Assert-True ($resp.Content -match 'style="[^"]*width:\s*\d+%;') "Missing visual progress bar width style"
    Assert-True ($resp.Content -match '<span style="[^"]*font-weight:\s*600;[^"]*">\s*\d+%\s*</span>') "Missing explicit percentage text label"
}

# ==============================================================================
# GROUP 4: ADMIN DASHBOARD RECENT EMPLOYEES TABLE
# ==============================================================================

Register-ChallengerTest "CH_REC_EMP_01" "Recent Employees" "Verify Recent Employees section heading and View Full Directory link" {
    $session = New-E2ESession -BaseUrl $BaseUrl
    Invoke-E2ELogin -Session $session -UsernameOrEmail "admin" -Password "Admin@123" | Out-Null
    $resp = Invoke-E2EGet -Session $session -Path "/Admin/Dashboard"

    Assert-True ($resp.Content -match 'Recent Employees') "Missing verbatim 'Recent Employees' heading"
    Assert-True ($resp.Content -match 'href="/Employee/Index"') "Missing link to full Employee directory"
}

Register-ChallengerTest "CH_REC_EMP_02" "Recent Employees" "Verify .notion-table-container and .table-responsive wrapper classes" {
    $session = New-E2ESession -BaseUrl $BaseUrl
    Invoke-E2ELogin -Session $session -UsernameOrEmail "admin" -Password "Admin@123" | Out-Null
    $resp = Invoke-E2EGet -Session $session -Path "/Admin/Dashboard"

    Assert-True ($resp.Content -match 'class="notion-table-container table-responsive"') "Missing .notion-table-container table-responsive wrapper"
}

Register-ChallengerTest "CH_REC_EMP_03" "Recent Employees" "Verify table column headers: ID, Name, Department, Salary, Location, Actions" {
    $session = New-E2ESession -BaseUrl $BaseUrl
    Invoke-E2ELogin -Session $session -UsernameOrEmail "admin" -Password "Admin@123" | Out-Null
    $resp = Invoke-E2EGet -Session $session -Path "/Admin/Dashboard"

    Assert-True ($resp.Content -match '<th[^>]*>\s*ID\s*</th>') "Missing ID column header"
    Assert-True ($resp.Content -match '<th[^>]*>\s*Name\s*</th>') "Missing Name column header"
    Assert-True ($resp.Content -match '<th[^>]*>\s*Department\s*</th>') "Missing Department column header"
    Assert-True ($resp.Content -match '<th[^>]*>\s*Salary\s*</th>') "Missing Salary column header"
    Assert-True ($resp.Content -match '<th[^>]*>\s*Location\s*</th>') "Missing Location column header"
    Assert-True ($resp.Content -match '<th[^>]*>\s*Actions\s*</th>') "Missing Actions column header"
}

Register-ChallengerTest "CH_REC_EMP_04" "Recent Employees" "Verify maximum 5 records limit in Recent Employees table" {
    $session = New-E2ESession -BaseUrl $BaseUrl
    Invoke-E2ELogin -Session $session -UsernameOrEmail "admin" -Password "Admin@123" | Out-Null
    $resp = Invoke-E2EGet -Session $session -Path "/Admin/Dashboard"

    $sectionMatch = [regex]::Match($resp.Content, 'Recent Employees.*?<tbody>(.*?)</tbody>', [System.Text.RegularExpressions.RegexOptions]::Singleline)
    Assert-True ($sectionMatch.Success) "Could not isolate Recent Employees tbody"
    $tbody = $sectionMatch.Groups[1].Value
    $rows = [regex]::Matches($tbody, '<tr>')
    Assert-True ($rows.Count -le 5) "Recent Employees contains $($rows.Count) rows, exceeding top 5 limit"
}

Register-ChallengerTest "CH_REC_EMP_05" "Recent Employees" "Verify action links: View, Edit, and Delete (.action-link-danger)" {
    $session = New-E2ESession -BaseUrl $BaseUrl
    Invoke-E2ELogin -Session $session -UsernameOrEmail "admin" -Password "Admin@123" | Out-Null
    $resp = Invoke-E2EGet -Session $session -Path "/Admin/Dashboard"

    Assert-True ($resp.Content -match 'href="/Employee/Details/\d+"') "Missing View action link"
    Assert-True ($resp.Content -match 'href="/Employee/Edit/\d+"') "Missing Edit action link"
    Assert-True ($resp.Content -match 'href="/Employee/Delete/\d+"') "Missing Delete action link"
    Assert-True ($resp.Content -match 'class="action-link action-link-danger"') "Missing danger class for Delete action"
}

# ==============================================================================
# GROUP 5: ADMIN DASHBOARD RECENT USERS TABLE
# ==============================================================================

Register-ChallengerTest "CH_REC_USR_01" "Recent Users" "Verify Recent User Registrations heading and Manage Users link" {
    $session = New-E2ESession -BaseUrl $BaseUrl
    Invoke-E2ELogin -Session $session -UsernameOrEmail "admin" -Password "Admin@123" | Out-Null
    $resp = Invoke-E2EGet -Session $session -Path "/Admin/Dashboard"

    Assert-True ($resp.Content -match 'Recent User Registrations') "Missing 'Recent User Registrations' heading"
    Assert-True ($resp.Content -match 'href="/Admin/Users"') "Missing link to /Admin/Users directory"
}

Register-ChallengerTest "CH_REC_USR_02" "Recent Users" "Verify table column headers: User ID, Username, Full Name, Email, Assigned Role, Registration Date" {
    $session = New-E2ESession -BaseUrl $BaseUrl
    Invoke-E2ELogin -Session $session -UsernameOrEmail "admin" -Password "Admin@123" | Out-Null
    $resp = Invoke-E2EGet -Session $session -Path "/Admin/Dashboard"

    Assert-True ($resp.Content -match '<th[^>]*>\s*User ID\s*</th>') "Missing User ID header"
    Assert-True ($resp.Content -match '<th[^>]*>\s*Username\s*</th>') "Missing Username header"
    Assert-True ($resp.Content -match '<th[^>]*>\s*Full Name\s*</th>') "Missing Full Name header"
    Assert-True ($resp.Content -match '<th[^>]*>\s*Email\s*</th>') "Missing Email header"
    Assert-True ($resp.Content -match '<th[^>]*>\s*Assigned Role\s*</th>') "Missing Assigned Role header"
    Assert-True ($resp.Content -match '<th[^>]*>\s*Registration Date\s*</th>') "Missing Registration Date header"
}

Register-ChallengerTest "CH_REC_USR_03" "Recent Users" "Verify maximum 5 records limit in Recent Users table" {
    $session = New-E2ESession -BaseUrl $BaseUrl
    Invoke-E2ELogin -Session $session -UsernameOrEmail "admin" -Password "Admin@123" | Out-Null
    $resp = Invoke-E2EGet -Session $session -Path "/Admin/Dashboard"

    $sectionMatch = [regex]::Match($resp.Content, 'Recent User Registrations.*?<tbody>(.*?)</tbody>', [System.Text.RegularExpressions.RegexOptions]::Singleline)
    Assert-True ($sectionMatch.Success) "Could not isolate Recent Users tbody"
    $tbody = $sectionMatch.Groups[1].Value
    $rows = [regex]::Matches($tbody, '<tr>')
    Assert-True ($rows.Count -le 5) "Recent Users contains $($rows.Count) rows, exceeding top 5 limit"
}

Register-ChallengerTest "CH_REC_USR_04" "Recent Users" "Verify role badges (.role-badge, .badge-admin, .badge-user) and mailto links" {
    $session = New-E2ESession -BaseUrl $BaseUrl
    Invoke-E2ELogin -Session $session -UsernameOrEmail "admin" -Password "Admin@123" | Out-Null
    $resp = Invoke-E2EGet -Session $session -Path "/Admin/Dashboard"

    Assert-True ($resp.Content -match 'class="role-badge (badge-admin|badge-user)"') "Missing role badge classes"
    Assert-True ($resp.Content -match 'href="mailto:[^"]+"') "Missing mailto link for email address"
    Assert-True ($resp.Content -match '[A-Za-z]{3} \d{2}, \d{4}') "Missing formatted date (MMM dd, yyyy)"
}

# ==============================================================================
# GROUP 6: ADMIN USERS DIRECTORY ACCESS CONTROL
# ==============================================================================

Register-ChallengerTest "CH_USR_DIR_01" "Users Directory Access" "Unauthenticated guest GET /Admin/Users returns 302 redirect with returnUrl" {
    $session = New-E2ESession -BaseUrl $BaseUrl
    $resp = Invoke-E2EGet -Session $session -Path "/Admin/Users" -FollowRedirects $false
    Assert-True ($resp.StatusCode -eq 302) "Expected status code 302 for unauthenticated access, got $($resp.StatusCode)"
    Assert-True ($resp.Location -match '/Account/Login') "Expected redirect to Login page, got $($resp.Location)"
    Assert-True ($resp.Location -match 'returnUrl=.*Admin.*Users') "Missing returnUrl parameter in redirect"
}

Register-ChallengerTest "CH_USR_DIR_02" "Users Directory Access" "Standard authenticated user GET /Admin/Users returns 302 redirect with access denied alert" {
    $session = New-E2ESession -BaseUrl $BaseUrl
    $loginResp = Invoke-E2ELogin -Session $session -UsernameOrEmail "rahul" -Password "User@123"
    Assert-True ($loginResp.StatusCode -eq 302) "Standard user login failed"

    $resp = Invoke-E2EGet -Session $session -Path "/Admin/Users" -FollowRedirects $false
    Assert-True ($resp.StatusCode -eq 302) "Expected status code 302 for standard user, got $($resp.StatusCode)"

    $followed = Invoke-E2EGet -Session $session -Path "/Admin/Users" -FollowRedirects $true
    Assert-True ($followed.StatusCode -eq 200) "Expected status 200 following redirect, got $($followed.StatusCode)"
    Assert-True ($followed.Content -match 'Access restricted\. Administrator privileges required\.') "Expected exact admin privilege required alert"
}

Register-ChallengerTest "CH_USR_DIR_03" "Users Directory Access" "Admin authenticated user GET /Admin/Users returns 200 OK" {
    $session = New-E2ESession -BaseUrl $BaseUrl
    Invoke-E2ELogin -Session $session -UsernameOrEmail "admin" -Password "Admin@123" | Out-Null
    $resp = Invoke-E2EGet -Session $session -Path "/Admin/Users" -FollowRedirects $false
    Assert-True ($resp.StatusCode -eq 200) "Expected status code 200 for Admin, got $($resp.StatusCode)"
    Assert-True ($resp.Content -match 'Registered System Users') "Missing 'Registered System Users' heading"
}

# ==============================================================================
# GROUP 7: ADMIN USERS DIRECTORY SECURITY & PLAINTEXT PASSWORD AUDIT
# ==============================================================================

Register-ChallengerTest "CH_USR_DIR_04" "Security Audit" "Admin Users Directory renders all user accounts without exposing plain passwords" {
    $session = New-E2ESession -BaseUrl $BaseUrl
    Invoke-E2ELogin -Session $session -UsernameOrEmail "admin" -Password "Admin@123" | Out-Null
    $resp = Invoke-E2EGet -Session $session -Path "/Admin/Users"

    # Verify seed accounts exist in directory
    Assert-True ($resp.Content -match 'admin') "Admin account not found in user directory"
    Assert-True ($resp.Content -match 'rahul') "Rahul account not found in user directory"

    # Strictly verify NO plain passwords exist in output
    Assert-False ($resp.Content -match 'Admin@123') "SECURITY VULNERABILITY: Plaintext password 'Admin@123' exposed in HTML!"
    Assert-False ($resp.Content -match 'User@123') "SECURITY VULNERABILITY: Plaintext password 'User@123' exposed in HTML!"
    Assert-False ($resp.Content -match 'PasswordHash|password_hash') "SECURITY VULNERABILITY: PasswordHash column or value exposed in HTML!"
    Assert-False ($resp.Content -match '<th>Password') "SECURITY VULNERABILITY: Password column header found in table!"
}

Register-ChallengerTest "CH_USR_DIR_05" "Security Audit" "Admin Dashboard renders recent users without exposing plain passwords or hashes" {
    $session = New-E2ESession -BaseUrl $BaseUrl
    Invoke-E2ELogin -Session $session -UsernameOrEmail "admin" -Password "Admin@123" | Out-Null
    $resp = Invoke-E2EGet -Session $session -Path "/Admin/Dashboard"

    Assert-False ($resp.Content -match 'Admin@123') "SECURITY VULNERABILITY: Plaintext password 'Admin@123' exposed on Dashboard!"
    Assert-False ($resp.Content -match 'User@123') "SECURITY VULNERABILITY: Plaintext password 'User@123' exposed on Dashboard!"
    Assert-False ($resp.Content -match 'PasswordHash|password_hash') "SECURITY VULNERABILITY: PasswordHash exposed on Dashboard!"
}

# ==============================================================================
# GROUP 8: ADMIN USERS DIRECTORY VISUAL & LAYOUT ELEMENTS
# ==============================================================================

Register-ChallengerTest "CH_USR_VIS_01" "Visual Elements" "Verify initial circle avatar (.user-avatar), mailto link with SVG, and role badges" {
    $session = New-E2ESession -BaseUrl $BaseUrl
    Invoke-E2ELogin -Session $session -UsernameOrEmail "admin" -Password "Admin@123" | Out-Null
    $resp = Invoke-E2EGet -Session $session -Path "/Admin/Users"

    # Initial circle avatar
    Assert-True ($resp.Content -match '<span class="user-avatar"[^>]*>\s*[A-Z]\s*</span>') "Missing initial circle avatar element"
    # Mailto link
    Assert-True ($resp.Content -match 'href="mailto:[^"]+"') "Missing mailto link"
    # Mail SVG envelope icon
    Assert-True ($resp.Content -match 'polyline points="22,6 12,13 2,6"') "Missing mail SVG envelope icon polyline"
    # Role badges
    Assert-True ($resp.Content -match 'class="role-badge badge-admin"') "Missing badge-admin role badge"
    Assert-True ($resp.Content -match 'class="role-badge badge-user"') "Missing badge-user role badge"
}

Register-ChallengerTest "CH_USR_VIS_02" "Visual Elements" "Verify semantic <time datetime='...'> tag with ISO timestamp and formatted date" {
    $session = New-E2ESession -BaseUrl $BaseUrl
    Invoke-E2ELogin -Session $session -UsernameOrEmail "admin" -Password "Admin@123" | Out-Null
    $resp = Invoke-E2EGet -Session $session -Path "/Admin/Users"

    Assert-True ($resp.Content -match '<time datetime="\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}"') "Missing semantic time tag with ISO format"
    Assert-True ($resp.Content -match '[A-Za-z]{3} \d{2}, \d{4} \d{2}:\d{2}') "Missing formatted created date string"
}

Register-ChallengerTest "CH_USR_VIS_03" "Visual Elements" "Verify breadcrumbs, Back to Dashboard button, and accounts badge" {
    $session = New-E2ESession -BaseUrl $BaseUrl
    Invoke-E2ELogin -Session $session -UsernameOrEmail "admin" -Password "Admin@123" | Out-Null
    $resp = Invoke-E2EGet -Session $session -Path "/Admin/Users"

    Assert-True ($resp.Content -match 'class="notion-breadcrumb"') "Missing notion-breadcrumb navigation"
    Assert-True ($resp.Content -match 'href="/Admin/Dashboard"') "Missing link to /Admin/Dashboard"
    Assert-True ($resp.Content -match 'Back to Dashboard') "Missing 'Back to Dashboard' button label"
    Assert-True ($resp.Content -match '\d+ Accounts') "Missing account count pill badge"
}

# ==============================================================================
# GROUP 9: RESPONSIVE VIEWPORTS & CSS ARCHITECTURE
# ==============================================================================

Register-ChallengerTest "CH_RESP_01" "Responsive Layout" "Verify responsive viewport CSS rules for Mobile (<768px), Tablet (768-1024px), Desktop (>1024px)" {
    $cssPath = "D:\.NET\ViewModelDemo\Content\site.css"
    Assert-True (Test-Path $cssPath) "site.css file not found"
    $css = Get-Content -Path $cssPath -Raw

    # Desktop metrics grid
    Assert-True ($css -match '\.metrics-grid\s*\{[^}]*grid-template-columns:\s*repeat\(auto-fit,\s*minmax\(200px,\s*1fr\)\)') "Missing desktop auto-fit metrics-grid CSS rule"
    # Tablet media query (single-line regex mode (?s))
    Assert-True ($css -match '(?s)@media\s*\(\s*max-width:\s*1024px\s*\).*?\.metrics-grid\s*\{[^}]*grid-template-columns:\s*repeat\(2,\s*1fr\)') "Missing tablet 2-column metrics-grid rule"
    # Mobile media query (single-line regex mode (?s))
    Assert-True ($css -match '(?s)@media\s*\(\s*max-width:\s*768px\s*\).*?\.metrics-grid\s*\{[^}]*grid-template-columns:\s*1fr') "Missing mobile 1-column metrics-grid rule"
    # Horizontal scroll containers
    Assert-True ($css -match '\.notion-table-container[^{]*\{[^}]*overflow-x:\s*auto') "Missing overflow-x: auto on .notion-table-container"
    # Reduced motion
    Assert-True ($css -match '@media\s*\(\s*prefers-reduced-motion:\s*reduce\s*\)') "Missing prefers-reduced-motion media query"
}

Register-ChallengerTest "CH_RESP_02" "Responsive Layout" "Verify responsive HTML containers present on both Admin views" {
    $session = New-E2ESession -BaseUrl $BaseUrl
    Invoke-E2ELogin -Session $session -UsernameOrEmail "admin" -Password "Admin@123" | Out-Null

    $dash = Invoke-E2EGet -Session $session -Path "/Admin/Dashboard"
    Assert-True ($dash.Content -match 'class="notion-table-container table-responsive"') "Dashboard missing responsive table container"

    $users = Invoke-E2EGet -Session $session -Path "/Admin/Users"
    Assert-True ($users.Content -match 'class="notion-table-container table-responsive"') "Users directory missing responsive table container"
}

# ==============================================================================
# GROUP 10: STRESS, CONCURRENCY & ZERO EMOJIS AUDIT
# ==============================================================================

Register-ChallengerTest "CH_STRESS_01" "Stress & Concurrency" "Execute 20 rapid sequential requests to /Admin/Dashboard with session integrity" {
    $session = New-E2ESession -BaseUrl $BaseUrl
    Invoke-E2ELogin -Session $session -UsernameOrEmail "admin" -Password "Admin@123" | Out-Null

    $successCount = 0
    for ($i = 1; $i -le 20; $i++) {
        $r = Invoke-E2EGet -Session $session -Path "/Admin/Dashboard"
        if ($r.StatusCode -eq 200 -and $r.Content -match 'Administrator Dashboard') {
            $successCount++
        }
    }
    Assert-True ($successCount -eq 20) "Rapid sequential requests failed: $successCount/20 succeeded"
}

Register-ChallengerTest "CH_EMOJI_01" "Zero Emojis" "Audit live /Admin/Dashboard and /Admin/Users HTML responses for zero emojis" {
    $session = New-E2ESession -BaseUrl $BaseUrl
    Invoke-E2ELogin -Session $session -UsernameOrEmail "admin" -Password "Admin@123" | Out-Null

    $dash = Invoke-E2EGet -Session $session -Path "/Admin/Dashboard"
    $users = Invoke-E2EGet -Session $session -Path "/Admin/Users"

    # Comprehensive regex matching Unicode emojis and surrogate pairs
    $emojiPattern = '[\uD83C-\uDBFF\uDC00-\uDFFF\u2600-\u26FF\u2700-\u27BF\uFE00-\uFE0F]'

    $dashMatches = [regex]::Matches($dash.Content, $emojiPattern)
    Assert-True ($dashMatches.Count -eq 0) "Found $($dashMatches.Count) emoji characters on /Admin/Dashboard"

    $usersMatches = [regex]::Matches($users.Content, $emojiPattern)
    Assert-True ($usersMatches.Count -eq 0) "Found $($usersMatches.Count) emoji characters on /Admin/Users"
}

# ==============================================================================
# RUNNER & REPORTING
# ==============================================================================

Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host " Challenger 2 - Admin Views & System Regression Test Harness" -ForegroundColor Cyan
Write-Host " Target Base URL: $BaseUrl" -ForegroundColor Cyan
Write-Host " Tests Registered: $($Script:ChallengerTests.Count)" -ForegroundColor Cyan
Write-Host " Timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Cyan
Write-Host "================================================================================" -ForegroundColor Cyan

$sw = [System.Diagnostics.Stopwatch]::StartNew()

foreach ($test in $Script:ChallengerTests) {
    try {
        & $test.Action
        $Script:PassedCount++
        Write-Host " [PASS] $($test.Id) - $($test.Category): $($test.Description)" -ForegroundColor Green
    } catch {
        $Script:FailedCount++
        Write-Host " [FAIL] $($test.Id) - $($test.Category): $($test.Description)" -ForegroundColor Red
        Write-Host "        Error: $($_.Exception.Message)" -ForegroundColor DarkRed
    }
}

$sw.Stop()

Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host " TEST EXECUTION SUMMARY" -ForegroundColor Cyan
Write-Host " Total Tests: $($Script:ChallengerTests.Count)" -ForegroundColor Cyan
Write-Host " Passed:      $Script:PassedCount" -ForegroundColor Green
Write-Host " Failed:      $Script:FailedCount" -ForegroundColor $(if ($Script:FailedCount -gt 0) { "Red" } else { "Green" })
Write-Host " Elapsed:     $([Math]::Round($sw.Elapsed.TotalSeconds, 2)) seconds" -ForegroundColor Cyan
Write-Host "================================================================================" -ForegroundColor Cyan

if ($Script:FailedCount -gt 0) {
    exit 1
} else {
    exit 0
}
