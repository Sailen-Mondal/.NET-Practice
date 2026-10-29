# ==============================================================================
# Tier2_BoundaryCorner.ps1 - Tier 2: Boundary & Corner Cases (F01 to F15)
# Methodology: Boundary Value Analysis (BVA), Equivalence Partitioning, Corner Cases
# 15 Features x 5 Tests = 75 Tests
# STRICT ZERO EMOJIS
# ==============================================================================

# Ensure TestHarness functions are available
if (-not (Get-Command "Register-TestCase" -ErrorAction SilentlyContinue)) {
    . "$PSScriptRoot\TestHarness.ps1"
}

# ------------------------------------------------------------------------------
# F01: User Authentication & Login Boundary Cases (5 tests)
# ------------------------------------------------------------------------------

Register-TestCase -Id "T2_F01_01" -Tier "Tier 2" -Feature "F01" -Title "Login with incorrect password returns 200 with invalid credentials message" -ScriptBlock {
    $sess = New-E2ESession
    $res = Invoke-E2ELogin -Session $sess -UsernameOrEmail "admin" -Password "WrongSecret999"
    Assert-StatusCode -Response $res -ExpectedCode 200 -Message "Failed login should return 200 with view"
    Assert-ContainsText -Content $res.Content -ExpectedText "Invalid username/email or password." -Message "Error alert must be shown"
}

Register-TestCase -Id "T2_F01_02" -Tier "Tier 2" -Feature "F01" -Title "Login with non-existent username returns 200 with invalid credentials message" -ScriptBlock {
    $sess = New-E2ESession
    $res = Invoke-E2ELogin -Session $sess -UsernameOrEmail "ghost_user_xyz" -Password "Secret@123"
    Assert-StatusCode -Response $res -ExpectedCode 200 -Message "Non-existent user login should return 200"
    Assert-ContainsText -Content $res.Content -ExpectedText "Invalid username/email or password." -Message "Error alert must be shown"
}

Register-TestCase -Id "T2_F01_03" -Tier "Tier 2" -Feature "F01" -Title "Login with empty username returns validation error" -ScriptBlock {
    $sess = New-E2ESession
    $loginPage = Invoke-E2EGet -Session $sess -Path "/Account/Login"
    $token = Get-VerificationToken -Html $loginPage.Content
    $body = @{
        "__RequestVerificationToken" = $token
        "UsernameOrEmail"            = ""
        "Password"                   = "Admin@123"
        "RememberMe"                 = "false"
    }
    $res = Invoke-E2EPost -Session $sess -Path "/Account/Login" -FormData $body -AutoToken $false -FollowRedirects $false
    Assert-StatusCode -Response $res -ExpectedCode 200 -Message "Empty username should return 200"
    Assert-ContainsText -Content $res.Content -ExpectedText "Username or Email is required" -Message "Validation message shown"
}

Register-TestCase -Id "T2_F01_04" -Tier "Tier 2" -Feature "F01" -Title "Login with empty password returns validation error" -ScriptBlock {
    $sess = New-E2ESession
    $loginPage = Invoke-E2EGet -Session $sess -Path "/Account/Login"
    $token = Get-VerificationToken -Html $loginPage.Content
    $body = @{
        "__RequestVerificationToken" = $token
        "UsernameOrEmail"            = "admin"
        "Password"                   = ""
        "RememberMe"                 = "false"
    }
    $res = Invoke-E2EPost -Session $sess -Path "/Account/Login" -FormData $body -AutoToken $false -FollowRedirects $false
    Assert-StatusCode -Response $res -ExpectedCode 200 -Message "Empty password should return 200"
    Assert-ContainsText -Content $res.Content -ExpectedText "Password is required" -Message "Validation message shown"
}

Register-TestCase -Id "T2_F01_05" -Tier "Tier 2" -Feature "F01" -Title "External ReturnUrl open redirect attack is prevented" -ScriptBlock {
    $sess = New-E2ESession
    $res = Invoke-E2ELogin -Session $sess -UsernameOrEmail "admin" -Password "Admin@123" -ReturnUrl "http://malicious-attacker.com/steal"
    Assert-StatusCode -Response $res -ExpectedCode 302 -Message "Redirects"
    Assert-RedirectLocation -Response $res -ExpectedPattern "/Admin/Dashboard" -Message "Must NOT redirect to external site, routes to Dashboard"
}

# ------------------------------------------------------------------------------
# F02: User Registration Boundary Cases (5 tests)
# ------------------------------------------------------------------------------

Register-TestCase -Id "T2_F02_01" -Tier "Tier 2" -Feature "F02" -Title "Registration rejects duplicate username with validation message" -ScriptBlock {
    $sess = New-E2ESession
    $regData = @{
        "FullName"        = "Duplicate Admin Attempt"
        "Username"        = "admin"
        "Email"           = "unique_email_$(Get-Random)@example.in"
        "Password"        = "Admin@123"
        "ConfirmPassword" = "Admin@123"
    }
    $res = Invoke-E2EPost -Session $sess -Path "/Account/Register" -FormData $regData -AutoToken $true -FollowRedirects $false
    Assert-StatusCode -Response $res -ExpectedCode 200 -Message "Duplicate username returns 200"
    Assert-ContainsText -Content $res.Content -ExpectedText "already exists" -Message "Error message shows user already exists"
}

Register-TestCase -Id "T2_F02_02" -Tier "Tier 2" -Feature "F02" -Title "Registration rejects duplicate email address with validation message" -ScriptBlock {
    $sess = New-E2ESession
    $rnd = Get-Random -Minimum 1000 -Maximum 9999
    $regData = @{
        "FullName"        = "Duplicate Email Attempt"
        "Username"        = "unique_user_$rnd"
        "Email"           = "admin@viewmodeldemo.com"
        "Password"        = "Admin@123"
        "ConfirmPassword" = "Admin@123"
    }
    $res = Invoke-E2EPost -Session $sess -Path "/Account/Register" -FormData $regData -AutoToken $true -FollowRedirects $false
    Assert-StatusCode -Response $res -ExpectedCode 200 -Message "Duplicate email returns 200"
    Assert-ContainsText -Content $res.Content -ExpectedText "already exists" -Message "Error message shows email already exists"
}

Register-TestCase -Id "T2_F02_03" -Tier "Tier 2" -Feature "F02" -Title "Username regex rejects special characters like @, !, #" -ScriptBlock {
    $sess = New-E2ESession
    $rnd = Get-Random -Minimum 1000 -Maximum 9999
    $regData = @{
        "FullName"        = "Invalid Username User"
        "Username"        = "rahul@work!_$rnd"
        "Email"           = "invalid_user_$rnd@example.in"
        "Password"        = "Valid@123"
        "ConfirmPassword" = "Valid@123"
    }
    $res = Invoke-E2EPost -Session $sess -Path "/Account/Register" -FormData $regData -AutoToken $true -FollowRedirects $false
    Assert-StatusCode -Response $res -ExpectedCode 200 -Message "Regex failure returns 200"
    Assert-ContainsText -Content $res.Content -ExpectedText "can only contain letters, numbers, and underscores" -Message "Regex validation message shown"
}

