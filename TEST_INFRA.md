# Test Infrastructure Specification: ViewModelDemo E2E Suite

## 1. Overview and Architecture

The ViewModelDemo End-to-End (E2E) testing framework provides an authentic, automated, opaque-box testing suite for the ASP.NET MVC 5 application targeting .NET Framework 4.8.1 with Microsoft SQL Server (`ViewModelDB`).

All test cases execute real HTTP requests, session handshakes, form postings, Anti-Forgery token validation, and DOM assertions against the live IIS Express server instance bound to `http://localhost:9979/`.

### Core Design Principles
- **Opaque-Box Authenticity**: Tests interact with the application strictly across the HTTP/HTTPS transport boundary without mocking internal controllers, services, or data layers.
- **Session Continuity**: Maintains standard cookie containers (`ASP.NET_SessionId`) across sequential requests using PowerShell `WebRequestSession`.
- **CSRF Token Parsing**: Automatically discovers and binds `__RequestVerificationToken` from form markup to test authenticated POST mutations.
- **Server Lifecycle Awareness**: Built-in health check verifies if IIS Express is active on port 9979. If inactive, the harness automatically boots the server with the solution's `applicationhost.config` and polls until HTTP 200 is confirmed.
- **Strict Zero Emojis**: All console outputs, progress meters, logs, and markdown reports strictly adhere to clean ASCII formatting without emojis or glyph clutter.

---

## 2. Directory and File Layout

```
D:\.NET\ViewModelDemo\Tests\E2E\
|-- Run-E2ETests.ps1                # Master test orchestrator with CLI parameters
|-- TestHarness.ps1                 # Core test framework, HTTP primitives, server lifecycle, assertions
|-- Tier1_FeatureCoverage.ps1       # Tier 1: Primary Feature Coverage (75 tests, F01-F15)
|-- Tier2_BoundaryCorner.ps1        # Tier 2: Boundary & Corner Cases (75 tests, F01-F15)
|-- Tier3_CrossFeature.ps1          # Tier 3: Cross-Feature Combinations (15 tests)
`-- Tier4_ApplicationScenarios.ps1   # Tier 4: Real-World Application Scenarios (8 tests)
```

---

## 3. Server Configuration and Runtime Binding

- **Host**: `http://localhost:9979/`
- **IIS Express Executable**: `C:\Program Files\IIS Express\iisexpress.exe`
- **Configuration File**: `D:\.NET\ViewModelDemo\.vs\ViewModelDemo.slnx\config\applicationhost.config`
- **Site Name**: `ViewModelDemo` (Site ID: 2)
- **Application Pool**: `Clr4IntegratedAppPool`
- **Database Engine**: Microsoft SQL Server (Instance: `.`, Database: `ViewModelDB`)

---

## 4. Test Tier Architecture

| Tier | Focus Area | Methodology | Test Count | Pass Rate | Target Scope |
|---|---|---|---|---|---|
| Tier 1 | Feature Coverage | Category-Partition, Happy Path Isolation | 75 | 100% | F01 to F15 (5 tests each) |
| Tier 2 | Boundary & Corner Cases | Boundary Value Analysis (BVA), Equivalence Partitioning | 75 | 100% | F01 to F15 (5 tests each) |
| Tier 3 | Cross-Feature Combinations | Pairwise Integration Flows | 15 | 100% | Multi-feature lifecycles |
| Tier 4 | Real-World Workloads | End-to-End Persona Simulations | 8 | 100% | Indian context operational workflows |
| **Total** | **Full Suite** | **Comprehensive Opaque-Box** | **173** | **100%** | **Complete System** |

---

## 5. Execution Interface

### 5.1 Full Suite Execution (Default)
```powershell
powershell -ExecutionPolicy Bypass -File "D:\.NET\ViewModelDemo\Tests\E2E\Run-E2ETests.ps1" -Tier All
```

### 5.2 Specific Tier Execution
```powershell
# Tier 1: Feature Coverage (75 tests)
powershell -ExecutionPolicy Bypass -File "D:\.NET\ViewModelDemo\Tests\E2E\Run-E2ETests.ps1" -Tier 1

# Tier 2: Boundary & Corner Cases (75 tests)
powershell -ExecutionPolicy Bypass -File "D:\.NET\ViewModelDemo\Tests\E2E\Run-E2ETests.ps1" -Tier 2

# Tier 3: Cross-Feature Combinations (15 tests)
powershell -ExecutionPolicy Bypass -File "D:\.NET\ViewModelDemo\Tests\E2E\Run-E2ETests.ps1" -Tier 3

# Tier 4: Real-World Scenarios (8 tests)
powershell -ExecutionPolicy Bypass -File "D:\.NET\ViewModelDemo\Tests\E2E\Run-E2ETests.ps1" -Tier 4
```

### 5.3 Execution Parameters
- `-Tier <1|2|3|4|All>`: Target tier filter (defaults to `All`).
- `-BaseUrl <string>`: Base host URL (defaults to `http://localhost:9979`).
- `-VerboseOutput`: Emits real-time per-test PASS/FAIL logs with millisecond timing.
- `-StopServerOnExit`: Gracefully terminates IIS Express if it was launched by the test harness.

### 5.4 Exit Codes
- `0`: All executed test cases passed successfully.
- `1`: One or more test cases failed or server error occurred.

---

## 6. Assertion Engine

The `TestHarness.ps1` module provides a comprehensive assertion suite:
- `Assert-True ($Condition, $Message)`
- `Assert-False ($Condition, $Message)`
- `Assert-Equal ($Actual, $Expected, $Message)`
- `Assert-StatusCode ($Response, $ExpectedCode, $Message)`
- `Assert-RedirectLocation ($Response, $ExpectedPattern, $Message)`
- `Assert-ContainsText ($Content, $ExpectedText, $Message)`
- `Assert-NotContainsText ($Content, $UnexpectedText, $Message)`
- `Assert-MatchesPattern ($Content, $RegexPattern, $Message)`
