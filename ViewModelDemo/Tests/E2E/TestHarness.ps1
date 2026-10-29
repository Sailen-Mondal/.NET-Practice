# ==============================================================================
# TestHarness.ps1 - Automated Opaque-Box E2E Testing Framework for ViewModelDemo
# Target: ASP.NET MVC 5 on IIS Express (http://localhost:9979)
# STRICT ZERO EMOJIS - Clean Minimalist Terminal Formatting
# ==============================================================================

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Global Test Registry and State
$Script:AllTests = [System.Collections.Generic.List[PSObject]]::new()
$Script:TestResults = [System.Collections.Generic.List[PSObject]]::new()
$Script:IisExpressProcess = $null
$Script:LaunchedIis = $false
$Script:BaseUrl = "http://localhost:9979"
$Script:VerboseOutput = $false

# ------------------------------------------------------------------------------
# Server Lifecycle Management
# ------------------------------------------------------------------------------

function Test-PortOpen {
    param([int]$Port = 9979, [string]$HostName = "127.0.0.1")
    $client = $null
    try {
        $client = New-Object System.Net.Sockets.TcpClient
        $iar = $client.BeginConnect($HostName, $Port, $null, $null)
        $success = $iar.AsyncWaitHandle.WaitOne(800, $false)
        if ($success) {
            $client.EndConnect($iar)
            return $true
        }
        return $false
    } catch {
        return $false
    } finally {
        if ($client -ne $null) {
            $client.Close()
            $client.Dispose()
        }
    }
}

function Ensure-ServerRunning {
    param(
        [string]$TargetUrl = "http://localhost:9979",
        [string]$ConfigPath = "D:\.NET\ViewModelDemo\.vs\ViewModelDemo.slnx\config\applicationhost.config",
        [string]$SiteName = "ViewModelDemo"
    )

    $Script:BaseUrl = $TargetUrl.TrimEnd('/')
    $uri = [System.Uri]$TargetUrl
    $port = $uri.Port

    Write-Host "[INFO] Checking target host: $TargetUrl (Port: $port)" -ForegroundColor DarkGray

    # Check if port is already listening and responsive
    if (Test-PortOpen -Port $port) {
        try {
            $check = Invoke-WebRequest -Uri "$Script:BaseUrl/" -UseBasicParsing -TimeoutSec 3 -ErrorAction SilentlyContinue
            if ($check -and $check.StatusCode -ge 200 -and $check.StatusCode -lt 400) {
                Write-Host "[OK] IIS Express is already active on port $port." -ForegroundColor Green
                return
            }
        } catch {
            # Port listening but request failed, continue to startup check
        }
    }

    # If not running, find IIS Express executable
    $iisPath = "C:\Program Files\IIS Express\iisexpress.exe"
    if (-not (Test-Path $iisPath)) {
        $iisPath = "C:\Program Files (x86)\IIS Express\iisexpress.exe"
    }

    if (-not (Test-Path $iisPath)) {
        throw "IIS Express executable not found at $iisPath"
    }

    if (-not (Test-Path $ConfigPath)) {
        throw "applicationhost.config not found at $ConfigPath"
    }

    Write-Host "[INFO] Launching IIS Express on site $SiteName..." -ForegroundColor DarkGray
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $iisPath
    $psi.Arguments = "/config:`"$ConfigPath`" /site:`"$SiteName`""
    $psi.UseShellExecute = $false
    $psi.CreateNoWindow = $true
    $psi.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Hidden

    $process = [System.Diagnostics.Process]::Start($psi)
    $Script:IisExpressProcess = $process
    $Script:LaunchedIis = $true

    # Poll until ready or timeout (25 seconds)
    $timeoutSeconds = 25
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    $isReady = $false

    while ($sw.Elapsed.TotalSeconds -lt $timeoutSeconds) {
        Start-Sleep -Milliseconds 800
        if (Test-PortOpen -Port $port) {
            try {
                $check = Invoke-WebRequest -Uri "$Script:BaseUrl/" -UseBasicParsing -TimeoutSec 3 -ErrorAction SilentlyContinue
                if ($check -and $check.StatusCode -ge 200 -and $check.StatusCode -lt 400) {
                    $isReady = $true
                    break
                }
            } catch {
                # Still initializing
            }
        }
    }

    if (-not $isReady) {
        throw "IIS Express failed to become responsive on $TargetUrl within $timeoutSeconds seconds."
    }

    Write-Host "[OK] IIS Express initialized successfully (PID: $($process.Id))." -ForegroundColor Green
    return
}

