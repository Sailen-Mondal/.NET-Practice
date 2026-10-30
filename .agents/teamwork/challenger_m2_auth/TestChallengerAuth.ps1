# ==============================================================================
# TestChallengerAuth.ps1
# Adversarial Challenge & Stress Harness for Milestone 2 Account & Security
# Scope: Login, Register, Logout, Anti-Forgery, Open Redirect, Session, D-01
# STRICT ZERO EMOJIS - Clean Minimalist Terminal Formatting
# ==============================================================================

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$script:BaseUrl = "http://localhost:9979"
$script:Results = [System.Collections.Generic.List[PSCustomObject]]::new()

function Record-Assertion {
    param(
        [string]$Id,
        [string]$Category,
        [string]$Name,
        [bool]$Passed,
        [string]$Details
    )
    $record = [PSCustomObject]@{
        Id       = $Id
        Category = $Category
        Name     = $Name
        Passed   = $Passed
        Details  = $Details
    }
    $script:Results.Add($record)

    $status = if ($Passed) { "[PASS]" } else { "[FAIL]" }
    $color = if ($Passed) { "Green" } else { "Red" }
    Write-Host "$status $Id :: $Category - $Name" -ForegroundColor $color
    if (-not [string]::IsNullOrEmpty($Details)) {
        Write-Host "       $Details" -ForegroundColor DarkGray
    }
}

function Extract-VerificationToken {
    param([string]$Html)
    if ([string]::IsNullOrEmpty($Html)) { return $null }

    if ($Html -match '__RequestVerificationToken"[^>]*value="([^"]+)"') {
        return $matches[1]
    }
    if ($Html -match 'value="([^"]+)"[^>]*__RequestVerificationToken"') {
        return $matches[1]
    }
    return $null
}

function Invoke-ChallengerGet {
    param(
        [Microsoft.PowerShell.Commands.WebRequestSession]$Session,
        [string]$Path,
        [bool]$FollowRedirects = $false
    )

    $targetUrl = if ($Path.StartsWith("http")) { $Path } else { "$script:BaseUrl$Path" }
    $maxRedir = if ($FollowRedirects) { 10 } else { 0 }

    try {
        $resp = Invoke-WebRequest -Uri $targetUrl `
                                  -WebSession $Session `
                                  -UseBasicParsing `
                                  -MaximumRedirection $maxRedir `
                                  -ErrorAction SilentlyContinue

        $loc = $null
        if ($resp -and $resp.Headers) {
            try { $loc = $resp.Headers["Location"] } catch { $loc = $null }
        }

        return [PSCustomObject]@{
            StatusCode = if ($resp) { [int]$resp.StatusCode } else { 0 }
            Content    = if ($resp) { [string]$resp.Content } else { "" }
            Headers    = if ($resp) { $resp.Headers } else { @{} }
            Location   = $loc
        }
    } catch [System.Net.WebException] {
        $webEx = $_.Exception
        $webResp = $webEx.Response
        $status = 0
        $loc = $null
        $content = ""
        if ($webResp -ne $null) {
            $status = [int]$webResp.StatusCode
            if ($webResp.Headers -ne $null) {
                try { $loc = $webResp.Headers["Location"] } catch { $loc = $null }
            }
            try {
                $stream = $webResp.GetResponseStream()
                if ($stream -ne $null) {
                    $reader = New-Object System.IO.StreamReader($stream)
                    $content = $reader.ReadToEnd()
                    $reader.Close()
                }
            } catch {
                # Stream read fallback
            }
        }
        return [PSCustomObject]@{
            StatusCode = $status
            Content    = $content
            Headers    = if ($webResp) { $webResp.Headers } else { @{} }
            Location   = $loc
        }
    } catch {
        return [PSCustomObject]@{
            StatusCode = 500
            Content    = $_.Exception.Message
            Headers    = @{}
            Location   = $null
        }
    }
}

function Invoke-ChallengerPost {
    param(
        [Microsoft.PowerShell.Commands.WebRequestSession]$Session,
        [string]$Path,
        [hashtable]$FormData,
        [bool]$FollowRedirects = $false
    )

    $targetUrl = if ($Path.StartsWith("http")) { $Path } else { "$script:BaseUrl$Path" }
    $maxRedir = if ($FollowRedirects) { 10 } else { 0 }

    try {
        $resp = Invoke-WebRequest -Uri $targetUrl `
                                  -Method Post `
                                  -Body $FormData `
                                  -WebSession $Session `
                                  -UseBasicParsing `
                                  -MaximumRedirection $maxRedir `
                                  -ErrorAction SilentlyContinue

        $loc = $null
        if ($resp -and $resp.Headers) {
            try { $loc = $resp.Headers["Location"] } catch { $loc = $null }
        }

        return [PSCustomObject]@{
            StatusCode = if ($resp) { [int]$resp.StatusCode } else { 0 }
            Content    = if ($resp) { [string]$resp.Content } else { "" }
            Headers    = if ($resp) { $resp.Headers } else { @{} }
            Location   = $loc
        }
    } catch [System.Net.WebException] {
        $webEx = $_.Exception
        $webResp = $webEx.Response
        $status = 0
        $loc = $null
        $content = ""
        if ($webResp -ne $null) {
            $status = [int]$webResp.StatusCode
            if ($webResp.Headers -ne $null) {
                try { $loc = $webResp.Headers["Location"] } catch { $loc = $null }
            }
            try {
                $stream = $webResp.GetResponseStream()
                if ($stream -ne $null) {
                    $reader = New-Object System.IO.StreamReader($stream)
                    $content = $reader.ReadToEnd()
                    $reader.Close()
                }
            } catch {
                # Stream read fallback
            }
        }
        return [PSCustomObject]@{
            StatusCode = $status
            Content    = $content
            Headers    = if ($webResp) { $webResp.Headers } else { @{} }
            Location   = $loc
        }
    } catch {
        return [PSCustomObject]@{
            StatusCode = 500
            Content    = $_.Exception.Message
            Headers    = @{}
            Location   = $null
        }
    }
}

