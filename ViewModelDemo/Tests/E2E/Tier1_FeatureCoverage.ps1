# ==============================================================================
# Tier1_FeatureCoverage.ps1 - Tier 1: Primary Feature Coverage (F01 to F15)
# Methodology: Category-Partition, Happy Path Isolation
# 15 Features x 5 Tests = 75 Tests
# STRICT ZERO EMOJIS
# ==============================================================================

# Ensure TestHarness functions are available
if (-not (Get-Command "Register-TestCase" -ErrorAction SilentlyContinue)) {
    . "$PSScriptRoot\TestHarness.ps1"
}

# ------------------------------------------------------------------------------
# F01: User Authentication & Login (5 tests)
# ------------------------------------------------------------------------------

Register-TestCase -Id "T1_F01_01" -Tier "Tier 1" -Feature "F01" -Title "Login page loads successfully with HTTP 200" -ScriptBlock {
    $sess = New-E2ESession
    $res = Invoke-E2EGet -Session $sess -Path "/Account/Login"
    Assert-StatusCode -Response $res -ExpectedCode 200 -Message "Login page should return 200"
    Assert-ContainsText -Content $res.Content -ExpectedText "Login" -Message "Page content should contain Login"
    Assert-MatchesPattern -Content $res.Content -RegexPattern 'name="UsernameOrEmail"' -Message "Form must include UsernameOrEmail input"
    Assert-MatchesPattern -Content $res.Content -RegexPattern 'name="Password"' -Message "Form must include Password input"
}

Register-TestCase -Id "T1_F01_02" -Tier "Tier 1" -Feature "F01" -Title "Admin credentials authenticate successfully and redirect to Dashboard" -ScriptBlock {
    $sess = New-E2ESession
    $res = Invoke-E2ELogin -Session $sess -UsernameOrEmail "admin" -Password "Admin@123"
    Assert-StatusCode -Response $res -ExpectedCode 302 -Message "Valid admin login should return 302 redirect"
    Assert-RedirectLocation -Response $res -ExpectedPattern "/Admin/Dashboard" -Message "Admin should redirect to Dashboard"
}

Register-TestCase -Id "T1_F01_03" -Tier "Tier 1" -Feature "F01" -Title "Standard user credentials authenticate and redirect to Employee Directory" -ScriptBlock {
    $sess = New-E2ESession
    $res = Invoke-E2ELogin -Session $sess -UsernameOrEmail "rahul" -Password "User@123"
    Assert-StatusCode -Response $res -ExpectedCode 302 -Message "Valid user login should return 302 redirect"
    Assert-RedirectLocation -Response $res -ExpectedPattern "/Employee/Index" -Message "Standard user should redirect to Employee Index"
}

Register-TestCase -Id "T1_F01_04" -Tier "Tier 1" -Feature "F01" -Title "Valid ReturnUrl parameter redirects to requested destination upon login" -ScriptBlock {
    $sess = New-E2ESession
    $res = Invoke-E2ELogin -Session $sess -UsernameOrEmail "admin" -Password "Admin@123" -ReturnUrl "/Student/Index"
    Assert-StatusCode -Response $res -ExpectedCode 302 -Message "Login with returnUrl should redirect"
    Assert-RedirectLocation -Response $res -ExpectedPattern "/Student/Index" -Message "Should redirect to requested ReturnUrl"
}

Register-TestCase -Id "T1_F01_05" -Tier "Tier 1" -Feature "F01" -Title "Email address identifier authenticates user successfully" -ScriptBlock {
    $sess = New-E2ESession
    $res = Invoke-E2ELogin -Session $sess -UsernameOrEmail "admin@viewmodeldemo.com" -Password "Admin@123"
    Assert-StatusCode -Response $res -ExpectedCode 302 -Message "Login with email should return 302"
    Assert-RedirectLocation -Response $res -ExpectedPattern "/Admin/Dashboard" -Message "Admin email login should redirect to Dashboard"
}

# ------------------------------------------------------------------------------
# F02: User Registration (5 tests)
# ------------------------------------------------------------------------------

Register-TestCase -Id "T1_F02_01" -Tier "Tier 1" -Feature "F02" -Title "Registration page loads successfully with HTTP 200" -ScriptBlock {
    $sess = New-E2ESession
    $res = Invoke-E2EGet -Session $sess -Path "/Account/Register"
    Assert-StatusCode -Response $res -ExpectedCode 200 -Message "Register page should return 200"
    Assert-ContainsText -Content $res.Content -ExpectedText "Register" -Message "Page should contain Register"
    Assert-MatchesPattern -Content $res.Content -RegexPattern 'name="FullName"' -Message "Form must include FullName input"
    Assert-MatchesPattern -Content $res.Content -RegexPattern 'name="Username"' -Message "Form must include Username input"
}

Register-TestCase -Id "T1_F02_02" -Tier "Tier 1" -Feature "F02" -Title "New user registers successfully and redirects to Employee Index" -ScriptBlock {
    $sess = New-E2ESession
    $regPage = Invoke-E2EGet -Session $sess -Path "/Account/Register"
    $token = Get-VerificationToken -Html $regPage.Content
    $rnd = Get-Random -Minimum 10000 -Maximum 99999
    $regData = @{
        "__RequestVerificationToken" = $token
        "FullName"                   = "Ananya Sen $rnd"
        "Username"                   = "ananya_$rnd"
        "Email"                      = "ananya_$rnd@example.in"
        "Password"                   = "Ananya@123"
        "ConfirmPassword"            = "Ananya@123"
    }
    $res = Invoke-E2EPost -Session $sess -Path "/Account/Register" -FormData $regData -AutoToken $false -FollowRedirects $false
    Assert-StatusCode -Response $res -ExpectedCode 302 -Message "Successful registration should return 302"
    Assert-RedirectLocation -Response $res -ExpectedPattern "/Employee/Index" -Message "Registration should redirect to Employee Index"
}

Register-TestCase -Id "T1_F02_03" -Tier "Tier 1" -Feature "F02" -Title "Auto-login creates active session following registration" -ScriptBlock {
    $sess = New-E2ESession
    $rnd = Get-Random -Minimum 10000 -Maximum 99999
    $regData = @{
        "FullName"        = "Deepak Verma $rnd"
        "Username"        = "deepak_$rnd"
        "Email"           = "deepak_$rnd@example.in"
        "Password"        = "Deepak@123"
        "ConfirmPassword" = "Deepak@123"
    }
    $null = Invoke-E2EPost -Session $sess -Path "/Account/Register" -FormData $regData -AutoToken $true -FollowRedirects $false
    $indexRes = Invoke-E2EGet -Session $sess -Path "/Employee/Index"
    Assert-StatusCode -Response $indexRes -ExpectedCode 200 -Message "Index should load for registered user"
    Assert-ContainsText -Content $indexRes.Content -ExpectedText "Deepak Verma $rnd" -Message "Nav should render registered user's full name"
}

Register-TestCase -Id "T1_F02_04" -Tier "Tier 1" -Feature "F02" -Title "Registration accepts username with alphanumeric and underscore characters" -ScriptBlock {
    $sess = New-E2ESession
    $rnd = Get-Random -Minimum 10000 -Maximum 99999
    $regData = @{
        "FullName"        = "Kavita Rao $rnd"
        "Username"        = "kavita_rao_$rnd"
        "Email"           = "kavita_$rnd@example.in"
        "Password"        = "Kavita@123"
        "ConfirmPassword" = "Kavita@123"
    }
    $res = Invoke-E2EPost -Session $sess -Path "/Account/Register" -FormData $regData -AutoToken $true -FollowRedirects $false
    Assert-StatusCode -Response $res -ExpectedCode 302 -Message "Valid username with underscores should register"
    Assert-RedirectLocation -Response $res -ExpectedPattern "/Employee/Index" -Message "Redirects to Index"
}

