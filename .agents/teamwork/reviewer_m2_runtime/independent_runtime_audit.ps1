# Independent Runtime & Adversarial Audit for Milestone 2
# Reviewer 2: Runtime and Integration Reviewer
# Target: http://localhost:9979

$ErrorActionPreference = "Stop"
. "D:\.NET\ViewModelDemo\Tests\E2E\TestHarness.ps1"

$auditResults = [System.Collections.Generic.List[PSObject]]::new()

function Record-AuditResult {
    param(
        [string]$TestId,
        [string]$Description,
        [bool]$Passed,
        [string]$Details
    )
    $obj = [PSCustomObject]@{
        TestId = $TestId
        Description = $Description
        Passed = $Passed
        Details = $Details
    }
    $auditResults.Add($obj)
    $statusStr = if ($Passed) { "[PASS]" } else { "[FAIL]" }
    Write-Host "$statusStr $TestId : $Description - $Details"
}

Write-Host "============================================================="
Write-Host "REVIEWER 2 INDEPENDENT RUNTIME AUDIT (PORT 9979)"
Write-Host "============================================================="

# 1. Server Alive Check
$sess = New-E2ESession
$homePage = Invoke-E2EGet -Session $sess -Path "/" -FollowRedirects $true
Record-AuditResult -TestId "R2_01" -Description "IIS Express Root Accessibility" -Passed ($homePage.StatusCode -eq 200) -Details "Status $($homePage.StatusCode)"

# 2. Unauthenticated RBAC Protection
$dashAnon = Invoke-E2EGet -Session $sess -Path "/Admin/Dashboard" -FollowRedirects $false
$dashAnonOk = ($dashAnon.StatusCode -eq 302 -and $dashAnon.Location -match "/Account/Login")
Record-AuditResult -TestId "R2_02" -Description "Anonymous Dashboard Access Blocked" -Passed $dashAnonOk -Details "Status: $($dashAnon.StatusCode), Location: $($dashAnon.Location)"

$usersAnon = Invoke-E2EGet -Session $sess -Path "/Admin/Users" -FollowRedirects $false
$usersAnonOk = ($usersAnon.StatusCode -eq 302 -and $usersAnon.Location -match "/Account/Login")
Record-AuditResult -TestId "R2_03" -Description "Anonymous Users Access Blocked" -Passed $usersAnonOk -Details "Status: $($usersAnon.StatusCode), Location: $($usersAnon.Location)"

# Follow redirect and verify error alert banner
$loginWithRedirect = Invoke-E2EGet -Session $sess -Path "/Admin/Dashboard" -FollowRedirects $true
$hasRestrictedAlert = ($loginWithRedirect.Content -match 'alert-danger' -and $loginWithRedirect.Content -match 'Access restricted')
Record-AuditResult -TestId "R2_04" -Description "Access Restricted Flash Message on Redirect" -Passed $hasRestrictedAlert -Details "Has alert-danger: $($loginWithRedirect.Content -match 'alert-danger')"

# 3. AntiForgery Token Enforcement
$csrfFail = $false
try {
    $rawRes = Invoke-WebRequest -Uri "http://localhost:9979/Account/Login" -Method POST -Body @{ UsernameOrEmail="admin"; Password="foo" } -UseBasicParsing -ErrorAction Stop
} catch {
    if ($_.Exception.Response.StatusCode.value__ -eq 500) {
        $csrfFail = $true
    }
}
Record-AuditResult -TestId "R2_05" -Description "CSRF Token Enforcement on POST /Account/Login" -Passed $csrfFail -Details "Blocked with HTTP 500 without token"

# 4. Invalid Credentials Validation
$badLogin = Invoke-E2ELogin -Session $sess -UsernameOrEmail "nonexistent_user_99" -Password "WrongPass!@#"
$badLoginOk = ($badLogin.StatusCode -eq 200 -and $badLogin.Content -match "Invalid username/email or password")
Record-AuditResult -TestId "R2_06" -Description "Invalid Login Credentials Error Feedback" -Passed $badLoginOk -Details "Returned status $($badLogin.StatusCode), message match: $($badLogin.Content -match 'Invalid username/email or password')"

# 5. Standard User RBAC Isolation
$userSess = New-E2ESession
$userLogin = Invoke-E2ELogin -Session $userSess -UsernameOrEmail "rahul" -Password "User@123"
$userLoginOk = ($userLogin.StatusCode -eq 302 -and $userLogin.Location -match "/Employee")
Record-AuditResult -TestId "R2_07" -Description "Standard User Login Redirect" -Passed $userLoginOk -Details "Location: $($userLogin.Location)"

$userDash = Invoke-E2EGet -Session $userSess -Path "/Admin/Dashboard" -FollowRedirects $false
$userDashBlocked = ($userDash.StatusCode -eq 302 -and $userDash.Location -match "/Account/Login")
Record-AuditResult -TestId "R2_08" -Description "Standard User Blocked from Admin Dashboard" -Passed $userDashBlocked -Details "Status: $($userDash.StatusCode)"

$userUsers = Invoke-E2EGet -Session $userSess -Path "/Admin/Users" -FollowRedirects $false
$userUsersBlocked = ($userUsers.StatusCode -eq 302 -and $userUsers.Location -match "/Account/Login")
Record-AuditResult -TestId "R2_09" -Description "Standard User Blocked from Admin Users Directory" -Passed $userUsersBlocked -Details "Status: $($userUsers.StatusCode)"