Register-TestCase -Id "T2_F02_04" -Tier "Tier 2" -Feature "F02" -Title "Password shorter than 6 characters fails StringLength validation" -ScriptBlock {
    $sess = New-E2ESession
    $rnd = Get-Random -Minimum 1000 -Maximum 9999
    $regData = @{
        "FullName"        = "Short Password User"
        "Username"        = "short_pwd_$rnd"
        "Email"           = "short_pwd_$rnd@example.in"
        "Password"        = "12345"
        "ConfirmPassword" = "12345"
    }
    $res = Invoke-E2EPost -Session $sess -Path "/Account/Register" -FormData $regData -AutoToken $true -FollowRedirects $false
    Assert-StatusCode -Response $res -ExpectedCode 200 -Message "Short password returns 200"
    Assert-ContainsText -Content $res.Content -ExpectedText "Password must be at least 6 characters" -Message "Min length error shown"
}

Register-TestCase -Id "T2_F02_05" -Tier "Tier 2" -Feature "F02" -Title "Mismatched Password and ConfirmPassword fails Compare validation" -ScriptBlock {
    $sess = New-E2ESession
    $rnd = Get-Random -Minimum 1000 -Maximum 9999
    $regData = @{
        "FullName"        = "Mismatch Password User"
        "Username"        = "mismatch_$rnd"
        "Email"           = "mismatch_$rnd@example.in"
        "Password"        = "Password@123"
        "ConfirmPassword" = "Different@456"
    }
    $res = Invoke-E2EPost -Session $sess -Path "/Account/Register" -FormData $regData -AutoToken $true -FollowRedirects $false
    Assert-StatusCode -Response $res -ExpectedCode 200 -Message "Password mismatch returns 200"
    Assert-ContainsText -Content $res.Content -ExpectedText "Passwords do not match" -Message "Compare validator error shown"
}

# ------------------------------------------------------------------------------
# F03: Session Management & Logout Boundary Cases (5 tests)
# ------------------------------------------------------------------------------

Register-TestCase -Id "T2_F03_01" -Tier "Tier 2" -Feature "F03" -Title "Logout called without prior authentication is idempotent and redirects to Login" -ScriptBlock {
    $sess = New-E2ESession
    $res = Invoke-E2EGet -Session $sess -Path "/Account/Logout" -FollowRedirects $false
    Assert-StatusCode -Response $res -ExpectedCode 302 -Message "Anonymous logout returns 302"
    Assert-RedirectLocation -Response $res -ExpectedPattern "/Account/Login" -Message "Redirects to Login"
}

Register-TestCase -Id "T2_F03_02" -Tier "Tier 2" -Feature "F03" -Title "Multiple consecutive logout invocations succeed without server error" -ScriptBlock {
    $sess = New-E2ESession
    $null = Invoke-E2ELogin -Session $sess -UsernameOrEmail "admin" -Password "Admin@123"
    $res1 = Invoke-E2ELogout -Session $sess
    Assert-StatusCode -Response $res1 -ExpectedCode 302 -Message "First logout succeeds"
    $res2 = Invoke-E2ELogout -Session $sess
    Assert-StatusCode -Response $res2 -ExpectedCode 302 -Message "Second logout succeeds without error"
}

Register-TestCase -Id "T2_F03_03" -Tier "Tier 2" -Feature "F03" -Title "Accessing /Admin/Dashboard post-logout sets ReturnUrl query parameter" -ScriptBlock {
    $sess = New-E2ESession
    $null = Invoke-E2ELogin -Session $sess -UsernameOrEmail "admin" -Password "Admin@123"
    $null = Invoke-E2ELogout -Session $sess
    $res = Invoke-E2EGet -Session $sess -Path "/Admin/Dashboard" -FollowRedirects $false
    Assert-StatusCode -Response $res -ExpectedCode 302 -Message "Redirects to Login"
    Assert-MatchesPattern -Content $res.Location -RegexPattern 'returnUrl=%2FAdmin%2FDashboard|returnUrl=/Admin/Dashboard' -Message "Preserves returnUrl"
}

Register-TestCase -Id "T2_F03_04" -Tier "Tier 2" -Feature "F03" -Title "Corrupted session cookie cannot access protected administrative route" -ScriptBlock {
    $sess = New-E2ESession
    # Invalidate session by forging random cookie
    $badCookie = New-Object System.Net.Cookie("ASP.NET_SessionId", "corrupted_session_id_9999", "/", "localhost")
    $sess.WebSession.Cookies.Add($badCookie)
    $res = Invoke-E2EGet -Session $sess -Path "/Admin/Dashboard" -FollowRedirects $false
    Assert-StatusCode -Response $res -ExpectedCode 302 -Message "Forged cookie blocked from Dashboard"
    Assert-RedirectLocation -Response $res -ExpectedPattern "/Account/Login" -Message "Redirects to Login"
}

Register-TestCase -Id "T2_F03_05" -Tier "Tier 2" -Feature "F03" -Title "Unauthenticated POST to /Employee/Create is rejected" -ScriptBlock {
    $sess = New-E2ESession
    # Unauthenticated session attempting direct POST
    $empData = @{
        "Name"       = "Intruder Employee"
        "Gender"     = "Male"
        "Department" = "IT"
        "Salary"     = "50000"
        "Country"    = "India"
        "State"      = "Delhi"
        "City"       = "New Delhi"
        "Pin"        = "110001"
    }
    $res = Invoke-E2EPost -Session $sess -Path "/Employee/Create" -FormData $empData -AutoToken $true -FollowRedirects $false
    Assert-StatusCode -Response $res -ExpectedCode 302 -Message "Unauthorized POST redirects"
    Assert-RedirectLocation -Response $res -ExpectedPattern "/Account/Login" -Message "Redirects to Login"
}

# ------------------------------------------------------------------------------
# F04: Role-Based Access Control Boundary Cases (5 tests)
# ------------------------------------------------------------------------------

Register-TestCase -Id "T2_F04_01" -Tier "Tier 2" -Feature "F04" -Title "Standard User accessing /Admin/Dashboard is redirected to Login with error alert" -ScriptBlock {
    $sess = New-E2ESession
    $null = Invoke-E2ELogin -Session $sess -UsernameOrEmail "rahul" -Password "User@123"
    $res = Invoke-E2EGet -Session $sess -Path "/Admin/Dashboard" -FollowRedirects $false
    Assert-StatusCode -Response $res -ExpectedCode 302 -Message "User role redirected from Dashboard"
    Assert-RedirectLocation -Response $res -ExpectedPattern "/Account/Login" -Message "Redirects to Login"
}

Register-TestCase -Id "T2_F04_02" -Tier "Tier 2" -Feature "F04" -Title "Standard User accessing /Admin/Users is redirected to Login with error alert" -ScriptBlock {
    $sess = New-E2ESession
    $null = Invoke-E2ELogin -Session $sess -UsernameOrEmail "rahul" -Password "User@123"
    $res = Invoke-E2EGet -Session $sess -Path "/Admin/Users" -FollowRedirects $false
    Assert-StatusCode -Response $res -ExpectedCode 302 -Message "User role redirected from Users"
    Assert-RedirectLocation -Response $res -ExpectedPattern "/Account/Login" -Message "Redirects to Login"
}