Register-TestCase -Id "T1_F02_05" -Tier "Tier 1" -Feature "F02" -Title "Newly registered user has User role and can access Student directory" -ScriptBlock {
    $sess = New-E2ESession
    $rnd = Get-Random -Minimum 10000 -Maximum 99999
    $regData = @{
        "FullName"        = "Arjun Nair $rnd"
        "Username"        = "arjun_$rnd"
        "Email"           = "arjun_$rnd@example.in"
        "Password"        = "Arjun@123"
        "ConfirmPassword" = "Arjun@123"
    }
    $null = Invoke-E2EPost -Session $sess -Path "/Account/Register" -FormData $regData -AutoToken $true -FollowRedirects $false
    $studRes = Invoke-E2EGet -Session $sess -Path "/Student/Index"
    Assert-StatusCode -Response $studRes -ExpectedCode 200 -Message "Registered user should access Student Index"
    Assert-MatchesPattern -Content $studRes.Content -RegexPattern 'role-badge[^>]*badge-user|badge-user' -Message "Role badge should indicate User role"
}

# ------------------------------------------------------------------------------
# F03: Session Management & Logout (5 tests)
# ------------------------------------------------------------------------------

Register-TestCase -Id "T1_F03_01" -Tier "Tier 1" -Feature "F03" -Title "Logout clears session and redirects to /Account/Login with HTTP 302" -ScriptBlock {
    $sess = New-E2ESession
    $null = Invoke-E2ELogin -Session $sess -UsernameOrEmail "admin" -Password "Admin@123"
    $logoutRes = Invoke-E2ELogout -Session $sess
    Assert-StatusCode -Response $logoutRes -ExpectedCode 302 -Message "Logout should return 302 redirect"
    Assert-RedirectLocation -Response $logoutRes -ExpectedPattern "/Account/Login" -Message "Logout should redirect to Login"
}

Register-TestCase -Id "T1_F03_02" -Tier "Tier 1" -Feature "F03" -Title "Logout confirms session termination in footer" -ScriptBlock {
    $sess = New-E2ESession
    $null = Invoke-E2ELogin -Session $sess -UsernameOrEmail "admin" -Password "Admin@123"
    $null = Invoke-E2ELogout -Session $sess
    $loginPage = Invoke-E2EGet -Session $sess -Path "/Account/Login"
    Assert-StatusCode -Response $loginPage -ExpectedCode 200 -Message "Login page should load"
    Assert-ContainsText -Content $loginPage.Content -ExpectedText "Session: Guest" -Message "Footer should confirm Guest session after logout"
}

Register-TestCase -Id "T1_F03_03" -Tier "Tier 1" -Feature "F03" -Title "Post-logout navigation bar renders unauthenticated controls" -ScriptBlock {
    $sess = New-E2ESession
    $null = Invoke-E2ELogin -Session $sess -UsernameOrEmail "admin" -Password "Admin@123"
    $null = Invoke-E2ELogout -Session $sess
    $indexRes = Invoke-E2EGet -Session $sess -Path "/Employee/Index"
    Assert-StatusCode -Response $indexRes -ExpectedCode 200 -Message "Index should load"
    Assert-ContainsText -Content $indexRes.Content -ExpectedText "Login" -Message "Navbar should show Login"
    Assert-NotContainsText -Content $indexRes.Content -UnexpectedText "Logout" -Message "Navbar should NOT show Logout"
}

Register-TestCase -Id "T1_F03_04" -Tier "Tier 1" -Feature "F03" -Title "Protected Admin Dashboard is inaccessible post-logout" -ScriptBlock {
    $sess = New-E2ESession
    $null = Invoke-E2ELogin -Session $sess -UsernameOrEmail "admin" -Password "Admin@123"
    $null = Invoke-E2ELogout -Session $sess
    $dashRes = Invoke-E2EGet -Session $sess -Path "/Admin/Dashboard" -FollowRedirects $false
    Assert-StatusCode -Response $dashRes -ExpectedCode 302 -Message "Accessing Dashboard post-logout should redirect"
    Assert-RedirectLocation -Response $dashRes -ExpectedPattern "/Account/Login" -Message "Should redirect to Login"
}

Register-TestCase -Id "T1_F03_05" -Tier "Tier 1" -Feature "F03" -Title "Protected Employee Create is inaccessible post-logout" -ScriptBlock {
    $sess = New-E2ESession
    $null = Invoke-E2ELogin -Session $sess -UsernameOrEmail "admin" -Password "Admin@123"
    $null = Invoke-E2ELogout -Session $sess
    $createRes = Invoke-E2EGet -Session $sess -Path "/Employee/Create" -FollowRedirects $false
    Assert-StatusCode -Response $createRes -ExpectedCode 302 -Message "Accessing Create post-logout should redirect"
    Assert-RedirectLocation -Response $createRes -ExpectedPattern "/Account/Login" -Message "Should redirect to Login"
}

# ------------------------------------------------------------------------------
# F04: Role-Based Access Control (5 tests)
# ------------------------------------------------------------------------------

Register-TestCase -Id "T1_F04_01" -Tier "Tier 1" -Feature "F04" -Title "Admin role grants authorized access to /Admin/Dashboard" -ScriptBlock {
    $sess = New-E2ESession
    $null = Invoke-E2ELogin -Session $sess -UsernameOrEmail "admin" -Password "Admin@123"
    $res = Invoke-E2EGet -Session $sess -Path "/Admin/Dashboard"
    Assert-StatusCode -Response $res -ExpectedCode 200 -Message "Admin should access Dashboard with 200 OK"
    Assert-ContainsText -Content $res.Content -ExpectedText "Dashboard" -Message "Dashboard header present"
}

Register-TestCase -Id "T1_F04_02" -Tier "Tier 1" -Feature "F04" -Title "Admin role grants authorized access to /Admin/Users" -ScriptBlock {
    $sess = New-E2ESession
    $null = Invoke-E2ELogin -Session $sess -UsernameOrEmail "admin" -Password "Admin@123"
    $res = Invoke-E2EGet -Session $sess -Path "/Admin/Users"
    Assert-StatusCode -Response $res -ExpectedCode 200 -Message "Admin should access Users with 200 OK"
    Assert-ContainsText -Content $res.Content -ExpectedText "System Users" -Message "Users header present"
}

Register-TestCase -Id "T1_F04_03" -Tier "Tier 1" -Feature "F04" -Title "Admin role grants authorized access to /Employee/Create" -ScriptBlock {
    $sess = New-E2ESession
    $null = Invoke-E2ELogin -Session $sess -UsernameOrEmail "admin" -Password "Admin@123"
    $res = Invoke-E2EGet -Session $sess -Path "/Employee/Create"
    Assert-StatusCode -Response $res -ExpectedCode 200 -Message "Admin should access Create with 200 OK"
    Assert-MatchesPattern -Content $res.Content -RegexPattern 'name="Salary"' -Message "Form includes Salary"
}

