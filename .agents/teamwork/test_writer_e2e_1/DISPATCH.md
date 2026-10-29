## 2026-10-29T13:25:28Z
You are test_writer_e2e_1, an E2E testing subagent.
Your metadata working directory: D:\.NET\.agents\teamwork\test_writer_e2e_1\
Original user request file: D:\.NET\.agents\teamwork\ORIGINAL_REQUEST.md (You MUST read this file first before starting work).
Project scope document: D:\.NET\.agents\teamwork\PROJECT.md
Mined specification document: D:\.NET\.agents\teamwork\spec_miner_vmd_1\spec.md

MANDATORY INTEGRITY WARNING:
DO NOT CHEAT. All tests must be authentic opaque-box tests that execute real HTTP requests, session handshakes, form postings, and validations against the running ASP.NET MVC 5 application on IIS Express. Integrity violations WILL be detected and rejected.

Mission:
Author the complete, automated, opaque-box E2E testing suite for ViewModelDemo in D:\.NET\ViewModelDemo\Tests\E2E\.

Test Suite Architecture & Requirements:
1. Target Environment:
   - Target host: http://localhost:9979/ (bound via D:\.NET\ViewModelDemo\.vs\ViewModelDemo.slnx\config\applicationhost.config).
   - Test runner must check if IIS Express is running; if not, it should launch it, verify HTTP 200, and gracefully clean up or attach to it.
   - Maintain cookie session container across sequential requests (e.g., using Invoke-WebRequest with -SessionVariable).
   - Parse HTML forms for __RequestVerificationToken to support authenticated POST requests.

2. Coverage Tiers (Methodology: Category-Partition, BVA, Pairwise, Real-World Workloads):
   Cover all 15 features (F01 to F15) identified in PROJECT.md:
   - Tier 1: Feature Coverage (>=5 test cases per feature = at least 75 tests)
     Happy-path tests verifying each feature in isolation (e.g., login success, register success, employee directory load, search filter, details view, student marks listing, admin dashboard, user management, logout).
   - Tier 2: Boundary & Corner Cases (>=5 test cases per feature = at least 75 tests)
     Boundary conditions, edge cases, error-prone inputs (e.g., invalid login credentials, duplicate user registration, invalid regex username, empty required fields, salary < 1000 or > 10,000,000, unauthorized access to /Admin/Dashboard without admin role, non-existent employee ID, student marks exactly 35.0 vs 35.1 colorname check).
   - Tier 3: Cross-Feature Combinations (at least 15 tests)
     Interactions between features (e.g., Register new user -> Login -> Verify role is User -> Attempt Admin endpoint -> Expect access denied redirect -> Logout -> Login as Admin -> View user in Admin/Users -> Create Employee -> Search Employee in directory -> Verify Details aggregation -> Delete employee -> Verify removed from search).
   - Tier 4: Real-World Application Scenarios (at least 8 tests)
     End-to-end multi-step workflow simulations under realistic Indian context (e.g. Rahul Sharma creates employee Dillip Mohapatra in Kolkata, edits salary to Rs. 65,000, audits dashboard totals and department counts, checks student marks grading).

   Total test count MUST be at least 173 test cases across Tiers 1-4.

3. Script Implementation:
   - Create D:\.NET\ViewModelDemo\Tests\E2E\Run-E2ETests.ps1 with parameters:
     `-Tier <1|2|3|4|All>` (defaults to All), `-BaseUrl <string>` (defaults to http://localhost:9979), `-VerboseOutput <switch>`.
   - Organize test tier files:
     `Tier1_FeatureCoverage.ps1`, `Tier2_BoundaryCorner.ps1`, `Tier3_CrossFeature.ps1`, `Tier4_ApplicationScenarios.ps1`, `TestHarness.ps1`.
   - The runner must return exit code 0 when all tests pass, or non-zero if tests fail, with clear summary table: Tier, Total Tests, Passed, Failed, Skipped.
   - STRICT ZERO EMOJIS in all test output, scripts, logs, and markdown files.

4. Deliverables:
   - Working test scripts in D:\.NET\ViewModelDemo\Tests\E2E\
   - Publish D:\.NET\.agents\teamwork\TEST_INFRA.md and D:\.NET\TEST_INFRA.md
   - Publish D:\.NET\.agents\teamwork\TEST_READY.md and D:\.NET\TEST_READY.md
   - Write completion handoff in D:\.NET\.agents\teamwork\test_writer_e2e_1\handoff.md
   - Send completion message to parent orchestrator via send_message when ready.