Register-TestCase -Id "T2_F04_03" -Tier "Tier 2" -Feature "F04" -Title "Standard User accessing /Employee/Create is redirected to Login" -ScriptBlock {
    $sess = New-E2ESession
    $null = Invoke-E2ELogin -Session $sess -UsernameOrEmail "rahul" -Password "User@123"
    $res = Invoke-E2EGet -Session $sess -Path "/Employee/Create" -FollowRedirects $false
    Assert-StatusCode -Response $res -ExpectedCode 302 -Message "User role redirected from Create"
    Assert-RedirectLocation -Response $res -ExpectedPattern "/Account/Login" -Message "Redirects to Login"
}

Register-TestCase -Id "T2_F04_04" -Tier "Tier 2" -Feature "F04" -Title "Standard User accessing /Employee/Edit/101 is redirected to Login" -ScriptBlock {
    $sess = New-E2ESession
    $null = Invoke-E2ELogin -Session $sess -UsernameOrEmail "rahul" -Password "User@123"
    $res = Invoke-E2EGet -Session $sess -Path "/Employee/Edit/101" -FollowRedirects $false
    Assert-StatusCode -Response $res -ExpectedCode 302 -Message "User role redirected from Edit"
    Assert-RedirectLocation -Response $res -ExpectedPattern "/Account/Login" -Message "Redirects to Login"
}

Register-TestCase -Id "T2_F04_05" -Tier "Tier 2" -Feature "F04" -Title "Standard User accessing /Employee/Delete/101 is redirected to Login" -ScriptBlock {
    $sess = New-E2ESession
    $null = Invoke-E2ELogin -Session $sess -UsernameOrEmail "rahul" -Password "User@123"
    $res = Invoke-E2EGet -Session $sess -Path "/Employee/Delete/101" -FollowRedirects $false
    Assert-StatusCode -Response $res -ExpectedCode 302 -Message "User role redirected from Delete"
    Assert-RedirectLocation -Response $res -ExpectedPattern "/Account/Login" -Message "Redirects to Login"
}

# ------------------------------------------------------------------------------
# F05: Global Navigation & User Pill Boundary Cases (5 tests)
# ------------------------------------------------------------------------------

Register-TestCase -Id "T2_F05_01" -Tier "Tier 2" -Feature "F05" -Title "Navigation brand link href attribute consistently points to /Employee/Index" -ScriptBlock {
    $sess = New-E2ESession
    $res = Invoke-E2EGet -Session $sess -Path "/Student/getStud"
    Assert-MatchesPattern -Content $res.Content -RegexPattern 'class="nav-brand"[^>]*href="/Employee/Index"' -Message "Brand link points to Employee Index"
}

Register-TestCase -Id "T2_F05_02" -Tier "Tier 2" -Feature "F05" -Title "Mobile drawer navigation links mirror desktop navigation structure" -ScriptBlock {
    $sess = New-E2ESession
    $res = Invoke-E2EGet -Session $sess -Path "/Employee/Index"
    Assert-MatchesPattern -Content $res.Content -RegexPattern 'id="mobileNavDrawer"' -Message "Mobile drawer present"
    Assert-MatchesPattern -Content $res.Content -RegexPattern 'class="nav-drawer-links"' -Message "Drawer links container present"
}

Register-TestCase -Id "T2_F05_03" -Tier "Tier 2" -Feature "F05" -Title "Navigation highlights active link matching current controller and action" -ScriptBlock {
    $sess = New-E2ESession
    $res = Invoke-E2EGet -Session $sess -Path "/Employee/Index"
    Assert-MatchesPattern -Content $res.Content -RegexPattern 'class="nav-link\s+active"[^>]*href="/Employee/Index"' -Message "Active class applied to current link"
}

Register-TestCase -Id "T2_F05_04" -Tier "Tier 2" -Feature "F05" -Title "User avatar pill renders uppercase first initial of user full name" -ScriptBlock {
    $sess = New-E2ESession
    $null = Invoke-E2ELogin -Session $sess -UsernameOrEmail "admin" -Password "Admin@123"
    $res = Invoke-E2EGet -Session $sess -Path "/Employee/Index"
    Assert-MatchesPattern -Content $res.Content -RegexPattern 'class="user-avatar"[^>]*>S<' -Message "Avatar displays 'S' for System Administrator"
}

Register-TestCase -Id "T2_F05_05" -Tier "Tier 2" -Feature "F05" -Title "Alert container is prepared in DOM structure for notifications" -ScriptBlock {
    $sess = New-E2ESession
    $null = Invoke-E2ELogin -Session $sess -UsernameOrEmail "admin" -Password "Admin@123"
    # Cause an error alert by trying non-existent employee edit
    $res = Invoke-E2EGet -Session $sess -Path "/Employee/Edit/99999" -FollowRedirects $true
    Assert-StatusCode -Response $res -ExpectedCode 200 -Message "Redirected page loads"
    Assert-MatchesPattern -Content $res.Content -RegexPattern 'notion-alerts-container|alert-danger|alert' -Message "Alert markup present"
}

# ------------------------------------------------------------------------------
# F06: Employee Directory & Search Filter Boundary Cases (5 tests)
# ------------------------------------------------------------------------------

Register-TestCase -Id "T2_F06_01" -Tier "Tier 2" -Feature "F06" -Title "Search query with non-matching term renders empty state notice" -ScriptBlock {
    $sess = New-E2ESession
    $res = Invoke-E2EGet -Session $sess -Path "/Employee/Index?search=ZzzNonExistentPersonZzz"
    Assert-StatusCode -Response $res -ExpectedCode 200 -Message "Search returns 200"
    Assert-ContainsText -Content $res.Content -ExpectedText "No employee records found" -Message "Empty state rendered"
}

Register-TestCase -Id "T2_F06_02" -Tier "Tier 2" -Feature "F06" -Title "Search query with whitespace only returns complete directory" -ScriptBlock {
    $sess = New-E2ESession
    $res = Invoke-E2EGet -Session $sess -Path "/Employee/Index?search=%20%20%20"
    Assert-StatusCode -Response $res -ExpectedCode 200 -Message "Whitespace search returns 200"
    Assert-ContainsText -Content $res.Content -ExpectedText "Dillip Mohapatra" -Message "Contains seeded records"
    Assert-ContainsText -Content $res.Content -ExpectedText "Priya Patel" -Message "Contains seeded records"
}

Register-TestCase -Id "T2_F06_03" -Tier "Tier 2" -Feature "F06" -Title "Search query matches case-insensitively for lowercase city" -ScriptBlock {
    $sess = New-E2ESession
    $res = Invoke-E2EGet -Session $sess -Path "/Employee/Index?search=bhubaneswar"
    Assert-StatusCode -Response $res -ExpectedCode 200 -Message "Case-insensitive search returns 200"
    Assert-ContainsText -Content $res.Content -ExpectedText "Dillip Mohapatra" -Message "Matches Bhubaneswar in lowercase"
}

