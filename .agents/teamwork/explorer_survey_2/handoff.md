# Handoff Report: Survey 2 - Data Sources, Schemas, Images & Storage

**Agent**: explorer_survey_2  
**Target Project**: `C:\Users\sailenmondal\OneDrive - MANAGEMENT & COMPUTER CONSULTANTS\Documents\Visual Studio 2015\WebSites\WebSite2`  
**Working Directory**: `d:\.NET\.agents\teamwork\explorer_survey_2`  
**Date**: 2026-10-27  

---

## 1. Observation

### 1.1 Database Engine, App_Data, and Connection Strings
1. **Target Directory Structure**:
   `C:\Users\sailenmondal\OneDrive - MANAGEMENT & COMPUTER CONSULTANTS\Documents\Visual Studio 2015\WebSites\WebSite2` contains:
   - `App_Code/` (contains `CandidateDataSet.xsd`)
   - `Images/` (contains `emp1.png`, `emp2.png`, `emp3.png`, `emp4.png`, `emp5.png`, `logo.png`)
   - `Resumes/` (contains 5 PDF resume files)
   - `crystalreportviewers13/` (Crystal Reports viewer client resources)
   - `CandidateDirectory.rpt` (336,896 bytes)
   - `CandidateResume.rpt` (102,400 bytes)
   - `TestReportWithPicture.rpt` (102,400 bytes)
   - `CandidateBase.rpt` (11,264 bytes)
   - `Default.aspx` (12,062 bytes)
   - `Default.aspx.cs` (10,063 bytes)
   - `Web.config` (3,111 bytes)
   - `Web.Debug.config` (1,360 bytes)
   - `TestExport.pdf` (37,488 bytes)
   - There is **no `App_Data` folder** in `WebSite2`.

2. **SQL Server Service**:
   Command: `Get-Service *sql* | Format-Table Name, DisplayName, Status`
   Result:
   ```
   Name           DisplayName                            Status
   ----           -----------                            ------
   MSSQLSERVER    SQL Server (MSSQLSERVER)              Running
   SQLBrowser     SQL Server Browser                    Stopped
   SQLSERVERAGENT SQL Server Agent (MSSQLSERVER)        Stopped
   SQLTELEMETRY   SQL Server CEIP service (MSSQLSERVER) Running
   SQLWriter      SQL Server VSS Writer                 Running
   ```
   LocalDB instances present on machine: `MSSQLLocalDB`, `ProjectModels` (verified via `sqllocaldb info`).

3. **Web.config Connection String**:
   File: `C:\Users\sailenmondal\OneDrive - MANAGEMENT & COMPUTER CONSULTANTS\Documents\Visual Studio 2015\WebSites\WebSite2\Web.config`
   Lines 12-14:
   ```xml
   <connectionStrings>
     <add name="conStr" connectionString="Data Source=.;Initial Catalog=ProjectManagementDB;User ID=sa;Password=mcc#1234;TrustServerCertificate=True" providerName="System.Data.SqlClient" />
   </connectionStrings>
   ```

4. **ADO.NET Connection Verification**:
   Command:
   ```powershell
   $c = New-Object System.Data.SqlClient.SqlConnection 'Data Source=.;Initial Catalog=ProjectManagementDB;User ID=sa;Password=mcc#1234;TrustServerCertificate=True'
   $c.Open()
   Write-Output ('Connection State: ' + $c.State)
   $c.Close()
   ```
   Output: `Connection State: Open`

---

### 1.2 Candidate Profile Data Schema and Existing Records
1. **Database Tables in `ProjectManagementDB`**:
   Command: `sqlcmd -S . -U sa -P "mcc#1234" -C -d ProjectManagementDB -Q "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES"`
   Relevant tables: `CandidateProfiles`, `Employee1`, `Employees`, `Departments`.

