# Forensic Audit Report: Milestone 1 - Data Architecture & Image BLOBs

**Work Product**: Milestone 1 Deliverables (SQL Server Database `ProjectManagementDB`, `dbo.CandidateProfiles` table, `PhotoData` BLOBs, `Images/` assets, `App_Code/CandidateDataSet.xsd`, and ADO.NET data access in `Default.aspx.cs`)  
**Target Project**: `C:\Users\sailenmondal\OneDrive - MANAGEMENT & COMPUTER CONSULTANTS\Documents\Visual Studio 2015\WebSites\WebSite2`  
**Auditor Working Directory**: `d:\.NET\.agents\teamwork\auditor_m1_1`  
**Profile**: General Project  
**Integrity Mode**: Development  
**Auditor**: auditor_m1_1 (Roles: critic, specialist, auditor)  
**Date**: 2026-10-27  
**Verdict**: CLEAN  

---

## Forensic Audit Summary

| Check # | Forensic Verification Check | Scope | Result | Empirical Details |
|---|---|---|---|---|
| 1 | Database Connectivity | `Web.config` `conStr` | PASS | Connected to SQL Server 15.00.2200, catalog `ProjectManagementDB`, state `Open`. |
| 2 | Table Reality & Schema | `dbo.CandidateProfiles` | PASS | 16 physical columns present, PK on `CandidateId`, `PhotoData` type `varbinary(-1)`. |
| 3 | Candidate Record Reality | `dbo.CandidateProfiles` rows | PASS | Exactly 5 candidate records found adhering to authentic Indian naming and geographic context. |
| 4 | BLOB Binary Authenticity | SQL `PhotoData` byte streams | PASS | Valid PNG magic header `89 50 4E 47 0D 0A 1A 0A`, `IHDR` chunk, 240x240 dimensions, GDI+ decode success, SHA256 match with disk. |
| 5 | Source Code & Facade Audit | `Default.aspx.cs` | PASS | Zero hardcoded candidate arrays, zero dummy facades, zero `NotImplementedException`, real SQL queries with parameters. |
| 6 | In-Memory DataSet Schema | `CandidateDataSet.xsd` | PASS | Valid XML Schema, compiles via `XmlSchemaSet`, `PhotoData` defined as `xs:base64Binary`, mapped to `System.Byte[]`. |
| 7 | Pre-populated Artifacts | Project Root | PASS | Zero pre-cooked `.log`, `.out`, or fabricated test outputs. |
| 8 | Independent Compilation | ASP.NET WebSite2 | PASS | `aspnet_compiler.exe` exited with code 0 (clean compilation, zero errors). |
| 9 | Adversarial Stress Testing | Injection & Boundary | PASS | SQL injection payload `' OR '1'='1` blocked (0 rows), non-existent ID handled safely, `logo.png` valid PNG. |
| 10 | Emoji Prohibition Audit | All Project & Teamwork Files | PASS | Exactly zero unicode emojis detected across the entire codebase and metadata. |

---

## 1. Observation

### 1.1 Direct Database Verification
Independent execution of `d:\.NET\.agents\teamwork\auditor_m1_1\forensic_audit.ps1` connected to SQL Server using connection string extracted directly from `Web.config`:
- **Server Version**: `15.00.2200` (Microsoft SQL Server)
- **Catalog**: `ProjectManagementDB`
- **State**: `Open`
- **Tables Verified in Database**: `CandidateProfiles`, `Employee1`, `Employees`, `Departments`, `Projects`, `Students`, `Tasks`, `parts`, `bill_of_materials`.

