# Test Infrastructure Specification: WebSite2 Crystal Reports Solution

## 1. Architecture Overview

This document specifies the end-to-end (E2E) automated test architecture for WebSite2, an ASP.NET WebForms solution utilizing SAP Crystal Reports runtime v13.0.2000.0, running on IIS Express at `http://localhost:8188/Default.aspx`.

### Core Architectural Principles
1. **Opaque-Box E2E Testing**:
   The test suite interacts strictly through standard HTTP protocols (GET, POST), simulating authentic browser sessions without relying on internal process hooks or privileged APIs.
2. **WebForms State Lifecycle Management**:
   The test runner handles ASP.NET WebForms page lifecycle transitions, capturing hidden fields (`__VIEWSTATE`, `__EVENTVALIDATION`, `__VIEWSTATEGENERATOR`) from HTML payloads and transmitting them in simulated postbacks.
3. **Session Cookie Preservation**:
   A dedicated `Microsoft.PowerShell.Commands.WebRequestSession` maintains `ASP.NET_SessionId` cookies across sequential requests, verifying server-side session caching (`Session["FilterName"]`, `Session["FilterGender"]`, `Session["ViewMode"]`, `Session["SelectedCandidateId"]`).
4. **Binary Stream Verification**:
   The test suite performs binary integrity verification on returned media:
   - Exported PDFs: Validates HTTP 200, MIME `application/pdf`, `Content-Disposition` header, and `%PDF-` (hex `25 50 44 46`) binary magic header.
   - Dynamic Profile Photos: Validates `CrystalImageHandler.aspx` responses for HTTP 200, MIME `image/png`, and PNG binary signature (hex `89 50 4E 47 0D 0A 1A 0A`).
   - Static Resume Documents: Validates `Resumes/*.pdf` accessibility, HTTP 200, and valid PDF binary headers.

---

## 2. Test Execution Command

The test harness is fully automated and executable from PowerShell.

### Primary Command Line
```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "d:\.NET\.agents\teamwork\test_writer_e2e\run_e2e_tests.ps1"
```

### Exit Code Protocol
- Exit Code `0`: All test assertions passed (100% pass rate).
- Exit Code `1`: One or more test assertions failed or server unreachable.

### Output Formatting
In adherence to project visual aesthetics, all console outputs use clean, minimalist, Apple-style terminal formatting without gaudy colors and strictly zero emojis.

---

## 3. Coverage Matrix Across 4 Systematic Tiers

### Summary Counts
| Tier | Category | Number of Tests | Pass Criteria |
|------|----------|-----------------|---------------|
| Tier 1 | Feature Coverage (7 features) | 35 | >=5 tests per feature |
| Tier 2 | Boundary & Corner Cases (5 areas) | 25 | >=5 tests per area |
| Tier 3 | Cross-Feature Combinations (pairwise) | 10 | Exact pairwise state verification |
| Tier 4 | Real-World Application Workflows | 18 | 5 multi-step end-to-end scenarios |
| **Total** | **Comprehensive Suite** | **88** | **100% Pass** |

---

### Tier 1: Feature Coverage (35 Tests)

#### Feature 1.1: Multi-Field Search (5 tests)
- **T1.1.1**: Search candidate "Rahul" -> Returns 1 card for "Rahul Sharma", 0 cards for Priya.
- **T1.1.2**: Search candidate "Priya" -> Returns 1 card for "Priya Mukherjee", 0 cards for Rahul.
- **T1.1.3**: Search candidate "Amit" -> Returns 1 card for "Amit Verma", 0 cards for Sneha.
- **T1.1.4**: Search candidate "Sneha" -> Returns 1 card for "Sneha Patel", 0 cards for Vikram.
- **T1.1.5**: Search candidate "Vikram" -> Returns 1 card for "Vikram Singh", 0 cards for Rahul.