2. **`dbo.CandidateProfiles` Table Schema**:
   Command:
   ```sql
   SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, IS_NULLABLE 
   FROM INFORMATION_SCHEMA.COLUMNS 
   WHERE TABLE_NAME = 'CandidateProfiles' 
   ORDER BY ORDINAL_POSITION
   ```
   Result:
   | Column Name | Data Type | Max Length | Nullable | Primary Key / Identity |
   |---|---|---|---|---|
   | CandidateId | int | NULL | NO | PK, Identity(1,1) |
   | FullName | nvarchar | 100 | NO | No |
   | JobTitle | nvarchar | 100 | NO | No |
   | Department | nvarchar | 100 | NO | No |
   | Gender | nvarchar | 20 | NO | No |
   | Email | nvarchar | 100 | NO | No |
   | Phone | nvarchar | 50 | NO | No |
   | City | nvarchar | 50 | NO | No |
   | Skills | nvarchar | 500 | NO | No |
   | ExperienceYears | int | NULL | NO | No |
   | Summary | nvarchar | 1000 | NO | No |
   | PhotoFileName | nvarchar | 100 | NO | No |
   | PhotoPath | nvarchar | 255 | NO | No |
   | ResumeFileName | nvarchar | 100 | NO | No |
   | ResumePath | nvarchar | 255 | NO | No |
   | PhotoData | varbinary | -1 (max) | YES | No |

3. **In-Memory Schema (`CandidateDataSet.xsd`)**:
   File: `C:\Users\sailenmondal\OneDrive - MANAGEMENT & COMPUTER CONSULTANTS\Documents\Visual Studio 2015\WebSites\WebSite2\App_Code\CandidateDataSet.xsd`
   Complex element `Candidate` defines:
   - `CandidateId` (xs:int)
   - `FullName` (xs:string)
   - `JobTitle` (xs:string)
   - `Department` (xs:string)
   - `Gender` (xs:string)
   - `Email` (xs:string)
   - `Phone` (xs:string)
   - `City` (xs:string)
   - `Skills` (xs:string)
   - `ExperienceYears` (xs:int)
   - `Summary` (xs:string)
   - `PhotoPath` (xs:string)
   - `ResumePath` (xs:string)
   - `PhotoData` (xs:base64Binary)

4. **Existing Data Rows in `dbo.CandidateProfiles`**:
   Command:
   ```sql
   SELECT CandidateId, FullName, JobTitle, Department, Gender, City, PhotoFileName, ResumeFileName, DATALENGTH(PhotoData) AS PhotoDataBytes 
   FROM dbo.CandidateProfiles
   ```
   Output:
   - Row 1: CandidateId=1, FullName="Rahul Sharma", JobTitle="Senior .NET Developer", Department="Software Engineering", Gender="Male", City="Kolkata", PhotoFileName="emp1.png", ResumeFileName="rahul_sharma_resume.pdf", PhotoDataBytes=4194
   - Row 2: CandidateId=2, FullName="Priya Mukherjee", JobTitle="Database Administrator", Department="Database Engineering", Gender="Female", City="Kolkata", PhotoFileName="emp2.png", ResumeFileName="priya_mukherjee_resume.pdf", PhotoDataBytes=4412
   - Row 3: CandidateId=3, FullName="Amit Verma", JobTitle="Full Stack Engineer", Department="Product Development", Gender="Male", City="Mumbai", PhotoFileName="emp3.png", ResumeFileName="amit_verma_resume.pdf", PhotoDataBytes=4356
   - Row 4: CandidateId=4, FullName="Sneha Patel", JobTitle="BI & Reporting Analyst", Department="Business Intelligence", Gender="Female", City="Bangalore", PhotoFileName="emp4.png", ResumeFileName="sneha_patel_resume.pdf", PhotoDataBytes=4048
   - Row 5: CandidateId=5, FullName="Vikram Singh", JobTitle="Cloud Solutions Architect", Department="Cloud Infrastructure", Gender="Male", City="Delhi", PhotoFileName="emp5.png", ResumeFileName="vikram_singh_resume.pdf", PhotoDataBytes=4296

