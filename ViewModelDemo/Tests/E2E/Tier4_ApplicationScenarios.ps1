# ==============================================================================
# Tier4_ApplicationScenarios.ps1 - Tier 4: Real-World Application Workflows
# Realistic Multi-Step Workflows under authentic Indian Context
# Total Tests: 8 Comprehensive Workflows (T4_SCENARIO_01 to T4_SCENARIO_08)
# STRICT ZERO EMOJIS
# ==============================================================================

# Ensure TestHarness functions are available
if (-not (Get-Command "Register-TestCase" -ErrorAction SilentlyContinue)) {
    . "$PSScriptRoot\TestHarness.ps1"
}

Register-TestCase -Id "T4_SCENARIO_01" -Tier "Tier 4" -Feature "F08+F06+F07+F10" -Title "Scenario 1: Kolkata Technology Hub Onboarding" -ScriptBlock {
    $sess = New-E2ESession
    $null = Invoke-E2ELogin -Session $sess -UsernameOrEmail "admin" -Password "Admin@123"

    # 1. Onboard Subhashish Roy in Kolkata
    $rnd = Get-Random -Minimum 1000 -Maximum 9999
    $empName = "Subhashish Roy $rnd"
    $empData = @{
        "EmployeeId" = "0"
        "AddressId"  = "0"
        "Name"       = $empName
        "Gender"     = "Male"
        "Department" = "IT"
        "Salary"     = "64000"
        "Country"    = "India"
        "State"      = "West Bengal"
        "City"       = "Kolkata"
        "Pin"        = "700091"
    }
    $createRes = Invoke-E2EPost -Session $sess -Path "/Employee/Create" -FormData $empData -AutoToken $true -FollowRedirects $false
    Assert-StatusCode -Response $createRes -ExpectedCode 302 -Message "Creation succeeded"

    # 2. Search directory
    $searchRes = Invoke-E2EGet -Session $sess -Path "/Employee/Index?search=Subhashish%20Roy%20$rnd"
    Assert-ContainsText -Content $searchRes.Content -ExpectedText $empName -Message "Employee found in search"
    Assert-MatchesPattern -Content $searchRes.Content -RegexPattern 'Rs\.\s*64,000\.00' -Message "Salary formatted in INR"
    Assert-True -Condition ($searchRes.Content -match 'Details/(\d+)') -Message "Details link exists"
    $id = $matches[1]

    # 3. View aggregated details
    $detailsRes = Invoke-E2EGet -Session $sess -Path "/Employee/Details/$id"
    Assert-StatusCode -Response $detailsRes -ExpectedCode 200 -Message "Details loads"
    Assert-ContainsText -Content $detailsRes.Content -ExpectedText "Kolkata" -Message "City is Kolkata"
    Assert-ContainsText -Content $detailsRes.Content -ExpectedText "West Bengal" -Message "State is West Bengal"
    Assert-ContainsText -Content $detailsRes.Content -ExpectedText "700091" -Message "PIN is 700091"

    # 4. Clean up employee
    $delPage = Invoke-E2EGet -Session $sess -Path "/Employee/Delete/$id"
    $token = Get-VerificationToken -Html $delPage.Content
    $null = Invoke-E2EPost -Session $sess -Path "/Employee/Delete/$id" -FormData @{ "__RequestVerificationToken" = $token; "id" = $id } -AutoToken $false -FollowRedirects $false
    $null = Invoke-E2ELogout -Session $sess
}