function Stop-ServerIfLaunched {
    if ($Script:LaunchedIis -and $Script:IisExpressProcess -and -not $Script:IisExpressProcess.HasExited) {
        Write-Host "[INFO] Terminating launched IIS Express process (PID: $($Script:IisExpressProcess.Id))..." -ForegroundColor DarkGray
        try {
            $Script:IisExpressProcess.Kill()
            $Script:IisExpressProcess.WaitForExit(3000)
        } catch {
            # Ignore cleanup exceptions
        }
    }
}

# ------------------------------------------------------------------------------
# Session & HTTP Client Utilities
# ------------------------------------------------------------------------------

function New-E2ESession {
    param([string]$BaseUrl = $Script:BaseUrl)
    return [PSCustomObject]@{
        WebSession   = New-Object Microsoft.PowerShell.Commands.WebRequestSession
        BaseUrl      = $BaseUrl.TrimEnd('/')
        LastResponse = $null
        CurrentUser  = $null
    }
}

function Get-VerificationToken {
    param([string]$Html)
    if ([string]::IsNullOrEmpty($Html)) { return $null }

    # Pattern 1: name="__RequestVerificationToken" ... value="TOKEN"
    if ($Html -match 'name="__RequestVerificationToken"\s+type="hidden"\s+value="([^"]+)"') {
        return $matches[1]
    }
    # Pattern 2: value="TOKEN" ... name="__RequestVerificationToken"
    if ($Html -match 'value="([^"]+)"\s+(?:type="hidden"\s+)?name="__RequestVerificationToken"') {
        return $matches[1]
    }
    # Pattern 3: value="TOKEN" anywhere with RequestVerificationToken
    if ($Html -match '__RequestVerificationToken"[^>]*value="([^"]+)"') {
        return $matches[1]
    }
    return $null
}

function Invoke-E2EGet {
    param(
        [Parameter(Mandatory = $true)]
        [PSCustomObject]$Session,
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [bool]$FollowRedirects = $true
    )

    $targetUrl = if ($Path.StartsWith("http")) { $Path } else { "$($Session.BaseUrl)$Path" }
    $maxRedir = if ($FollowRedirects) { 10 } else { 0 }

    try {
        $resp = Invoke-WebRequest -Uri $targetUrl `
                                  -WebSession $Session.WebSession `
                                  -UseBasicParsing `
                                  -MaximumRedirection $maxRedir `
                                  -ErrorAction SilentlyContinue

        $loc = $null
        if ($resp -and $resp.Headers) {
            try { $loc = $resp.Headers["Location"] } catch { $loc = $null }
        }

        $result = [PSCustomObject]@{
            StatusCode = if ($resp) { [int]$resp.StatusCode } else { 0 }
            Content    = if ($resp) { [string]$resp.Content } else { "" }
            Headers    = if ($resp) { $resp.Headers } else { @{} }
            Location   = $loc
            RawResponse = $resp
        }
        $Session.LastResponse = $result
        return $result
    } catch [System.Net.WebException] {
        $webEx = $_.Exception
        $webResp = $webEx.Response
        $status = 0
        $loc = $null
        $content = ""
        if ($webResp -ne $null) {
            $status = [int]$webResp.StatusCode
            if ($webResp.Headers -ne $null) {
                $loc = $webResp.Headers["Location"]
            }
            try {
                $stream = $webResp.GetResponseStream()
                if ($stream -ne $null) {
                    $reader = New-Object System.IO.StreamReader($stream)
                    $content = $reader.ReadToEnd()
                    $reader.Close()
                }
            } catch {
                # Ignore stream read errors
            }
        }
        $result = [PSCustomObject]@{
            StatusCode  = $status
            Content     = $content
            Headers     = if ($webResp) { $webResp.Headers } else { @{} }
            Location    = $loc
            RawResponse = $webResp
        }
        $Session.LastResponse = $result
        return $result
    } catch {
        $result = [PSCustomObject]@{
            StatusCode  = 500
            Content     = $_.Exception.Message
            Headers     = @{}
            Location    = $null
            RawResponse = $null
        }
        $Session.LastResponse = $result
        return $result
    }
}