#### Feature 1.2: Gender Filter (5 tests)
- **T1.2.1**: Filter "All Genders" -> Returns all 5 seeded candidates.
- **T1.2.2**: Filter "Male" -> Returns exactly 3 candidates (Rahul, Amit, Vikram).
- **T1.2.3**: Filter "Female" -> Returns exactly 2 candidates (Priya, Sneha).
- **T1.2.4**: Gender Filter Transition -> Switching from Male to Female updates count from 3 to 2.
- **T1.2.5**: Filter State Persistence -> Postback retains selected gender in dropdown.

#### Feature 1.3: View Mode Switching (5 tests)
- **T1.3.1**: Default Mode -> Initial page load defaults to "Directory" view mode.
- **T1.3.2**: Switch to Resume Mode -> Postback selects "Resume" and reveals candidate selector panel.
- **T1.3.3**: Resume View Mode Header -> Label updates to "Individual Candidate Biodata & Resume Report".
- **T1.3.4**: Candidate Selection in Resume Mode -> Selecting Candidate 2 updates active candidate profile.
- **T1.3.5**: Switch Back to Directory Mode -> Restores "All Candidates Directory" roster.

#### Feature 1.4: PDF Export (5 tests)
- **T1.4.1**: Directory PDF Export HTTP Status -> Postback with `btnPDF` returns HTTP 200 OK.
- **T1.4.2**: Directory PDF Content-Type -> Header equals `application/pdf`.
- **T1.4.3**: Directory PDF Content-Disposition -> Contains `filename=CandidateDirectory.pdf`.
- **T1.4.4**: Directory PDF Binary Header -> First 4 bytes equal `%PDF` (ASCII 0x25 0x50 0x44 0x46).
- **T1.4.5**: Resume PDF Export Filename -> In Resume mode, attachment filename equals `CandidateResume.pdf`.

#### Feature 1.5: Client-Side Printing (5 tests)
- **T1.5.1**: Print Button Presence -> DOM contains `<input id="btnPrint" ...>`.
- **T1.5.2**: Print Button Caption -> Value attribute equals "Print Report".
- **T1.5.3**: Print JavaScript Function -> Page defines `function printClientReport()`.
- **T1.5.4**: Report Container Binding -> Page contains `<div id="dvReport">` targeting the Crystal viewer.
- **T1.5.5**: Print Button Event Handler -> `onclick` calls `printClientReport()`.

#### Feature 1.6: Dynamic Profile Photos via CrystalImageHandler (5 tests)
- **T1.6.1**: Image Handler URL Pattern -> Viewer renders `CrystalImageHandler.aspx?dynamicimage=...`.
- **T1.6.2**: Dynamic Image HTTP Status -> Requesting dynamic image returns HTTP 200 OK.
- **T1.6.3**: Dynamic Image MIME Type -> Response `Content-Type` is `image/png`.
- **T1.6.4**: Dynamic Image Binary Magic Header -> First 4 bytes match PNG header (`\x89PNG`).
- **T1.6.5**: Dynamic Image Non-Empty Stream -> Response length is greater than 1000 bytes.

#### Feature 1.7: Resume Document Hyperlinks (5 tests)
- **T1.7.1**: Rahul Sharma Resume -> `Resumes/rahul_sharma_resume.pdf` returns HTTP 200 with `%PDF-` header.
- **T1.7.2**: Priya Mukherjee Resume -> `Resumes/priya_mukherjee_resume.pdf` returns HTTP 200 with `%PDF-` header.
- **T1.7.3**: Amit Verma Resume -> `Resumes/amit_verma_resume.pdf` returns HTTP 200 with `%PDF-` header.
- **T1.7.4**: Sneha Patel Resume -> `Resumes/sneha_patel_resume.pdf` returns HTTP 200 with `%PDF-` header.
- **T1.7.5**: Vikram Singh Resume -> `Resumes/vikram_singh_resume.pdf` returns HTTP 200 with `%PDF-` header.

---

### Tier 2: Boundary & Corner Cases (25 Tests)