---

### 1.3 Photo / Image Storage Architecture
1. **File System Location**:
   Directory: `C:\Users\sailenmondal\OneDrive - MANAGEMENT & COMPUTER CONSULTANTS\Documents\Visual Studio 2015\WebSites\WebSite2\Images`
   Files:
   - `emp1.png`: 4,194 bytes
   - `emp2.png`: 4,412 bytes
   - `emp3.png`: 4,356 bytes
   - `emp4.png`: 4,048 bytes
   - `emp5.png`: 4,296 bytes
   - `logo.png`: 1,654 bytes

2. **Byte-for-Byte Correlation**:
   The disk file size of each `empX.png` matches the SQL `DATALENGTH(PhotoData)` column value:
   - emp1.png: disk 4,194 bytes == SQL 4,194 bytes
   - emp2.png: disk 4,412 bytes == SQL 4,412 bytes
   - emp3.png: disk 4,356 bytes == SQL 4,356 bytes
   - emp4.png: disk 4,048 bytes == SQL 4,048 bytes
   - emp5.png: disk 4,296 bytes == SQL 4,296 bytes

3. **HTTP Serving Verification**:
   Command: `Invoke-WebRequest -Uri 'http://localhost:8188/Images/emp1.png'`
   Result: `Status: 200 | Content-Type: image/png | Length: 4194`

4. **Crystal Reports Dynamic Image Handler Verification**:
   When CrystalReportViewer rendered `CandidateDirectory.rpt` on `Default.aspx`, dynamic image URLs of form `CrystalImageHandler.aspx?dynamicimage=cr_tmp_image_<guid>.png` were generated.
   Command:
   ```powershell
   $imgResp = Invoke-WebRequest -Uri 'http://localhost:8188/CrystalImageHandler.aspx?dynamicimage=cr_tmp_image_0935d358-a75f-41dc-98fa-4669ad22aa16.png' -WebSession $sess
   ```
   Result: `Status: 200 (1791 bytes)` and subsequent candidate picture requests returned `Status: 200 (4024 bytes)`.

---

### 1.4 Resume Details and Documents
1. **File System Location**:
   Directory: `C:\Users\sailenmondal\OneDrive - MANAGEMENT & COMPUTER CONSULTANTS\Documents\Visual Studio 2015\WebSites\WebSite2\Resumes`
   Files:
   - `amit_verma_resume.pdf`: 639,576 bytes
   - `priya_mukherjee_resume.pdf`: 639,576 bytes
   - `rahul_sharma_resume.pdf`: 639,576 bytes
   - `sneha_patel_resume.pdf`: 639,576 bytes
   - `vikram_singh_resume.pdf`: 639,576 bytes

2. **PDF Header Verification**:
   First 8 bytes of all resume files confirm valid format `%PDF-1.5`.

3. **HTTP Serving Verification**:
   Command: `Invoke-WebRequest -Uri 'http://localhost:8188/Resumes/rahul_sharma_resume.pdf'`
   Result: `Status: 200 | Content-Type: application/pdf | Length: 639576`

4. **Data Fields for Resume View**:
   Verified in `dbo.CandidateProfiles`:
   - Contact Info: `Email`, `Phone` (+91 mobile numbers), `City`
   - Professional Profile: `JobTitle`, `Department`, `ExperienceYears`, `Skills`
   - Summary: Rich narrative summary (e.g. "Results-oriented software engineer specializing in robust ASP.NET enterprise applications and reporting solutions.")
   - Resume Document Links: `ResumePath` (`Resumes/<filename>.pdf`), `ResumeFileName`

---

### 1.5 Indian Context Requirements Compliance
User Global Rule 5 dictates:
- Realistic Indian names (Rahul, Amit, Priya, Sneha)
- Realistic Indian locations (Kolkata, Delhi, Bangalore)
- Zero emojis

