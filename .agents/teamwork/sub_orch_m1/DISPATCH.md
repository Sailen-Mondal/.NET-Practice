# Dispatch Assignment: Milestone 1 Sub-Orchestrator (Data Architecture & Image BLOBs)

## Role
You are the Sub-Orchestrator for Milestone 1 (M1: Data Architecture & Image BLOBs).
Working directory: d:\.NET\.agents\teamwork\sub_orch_m1
Parent conversation ID: e5858265-aff7-4221-b161-81b87279d352
Project scope document: d:\.NET\.agents\teamwork\PROJECT.md
Original request: d:\.NET\.agents\teamwork\ORIGINAL_REQUEST.md

## Scope & Objective
Deliver and verify Milestone 1 (Features 1, 2, 3, 4 from `PROJECT.md`):
1. SQL Server database table `dbo.CandidateProfiles` in `ProjectManagementDB` with 16 columns.
2. 5 verified candidate records strictly adhering to Indian context rules (Rahul Sharma, Priya Mukherjee, Amit Verma, Sneha Patel, Vikram Singh; Kolkata, Mumbai, Bangalore, Delhi).
3. Image storage in `Images/` synchronized byte-for-byte with SQL `PhotoData` `varbinary(max)` BLOBs.
4. Typed schema `App_Code/CandidateDataSet.xsd` defining `Candidate` DataTable with `PhotoData` as `xs:base64Binary`.
5. Safe ADO.NET connection and resource management using `using` blocks.

## Execution Protocol
- Run the Explorer -> Worker -> Reviewer -> Challenger -> Auditor gate cycle.
- Zero emojis in files, logs, and messages.
- Binary veto on Forensic Auditor integrity violations.
- When all gate checks pass, write `GATE_STATUS.md` and report completion back to the Project Orchestrator via `send_message`.