Register-TestCase -Id "T4_SCENARIO_02" -Tier "Tier 4" -Feature "F09+F11" -Title "Scenario 2: Annual Compensation Review & Payroll Audit" -ScriptBlock {
    $sess = New-E2ESession
    $null = Invoke-E2ELogin -Session $sess -UsernameOrEmail "admin" -Password "Admin@123"

    # 1. Capture initial dashboard payroll
    $dashBefore = Invoke-E2EGet -Session $sess -Path "/Admin/Dashboard"
    Assert-StatusCode -Response $dashBefore -ExpectedCode 200 -Message "Dashboard loads"

    # 2. Find Priya Patel (ID 102) and update salary from 58000 to 68000
    $editPage = Invoke-E2EGet -Session $sess -Path "/Employee/Edit/102"
    $token = Get-VerificationToken -Html $editPage.Content
    $addrId = if ($editPage.Content -match 'name="AddressId"[^>]*value="(\d+)"|value="(\d+)"[^>]*name="AddressId"') {
                  if ($matches[1]) { $matches[1] } else { $matches[2] }
              } else { "1002" }

    $updateData = @{
        "__RequestVerificationToken" = $token
        "EmployeeId"                 = "102"
        "AddressId"                  = $addrId
        "Name"                       = "Priya Patel"
        "Gender"                     = "Female"
        "Department"                 = "HR"
        "Salary"                     = "68000"
        "Country"                    = "India"
        "State"                      = "West Bengal"
        "City"                       = "Kolkata"
        "Pin"                        = "700091"
    }
    $editRes = Invoke-E2EPost -Session $sess -Path "/Employee/Edit/102" -FormData $updateData -AutoToken $false -FollowRedirects $false
    Assert-StatusCode -Response $editRes -ExpectedCode 302 -Message "Salary update returns 302"

    # 3. Check Dashboard payroll reflects updated figure
    $dashAfter = Invoke-E2EGet -Session $sess -Path "/Admin/Dashboard"
    Assert-StatusCode -Response $dashAfter -ExpectedCode 200 -Message "Dashboard loads after salary change"
    Assert-MatchesPattern -Content $dashAfter.Content -RegexPattern 'Monthly Payroll' -Message "Monthly Payroll card present"

    # 4. Restore Priya Patel's salary back to baseline 58000
    $updateData["Salary"] = "58000"
    $editPageRestore = Invoke-E2EGet -Session $sess -Path "/Employee/Edit/102"
    $updateData["__RequestVerificationToken"] = Get-VerificationToken -Html $editPageRestore.Content
    $null = Invoke-E2EPost -Session $sess -Path "/Employee/Edit/102" -FormData $updateData -AutoToken $false -FollowRedirects $false

    $null = Invoke-E2ELogout -Session $sess
}

Register-TestCase -Id "T4_SCENARIO_03" -Tier "Tier 4" -Feature "F08+F06+F11" -Title "Scenario 3: Bengaluru Tech Hub Workforce Expansion" -ScriptBlock {
    $sess = New-E2ESession
    $null = Invoke-E2ELogin -Session $sess -UsernameOrEmail "admin" -Password "Admin@123"

    # 1. Create Vikram Joshi in Bengaluru
    $rnd = Get-Random -Minimum 1000 -Maximum 9999
    $empName = "Vikram Joshi $rnd"
    $empData = @{
        "EmployeeId" = "0"
        "AddressId"  = "0"
        "Name"       = $empName
        "Gender"     = "Male"
        "Department" = "Engineering"
        "Salary"     = "88000"
        "Country"    = "India"
        "State"      = "Karnataka"
        "City"       = "Bengaluru"
        "Pin"        = "560001"
    }
    $null = Invoke-E2EPost -Session $sess -Path "/Employee/Create" -FormData $empData -AutoToken $true -FollowRedirects $false

    # 2. Search directory by city Bengaluru
    $citySearch = Invoke-E2EGet -Session $sess -Path "/Employee/Index?search=Bengaluru"
    Assert-StatusCode -Response $citySearch -ExpectedCode 200 -Message "City search succeeds"
    Assert-ContainsText -Content $citySearch.Content -ExpectedText "Rahul Sharma" -Message "Seeded Bengaluru employee present"
    Assert-ContainsText -Content $citySearch.Content -ExpectedText $empName -Message "New Bengaluru employee present"

    # 3. Locate ID and clean up
    Assert-True -Condition ($citySearch.Content -match "Edit/(\d+)[^>]*>.*?$empName|Details/(\d+)") -Message "Employee found"
    $searchSpecific = Invoke-E2EGet -Session $sess -Path "/Employee/Index?search=Vikram%20Joshi%20$rnd"
    Assert-True -Condition ($searchSpecific.Content -match 'Delete/(\d+)') -Message "Delete link found"
    $delId = $matches[1]

    $delPage = Invoke-E2EGet -Session $sess -Path "/Employee/Delete/$delId"
    $token = Get-VerificationToken -Html $delPage.Content
    $null = Invoke-E2EPost -Session $sess -Path "/Employee/Delete/$delId" -FormData @{ "__RequestVerificationToken" = $token; "id" = $delId } -AutoToken $false -FollowRedirects $false
    $null = Invoke-E2ELogout -Session $sess
}