function Test-ContainsEmojis {
    param([string]$Text)
    if ([string]::IsNullOrEmpty($Text)) { return $false }
    for ($i = 0; $i -lt $Text.Length; $i++) {
        $cp = [char]::ConvertToUtf32($Text, $i)
        if ([char]::IsSurrogatePair($Text, $i)) { $i++ }
        if (($cp -ge 0x1F600 -and $cp -le 0x1F64F) -or
            ($cp -ge 0x1F300 -and $cp -le 0x1F5FF) -or
            ($cp -ge 0x1F680 -and $cp -le 0x1F6FF) -or
            ($cp -ge 0x1F700 -and $cp -le 0x1F77F) -or
            ($cp -ge 0x1F780 -and $cp -le 0x1F7FF) -or
            ($cp -ge 0x1F800 -and $cp -le 0x1F8FF) -or
            ($cp -ge 0x1F900 -and $cp -le 0x1F9FF) -or
            ($cp -ge 0x1FA00 -and $cp -le 0x1FA6F) -or
            ($cp -ge 0x1FA70 -and $cp -le 0x1FAFF) -or
            ($cp -ge 0x2600 -and $cp -le 0x26FF) -or
            ($cp -ge 0x2700 -and $cp -le 0x27BF)) {
            return $true
        }
    }
    return $false
}

Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host "CHALLENGER 1: ACCOUNT & SECURITY ADVERSARIAL STRESS TEST SUITE" -ForegroundColor Cyan
Write-Host "Target: $script:BaseUrl | Scope: Login, Register, Logout, D-01, Anti-Forgery" -ForegroundColor Cyan
Write-Host "==============================================================================" -ForegroundColor Cyan

# ==============================================================================
# SECTION 1: BASELINE & ZERO EMOJIS AUDIT
# ==============================================================================
Write-Host "`n--- Section 1: Baseline & Zero-Emoji Conformance ---" -ForegroundColor Yellow

$sess = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$loginGet = Invoke-ChallengerGet -Session $sess -Path "/Account/Login" -FollowRedirects $false

Record-Assertion "SEC1-01" "Baseline" "Login Endpoint Returns 200" `
    ($loginGet.StatusCode -eq 200) `
    "Status: $($loginGet.StatusCode), ContentLength: $($loginGet.Content.Length)"

$loginHasEmoji = Test-ContainsEmojis $loginGet.Content
Record-Assertion "SEC1-02" "Visual" "Login Rendered HTML Zero Emojis" `
    (-not $loginHasEmoji) `
    "Scanned $($loginGet.Content.Length) characters. Contains emojis: $loginHasEmoji"

$regGet = Invoke-ChallengerGet -Session $sess -Path "/Account/Register" -FollowRedirects $false
Record-Assertion "SEC1-03" "Baseline" "Register Endpoint Returns 200" `
    ($regGet.StatusCode -eq 200) `
    "Status: $($regGet.StatusCode), ContentLength: $($regGet.Content.Length)"

$regHasEmoji = Test-ContainsEmojis $regGet.Content
Record-Assertion "SEC1-04" "Visual" "Register Rendered HTML Zero Emojis" `
    (-not $regHasEmoji) `
    "Scanned $($regGet.Content.Length) characters. Contains emojis: $regHasEmoji"

# ==============================================================================
# SECTION 2: UI ELEMENTS & DESIGN SYSTEM CONFORMANCE
# ==============================================================================
Write-Host "`n--- Section 2: UI Elements & Design System Conformance ---" -ForegroundColor Yellow

$hasLoginCard = $loginGet.Content -match 'card\s+notion-card'
$hasLoginTitle = $loginGet.Content -match 'Sign in to your account'
$hasLoginSubtitle = $loginGet.Content -match 'Enter your credentials to access your workspace'
Record-Assertion "SEC2-01" "UI" "Login Card Container and Headings" `
    ($hasLoginCard -and $hasLoginTitle -and $hasLoginSubtitle) `
    "Card: $hasLoginCard, Title: $hasLoginTitle, Subtitle: $hasLoginSubtitle"

$hasUserInput = $loginGet.Content -match 'name="UsernameOrEmail"' -and $loginGet.Content -match 'notion-form-input'
$hasPassInput = $loginGet.Content -match 'name="Password"' -and $loginGet.Content -match 'notion-form-input'
$hasLabels = $loginGet.Content -match 'class="form-label"'
$hasReqStars = $loginGet.Content -match 'class="required-indicator"'
Record-Assertion "SEC2-02" "UI" "Login Form Inputs and Accessible Labels" `
    ($hasUserInput -and $hasPassInput -and $hasLabels -and $hasReqStars) `
    "UserInput: $hasUserInput, PassInput: $hasPassInput, Labels: $hasLabels, RequiredStars: $hasReqStars"

$hasDemoAccounts = $loginGet.Content -match 'Pre-Configured Test Accounts'
$hasQuickFill = $loginGet.Content -match 'quickFill\('
$hasAdminBadge = $loginGet.Content -match 'badge-admin'
$hasUserBadge = $loginGet.Content -match 'badge-user'
Record-Assertion "SEC2-03" "UI" "Login Pre-Configured Test Accounts Callout" `
    ($hasDemoAccounts -and $hasQuickFill -and $hasAdminBadge -and $hasUserBadge) `
    "DemoCard: $hasDemoAccounts, quickFill: $hasQuickFill, AdminBadge: $hasAdminBadge, UserBadge: $hasUserBadge"

$cssGet = Invoke-ChallengerGet -Session $sess -Path "/Content/site.css" -FollowRedirects $false
$hasFocusStyles = ($cssGet.Content -match ':focus-visible' -or $cssGet.Content -match '\.notion-form-input:focus')
Record-Assertion "SEC2-04" "UI" "Focus and Focus-Visible Ring Styles in site.css" `
    ($cssGet.StatusCode -eq 200 -and $hasFocusStyles) `
    "site.css Status: $($cssGet.StatusCode), Focus ring defined: $hasFocusStyles"

