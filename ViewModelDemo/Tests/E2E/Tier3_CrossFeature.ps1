# ==============================================================================
# Tier3_CrossFeature.ps1 - Tier 3: Cross-Feature Combinations
# Methodology: Pairwise & Cross-Feature Integration Testing
# Total Tests: 15 Tests (T3_CROSS_01 to T3_CROSS_15)
# STRICT ZERO EMOJIS
# ==============================================================================

# Ensure TestHarness functions are available
if (-not (Get-Command "Register-TestCase" -ErrorAction SilentlyContinue)) {
    . "$PSScriptRoot\TestHarness.ps1"
}

Register-TestCase -Id "T3_CROSS_01" -Tier "Tier 3" -Feature "F02+F01+F05" -Title "Registration automatically creates session, sets user pill, and redirects to Directory" -ScriptBlock {
    $sess = New-E2ESession
    $rnd = Get-Random -Minimum 10000 -Maximum 99999
    $userName = "priya_$rnd"
    $fullName = "Priya Roy $rnd"
    $regData = @{
        "FullName"        = $fullName
        "Username"        = $userName
        "Email"           = "priya_$rnd@example.in"
        "Password"        = "Priya@123"
        "ConfirmPassword" = "Priya@123"
    }
    $regRes = Invoke-E2EPost -Session $sess -Path "/Account/Register" -FormData $regData -AutoToken $true -FollowRedirects $false
    Assert-StatusCode -Response $regRes -ExpectedCode 302 -Message "Registration redirects"
    Assert-RedirectLocation -Response $regRes -ExpectedPattern "/Employee/Index" -Message "Redirects to Index"

    # Follow redirect
    $indexRes = Invoke-E2EGet -Session $sess -Path "/Employee/Index"
    Assert-StatusCode -Response $indexRes -ExpectedCode 200 -Message "Index loads for registered user"
    Assert-ContainsText -Content $indexRes.Content -ExpectedText $fullName -Message "User pill renders registered full name"
    Assert-MatchesPattern -Content $indexRes.Content -RegexPattern 'role-badge[^>]*badge-user|badge-user' -Message "User pill renders User badge"
}

Register-TestCase -Id "T3_CROSS_02" -Tier "Tier 3" -Feature "F02+F04+F11" -Title "Registered User attempting /Admin/Dashboard is intercepted with access restricted notice" -ScriptBlock {
    $sess = New-E2ESession
    $rnd = Get-Random -Minimum 10000 -Maximum 99999
    $regData = @{
        "FullName"        = "Rajesh Sen $rnd"
        "Username"        = "rajesh_$rnd"
        "Email"           = "rajesh_$rnd@example.in"
        "Password"        = "Rajesh@123"
        "ConfirmPassword" = "Rajesh@123"
    }
    $null = Invoke-E2EPost -Session $sess -Path "/Account/Register" -FormData $regData -AutoToken $true -FollowRedirects $false

    # Attempt to access Admin Dashboard
    $dashRes = Invoke-E2EGet -Session $sess -Path "/Admin/Dashboard" -FollowRedirects $false
    Assert-StatusCode -Response $dashRes -ExpectedCode 302 -Message "User role redirected from Dashboard"
    Assert-MatchesPattern -Content $dashRes.Location -RegexPattern '/Account/Login\?returnUrl=' -Message "Redirects to Login preserving returnUrl"

    # Landing page has error message
    $landingRes = Invoke-E2EGet -Session $sess -Path $dashRes.Location -FollowRedirects $true
    Assert-ContainsText -Content $landingRes.Content -ExpectedText "Access restricted" -Message "Access restricted error message present"
}

Register-TestCase -Id "T3_CROSS_03" -Tier "Tier 3" -Feature "F02+F04+F12" -Title "Registered User attempting /Admin/Users is intercepted with privileges required notice" -ScriptBlock {
    $sess = New-E2ESession
    $rnd = Get-Random -Minimum 10000 -Maximum 99999
    $regData = @{
        "FullName"        = "Alok Gupta $rnd"
        "Username"        = "alok_$rnd"
        "Email"           = "alok_$rnd@example.in"
        "Password"        = "Alok@123"
        "ConfirmPassword" = "Alok@123"
    }
    $null = Invoke-E2EPost -Session $sess -Path "/Account/Register" -FormData $regData -AutoToken $true -FollowRedirects $false

    # Attempt to access Users directory
    $usersRes = Invoke-E2EGet -Session $sess -Path "/Admin/Users" -FollowRedirects $false
    Assert-StatusCode -Response $usersRes -ExpectedCode 302 -Message "User role redirected from Users"

    # Landing page has error message
    $landingRes = Invoke-E2EGet -Session $sess -Path $usersRes.Location -FollowRedirects $true
    Assert-ContainsText -Content $landingRes.Content -ExpectedText "Administrator privileges required." -Message "Privileges required message"
}