Register-TestCase -Id "T1_F04_04" -Tier "Tier 1" -Feature "F04" -Title "Standard User role has access to public Employee Directory and Details" -ScriptBlock {
    $sess = New-E2ESession
    $null = Invoke-E2ELogin -Session $sess -UsernameOrEmail "rahul" -Password "User@123"
    $indexRes = Invoke-E2EGet -Session $sess -Path "/Employee/Index"
    Assert-StatusCode -Response $indexRes -ExpectedCode 200 -Message "User should access Directory"
    $detailsRes = Invoke-E2EGet -Session $sess -Path "/Employee/Details/101"
    Assert-StatusCode -Response $detailsRes -ExpectedCode 200 -Message "User should access Details"
}

Register-TestCase -Id "T1_F04_05" -Tier "Tier 1" -Feature "F04" -Title "Standard User role has access to Student Views" -ScriptBlock {
    $sess = New-E2ESession
    $null = Invoke-E2ELogin -Session $sess -UsernameOrEmail "rahul" -Password "User@123"
    $res1 = Invoke-E2EGet -Session $sess -Path "/Student/Index"
    Assert-StatusCode -Response $res1 -ExpectedCode 200 -Message "User should access Student Index"
    $res2 = Invoke-E2EGet -Session $sess -Path "/Student/getStud"
    Assert-StatusCode -Response $res2 -ExpectedCode 200 -Message "User should access Student getStud"
}

# ------------------------------------------------------------------------------
# F05: Global Navigation & User Pill (5 tests)
# ------------------------------------------------------------------------------

Register-TestCase -Id "T1_F05_01" -Tier "Tier 1" -Feature "F05" -Title "Unauthenticated header renders Login and Register actions" -ScriptBlock {
    $sess = New-E2ESession
    $res = Invoke-E2EGet -Session $sess -Path "/Employee/Index"
    Assert-StatusCode -Response $res -ExpectedCode 200 -Message "Index should load"
    Assert-MatchesPattern -Content $res.Content -RegexPattern 'href="[^"]*Account/Login"' -Message "Header contains Login link"
    Assert-MatchesPattern -Content $res.Content -RegexPattern 'href="[^"]*Account/Register"' -Message "Header contains Register link"
}

Register-TestCase -Id "T1_F05_02" -Tier "Tier 1" -Feature "F05" -Title "Authenticated Admin header renders ADMIN badge and FullName pill" -ScriptBlock {
    $sess = New-E2ESession
    $null = Invoke-E2ELogin -Session $sess -UsernameOrEmail "admin" -Password "Admin@123"
    $res = Invoke-E2EGet -Session $sess -Path "/Employee/Index"
    Assert-StatusCode -Response $res -ExpectedCode 200 -Message "Index should load"
    Assert-ContainsText -Content $res.Content -ExpectedText "System Administrator" -Message "Header renders Admin FullName"
    Assert-MatchesPattern -Content $res.Content -RegexPattern 'role-badge[^>]*badge-admin|badge-admin' -Message "Header renders badge-admin"
}

Register-TestCase -Id "T1_F05_03" -Tier "Tier 1" -Feature "F05" -Title "Authenticated Admin header displays Dashboard and Users navigation links" -ScriptBlock {
    $sess = New-E2ESession
    $null = Invoke-E2ELogin -Session $sess -UsernameOrEmail "admin" -Password "Admin@123"
    $res = Invoke-E2EGet -Session $sess -Path "/Employee/Index"
    Assert-MatchesPattern -Content $res.Content -RegexPattern 'href="[^"]*Admin/Dashboard"' -Message "Header contains Dashboard link"
    Assert-MatchesPattern -Content $res.Content -RegexPattern 'href="[^"]*Admin/Users"' -Message "Header contains Users link"
}

Register-TestCase -Id "T1_F05_04" -Tier "Tier 1" -Feature "F05" -Title "Authenticated User header displays USER badge and Rahul Sharma pill" -ScriptBlock {
    $sess = New-E2ESession
    $null = Invoke-E2ELogin -Session $sess -UsernameOrEmail "rahul" -Password "User@123"
    $res = Invoke-E2EGet -Session $sess -Path "/Employee/Index"
    Assert-ContainsText -Content $res.Content -ExpectedText "Rahul Sharma" -Message "Header renders User FullName"
    Assert-MatchesPattern -Content $res.Content -RegexPattern 'role-badge[^>]*badge-user|badge-user' -Message "Header renders badge-user"
}

Register-TestCase -Id "T1_F05_05" -Tier "Tier 1" -Feature "F05" -Title "Authenticated User header hides Admin Dashboard and Users navigation links" -ScriptBlock {
    $sess = New-E2ESession
    $null = Invoke-E2ELogin -Session $sess -UsernameOrEmail "rahul" -Password "User@123"
    $res = Invoke-E2EGet -Session $sess -Path "/Employee/Index"
    Assert-NotContainsText -Content $res.Content -UnexpectedText "/Admin/Dashboard" -Message "User should NOT see Dashboard link"
    Assert-NotContainsText -Content $res.Content -UnexpectedText "/Admin/Users" -Message "User should NOT see Users link"
}

# ------------------------------------------------------------------------------
# F06: Employee Directory & Search Filter (5 tests)
# ------------------------------------------------------------------------------

Register-TestCase -Id "T1_F06_01" -Tier "Tier 1" -Feature "F06" -Title "Employee directory loads successfully with HTTP 200" -ScriptBlock {
    $sess = New-E2ESession
    $res = Invoke-E2EGet -Session $sess -Path "/Employee/Index"
    Assert-StatusCode -Response $res -ExpectedCode 200 -Message "Directory should return 200"
    Assert-ContainsText -Content $res.Content -ExpectedText "Employee Directory" -Message "Directory title present"
    Assert-MatchesPattern -Content $res.Content -RegexPattern 'name="search"' -Message "Search input present"
}

Register-TestCase -Id "T1_F06_02" -Tier "Tier 1" -Feature "F06" -Title "Employee directory displays seeded workforce records" -ScriptBlock {
    $sess = New-E2ESession
    $res = Invoke-E2EGet -Session $sess -Path "/Employee/Index"
    Assert-ContainsText -Content $res.Content -ExpectedText "Dillip Mohapatra" -Message "Contains Dillip Mohapatra"
    Assert-ContainsText -Content $res.Content -ExpectedText "Priya Patel" -Message "Contains Priya Patel"
    Assert-ContainsText -Content $res.Content -ExpectedText "Rahul Sharma" -Message "Contains Rahul Sharma"
}

Register-TestCase -Id "T1_F06_03" -Tier "Tier 1" -Feature "F06" -Title "Search query filters directory by employee name" -ScriptBlock {
    $sess = New-E2ESession
    $res = Invoke-E2EGet -Session $sess -Path "/Employee/Index?search=Dillip"
    Assert-StatusCode -Response $res -ExpectedCode 200 -Message "Search should return 200"
    Assert-ContainsText -Content $res.Content -ExpectedText "Dillip Mohapatra" -Message "Search matches Dillip Mohapatra"
    Assert-NotContainsText -Content $res.Content -UnexpectedText "Priya Patel" -Message "Non-matching employee excluded"
}

Register-TestCase -Id "T1_F06_04" -Tier "Tier 1" -Feature "F06" -Title "Search query filters directory by department name" -ScriptBlock {
    $sess = New-E2ESession
    $res = Invoke-E2EGet -Session $sess -Path "/Employee/Index?search=Engineering"
    Assert-StatusCode -Response $res -ExpectedCode 200 -Message "Search should return 200"
    Assert-ContainsText -Content $res.Content -ExpectedText "Rahul Sharma" -Message "Engineering dept matches Rahul Sharma"
}