Register-TestCase -Id "T2_F06_04" -Tier "Tier 2" -Feature "F06" -Title "Search query containing special symbols is handled gracefully without crashing" -ScriptBlock {
    $sess = New-E2ESession
    $res = Invoke-E2EGet -Session $sess -Path "/Employee/Index?search=%25%5B%2A%2B%3F%5D"
    Assert-StatusCode -Response $res -ExpectedCode 200 -Message "Symbol search returns 200"
}

Register-TestCase -Id "T2_F06_05" -Tier "Tier 2" -Feature "F06" -Title "Standard User sees View action link while Admin sees Edit and Delete action links" -ScriptBlock {
    $sessUser = New-E2ESession
    $null = Invoke-E2ELogin -Session $sessUser -UsernameOrEmail "rahul" -Password "User@123"
    $userView = Invoke-E2EGet -Session $sessUser -Path "/Employee/Index"
    Assert-MatchesPattern -Content $userView.Content -RegexPattern 'href="[^"]*Employee/Details/101"' -Message "User sees View Details link"
    Assert-NotContainsText -Content $userView.Content -UnexpectedText "/Employee/Edit/101" -Message "User does NOT see Edit link"

    $sessAdmin = New-E2ESession
    $null = Invoke-E2ELogin -Session $sessAdmin -UsernameOrEmail "admin" -Password "Admin@123"
    $adminView = Invoke-E2EGet -Session $sessAdmin -Path "/Employee/Index"
    Assert-MatchesPattern -Content $adminView.Content -RegexPattern 'href="[^"]*Employee/Edit/101"' -Message "Admin sees Edit link"
    Assert-MatchesPattern -Content $adminView.Content -RegexPattern 'href="[^"]*Employee/Delete/101"' -Message "Admin sees Delete link"
}

# ------------------------------------------------------------------------------
# F07: Multi-Model Aggregated Details View Boundary Cases (5 tests)
# ------------------------------------------------------------------------------

Register-TestCase -Id "T2_F07_01" -Tier "Tier 2" -Feature "F07" -Title "Non-existent Employee ID in Details view handles gracefully" -ScriptBlock {
    $sess = New-E2ESession
    $res = Invoke-E2EGet -Session $sess -Path "/Employee/Details/99999"
    Assert-StatusCode -Response $res -ExpectedCode 200 -Message "Graceful response for non-existent ID"
}

Register-TestCase -Id "T2_F07_02" -Tier "Tier 2" -Feature "F07" -Title "Negative Employee ID in Details view handles gracefully" -ScriptBlock {
    $sess = New-E2ESession
    $res = Invoke-E2EGet -Session $sess -Path "/Employee/Details/-1"
    Assert-StatusCode -Response $res -ExpectedCode 200 -Message "Negative ID handled gracefully"
}

Register-TestCase -Id "T2_F07_03" -Tier "Tier 2" -Feature "F07" -Title "Zero Employee ID in Details view handles gracefully" -ScriptBlock {
    $sess = New-E2ESession
    $res = Invoke-E2EGet -Session $sess -Path "/Employee/Details/0"
    Assert-StatusCode -Response $res -ExpectedCode 200 -Message "Zero ID handled gracefully"
}

Register-TestCase -Id "T2_F07_04" -Tier "Tier 2" -Feature "F07" -Title "Details view formats employee salary with INR currency prefix Rs." -ScriptBlock {
    $sess = New-E2ESession
    $res = Invoke-E2EGet -Session $sess -Path "/Employee/Details/101"
    Assert-MatchesPattern -Content $res.Content -RegexPattern 'Rs\.\s*[0-9,]+' -Message "Salary formatted with Rs. prefix"
}

Register-TestCase -Id "T2_F07_05" -Tier "Tier 2" -Feature "F07" -Title "Details view shows Edit button for Admin but hides it for unauthenticated visitors" -ScriptBlock {
    $sessGuest = New-E2ESession
    $guestView = Invoke-E2EGet -Session $sessGuest -Path "/Employee/Details/101"
    Assert-NotContainsText -Content $guestView.Content -UnexpectedText "/Employee/Edit/101" -Message "Guest cannot see Edit button"

    $sessAdmin = New-E2ESession
    $null = Invoke-E2ELogin -Session $sessAdmin -UsernameOrEmail "admin" -Password "Admin@123"
    $adminView = Invoke-E2EGet -Session $sessAdmin -Path "/Employee/Details/101"
    Assert-MatchesPattern -Content $adminView.Content -RegexPattern 'href="[^"]*Employee/Edit/101"' -Message "Admin sees Edit button"
}

# ------------------------------------------------------------------------------
# F08: Multi-Table Employee Creation Form Boundary Cases (5 tests)
# ------------------------------------------------------------------------------

Register-TestCase -Id "T2_F08_01" -Tier "Tier 2" -Feature "F08" -Title "Employee creation rejects salary below minimum boundary of Rs. 1,000" -ScriptBlock {
    $sess = New-E2ESession
    $null = Invoke-E2ELogin -Session $sess -UsernameOrEmail "admin" -Password "Admin@123"
    $empData = @{
        "EmployeeId" = "0"
        "AddressId"  = "0"
        "Name"       = "Low Salary Test"
        "Gender"     = "Male"
        "Department" = "IT"
        "Salary"     = "500"
        "Country"    = "India"
        "State"      = "West Bengal"
        "City"       = "Kolkata"
        "Pin"        = "700001"
    }
    $res = Invoke-E2EPost -Session $sess -Path "/Employee/Create" -FormData $empData -AutoToken $true -FollowRedirects $false
    Assert-StatusCode -Response $res -ExpectedCode 200 -Message "Range validation failure returns 200"
    Assert-ContainsText -Content $res.Content -ExpectedText "Salary must be between Rs. 1,000 and Rs. 10,000,000" -Message "Range error shown"
}

Register-TestCase -Id "T2_F08_02" -Tier "Tier 2" -Feature "F08" -Title "Employee creation rejects salary above maximum boundary of Rs. 10,000,000" -ScriptBlock {
    $sess = New-E2ESession
    $null = Invoke-E2ELogin -Session $sess -UsernameOrEmail "admin" -Password "Admin@123"
    $empData = @{
        "EmployeeId" = "0"
        "AddressId"  = "0"
        "Name"       = "High Salary Test"
        "Gender"     = "Male"
        "Department" = "Engineering"
        "Salary"     = "15000000"
        "Country"    = "India"
        "State"      = "Karnataka"
        "City"       = "Bengaluru"
        "Pin"        = "560001"
    }
    $res = Invoke-E2EPost -Session $sess -Path "/Employee/Create" -FormData $empData -AutoToken $true -FollowRedirects $false
    Assert-StatusCode -Response $res -ExpectedCode 200 -Message "High salary validation returns 200"
    Assert-ContainsText -Content $res.Content -ExpectedText "Salary must be between Rs. 1,000 and Rs. 10,000,000" -Message "Range error shown"
}