Register-TestCase -Id "T4_SCENARIO_04" -Tier "Tier 4" -Feature "F04+F01+F03" -Title "Scenario 4: Cross-Role Privilege Escalation Security Audit" -ScriptBlock {
    $sess = New-E2ESession
    $null = Invoke-E2ELogin -Session $sess -UsernameOrEmail "rahul" -Password "User@123"

    # 1. Directory view has no Edit/Delete links
    $dirRes = Invoke-E2EGet -Session $sess -Path "/Employee/Index"
    Assert-NotContainsText -Content $dirRes.Content -UnexpectedText "/Employee/Edit" -Message "User cannot see Edit links"
    Assert-NotContainsText -Content $dirRes.Content -UnexpectedText "/Employee/Delete" -Message "User cannot see Delete links"

    # 2. Verify all 5 privileged routes are intercepted:
    $p1 = Invoke-E2EGet -Session $sess -Path "/Admin/Dashboard" -FollowRedirects $false
    Assert-StatusCode -Response $p1 -ExpectedCode 302 -Message "Admin Dashboard blocked"

    $p2 = Invoke-E2EGet -Session $sess -Path "/Admin/Users" -FollowRedirects $false
    Assert-StatusCode -Response $p2 -ExpectedCode 302 -Message "Admin Users blocked"

    $p3 = Invoke-E2EGet -Session $sess -Path "/Employee/Create" -FollowRedirects $false
    Assert-StatusCode -Response $p3 -ExpectedCode 302 -Message "Employee Create blocked"

    $p4 = Invoke-E2EGet -Session $sess -Path "/Employee/Edit/101" -FollowRedirects $false
    Assert-StatusCode -Response $p4 -ExpectedCode 302 -Message "Employee Edit blocked"

    $p5 = Invoke-E2EGet -Session $sess -Path "/Employee/Delete/101" -FollowRedirects $false
    Assert-StatusCode -Response $p5 -ExpectedCode 302 -Message "Employee Delete blocked"

    $null = Invoke-E2ELogout -Session $sess
}

Register-TestCase -Id "T4_SCENARIO_05" -Tier "Tier 4" -Feature "F13+F14" -Title "Scenario 5: Academic Semester Grading & Score Evaluation" -ScriptBlock {
    $sess = New-E2ESession

    # 1. Review raw domain scores
    $rawRes = Invoke-E2EGet -Session $sess -Path "/Student/Index"
    Assert-StatusCode -Response $rawRes -ExpectedCode 200 -Message "Student raw list returns 200"
    Assert-ContainsText -Content $rawRes.Content -ExpectedText "Ankur" -Message "Contains student Ankur"
    Assert-ContainsText -Content $rawRes.Content -ExpectedText "Dhrumit" -Message "Contains student Dhrumit"
    Assert-ContainsText -Content $rawRes.Content -ExpectedText "34" -Message "Raw marks 34 displayed"

    # 2. View ViewModel presentation logic
    $vmRes = Invoke-E2EGet -Session $sess -Path "/Student/getStud"
    Assert-StatusCode -Response $vmRes -ExpectedCode 200 -Message "getStud returns 200"

    # Validate threshold logic (>35 green, <=35 red)
    Assert-MatchesPattern -Content $vmRes.Content -RegexPattern '(?s)background-color:\s*red[^>]*>\s*34' -Message "Score 34 (<=35) is Red"
    Assert-MatchesPattern -Content $vmRes.Content -RegexPattern '(?s)background-color:\s*green[^>]*>\s*79' -Message "Score 79 (>35) is Green"
    Assert-MatchesPattern -Content $vmRes.Content -RegexPattern '(?s)background-color:\s*green[^>]*>\s*67' -Message "Score 67 (>35) is Green"
    Assert-MatchesPattern -Content $vmRes.Content -RegexPattern '(?s)background-color:\s*green[^>]*>\s*88\.5' -Message "Score 88.5 (>35) is Green"
    Assert-MatchesPattern -Content $vmRes.Content -RegexPattern '(?s)background-color:\s*red[^>]*>\s*31' -Message "Score 31 (<=35) is Red"
}