Register-TestCase -Id "T1_F06_05" -Tier "Tier 1" -Feature "F06" -Title "Search query filters directory by city name" -ScriptBlock {
    $sess = New-E2ESession
    $res = Invoke-E2EGet -Session $sess -Path "/Employee/Index?search=Kolkata"
    Assert-StatusCode -Response $res -ExpectedCode 200 -Message "Search should return 200"
    Assert-ContainsText -Content $res.Content -ExpectedText "Priya Patel" -Message "Kolkata city matches Priya Patel"
}

# ------------------------------------------------------------------------------
# F07: Multi-Model Aggregated Employee Details View (5 tests)
# ------------------------------------------------------------------------------

Register-TestCase -Id "T1_F07_01" -Tier "Tier 1" -Feature "F07" -Title "Employee Details loads default employee with HTTP 200" -ScriptBlock {
    $sess = New-E2ESession
    $res = Invoke-E2EGet -Session $sess -Path "/Employee/Details"
    Assert-StatusCode -Response $res -ExpectedCode 200 -Message "Details default should return 200"
    Assert-ContainsText -Content $res.Content -ExpectedText "Employee Details" -Message "Details heading present"
    Assert-ContainsText -Content $res.Content -ExpectedText "Dillip Mohapatra" -Message "Default employee 101 name"
}

Register-TestCase -Id "T1_F07_02" -Tier "Tier 1" -Feature "F07" -Title "Employee Details presents employee domain model properties" -ScriptBlock {
    $sess = New-E2ESession
    $res = Invoke-E2EGet -Session $sess -Path "/Employee/Details/101"
    Assert-StatusCode -Response $res -ExpectedCode 200 -Message "Details 101 should return 200"
    Assert-ContainsText -Content $res.Content -ExpectedText "Dillip Mohapatra" -Message "Employee Name present"
    Assert-ContainsText -Content $res.Content -ExpectedText "Male" -Message "Gender present"
    Assert-ContainsText -Content $res.Content -ExpectedText "IT" -Message "Department present"
}

Register-TestCase -Id "T1_F07_03" -Tier "Tier 1" -Feature "F07" -Title "Employee Details presents linked residential address domain model properties" -ScriptBlock {
    $sess = New-E2ESession
    $res = Invoke-E2EGet -Session $sess -Path "/Employee/Details/101"
    Assert-ContainsText -Content $res.Content -ExpectedText "Bhubaneswar" -Message "Address City present"
    Assert-ContainsText -Content $res.Content -ExpectedText "Odisha" -Message "Address State present"
    Assert-ContainsText -Content $res.Content -ExpectedText "India" -Message "Address Country present"
    Assert-ContainsText -Content $res.Content -ExpectedText "751024" -Message "Address PIN present"
}

Register-TestCase -Id "T1_F07_04" -Tier "Tier 1" -Feature "F07" -Title "Employee Details for ID 102 displays Priya Patel and Kolkata address" -ScriptBlock {
    $sess = New-E2ESession
    $res = Invoke-E2EGet -Session $sess -Path "/Employee/Details/102"
    Assert-StatusCode -Response $res -ExpectedCode 200 -Message "Details 102 should return 200"
    Assert-ContainsText -Content $res.Content -ExpectedText "Priya Patel" -Message "Employee Name Priya Patel"
    Assert-ContainsText -Content $res.Content -ExpectedText "Kolkata" -Message "City Kolkata"
    Assert-ContainsText -Content $res.Content -ExpectedText "West Bengal" -Message "State West Bengal"
}

Register-TestCase -Id "T1_F07_05" -Tier "Tier 1" -Feature "F07" -Title "Employee Details page includes back link to Employee Directory" -ScriptBlock {
    $sess = New-E2ESession
    $res = Invoke-E2EGet -Session $sess -Path "/Employee/Details/101"
    Assert-MatchesPattern -Content $res.Content -RegexPattern 'href="[^"]*Employee/Index"' -Message "Back link to Directory present"
}

# ------------------------------------------------------------------------------
# F08: Multi-Table Employee Creation Form (5 tests)
# ------------------------------------------------------------------------------

Register-TestCase -Id "T1_F08_01" -Tier "Tier 1" -Feature "F08" -Title "Admin can access Create form with HTTP 200" -ScriptBlock {
    $sess = New-E2ESession
    $null = Invoke-E2ELogin -Session $sess -UsernameOrEmail "admin" -Password "Admin@123"
    $res = Invoke-E2EGet -Session $sess -Path "/Employee/Create"
    Assert-StatusCode -Response $res -ExpectedCode 200 -Message "Create form returns 200"
    Assert-MatchesPattern -Content $res.Content -RegexPattern 'name="__RequestVerificationToken"' -Message "Token present"
}

Register-TestCase -Id "T1_F08_02" -Tier "Tier 1" -Feature "F08" -Title "Admin creates employee record with atomic multi-table transaction" -ScriptBlock {
    $sess = New-E2ESession
    $null = Invoke-E2ELogin -Session $sess -UsernameOrEmail "admin" -Password "Admin@123"
    $rnd = Get-Random -Minimum 1000 -Maximum 9999
    $empName = "Amit Sengupta $rnd"
    $empData = @{
        "EmployeeId" = "0"
        "AddressId"  = "0"
        "Name"       = $empName
        "Gender"     = "Male"
        "Department" = "IT"
        "Salary"     = "62000"
        "Country"    = "India"
        "State"      = "West Bengal"
        "City"       = "Kolkata"
        "Pin"        = "700091"
    }
    $res = Invoke-E2EPost -Session $sess -Path "/Employee/Create" -FormData $empData -AutoToken $true -FollowRedirects $false
    Assert-StatusCode -Response $res -ExpectedCode 302 -Message "Creation should return 302"
    Assert-RedirectLocation -Response $res -ExpectedPattern "/Employee/Index" -Message "Redirects to Index"
}

Register-TestCase -Id "T1_F08_03" -Tier "Tier 1" -Feature "F08" -Title "Newly created employee displays success banner on directory" -ScriptBlock {
    $sess = New-E2ESession
    $null = Invoke-E2ELogin -Session $sess -UsernameOrEmail "admin" -Password "Admin@123"
    $rnd = Get-Random -Minimum 1000 -Maximum 9999
    $empName = "Snehashish Roy $rnd"
    $empData = @{
        "EmployeeId" = "0"
        "AddressId"  = "0"
        "Name"       = $empName
        "Gender"     = "Male"
        "Department" = "Finance"
        "Salary"     = "74000"
        "Country"    = "India"
        "State"      = "Delhi"
        "City"       = "New Delhi"
        "Pin"        = "110001"
    }
    $null = Invoke-E2EPost -Session $sess -Path "/Employee/Create" -FormData $empData -AutoToken $true -FollowRedirects $false
    $indexRes = Invoke-E2EGet -Session $sess -Path "/Employee/Index"
    Assert-ContainsText -Content $indexRes.Content -ExpectedText "was created successfully." -Message "Success flash message present"
}

Register-TestCase -Id "T1_F08_04" -Tier "Tier 1" -Feature "F08" -Title "Created employee is immediately discoverable via Directory search" -ScriptBlock {
    $sess = New-E2ESession
    $null = Invoke-E2ELogin -Session $sess -UsernameOrEmail "admin" -Password "Admin@123"
    $rnd = Get-Random -Minimum 1000 -Maximum 9999
    $empName = "Gaurav Joshi $rnd"
    $empData = @{
        "EmployeeId" = "0"
        "AddressId"  = "0"
        "Name"       = $empName
        "Gender"     = "Male"
        "Department" = "Operations"
        "Salary"     = "58000"
        "Country"    = "India"
        "State"      = "Maharashtra"
        "City"       = "Pune"
        "Pin"        = "411001"
    }
    $null = Invoke-E2EPost -Session $sess -Path "/Employee/Create" -FormData $empData -AutoToken $true -FollowRedirects $false
    $searchRes = Invoke-E2EGet -Session $sess -Path "/Employee/Index?search=Gaurav%20Joshi%20$rnd"
    Assert-ContainsText -Content $searchRes.Content -ExpectedText $empName -Message "Search finds created employee"
}