$hasRegCard = $regGet.Content -match 'card\s+notion-card'
$hasRegTitle = $regGet.Content -match 'Create a New Account'
$hasRegHint = $regGet.Content -match '3-50 characters: letters, numbers, and underscores only'
$hasIndianPlaceholder = $regGet.Content -match 'Sneha Roy'
Record-Assertion "SEC2-05" "UI" "Register Card, Hint, and Indian Context" `
    ($hasRegCard -and $hasRegTitle -and $hasRegHint -and $hasIndianPlaceholder) `
    "Card: $hasRegCard, Title: $hasRegTitle, RegexHint: $hasRegHint, IndianContext: $hasIndianPlaceholder"

# ==============================================================================
# SECTION 3: ANTI-FORGERY TOKEN SECURITY CHALLENGE
# ==============================================================================
Write-Host "`n--- Section 3: Anti-Forgery Token Validation ---" -ForegroundColor Yellow

# Test A: Login POST without Anti-Forgery Token
$afSess1 = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$null = Invoke-ChallengerGet -Session $afSess1 -Path "/Account/Login"
$postNoToken = Invoke-ChallengerPost -Session $afSess1 -Path "/Account/Login" -FormData @{
    "UsernameOrEmail" = "admin"
    "Password"        = "Admin@123"
}
Record-Assertion "SEC3-01" "Security" "Login Rejects Missing Anti-Forgery Token" `
    ($postNoToken.StatusCode -eq 500) `
    "Expected HTTP 500 (HttpAntiForgeryException), Received: $($postNoToken.StatusCode)"

# Test B: Login POST with Forged/Mismatched Anti-Forgery Token
$afSess2 = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$null = Invoke-ChallengerGet -Session $afSess2 -Path "/Account/Login"
$postForgedToken = Invoke-ChallengerPost -Session $afSess2 -Path "/Account/Login" -FormData @{
    "__RequestVerificationToken" = "FORGED_TAMPERED_TOKEN_VALUE_XYZ"
    "UsernameOrEmail"            = "admin"
    "Password"                   = "Admin@123"
}
Record-Assertion "SEC3-02" "Security" "Login Rejects Forged Anti-Forgery Token" `
    ($postForgedToken.StatusCode -eq 500) `
    "Expected HTTP 500 (HttpAntiForgeryException), Received: $($postForgedToken.StatusCode)"

# Test C: Register POST without Anti-Forgery Token
$afSess3 = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$null = Invoke-ChallengerGet -Session $afSess3 -Path "/Account/Register"
$postRegNoToken = Invoke-ChallengerPost -Session $afSess3 -Path "/Account/Register" -FormData @{
    "FullName"        = "Attacker Bot"
    "Username"        = "attacker_bot"
    "Email"           = "bot@evil.com"
    "Password"        = "Pass123!"
    "ConfirmPassword" = "Pass123!"
}
Record-Assertion "SEC3-03" "Security" "Register Rejects Missing Anti-Forgery Token" `
    ($postRegNoToken.StatusCode -eq 500) `
    "Expected HTTP 500 (HttpAntiForgeryException), Received: $($postRegNoToken.StatusCode)"

# Test D: Register POST with Forged Token
$afSess4 = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$null = Invoke-ChallengerGet -Session $afSess4 -Path "/Account/Register"
$postRegForged = Invoke-ChallengerPost -Session $afSess4 -Path "/Account/Register" -FormData @{
    "__RequestVerificationToken" = "FORGED_TAMPERED_REGISTER_TOKEN"
    "FullName"                   = "Attacker Bot"
    "Username"                   = "attacker_bot"
    "Email"                      = "bot@evil.com"
    "Password"                   = "Pass123!"
    "ConfirmPassword"            = "Pass123!"
}
Record-Assertion "SEC3-04" "Security" "Register Rejects Forged Anti-Forgery Token" `
    ($postRegForged.StatusCode -eq 500) `
    "Expected HTTP 500 (HttpAntiForgeryException), Received: $($postRegForged.StatusCode)"

# ==============================================================================
# SECTION 4: LOGIN AUTHENTICATION WORKFLOWS
# ==============================================================================
Write-Host "`n--- Section 4: Login Authentication Workflows ---" -ForegroundColor Yellow

# Test A: Valid Admin Login
$loginAdminSess = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$l1 = Invoke-ChallengerGet -Session $loginAdminSess -Path "/Account/Login"
$tokenAdmin = Extract-VerificationToken $l1.Content

$postAdmin = Invoke-ChallengerPost -Session $loginAdminSess -Path "/Account/Login" -FormData @{
    "__RequestVerificationToken" = $tokenAdmin
    "UsernameOrEmail"            = "admin"
    "Password"                   = "Admin@123"
    "RememberMe"                 = "false"
} -FollowRedirects $false

$adminRedirectCorrect = ($postAdmin.StatusCode -eq 302 -and $postAdmin.Location -like "*/Admin/Dashboard*")
$dashGet = Invoke-ChallengerGet -Session $loginAdminSess -Path "/Admin/Dashboard" -FollowRedirects $false
$hasAdminRole = $dashGet.Content -match 'Session:\s*Admin\s*\(admin\)'
$hasAdminDashText = $dashGet.Content -match 'Administrator Dashboard'

Record-Assertion "SEC4-01" "Auth" "Valid Admin Login and Dashboard Redirect" `
    ($adminRedirectCorrect -and $dashGet.StatusCode -eq 200 -and $hasAdminRole -and $hasAdminDashText) `
    "PostStatus: $($postAdmin.StatusCode), Location: $($postAdmin.Location), DashStatus: $($dashGet.StatusCode), RoleSession: $hasAdminRole"

# Test B: Valid User Login
$loginUserSess = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$l2 = Invoke-ChallengerGet -Session $loginUserSess -Path "/Account/Login"
$tokenUser = Extract-VerificationToken $l2.Content

$postUser = Invoke-ChallengerPost -Session $loginUserSess -Path "/Account/Login" -FormData @{
    "__RequestVerificationToken" = $tokenUser
    "UsernameOrEmail"            = "rahul"
    "Password"                   = "User@123"
    "RememberMe"                 = "false"
} -FollowRedirects $false

$userRedirectCorrect = ($postUser.StatusCode -eq 302 -and $postUser.Location -like "*/Employee*")
$empGet = Invoke-ChallengerGet -Session $loginUserSess -Path "/Employee/Index" -FollowRedirects $false
$hasUserRole = $empGet.Content -match 'Session:\s*User\s*\(rahul\)'
$hasUserPill = $empGet.Content -match 'Rahul Sharma' -and $empGet.Content -match 'badge-user'

