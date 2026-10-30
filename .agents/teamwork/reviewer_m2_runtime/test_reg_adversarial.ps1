# Registration Adversarial & Persistence Tests
$ErrorActionPreference = "Stop"
. "D:\.NET\ViewModelDemo\Tests\E2E\TestHarness.ps1"

Write-Host "--- TEST REGISTRATION ADVERSARIAL ---"

# 1. Mismatched passwords
$sess1 = New-E2ESession
$regPage1 = Invoke-E2EGet -Session $sess1 -Path "/Account/Register" -FollowRedirects $true
$token1 = Get-VerificationToken -Html $regPage1.Content
$bodyMismatch = @{
    "__RequestVerificationToken" = $token1
    "FullName" = "Test User"
    "Username" = "testuser_mismatch"
    "Email" = "testuser_mismatch@example.com"
    "Password" = "Password123"
    "ConfirmPassword" = "MismatchPassword456"
}
$resMismatch = Invoke-E2EPost -Session $sess1 -Path "/Account/Register" -FormData $bodyMismatch -AutoToken $false -FollowRedirects $false
Write-Host "Password mismatch status: $($resMismatch.StatusCode)"
$hasMismatchErr = ($resMismatch.Content -match "match" -or $resMismatch.Content -match "ConfirmPassword")
Write-Host "Password mismatch error present: $hasMismatchErr"

# 2. Duplicate Username (attempt registering existing user 'admin')
$sess2 = New-E2ESession
$regPage2 = Invoke-E2EGet -Session $sess2 -Path "/Account/Register" -FollowRedirects $true
$token2 = Get-VerificationToken -Html $regPage2.Content
$bodyDup = @{
    "__RequestVerificationToken" = $token2
    "FullName" = "Duplicate Admin"
    "Username" = "admin"
    "Email" = "unique_admin_email@example.com"
    "Password" = "Password123"
    "ConfirmPassword" = "Password123"
}
$resDup = Invoke-E2EPost -Session $sess2 -Path "/Account/Register" -FormData $bodyDup -AutoToken $false -FollowRedirects $false
Write-Host "Duplicate username status: $($resDup.StatusCode)"
$hasDupErr = ($resDup.Content -match "already taken" -or $resDup.Content -match "already exists" -or $resDup.Content -match "Username")
Write-Host "Duplicate error present: $hasDupErr"

Write-Host "--- REGISTRATION ADVERSARIAL COMPLETED ---"