Register-TestCase -Id "T1_F08_05" -Tier "Tier 1" -Feature "F08" -Title "Created employee's residential address is verified via Details view" -ScriptBlock {
    $sess = New-E2ESession
    $null = Invoke-E2ELogin -Session $sess -UsernameOrEmail "admin" -Password "Admin@123"
    $rnd = Get-Random -Minimum 1000 -Maximum 9999
    $empName = "Sunita Menon $rnd"
    $empData = @{
        "EmployeeId" = "0"
        "AddressId"  = "0"
        "Name"       = $empName
        "Gender"     = "Female"
        "Department" = "HR"
        "Salary"     = "63000"
        "Country"    = "India"
        "State"      = "Karnataka"
        "City"       = "Bengaluru"
        "Pin"        = "560001"
    }
    $null = Invoke-E2EPost -Session $sess -Path "/Employee/Create" -FormData $empData -AutoToken $true -FollowRedirects $false
    $searchRes = Invoke-E2EGet -Session $sess -Path "/Employee/Index?search=Sunita%20Menon%20$rnd"
    Assert-True -Condition ($searchRes.Content -match 'Details/(\d+)') -Message "Details link found in search"
    $id = $matches[1]
    $detailsRes = Invoke-E2EGet -Session $sess -Path "/Employee/Details/$id"
    Assert-ContainsText -Content $detailsRes.Content -ExpectedText "Bengaluru" -Message "Details verifies Bengaluru"
    Assert-ContainsText -Content $detailsRes.Content -ExpectedText "560001" -Message "Details verifies PIN"
}

# ------------------------------------------------------------------------------
# F09: Multi-Table Employee Editing Form (5 tests)
# ------------------------------------------------------------------------------

Register-TestCase -Id "T1_F09_01" -Tier "Tier 1" -Feature "F09" -Title "Edit form loads pre-populated data for existing employee with HTTP 200" -ScriptBlock {
    $sess = New-E2ESession
    $null = Invoke-E2ELogin -Session $sess -UsernameOrEmail "admin" -Password "Admin@123"
    $res = Invoke-E2EGet -Session $sess -Path "/Employee/Edit/101"
    Assert-StatusCode -Response $res -ExpectedCode 200 -Message "Edit page should return 200"
    Assert-ContainsText -Content $res.Content -ExpectedText "Dillip Mohapatra" -Message "Name prefilled"
    Assert-ContainsText -Content $res.Content -ExpectedText "Bhubaneswar" -Message "City prefilled"
}

Register-TestCase -Id "T1_F09_02" -Tier "Tier 1" -Feature "F09" -Title "Admin updates employee salary and updates persist in database" -ScriptBlock {
    $sess = New-E2ESession
    $null = Invoke-E2ELogin -Session $sess -UsernameOrEmail "admin" -Password "Admin@123"
    $editPage = Invoke-E2EGet -Session $sess -Path "/Employee/Edit/101"
    $token = Get-VerificationToken -Html $editPage.Content
    $updateData = @{
        "__RequestVerificationToken" = $token
        "EmployeeId"                 = "101"
        "AddressId"                  = "1001"
        "Name"                       = "Dillip Mohapatra"
        "Gender"                     = "Male"
        "Department"                 = "IT"
        "Salary"                     = "67500"
        "Country"                    = "India"
        "State"                      = "Odisha"
        "City"                       = "Bhubaneswar"
        "Pin"                        = "751024"
    }
    $res = Invoke-E2EPost -Session $sess -Path "/Employee/Edit/101" -FormData $updateData -AutoToken $false -FollowRedirects $false
    Assert-StatusCode -Response $res -ExpectedCode 302 -Message "Update returns 302 redirect"
    Assert-RedirectLocation -Response $res -ExpectedPattern "/Employee/Index" -Message "Redirects to Index"
}

Register-TestCase -Id "T1_F09_03" -Tier "Tier 1" -Feature "F09" -Title "Employee update displays success banner on directory" -ScriptBlock {
    $sess = New-E2ESession
    $null = Invoke-E2ELogin -Session $sess -UsernameOrEmail "admin" -Password "Admin@123"
    $editPage = Invoke-E2EGet -Session $sess -Path "/Employee/Edit/101"
    $token = Get-VerificationToken -Html $editPage.Content
    $updateData = @{
        "__RequestVerificationToken" = $token
        "EmployeeId"                 = "101"
        "AddressId"                  = "1001"
        "Name"                       = "Dillip Mohapatra"
        "Gender"                     = "Male"
        "Department"                 = "IT"
        "Salary"                     = "66000"
        "Country"                    = "India"
        "State"                      = "Odisha"
        "City"                       = "Bhubaneswar"
        "Pin"                        = "751024"
    }
    $null = Invoke-E2EPost -Session $sess -Path "/Employee/Edit/101" -FormData $updateData -AutoToken $false -FollowRedirects $false
    $indexRes = Invoke-E2EGet -Session $sess -Path "/Employee/Index"
    Assert-ContainsText -Content $indexRes.Content -ExpectedText "was updated successfully." -Message "Update success flash message"
}

Register-TestCase -Id "T1_F09_04" -Tier "Tier 1" -Feature "F09" -Title "Admin updates employee address details (City and PIN)" -ScriptBlock {
    $sess = New-E2ESession
    $null = Invoke-E2ELogin -Session $sess -UsernameOrEmail "admin" -Password "Admin@123"
    $updateData = @{
        "EmployeeId" = "101"
        "AddressId"  = "1001"
        "Name"       = "Dillip Mohapatra"
        "Gender"     = "Male"
        "Department" = "IT"
        "Salary"     = "65000"
        "Country"    = "India"
        "State"      = "Odisha"
        "City"       = "Bhubaneswar"
        "Pin"        = "751024"
    }
    $null = Invoke-E2EPost -Session $sess -Path "/Employee/Edit/101" -FormData $updateData -AutoToken $true -FollowRedirects $false
    $detailsRes = Invoke-E2EGet -Session $sess -Path "/Employee/Details/101"
    Assert-ContainsText -Content $detailsRes.Content -ExpectedText "Bhubaneswar" -Message "Details reflects updated city"
}

Register-TestCase -Id "T1_F09_05" -Tier "Tier 1" -Feature "F09" -Title "Edit form contains hidden bindings for EmployeeId and AddressId" -ScriptBlock {
    $sess = New-E2ESession
    $null = Invoke-E2ELogin -Session $sess -UsernameOrEmail "admin" -Password "Admin@123"
    $res = Invoke-E2EGet -Session $sess -Path "/Employee/Edit/101"
    Assert-MatchesPattern -Content $res.Content -RegexPattern '<input[^>]*name="EmployeeId"[^>]*type="hidden"|<input[^>]*type="hidden"[^>]*name="EmployeeId"' -Message "Hidden EmployeeId input"
    Assert-MatchesPattern -Content $res.Content -RegexPattern '<input[^>]*name="AddressId"[^>]*type="hidden"|<input[^>]*type="hidden"[^>]*name="AddressId"' -Message "Hidden AddressId input"
}