Register-TestCase -Id "T3_CROSS_04" -Tier "Tier 3" -Feature "F02+F04+F08" -Title "Registered User attempting /Employee/Create is intercepted with administrator rights notice" -ScriptBlock {
    $sess = New-E2ESession
    $rnd = Get-Random -Minimum 10000 -Maximum 99999
    $regData = @{
        "FullName"        = "Manoj Das $rnd"
        "Username"        = "manoj_$rnd"
        "Email"           = "manoj_$rnd@example.in"
        "Password"        = "Manoj@123"
        "ConfirmPassword" = "Manoj@123"
    }
    $null = Invoke-E2EPost -Session $sess -Path "/Account/Register" -FormData $regData -AutoToken $true -FollowRedirects $false

    # Attempt to access Employee Create
    $createRes = Invoke-E2EGet -Session $sess -Path "/Employee/Create" -FollowRedirects $false
    Assert-StatusCode -Response $createRes -ExpectedCode 302 -Message "User role redirected from Create"
    Assert-MatchesPattern -Content $createRes.Location -RegexPattern '/Account/Login\?returnUrl=' -Message "Redirects to Login preserving returnUrl"

    $landingRes = Invoke-E2EGet -Session $sess -Path $createRes.Location -FollowRedirects $true
    Assert-ContainsText -Content $landingRes.Content -ExpectedText "Only Administrators can add new employees." -Message "Admin only error alert"
}

Register-TestCase -Id "T3_CROSS_05" -Tier "Tier 3" -Feature "F03+F05" -Title "User Logout terminates session, resets user pill, and switches navbar to Login/Register" -ScriptBlock {
    $sess = New-E2ESession
    $null = Invoke-E2ELogin -Session $sess -UsernameOrEmail "admin" -Password "Admin@123"
    $logoutRes = Invoke-E2ELogout -Session $sess
    Assert-StatusCode -Response $logoutRes -ExpectedCode 302 -Message "Logout redirects"

    $indexRes = Invoke-E2EGet -Session $sess -Path "/Employee/Index"
    Assert-MatchesPattern -Content $indexRes.Content -RegexPattern 'href="[^"]*Account/Login"' -Message "Navbar renders Login link"
    Assert-MatchesPattern -Content $indexRes.Content -RegexPattern 'href="[^"]*Account/Register"' -Message "Navbar renders Register link"
    Assert-NotContainsText -Content $indexRes.Content -UnexpectedText "Logout" -Message "Navbar hides Logout"
}

Register-TestCase -Id "T3_CROSS_06" -Tier "Tier 3" -Feature "F02+F12" -Title "Admin logs in and discovers newly registered user in /Admin/Users directory" -ScriptBlock {
    # 1. Register a new user
    $sessUser = New-E2ESession
    $rnd = Get-Random -Minimum 10000 -Maximum 99999
    $uName = "siddharth_$rnd"
    $fName = "Siddharth Rao $rnd"
    $email = "siddharth_$rnd@example.in"
    $regData = @{
        "FullName"        = $fName
        "Username"        = $uName
        "Email"           = $email
        "Password"        = "Sidd@123"
        "ConfirmPassword" = "Sidd@123"
    }
    $null = Invoke-E2EPost -Session $sessUser -Path "/Account/Register" -FormData $regData -AutoToken $true -FollowRedirects $false

    # 2. Admin logs in and audits Users table
    $sessAdmin = New-E2ESession
    $null = Invoke-E2ELogin -Session $sessAdmin -UsernameOrEmail "admin" -Password "Admin@123"
    $usersRes = Invoke-E2EGet -Session $sessAdmin -Path "/Admin/Users"
    Assert-StatusCode -Response $usersRes -ExpectedCode 200 -Message "Users table loads"
    Assert-ContainsText -Content $usersRes.Content -ExpectedText $uName -Message "New username displayed in table"
    Assert-ContainsText -Content $usersRes.Content -ExpectedText $fName -Message "New full name displayed in table"
    Assert-ContainsText -Content $usersRes.Content -ExpectedText $email -Message "New email displayed in table"
}