Register-TestCase -Id "T4_SCENARIO_06" -Tier "Tier 4" -Feature "F08+F09+F06" -Title "Scenario 6: Departmental Transfer & Workforce Reorganization" -ScriptBlock {
    $sess = New-E2ESession
    $null = Invoke-E2ELogin -Session $sess -UsernameOrEmail "admin" -Password "Admin@123"

    # 1. Create employee in IT
    $rnd = Get-Random -Minimum 1000 -Maximum 9999
    $empName = "Manish Agarwal $rnd"
    $empData = @{
        "EmployeeId" = "0"
        "AddressId"  = "0"
        "Name"       = $empName
        "Gender"     = "Male"
        "Department" = "IT"
        "Salary"     = "56000"
        "Country"    = "India"
        "State"      = "Maharashtra"
        "City"       = "Pune"
        "Pin"        = "411001"
    }
    $null = Invoke-E2EPost -Session $sess -Path "/Employee/Create" -FormData $empData -AutoToken $true -FollowRedirects $false

    # 2. Locate employee and transfer to Operations with salary 62000
    $searchRes = Invoke-E2EGet -Session $sess -Path "/Employee/Index?search=Manish%20Agarwal%20$rnd"
    Assert-True -Condition ($searchRes.Content -match 'Edit/(\d+)') -Message "Edit link found"
    $id = $matches[1]

    $editPage = Invoke-E2EGet -Session $sess -Path "/Employee/Edit/$id"
    $token = Get-VerificationToken -Html $editPage.Content
    $addrId = if ($editPage.Content -match 'name="AddressId"[^>]*value="(\d+)"|value="(\d+)"[^>]*name="AddressId"') {
                  if ($matches[1]) { $matches[1] } else { $matches[2] }
              } else { "1001" }

    $transferData = @{
        "__RequestVerificationToken" = $token
        "EmployeeId"                 = $id
        "AddressId"                  = $addrId
        "Name"                       = $empName
        "Gender"                     = "Male"
        "Department"                 = "Operations"
        "Salary"                     = "62000"
        "Country"                    = "India"
        "State"                      = "Maharashtra"
        "City"                       = "Pune"
        "Pin"                        = "411001"
    }
    $null = Invoke-E2EPost -Session $sess -Path "/Employee/Edit/$id" -FormData $transferData -AutoToken $false -FollowRedirects $false

    # 3. Verify directory reflects Operations department
    $searchAfter = Invoke-E2EGet -Session $sess -Path "/Employee/Index?search=Manish%20Agarwal%20$rnd"
    Assert-ContainsText -Content $searchAfter.Content -ExpectedText "Operations" -Message "Department updated to Operations"

    # 4. Clean up
    $delPage = Invoke-E2EGet -Session $sess -Path "/Employee/Delete/$id"
    $tokenDel = Get-VerificationToken -Html $delPage.Content
    $null = Invoke-E2EPost -Session $sess -Path "/Employee/Delete/$id" -FormData @{ "__RequestVerificationToken" = $tokenDel; "id" = $id } -AutoToken $false -FollowRedirects $false
    $null = Invoke-E2ELogout -Session $sess
}

