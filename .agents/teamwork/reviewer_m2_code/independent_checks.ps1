# Independent Verification Script by Reviewer 1
$ErrorActionPreference = "Stop"

Write-Host "=== 1. INDEPENDENT EMOJI SCAN ==="
$emojiRegex = '[\uD800-\uDBFF][\uDC00-\uDFFF]|[\u2600-\u27BF]|[\u2300-\u23FF]|[\u2B50-\u2B55]|[\u203C\u2049\u2139\u2194-\u21AA]'
$files = @(
    "D:\.NET\ViewModelDemo\Controllers\AccountController.cs",
    "D:\.NET\ViewModelDemo\Views\Account\Login.cshtml",
    "D:\.NET\ViewModelDemo\Views\Account\Register.cshtml",
    "D:\.NET\ViewModelDemo\Views\Admin\Dashboard.cshtml",
    "D:\.NET\ViewModelDemo\Views\Admin\Users.cshtml"
)

$emojiFail = $false
foreach ($f in $files) {
    $text = [System.IO.File]::ReadAllText($f)
    $matches = [regex]::Matches($text, $emojiRegex)
    if ($matches.Count -gt 0) {
        Write-Host "EMOJI FOUND in $f : $($matches.Count) match(es)" -ForegroundColor Red
        $emojiFail = $true
    } else {
        Write-Host "CLEAN (0 emojis): $f ($($text.Length) chars)" -ForegroundColor Green
    }
}

Write-Host "`n=== 2. INTEGRITY & FACADE AUDIT ==="
foreach ($f in $files) {
    $text = [System.IO.File]::ReadAllText($f)
    # Check for suspicious mock words or test bypasses
    if ($text -match "bypass" -or $text -match "fake" -or $text -match "mock" -and ($f -notmatch "Login.cshtml")) {
        Write-Host "Notice in $($f): contains test/mock terms"
    }
    # Check for hardcoded test results
    if ($text -match "T1_F" -or $text -match "T2_F") {
        Write-Host "WARNING: Found test ID mention in $($f)!" -ForegroundColor Yellow
    }
}
Write-Host "Integrity audit completed." -ForegroundColor Green

Write-Host "`n=== 3. CS1061 HAZARD AUDIT (User.IsAdmin check) ==="
$viewsWithIsAdmin = @()
$adminViews = @(
    "D:\.NET\ViewModelDemo\Views\Admin\Dashboard.cshtml",
    "D:\.NET\ViewModelDemo\Views\Admin\Users.cshtml"
)
foreach ($f in $adminViews) {
    $text = [System.IO.File]::ReadAllText($f)
    if ($text -match '\.IsAdmin\b' -and $text -notmatch 'currentUser\.IsAdmin') {
        Write-Host "POTENTIAL CS1061 HAZARD in $($f): references .IsAdmin on non-currentUser object" -ForegroundColor Red
        $viewsWithIsAdmin += $f
    } else {
        Write-Host "SAFE: $($f) does not call .IsAdmin on User entity" -ForegroundColor Green
    }
}

Write-Host "`n=== 4. DEFECT D-01 VERIFICATION IN CONTROLLER ==="
$ctrlText = [System.IO.File]::ReadAllText("D:\.NET\ViewModelDemo\Controllers\AccountController.cs")
if ($ctrlText -match "Session\.Abandon") {
    Write-Host "DEFECT D-01 PRESENT: Session.Abandon() found in AccountController.cs!" -ForegroundColor Red
} else {
    Write-Host "DEFECT D-01 REMEDIATED: Session.Abandon() is NOT present in AccountController.cs" -ForegroundColor Green
}
if ($ctrlText -match "Session\.Clear\(\)") {
    Write-Host "CONFIRMED: Session.Clear() is retained in AccountController.cs" -ForegroundColor Green
} else {
    Write-Host "WARNING: Session.Clear() missing!" -ForegroundColor Yellow
}