### 1.2 Table Schema & Column Counts
Query on `INFORMATION_SCHEMA.COLUMNS` confirmed exactly 16 columns in `dbo.CandidateProfiles`:
```
[01] CandidateId        int          len:      nullable:NO
[02] FullName           nvarchar     len:100   nullable:NO
[03] JobTitle           nvarchar     len:100   nullable:NO
[04] Department         nvarchar     len:100   nullable:NO
[05] Gender             nvarchar     len:20    nullable:NO
[06] Email              nvarchar     len:100   nullable:NO
[07] Phone              nvarchar     len:50    nullable:NO
[08] City               nvarchar     len:50    nullable:NO
[09] Skills             nvarchar     len:500   nullable:NO
[10] ExperienceYears    int          len:      nullable:NO
[11] Summary            nvarchar     len:1000  nullable:NO
[12] PhotoFileName      nvarchar     len:100   nullable:NO
[13] PhotoPath          nvarchar     len:255   nullable:NO
[14] ResumeFileName     nvarchar     len:100   nullable:NO
[15] ResumePath         nvarchar     len:255   nullable:NO
[16] PhotoData          varbinary    len:-1    nullable:YES
```
Primary key verified on `CandidateId`.

### 1.3 Candidate Record Verification
Retrieved 5 distinct rows from `dbo.CandidateProfiles`:
1. Candidate 1: Rahul Sharma, Male, Kolkata, Senior .NET Developer, 5 yrs exp, Photo: emp1.png, BLOB: 4,194 bytes.
2. Candidate 2: Priya Mukherjee, Female, Kolkata, Database Administrator, 4 yrs exp, Photo: emp2.png, BLOB: 4,412 bytes.
3. Candidate 3: Amit Verma, Male, Mumbai, Full Stack Engineer, 6 yrs exp, Photo: emp3.png, BLOB: 4,356 bytes.
4. Candidate 4: Sneha Patel, Female, Bangalore, BI & Reporting Analyst, 3 yrs exp, Photo: emp4.png, BLOB: 4,048 bytes.
5. Candidate 5: Vikram Singh, Male, Delhi, Cloud Solutions Architect, 8 yrs exp, Photo: emp5.png, BLOB: 4,296 bytes.

### 1.4 Binary Magic Header Inspection and GDI+ Decoding
Each of the 5 `PhotoData` BLOBs was extracted directly from SQL Server into a byte array:
- **Magic Header**: Byte indices 0..7 are verbatim `89 50 4E 47 0D 0A 1A 0A` (Hex: `89 50 4E 47 0D 0A 1A 0A`).
- **IHDR Chunk**: Byte indices 12..15 decoded to ASCII string `IHDR`.
- **Dimensions Decoded from IHDR**: Exactly 240x240 pixels for each image.
- **GDI+ Engine Test**: `[System.Drawing.Bitmap]::FromStream(ms)` successfully loaded every BLOB without exception; `PixelFormat` confirmed as `Format32bppArgb`.
- **SHA256 Hash Matching**:
  - `emp1.png`: `C42435E9CA307534E87D418880F5F94B28F32C933DA1B7881B0CF4A2F82A0057` (Exact match)
  - `emp2.png`: `255ACA11E37A124078CB5ADE0C47FD4A7636046953FFDBFC3CEC8699EBA3DEDF` (Exact match)
  - `emp3.png`: `7669F06E84A3888346764C8A3DD5B758715721F38C4AA2FA82128CE54F5AFE5F` (Exact match)
  - `emp4.png`: `9CED5B91D4C59A578FE99124D1A1649FE9E67917FEFA9A431CD628B38C943D39` (Exact match)
  - `emp5.png`: `705E321316E62E463EE0D8F2211F9062B32DB6A15302892B28020D998B0E8DD7` (Exact match)
- **Asset logo.png**: Verified at 1,654 bytes, valid PNG header, decoded to 280x80 pixels.

### 1.5 Source Code Integrity & Facade Inspection
Inspected `C:\Users\sailenmondal\OneDrive - MANAGEMENT & COMPUTER CONSULTANTS\Documents\Visual Studio 2015\WebSites\WebSite2\Default.aspx.cs`:
- Line 171: Method `FetchCandidateData(string mode, string nameFilter, string genderFilter, string candidateId)` executes genuine ADO.NET query against `dbo.CandidateProfiles`.
- Lines 176, 217, 235: Resources wrapped in nested `using (SqlConnection ...)`, `using (SqlCommand ...)`, `using (SqlDataAdapter ...)`.
- Lines 221, 227, 231: Parameterized queries using `cmd.Parameters.AddWithValue` for `@candId`, `@fname`, `@gender`.
- Zero hardcoded profile lists, zero mock return stubs, zero `NotImplementedException`.