Record-Assertion "SEC4-02" "Auth" "Valid Standard User Login and Employee Redirect" `
    ($userRedirectCorrect -and $empGet.StatusCode -eq 200 -and $hasUserRole -and $hasUserPill) `
    "PostStatus: $($postUser.StatusCode), Location: $($postUser.Location), RoleSession: $hasUserRole, UserPill: $hasUserPill"

# Test C: Invalid Password
$badPassSess = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$l3 = Invoke-ChallengerGet -Session $badPassSess -Path "/Account/Login"
$token3 = Extract-VerificationToken $l3.Content

$postBadPass = Invoke-ChallengerPost -Session $badPassSess -Path "/Account/Login" -FormData @{
    "__RequestVerificationToken" = $token3
    "UsernameOrEmail"            = "admin"
    "Password"                   = "WrongPasswordXYZ!"
} -FollowRedirects $false

$hasInvalidCredMsg1 = $postBadPass.Content -match 'Invalid username/email or password\.'
$isStillGuest1 = $postBadPass.Content -match 'Session:\s*Guest'
Record-Assertion "SEC4-03" "Auth" "Invalid Password Rejected with Error Message" `
    ($postBadPass.StatusCode -eq 200 -and $hasInvalidCredMsg1 -and $isStillGuest1) `
    "Status: $($postBadPass.StatusCode), ErrorMsgPresent: $hasInvalidCredMsg1, SessionIsGuest: $isStillGuest1"

# Test D: Non-existent User
$nonUserSess = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$l4 = Invoke-ChallengerGet -Session $nonUserSess -Path "/Account/Login"
$token4 = Extract-VerificationToken $l4.Content

$postNonUser = Invoke-ChallengerPost -Session $nonUserSess -Path "/Account/Login" -FormData @{
    "__RequestVerificationToken" = $token4
    "UsernameOrEmail"            = "ghost_user_does_not_exist"
    "Password"                   = "AnyPass@123"
} -FollowRedirects $false

$hasInvalidCredMsg2 = $postNonUser.Content -match 'Invalid username/email or password\.'
Record-Assertion "SEC4-04" "Auth" "Non-Existent User Rejected with Error Message" `
    ($postNonUser.StatusCode -eq 200 -and $hasInvalidCredMsg2) `
    "Status: $($postNonUser.StatusCode), ErrorMsgPresent: $hasInvalidCredMsg2"

# Test E: Empty Username
$emptyUserSess = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$l5 = Invoke-ChallengerGet -Session $emptyUserSess -Path "/Account/Login"
$token5 = Extract-VerificationToken $l5.Content

$postEmptyUser = Invoke-ChallengerPost -Session $emptyUserSess -Path "/Account/Login" -FormData @{
    "__RequestVerificationToken" = $token5
    "UsernameOrEmail"            = ""
    "Password"                   = "SomePassword123!"
} -FollowRedirects $false

$hasUserReqMsg = $postEmptyUser.Content -match 'Username or Email is required'
Record-Assertion "SEC4-05" "Auth" "Empty Username Rejected by Model Validation" `
    ($postEmptyUser.StatusCode -eq 200 -and $hasUserReqMsg) `
    "Status: $($postEmptyUser.StatusCode), ValidationMsgPresent: $hasUserReqMsg"

# Test F: Empty Password
$emptyPassSess = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$l6 = Invoke-ChallengerGet -Session $emptyPassSess -Path "/Account/Login"
$token6 = Extract-VerificationToken $l6.Content

$postEmptyPass = Invoke-ChallengerPost -Session $emptyPassSess -Path "/Account/Login" -FormData @{
    "__RequestVerificationToken" = $token6
    "UsernameOrEmail"            = "admin"
    "Password"                   = ""
} -FollowRedirects $false

$hasPassReqMsg = $postEmptyPass.Content -match 'Password is required'
Record-Assertion "SEC4-06" "Auth" "Empty Password Rejected by Model Validation" `
    ($postEmptyPass.StatusCode -eq 200 -and $hasPassReqMsg) `
    "Status: $($postEmptyPass.StatusCode), ValidationMsgPresent: $hasPassReqMsg"

# Test G: Both Username and Password Empty
$emptyBothSess = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$l7 = Invoke-ChallengerGet -Session $emptyBothSess -Path "/Account/Login"
$token7 = Extract-VerificationToken $l7.Content

$postEmptyBoth = Invoke-ChallengerPost -Session $emptyBothSess -Path "/Account/Login" -FormData @{
    "__RequestVerificationToken" = $token7
    "UsernameOrEmail"            = ""
    "Password"                   = ""
} -FollowRedirects $false

$hasBothReqMsg = ($postEmptyBoth.Content -match 'Username or Email is required') -and ($postEmptyBoth.Content -match 'Password is required')
Record-Assertion "SEC4-07" "Auth" "Both Fields Empty Shows Both Validation Errors" `
    ($postEmptyBoth.StatusCode -eq 200 -and $hasBothReqMsg) `
    "Status: $($postEmptyBoth.StatusCode), BothMsgPresent: $hasBothReqMsg"

# Test H: SQL Injection Payload in Login
$sqliSess = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$l8 = Invoke-ChallengerGet -Session $sqliSess -Path "/Account/Login"
$token8 = Extract-VerificationToken $l8.Content

$postSqli = Invoke-ChallengerPost -Session $sqliSess -Path "/Account/Login" -FormData @{
    "__RequestVerificationToken" = $token8
    "UsernameOrEmail"            = "' OR '1'='1"
    "Password"                   = "' OR '1'='1"
} -FollowRedirects $false

$sqliSafelyRejected = ($postSqli.StatusCode -eq 200 -and ($postSqli.Content -match 'Invalid username/email or password\.'))
Record-Assertion "SEC4-08" "Security" "SQL Injection Attack Safely Rejected" `
    $sqliSafelyRejected `
    "Status: $($postSqli.StatusCode), RejectedWithoutLeak: $sqliSafelyRejected"