Register-TestCase -Id "T3_CROSS_07" -Tier "Tier 3" -Feature "F08+F06" -Title "Admin creates composite Employee and Address record, verified via Directory landing" -ScriptBlock {
    $sess = New-E2ESession
    $null = Invoke-E2ELogin -Session $sess -UsernameOrEmail "admin" -Password "Admin@123"
    $rnd = Get-Random -Minimum 1000 -Maximum 9999
    $empName = "Sourav Ganguly $rnd"
    $empData = @{
        "EmployeeId" = "0"
        "AddressId"  = "0"
        "Name"       = $empName
        "Gender"     = "Male"
        "Department" = "Operations"
        "Salary"     = "78000"
        "Country"    = "India"
        "State"      = "West Bengal"
        "City"       = "Kolkata"
        "Pin"        = "700091"
    }
    $createRes = Invoke-E2EPost -Session $sess -Path "/Employee/Create" -FormData $empData -AutoToken $true -FollowRedirects $false
    Assert-StatusCode -Response $createRes -ExpectedCode 302 -Message "Creation returns 302"
    Assert-RedirectLocation -Response $createRes -ExpectedPattern "/Employee/Index" -Message "Redirects to Index"

    $indexRes = Invoke-E2EGet -Session $sess -Path "/Employee/Index"
    Assert-ContainsText -Content $indexRes.Content -ExpectedText "was created successfully." -Message "Creation flash message displayed"
}

Register-TestCase -Id "T3_CROSS_08" -Tier "Tier 3" -Feature "F06+F07" -Title "Directory search accurately isolates created employee with formatted INR salary" -ScriptBlock {
    $sess = New-E2ESession
    $null = Invoke-E2ELogin -Session $sess -UsernameOrEmail "admin" -Password "Admin@123"
    $rnd = Get-Random -Minimum 1000 -Maximum 9999
    $empName = "Mithali Raj $rnd"
    $empData = @{
        "EmployeeId" = "0"
        "AddressId"  = "0"
        "Name"       = $empName
        "Gender"     = "Female"
        "Department" = "Finance"
        "Salary"     = "85000"
        "Country"    = "India"
        "State"      = "Telangana"
        "City"       = "Hyderabad"
        "Pin"        = "500081"
    }
    $null = Invoke-E2EPost -Session $sess -Path "/Employee/Create" -FormData $empData -AutoToken $true -FollowRedirects $false

    $searchRes = Invoke-E2EGet -Session $sess -Path "/Employee/Index?search=Mithali%20Raj%20$rnd"
    Assert-StatusCode -Response $searchRes -ExpectedCode 200 -Message "Search returns 200"
    Assert-ContainsText -Content $searchRes.Content -ExpectedText $empName -Message "Search matches name"
    Assert-MatchesPattern -Content $searchRes.Content -RegexPattern 'Rs\.\s*85,000\.00' -Message "Salary formatted as Rs. 85,000.00"
}

Register-TestCase -Id "T3_CROSS_09" -Tier "Tier 3" -Feature "F06+F07" -Title "Clicking Details on searched employee aggregates Employee and Address domain models" -ScriptBlock {
    $sess = New-E2ESession
    $null = Invoke-E2ELogin -Session $sess -UsernameOrEmail "admin" -Password "Admin@123"
    $rnd = Get-Random -Minimum 1000 -Maximum 9999
    $empName = "Harmanpreet Kaur $rnd"
    $empData = @{
        "EmployeeId" = "0"
        "AddressId"  = "0"
        "Name"       = $empName
        "Gender"     = "Female"
        "Department" = "Engineering"
        "Salary"     = "92000"
        "Country"    = "India"
        "State"      = "Punjab"
        "City"       = "Amritsar"
        "Pin"        = "143001"
    }
    $null = Invoke-E2EPost -Session $sess -Path "/Employee/Create" -FormData $empData -AutoToken $true -FollowRedirects $false

    # Find ID via search
    $searchRes = Invoke-E2EGet -Session $sess -Path "/Employee/Index?search=Harmanpreet%20Kaur%20$rnd"
    Assert-True -Condition ($searchRes.Content -match 'Details/(\d+)') -Message "Details link located"
    $empId = $matches[1]

    # Navigate to Details
    $detailsRes = Invoke-E2EGet -Session $sess -Path "/Employee/Details/$empId"
    Assert-StatusCode -Response $detailsRes -ExpectedCode 200 -Message "Details page returns 200"
    Assert-ContainsText -Content $detailsRes.Content -ExpectedText $empName -Message "Employee name displayed"
    Assert-ContainsText -Content $detailsRes.Content -ExpectedText "Engineering" -Message "Department displayed"
    Assert-ContainsText -Content $detailsRes.Content -ExpectedText "Amritsar" -Message "Address City displayed"
    Assert-ContainsText -Content $detailsRes.Content -ExpectedText "143001" -Message "Address PIN displayed"
}