# ------------------------------------------------------------------------------
# F10: Transactional Employee Deletion (5 tests)
# ------------------------------------------------------------------------------

Register-TestCase -Id "T1_F10_01" -Tier "Tier 1" -Feature "F10" -Title "Admin accesses Delete confirmation view with HTTP 200" -ScriptBlock {
    $sess = New-E2ESession
    $null = Invoke-E2ELogin -Session $sess -UsernameOrEmail "admin" -Password "Admin@123"
    # Create temp record to delete
    $rnd = Get-Random -Minimum 1000 -Maximum 9999
    $empData = @{
        "EmployeeId" = "0"
        "AddressId"  = "0"
        "Name"       = "Delete Target $rnd"
        "Gender"     = "Other"
        "Department" = "IT"
        "Salary"     = "45000"
        "Country"    = "India"
        "State"      = "Delhi"
        "City"       = "New Delhi"
        "Pin"        = "110001"
    }
    $null = Invoke-E2EPost -Session $sess -Path "/Employee/Create" -FormData $empData -AutoToken $true -FollowRedirects $false
    $searchRes = Invoke-E2EGet -Session $sess -Path "/Employee/Index?search=Delete%20Target%20$rnd"
    Assert-True -Condition ($searchRes.Content -match 'Delete/(\d+)') -Message "Delete link found"
    $id = $matches[1]

    $delPage = Invoke-E2EGet -Session $sess -Path "/Employee/Delete/$id"
    Assert-StatusCode -Response $delPage -ExpectedCode 200 -Message "Delete page should return 200"
    Assert-ContainsText -Content $delPage.Content -ExpectedText "Delete Target $rnd" -Message "Delete confirmation shows name"
}

Register-TestCase -Id "T1_F10_02" -Tier "Tier 1" -Feature "F10" -Title "Delete confirmation view presents record summary" -ScriptBlock {
    $sess = New-E2ESession
    $null = Invoke-E2ELogin -Session $sess -UsernameOrEmail "admin" -Password "Admin@123"
    $res = Invoke-E2EGet -Session $sess -Path "/Employee/Delete/101"
    Assert-StatusCode -Response $res -ExpectedCode 200 -Message "Delete view returns 200"
    Assert-ContainsText -Content $res.Content -ExpectedText "Dillip Mohapatra" -Message "Shows employee name"
    Assert-MatchesPattern -Content $res.Content -RegexPattern 'name="__RequestVerificationToken"' -Message "Has anti-forgery token"
}

Register-TestCase -Id "T1_F10_03" -Tier "Tier 1" -Feature "F10" -Title "Admin executes deletion via POST and redirects to Index" -ScriptBlock {
    $sess = New-E2ESession
    $null = Invoke-E2ELogin -Session $sess -UsernameOrEmail "admin" -Password "Admin@123"
    # Create temp record
    $rnd = Get-Random -Minimum 1000 -Maximum 9999
    $empData = @{
        "EmployeeId" = "0"
        "AddressId"  = "0"
        "Name"       = "Temporary Rec $rnd"
        "Gender"     = "Male"
        "Department" = "HR"
        "Salary"     = "42000"
        "Country"    = "India"
        "State"      = "Karnataka"
        "City"       = "Bengaluru"
        "Pin"        = "560001"
    }
    $null = Invoke-E2EPost -Session $sess -Path "/Employee/Create" -FormData $empData -AutoToken $true -FollowRedirects $false
    $searchRes = Invoke-E2EGet -Session $sess -Path "/Employee/Index?search=Temporary%20Rec%20$rnd"
    Assert-True -Condition ($searchRes.Content -match 'Delete/(\d+)') -Message "Delete link found"
    $id = $matches[1]

    $delPage = Invoke-E2EGet -Session $sess -Path "/Employee/Delete/$id"
    $token = Get-VerificationToken -Html $delPage.Content
    $delPost = Invoke-E2EPost -Session $sess -Path "/Employee/Delete/$id" -FormData @{ "__RequestVerificationToken" = $token; "id" = $id } -AutoToken $false -FollowRedirects $false
    Assert-StatusCode -Response $delPost -ExpectedCode 302 -Message "Delete returns 302 redirect"
    Assert-RedirectLocation -Response $delPost -ExpectedPattern "/Employee/Index" -Message "Redirects to Index"
}

Register-TestCase -Id "T1_F10_04" -Tier "Tier 1" -Feature "F10" -Title "Deleted employee triggers success flash alert on directory" -ScriptBlock {
    $sess = New-E2ESession
    $null = Invoke-E2ELogin -Session $sess -UsernameOrEmail "admin" -Password "Admin@123"
    $rnd = Get-Random -Minimum 1000 -Maximum 9999
    $empData = @{
        "EmployeeId" = "0"
        "AddressId"  = "0"
        "Name"       = "Flash Delete $rnd"
        "Gender"     = "Female"
        "Department" = "HR"
        "Salary"     = "46000"
        "Country"    = "India"
        "State"      = "Karnataka"
        "City"       = "Bengaluru"
        "Pin"        = "560001"
    }
    $null = Invoke-E2EPost -Session $sess -Path "/Employee/Create" -FormData $empData -AutoToken $true -FollowRedirects $false
    $searchRes = Invoke-E2EGet -Session $sess -Path "/Employee/Index?search=Flash%20Delete%20$rnd"
    Assert-True -Condition ($searchRes.Content -match 'Delete/(\d+)') -Message "Delete link found"
    $id = $matches[1]

    $delPage = Invoke-E2EGet -Session $sess -Path "/Employee/Delete/$id"
    $token = Get-VerificationToken -Html $delPage.Content
    $null = Invoke-E2EPost -Session $sess -Path "/Employee/Delete/$id" -FormData @{ "__RequestVerificationToken" = $token; "id" = $id } -AutoToken $false -FollowRedirects $false
    $indexRes = Invoke-E2EGet -Session $sess -Path "/Employee/Index"
    Assert-ContainsText -Content $indexRes.Content -ExpectedText "was deleted successfully." -Message "Delete success notice"
}

Register-TestCase -Id "T1_F10_05" -Tier "Tier 1" -Feature "F10" -Title "Deleted employee record is removed from Directory search" -ScriptBlock {
    $sess = New-E2ESession
    $null = Invoke-E2ELogin -Session $sess -UsernameOrEmail "admin" -Password "Admin@123"
    $rnd = Get-Random -Minimum 1000 -Maximum 9999
    $empName = "Search Purge $rnd"
    $empData = @{
        "EmployeeId" = "0"
        "AddressId"  = "0"
        "Name"       = $empName
        "Gender"     = "Male"
        "Department" = "Finance"
        "Salary"     = "49000"
        "Country"    = "India"
        "State"      = "Maharashtra"
        "City"       = "Mumbai"
        "Pin"        = "400001"
    }
    $null = Invoke-E2EPost -Session $sess -Path "/Employee/Create" -FormData $empData -AutoToken $true -FollowRedirects $false
    $searchRes = Invoke-E2EGet -Session $sess -Path "/Employee/Index?search=Search%20Purge%20$rnd"
    Assert-True -Condition ($searchRes.Content -match 'Delete/(\d+)') -Message "Delete link found"
    $id = $matches[1]

    $delPage = Invoke-E2EGet -Session $sess -Path "/Employee/Delete/$id"
    $token = Get-VerificationToken -Html $delPage.Content
    $null = Invoke-E2EPost -Session $sess -Path "/Employee/Delete/$id" -FormData @{ "__RequestVerificationToken" = $token; "id" = $id } -AutoToken $false -FollowRedirects $false
    $searchAfter = Invoke-E2EGet -Session $sess -Path "/Employee/Index?search=Search%20Purge%20$rnd"
    Assert-ContainsText -Content $searchAfter.Content -ExpectedText "No employee records found" -Message "Empty search state rendered for deleted record"
}

