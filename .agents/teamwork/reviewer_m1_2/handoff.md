# Reviewer 2 Report: Milestone 1 - Data Architecture & Image BLOBs

- **Reviewer**: Reviewer 2 (Roles: reviewer, critic)
- **Target Project**: `C:\Users\sailenmondal\OneDrive - MANAGEMENT & COMPUTER CONSULTANTS\Documents\Visual Studio 2015\WebSites\WebSite2`
- **Working Directory**: `d:\.NET\.agents\teamwork\reviewer_m1_2`
- **Verdict**: **APPROVE**
- **Date**: 2026-10-27

---

## 1. Observation

### 1.1 Database Connectivity and Web.config Configuration
- File: `C:\Users\sailenmondal\OneDrive - MANAGEMENT & COMPUTER CONSULTANTS\Documents\Visual Studio 2015\WebSites\WebSite2\Web.config` (lines 12-14)
  ```xml
  <connectionStrings>
    <add name="conStr" connectionString="Data Source=.;Initial Catalog=ProjectManagementDB;User ID=sa;Password=mcc#1234;TrustServerCertificate=True" providerName="System.Data.SqlClient" />
  </connectionStrings>
  ```
- Command executed:
  ```powershell
  $conStr = "Data Source=.;Initial Catalog=ProjectManagementDB;User ID=sa;Password=mcc#1234;TrustServerCertificate=True"
  $conn = New-Object System.Data.SqlClient.SqlConnection($conStr)
  $conn.Open()
  ```
- Observed output:
  - Connection State: `Open`
  - Server Version: `15.00.2200` (Microsoft SQL Server 2019)
  - Database: `ProjectManagementDB`

### 1.2 Table Schema and Primary Key: dbo.CandidateProfiles
- Primary Key Constraint Query:
  ```sql
  SELECT tc.CONSTRAINT_NAME, kcu.COLUMN_NAME 
  FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
  JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu 
    ON tc.CONSTRAINT_NAME = kcu.CONSTRAINT_NAME 
  WHERE tc.TABLE_NAME = 'CandidateProfiles' AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
  ```
  - Result: `PK__Candidat__DF539B9CE7D65CF6` on column `CandidateId` (Identity(1,1), NOT NULL).
- Column Schema Query on `INFORMATION_SCHEMA.COLUMNS`:
  - Exactly 16 columns present:
    1. `CandidateId`: `int`, NOT NULL
    2. `FullName`: `nvarchar(100)`, NOT NULL
    3. `JobTitle`: `nvarchar(100)`, NOT NULL
    4. `Department`: `nvarchar(100)`, NOT NULL
    5. `Gender`: `nvarchar(20)`, NOT NULL
    6. `Email`: `nvarchar(100)`, NOT NULL
    7. `Phone`: `nvarchar(50)`, NOT NULL
    8. `City`: `nvarchar(50)`, NOT NULL
    9. `Skills`: `nvarchar(500)`, NOT NULL
    10. `ExperienceYears`: `int`, NOT NULL
    11. `Summary`: `nvarchar(1000)`, NOT NULL
    12. `PhotoFileName`: `nvarchar(100)`, NOT NULL
    13. `PhotoPath`: `nvarchar(255)`, NOT NULL
    14. `ResumeFileName`: `nvarchar(100)`, NOT NULL
    15. `ResumePath`: `nvarchar(255)`, NOT NULL
    16. `PhotoData`: `varbinary(-1)` (max), IS_NULLABLE = YES

### 1.3 Schema Comparison: dbo.CandidateProfiles vs App_Code/CandidateDataSet.xsd
- File: `C:\Users\sailenmondal\OneDrive - MANAGEMENT & COMPUTER CONSULTANTS\Documents\Visual Studio 2015\WebSites\WebSite2\App_Code\CandidateDataSet.xsd` (lines 15-34)
  - Elements defined: `CandidateId` (xs:int), `FullName` (xs:string), `JobTitle` (xs:string), `Department` (xs:string), `Gender` (xs:string), `Email` (xs:string), `Phone` (xs:string), `City` (xs:string), `Skills` (xs:string), `ExperienceYears` (xs:int), `Summary` (xs:string), `PhotoPath` (xs:string), `ResumePath` (xs:string), `PhotoData` (xs:base64Binary).
  - All elements specify `minOccurs="0"`.
  - Deserialization test via `DataSet.ReadXmlSchema`:
    - Table created: `"Candidate"`
    - Column `PhotoData` .NET DataType: `System.Byte[]`
- Differential analysis:
  - Database table `dbo.CandidateProfiles` includes internal storage columns `PhotoFileName` and `ResumeFileName`.
  - `CandidateDataSet.xsd` excludes `PhotoFileName` and `ResumeFileName`, aligning with Interface Contract 1 where the Reporting layer references `PhotoData` and `ResumePath`.
  - Table name in `CandidateDataSet.xsd` is `"Candidate"`, whereas `Default.aspx.cs` constructs `DataTable("Employee1")` to match existing `.rpt` table definitions.

