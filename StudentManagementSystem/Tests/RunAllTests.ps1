# Automated Code Testing Suite for StudentManagementSystem
# Tests Domain Models, Business Layer, and ADO.NET Data Access against ProjectManagementDB

$ErrorActionPreference = "Stop"

Write-Host "=========================================================="
Write-Host "STARTING REGOROUS CODE TESTING SUITE"
Write-Host "Target Assembly: D:\.NET\StudentManagementSystem\bin\StudentManagementSystem.dll"
Write-Host "=========================================================="

Add-Type -Path "D:\.NET\StudentManagementSystem\bin\StudentManagementSystem.dll"

$passed = 0
$failed = 0
$results = @()

function Assert-Test {
    param(
        [string]$TestName,
        [scriptblock]$Condition,
        [string]$Expected = "",
        [string]$Actual = ""
    )
    try {
        $result = & $Condition
        if ($result -eq $true) {
            $global:passed++
            Write-Host "[PASS] $TestName" -ForegroundColor Green
            $global:results += [PSCustomObject]@{ Test = $TestName; Status = "PASS"; Details = "Verified" }
        } else {
            $global:failed++
            Write-Host "[FAIL] $TestName (Expected: $Expected, Actual: $Actual)" -ForegroundColor Red
            $global:results += [PSCustomObject]@{ Test = $TestName; Status = "FAIL"; Details = "Failed assertion" }
        }
    } catch {
        $global:failed++
        Write-Host "[FAIL] $TestName - Exception: $($_.Exception.Message)" -ForegroundColor Red
        $global:results += [PSCustomObject]@{ Test = $TestName; Status = "FAIL"; Details = $_.Exception.Message }
    }
}

# ----------------------------------------------------
# 1. StudentBusinessLayer Tests
# ----------------------------------------------------
Write-Host "`n--- 1. Testing StudentBusinessLayer ---" -ForegroundColor Cyan
$studentBL = New-Object StudentManagementSystem.Models.StudentBusinessLayer

Assert-Test -TestName "StudentBL_GetById_2_Returns_James" -Condition {
    $s = $studentBL.GetById(2)
    return ($s.StudentID -eq 2 -and $s.Name -eq "James" -and $s.Branch -eq "CSE" -and $s.Section -eq "A2")
}

Assert-Test -TestName "StudentBL_GetById_1_Returns_Rahul" -Condition {
    $s = $studentBL.GetById(1)
    return ($s.StudentID -eq 1 -and $s.Name -eq "Rahul Sharma" -and $s.Gender -eq "Male")
}

Assert-Test -TestName "StudentBL_GetById_NonExistent_Returns_Fallback" -Condition {
    $s = $studentBL.GetById(999)
    return ($s.StudentID -eq 999 -and $s.Name -eq "James")
}

Assert-Test -TestName "StudentBL_GetAllStudents_Returns_AtLeast_4_Records" -Condition {
    $all = $studentBL.GetAllStudents()
    return ($all.Count -ge 4)
}

# ----------------------------------------------------
# 2. ProjectDataAccess ADO.NET Tests (ProjectManagementDB)
# ----------------------------------------------------
Write-Host "`n--- 2. Testing ProjectDataAccess (ADO.NET on SQL Server) ---" -ForegroundColor Cyan

$connString = "Data Source=(localdb)\MSSQLLocalDB;Initial Catalog=ProjectManagementDB;Integrated Security=True;"
$projectDA = New-Object StudentManagementSystem.Models.ProjectDataAccess($connString)

Assert-Test -TestName "ProjectDA_GetAllProjects_Returns_Initial_Seed" -Condition {
    $projects = $projectDA.GetAllProjects($null, $null)
    return ($projects.Count -ge 5)
}

Assert-Test -TestName "ProjectDA_GetMetrics_Returns_Valid_Sums" -Condition {
    $metrics = $projectDA.GetProjectMetrics()
    return ($metrics.TotalProjects -ge 5 -and $metrics.TotalBudget -gt 0 -and $metrics.AverageBudget -gt 0)
}

# Test Insert -> Read -> Update -> Delete Lifecycle
$testProj = New-Object StudentManagementSystem.Models.Project
$testProj.Title = "Rigorous Automated Test Project"
$testProj.Description = "End-to-end integration test record"
$testProj.Category = "Cloud Platform"
$testProj.LeadStudent = "Deepak Sen"
$testProj.Status = "Planning"
$testProj.Priority = "High"
$testProj.Budget = 88500.00
$testProj.StartDate = [DateTime]::Today

$createdId = $projectDA.InsertProject($testProj)

Assert-Test -TestName "ProjectDA_InsertProject_Generates_Positive_ID" -Condition {
    return ($createdId -gt 0)
}