# ==============================================================================
# SECTION 5: OPEN REDIRECT ATTACK SURFACE
# ==============================================================================
Write-Host "`n--- Section 5: Open Redirect Attack Surface ---" -ForegroundColor Yellow

# Test A: HTTP External URL (e.g. http://evil.com)
$orSess1 = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$orGet1 = Invoke-ChallengerGet -Session $orSess1 -Path "/Account/Login?returnUrl=http://evil.com"
$orTok1 = Extract-VerificationToken $orGet1.Content

$postOr1 = Invoke-ChallengerPost -Session $orSess1 -Path "/Account/Login" -FormData @{
    "__RequestVerificationToken" = $orTok1
    "UsernameOrEmail"            = "admin"
    "Password"                   = "Admin@123"
    "ReturnUrl"                  = "http://evil.com"
} -FollowRedirects $false

$or1Safe = ($postOr1.StatusCode -eq 302 -and $postOr1.Location -like "*/Admin/Dashboard*" -and $postOr1.Location -notlike "*evil.com*")
Record-Assertion "SEC5-01" "Security" "Open Redirect: http://evil.com Rejected" `
    $or1Safe `
    "PostStatus: $($postOr1.StatusCode), RedirectedTo: $($postOr1.Location)"

# Test B: HTTPS External URL (e.g. https://attacker.org/phish)
$orSess2 = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$orGet2 = Invoke-ChallengerGet -Session $orSess2 -Path "/Account/Login?returnUrl=https://attacker.org/phish"
$orTok2 = Extract-VerificationToken $orGet2.Content

$postOr2 = Invoke-ChallengerPost -Session $orSess2 -Path "/Account/Login" -FormData @{
    "__RequestVerificationToken" = $orTok2
    "UsernameOrEmail"            = "admin"
    "Password"                   = "Admin@123"
    "ReturnUrl"                  = "https://attacker.org/phish"
} -FollowRedirects $false

$or2Safe = ($postOr2.StatusCode -eq 302 -and $postOr2.Location -like "*/Admin/Dashboard*" -and $postOr2.Location -notlike "*attacker.org*")
Record-Assertion "SEC5-02" "Security" "Open Redirect: https://attacker.org Rejected" `
    $or2Safe `
    "PostStatus: $($postOr2.StatusCode), RedirectedTo: $($postOr2.Location)"

# Test C: Protocol Relative URL (//evil.com/phish)
$orSess3 = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$orGet3 = Invoke-ChallengerGet -Session $orSess3 -Path "/Account/Login?returnUrl=//evil.com/phish"
$orTok3 = Extract-VerificationToken $orGet3.Content

$postOr3 = Invoke-ChallengerPost -Session $orSess3 -Path "/Account/Login" -FormData @{
    "__RequestVerificationToken" = $orTok3
    "UsernameOrEmail"            = "admin"
    "Password"                   = "Admin@123"
    "ReturnUrl"                  = "//evil.com/phish"
} -FollowRedirects $false

$or3Safe = ($postOr3.StatusCode -eq 302 -and $postOr3.Location -like "*/Admin/Dashboard*" -and $postOr3.Location -notlike "*evil.com*")
Record-Assertion "SEC5-03" "Security" "Open Redirect: //evil.com/phish Rejected" `
    $or3Safe `
    "PostStatus: $($postOr3.StatusCode), RedirectedTo: $($postOr3.Location)"

# Test D: Backslash Evasion (\\evil.com\phish)
$orSess4 = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$orGet4 = Invoke-ChallengerGet -Session $orSess4 -Path "/Account/Login?returnUrl=\\evil.com\phish"
$orTok4 = Extract-VerificationToken $orGet4.Content

$postOr4 = Invoke-ChallengerPost -Session $orSess4 -Path "/Account/Login" -FormData @{
    "__RequestVerificationToken" = $orTok4
    "UsernameOrEmail"            = "admin"
    "Password"                   = "Admin@123"
    "ReturnUrl"                  = "\\evil.com\phish"
} -FollowRedirects $false

$or4Safe = ($postOr4.StatusCode -eq 302 -and $postOr4.Location -like "*/Admin/Dashboard*" -and $postOr4.Location -notlike "*evil.com*")
Record-Assertion "SEC5-04" "Security" "Open Redirect: Backslash Evasion Rejected" `
    $or4Safe `
    "PostStatus: $($postOr4.StatusCode), RedirectedTo: $($postOr4.Location)"

# Test E: Javascript Scheme (javascript:alert(1))
$orSess5 = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$orGet5 = Invoke-ChallengerGet -Session $orSess5 -Path "/Account/Login?returnUrl=javascript:alert(1)"
$orTok5 = Extract-VerificationToken $orGet5.Content

$postOr5 = Invoke-ChallengerPost -Session $orSess5 -Path "/Account/Login" -FormData @{
    "__RequestVerificationToken" = $orTok5
    "UsernameOrEmail"            = "admin"
    "Password"                   = "Admin@123"
    "ReturnUrl"                  = "javascript:alert(1)"
} -FollowRedirects $false

$or5Safe = ($postOr5.StatusCode -eq 302 -and $postOr5.Location -like "*/Admin/Dashboard*" -and $postOr5.Location -notlike "*javascript*")
Record-Assertion "SEC5-05" "Security" "Open Redirect: javascript: URI Rejected" `
    $or5Safe `
    "PostStatus: $($postOr5.StatusCode), RedirectedTo: $($postOr5.Location)"

# Test F: Valid Local URL Allowed (/Employee/Details)
$orSess6 = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$orGet6 = Invoke-ChallengerGet -Session $orSess6 -Path "/Account/Login?returnUrl=/Employee/Details"
$orTok6 = Extract-VerificationToken $orGet6.Content

$postOr6 = Invoke-ChallengerPost -Session $orSess6 -Path "/Account/Login" -FormData @{
    "__RequestVerificationToken" = $orTok6
    "UsernameOrEmail"            = "admin"
    "Password"                   = "Admin@123"
    "ReturnUrl"                  = "/Employee/Details"
} -FollowRedirects $false

$or6Allowed = ($postOr6.StatusCode -eq 302 -and $postOr6.Location -eq "/Employee/Details")
Record-Assertion "SEC5-06" "Auth" "Open Redirect: Valid Local ReturnUrl Safely Preserved" `
    $or6Allowed `
    "PostStatus: $($postOr6.StatusCode), RedirectedTo: $($postOr6.Location)"