function Invoke-E2EPost {
    param(
        [Parameter(Mandatory = $true)]
        [PSCustomObject]$Session,
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        [hashtable]$FormData,
        [bool]$AutoToken = $true,
        [bool]$FollowRedirects = $false
    )

    $targetUrl = if ($Path.StartsWith("http")) { $Path } else { "$($Session.BaseUrl)$Path" }

    if ($AutoToken -and -not $FormData.ContainsKey("__RequestVerificationToken")) {
        $token = $null
        if ($Session.LastResponse -ne $null -and -not [string]::IsNullOrEmpty($Session.LastResponse.Content)) {
            $token = Get-VerificationToken -Html $Session.LastResponse.Content
        }
        if ([string]::IsNullOrEmpty($token)) {
            $getPage = Invoke-E2EGet -Session $Session -Path $Path -FollowRedirects $true
            $token = Get-VerificationToken -Html $getPage.Content
        }
        if (-not [string]::IsNullOrEmpty($token)) {
            $FormData["__RequestVerificationToken"] = $token
        }
    }

    $maxRedir = if ($FollowRedirects) { 10 } else { 0 }

    try {
        $resp = Invoke-WebRequest -Uri $targetUrl `
                                  -Method Post `
                                  -Body $FormData `
                                  -WebSession $Session.WebSession `
                                  -UseBasicParsing `
                                  -MaximumRedirection $maxRedir `
                                  -ErrorAction SilentlyContinue

        $loc = $null
        if ($resp -and $resp.Headers) {
            try { $loc = $resp.Headers["Location"] } catch { $loc = $null }
        }

        $result = [PSCustomObject]@{
            StatusCode  = if ($resp) { [int]$resp.StatusCode } else { 0 }
            Content     = if ($resp) { [string]$resp.Content } else { "" }
            Headers     = if ($resp) { $resp.Headers } else { @{} }
            Location    = $loc
            RawResponse = $resp
        }
        $Session.LastResponse = $result
        return $result
    } catch [System.Net.WebException] {
        $webEx = $_.Exception
        $webResp = $webEx.Response
        $status = 0
        $loc = $null
        $content = ""
        if ($webResp -ne $null) {
            $status = [int]$webResp.StatusCode
            if ($webResp.Headers -ne $null) {
                $loc = $webResp.Headers["Location"]
            }
            try {
                $stream = $webResp.GetResponseStream()
                if ($stream -ne $null) {
                    $reader = New-Object System.IO.StreamReader($stream)
                    $content = $reader.ReadToEnd()
                    $reader.Close()
                }
            } catch {
                # Ignore stream read errors
            }
        }
        $result = [PSCustomObject]@{
            StatusCode  = $status
            Content     = $content
            Headers     = if ($webResp) { $webResp.Headers } else { @{} }
            Location    = $loc
            RawResponse = $webResp
        }
        $Session.LastResponse = $result
        return $result
    } catch {
        $result = [PSCustomObject]@{
            StatusCode  = 500
            Content     = $_.Exception.Message
            Headers     = @{}
            Location    = $null
            RawResponse = $null
        }
        $Session.LastResponse = $result
        return $result
    }
}

function Invoke-E2ELogin {
    param(
        [Parameter(Mandatory = $true)]
        [PSCustomObject]$Session,
        [Parameter(Mandatory = $true)]
        [string]$UsernameOrEmail,
        [Parameter(Mandatory = $true)]
        [string]$Password,
        [string]$ReturnUrl = $null
    )

    $loginPath = if ([string]::IsNullOrEmpty($ReturnUrl)) { "/Account/Login" } else { "/Account/Login?returnUrl=$([System.Uri]::EscapeDataString($ReturnUrl))" }
    $loginPage = Invoke-E2EGet -Session $Session -Path $loginPath -FollowRedirects $true
    $token = Get-VerificationToken -Html $loginPage.Content

    $body = @{
        "__RequestVerificationToken" = $token
        "UsernameOrEmail"            = $UsernameOrEmail
        "Password"                   = $Password
        "RememberMe"                 = "false"
    }
    if (-not [string]::IsNullOrEmpty($ReturnUrl)) {
        $body["ReturnUrl"] = $ReturnUrl
    }

    $loginPost = Invoke-E2EPost -Session $Session -Path "/Account/Login" -FormData $body -AutoToken $false -FollowRedirects $false
    if ($loginPost.StatusCode -eq 302) {
        $Session.CurrentUser = $UsernameOrEmail
    }
    return $loginPost
}