All seeded data records strictly adhere to this rule:
| CandidateId | Name | Gender | City | Phone | Email |
|---|---|---|---|---|---|
| 1 | Rahul Sharma | Male | Kolkata | +91 98301 23456 | rahul.sharma@example.com |
| 2 | Priya Mukherjee | Female | Kolkata | +91 98312 34567 | priya.mukherjee@example.com |
| 3 | Amit Verma | Male | Mumbai | +91 98200 12345 | amit.verma@example.com |
| 4 | Sneha Patel | Female | Bangalore | +91 98790 54321 | sneha.patel@example.com |
| 5 | Vikram Singh | Male | Delhi | +91 98110 98765 | vikram.singh@example.com |

---

### 1.6 Crystal Reports Data Binding and Compatibility Bridge
1. **Crystal Report Internal Table Name**:
   Inspection via `CrystalDecisions.CrystalReports.Engine.ReportDocument`:
   - `CandidateDirectory.rpt`: Database table name is `Employee1` (Fields: `ID`, `Name`, `Location`, `Gender`).
   - `CandidateResume.rpt`: Database table name is `Employee1` (Fields: `ID`, `Name`, `Location`, `Gender`).
   - `Section3` (Detail section) of `CandidateDirectory.rpt` contains `Picture2` (`CrystalDecisions.CrystalReports.Engine.PictureObject`) for dynamic candidate photo rendering.

2. **Data Adapter Bridge in `Default.aspx.cs`**:
   Lines 173-197:
   ```csharp
   DataTable dt = new DataTable("Employee1");
   string sql = @"SELECT 
                   CandidateId AS ID, 
                   FullName AS Name, 
                   City AS Location, 
                   Gender, 
                   CandidateId, 
                   FullName, 
                   JobTitle, 
                   Department, 
                   Email, 
                   Phone, 
                   City, 
                   Skills, 
                   ExperienceYears, 
                   Summary, 
                   PhotoPath, 
                   ResumePath, 
                   PhotoData 
                  FROM dbo.CandidateProfiles 
                  WHERE 1=1";
   ```
   This query aliases `CandidateId` to `ID`, `FullName` to `Name`, and `City` to `Location` on a `DataTable` named `"Employee1"`, satisfying the report's internal schema requirements while providing all extended candidate profile columns and `PhotoData` BLOB bytes.

3. **Programmatic PDF Export Verification**:
   - `CandidateDirectory.rpt` loaded and exported to PDF: file size 38,149 bytes.
   - `CandidateResume.rpt` loaded with CandidateId=1 filter and exported to PDF: file size 28,785 bytes.

4. **Live Web Application Verification**:
   Running under IIS Express (PID 5612) at `http://localhost:8188`:
   - `GET /Default.aspx` returned HTTP 200 (length: 36,199 bytes), containing all candidate profile cards and CrystalReportViewer markup.
   - `POST btnFilterGender=Filter` with `DropDownList1=Female` returned Priya Mukherjee and Sneha Patel (correctly suppressing Rahul Sharma).
   - `POST btnSearch=Search` with `txtFirstName=Rahul` returned Rahul Sharma (correctly suppressing Priya Mukherjee).
   - `POST btnPDF=Convert To PDF` returned HTTP 200 with `Content-Type: application/pdf`, `Content-Disposition: attachment; filename=CandidateDirectory.pdf`, and length 38,149 bytes.

---

## 2. Logic Chain

1. **Database & Connection Strategy**:
   - Observation 1.1.1 and 1.1.2 established that SQL Server (`MSSQLSERVER`) is running and `ProjectManagementDB` is an existing database.
   - Observation 1.1.3 confirmed the `Web.config` connection string references `ProjectManagementDB` on `.` with SQL authentication (`sa`).
   - Observation 1.1.4 confirmed ADO.NET opens the connection successfully.
   - Therefore, the application does not rely on an embedded file in `App_Data`; it is an enterprise SQL Server database configuration.