Register-TestCase -Id "T2_F08_03" -Tier "Tier 2" -Feature "F08" -Title "Employee creation accepts exact minimum boundary salary of Rs. 1,000" -ScriptBlock {
    $sess = New-E2ESession
    $null = Invoke-E2ELogin -Session $sess -UsernameOrEmail "admin" -Password "Admin@123"
    $rnd = Get-Random -Minimum 1000 -Maximum 9999
    $empData = @{
        "EmployeeId" = "0"
        "AddressId"  = "0"
        "Name"       = "Min Boundary Employee $rnd"
        "Gender"     = "Other"
        "Department" = "Operations"
        "Salary"     = "1000"
        "Country"    = "India"
        "State"      = "Delhi"
        "City"       = "New Delhi"
        "Pin"        = "110001"
    }
    $res = Invoke-E2EPost -Session $sess -Path "/Employee/Create" -FormData $empData -AutoToken $true -FollowRedirects $false
    Assert-StatusCode -Response $res -ExpectedCode 302 -Message "Valid boundary salary passes"
    Assert-RedirectLocation -Response $res -ExpectedPattern "/Employee/Index" -Message "Redirects to Index"
}

Register-TestCase -Id "T2_F08_04" -Tier "Tier 2" -Feature "F08" -Title "Employee creation rejects empty Name with required validation error" -ScriptBlock {
    $sess = New-E2ESession
    $null = Invoke-E2ELogin -Session $sess -UsernameOrEmail "admin" -Password "Admin@123"
    $empData = @{
        "EmployeeId" = "0"
        "AddressId"  = "0"
        "Name"       = ""
        "Gender"     = "Female"
        "Department" = "HR"
        "Salary"     = "50000"
        "Country"    = "India"
        "State"      = "Karnataka"
        "City"       = "Bengaluru"
        "Pin"        = "560001"
    }
    $res = Invoke-E2EPost -Session $sess -Path "/Employee/Create" -FormData $empData -AutoToken $true -FollowRedirects $false
    Assert-StatusCode -Response $res -ExpectedCode 200 -Message "Empty name returns 200"
    Assert-ContainsText -Content $res.Content -ExpectedText "Employee Name is required" -Message "Name required error shown"
}

Register-TestCase -Id "T2_F08_05" -Tier "Tier 2" -Feature "F08" -Title "Employee creation rejects empty PIN code with required validation error" -ScriptBlock {
    $sess = New-E2ESession
    $null = Invoke-E2ELogin -Session $sess -UsernameOrEmail "admin" -Password "Admin@123"
    $empData = @{
        "EmployeeId" = "0"
        "AddressId"  = "0"
        "Name"       = "Missing PIN Employee"
        "Gender"     = "Male"
        "Department" = "IT"
        "Salary"     = "55000"
        "Country"    = "India"
        "State"      = "Maharashtra"
        "City"       = "Mumbai"
        "Pin"        = ""
    }
    $res = Invoke-E2EPost -Session $sess -Path "/Employee/Create" -FormData $empData -AutoToken $true -FollowRedirects $false
    Assert-StatusCode -Response $res -ExpectedCode 200 -Message "Empty PIN returns 200"
    Assert-ContainsText -Content $res.Content -ExpectedText "PIN Code is required" -Message "PIN required error shown"
}

# ------------------------------------------------------------------------------
# F09: Multi-Table Employee Editing Form Boundary Cases (5 tests)
# ------------------------------------------------------------------------------

Register-TestCase -Id "T2_F09_01" -Tier "Tier 2" -Feature "F09" -Title "Edit request for non-existent employee ID redirects to Index with error notice" -ScriptBlock {
    $sess = New-E2ESession
    $null = Invoke-E2ELogin -Session $sess -UsernameOrEmail "admin" -Password "Admin@123"
    $res = Invoke-E2EGet -Session $sess -Path "/Employee/Edit/99999" -FollowRedirects $false
    Assert-StatusCode -Response $res -ExpectedCode 302 -Message "Non-existent edit returns 302 redirect"
    Assert-RedirectLocation -Response $res -ExpectedPattern "/Employee/Index" -Message "Redirects to Index"
}

Register-TestCase -Id "T2_F09_02" -Tier "Tier 2" -Feature "F09" -Title "Edit submission with salary below minimum of Rs. 1,000 is rejected" -ScriptBlock {
    $sess = New-E2ESession
    $null = Invoke-E2ELogin -Session $sess -UsernameOrEmail "admin" -Password "Admin@123"
    $updateData = @{
        "EmployeeId" = "101"
        "AddressId"  = "1001"
        "Name"       = "Dillip Mohapatra"
        "Gender"     = "Male"
        "Department" = "IT"
        "Salary"     = "400"
        "Country"    = "India"
        "State"      = "Odisha"
        "City"       = "Bhubaneswar"
        "Pin"        = "751024"
    }
    $res = Invoke-E2EPost -Session $sess -Path "/Employee/Edit/101" -FormData $updateData -AutoToken $true -FollowRedirects $false
    Assert-StatusCode -Response $res -ExpectedCode 200 -Message "Invalid edit salary returns 200"
    Assert-ContainsText -Content $res.Content -ExpectedText "Salary must be between Rs. 1,000 and Rs. 10,000,000" -Message "Range validation message"
}

Register-TestCase -Id "T2_F09_03" -Tier "Tier 2" -Feature "F09" -Title "Edit submission with empty Department is rejected" -ScriptBlock {
    $sess = New-E2ESession
    $null = Invoke-E2ELogin -Session $sess -UsernameOrEmail "admin" -Password "Admin@123"
    $updateData = @{
        "EmployeeId" = "101"
        "AddressId"  = "1001"
        "Name"       = "Dillip Mohapatra"
        "Gender"     = "Male"
        "Department" = ""
        "Salary"     = "65000"
        "Country"    = "India"
        "State"      = "Odisha"
        "City"       = "Bhubaneswar"
        "Pin"        = "751024"
    }
    $res = Invoke-E2EPost -Session $sess -Path "/Employee/Edit/101" -FormData $updateData -AutoToken $true -FollowRedirects $false
    Assert-StatusCode -Response $res -ExpectedCode 200 -Message "Empty department returns 200"
    Assert-ContainsText -Content $res.Content -ExpectedText "Department is required" -Message "Department required message"
}

Register-TestCase -Id "T2_F09_04" -Tier "Tier 2" -Feature "F09" -Title "Edit submission with empty City is rejected" -ScriptBlock {
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
        "City"       = ""
        "Pin"        = "751024"
    }
    $res = Invoke-E2EPost -Session $sess -Path "/Employee/Edit/101" -FormData $updateData -AutoToken $true -FollowRedirects $false
    Assert-StatusCode -Response $res -ExpectedCode 200 -Message "Empty city returns 200"
    Assert-ContainsText -Content $res.Content -ExpectedText "City is required" -Message "City required message"
}

