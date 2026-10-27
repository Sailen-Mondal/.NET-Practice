# Task Assignment: Test Writer - E2E Testing Track (Tiers 1-4)

## Target Project Directory
C:\Users\sailenmondal\OneDrive - MANAGEMENT & COMPUTER CONSULTANTS\Documents\Visual Studio 2015\WebSites\WebSite2

## Working Directory
d:\.NET\.agents\teamwork\test_writer_e2e

## References & Inputs
- Original Request: d:\.NET\.agents\teamwork\ORIGINAL_REQUEST.md
- Project Scope: d:\.NET\.agents\teamwork\PROJECT.md (Feature Inventory)
- Survey Findings: d:\.NET\.agents\teamwork\explorer_survey_1\handoff.md and d:\.NET\.agents\teamwork\spec_miner_survey_1\handoff.md

## Scope & Objective
Create an automated, opaque-box E2E test suite for WebSite2 running against IIS Express at `http://localhost:8188/Default.aspx`.
Follow the 4-tier methodology:
1. **Tier 1 - Feature Coverage (>=5 per feature)**:
   - Search feature (Name, Skills, City, Department, JobTitle)
   - Gender filter (All, Male, Female, postback persistence)
   - View mode switching (Candidate Directory list view vs Individual Resume view)
   - PDF export (HTTP header `application/pdf`, attachment filename, valid PDF binary header `%PDF-`)
   - Client printing (presence of print button, print mode configuration, print media CSS)
   - Dynamic profile photos (`CrystalImageHandler.aspx` HTTP 200, valid image byte stream)
   - Resume download links (`Resumes/<name>_resume.pdf` HTTP 200, valid `%PDF-`)
2. **Tier 2 - Boundary & Corner Cases (>=5 per feature)**:
   - Empty search input
   - Leading/trailing whitespace in search
   - Case-insensitive search ('rahul', 'RAHUL', 'Rahul')
   - Special characters in search (single quote, percent sign, script tag)
   - Non-matching search criteria (0 results graceful display)
   - Repeated postbacks / state persistence
3. **Tier 3 - Cross-Feature Combinations (pairwise)**:
   - Search by keyword + Male filter
   - Search by keyword + Female filter
   - Filter by Gender + Switch to Resume view
   - Filter by Gender + PDF export (verifying exported PDF reflects filter)
   - Search by Skill + PDF export
4. **Tier 4 - Real-World Application Scenarios (>=5 application scenarios)**:
   - Recruiter searches for ".NET Developer" in "Kolkata", views candidate profile, verifies photo, and downloads PDF resume.
   - HR manager filters "Female" candidates to inspect diversity statistics, switches between directory and resume views.
   - Hiring director searches by skill "SQL Server", exports summary directory PDF report for interview committee.
   - Candidate screening workflow: individual candidate resume view inspection for CandidateId=1 through CandidateId=5.
   - Rapid multi-filter reset and re-query workflow.

## Output Requirements
1. Create `d:\.NET\.agents\teamwork\TEST_INFRA.md` documenting test architecture, runner command, and coverage matrix.
2. Implement an automated executable test runner script (e.g. `d:\.NET\.agents\teamwork\test_writer_e2e\run_e2e_tests.ps1`) that executes all tests against `http://localhost:8188/Default.aspx` and returns clean pass/fail counts.
3. When test suite execution succeeds with 100% pass, publish `d:\.NET\.agents\teamwork\TEST_READY.md`.
4. STRICT: Zero emojis in code, test outputs, or markdown files.
5. Produce `d:\.NET\.agents\teamwork\test_writer_e2e\handoff.md` and report completion back via send_message.


## 2026-10-27T14:04:55Z
From: e5858265-aff7-4221-b161-81b87279d352
Message:
You are the Test Writer agent for the E2E Testing Track of the WebSite2 Crystal Reports solution.
Your working directory: d:\.NET\.agents\teamwork\test_writer_e2e
Target project directory: C:\Users\sailenmondal\OneDrive - MANAGEMENT & COMPUTER CONSULTANTS\Documents\Visual Studio 2015\WebSites\WebSite2
Your dispatch task: d:\.NET\.agents\teamwork\test_writer_e2e\DISPATCH.md
Original request: d:\.NET\.agents\teamwork\ORIGINAL_REQUEST.md
Project specification: d:\.NET\.agents\teamwork\PROJECT.md

Tasks:
1. Review ORIGINAL_REQUEST.md and PROJECT.md § Feature Inventory.
2. Produce `d:\.NET\.agents\teamwork\TEST_INFRA.md` documenting test architecture, runner command, and coverage matrix across 4 tiers:
   - Tier 1: Feature Coverage (>=5 tests per feature: search, gender filter, view mode, PDF export, client printing, dynamic photo serving, resume document links).
   - Tier 2: Boundary & Corner Cases (>=5 tests per feature: empty search, whitespace search, special characters, zero match, case insensitivity).
   - Tier 3: Cross-Feature Combinations (pairwise interactions: search + gender filter, search + view mode, filter + PDF export).
   - Tier 4: Real-World Application Scenarios (>=5 multi-step workflows: recruitment search, candidate screening, executive PDF export dossier, printing layout).
3. Implement an automated executable test runner script `d:\.NET\.agents\teamwork\test_writer_e2e\run_e2e_tests.ps1` that tests the live application at `http://localhost:8188/Default.aspx`.
4. Run the test suite and verify all tests execute and pass.
5. Publish `d:\.NET\.agents\teamwork\TEST_READY.md` summarizing the test suite, execution command, and pass results.
6. Write `d:\.NET\.agents\teamwork\test_writer_e2e\handoff.md`.

STRICT RULE: Zero emojis anywhere in code, test outputs, or markdown files.
When done, report back to the orchestrator via send_message.