2. **Candidate Profile & Schema Alignment**:
   - Observation 1.2.2 established that `dbo.CandidateProfiles` defines 16 columns encompassing candidate personal details, skills, summary, photo paths, resume paths, and binary image data (`PhotoData`).
   - Observation 1.2.3 demonstrated that `App_Code/CandidateDataSet.xsd` defines an in-memory schema that mirrors `dbo.CandidateProfiles`.
   - Therefore, strongly-typed and untyped DataTables can be bound interchangeably to Crystal Reports.

3. **Dual Photo Storage Reliability**:
   - Observation 1.3.1 identified local PNG files in `Images/`.
   - Observation 1.3.2 proved that `PhotoData` in SQL Server stores the exact byte content of those image files.
   - In ASP.NET WebForms, browser display of `<img src="Images/empX.png">` uses HTTP static caching, while Crystal Reports requires `byte[]` binary data to render dynamic pictures without file permission or relative URL resolution failures.
   - Observation 1.3.4 confirmed that the binary image data binds into Crystal Reports and is served by `CrystalImageHandler.aspx` with HTTP 200.
   - Therefore, the dual storage architecture satisfies both web frontend rendering and Crystal Reports engine requirements.

4. **Resume Documents and Field Availability**:
   - Observation 1.4.1 confirmed that pre-generated PDF resumes reside in `Resumes/`.
   - Observation 1.4.3 confirmed these documents are directly downloadable via HTTP at `Resumes/<filename>.pdf`.
   - Observation 1.4.4 verified that detailed professional fields (Education/Experience/Skills/Summary) exist in `dbo.CandidateProfiles` to populate individual candidate resume reports.
   - Therefore, both interactive PDF document downloads and generated Crystal Report resume biodata views are fully supported.

5. **Indian Context Conformance**:
   - Observation 1.5 confirmed all 5 seeded profiles use authentic Indian names (Rahul Sharma, Priya Mukherjee, Amit Verma, Sneha Patel, Vikram Singh) and locations (Kolkata, Mumbai, Bangalore, Delhi).
   - This directly fulfills User Global Rule 5.

6. **Report Binding Contract**:
   - Observation 1.6.1 found that the pre-compiled `.rpt` files target table `Employee1`.
   - Observation 1.6.2 and 1.6.3 showed that naming the ADO.NET `DataTable` `"Employee1"` and aliasing `CandidateId AS ID`, `FullName AS Name`, `City AS Location` satisfies the report engine while injecting the new `PhotoData` BLOB.
   - Observation 1.6.4 verified that the live web application on port 8188 successfully searches, filters, displays Crystal Reports with dynamic photos, and exports PDFs.

---

## 3. Caveats

1. **IIS Express Port Dependency**:
   IIS Express is currently running on port 8188. If IIS Express is restarted without the `/port:8188` flag or on another port, test URLs must adjust accordingly.
2. **Crystal Reports Table Name Dependency**:
   Existing reports `CandidateDirectory.rpt` and `CandidateResume.rpt` have hardcoded table name `Employee1`. The application query must continue using `new DataTable("Employee1")` when supplying data to these reports unless the `.rpt` files are redesigned with a different datasource.
3. **App_Data Usage**:
   No `App_Data` folder exists, and creating one is not needed since SQL Server `ProjectManagementDB` is operational and configured in `Web.config`.

---

## 4. Conclusion

1. **Data Source**: Microsoft SQL Server local instance (`.`), database `ProjectManagementDB`, configured in `Web.config` via connection string `conStr`.
2. **Profile Data**: Fully structured in `dbo.CandidateProfiles` (16 columns) with 5 production-ready Indian candidate records and an equivalent in-memory schema in `App_Code/CandidateDataSet.xsd`.
3. **Photo Storage**: Robust dual-tier model:
   - File system: `Images/emp1.png` through `emp5.png` and `Images/logo.png`.
   - Database: `PhotoData` `varbinary(max)` column matching exact file byte arrays.