# ==============================================================================
# SECTION 6: REGISTRATION VALIDATION & AUTO-LOGIN WORKFLOWS
# ==============================================================================
Write-Host "`n--- Section 6: Registration Validation & Auto-Login Workflows ---" -ForegroundColor Yellow

# Test A: Duplicate Username (admin)
$regDupUserSess = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$rg1 = Invoke-ChallengerGet -Session $regDupUserSess -Path "/Account/Register"
$tokReg1 = Extract-VerificationToken $rg1.Content

$postDupUser = Invoke-ChallengerPost -Session $regDupUserSess -Path "/Account/Register" -FormData @{
    "__RequestVerificationToken" = $tokReg1
    "FullName"                   = "Duplicate Admin"
    "Username"                   = "admin"
    "Email"                      = "new_unique_email_$(Get-Random)@example.com"
    "Password"                   = "Password@123"
    "ConfirmPassword"            = "Password@123"
} -FollowRedirects $false

$hasDupUserMsg = $postDupUser.Content -match 'A user with this username or email already exists\.'
Record-Assertion "SEC6-01" "Register" "Duplicate Username Rejected with Explicit Message" `
    ($postDupUser.StatusCode -eq 200 -and $hasDupUserMsg) `
    "Status: $($postDupUser.StatusCode), ErrorMsgPresent: $hasDupUserMsg"

# Test B: Duplicate Email (admin@viewmodeldemo.com)
$regDupMailSess = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$rg2 = Invoke-ChallengerGet -Session $regDupMailSess -Path "/Account/Register"
$tokReg2 = Extract-VerificationToken $rg2.Content

$postDupMail = Invoke-ChallengerPost -Session $regDupMailSess -Path "/Account/Register" -FormData @{
    "__RequestVerificationToken" = $tokReg2
    "FullName"                   = "Duplicate Email User"
    "Username"                   = "unique_user_$(Get-Random)"
    "Email"                      = "admin@viewmodeldemo.com"
    "Password"                   = "Password@123"
    "ConfirmPassword"            = "Password@123"
} -FollowRedirects $false

$hasDupMailMsg = $postDupMail.Content -match 'A user with this username or email already exists\.'
Record-Assertion "SEC6-02" "Register" "Duplicate Email Rejected with Explicit Message" `
    ($postDupMail.StatusCode -eq 200 -and $hasDupMailMsg) `
    "Status: $($postDupMail.StatusCode), ErrorMsgPresent: $hasDupMailMsg"

# Test C: Special Characters in Username: Spaces ("sneha roy")
$regSpaceSess = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$rg3 = Invoke-ChallengerGet -Session $regSpaceSess -Path "/Account/Register"
$tokReg3 = Extract-VerificationToken $rg3.Content

$postSpaceUser = Invoke-ChallengerPost -Session $regSpaceSess -Path "/Account/Register" -FormData @{
    "__RequestVerificationToken" = $tokReg3
    "FullName"                   = "Sneha Roy"
    "Username"                   = "sneha roy"
    "Email"                      = "sneha_space_$(Get-Random)@example.com"
    "Password"                   = "Password@123"
    "ConfirmPassword"            = "Password@123"
} -FollowRedirects $false

$hasRegexMsg1 = $postSpaceUser.Content -match 'Username can only contain letters, numbers, and underscores'
Record-Assertion "SEC6-03" "Register" "Username with Space Fails Regex Validation" `
    ($postSpaceUser.StatusCode -eq 200 -and $hasRegexMsg1) `
    "Status: $($postSpaceUser.StatusCode), RegexMsgPresent: $hasRegexMsg1"

# Test D: Special Characters in Username: Symbols ("sneha@roy!")
$regSymSess = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$rg4 = Invoke-ChallengerGet -Session $regSymSess -Path "/Account/Register"
$tokReg4 = Extract-VerificationToken $rg4.Content

$postSymUser = Invoke-ChallengerPost -Session $regSymSess -Path "/Account/Register" -FormData @{
    "__RequestVerificationToken" = $tokReg4
    "FullName"                   = "Sneha Roy"
    "Username"                   = "sneha@roy!"
    "Email"                      = "sneha_sym_$(Get-Random)@example.com"
    "Password"                   = "Password@123"
    "ConfirmPassword"            = "Password@123"
} -FollowRedirects $false

$hasRegexMsg2 = $postSymUser.Content -match 'Username can only contain letters, numbers, and underscores'
Record-Assertion "SEC6-04" "Register" "Username with Symbols Fails Regex Validation" `
    ($postSymUser.StatusCode -eq 200 -and $hasRegexMsg2) `
    "Status: $($postSymUser.StatusCode), RegexMsgPresent: $hasRegexMsg2"

# Test E: Special Characters in Username: Hyphen ("sneha-roy")
$regHyphenSess = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$rg5 = Invoke-ChallengerGet -Session $regHyphenSess -Path "/Account/Register"
$tokReg5 = Extract-VerificationToken $rg5.Content

$postHyphenUser = Invoke-ChallengerPost -Session $regHyphenSess -Path "/Account/Register" -FormData @{
    "__RequestVerificationToken" = $tokReg5
    "FullName"                   = "Sneha Roy"
    "Username"                   = "sneha-roy"
    "Email"                      = "sneha_hyphen_$(Get-Random)@example.com"
    "Password"                   = "Password@123"
    "ConfirmPassword"            = "Password@123"
} -FollowRedirects $false

$hasRegexMsg3 = $postHyphenUser.Content -match 'Username can only contain letters, numbers, and underscores'
Record-Assertion "SEC6-05" "Register" "Username with Hyphen Fails Regex Validation" `
    ($postHyphenUser.StatusCode -eq 200 -and $hasRegexMsg3) `
    "Status: $($postHyphenUser.StatusCode), RegexMsgPresent: $hasRegexMsg3"

# Test F: Too Short Username ("ab" < 3 chars)
$regShortUserSess = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$rg6 = Invoke-ChallengerGet -Session $regShortUserSess -Path "/Account/Register"
$tokReg6 = Extract-VerificationToken $rg6.Content