function Invoke-E2ELogout {
    param(
        [Parameter(Mandatory = $true)]
        [PSCustomObject]$Session
    )
    $logoutRes = Invoke-E2EGet -Session $Session -Path "/Account/Logout" -FollowRedirects $false
    $Session.CurrentUser = $null
    return $logoutRes
}

# ------------------------------------------------------------------------------
# Assertion Engine
# ------------------------------------------------------------------------------

function Assert-True {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) {
        throw "Assertion Failed: $Message"
    }
}

function Assert-False {
    param([bool]$Condition, [string]$Message)
    if ($Condition) {
        throw "Assertion Failed (Expected False): $Message"
    }
}

function Assert-Equal {
    param($Actual, $Expected, [string]$Message)
    if ($Actual -ne $Expected) {
        throw "Assertion Failed: $Message. Expected: '$Expected', Actual: '$Actual'"
    }
}

function Assert-StatusCode {
    param([PSCustomObject]$Response, [int]$ExpectedCode, [string]$Message)
    if ($Response -eq $null -or $Response.StatusCode -ne $ExpectedCode) {
        $code = if ($Response) { $Response.StatusCode } else { "null" }
        throw "Assertion Failed: $Message. Expected HTTP status $ExpectedCode, received $code."
    }
}

function Assert-RedirectLocation {
    param([PSCustomObject]$Response, [string]$ExpectedPattern, [string]$Message)
    Assert-StatusCode -Response $Response -ExpectedCode 302 -Message "$Message (Expected 302 Redirect)"
    if ([string]::IsNullOrEmpty($Response.Location) -or ($Response.Location -notmatch $ExpectedPattern)) {
        throw "Assertion Failed: $Message. Expected Location matching '$ExpectedPattern', received '$($Response.Location)'"
    }
}

function Assert-ContainsText {
    param([string]$Content, [string]$ExpectedText, [string]$Message)
    if ([string]::IsNullOrEmpty($Content) -or -not ($Content.Contains($ExpectedText))) {
        throw "Assertion Failed: $Message. Expected content to contain '$ExpectedText'."
    }
}

function Assert-NotContainsText {
    param([string]$Content, [string]$UnexpectedText, [string]$Message)
    if (-not [string]::IsNullOrEmpty($Content) -and $Content.Contains($UnexpectedText)) {
        throw "Assertion Failed: $Message. Expected content NOT to contain '$UnexpectedText'."
    }
}

function Assert-MatchesPattern {
    param([string]$Content, [string]$RegexPattern, [string]$Message)
    if ([string]::IsNullOrEmpty($Content) -or -not ($Content -match $RegexPattern)) {
        throw "Assertion Failed: $Message. Expected content to match pattern '$RegexPattern'."
    }
}

# ------------------------------------------------------------------------------
# Test Registration & Execution Infrastructure
# ------------------------------------------------------------------------------

function Register-TestCase {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Id,
        [Parameter(Mandatory = $true)]
        [string]$Tier,
        [Parameter(Mandatory = $true)]
        [string]$Feature,
        [Parameter(Mandatory = $true)]
        [string]$Title,
        [Parameter(Mandatory = $true)]
        [scriptblock]$ScriptBlock
    )

    $test = [PSCustomObject]@{
        Id          = $Id
        Tier        = $Tier
        Feature     = $Feature
        Title       = $Title
        ScriptBlock = $ScriptBlock
    }
    $Script:AllTests.Add($test)
}

