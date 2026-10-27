# Task Assignment: Worker - Milestone 1 (Data Architecture & Image BLOBs)

## Target Project Directory
C:\Users\sailenmondal\OneDrive - MANAGEMENT & COMPUTER CONSULTANTS\Documents\Visual Studio 2015\WebSites\WebSite2

## Working Directory
d:\.NET\.agents\teamwork\worker_m1

## References & Findings
- Original Request: d:\.NET\.agents\teamwork\ORIGINAL_REQUEST.md
- Project Scope: d:\.NET\.agents\teamwork\PROJECT.md
- Survey Findings: d:\.NET\.agents\teamwork\explorer_survey_2\handoff.md and d:\.NET\.agents\teamwork\spec_miner_survey_1\handoff.md

## Scope & Tasks
Implement and verify all requirements for Milestone 1:
1. SQL Server database connection & schema:
   - Ensure table `dbo.CandidateProfiles` in `ProjectManagementDB` has all 16 required columns.
   - Verify connection string `conStr` in `Web.config`.
2. Indian context candidate profiles:
   - Verify 5 candidate records (Rahul Sharma, Priya Mukherjee, Amit Verma, Sneha Patel, Vikram Singh) with Kolkata, Mumbai, Bangalore, Delhi locations.
3. Dual photo storage:
   - Verify `Images/emp1.png` through `emp5.png` and `Images/logo.png`.
   - Ensure `PhotoData` varbinary(max) column in SQL stores matching image byte arrays.
4. Typed schema in `App_Code/CandidateDataSet.xsd`:
   - Verify `Candidate` DataTable has `PhotoData` as `xs:base64Binary` (compiling to `System.Byte[]`).
5. ADO.NET data access:
   - Verify clean, safe `using` blocks (`SqlConnection`, `SqlCommand`, `SqlDataAdapter`, `SqlDataReader`) preventing connection leaks.
6. Verification & Compilation:
   - Compile WebSite2 with `aspnet_compiler.exe` (0 errors).
   - Execute verification script testing ADO.NET querying, schema filling, and BLOB byte retrieval.

## MANDATORY INTEGRITY WARNING
DO NOT CHEAT. All implementations must be genuine. DO NOT hardcode test results, create dummy/facade implementations, or circumvent the intended task. A teamwork_preview_auditor will independently verify your work. Integrity violations WILL be detected and your work WILL be rejected.

## Constraints
- STRICT: Zero emojis in source code, console output, commits, markdown, or messages.
- Clean, didactic architecture.
- Produce `d:\.NET\.agents\teamwork\worker_m1\handoff.md` with build/test commands and output.
- When complete, notify orchestrator via send_message.


## 2026-10-27T14:04:55Z
You are a Worker agent for Milestone 1 (M1: Data Architecture & Image BLOBs).
Your working directory: d:\.NET\.agents\teamwork\worker_m1
Target project directory: C:\Users\sailenmondal\OneDrive - MANAGEMENT & COMPUTER CONSULTANTS\Documents\Visual Studio 2015\WebSites\WebSite2
Your dispatch task: d:\.NET\.agents\teamwork\worker_m1\DISPATCH.md
Original request: d:\.NET\.agents\teamwork\ORIGINAL_REQUEST.md
Project specification: d:\.NET\.agents\teamwork\PROJECT.md

Tasks:
1. Verify database connectivity to ProjectManagementDB via conStr.
2. Verify dbo.CandidateProfiles table schema (16 columns), data types, and primary key.
3. Verify 5 candidate records with authentic Indian context (Rahul Sharma, Priya Mukherjee, Amit Verma, Sneha Patel, Vikram Singh; Kolkata, Mumbai, Bangalore, Delhi).
4. Verify Images/ folder (emp1.png - emp5.png, logo.png) and byte-for-byte match with PhotoData varbinary(max) column.
5. Verify App_Code/CandidateDataSet.xsd schema defines PhotoData as xs:base64Binary (mapping to System.Byte[]).
6. Verify ADO.NET data access patterns use safe using blocks preventing connection leaks.
7. Run build/compilation check with aspnet_compiler.exe to verify 0 compilation errors.
8. Run verification script and record all command outputs in `d:\.NET\.agents\teamwork\worker_m1\handoff.md`.

MANDATORY INTEGRITY WARNING:
DO NOT CHEAT. All implementations must be genuine. DO NOT hardcode test results, create dummy/facade implementations, or circumvent the intended task. A teamwork_preview_auditor will independently verify your work. Integrity violations WILL be detected and your work WILL be rejected.

STRICT RULE: Zero emojis anywhere in files, test outputs, or messages.
When done, report completion to the orchestrator via send_message with the handoff report path.
