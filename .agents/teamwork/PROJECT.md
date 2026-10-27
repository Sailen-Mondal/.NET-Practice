# Project: Resume and Image Show Crystal Reports Solution in WebSite2

## Architecture
WebSite2 is an ASP.NET Web Site Project (WSP) targeting .NET Framework 4.5.2, utilizing SAP Crystal Reports runtime v13.0.2000.0 (Service Pack 20) and Microsoft SQL Server (MSSQLSERVER).

### Core Architecture Layers
1. **Data Access Layer (ADO.NET)**:
   - SQL Server database: `ProjectManagementDB` via connection string `conStr`.
   - Table: `dbo.CandidateProfiles` (16 columns including `CandidateId`, `FullName`, `JobTitle`, `Department`, `Gender`, `City`, `Skills`, `ExperienceYears`, `Summary`, `PhotoPath`, `ResumePath`, `PhotoData` varbinary(max)).
   - In-memory schema: `App_Code/CandidateDataSet.xsd` (with `type="xs:base64Binary"` for `PhotoData`).
   - Schema Bridge: ADO.NET query mapping `CandidateId AS ID`, `FullName AS Name`, `City AS Location` to `DataTable("Employee1")` for compatibility with `.rpt` data sources.
2. **Reporting Layer (SAP Crystal Reports)**:
   - Dynamic profile image rendering via `BlobFieldObject` bound to `PhotoData` byte array in memory, completely avoiding IIS file permission and Graphic Location path issues.
   - Dynamic image delivery via `CrystalImageHandler.aspx` (registered in classic and integrated pipeline modes).
   - `CandidateDirectory.rpt`: Tabular multi-candidate directory roster with 1-inch thumbnail, candidate details, skills, and resume link.
   - `CandidateResume.rpt`: 1-page individual candidate profile dossier with 1.8-inch photo, executive bio, detailed skills breakdown, experience, and contact card.
3. **Presentation Layer (ASP.NET WebForms)**:
   - UI (`Default.aspx`): Notion-like minimalist aesthetic (neutral `#F9FAFB` background, `#FFFFFF` cards, `1px solid #E5E7EB` borders, `#111827` primary text, clean sans-serif typography, zero emojis).
   - Standard control naming: `txtSearch`, `ddlGender`, `ddlViewMode`, `ddlCandidate`, `btnSearch`, `btnReset`, `btnExportPdf`, `btnPrint`, `crvReport`.
   - Lifecycle (`Default.aspx.cs`): Session-based DataTable caching, `Page_Init` report document instantiation and binding for seamless viewer postbacks (paging, zooming), `Page_Unload` unmanaged handle disposal (`Close()` and `Dispose()`).
   - Export: `ExportToStream(ExportFormatType.PortableDocFormat)` with `CompleteRequest()` preventing `ThreadAbortException`.
   - Printing: Dual support via `PrintMode="Pdf"` on CrystalReportViewer and client-side `@media print` CSS.
4. **Testing Track (Opaque-Box E2E)**:
   - Independent test harness exercising the live endpoint `http://localhost:8188/Default.aspx`.
   - Testing 4 systematic tiers: Feature Coverage (Tier 1), Boundary & Corner Cases (Tier 2), Cross-Feature Combinations (Tier 3), Real-World Scenarios (Tier 4).
   - Phase 2 Adversarial Coverage Hardening (Tier 5).

---

## Feature Inventory
| # | Feature | Description | Milestone | Source |
|---|---------|-------------|-----------|--------|
| 1 | Candidate Database & Schema | SQL Server `dbo.CandidateProfiles` table with 16 columns, safe ADO.NET query with `using` blocks. | M1 | Survey 2 |
| 2 | Indian Mock Data Profiles | 5 production-ready candidate profiles adhering strictly to Indian context rules (Rahul, Priya, Amit, Sneha, Vikram; Kolkata, Mumbai, Bangalore, Delhi). | M1 | Survey 2 |
| 3 | Dual Photo Storage & BLOBs | Image files in `Images/` (emp1.png to emp5.png, logo.png) synchronized with `PhotoData` `varbinary(max)` BLOB bytes in SQL. | M1 | Survey 2 |
| 4 | Typed DataSet Schema | `App_Code/CandidateDataSet.xsd` defining in-memory candidate DataTable with `xs:base64Binary` for `PhotoData`. | M1 | Survey 1, 3 |
| 5 | Candidate Directory Report | `CandidateDirectory.rpt` displaying candidate roster with dynamic thumbnail photo, details, skills, and resume link. | M2 | Survey 1, 3, R1 |
| 6 | Candidate Resume Report | `CandidateResume.rpt` displaying comprehensive 1-page candidate CV dossier with large photo, bio, skills, and contact. | M2 | Survey 1, 3, R1 |
| 7 | Dynamic Image BLOB Rendering | Crystal Reports `BlobFieldObject` dynamic image rendering served via `CrystalImageHandler.aspx`. | M2 | Survey 3, R1 |
| 8 | Notion-Style WebForms UI | `Default.aspx` styled with Notion-like clean aesthetic, neutral palette, clean typography, zero emojis. | M3 | Survey 3, R2 |
| 9 | Multi-Field Text Search | `txtSearch` and `btnSearch` filtering candidates across FullName, JobTitle, Department, Skills, City. | M3 | Survey 3, R2 |
| 10 | Gender Parameter Filter | `ddlGender` filtering candidates by All, Male, Female. | M3 | Survey 3, R2 |
| 11 | View Mode Selector | `ddlViewMode` switching between Candidate Directory roster and Individual Resume view. | M3 | Survey 3, R1, R2 |
| 12 | Candidate Selector Dropdown | `ddlCandidate` enabling direct selection of specific candidate in Resume view mode. | M3 | Survey 3 |
| 13 | Safe WebForms Lifecycle | `Page_Init` report document binding from Session-cached data; `Page_Unload` clean disposal. | M3 | Survey 3 |
| 14 | Zero-Exception PDF Export | `btnExportPdf` exporting report via `ExportToStream` with `CompleteRequest()`, downloading valid PDF. | M3 | Survey 3, R2 |
| 15 | Browser Client Printing | `btnPrint` and `CrystalReportViewer.PrintMode="Pdf"` with `@media print` CSS for clean vector printouts. | M3 | Survey 3, R2 |
| 16 | Resume Document Hyperlinks | Hyperlinks in report and UI navigating directly to `Resumes/<candidate>_resume.pdf`. | M3 | Survey 2, 3, R1 |
| 17 | E2E Test Suite (Tiers 1-4) | Comprehensive opaque-box test suite verifying all features, boundaries, combinations, and application scenarios. | E2E Track | Project Pattern |
| 18 | Adversarial Coverage Hardening | White-box stress testing and edge-case verification (Tier 5). | M4 Phase 2 | Project Pattern |