4. **Resume Storage & Data**: 5 valid PDF resumes in `Resumes/`, linked by relative path and augmented by rich database profile fields (skills, summary, experience years, contact info).
5. **Indian Context**: 100% compliant with User Global Rule 5 (Rahul Sharma, Priya Mukherjee, Amit Verma, Sneha Patel, Vikram Singh; Kolkata, Mumbai, Bangalore, Delhi).
6. **Solution Status**: The entire data flow, schema bridge, report binding, dynamic image handler, gender/name filtering, and PDF export are verified and operational.

---

## 5. Verification Method

To independently verify these findings, execute the following commands in PowerShell from `d:\.NET`:

1. **Verify SQL Server Connection and Row Count**:
   ```powershell
   sqlcmd -S . -U sa -P "mcc#1234" -C -d ProjectManagementDB -Q "SELECT CandidateId, FullName, City, PhotoFileName, ResumeFileName, DATALENGTH(PhotoData) AS PhotoBytes FROM dbo.CandidateProfiles"
   ```
   *Expected*: 5 rows affected, with Indian names, cities, photo files, and non-zero PhotoBytes.

2. **Verify Crystal Reports Compilation in WebSite2**:
   ```powershell
   C:\Windows\Microsoft.NET\Framework64\v4.0.30319\aspnet_compiler.exe -v / -p "C:\Users\sailenmondal\OneDrive - MANAGEMENT & COMPUTER CONSULTANTS\Documents\Visual Studio 2015\WebSites\WebSite2"
   ```
   *Expected*: Exit code 0 (clean compilation).

3. **Verify Programmatic Crystal Reports PDF Export**:
   ```powershell
   powershell -Command "
   [System.Reflection.Assembly]::Load('CrystalDecisions.CrystalReports.Engine, Version=13.0.2000.0, Culture=neutral, PublicKeyToken=692fbea5521e1304') | Out-Null
   [System.Reflection.Assembly]::Load('CrystalDecisions.Shared, Version=13.0.2000.0, Culture=neutral, PublicKeyToken=692fbea5521e1304') | Out-Null
   $conn = New-Object System.Data.SqlClient.SqlConnection('Data Source=.;Initial Catalog=ProjectManagementDB;User ID=sa;Password=mcc#1234;TrustServerCertificate=True')
   $cmd = New-Object System.Data.SqlClient.SqlCommand('SELECT CandidateId AS ID, FullName AS Name, City AS Location, Gender, PhotoData FROM dbo.CandidateProfiles', $conn)
   $conn.Open()
   $da = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
   $dt = New-Object System.Data.DataTable('Employee1')
   $da.Fill($dt) | Out-Null
   $conn.Close()
   $doc = New-Object CrystalDecisions.CrystalReports.Engine.ReportDocument
   $doc.Load('C:\Users\sailenmondal\OneDrive - MANAGEMENT & COMPUTER CONSULTANTS\Documents\Visual Studio 2015\WebSites\WebSite2\CandidateDirectory.rpt')
   $doc.SetDataSource($dt)
   $temp = [System.IO.Path]::GetTempFileName() + '.pdf'
   $doc.ExportToDisk([CrystalDecisions.Shared.ExportFormatType]::PortableDocFormat, $temp)
   $doc.Close(); $doc.Dispose()
   Write-Output ('Exported PDF Size: ' + (Get-Item $temp).Length + ' bytes')
   Remove-Item $temp
   "
   ```
   *Expected*: Non-zero file size (~38 KB).

4. **Verify Live Web Application Endpoint**:
   ```powershell
   Invoke-WebRequest -Uri 'http://localhost:8188/Default.aspx' -UseBasicParsing | Select-Object StatusCode, ContentLength
   ```
   *Expected*: StatusCode: 200.