### 1.4 Image BLOB Validity and Cryptographic SHA256 Verification
- Image files present in `Images/`:
  - `emp1.png` (4,194 bytes)
  - `emp2.png` (4,412 bytes)
  - `emp3.png` (4,356 bytes)
  - `emp4.png` (4,048 bytes)
  - `emp5.png` (4,296 bytes)
  - `logo.png` (1,654 bytes)
- Independent cryptographic SHA256 hashes computed on disk files and SQL `PhotoData` byte arrays:
  - Candidate 1 (`emp1.png`):
    - Disk SHA256: `C42435E9CA307534E87D418880F5F94B28F32C933DA1B7881B0CF4A2F82A0057`
    - SQL BLOB SHA256: `C42435E9CA307534E87D418880F5F94B28F32C933DA1B7881B0CF4A2F82A0057`
    - Match: EXACT MATCH (4,194 bytes)
  - Candidate 2 (`emp2.png`):
    - Disk SHA256: `255ACA11E37A124078CB5ADE0C47FD4A7636046953FFDBFC3CEC8699EBA3DEDF`
    - SQL BLOB SHA256: `255ACA11E37A124078CB5ADE0C47FD4A7636046953FFDBFC3CEC8699EBA3DEDF`
    - Match: EXACT MATCH (4,412 bytes)
  - Candidate 3 (`emp3.png`):
    - Disk SHA256: `7669F06E84A3888346764C8A3DD5B758715721F38C4AA2FA82128CE54F5AFE5F`
    - SQL BLOB SHA256: `7669F06E84A3888346764C8A3DD5B758715721F38C4AA2FA82128CE54F5AFE5F`
    - Match: EXACT MATCH (4,356 bytes)
  - Candidate 4 (`emp4.png`):
    - Disk SHA256: `9CED5B91D4C59A578FE99124D1A1649FE9E67917FEFA9A431CD628B38C943D39`
    - SQL BLOB SHA256: `9CED5B91D4C59A578FE99124D1A1649FE9E67917FEFA9A431CD628B38C943D39`
    - Match: EXACT MATCH (4,048 bytes)
  - Candidate 5 (`emp5.png`):
    - Disk SHA256: `705E321316E62E463EE0D8F2211F9062B32DB6A15302892B28020D998B0E8DD7`
    - SQL BLOB SHA256: `705E321316E62E463EE0D8F2211F9062B32DB6A15302892B28020D998B0E8DD7`
    - Match: EXACT MATCH (4,296 bytes)
- Image Decoding Verification:
  - All 5 BLOB byte streams were loaded into `System.Drawing.Image.FromStream()`.
  - Format: PNG (`[ImageFormat: b96b3caf-0728-11d3-9d7b-0000f81ef32e]`).
  - Dimensions: exactly `240x240` pixels.
  - PixelFormat: `Format32bppArgb`.
  - `logo.png` loaded via `System.Drawing.Image`: `280x80` pixels, 1,654 bytes.
  - All 5 resume files in `Resumes/` verified: valid `%PDF-` header, 639,576 bytes each.

### 1.5 ADO.NET Parameterization and SQL Injection Stress Testing
- Code Inspection in `Default.aspx.cs`:
  - `PopulateCandidateDropdown()` (lines 62-80): Static parameterized query, enclosed in nested `using` blocks (`SqlConnection`, `SqlCommand`, `SqlDataReader`).
  - `FetchCandidateData()` (lines 171-243): Dynamic WHERE clause assembly using parameterized command `@candId`, `@fname`, `@gender`.
- Adversarial SQL Injection Inputs Tested:
  - `@fname = "' OR '1'='1"` -> Returns 0 rows. Safe.
  - `@fname = "'; DROP TABLE dummy; --"` -> Returns 0 rows. Safe.
  - `@fname = "' UNION SELECT 1, 'a', ... --"` -> Returns 0 rows. Safe.
  - `@gender = "' OR '1'='1"` -> Returns 0 rows. Safe.
  - `@gender = "Male"` -> Returns 3 rows. Correct.
  - `@gender = "Female"` -> Returns 2 rows. Correct.
  - `@candId = "1"` -> Returns 1 row. Correct.
  - `@candId = "abc"` -> Throws `FormatException` in `Convert.ToInt32` before SQL command execution. Safe from injection.

### 1.6 Compilation and Live Execution Verification
- Compilation tool: `C:\Windows\Microsoft.NET\Framework64\v4.0.30319\aspnet_compiler.exe`
- Command: `aspnet_compiler.exe -v / -p "C:\Users\...\WebSite2"`
- Exit Code: `0` (Zero errors, zero warnings).
- Automated test script: `powershell -NoProfile -ExecutionPolicy Bypass -File "d:\.NET\scripts\verify_m1.ps1"`
- Execution result: 7/7 verification tasks passed.
- Live HTTP Request to `http://localhost:8188/Default.aspx`:
  - Request with browser `User-Agent`: HTTP 200, 36,197 bytes HTML returned, contains candidate profile names and `CrystalReportViewer`.

---

## 2. Logic Chain