function Invoke-TestSuite {
    param(
        [string]$TierFilter = "All",
        [string]$BaseUrl = "http://localhost:9979",
        [switch]$VerboseOutput
    )

    $Script:BaseUrl = $BaseUrl.TrimEnd('/')
    $Script:VerboseOutput = $VerboseOutput.IsPresent
    $Script:TestResults.Clear()

    # Filter tests by tier
    $testsToRun = @($Script:AllTests | Where-Object {
        if ($TierFilter -eq "All") { $true }
        else { $_.Tier -eq "Tier $TierFilter" -or $_.Tier -eq "Tier$TierFilter" -or $_.Tier -eq $TierFilter }
    })

    $totalCount = $testsToRun.Count
    Write-Host "================================================================================" -ForegroundColor Cyan
    Write-Host " ViewModelDemo E2E Test Suite Execution" -ForegroundColor Cyan
    Write-Host " Target Host: $Script:BaseUrl" -ForegroundColor Cyan
    Write-Host " Scope: Tier $TierFilter (Total Tests Queued: $totalCount)" -ForegroundColor Cyan
    Write-Host "================================================================================" -ForegroundColor Cyan

    $passCount = 0
    $failCount = 0
    $skipCount = 0
    $swTotal = [System.Diagnostics.Stopwatch]::StartNew()

    foreach ($test in $testsToRun) {
        $swTest = [System.Diagnostics.Stopwatch]::StartNew()
        $status = "PASS"
        $errMessage = ""

        try {
            # Execute test scriptblock
            & $test.ScriptBlock
            $swTest.Stop()
            $passCount++
            if ($Script:VerboseOutput) {
                Write-Host ("[PASS] {0,-10} [{1}] {2} ({3} ms)" -f $test.Id, $test.Feature, $test.Title, [math]::Round($swTest.Elapsed.TotalMilliseconds)) -ForegroundColor Green
            }
        } catch {
            $swTest.Stop()
            $status = "FAIL"
            $errMessage = $_.Exception.Message
            $failCount++
            Write-Host ("[FAIL] {0,-10} [{1}] {2} ({3} ms)" -f $test.Id, $test.Feature, $test.Title, [math]::Round($swTest.Elapsed.TotalMilliseconds)) -ForegroundColor Red
            Write-Host ("       Error: {0}" -f $errMessage) -ForegroundColor Yellow
        }

        $Script:TestResults.Add([PSCustomObject]@{
            Id        = $test.Id
            Tier      = $test.Tier
            Feature   = $test.Feature
            Title     = $test.Title
            Status    = $status
            Duration  = $swTest.Elapsed.TotalMilliseconds
            Error     = $errMessage
        })
    }

    $swTotal.Stop()

    # Summary table
    Write-Host ""
    Write-Host "--------------------------------------------------------------------------------" -ForegroundColor Cyan
    Write-Host " Test Execution Summary" -ForegroundColor Cyan
    Write-Host "--------------------------------------------------------------------------------" -ForegroundColor Cyan
    
    $tierGroups = @($Script:TestResults | Group-Object Tier)
    $tierSummaries = foreach ($tg in $tierGroups) {
        $tTotal = @($tg.Group).Count
        $tPass = @($tg.Group | Where-Object { $_.Status -eq "PASS" }).Count
        $tFail = @($tg.Group | Where-Object { $_.Status -eq "FAIL" }).Count
        $tSkip = @($tg.Group | Where-Object { $_.Status -eq "SKIP" }).Count
        $tDur  = [math]::Round((@($tg.Group) | Measure-Object -Property Duration -Sum).Sum / 1000, 2)
        
        [PSCustomObject]@{
            Tier       = $tg.Name
            Total      = $tTotal
            Passed     = $tPass
            Failed     = $tFail
            Skipped    = $tSkip
            "Time (s)" = $tDur
        }
    }

    $tierSummaries | Format-Table -AutoSize | Out-String | Write-Host -ForegroundColor White

    Write-Host ("Total Tests: {0} | Passed: {1} | Failed: {2} | Skipped: {3} | Total Time: {4}s" -f `
        $totalCount, $passCount, $failCount, $skipCount, [math]::Round($swTotal.Elapsed.TotalSeconds, 2)) `
        -ForegroundColor $(if ($failCount -eq 0) { "Green" } else { "Red" })
    Write-Host "================================================================================" -ForegroundColor Cyan

    return ($failCount -eq 0)
}
