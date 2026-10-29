# Verification script for Milestone 1 Reviewer
$ErrorActionPreference = 'Stop'

Write-Host "=== 1. Checking site.css ==="
$cssResp = Invoke-WebRequest -Uri 'http://localhost:9979/Content/site.css' -UseBasicParsing
Write-Host "Status: $($cssResp.StatusCode)"
Write-Host "Content-Type: $($cssResp.Headers['Content-Type'])"
Write-Host "Content-Length: $($cssResp.Content.Length)"

$cssTokens = @(
    '--canvas-bg',
    '--surface-card',
    '--border-color',
    '--text-primary',
    '--text-secondary',
    '--accent-dark',
    '--nav-height',
    '.notion-main',
    '.notion-content',
    '.notion-alerts-container',
    '.nav-drawer',
    '.nav-mobile-toggle',
    '.notion-modal-overlay',
    'prefers-reduced-motion'
)

foreach ($t in $cssTokens) {
    $present = $cssResp.Content.Contains($t)
    Write-Host "  CSS Token '$t': $present"
    if (-not $present) { throw "Missing CSS token: $t" }
}

Write-Host "`n=== 2. Checking app.js ==="
$jsResp = Invoke-WebRequest -Uri 'http://localhost:9979/Scripts/app.js' -UseBasicParsing
Write-Host "Status: $($jsResp.StatusCode)"
Write-Host "Content-Type: $($jsResp.Headers['Content-Type'])"
Write-Host "Content-Length: $($jsResp.Content.Length)"

$jsTokens = @(
    'initMobileNav',
    'initAlertDismiss',
    'initModals',
    'initFormState',
    'ViewModelDemoModal',
    'mobileNavToggle',
    'mobileNavDrawer',
    'mobileNavOverlay'
)

foreach ($j in $jsTokens) {
    $present = $jsResp.Content.Contains($j)
    Write-Host "  JS Token '$j': $present"
    if (-not $present) { throw "Missing JS token: $j" }
}

Write-Host "`n=== 3. Checking Employee/Index ==="
$empResp = Invoke-WebRequest -Uri 'http://localhost:9979/Employee/Index' -UseBasicParsing
Write-Host "Status: $($empResp.StatusCode)"
Write-Host "Content-Type: $($empResp.Headers['Content-Type'])"
$empContent = $empResp.Content

$empChecks = @(
    '<!DOCTYPE html>',
    '<meta name="viewport" content="width=device-width, initial-scale=1.0" />',
    '<link rel="stylesheet" href="/Content/site.css" />',
    '<header class="top-nav">',
    'id="mobileNavToggle"',
    'id="mobileNavDrawer"',
    'id="mobileNavOverlay"',
    '<main class="notion-main">',
    '<div class="notion-content">',
    '<footer class="notion-footer">',
    '<script src="/Scripts/app.js"></script>'
)

foreach ($c in $empChecks) {
    $present = $empContent.Contains($c)
    Write-Host "  Employee/Index contains '$c': $present"
    if (-not $present) { throw "Missing markup in Employee/Index: $c" }
}

Write-Host "`n=== 4. Checking Account/Login ==="
$loginResp = Invoke-WebRequest -Uri 'http://localhost:9979/Account/Login' -UseBasicParsing
Write-Host "Status: $($loginResp.StatusCode)"
Write-Host "Content-Type: $($loginResp.Headers['Content-Type'])"
$loginContent = $loginResp.Content

$loginChecks = @(
    '<a href="/Account/Login" class="btn btn-secondary btn-sm">Login</a>',
    '<a href="/Account/Register" class="btn btn-primary btn-sm">Register</a>',
    'Session: Guest',
    '<form action="/Account/Login" method="post">'
)

foreach ($l in $loginChecks) {
    $present = $loginContent.Contains($l)
    Write-Host "  Account/Login contains '$l': $present"
    if (-not $present) { throw "Missing markup in Account/Login: $l" }
}

Write-Host "`n=== All Live Runtime Serving Checks PASSED ==="