#### Area 2.1: Empty Search Input (5 tests)
- **T2.1.1**: Blank Search -> Empty `txtFirstName` returns all 5 candidates.
- **T2.1.2**: Search Clear -> Searching specific name then blank restores all 5 candidates.
- **T2.1.3**: Blank Search with Male Filter -> Returns all 3 male candidates.
- **T2.1.4**: Blank Search with Female Filter -> Returns both female candidates.
- **T2.1.5**: Blank Search in Resume View -> Maintains current candidate selection.

#### Area 2.2: Whitespace Handling (5 tests)
- **T2.2.1**: Leading Whitespace -> Search `"   Rahul"` correctly resolves to "Rahul Sharma".
- **T2.2.2**: Trailing Whitespace -> Search `"Rahul   "` correctly resolves to "Rahul Sharma".
- **T2.2.3**: Surrounding Whitespace -> Search `"   Rahul   "` correctly resolves to "Rahul Sharma".
- **T2.2.4**: Full Name with Internal Space -> Search `"Rahul Sharma"` correctly resolves.
- **T2.2.5**: Whitespace-Only String -> Search `"    "` trims to empty and returns all 5 candidates.

#### Area 2.3: Special Characters & Injection Resilience (5 tests)
- **T2.3.1**: Single Quote -> Search `"O'Connor"` returns 0 cards with HTTP 200 without SQL exception.
- **T2.3.2**: Wildcard Character -> Search `"%" ` safely processes via SQL parameterization.
- **T2.3.3**: SQL Injection Payload -> Search `"' OR '1'='1"` returns 0 cards with HTTP 200 (parameterized).
- **T2.3.4**: Special Symbols -> Search `"C# / .NET"` returns 0 cards safely without parser failure.
- **T2.3.5**: Script Tag Injection -> Search `"<script>alert(1)</script>"` is trapped by ASP.NET RequestValidation.

#### Area 2.4: Zero Match Handling (5 tests)
- **T2.4.1**: Non-Existent Name -> Search `"NonExistentCandidate999"` returns exactly 0 profile cards.
- **T2.4.2**: Non-Existent with Male Filter -> Returns 0 cards with clean UI.
- **T2.4.3**: Non-Existent with Female Filter -> Returns 0 cards with clean UI.
- **T2.4.4**: Conflicting Criteria -> Search `"Rahul"` with Gender `"Female"` yields 0 cards cleanly.
- **T2.4.5**: Crystal Reports Empty Dataset Rendering -> Empty dataset renders report without crashing.

#### Area 2.5: Case Insensitivity (5 tests)
- **T2.5.1**: All Lowercase -> Search `"rahul"` matches "Rahul Sharma".
- **T2.5.2**: All Uppercase -> Search `"RAHUL"` matches "Rahul Sharma".
- **T2.5.3**: Mixed Inverted Case -> Search `"rAhUl"` matches "Rahul Sharma".
- **T2.5.4**: All Lowercase Female -> Search `"priya"` matches "Priya Mukherjee".
- **T2.5.5**: All Uppercase Female -> Search `"PRIYA"` matches "Priya Mukherjee".

---

### Tier 3: Cross-Feature Combinations (10 Tests)

- **T3.1**: Search "Rahul" + Gender "Male" -> Exactly 1 candidate card (Rahul Sharma).
- **T3.2**: Search "Rahul" + Gender "Female" -> 0 candidate cards (cross-gender conflict).
- **T3.3**: Search "Priya" + Gender "Female" -> Exactly 1 candidate card (Priya Mukherjee).
- **T3.4**: Search "Priya" + Gender "Male" -> 0 candidate cards (cross-gender conflict).
- **T3.5**: Gender "Male" + Switch View Mode to "Resume" -> Displays Resume mode with candidate dropdown.
- **T3.6**: Gender "Female" + Switch View Mode to "Resume" -> Displays Resume mode with candidate dropdown.
- **T3.7**: Gender "Male" + Export PDF -> Downloads `CandidateDirectory.pdf` with valid `%PDF-` header.
- **T3.8**: Gender "Female" + Export PDF -> Downloads `CandidateDirectory.pdf` with valid `%PDF-` header.
- **T3.9**: Search "Amit" + Export PDF -> Downloads `CandidateDirectory.pdf` reflecting filtered dataset.
- **T3.10**: View Mode "Resume" + Candidate 3 + Export PDF -> Downloads `CandidateResume.pdf` with valid `%PDF-` header.