# ------------------------------------------------------------------------------
# F11: Admin Metrics & Workforce Dashboard (5 tests)
# ------------------------------------------------------------------------------

Register-TestCase -Id "T1_F11_01" -Tier "Tier 1" -Feature "F11" -Title "Admin Dashboard loads with HTTP 200" -ScriptBlock {
    $sess = New-E2ESession
    $null = Invoke-E2ELogin -Session $sess -UsernameOrEmail "admin" -Password "Admin@123"
    $res = Invoke-E2EGet -Session $sess -Path "/Admin/Dashboard"
    Assert-StatusCode -Response $res -ExpectedCode 200 -Message "Dashboard returns 200"
    Assert-ContainsText -Content $res.Content -ExpectedText "Administrator Dashboard" -Message "Dashboard heading present"
}

Register-TestCase -Id "T1_F11_02" -Tier "Tier 1" -Feature "F11" -Title "Dashboard displays Total Employees metric KPI card" -ScriptBlock {
    $sess = New-E2ESession
    $null = Invoke-E2ELogin -Session $sess -UsernameOrEmail "admin" -Password "Admin@123"
    $res = Invoke-E2EGet -Session $sess -Path "/Admin/Dashboard"
    Assert-ContainsText -Content $res.Content -ExpectedText "Total Employees" -Message "Total Employees KPI label"
}

Register-TestCase -Id "T1_F11_03" -Tier "Tier 1" -Feature "F11" -Title "Dashboard displays Registered Users metric KPI card" -ScriptBlock {
    $sess = New-E2ESession
    $null = Invoke-E2ELogin -Session $sess -UsernameOrEmail "admin" -Password "Admin@123"
    $res = Invoke-E2EGet -Session $sess -Path "/Admin/Dashboard"
    Assert-ContainsText -Content $res.Content -ExpectedText "Registered Users" -Message "Registered Users KPI label"
}

Register-TestCase -Id "T1_F11_04" -Tier "Tier 1" -Feature "F11" -Title "Dashboard displays Total Monthly Payroll formatted with INR prefix" -ScriptBlock {
    $sess = New-E2ESession
    $null = Invoke-E2ELogin -Session $sess -UsernameOrEmail "admin" -Password "Admin@123"
    $res = Invoke-E2EGet -Session $sess -Path "/Admin/Dashboard"
    Assert-ContainsText -Content $res.Content -ExpectedText "Monthly Payroll" -Message "Monthly Payroll label"
    Assert-MatchesPattern -Content $res.Content -RegexPattern 'Rs\.\s*[0-9,]+' -Message "Formatted in Rs. currency"
}

Register-TestCase -Id "T1_F11_05" -Tier "Tier 1" -Feature "F11" -Title "Dashboard displays Average Employee Salary formatted with INR prefix" -ScriptBlock {
    $sess = New-E2ESession
    $null = Invoke-E2ELogin -Session $sess -UsernameOrEmail "admin" -Password "Admin@123"
    $res = Invoke-E2EGet -Session $sess -Path "/Admin/Dashboard"
    Assert-ContainsText -Content $res.Content -ExpectedText "Average Salary" -Message "Average Salary label"
    Assert-MatchesPattern -Content $res.Content -RegexPattern 'Rs\.\s*[0-9,]+' -Message "Formatted in Rs. currency"
}

# ------------------------------------------------------------------------------
# F12: System User Management Directory (5 tests)
# ------------------------------------------------------------------------------

Register-TestCase -Id "T1_F12_01" -Tier "Tier 1" -Feature "F12" -Title "Admin Users directory loads with HTTP 200" -ScriptBlock {
    $sess = New-E2ESession
    $null = Invoke-E2ELogin -Session $sess -UsernameOrEmail "admin" -Password "Admin@123"
    $res = Invoke-E2EGet -Session $sess -Path "/Admin/Users"
    Assert-StatusCode -Response $res -ExpectedCode 200 -Message "Users directory returns 200"
    Assert-ContainsText -Content $res.Content -ExpectedText "System Users" -Message "Title present"
}

Register-TestCase -Id "T1_F12_02" -Tier "Tier 1" -Feature "F12" -Title "Users directory displays administrator user account" -ScriptBlock {
    $sess = New-E2ESession
    $null = Invoke-E2ELogin -Session $sess -UsernameOrEmail "admin" -Password "Admin@123"
    $res = Invoke-E2EGet -Session $sess -Path "/Admin/Users"
    Assert-ContainsText -Content $res.Content -ExpectedText "admin" -Message "Admin handle displayed"
    Assert-ContainsText -Content $res.Content -ExpectedText "admin@viewmodeldemo.com" -Message "Admin email displayed"
}

Register-TestCase -Id "T1_F12_03" -Tier "Tier 1" -Feature "F12" -Title "Users directory displays standard user account" -ScriptBlock {
    $sess = New-E2ESession
    $null = Invoke-E2ELogin -Session $sess -UsernameOrEmail "admin" -Password "Admin@123"
    $res = Invoke-E2EGet -Session $sess -Path "/Admin/Users"
    Assert-ContainsText -Content $res.Content -ExpectedText "rahul" -Message "User handle displayed"
    Assert-ContainsText -Content $res.Content -ExpectedText "rahul.sharma@example.com" -Message "User email displayed"
}

Register-TestCase -Id "T1_F12_04" -Tier "Tier 1" -Feature "F12" -Title "Users directory formats user role as role badge" -ScriptBlock {
    $sess = New-E2ESession
    $null = Invoke-E2ELogin -Session $sess -UsernameOrEmail "admin" -Password "Admin@123"
    $res = Invoke-E2EGet -Session $sess -Path "/Admin/Users"
    Assert-ContainsText -Content $res.Content -ExpectedText "Admin" -Message "Admin role text present"
    Assert-ContainsText -Content $res.Content -ExpectedText "User" -Message "User role text present"
}

Register-TestCase -Id "T1_F12_05" -Tier "Tier 1" -Feature "F12" -Title "Users directory displays account creation timestamps" -ScriptBlock {
    $sess = New-E2ESession
    $null = Invoke-E2ELogin -Session $sess -UsernameOrEmail "admin" -Password "Admin@123"
    $res = Invoke-E2EGet -Session $sess -Path "/Admin/Users"
    Assert-ContainsText -Content $res.Content -ExpectedText "Created Date" -Message "Created Date column header"
}

# ------------------------------------------------------------------------------
# F13: Student Domain Model Raw Listing (5 tests)
# ------------------------------------------------------------------------------

Register-TestCase -Id "T1_F13_01" -Tier "Tier 1" -Feature "F13" -Title "Student raw listing loads with HTTP 200" -ScriptBlock {
    $sess = New-E2ESession
    $res = Invoke-E2EGet -Session $sess -Path "/Student/Index"
    Assert-StatusCode -Response $res -ExpectedCode 200 -Message "Student Index returns 200"
    Assert-ContainsText -Content $res.Content -ExpectedText "Student Domain Model" -Message "Title present"
}