---

## Milestones
| # | Name | Scope | Dependencies | Status |
|---|------|-------|-------------|--------|
| E2E | E2E Testing Track | Design and implement automated opaque-box test suite (Tiers 1-4) and publish `TEST_READY.md`. | none | IN_PROGRESS |
| M1 | Data Architecture & Image BLOBs | Verify SQL table, connection string, Indian candidate seed data, image files, and `CandidateDataSet.xsd` BLOB binding. | none | IN_PROGRESS |
| M2 | Crystal Reports Templates & BLOBs | Verify and refine `CandidateDirectory.rpt` and `CandidateResume.rpt` layouts, dynamic BLOB image rendering, and schema compatibility. | M1 | PLANNED |
| M3 | WebForms UI & Lifecycle Handlers | Implement Notion-like UI in `Default.aspx` and code-behind in `Default.aspx.cs` (Search, Gender, ViewMode, PDF Export, Print, Lifecycle). | M1, M2 | PLANNED |
| M4 | Final Verification & Hardening | Phase 1: 100% pass of E2E Test Suite (Tiers 1-4). Phase 2: Tier 5 Adversarial Coverage Hardening. | E2E, M3 | PLANNED |

---

## Interface Contracts

### 1. Data Access Layer ↔ Reporting Layer
- **Input**: Query parameters (`searchKeyword`, `genderFilter`, `candidateIdFilter`).
- **Output**: `DataTable` named `"Employee1"` containing:
  - `ID` (int) [aliased from `CandidateId`]
  - `Name` (string) [aliased from `FullName`]
  - `Location` (string) [aliased from `City`]
  - `Gender` (string)
  - `CandidateId` (int)
  - `FullName` (string)
  - `JobTitle` (string)
  - `Department` (string)
  - `Email` (string)
  - `Phone` (string)
  - `City` (string)
  - `Skills` (string)
  - `ExperienceYears` (int)
  - `Summary` (string)
  - `PhotoPath` (string)
  - `ResumePath` (string)
  - `PhotoData` (byte[]) [raw PNG/JPG image binary]
- **Behavior**: If 0 rows match, returns empty `DataTable` with schema preserved. Never returns null.

### 2. Reporting Layer ↔ Presentation Layer (CrystalReportViewer)
- **Binding Event**: Must occur in `Page_Init` (or `Page_Load`) on every request (initial and postback).
- **Report Types**:
  - `CandidateDirectory.rpt`: Bound when `ddlViewMode.SelectedValue == "Summary"`.
  - `CandidateResume.rpt`: Bound when `ddlViewMode.SelectedValue == "Resume"`.
- **Resource Cleanup**: Active `ReportDocument` instance stored in request-scoped field, closed and disposed in `Page_Unload`.
- **Image URL**: Generated via `CrystalImageHandler.aspx?dynamicimage=...` returning HTTP 200 with MIME `image/png`.

### 3. Presentation Layer ↔ Export / Print
- **PDF Export**:
  - MIME: `application/pdf`
  - Header: `Content-Disposition: attachment; filename=<ReportName>.pdf`
  - Stream: Written directly to `Response.OutputStream`
  - Completion: `HttpContext.Current.ApplicationInstance.CompleteRequest()`
- **Print**:
  - Viewer: `PrintMode="Pdf"`
  - Client Button: `window.print()` with `@media print` CSS hiding navigation cards.

---

## Code Layout
Project root: `C:\Users\sailenmondal\OneDrive - MANAGEMENT & COMPUTER CONSULTANTS\Documents\Visual Studio 2015\WebSites\WebSite2\`
- `App_Code/CandidateDataSet.xsd`: Typed DataSet schema for candidate data and BLOB photos.
- `Images/`: Profile photo assets (`emp1.png` - `emp5.png`, `logo.png`).
- `Resumes/`: Candidate resume PDF documents (`*_resume.pdf`).
- `crystalreportviewers13/`: Crystal Reports static viewer client files.
- `CandidateDirectory.rpt`: Tabular candidate directory report template.
- `CandidateResume.rpt`: Individual candidate resume report template.
- `Default.aspx`: WebForms UI markup with Notion-like styling.
- `Default.aspx.cs`: WebForms code-behind logic.
- `Web.config`: ASP.NET configuration.