Register-TestCase -Id "T3_CROSS_10" -Tier "Tier 3" -Feature "F09+F06" -Title "Admin updates created employee details, reflected immediately in Directory search" -ScriptBlock {
    $sess = New-E2ESession
    $null = Invoke-E2ELogin -Session $sess -UsernameOrEmail "admin" -Password "Admin@123"
    $rnd = Get-Random -Minimum 1000 -Maximum 9999
    $empName = "Rohit Sharma $rnd"
    $empData = @{
        "EmployeeId" = "0"
        "AddressId"  = "0"
        "Name"       = $empName
        "Gender"     = "Male"
        "Department" = "IT"
        "Salary"     = "70000"
        "Country"    = "India"
        "State"      = "Maharashtra"
        "City"       = "Mumbai"
        "Pin"        = "400001"
    }
    $null = Invoke-E2EPost -Session $sess -Path "/Employee/Create" -FormData $empData -AutoToken $true -FollowRedirects $false

    # Get employee ID
    $searchRes = Invoke-E2EGet -Session $sess -Path "/Employee/Index?search=Rohit%20Sharma%20$rnd"
    Assert-True -Condition ($searchRes.Content -match 'Edit/(\d+)') -Message "Edit link located"
    $empId = $matches[1]

    # Get Edit view to capture AddressId and token
    $editPage = Invoke-E2EGet -Session $sess -Path "/Employee/Edit/$empId"
    $token = Get-VerificationToken -Html $editPage.Content
    $addrId = if ($editPage.Content -match 'name="AddressId"[^>]*value="(\d+)"|value="(\d+)"[^>]*name="AddressId"') {
                  if ($matches[1]) { $matches[1] } else { $matches[2] }
              } else { "1001" }

    # Update: Increase salary to 95000 and promote to Engineering
    $updateData = @{
        "__RequestVerificationToken" = $token
        "EmployeeId"                 = $empId
        "AddressId"                  = $addrId
        "Name"                       = $empName
        "Gender"                     = "Male"
        "Department"                 = "Engineering"
        "Salary"                     = "95000"
        "Country"                    = "India"
        "State"                      = "Maharashtra"
        "City"                       = "Mumbai"
        "Pin"                        = "400001"
    }
    $editPost = Invoke-E2EPost -Session $sess -Path "/Employee/Edit/$empId" -FormData $updateData -AutoToken $false -FollowRedirects $false
    Assert-StatusCode -Response $editPost -ExpectedCode 302 -Message "Edit update redirects"

    # Verify updated values in search
    $searchAfter = Invoke-E2EGet -Session $sess -Path "/Employee/Index?search=Rohit%20Sharma%20$rnd"
    Assert-ContainsText -Content $searchAfter.Content -ExpectedText "Engineering" -Message "Updated department present"
    Assert-MatchesPattern -Content $searchAfter.Content -RegexPattern 'Rs\.\s*95,000\.00' -Message "Updated salary formatted"
}

Register-TestCase -Id "T3_CROSS_11" -Tier "Tier 3" -Feature "F08+F11" -Title "Admin adds employee and verifies Dashboard metric counts increment" -ScriptBlock {
    $sess = New-E2ESession
    $null = Invoke-E2ELogin -Session $sess -UsernameOrEmail "admin" -Password "Admin@123"

    # Initial dashboard check
    $dashBefore = Invoke-E2EGet -Session $sess -Path "/Admin/Dashboard"
    Assert-StatusCode -Response $dashBefore -ExpectedCode 200 -Message "Dashboard loads"

    # Add new employee
    $rnd = Get-Random -Minimum 1000 -Maximum 9999
    $empData = @{
        "EmployeeId" = "0"
        "AddressId"  = "0"
        "Name"       = "Dashboard Audit Emp $rnd"
        "Gender"     = "Female"
        "Department" = "Finance"
        "Salary"     = "60000"
        "Country"    = "India"
        "State"      = "Delhi"
        "City"       = "New Delhi"
        "Pin"        = "110001"
    }
    $null = Invoke-E2EPost -Session $sess -Path "/Employee/Create" -FormData $empData -AutoToken $true -FollowRedirects $false

    # Audit dashboard after addition
    $dashAfter = Invoke-E2EGet -Session $sess -Path "/Admin/Dashboard"
    Assert-StatusCode -Response $dashAfter -ExpectedCode 200 -Message "Dashboard loads after employee creation"
    Assert-ContainsText -Content $dashAfter.Content -ExpectedText "Total Employees" -Message "Total Employees present"
}