$postShortUser = Invoke-ChallengerPost -Session $regShortUserSess -Path "/Account/Register" -FormData @{
    "__RequestVerificationToken" = $tokReg6
    "FullName"                   = "Short Username"
    "Username"                   = "ab"
    "Email"                      = "ab_user_$(Get-Random)@example.com"
    "Password"                   = "Password@123"
    "ConfirmPassword"            = "Password@123"
} -FollowRedirects $false

$hasLenMsg1 = $postShortUser.Content -match 'Username must be between 3 and 50 characters'
Record-Assertion "SEC6-06" "Register" "Username Shorter Than 3 Characters Fails Validation" `
    ($postShortUser.StatusCode -eq 200 -and $hasLenMsg1) `
    "Status: $($postShortUser.StatusCode), LengthMsgPresent: $hasLenMsg1"

# Test G: Short Password (< 6 chars)
$regShortPassSess = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$rg7 = Invoke-ChallengerGet -Session $regShortPassSess -Path "/Account/Register"
$tokReg7 = Extract-VerificationToken $rg7.Content

$postShortPass = Invoke-ChallengerPost -Session $regShortPassSess -Path "/Account/Register" -FormData @{
    "__RequestVerificationToken" = $tokReg7
    "FullName"                   = "Short Password User"
    "Username"                   = "valid_user_$(Get-Random)"
    "Email"                      = "short_pass_$(Get-Random)@example.com"
    "Password"                   = "12345"
    "ConfirmPassword"            = "12345"
} -FollowRedirects $false

$hasPassLenMsg = $postShortPass.Content -match 'Password must be at least 6 characters'
Record-Assertion "SEC6-07" "Register" "Password Shorter Than 6 Characters Fails Validation" `
    ($postShortPass.StatusCode -eq 200 -and $hasPassLenMsg) `
    "Status: $($postShortPass.StatusCode), PassLenMsgPresent: $hasPassLenMsg"

# Test H: Password Mismatch
$regMismatchSess = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$rg8 = Invoke-ChallengerGet -Session $regMismatchSess -Path "/Account/Register"
$tokReg8 = Extract-VerificationToken $rg8.Content

$postMismatch = Invoke-ChallengerPost -Session $regMismatchSess -Path "/Account/Register" -FormData @{
    "__RequestVerificationToken" = $tokReg8
    "FullName"                   = "Mismatch User"
    "Username"                   = "valid_user_$(Get-Random)"
    "Email"                      = "mismatch_$(Get-Random)@example.com"
    "Password"                   = "Password@123"
    "ConfirmPassword"            = "DifferentPass@456"
} -FollowRedirects $false

$hasMismatchMsg = $postMismatch.Content -match 'Passwords do not match'
Record-Assertion "SEC6-08" "Register" "Mismatched Confirmation Password Fails Validation" `
    ($postMismatch.StatusCode -eq 200 -and $hasMismatchMsg) `
    "Status: $($postMismatch.StatusCode), MismatchMsgPresent: $hasMismatchMsg"

# Test I: Valid User Registration & Auto-Login Session Creation
$uniqueSuffix = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
$newUsername = "challenger_$uniqueSuffix"
$newEmail = "challenger_$uniqueSuffix@viewmodeldemo.com"
$newFullName = "Ananya Mukherjee"
$newPassword = "TestPassword@123"

$validRegSess = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$rg9 = Invoke-ChallengerGet -Session $validRegSess -Path "/Account/Register"
$tokReg9 = Extract-VerificationToken $rg9.Content

$postValidReg = Invoke-ChallengerPost -Session $validRegSess -Path "/Account/Register" -FormData @{
    "__RequestVerificationToken" = $tokReg9
    "FullName"                   = $newFullName
    "Username"                   = $newUsername
    "Email"                      = $newEmail
    "Password"                   = $newPassword
    "ConfirmPassword"            = $newPassword
} -FollowRedirects $false

$regRedirectOk = ($postValidReg.StatusCode -eq 302 -and $postValidReg.Location -like "*/Employee*")

# Follow redirect with the registration session to verify auto-login & TempData
$empRedirectGet = Invoke-ChallengerGet -Session $validRegSess -Path "/Employee/Index" -FollowRedirects $false
$hasRegSuccessMsg = $empRedirectGet.Content -match 'Registration successful! Welcome to ViewModel Architecture Demo\.'
$hasNewUserPill = $empRedirectGet.Content -match $newFullName -and $empRedirectGet.Content -match 'badge-user'
$hasNewUserFooter = $empRedirectGet.Content -match "Session:\s*User\s*\($newUsername\)"

Record-Assertion "SEC6-09" "Register" "Valid Registration Creates Auto-Login Session" `
    ($regRedirectOk -and $empRedirectGet.StatusCode -eq 200 -and $hasRegSuccessMsg -and $hasNewUserPill -and $hasNewUserFooter) `
    "PostStatus: $($postValidReg.StatusCode), Location: $($postValidReg.Location), SuccessMsg: $hasRegSuccessMsg, Pill: $hasNewUserPill, Footer: $hasNewUserFooter"

# Test J: Subsequent Login with newly registered user
$newLoginSess = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$nl1 = Invoke-ChallengerGet -Session $newLoginSess -Path "/Account/Login"
$tokNl = Extract-VerificationToken $nl1.Content

$postNewLogin = Invoke-ChallengerPost -Session $newLoginSess -Path "/Account/Login" -FormData @{
    "__RequestVerificationToken" = $tokNl
    "UsernameOrEmail"            = $newUsername
    "Password"                   = $newPassword
} -FollowRedirects $false

$newLoginRedirectOk = ($postNewLogin.StatusCode -eq 302 -and $postNewLogin.Location -like "*/Employee*")
$newEmpGet = Invoke-ChallengerGet -Session $newLoginSess -Path "/Employee/Index" -FollowRedirects $false
$hasNewUserFooter2 = $newEmpGet.Content -match "Session:\s*User\s*\($newUsername\)"

