. "D:\.NET\ViewModelDemo\Tests\E2E\TestHarness.ps1"

$sess = New-E2ESession
Write-Output "Logging in as admin..."
$loginRes = Invoke-E2ELogin -Session $sess -UsernameOrEmail "admin" -Password "Admin@123"
Write-Output ("Login status: " + $loginRes.StatusCode + ", Location: " + $loginRes.Location)

Write-Output "Logging out..."
$logoutRes = Invoke-E2ELogout -Session $sess
Write-Output ("Logout status: " + $logoutRes.StatusCode + ", Location: " + $logoutRes.Location)

Write-Output "Following redirect to Login..."
$loginPage = Invoke-E2EGet -Session $sess -Path "/Account/Login" -FollowRedirects $false
Write-Output ("Login page status: " + $loginPage.StatusCode)
$hasAlert = $loginPage.Content -match 'alert-info'
$hasMsg = $loginPage.Content -match 'You have been logged out safely'
Write-Output ("Has alert-info in HTML: " + $hasAlert)
Write-Output ("Has 'You have been logged out safely' in HTML: " + $hasMsg)

if (-not $hasMsg) {
    Write-Output "CONFIRMED: Defect D-01 is present! TempData['InfoMessage'] was lost due to Session.Abandon()."
} else {
    Write-Output "TempData['InfoMessage'] rendered successfully."
}