1. **Database Foundation**:
   - Web.config line 13 provides the active connection string `conStr` pointing to `ProjectManagementDB` on local SQL Server.
   - Independent connection verification established an active connection to SQL Server 2019 (v15.00.2200).
   - Table `dbo.CandidateProfiles` contains all 16 designated columns with appropriate types and a primary key on `CandidateId`.
   - Therefore, the relational schema is properly structured and accessible.

2. **Indian Context & Seed Data**:
   - The 5 seed records represent authentic Indian profiles: Rahul Sharma (Kolkata), Priya Mukherjee (Kolkata), Amit Verma (Mumbai), Sneha Patel (Bangalore), Vikram Singh (Delhi).
   - There are zero emojis in the database, configuration, markup, or code.
   - Therefore, the dataset strictly complies with the project's realistic Indian context guidelines.

3. **BLOB Cryptography & Image Integrity**:
   - The SHA256 hashes of disk files `emp1.png` through `emp5.png` match the `PhotoData` BLOB columns in SQL Server byte-for-byte.
   - Decoding the raw BLOB bytes via .NET `System.Drawing.Image` confirms every candidate image is a valid, uncorrupted 240x240 32bpp PNG.
   - `CandidateDataSet.xsd` declares `PhotoData` as `xs:base64Binary`, deserializing to `System.Byte[]` in ADO.NET.
   - Therefore, the reporting engine can bind `PhotoData` directly in memory without relying on fragile relative disk paths.

4. **SQL Injection Defense & Resource Safety**:
   - `Default.aspx.cs` parameterizes all queries (`@candId`, `@fname`, `@gender`).
   - Adversarial testing with SQL injection payloads confirmed that malicious input is treated strictly as literal data.
   - All connection objects, commands, readers, and adapters are wrapped in `using` statements, preventing connection pool exhaustion.
   - Therefore, the data access layer is secure and follows ADO.NET best practices.

5. **Integrity Assessment**:
   - No hardcoded test responses or facade implementations were detected.
   - All verification queries and compilation tools operate directly on the real project assets and live database.
   - Therefore, the work product is genuine and free of integrity violations.

---

## 3. Caveats

1. **Crystal Reports User-Agent Requirement**:
   - Direct HTTP requests without a `User-Agent` header cause an internal `NullReferenceException` in `CrystalDecisions.Web.ViewerGlobal.get_IsSafari()`.
   - All test harnesses, automation scripts, and HTTP clients must supply a standard browser User-Agent header (e.g., Chrome or Edge).
2. **Table Name Bridge**:
   - `CandidateDataSet.xsd` defines table `"Candidate"`, whereas `Default.aspx.cs` constructs `DataTable("Employee1")` to align with the pre-existing Crystal Reports `.rpt` templates. In Milestone 2, if `.rpt` templates are re-linked to `CandidateDataSet.xsd`, ensure table naming is coordinated.
3. **Integer Parsing Robustness**:
   - In `Default.aspx.cs` line 221, `Convert.ToInt32(candidateId)` is used. If a non-integer value is injected via session manipulation, an unhandled `FormatException` is thrown. Adopting `int.TryParse` in Milestone 3 is recommended.

---

## 4. Conclusion

**Verdict**: **APPROVE**

Milestone 1 (Data Architecture & Image BLOBs) meets all architectural, functional, cryptographic, and security requirements.
- Database connectivity confirmed via `conStr`.
- 16-column `dbo.CandidateProfiles` table schema and primary key verified.
- 5 authentic Indian candidate profiles verified.
- Image BLOBs match disk files byte-for-byte (SHA256 verified) and decode into valid 240x240 PNGs.
- `CandidateDataSet.xsd` maps `PhotoData` to `System.Byte[]`.
- ADO.NET queries are parameterized and safe against SQL injection.
- Zero emojis across all artifacts.
- Zero compilation errors via `aspnet_compiler.exe`.

---

## 5. Verification Method

To independently reproduce this review, run the following commands in PowerShell:

1. **Full Milestone 1 Verification Suite**:
   ```powershell
   powershell -NoProfile -ExecutionPolicy Bypass -File "d:\.NET\scripts\verify_m1.ps1"
   ```

2. **Cryptographic, Schema, and SQL Injection Audit**:
   ```powershell
   powershell -NoProfile -ExecutionPolicy Bypass -File "d:\.NET\.agents\teamwork\reviewer_m1_2\deep_audit.ps1"
   ```

3. **Live Endpoint Test with Browser User-Agent**:
   ```powershell
   powershell -NoProfile -Command "& {
       $wc = New-Object System.Net.WebClient
       $wc.Headers.Add('User-Agent', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36')
       $html = $wc.DownloadString('http://localhost:8188/Default.aspx')
       Write-Output ('Status: OK, HTML Length: ' + $html.Length)
   }"
   ```

### Invalidation Conditions
- Modification of `conStr` in `Web.config` that disables connection to `ProjectManagementDB`.
- Dropping, altering, or renaming columns in `dbo.CandidateProfiles`.
- Updating disk image files without synchronizing SQL `PhotoData` bytes.
- Modifying queries to concatenate unparameterized user strings.
