# ==============================================================================
# Run-E2ETests.ps1 - Master Orchestrator for ViewModelDemo E2E Test Suite
# Target: ASP.NET MVC 5 on IIS Express (http://localhost:9979)
# STRICT ZERO EMOJIS - Clean Minimalist Terminal Formatting
# ==============================================================================

[CmdletBinding()]
param(
    [ValidateSet("1", "2", "3", "4", "All")]
    [string]$Tier = "All",

    [string]$BaseUrl = "http://localhost:9979",

    [switch]$VerboseOutput,

    [switch]$StopServerOnExit
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Force Process ExecutionPolicy to Bypass if restricted
try {
    if ((Get-ExecutionPolicy -Scope Process) -ne "Bypass") {
        Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force -ErrorAction SilentlyContinue
    }
} catch {
    # Ignore policy set failures if already bypassed
}

$scriptDir = $PSScriptRoot
if ([string]::IsNullOrEmpty($scriptDir)) {
    $scriptDir = (Get-Item -Path ".").FullName
}

Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host " ViewModelDemo - Automated Opaque-Box E2E Test Suite" -ForegroundColor Cyan
Write-Host " Execution Directory: $scriptDir" -ForegroundColor Cyan
Write-Host " Target Host: $BaseUrl" -ForegroundColor Cyan
Write-Host " Selected Scope: Tier $Tier" -ForegroundColor Cyan
Write-Host " Timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Cyan
Write-Host "================================================================================" -ForegroundColor Cyan

# 1. Load Test Framework Harness
$harnessPath = Join-Path $scriptDir "TestHarness.ps1"
if (-not (Test-Path $harnessPath)) {
    Write-Host "[ERROR] TestHarness.ps1 not found at: $harnessPath" -ForegroundColor Red
    exit 1
}
. $harnessPath

# 2. Ensure target web application is running
try {
    Ensure-ServerRunning -TargetUrl $BaseUrl
} catch {
    Write-Host "[FATAL] Failed to verify or launch IIS Express: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# 3. Load Tier Test Definitions based on requested Scope
$tierFiles = @()
if ($Tier -eq "1" -or $Tier -eq "All") {
    $tierFiles += (Join-Path $scriptDir "Tier1_FeatureCoverage.ps1")
}
if ($Tier -eq "2" -or $Tier -eq "All") {
    $tierFiles += (Join-Path $scriptDir "Tier2_BoundaryCorner.ps1")
}
if ($Tier -eq "3" -or $Tier -eq "All") {
    $tierFiles += (Join-Path $scriptDir "Tier3_CrossFeature.ps1")
}
if ($Tier -eq "4" -or $Tier -eq "All") {
    $tierFiles += (Join-Path $scriptDir "Tier4_ApplicationScenarios.ps1")
}

foreach ($tf in $tierFiles) {
    if (Test-Path $tf) {
        Write-Host "[INFO] Loading test suite: $([System.IO.Path]::GetFileName($tf))" -ForegroundColor DarkGray
        . $tf
    } else {
        Write-Host "[WARN] Test file missing: $tf" -ForegroundColor Yellow
    }
}

# 4. Execute Test Suite
$allPassed = $false
try {
    $allPassed = Invoke-TestSuite -TierFilter $Tier -BaseUrl $BaseUrl -VerboseOutput:$VerboseOutput
} finally {
    if ($StopServerOnExit) {
        Stop-ServerIfLaunched
    }
}

# 5. Exit with appropriate status code
if ($allPassed) {
    Write-Host "[SUCCESS] All E2E test cases passed successfully." -ForegroundColor Green
    exit 0
} else {
    Write-Host "[FAILURE] One or more test cases failed." -ForegroundColor Red
    exit 1
}