Record-Assertion "SEC6-10" "Register" "Newly Registered User Can Log In Independently" `
    ($newLoginRedirectOk -and $newEmpGet.StatusCode -eq 200 -and $hasNewUserFooter2) `
    "PostStatus: $($postNewLogin.StatusCode), Location: $($postNewLogin.Location), Authenticated: $hasNewUserFooter2"

# ==============================================================================
# SECTION 7: LOGOUT WORKFLOW & DEFECT D-01 VERIFICATION
# ==============================================================================
Write-Host "`n--- Section 7: Logout Workflow & Defect D-01 Remediation ---" -ForegroundColor Yellow

# Step 1: Establish an authenticated admin session
$logoutSess = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$loLoginGet = Invoke-ChallengerGet -Session $logoutSess -Path "/Account/Login"
$tokLo = Extract-VerificationToken $loLoginGet.Content

$loPostLogin = Invoke-ChallengerPost -Session $logoutSess -Path "/Account/Login" -FormData @{
    "__RequestVerificationToken" = $tokLo
    "UsernameOrEmail"            = "admin"
    "Password"                   = "Admin@123"
} -FollowRedirects $false

$loDashGet = Invoke-ChallengerGet -Session $logoutSess -Path "/Admin/Dashboard" -FollowRedirects $false
$preLogoutIsAdmin = ($loDashGet.StatusCode -eq 200 -and ($loDashGet.Content -match 'Session:\s*Admin\s*\(admin\)'))

Record-Assertion "SEC7-01" "Logout" "Pre-Logout: Verified Active Admin Session" `
    $preLogoutIsAdmin `
    "DashboardStatus: $($loDashGet.StatusCode), AuthenticatedAdmin: $preLogoutIsAdmin"

# Step 2: Trigger GET /Account/Logout
$logoutResp = Invoke-ChallengerGet -Session $logoutSess -Path "/Account/Logout" -FollowRedirects $false
$logoutRedirectOk = ($logoutResp.StatusCode -eq 302 -and $logoutResp.Location -like "*/Account/Login*")

Record-Assertion "SEC7-02" "Logout" "Logout Initiates 302 Redirect to /Account/Login" `
    $logoutRedirectOk `
    "Status: $($logoutResp.StatusCode), Location: $($logoutResp.Location)"

# Step 3: Follow the 302 redirect with the SAME session cookie (Defect D-01 critical check)
$postLogoutLoginGet = Invoke-ChallengerGet -Session $logoutSess -Path "/Account/Login" -FollowRedirects $false
$hasInfoAlertClass = $postLogoutLoginGet.Content -match 'alert\s+alert-info'
$hasLogoutSafeMessage = $postLogoutLoginGet.Content -match 'You have been logged out safely\.'

Record-Assertion "SEC7-03" "Logout" "Defect D-01 Remediation: TempData InfoMessage Rendered" `
    ($postLogoutLoginGet.StatusCode -eq 200 -and $hasInfoAlertClass -and $hasLogoutSafeMessage) `
    "HasAlertInfo: $hasInfoAlertClass, HasSafeLogoutMsg: $hasLogoutSafeMessage"

# Step 4: Verify Session["CurrentUser"] is completely cleared
$hasGuestInFooter = $postLogoutLoginGet.Content -match 'Session:\s*Guest'
$hasLoginButtonInNav = $postLogoutLoginGet.Content -match 'href="/Account/Login"'
$hasNoLogoutButton = -not ($postLogoutLoginGet.Content -match 'href="/Account/Logout"')
$hasNoUserPill = -not ($postLogoutLoginGet.Content -match 'class="user-pill"')

Record-Assertion "SEC7-04" "Logout" "Session Cleared: Header and Footer Revert to Guest State" `
    ($hasGuestInFooter -and $hasLoginButtonInNav -and $hasNoLogoutButton -and $hasNoUserPill) `
    "GuestInFooter: $hasGuestInFooter, LoginInNav: $hasLoginButtonInNav, NoLogoutBtn: $hasNoLogoutButton, NoUserPill: $hasNoUserPill"

# Step 5: Verify Protected Route Interception using post-logout session
$reentryResp = Invoke-ChallengerGet -Session $logoutSess -Path "/Admin/Dashboard" -FollowRedirects $false
$reentryIntercepted = ($reentryResp.StatusCode -eq 302 -and $reentryResp.Location -like "*Account/Login*")

$reentryLoginPage = Invoke-ChallengerGet -Session $logoutSess -Path "/Account/Login" -FollowRedirects $false
$hasAccessRestrictedMsg = $reentryLoginPage.Content -match 'Access restricted\. Please log in with an Administrator account\.'

Record-Assertion "SEC7-05" "Security" "Session Invalidation: Protected Admin Access Blocked" `
    ($reentryIntercepted -and $reentryLoginPage.StatusCode -eq 200 -and $hasAccessRestrictedMsg) `
    "Intercepted: $reentryIntercepted (Location: $($reentryResp.Location)), RestrictedAlert: $hasAccessRestrictedMsg"

# ==============================================================================
# SUMMARY & VERDICT
# ==============================================================================
$totalTests = $script:Results.Count
$passedCount = ($script:Results | Where-Object { $_.Passed }).Count
$failedCount = $totalTests - $passedCount

Write-Host "`n==============================================================================" -ForegroundColor Cyan
Write-Host "ADVERSARIAL CHALLENGE EXECUTION SUMMARY" -ForegroundColor Cyan
Write-Host "Total Assertions: $totalTests"
Write-Host "Passed:          $passedCount" -ForegroundColor Green
Write-Host "Failed:          $failedCount" -ForegroundColor $(if ($failedCount -eq 0) { "Green" } else { "Red" })

$verdict = if ($failedCount -eq 0) { "APPROVE" } else { "REJECT" }
Write-Host "Final Verdict:   $verdict" -ForegroundColor $(if ($verdict -eq "APPROVE") { "Green" } else { "Red" })
Write-Host "==============================================================================" -ForegroundColor Cyan

# Output results to JSON for machine readability
$jsonPath = "D:\.NET\.agents\teamwork\challenger_m2_auth\results.json"
$script:Results | ConvertTo-Json -Depth 5 | Set-Content -Path $jsonPath -Encoding utf8
Write-Host "Results serialized to: $jsonPath" -ForegroundColor DarkGray