Register-TestCase -Id "T4_SCENARIO_07" -Tier "Tier 4" -Feature "F08+F10+F06" -Title "Scenario 7: Contract Offboarding & Complete Relational Sanitization" -ScriptBlock {
    $sess = New-E2ESession
    $null = Invoke-E2ELogin -Session $sess -UsernameOrEmail "admin" -Password "Admin@123"

    # 1. Create temporary contractor
    $rnd = Get-Random -Minimum 1000 -Maximum 9999
    $empName = "Karan Mehra $rnd"
    $empData = @{
        "EmployeeId" = "0"
        "AddressId"  = "0"
        "Name"       = $empName
        "Gender"     = "Male"
        "Department" = "Finance"
        "Salary"     = "48000"
        "Country"    = "India"
        "State"      = "Delhi"
        "City"       = "New Delhi"
        "Pin"        = "110001"
    }
    $null = Invoke-E2EPost -Session $sess -Path "/Employee/Create" -FormData $empData -AutoToken $true -FollowRedirects $false

    # 2. Find contractor ID
    $searchRes = Invoke-E2EGet -Session $sess -Path "/Employee/Index?search=Karan%20Mehra%20$rnd"
    Assert-True -Condition ($searchRes.Content -match 'Delete/(\d+)') -Message "Delete link found"
    $empId = $matches[1]

    # 3. Execute transactional deletion
    $delPage = Invoke-E2EGet -Session $sess -Path "/Employee/Delete/$empId"
    $token = Get-VerificationToken -Html $delPage.Content
    $null = Invoke-E2EPost -Session $sess -Path "/Employee/Delete/$empId" -FormData @{ "__RequestVerificationToken" = $token; "id" = $empId } -AutoToken $false -FollowRedirects $false

    # 4. Search returns empty state
    $searchAfter = Invoke-E2EGet -Session $sess -Path "/Employee/Index?search=Karan%20Mehra%20$rnd"
    Assert-ContainsText -Content $searchAfter.Content -ExpectedText "No employee records found" -Message "Contractor purged"

    $null = Invoke-E2ELogout -Session $sess
}

Register-TestCase -Id "T4_SCENARIO_08" -Tier "Tier 4" -Feature "F01..F15" -Title "Scenario 8: Multi-Persona Enterprise Daily Operations Walkthrough" -ScriptBlock {
    # Persona A: Admin audits dashboard and creates employee
    $adminSess = New-E2ESession
    $null = Invoke-E2ELogin -Session $adminSess -UsernameOrEmail "admin" -Password "Admin@123"
    $dashRes = Invoke-E2EGet -Session $adminSess -Path "/Admin/Dashboard"
    Assert-StatusCode -Response $dashRes -ExpectedCode 200 -Message "Admin loads dashboard"

    $rnd = Get-Random -Minimum 1000 -Maximum 9999
    $empName = "Deepa Kulkarni $rnd"
    $empData = @{
        "EmployeeId" = "0"
        "AddressId"  = "0"
        "Name"       = $empName
        "Gender"     = "Female"
        "Department" = "IT"
        "Salary"     = "72000"
        "Country"    = "India"
        "State"      = "Maharashtra"
        "City"       = "Mumbai"
        "Pin"        = "400001"
    }
    $null = Invoke-E2EPost -Session $adminSess -Path "/Employee/Create" -FormData $empData -AutoToken $true -FollowRedirects $false

    # Persona B: Standard user Rahul Sharma browses directory concurrently
    $userSess = New-E2ESession
    $null = Invoke-E2ELogin -Session $userSess -UsernameOrEmail "rahul" -Password "User@123"
    $userDir = Invoke-E2EGet -Session $userSess -Path "/Employee/Index?search=Deepa%20Kulkarni%20$rnd"
    Assert-ContainsText -Content $userDir.Content -ExpectedText $empName -Message "Standard user sees newly created employee"
    Assert-MatchesPattern -Content $userDir.Content -RegexPattern 'href="[^"]*Employee/Details/\d+"' -Message "Standard user has View Details"
    Assert-NotContainsText -Content $userDir.Content -UnexpectedText "/Employee/Edit" -Message "Standard user cannot edit"

    # Persona A (Admin) cleans up
    $searchAdmin = Invoke-E2EGet -Session $adminSess -Path "/Employee/Index?search=Deepa%20Kulkarni%20$rnd"
    Assert-True -Condition ($searchAdmin.Content -match 'Delete/(\d+)') -Message "Delete link found"
    $empId = $matches[1]

    $delPage = Invoke-E2EGet -Session $adminSess -Path "/Employee/Delete/$empId"
    $token = Get-VerificationToken -Html $delPage.Content
    $null = Invoke-E2EPost -Session $adminSess -Path "/Employee/Delete/$empId" -FormData @{ "__RequestVerificationToken" = $token; "id" = $empId } -AutoToken $false -FollowRedirects $false

    # Both log out cleanly
    $null = Invoke-E2ELogout -Session $userSess
    $null = Invoke-E2ELogout -Session $adminSess
}
