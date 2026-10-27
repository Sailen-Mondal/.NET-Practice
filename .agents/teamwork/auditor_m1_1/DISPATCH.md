# Task Assignment: Forensic Auditor - Milestone 1 Integrity Audit

## Target Project Directory
C:\Users\sailenmondal\OneDrive - MANAGEMENT & COMPUTER CONSULTANTS\Documents\Visual Studio 2015\WebSites\WebSite2

## Working Directory
d:\.NET\.agents\teamwork\auditor_m1_1

## References
- Worker Handoff: d:\.NET\.agents\teamwork\worker_m1\handoff.md
- Project Scope: d:\.NET\.agents\teamwork\PROJECT.md
- Original Request: d:\.NET\.agents\teamwork\ORIGINAL_REQUEST.md

## Scope & Objective
Conduct a rigorous forensic integrity audit on Milestone 1:
1. Hardcoded results check: Verify that candidate data and photo BLOBs are not mock constants or dummy stubs hardcoded in code.
2. Database authenticity check: Verify that SQL Server database `ProjectManagementDB` and table `dbo.CandidateProfiles` actually exist and contain real tables and rows.
3. BLOB authenticity check: Verify that `PhotoData` contains genuine image binary headers (PNG header `89 50 4E 47 0D 0A 1A 0A`) and not dummy bytes or filler text.
4. Schema authenticity: Verify `CandidateDataSet.xsd` is a valid XML Schema definition.
5. Code integrity: Check for any deceptive patterns or bypassed validations.
6. Deliver verdict: CLEAN or INTEGRITY VIOLATION.

## Hard Rules
- Binary veto: Any finding of cheating, dummy facades, or fake results must be reported as INTEGRITY VIOLATION.
- STRICT: Zero emojis anywhere in files or messages.
- Write audit report and evidence to `d:\.NET\.agents\teamwork\auditor_m1_1\handoff.md`.
- Report verdict back to orchestrator via send_message.


## 2026-10-27T14:10:12Z
You are the Forensic Auditor for Milestone 1 (M1: Data Architecture & Image BLOBs).
Your working directory: d:\.NET\.agents\teamwork\auditor_m1_1
Target project directory: C:\Users\sailenmondal\OneDrive - MANAGEMENT & COMPUTER CONSULTANTS\Documents\Visual Studio 2015\WebSites\WebSite2
Dispatch instructions: d:\.NET\.agents\teamwork\auditor_m1_1\DISPATCH.md
Worker report: d:\.NET\.agents\teamwork\worker_m1\handoff.md
Original request: d:\.NET\.agents\teamwork\ORIGINAL_REQUEST.md
Project scope: d:\.NET\.agents\teamwork\PROJECT.md

Conduct a forensic integrity audit on M1: check for hardcoded fake results, dummy facades, genuine PNG binary magic headers in PhotoData BLOBs, database table reality, and code integrity.
Write your audit report and verdict (CLEAN or INTEGRITY VIOLATION) to `d:\.NET\.agents\teamwork\auditor_m1_1\handoff.md`.
STRICT: Zero emojis anywhere in files or messages.
Send your verdict back to the orchestrator via send_message.