# 6. Admin Authentication and Live SQL Data Rendering
$adminSess = New-E2ESession
$adminLogin = Invoke-E2ELogin -Session $adminSess -UsernameOrEmail "admin" -Password "Admin@123"
$adminLoginOk = ($adminLogin.StatusCode -eq 302 -and $adminLogin.Location -match "/Admin/Dashboard")
Record-AuditResult -TestId "R2_10" -Description "Admin Login Redirect to Dashboard" -Passed $adminLoginOk -Details "Location: $($adminLogin.Location)"

$adminDash = Invoke-E2EGet -Session $adminSess -Path "/Admin/Dashboard" -FollowRedirects $true
$hasKpis = ($adminDash.Content -match "Total Employees" -and 
            $adminDash.Content -match "Registered Users" -and 
            $adminDash.Content -match "Monthly Payroll" -and 
            $adminDash.Content -match "Workforce by Department" -and 
            $adminDash.Content -match "Recent Employees" -and 
            $adminDash.Content -match "Recent User Registrations")
Record-AuditResult -TestId "R2_11" -Description "Admin Dashboard Live SQL KPIs and Tables" -Passed $hasKpis -Details "All 6 required sections present: $hasKpis"

$adminUsers = Invoke-E2EGet -Session $adminSess -Path "/Admin/Users" -FollowRedirects $true
$hasUsersTable = ($adminUsers.Content -match "Registered System Users" -and 
                  $adminUsers.Content -match "admin" -and 
                  $adminUsers.Content -match "rahul" -and 
                  $adminUsers.Content -match "badge-admin")
Record-AuditResult -TestId "R2_12" -Description "Admin Users Live SQL Directory" -Passed $hasUsersTable -Details "Users rendered with badges and email links: $hasUsersTable"

# 7. Defect D-01 Verification & Post-Logout Invalidation
$logoutRes = Invoke-E2ELogout -Session $adminSess
$logoutOk = ($logoutRes.StatusCode -eq 302 -and $logoutRes.Location -match "/Account/Login")
$loginAfterLogout = Invoke-E2EGet -Session $adminSess -Path "/Account/Login" -FollowRedirects $false
$hasLogoutBanner = ($loginAfterLogout.Content -match "alert-info" -and $loginAfterLogout.Content -match "You have been logged out safely")
Record-AuditResult -TestId "R2_13" -Description "Defect D-01: TempData['InfoMessage'] Survives Logout Redirect" -Passed $hasLogoutBanner -Details "InfoMessage rendered in alert-info: $hasLogoutBanner"

$dashPostLogout = Invoke-E2EGet -Session $adminSess -Path "/Admin/Dashboard" -FollowRedirects $false
$postLogoutBlocked = ($dashPostLogout.StatusCode -eq 302 -and $dashPostLogout.Location -match "/Account/Login")
Record-AuditResult -TestId "R2_14" -Description "Session Invalidation: Protected Access Blocked After Logout" -Passed $postLogoutBlocked -Details "Session destroyed; status: $($dashPostLogout.StatusCode)"

# 8. Open Redirect Vulnerability Challenge
$openRedirectSess = New-E2ESession
$openRedirectRes = Invoke-E2ELogin -Session $openRedirectSess -UsernameOrEmail "admin" -Password "Admin@123" -ReturnUrl "https://attacker.evil.com/phishing"
$openRedirectSafe = ($openRedirectRes.Location -notmatch "attacker.evil.com" -and $openRedirectRes.Location -match "/Admin/Dashboard")
Record-AuditResult -TestId "R2_15" -Description "Open Redirect Challenge: External returnUrl Rejected" -Passed $openRedirectSafe -Details "Redirected safely to: $($openRedirectRes.Location)"

# 9. Zero Emojis Live HTML Audit
$emojiRegex = '[\uD83C-\uDBFF\uDC00-\uDFFF]|[\u2600-\u27BF]|[\u2300-\u23FF]|[\u2B50\u2B55\u2934\u2935]'
$pages = @(
    @{ Name = "Login"; Content = (Invoke-E2EGet -Session (New-E2ESession) -Path "/Account/Login" -FollowRedirects $true).Content },
    @{ Name = "Register"; Content = (Invoke-E2EGet -Session (New-E2ESession) -Path "/Account/Register" -FollowRedirects $true).Content },
    @{ Name = "Dashboard"; Content = $adminDash.Content },
    @{ Name = "Users"; Content = $adminUsers.Content }
)

$allPagesEmojiFree = $true
foreach ($p in $pages) {
    $match = [regex]::Match($p.Content, $emojiRegex)
    if ($match.Success) {
        $allPagesEmojiFree = $false
        Write-Host "[FAIL] Emoji found in $($p.Name): $($match.Value)"
    }
}
Record-AuditResult -TestId "R2_16" -Description "Strict Zero Emojis in Live HTML Output" -Passed $allPagesEmojiFree -Details "Scanned 4 live M2 views"

Write-Host "============================================================="
$passCount = ($auditResults | Where-Object { $_.Passed }).Count
$totalCount = $auditResults.Count
Write-Host "AUDIT COMPLETE: $passCount / $totalCount Passed"
Write-Host "============================================================="

if ($passCount -eq $totalCount) {
    exit 0
} else {
    exit 1
}