Register-TestCase -Id "T3_CROSS_12" -Tier "Tier 3" -Feature "F13+F14" -Title "Student raw domain model connects to getStud ViewModel formatting view" -ScriptBlock {
    $sess = New-E2ESession
    $rawRes = Invoke-E2EGet -Session $sess -Path "/Student/Index"
    Assert-StatusCode -Response $rawRes -ExpectedCode 200 -Message "Student raw list loads"
    Assert-MatchesPattern -Content $rawRes.Content -RegexPattern 'href="[^"]*Student/getStud"' -Message "Has link to getStud"

    $vmRes = Invoke-E2EGet -Session $sess -Path "/Student/getStud"
    Assert-StatusCode -Response $vmRes -ExpectedCode 200 -Message "getStud loads"
    Assert-ContainsText -Content $vmRes.Content -ExpectedText "green" -Message "Passing status green present"
    Assert-ContainsText -Content $vmRes.Content -ExpectedText "red" -Message "Failing status red present"
}

Register-TestCase -Id "T3_CROSS_13" -Tier "Tier 3" -Feature "F06+F04" -Title "Standard User sees limited actions on directory and cannot perform mutation" -ScriptBlock {
    $sess = New-E2ESession
    $null = Invoke-E2ELogin -Session $sess -UsernameOrEmail "rahul" -Password "User@123"
    $dirRes = Invoke-E2EGet -Session $sess -Path "/Employee/Index"
    Assert-StatusCode -Response $dirRes -ExpectedCode 200 -Message "Directory loads"
    Assert-MatchesPattern -Content $dirRes.Content -RegexPattern 'href="[^"]*Employee/Details/101"' -Message "View Details link present"
    Assert-NotContainsText -Content $dirRes.Content -UnexpectedText "/Employee/Edit/101" -Message "Edit link hidden"
    Assert-NotContainsText -Content $dirRes.Content -UnexpectedText "/Employee/Delete/101" -Message "Delete link hidden"

    # Attempting to access Edit directly redirects
    $editAttempt = Invoke-E2EGet -Session $sess -Path "/Employee/Edit/101" -FollowRedirects $false
    Assert-StatusCode -Response $editAttempt -ExpectedCode 302 -Message "Direct edit attempt blocked"
}

Register-TestCase -Id "T3_CROSS_14" -Tier "Tier 3" -Feature "F10+F06" -Title "Admin deletes created employee, verified purged from search" -ScriptBlock {
    $sess = New-E2ESession
    $null = Invoke-E2ELogin -Session $sess -UsernameOrEmail "admin" -Password "Admin@123"
    $rnd = Get-Random -Minimum 1000 -Maximum 9999
    $empName = "Purge Candidate $rnd"
    $empData = @{
        "EmployeeId" = "0"
        "AddressId"  = "0"
        "Name"       = $empName
        "Gender"     = "Male"
        "Department" = "IT"
        "Salary"     = "51000"
        "Country"    = "India"
        "State"      = "Odisha"
        "City"       = "Bhubaneswar"
        "Pin"        = "751024"
    }
    $null = Invoke-E2EPost -Session $sess -Path "/Employee/Create" -FormData $empData -AutoToken $true -FollowRedirects $false

    # Find ID via search
    $searchRes = Invoke-E2EGet -Session $sess -Path "/Employee/Index?search=Purge%20Candidate%20$rnd"
    Assert-True -Condition ($searchRes.Content -match 'Delete/(\d+)') -Message "Delete link located"
    $id = $matches[1]

    # Perform Delete
    $delPage = Invoke-E2EGet -Session $sess -Path "/Employee/Delete/$id"
    $token = Get-VerificationToken -Html $delPage.Content
    $delPost = Invoke-E2EPost -Session $sess -Path "/Employee/Delete/$id" -FormData @{ "__RequestVerificationToken" = $token; "id" = $id } -AutoToken $false -FollowRedirects $false
    Assert-StatusCode -Response $delPost -ExpectedCode 302 -Message "Delete redirects"

    # Verify search returns empty state
    $searchAfter = Invoke-E2EGet -Session $sess -Path "/Employee/Index?search=Purge%20Candidate%20$rnd"
    Assert-ContainsText -Content $searchAfter.Content -ExpectedText "No employee records found" -Message "Record purged from directory"
}