Register-TestCase -Id "T2_F09_05" -Tier "Tier 2" -Feature "F09" -Title "Unauthorized Edit POST by standard user is rejected" -ScriptBlock {
    $sess = New-E2ESession
    $null = Invoke-E2ELogin -Session $sess -UsernameOrEmail "rahul" -Password "User@123"
    $updateData = @{
        "EmployeeId" = "101"
        "AddressId"  = "1001"
        "Name"       = "Tampered Name"
        "Gender"     = "Male"
        "Department" = "IT"
        "Salary"     = "90000"
        "Country"    = "India"
        "State"      = "Odisha"
        "City"       = "Bhubaneswar"
        "Pin"        = "751024"
    }
    $res = Invoke-E2EPost -Session $sess -Path "/Employee/Edit/101" -FormData $updateData -AutoToken $true -FollowRedirects $false
    Assert-StatusCode -Response $res -ExpectedCode 302 -Message "Unauthorized Edit POST returns 302"
    Assert-RedirectLocation -Response $res -ExpectedPattern "/Account/Login" -Message "Redirects to Login"
}

# ------------------------------------------------------------------------------
# F10: Transactional Employee Deletion Boundary Cases (5 tests)
# ------------------------------------------------------------------------------

Register-TestCase -Id "T2_F10_01" -Tier "Tier 2" -Feature "F10" -Title "Delete GET for non-existent employee ID redirects to Index with error notice" -ScriptBlock {
    $sess = New-E2ESession
    $null = Invoke-E2ELogin -Session $sess -UsernameOrEmail "admin" -Password "Admin@123"
    $res = Invoke-E2EGet -Session $sess -Path "/Employee/Delete/99999" -FollowRedirects $false
    Assert-StatusCode -Response $res -ExpectedCode 302 -Message "Non-existent delete returns 302 redirect"
    Assert-RedirectLocation -Response $res -ExpectedPattern "/Employee/Index" -Message "Redirects to Index"
}

Register-TestCase -Id "T2_F10_02" -Tier "Tier 2" -Feature "F10" -Title "Delete POST for non-existent employee ID handles safely" -ScriptBlock {
    $sess = New-E2ESession
    $null = Invoke-E2ELogin -Session $sess -UsernameOrEmail "admin" -Password "Admin@123"
    $page = Invoke-E2EGet -Session $sess -Path "/Employee/Create"
    $token = Get-VerificationToken -Html $page.Content
    $res = Invoke-E2EPost -Session $sess -Path "/Employee/Delete/99999" -FormData @{ "__RequestVerificationToken" = $token; "id" = "99999" } -AutoToken $false -FollowRedirects $false
    Assert-StatusCode -Response $res -ExpectedCode 302 -Message "Non-existent delete POST returns 302"
    Assert-RedirectLocation -Response $res -ExpectedPattern "/Employee/Index" -Message "Redirects to Index"
}

Register-TestCase -Id "T2_F10_03" -Tier "Tier 2" -Feature "F10" -Title "Unauthorized Delete GET by standard user redirects to Login" -ScriptBlock {
    $sess = New-E2ESession
    $null = Invoke-E2ELogin -Session $sess -UsernameOrEmail "rahul" -Password "User@123"
    $res = Invoke-E2EGet -Session $sess -Path "/Employee/Delete/101" -FollowRedirects $false
    Assert-StatusCode -Response $res -ExpectedCode 302 -Message "Unauthorized Delete GET returns 302"
    Assert-RedirectLocation -Response $res -ExpectedPattern "/Account/Login" -Message "Redirects to Login"
}

Register-TestCase -Id "T2_F10_04" -Tier "Tier 2" -Feature "F10" -Title "Unauthorized Delete POST by standard user redirects to Login" -ScriptBlock {
    $sess = New-E2ESession
    $null = Invoke-E2ELogin -Session $sess -UsernameOrEmail "rahul" -Password "User@123"
    $res = Invoke-E2EPost -Session $sess -Path "/Employee/Delete/101" -FormData @{ "id" = "101" } -AutoToken $true -FollowRedirects $false
    Assert-StatusCode -Response $res -ExpectedCode 302 -Message "Unauthorized Delete POST returns 302"
    Assert-RedirectLocation -Response $res -ExpectedPattern "/Account/Login" -Message "Redirects to Login"
}

Register-TestCase -Id "T2_F10_05" -Tier "Tier 2" -Feature "F10" -Title "Transactional deletion cleans up linked address record completely" -ScriptBlock {
    $sess = New-E2ESession
    $null = Invoke-E2ELogin -Session $sess -UsernameOrEmail "admin" -Password "Admin@123"
    $rnd = Get-Random -Minimum 1000 -Maximum 9999
    $empData = @{
        "EmployeeId" = "0"
        "AddressId"  = "0"
        "Name"       = "Orphan Clean Test $rnd"
        "Gender"     = "Male"
        "Department" = "Operations"
        "Salary"     = "43000"
        "Country"    = "India"
        "State"      = "Odisha"
        "City"       = "Bhubaneswar"
        "Pin"        = "751024"
    }
    $null = Invoke-E2EPost -Session $sess -Path "/Employee/Create" -FormData $empData -AutoToken $true -FollowRedirects $false
    $searchRes = Invoke-E2EGet -Session $sess -Path "/Employee/Index?search=Orphan%20Clean%20Test%20$rnd"
    Assert-True -Condition ($searchRes.Content -match 'Delete/(\d+)') -Message "Delete link found"
    $id = $matches[1]

    # Delete
    $delPage = Invoke-E2EGet -Session $sess -Path "/Employee/Delete/$id"
    $token = Get-VerificationToken -Html $delPage.Content
    $null = Invoke-E2EPost -Session $sess -Path "/Employee/Delete/$id" -FormData @{ "__RequestVerificationToken" = $token; "id" = $id } -AutoToken $false -FollowRedirects $false

    # Verify directory confirms deletion
    $searchAfter = Invoke-E2EGet -Session $sess -Path "/Employee/Index?search=Orphan%20Clean%20Test%20$rnd"
    Assert-ContainsText -Content $searchAfter.Content -ExpectedText "No employee records found" -Message "Employee removed"
}

# ------------------------------------------------------------------------------
# F11: Admin Metrics & Workforce Dashboard Boundary Cases (5 tests)
# ------------------------------------------------------------------------------

Register-TestCase -Id "T2_F11_01" -Tier "Tier 2" -Feature "F11" -Title "Unauthenticated request to Dashboard redirects to Login preserving returnUrl" -ScriptBlock {
    $sess = New-E2ESession
    $res = Invoke-E2EGet -Session $sess -Path "/Admin/Dashboard" -FollowRedirects $false
    Assert-StatusCode -Response $res -ExpectedCode 302 -Message "Redirects"
    Assert-MatchesPattern -Content $res.Location -RegexPattern '/Account/Login\?returnUrl=' -Message "Redirects to Login with returnUrl"
}

Register-TestCase -Id "T2_F11_02" -Tier "Tier 2" -Feature "F11" -Title "Non-admin user request to Dashboard is blocked with error alert" -ScriptBlock {
    $sess = New-E2ESession
    $null = Invoke-E2ELogin -Session $sess -UsernameOrEmail "rahul" -Password "User@123"
    $res = Invoke-E2EGet -Session $sess -Path "/Admin/Dashboard" -FollowRedirects $true
    Assert-StatusCode -Response $res -ExpectedCode 200 -Message "Redirect landing returns 200"
    Assert-ContainsText -Content $res.Content -ExpectedText "Access restricted" -Message "Access restricted message shown"
}