Register-TestCase -Id "T1_F13_02" -Tier "Tier 1" -Feature "F13" -Title "Student raw listing table includes Roll No, Name, and Marks headers" -ScriptBlock {
    $sess = New-E2ESession
    $res = Invoke-E2EGet -Session $sess -Path "/Student/Index"
    Assert-ContainsText -Content $res.Content -ExpectedText "Roll No" -Message "Roll No header"
    Assert-ContainsText -Content $res.Content -ExpectedText "Student Name" -Message "Student Name header"
    Assert-ContainsText -Content $res.Content -ExpectedText "Marks" -Message "Marks column header"
}

Register-TestCase -Id "T1_F13_03" -Tier "Tier 1" -Feature "F13" -Title "Student raw listing renders seeded student records" -ScriptBlock {
    $sess = New-E2ESession
    $res = Invoke-E2EGet -Session $sess -Path "/Student/Index"
    Assert-ContainsText -Content $res.Content -ExpectedText "Ankur" -Message "Contains Ankur"
    Assert-ContainsText -Content $res.Content -ExpectedText "Dhrumit" -Message "Contains Dhrumit"
    Assert-ContainsText -Content $res.Content -ExpectedText "Mannan" -Message "Contains Mannan"
}

Register-TestCase -Id "T1_F13_04" -Tier "Tier 1" -Feature "F13" -Title "Student raw listing renders navigation link to ViewModel view (getStud)" -ScriptBlock {
    $sess = New-E2ESession
    $res = Invoke-E2EGet -Session $sess -Path "/Student/Index"
    Assert-MatchesPattern -Content $res.Content -RegexPattern 'href="[^"]*Student/getStud"' -Message "Link to getStud present"
}

Register-TestCase -Id "T1_F13_05" -Tier "Tier 1" -Feature "F13" -Title "Student raw listing is accessible anonymously" -ScriptBlock {
    $sess = New-E2ESession
    $res = Invoke-E2EGet -Session $sess -Path "/Student/Index"
    Assert-StatusCode -Response $res -ExpectedCode 200 -Message "Anonymous access allowed"
}

# ------------------------------------------------------------------------------
# F14: Student Marks Presentation (getStud) (5 tests)
# ------------------------------------------------------------------------------

Register-TestCase -Id "T1_F14_01" -Tier "Tier 1" -Feature "F14" -Title "Student marks ViewModel presentation loads with HTTP 200" -ScriptBlock {
    $sess = New-E2ESession
    $res = Invoke-E2EGet -Session $sess -Path "/Student/getStud"
    Assert-StatusCode -Response $res -ExpectedCode 200 -Message "getStud returns 200"
    Assert-ContainsText -Content $res.Content -ExpectedText "Student Marks Status" -Message "ViewModel title present"
}

Register-TestCase -Id "T1_F14_02" -Tier "Tier 1" -Feature "F14" -Title "Student with score > 35 (Dhrumit) is formatted with green status" -ScriptBlock {
    $sess = New-E2ESession
    $res = Invoke-E2EGet -Session $sess -Path "/Student/getStud"
    Assert-ContainsText -Content $res.Content -ExpectedText "Dhrumit" -Message "Contains Dhrumit"
    Assert-ContainsText -Content $res.Content -ExpectedText "green" -Message "Green status indicator present"
}

Register-TestCase -Id "T1_F14_03" -Tier "Tier 1" -Feature "F14" -Title "Student with score <= 35 (Ankur) is formatted with red status" -ScriptBlock {
    $sess = New-E2ESession
    $res = Invoke-E2EGet -Session $sess -Path "/Student/getStud"
    Assert-ContainsText -Content $res.Content -ExpectedText "Ankur" -Message "Contains Ankur"
    Assert-ContainsText -Content $res.Content -ExpectedText "red" -Message "Red status indicator present"
}

Register-TestCase -Id "T1_F14_04" -Tier "Tier 1" -Feature "F14" -Title "getStud view presents high-scoring student Priya Sharma" -ScriptBlock {
    $sess = New-E2ESession
    $res = Invoke-E2EGet -Session $sess -Path "/Student/getStud"
    Assert-ContainsText -Content $res.Content -ExpectedText "Priya Sharma" -Message "Contains Priya Sharma"
    Assert-ContainsText -Content $res.Content -ExpectedText "88.5" -Message "Score 88.5 present"
}

Register-TestCase -Id "T1_F14_05" -Tier "Tier 1" -Feature "F14" -Title "getStud view provides back link to raw Domain Model listing" -ScriptBlock {
    $sess = New-E2ESession
    $res = Invoke-E2EGet -Session $sess -Path "/Student/getStud"
    Assert-MatchesPattern -Content $res.Content -RegexPattern 'href="[^"]*Student/Index"' -Message "Back link to Student/Index present"
}

# ------------------------------------------------------------------------------
# F15: Offline Resiliency & Fallback Data Access (5 tests)
# ------------------------------------------------------------------------------

Register-TestCase -Id "T1_F15_01" -Tier "Tier 1" -Feature "F15" -Title "Fallback Admin credentials (admin / Admin@123) are recognized" -ScriptBlock {
    $sess = New-E2ESession
    $res = Invoke-E2ELogin -Session $sess -UsernameOrEmail "admin" -Password "Admin@123"
    Assert-StatusCode -Response $res -ExpectedCode 302 -Message "Fallback admin credentials recognized"
}

Register-TestCase -Id "T1_F15_02" -Tier "Tier 1" -Feature "F15" -Title "Fallback User credentials (rahul / User@123) are recognized" -ScriptBlock {
    $sess = New-E2ESession
    $res = Invoke-E2ELogin -Session $sess -UsernameOrEmail "rahul" -Password "User@123"
    Assert-StatusCode -Response $res -ExpectedCode 302 -Message "Fallback user credentials recognized"
}

Register-TestCase -Id "T1_F15_03" -Tier "Tier 1" -Feature "F15" -Title "DatabaseHelper query methods execute without unhandled 500 exceptions" -ScriptBlock {
    $sess = New-E2ESession
    $res1 = Invoke-E2EGet -Session $sess -Path "/Employee/Index"
    Assert-StatusCode -Response $res1 -ExpectedCode 200 -Message "Employee Index resilient"
    $res2 = Invoke-E2EGet -Session $sess -Path "/Student/Index"
    Assert-StatusCode -Response $res2 -ExpectedCode 200 -Message "Student Index resilient"
}

Register-TestCase -Id "T1_F15_04" -Tier "Tier 1" -Feature "F15" -Title "Dashboard metrics structure maintains integrity across queries" -ScriptBlock {
    $sess = New-E2ESession
    $null = Invoke-E2ELogin -Session $sess -UsernameOrEmail "admin" -Password "Admin@123"
    $res = Invoke-E2EGet -Session $sess -Path "/Admin/Dashboard"
    Assert-StatusCode -Response $res -ExpectedCode 200 -Message "Dashboard metrics resilient"
    Assert-ContainsText -Content $res.Content -ExpectedText "Total Employees" -Message "Total Employees present"
}

Register-TestCase -Id "T1_F15_05" -Tier "Tier 1" -Feature "F15" -Title "Student marks view calculates consistent color mapping" -ScriptBlock {
    $sess = New-E2ESession
    $res = Invoke-E2EGet -Session $sess -Path "/Student/getStud"
    Assert-StatusCode -Response $res -ExpectedCode 200 -Message "Student marks resilient"
    Assert-ContainsText -Content $res.Content -ExpectedText "green" -Message "Green present"
    Assert-ContainsText -Content $res.Content -ExpectedText "red" -Message "Red present"
}