### 1.6 Schema Validation
`App_Code/CandidateDataSet.xsd`:
- Parsed and compiled via `System.Xml.Schema.XmlSchemaSet`. Valid schema.
- Element `PhotoData` has attribute `type="xs:base64Binary"`.
- When read via `DataSet.ReadXmlSchema()`, `Candidate.PhotoData` column data type is `System.Byte[]`.

### 1.7 Independent Compilation
`C:\Windows\Microsoft.NET\Framework64\v4.0.30319\aspnet_compiler.exe -v / -p "..."` executed independently:
- Exit Code: `0`
- Zero compilation errors.

### 1.8 Adversarial Challenge Results
- **SQL Injection Payload**: Tested parameter `@fname = "' OR '1'='1"`. Result: Exactly 0 rows returned. No data leakage or SQL syntax malfunction.
- **Non-existent Candidate Filter**: Tested parameter `@candId = 999999`. Result: Exactly 0 rows returned with table schema intact.
- **Empty Filter**: Executed query with no filters. Result: Exactly 5 candidate records returned.

---

## 2. Logic Chain

1. **Premise 1 (Database Reality)**: Observation 1.1 and 1.2 prove that `dbo.CandidateProfiles` is a genuine physical table with 16 columns in local SQL Server `ProjectManagementDB`. It is not a simulated or in-memory stub.
2. **Premise 2 (Data Quality & Indian Context)**: Observation 1.3 proves that the table stores 5 realistic Indian profiles (names, locations, contact info) fulfilling User Global Rule 5.
3. **Premise 3 (Binary BLOB Authenticity)**: Observation 1.4 proves that `PhotoData` BLOBs contain authentic PNG magic headers (`89 50 4E 47 0D 0A 1A 0A`), correct IHDR chunk geometry (240x240 pixels), decode cleanly in .NET GDI+, and match on-disk image assets byte-for-byte.
4. **Premise 4 (Absence of Deception/Facades)**: Observation 1.5, 1.6, and 1.7 confirm that the application code queries SQL Server directly using parameterized commands, avoids hardcoded arrays, and compiles cleanly with `aspnet_compiler.exe`. Observation 1.8 proves the database query logic is resilient against SQL injection and boundary conditions.
5. **Conclusion**: Because every check in the Integrity Forensics suite passed empirically with zero integrity violations and zero fabricated outputs, the work product for Milestone 1 is verified authentic and clean.

---

## 3. Caveats

- Milestone 1 covers Data Architecture and Image BLOBs. Crystal Reports rendering via `BlobFieldObject` and web browser interface controls will be audited in subsequent milestones (M2 and M3).
- The test harness was run against local SQL Server instance using Windows authentication and `sa` credentials specified in `Web.config`.

---

## 4. Conclusion

**Verdict: CLEAN**

Milestone 1 satisfies all integrity criteria and implementation specifications:
- Database connectivity and table structure are genuine and fully operational.
- Dual storage of images on disk and in SQL Server `varbinary(max)` is 100% byte-for-byte identical.
- In-memory `CandidateDataSet.xsd` accurately represents binary BLOBs as `System.Byte[]`.
- ADO.NET patterns in code-behind prevent connection leaks and SQL injection.
- Zero emojis found across the repository.

---

## 5. Verification Method

To independently re-run the complete forensic verification suite, execute:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "d:\.NET\.agents\teamwork\auditor_m1_1\forensic_audit.ps1"
```

### Invalidation Conditions
- Any failure to connect to SQL Server via `conStr`.
- Any mismatch in the 16 columns of `dbo.CandidateProfiles`.
- Any corruption or alteration of the 8-byte PNG header in `PhotoData` BLOBs.
- Non-zero exit code from `aspnet_compiler.exe`.
- Introduction of any emoji characters into source code, markup, or markdown reports.