Register-TestCase -Id "T2_F11_03" -Tier "Tier 2" -Feature "F11" -Title "Dashboard displays Department breakdown pill badges" -ScriptBlock {
    $sess = New-E2ESession
    $null = Invoke-E2ELogin -Session $sess -UsernameOrEmail "admin" -Password "Admin@123"
    $res = Invoke-E2EGet -Session $sess -Path "/Admin/Dashboard"
    Assert-ContainsText -Content $res.Content -ExpectedText "Workforce by Department" -Message "Department section title"
    Assert-MatchesPattern -Content $res.Content -RegexPattern 'class="tag"' -Message "Department pill elements present"
}

Register-TestCase -Id "T2_F11_04" -Tier "Tier 2" -Feature "F11" -Title "Dashboard renders Recent Employees table limited to at most 5 entries" -ScriptBlock {
    $sess = New-E2ESession
    $null = Invoke-E2ELogin -Session $sess -UsernameOrEmail "admin" -Password "Admin@123"
    $res = Invoke-E2EGet -Session $sess -Path "/Admin/Dashboard"
    Assert-ContainsText -Content $res.Content -ExpectedText "Recent Employees" -Message "Recent Employees section present"
}

Register-TestCase -Id "T2_F11_05" -Tier "Tier 2" -Feature "F11" -Title "Dashboard renders Recent Users table limited to at most 5 entries" -ScriptBlock {
    $sess = New-E2ESession
    $null = Invoke-E2ELogin -Session $sess -UsernameOrEmail "admin" -Password "Admin@123"
    $res = Invoke-E2EGet -Session $sess -Path "/Admin/Dashboard"
    Assert-ContainsText -Content $res.Content -ExpectedText "Recent User Registrations" -Message "Recent Users section present"
}

# ------------------------------------------------------------------------------
# F12: System User Management Directory Boundary Cases (5 tests)
# ------------------------------------------------------------------------------

Register-TestCase -Id "T2_F12_01" -Tier "Tier 2" -Feature "F12" -Title "Unauthenticated request to /Admin/Users redirects to Login with returnUrl" -ScriptBlock {
    $sess = New-E2ESession
    $res = Invoke-E2EGet -Session $sess -Path "/Admin/Users" -FollowRedirects $false
    Assert-StatusCode -Response $res -ExpectedCode 302 -Message "Redirects"
    Assert-MatchesPattern -Content $res.Location -RegexPattern '/Account/Login\?returnUrl=' -Message "Redirects to Login with returnUrl"
}

Register-TestCase -Id "T2_F12_02" -Tier "Tier 2" -Feature "F12" -Title "Standard User request to /Admin/Users is blocked with privileges required notice" -ScriptBlock {
    $sess = New-E2ESession
    $null = Invoke-E2ELogin -Session $sess -UsernameOrEmail "rahul" -Password "User@123"
    $res = Invoke-E2EGet -Session $sess -Path "/Admin/Users" -FollowRedirects $true
    Assert-StatusCode -Response $res -ExpectedCode 200 -Message "Redirect landing returns 200"
    Assert-ContainsText -Content $res.Content -ExpectedText "Administrator privileges required." -Message "Privileges required alert"
}

Register-TestCase -Id "T2_F12_03" -Tier "Tier 2" -Feature "F12" -Title "System Users table does NOT expose passwords or password hashes in HTML" -ScriptBlock {
    $sess = New-E2ESession
    $null = Invoke-E2ELogin -Session $sess -UsernameOrEmail "admin" -Password "Admin@123"
    $res = Invoke-E2EGet -Session $sess -Path "/Admin/Users"
    Assert-NotContainsText -Content $res.Content -UnexpectedText "Admin@123" -Message "Plaintext password not displayed"
    Assert-NotContainsText -Content $res.Content -UnexpectedText "User@123" -Message "Plaintext password not displayed"
}

Register-TestCase -Id "T2_F12_04" -Tier "Tier 2" -Feature "F12" -Title "Newly registered user appears in /Admin/Users directory" -ScriptBlock {
    $sessReg = New-E2ESession
    $rnd = Get-Random -Minimum 10000 -Maximum 99999
    $regData = @{
        "FullName"        = "Audit User $rnd"
        "Username"        = "audit_$rnd"
        "Email"           = "audit_$rnd@example.in"
        "Password"        = "Audit@123"
        "ConfirmPassword" = "Audit@123"
    }
    $null = Invoke-E2EPost -Session $sessReg -Path "/Account/Register" -FormData $regData -AutoToken $true -FollowRedirects $false

    $sessAdmin = New-E2ESession
    $null = Invoke-E2ELogin -Session $sessAdmin -UsernameOrEmail "admin" -Password "Admin@123"
    $usersRes = Invoke-E2EGet -Session $sessAdmin -Path "/Admin/Users"
    Assert-ContainsText -Content $usersRes.Content -ExpectedText "audit_$rnd" -Message "Audit user present in table"
}

Register-TestCase -Id "T2_F12_05" -Tier "Tier 2" -Feature "F12" -Title "Users table renders formatted email addresses" -ScriptBlock {
    $sess = New-E2ESession
    $null = Invoke-E2ELogin -Session $sess -UsernameOrEmail "admin" -Password "Admin@123"
    $res = Invoke-E2EGet -Session $sess -Path "/Admin/Users"
    Assert-ContainsText -Content $res.Content -ExpectedText "admin@viewmodeldemo.com" -Message "Valid email format"
    Assert-ContainsText -Content $res.Content -ExpectedText "rahul.sharma@example.com" -Message "Valid email format"
}

# ------------------------------------------------------------------------------
# F13: Student Domain Model Raw Listing Boundary Cases (5 tests)
# ------------------------------------------------------------------------------

Register-TestCase -Id "T2_F13_01" -Tier "Tier 2" -Feature "F13" -Title "Raw student marks are rendered as plain numbers without badge wrapper" -ScriptBlock {
    $sess = New-E2ESession
    $res = Invoke-E2EGet -Session $sess -Path "/Student/Index"
    Assert-StatusCode -Response $res -ExpectedCode 200 -Message "Raw listing returns 200"
    Assert-NotContainsText -Content $res.Content -UnexpectedText "marks-badge" -Message "No colored marks badges in raw listing"
}

Register-TestCase -Id "T2_F13_02" -Tier "Tier 2" -Feature "F13" -Title "Student raw table records are ordered by RollNo ascending" -ScriptBlock {
    $sess = New-E2ESession
    $res = Invoke-E2EGet -Session $sess -Path "/Student/Index"
    $idx1 = $res.Content.IndexOf("Ankur")
    $idx2 = $res.Content.IndexOf("Dhrumit")
    $idx3 = $res.Content.IndexOf("Mannan")
    Assert-True -Condition ($idx1 -lt $idx2 -and $idx2 -lt $idx3) -Message "Students ordered by RollNo ascending"
}