---

### Tier 4: Real-World Application Workflows (18 Sub-Checks)

#### Workflow 4.1: End-to-End Recruiter Candidate Sourcing
1. Initial access to Candidate Directory roster.
2. Search candidate "Rahul".
3. Verify candidate role "Senior .NET Developer" and city "Kolkata".
4. Verify dynamic photo served via `CrystalImageHandler.aspx`.
5. Download and verify `Resumes/rahul_sharma_resume.pdf`.

#### Workflow 4.2: HR Diversity & Inclusion Screening
1. Filter candidates by gender "Female".
2. Verify returned candidates are Priya Mukherjee and Sneha Patel.
3. Switch report mode to "Resume" view for in-depth profile screening.
4. Verify report title updates to "Individual Candidate Biodata & Resume Report".
5. Return to "Directory" view mode and verify candidate count.

#### Workflow 4.3: Hiring Committee Dossier PDF Export
1. Filter candidates by gender "Male".
2. Search candidate "Vikram".
3. Verify candidate card details ("Cloud Solutions Architect", "Delhi").
4. Export report to PDF.
5. Verify downloaded file is a valid PDF containing `%PDF-` header.

#### Workflow 4.4: Candidate Screening Multi-Profile Inspection
1. Select Candidate 1 (Rahul) -> Verify profile card.
2. Select Candidate 2 (Priya) -> Verify profile card.
3. Select Candidate 3 (Amit) -> Verify profile card.
4. Select Candidate 4 (Sneha) -> Verify profile card.
5. Select Candidate 5 (Vikram) -> Verify profile card.

#### Workflow 4.5: Rapid Multi-Filter Reset & State Transition
1. Apply search "Amit" and gender "Male".
2. Click "Reset Filters" -> Verify all 5 candidates restored and inputs cleared.
3. Apply search "Sneha" and gender "Female".
4. Click "Reset Filters" -> Verify clean reset.

---

## 4. Authoritative Sources of Expected Outputs

| Entity / Field | Authoritative Source | Value / Specification |
|----------------|----------------------|-----------------------|
| Candidate 1 | `ProjectManagementDB.dbo.CandidateProfiles` | Rahul Sharma, Male, Senior .NET Developer, Kolkata, `emp1.png`, `rahul_sharma_resume.pdf` |
| Candidate 2 | `ProjectManagementDB.dbo.CandidateProfiles` | Priya Mukherjee, Female, Database Administrator, Kolkata, `emp2.png`, `priya_mukherjee_resume.pdf` |
| Candidate 3 | `ProjectManagementDB.dbo.CandidateProfiles` | Amit Verma, Male, Full Stack Engineer, Mumbai, `emp3.png`, `amit_verma_resume.pdf` |
| Candidate 4 | `ProjectManagementDB.dbo.CandidateProfiles` | Sneha Patel, Female, BI & Reporting Analyst, Bangalore, `emp4.png`, `sneha_patel_resume.pdf` |
| Candidate 5 | `ProjectManagementDB.dbo.CandidateProfiles` | Vikram Singh, Male, Cloud Solutions Architect, Delhi, `emp5.png`, `vikram_singh_resume.pdf` |
| PDF Format | Adobe PDF 1.7 / ISO 32000-1 | Magic bytes `25 50 44 46` (`%PDF-`), MIME `application/pdf` |
| PNG Format | ISO/IEC 15948:2004 | Magic bytes `89 50 4E 47 0D 0A 1A 0A`, MIME `image/png` |
| WebForms Engine | ASP.NET 4.5.2 State Machine | Hidden inputs `__VIEWSTATE`, `__EVENTVALIDATION`, Cookie `ASP.NET_SessionId` |