Assert-Test -TestName "ProjectDA_GetProjectById_Returns_Inserted_Data" -Condition {
    $retrieved = $projectDA.GetProjectById($createdId)
    return ($retrieved.Title -eq "Rigorous Automated Test Project" -and $retrieved.LeadStudent -eq "Deepak Sen" -and $retrieved.Budget -eq 88500.00)
}

# Update test
$testProj.ProjectID = $createdId
$testProj.Title = "Rigorous Automated Test Project (Updated)"
$testProj.Status = "In Progress"
$testProj.Budget = 92000.00
$updated = $projectDA.UpdateProject($testProj)

Assert-Test -TestName "ProjectDA_UpdateProject_Modifies_Data" -Condition {
    if (-not $updated) { return $false }
    $after = $projectDA.GetProjectById($createdId)
    return ($after.Title -eq "Rigorous Automated Test Project (Updated)" -and $after.Status -eq "In Progress" -and $after.Budget -eq 92000.00)
}

# Search & Filter tests
Assert-Test -TestName "ProjectDA_GetAllProjects_Filters_By_Search" -Condition {
    $matched = $projectDA.GetAllProjects("Rigorous", $null)
    return ($matched.Count -eq 1 -and $matched[0].ProjectID -eq $createdId)
}

Assert-Test -TestName "ProjectDA_GetAllProjects_Filters_By_Status" -Condition {
    $matched = $projectDA.GetAllProjects($null, "Completed")
    return ($matched.Count -ge 1 -and ($matched | Where-Object { $_.Status -ne "Completed" }).Count -eq 0)
}

# Delete test
$deleted = $projectDA.DeleteProject($createdId)

Assert-Test -TestName "ProjectDA_DeleteProject_Removes_Record" -Condition {
    if (-not $deleted) { return $false }
    $check = $projectDA.GetProjectById($createdId)
    return ($check -eq $null)
}

# ----------------------------------------------------
# 3. Model Validation Tests
# ----------------------------------------------------
Write-Host "`n--- 3. Testing Model Validation Attributes ---" -ForegroundColor Cyan

Assert-Test -TestName "ModelValidation_Valid_Project_Passes" -Condition {
    $p = New-Object StudentManagementSystem.Models.Project
    $p.Title = "Valid Title"
    $p.Category = "Web App"
    $p.LeadStudent = "Amit Kumar"
    $p.Status = "Planning"
    $p.Priority = "Low"
    $p.Budget = 50000.00
    $p.StartDate = [DateTime]::Today

    $context = New-Object System.ComponentModel.DataAnnotations.ValidationContext($p)
    $validationResults = New-Object System.Collections.Generic.List[System.ComponentModel.DataAnnotations.ValidationResult]
    $isValid = [System.ComponentModel.DataAnnotations.Validator]::TryValidateObject($p, $context, $validationResults, $true)
    return ($isValid -eq $true)
}

Assert-Test -TestName "ModelValidation_Missing_Title_Fails" -Condition {
    $p = New-Object StudentManagementSystem.Models.Project
    $p.Title = $null
    $p.Category = "Web App"
    $p.LeadStudent = "Amit Kumar"
    $p.Status = "Planning"
    $p.Priority = "Low"
    $p.Budget = 50000.00
    $p.StartDate = [DateTime]::Today

    $context = New-Object System.ComponentModel.DataAnnotations.ValidationContext($p)
    $validationResults = New-Object System.Collections.Generic.List[System.ComponentModel.DataAnnotations.ValidationResult]
    $isValid = [System.ComponentModel.DataAnnotations.Validator]::TryValidateObject($p, $context, $validationResults, $true)
    return ($isValid -eq $false -and ($validationResults | Where-Object { $_.MemberNames -contains "Title" }).Count -gt 0)
}

Assert-Test -TestName "ModelValidation_Negative_Budget_Fails" -Condition {
    $p = New-Object StudentManagementSystem.Models.Project
    $p.Title = "Negative Budget Test"
    $p.Category = "Web App"
    $p.LeadStudent = "Amit Kumar"
    $p.Status = "Planning"
    $p.Priority = "Low"
    $p.Budget = -500.00
    $p.StartDate = [DateTime]::Today

    $context = New-Object System.ComponentModel.DataAnnotations.ValidationContext($p)
    $validationResults = New-Object System.Collections.Generic.List[System.ComponentModel.DataAnnotations.ValidationResult]
    $isValid = [System.ComponentModel.DataAnnotations.Validator]::TryValidateObject($p, $context, $validationResults, $true)
    return ($isValid -eq $false)
}

# ----------------------------------------------------
# Summary
# ----------------------------------------------------
Write-Host "`n=========================================================="
Write-Host "TEST EXECUTION SUMMARY: Total: $($passed + $failed) | Passed: $passed | Failed: $failed"
Write-Host "=========================================================="

if ($failed -gt 0) {
    exit 1
} else {
    exit 0
}