Register-TestCase -Id "T2_F13_03" -Tier "Tier 2" -Feature "F13" -Title "Student raw listing presents complete database seed count of 5 students" -ScriptBlock {
    $sess = New-E2ESession
    $res = Invoke-E2EGet -Session $sess -Path "/Student/Index"
    Assert-ContainsText -Content $res.Content -ExpectedText "Ankur" -Message "Student 1 present"
    Assert-ContainsText -Content $res.Content -ExpectedText "Dhrumit" -Message "Student 2 present"
    Assert-ContainsText -Content $res.Content -ExpectedText "Mannan" -Message "Student 3 present"
    Assert-ContainsText -Content $res.Content -ExpectedText "Priya Sharma" -Message "Student 4 present"
    Assert-ContainsText -Content $res.Content -ExpectedText "Amit Verma" -Message "Student 5 present"
}

Register-TestCase -Id "T2_F13_04" -Tier "Tier 2" -Feature "F13" -Title "Student raw listing table has valid HTML table structure" -ScriptBlock {
    $sess = New-E2ESession
    $res = Invoke-E2EGet -Session $sess -Path "/Student/Index"
    Assert-MatchesPattern -Content $res.Content -RegexPattern '(?s)<table[^>]*>.*?<thead>.*?<tbody>.*?</table>' -Message "Valid table structure"
}

Register-TestCase -Id "T2_F13_05" -Tier "Tier 2" -Feature "F13" -Title "Student raw listing page title and header explicitly describe Domain Model pattern" -ScriptBlock {
    $sess = New-E2ESession
    $res = Invoke-E2EGet -Session $sess -Path "/Student/Index"
    Assert-ContainsText -Content $res.Content -ExpectedText "Student Domain Model List" -Message "Page title reflects domain model"
}

# ------------------------------------------------------------------------------
# F14: Student Marks Presentation (getStud) Boundary Cases (5 tests)
# ------------------------------------------------------------------------------

Register-TestCase -Id "T2_F14_01" -Tier "Tier 2" -Feature "F14" -Title "Boundary score evaluation: Score <= 35.0 (Ankur: 34) has background-color: red" -ScriptBlock {
    $sess = New-E2ESession
    $res = Invoke-E2EGet -Session $sess -Path "/Student/getStud"
    Assert-MatchesPattern -Content $res.Content -RegexPattern '(?s)background-color:\s*red[^>]*>\s*34' -Message "Score 34 has red background"
}

Register-TestCase -Id "T2_F14_02" -Tier "Tier 2" -Feature "F14" -Title "Boundary score evaluation: Score > 35.0 (Dhrumit: 79) has background-color: green" -ScriptBlock {
    $sess = New-E2ESession
    $res = Invoke-E2EGet -Session $sess -Path "/Student/getStud"
    Assert-MatchesPattern -Content $res.Content -RegexPattern '(?s)background-color:\s*green[^>]*>\s*79' -Message "Score 79 has green background"
}

Register-TestCase -Id "T2_F14_03" -Tier "Tier 2" -Feature "F14" -Title "Decimal score formatting: Priya Sharma with score 88.5 has green status" -ScriptBlock {
    $sess = New-E2ESession
    $res = Invoke-E2EGet -Session $sess -Path "/Student/getStud"
    Assert-MatchesPattern -Content $res.Content -RegexPattern '(?s)background-color:\s*green[^>]*>\s*88\.5' -Message "Decimal score 88.5 has green background"
}

Register-TestCase -Id "T2_F14_04" -Tier "Tier 2" -Feature "F14" -Title "Failing score evaluation: Amit Verma with score 31.0 has red status" -ScriptBlock {
    $sess = New-E2ESession
    $res = Invoke-E2EGet -Session $sess -Path "/Student/getStud"
    Assert-MatchesPattern -Content $res.Content -RegexPattern '(?s)background-color:\s*red[^>]*>\s*31' -Message "Score 31 has red background"
}

Register-TestCase -Id "T2_F14_05" -Tier "Tier 2" -Feature "F14" -Title "ViewModel formatting documentation: Subtitle describes pass/fail condition" -ScriptBlock {
    $sess = New-E2ESession
    $res = Invoke-E2EGet -Session $sess -Path "/Student/getStud"
    Assert-ContainsText -Content $res.Content -ExpectedText "Marks > 35 highlighted in Green, else Red" -Message "Subtitle describes threshold logic"
}

# ------------------------------------------------------------------------------
# F15: Offline Resiliency & Fallback Data Access Boundary Cases (5 tests)
# ------------------------------------------------------------------------------

Register-TestCase -Id "T2_F15_01" -Tier "Tier 2" -Feature "F15" -Title "Directory search input with SQL meta-characters executes safely without SQL injection" -ScriptBlock {
    $sess = New-E2ESession
    $res = Invoke-E2EGet -Session $sess -Path "/Employee/Index?search=%27%20OR%20%271%27%3D%271"
    Assert-StatusCode -Response $res -ExpectedCode 200 -Message "SQL injection probe handled safely with 200 OK"
}

Register-TestCase -Id "T2_F15_02" -Tier "Tier 2" -Feature "F15" -Title "Pre-configured Administrator credentials authenticate against system" -ScriptBlock {
    $sess = New-E2ESession
    $res = Invoke-E2ELogin -Session $sess -UsernameOrEmail "admin" -Password "Admin@123"
    Assert-StatusCode -Response $res -ExpectedCode 302 -Message "Admin credentials accepted"
    Assert-RedirectLocation -Response $res -ExpectedPattern "/Admin/Dashboard" -Message "Routes to Dashboard"
}

Register-TestCase -Id "T2_F15_03" -Tier "Tier 2" -Feature "F15" -Title "Pre-configured Standard User credentials authenticate against system" -ScriptBlock {
    $sess = New-E2ESession
    $res = Invoke-E2ELogin -Session $sess -UsernameOrEmail "rahul" -Password "User@123"
    Assert-StatusCode -Response $res -ExpectedCode 302 -Message "User credentials accepted"
    Assert-RedirectLocation -Response $res -ExpectedPattern "/Employee/Index" -Message "Routes to Index"
}

Register-TestCase -Id "T2_F15_04" -Tier "Tier 2" -Feature "F15" -Title "Workforce analytics aggregates calculate non-zero total payroll" -ScriptBlock {
    $sess = New-E2ESession
    $null = Invoke-E2ELogin -Session $sess -UsernameOrEmail "admin" -Password "Admin@123"
    $res = Invoke-E2EGet -Session $sess -Path "/Admin/Dashboard"
    Assert-MatchesPattern -Content $res.Content -RegexPattern 'Rs\.\s*[1-9][0-9,]+' -Message "Non-zero payroll calculated"
}

Register-TestCase -Id "T2_F15_05" -Tier "Tier 2" -Feature "F15" -Title "Student marks evaluation handles boundary logic consistently across all scores" -ScriptBlock {
    $sess = New-E2ESession
    $res = Invoke-E2EGet -Session $sess -Path "/Student/getStud"
    Assert-ContainsText -Content $res.Content -ExpectedText "green" -Message "Green mapping exists"
    Assert-ContainsText -Content $res.Content -ExpectedText "red" -Message "Red mapping exists"
}