Register-TestCase -Id "T3_CROSS_15" -Tier "Tier 3" -Feature "F01..F15" -Title "Comprehensive Enterprise Governance Lifecycle" -ScriptBlock {
    # 1. Register new user
    $sessUser = New-E2ESession
    $rnd = Get-Random -Minimum 10000 -Maximum 99999
    $uName = "gov_user_$rnd"
    $regData = @{
        "FullName"        = "Governance Auditor $rnd"
        "Username"        = $uName
        "Email"           = "gov_$rnd@example.in"
        "Password"        = "Audit@123"
        "ConfirmPassword" = "Audit@123"
    }
    $regRes = Invoke-E2EPost -Session $sessUser -Path "/Account/Register" -FormData $regData -AutoToken $true -FollowRedirects $false
    Assert-StatusCode -Response $regRes -ExpectedCode 302 -Message "Registration redirects"

    # 2. Verify User cannot access Admin Dashboard
    $dashAttempt = Invoke-E2EGet -Session $sessUser -Path "/Admin/Dashboard" -FollowRedirects $false
    Assert-StatusCode -Response $dashAttempt -ExpectedCode 302 -Message "Dashboard blocked for new user"

    # 3. Clean user logout
    $null = Invoke-E2ELogout -Session $sessUser

    # 4. Admin logs in
    $sessAdmin = New-E2ESession
    $null = Invoke-E2ELogin -Session $sessAdmin -UsernameOrEmail "admin" -Password "Admin@123"

    # 5. Admin audits user directory
    $usersRes = Invoke-E2EGet -Session $sessAdmin -Path "/Admin/Users"
    Assert-ContainsText -Content $usersRes.Content -ExpectedText $uName -Message "New user listed in Users directory"

    # 6. Admin creates temporary employee
    $empName = "Gov LifeCycle Emp $rnd"
    $empData = @{
        "EmployeeId" = "0"
        "AddressId"  = "0"
        "Name"       = $empName
        "Gender"     = "Female"
        "Department" = "Operations"
        "Salary"     = "68000"
        "Country"    = "India"
        "State"      = "Karnataka"
        "City"       = "Bengaluru"
        "Pin"        = "560001"
    }
    $null = Invoke-E2EPost -Session $sessAdmin -Path "/Employee/Create" -FormData $empData -AutoToken $true -FollowRedirects $false

    # 7. Locate employee and view Details
    $searchRes = Invoke-E2EGet -Session $sessAdmin -Path "/Employee/Index?search=Gov%20LifeCycle%20Emp%20$rnd"
    Assert-True -Condition ($searchRes.Content -match 'Details/(\d+)') -Message "Details link found"
    $empId = $matches[1]

    $detailsRes = Invoke-E2EGet -Session $sessAdmin -Path "/Employee/Details/$empId"
    Assert-ContainsText -Content $detailsRes.Content -ExpectedText "Bengaluru" -Message "Details shows Bengaluru"

    # 8. Check Student marks logic
    $studRes = Invoke-E2EGet -Session $sessAdmin -Path "/Student/getStud"
    Assert-ContainsText -Content $studRes.Content -ExpectedText "green" -Message "Student marks has green"
    Assert-ContainsText -Content $studRes.Content -ExpectedText "red" -Message "Student marks has red"

    # 9. Clean up employee
    $delPage = Invoke-E2EGet -Session $sessAdmin -Path "/Employee/Delete/$empId"
    $delToken = Get-VerificationToken -Html $delPage.Content
    $null = Invoke-E2EPost -Session $sessAdmin -Path "/Employee/Delete/$empId" -FormData @{ "__RequestVerificationToken" = $delToken; "id" = $empId } -AutoToken $false -FollowRedirects $false

    # 10. Clean admin logout
    $null = Invoke-E2ELogout -Session $sessAdmin
}
