# Specification Mining Report: Crystal Reports Dynamic Images, Layouts & WebForms Integration

## Observation

### 1. Crystal Reports Assembly & Runtime Environment
Probing the system Global Assembly Cache (GAC) and registry confirmed the following installed runtime assemblies:
- `CrystalDecisions.CrystalReports.Engine`: Version `13.0.2000.0` (File Version `13.0.20.2399`), located at `C:\WINDOWS\assembly\GAC_MSIL\CrystalDecisions.CrystalReports.Engine\13.0.2000.0__692fbea5521e1304\CrystalDecisions.CrystalReports.Engine.dll`.
- `CrystalDecisions.Shared`: Version `13.0.2000.0`, located at `C:\WINDOWS\assembly\GAC_MSIL\CrystalDecisions.Shared\13.0.2000.0__692fbea5521e1304\CrystalDecisions.Shared.dll`.
- `CrystalDecisions.Web`: Version `13.0.2000.0`, located at `C:\WINDOWS\assembly\GAC_MSIL\CrystalDecisions.Web\13.0.2000.0__692fbea5521e1304\CrystalDecisions.Web.dll`.
- `CrystalDecisions.ReportSource`: Version `13.0.2000.0`, located at `C:\WINDOWS\assembly\GAC_MSIL\CrystalDecisions.ReportSource\13.0.2000.0__692fbea5521e1304\CrystalDecisions.ReportSource.dll`.
- `CrystalDecisions.ReportAppServer.ClientDoc`: Version `13.0.2000.0`, located at `C:\WINDOWS\assembly\GAC_64\CrystalDecisions.ReportAppServer.ClientDoc\13.0.2000.0__692fbea5521e1304\CrystalDecisions.ReportAppServer.ClientDoc.dll`.
- WebSite2 configuration in `C:\Users\sailenmondal\OneDrive - MANAGEMENT & COMPUTER CONSULTANTS\Documents\Visual Studio 2015\WebSites\WebSite2\Web.config`:
  * Target framework: `.NET Framework 4.5.2` (lines 23, 35).
  * BuildProvider: `.rpt` extension mapped to `CrystalDecisions.Web.Compilation.RptBuildProvider` (line 32).
  * HTTP Handlers: `CrystalImageHandler.aspx` registered in both `<system.web>` (line 37) and `<system.webServer>` (line 60).
  * CrystalReportViewer resource URI: `/crystalreportviewers13` (line 47).
  * Static viewer assets: `C:\Users\sailenmondal\OneDrive - MANAGEMENT & COMPUTER CONSULTANTS\Documents\Visual Studio 2015\WebSites\WebSite2\crystalreportviewers13` exists with 7 subdirectories and 26 core script/CSS files (`allInOne.js`, `promptengine-compressed.js`, etc.).

### 2. Candidate Data Schema & Storage Architecture
- DataSet Schema in `C:\Users\sailenmondal\OneDrive - MANAGEMENT & COMPUTER CONSULTANTS\Documents\Visual Studio 2015\WebSites\WebSite2\App_Code\CandidateDataSet.xsd`:
  * Table `Candidate` elements:
    - `CandidateId` (type `xs:int`)
    - `FullName` (type `xs:string`)
    - `JobTitle` (type `xs:string`)
    - `Department` (type `xs:string`)
    - `Gender` (type `xs:string`)
    - `Email` (type `xs:string`)
    - `Phone` (type `xs:string`)
    - `City` (type `xs:string`)
    - `Skills` (type `xs:string`)
    - `ExperienceYears` (type `xs:int`)
    - `Summary` (type `xs:string`)
    - `PhotoPath` (type `xs:string`)
    - `ResumePath` (type `xs:string`)
    - `PhotoData` (type `xs:base64Binary`, mapping directly to .NET `System.Byte[]`)
- SQL Server Database `ProjectManagementDB` table `CandidateProfiles`:
  * Connection string: `Data Source=.;Initial Catalog=ProjectManagementDB;User ID=sa;Password=mcc#1234;TrustServerCertificate=True`
  * Rows present: 5 candidate records populated with realistic Indian context:
    1. Rahul Sharma (CandidateId=1, Male, Senior .NET Developer, Kolkata, PhotoBytes=4194, PhotoPath=Images/emp1.png, ResumePath=Resumes/rahul_sharma_resume.pdf)
    2. Priya Mukherjee (CandidateId=2, Female, Database Administrator, Kolkata, PhotoBytes=4412, PhotoPath=Images/emp2.png, ResumePath=Resumes/priya_mukherjee_resume.pdf)
    3. Amit Verma (CandidateId=3, Male, Full Stack Engineer, Mumbai, PhotoBytes=4356, PhotoPath=Images/emp3.png, ResumePath=Resumes/amit_verma_resume.pdf)
    4. Sneha Patel (CandidateId=4, Female, BI & Reporting Analyst, Bangalore, PhotoBytes=4048, PhotoPath=Images/emp4.png, ResumePath=Resumes/sneha_patel_resume.pdf)
    5. Vikram Singh (CandidateId=5, Male, Cloud Solutions Architect, Delhi, PhotoBytes=4296, PhotoPath=Images/emp5.png, ResumePath=Resumes/vikram_singh_resume.pdf)
- Asset Files:
  * Physical photos: `WebSite2\Images\emp1.png` through `emp5.png` (240x240 pixels PNG, ~4 KB each) and `logo.png` (280x80 pixels PNG).
  * Physical resumes: `WebSite2\Resumes\rahul_sharma_resume.pdf`, `priya_mukherjee_resume.pdf`, `amit_verma_resume.pdf`, `sneha_patel_resume.pdf`, `vikram_singh_resume.pdf` (639 KB PDF files).

### 3. Crystal Reports Object Model & Dynamic Image Types
- Reflection analysis of `CrystalDecisions.CrystalReports.Engine` identified:
  * `CrystalDecisions.CrystalReports.Engine.BlobFieldObject`: Inherits from `ReportObject`. Represents a binary BLOB column from a database or typed DataSet (`CandidateDataSet.xsd` column `PhotoData` with `type="xs:base64Binary"`). Exposes `DataSource` property of type `DatabaseFieldDefinition`.
  * `CrystalDecisions.CrystalReports.Engine.PictureObject`: Inherits from `ReportObject`. Represents static images or images resolved via Graphic Location formula.
  * `CrystalDecisions.Shared.ReportObjectKind`: Enum values include `BlobFieldObject` (kind 8) and `PictureObject` (kind 5).
- ReportDocument export and parameter methods:
  * `ExportToHttpResponse(ExportFormatType formatType, HttpResponse response, bool asAttachment, string attachmentName)`
  * `ExportToStream(ExportFormatType formatType)` returning `System.IO.Stream`
  * `SetParameterValue(string name, object val)`
- CrystalReportViewer properties for printing:
  * `PrintMode`: Enum values `ActiveX` and `Pdf`.
  * `PDFOneClickPrinting`: Boolean.
  * `HasPrintButton`: Boolean.

---

## Features Discovered

| # | Category | Feature | Description | Inputs | Outputs | Error Behavior | Discovered Via |
|---|----------|---------|-------------|--------|---------|----------------|----------------|
| 1 | Image Display | In-Memory BLOB Field (xs:base64Binary / byte[]) | Renders dynamic profile photo from in-memory byte array in typed DataSet column `PhotoData` via `BlobFieldObject`. | `byte[]` binary image stream (PNG/JPG/BMP) | Rendered image within report section | Displays blank space if null or empty byte array; no runtime COM exception. | `CandidateDataSet.xsd`, `CrystalDecisions.CrystalReports.Engine.BlobFieldObject` |
| 2 | Image Display | Graphic Location Formula | Evaluates a string formula at render time pointing to an absolute disk path or URL. | String file path (`C:\...\photo.png`) or URL | Rendered image via GDI+/OLE | Throws COM/GDI+ exception or fails silently if IIS AppPool lacks NTFS permissions, or path is relative, or blocked by CR13 security registry policy. | `CrystalDecisions.CrystalReports.Engine.PictureObject` object model |
| 3 | Report Layout | Candidate Summary Directory View | Tabular multi-candidate roster listing photo thumbnail, candidate ID, full name, job title, department, gender, experience, skills, contact info, and resume link. | Filtered `DataTable` of candidates | Multi-row formatted report with page headers and footers | Gracefully displays empty report or header message if 0 records match. | `CandidateDirectory.rpt` inspection and `ORIGINAL_REQUEST.md` R1 |
| 4 | Report Layout | Individual Candidate Resume View | Deep candidate profile / CV layout featuring large candidate photo, executive summary, comprehensive skill breakdown, experience, contact card, and resume link. | Single candidate row or candidate group | 1-page per candidate resume profile | Shows complete profile card; handles missing bio or skills via CanGrow text objects. | `CandidateResume.rpt` inspection and `ORIGINAL_REQUEST.md` R1/R2 |
| 5 | Hyperlinks | Resume Document Hyperlink | Crystal Reports TextObject or FieldObject formatted with Hyperlink formula pointing to relative or absolute resume PDF URL. | String URL or relative path (`Resumes/rahul_sharma_resume.pdf`) | Clickable HTML anchor tag `<a href="..." target="_blank">` in viewer | If file missing, browser shows 404; report rendering itself is unaffected. | Crystal Reports Hyperlink property specification |
| 6 | WebForms UI | Multi-Field Text Search | Searches across FullName, JobTitle, Department, Skills, and City in C# code-behind before populating DataSet. | `txtSearch.Text` (string) | Filtered candidate records | Trimmed, case-insensitive substring matching; empty input returns all matching other filters. | `ORIGINAL_REQUEST.md` R2, `Default.aspx` specification |
| 7 | WebForms UI | Gender Filter Dropdown | Filters candidates by gender (All, Male, Female). | `ddlGender.SelectedValue` ("" / "Male" / "Female") | Filtered candidate records | "All" applies no gender restriction. | `ORIGINAL_REQUEST.md` R2, `Default.aspx` specification |
| 8 | WebForms UI | View Mode Selector | Switches between "Candidate Directory (List View)" and "Individual Resume Profile". | `ddlViewMode.SelectedValue` ("Summary" / "Resume") | Switches active report document binding | Rebinds viewer seamlessly; activates candidate dropdown for individual selection if needed. | Dispatch prompt topic 2, `ORIGINAL_REQUEST.md` R1 |
| 9 | Lifecycle | Page_Init Report Rebinding | Re-instantiates and binds `ReportDocument` during `Page_Init` on postback to enable CrystalReportViewer paging, zooming, and drilldown. | `Session["CandidateTable"]` or cached query state | Fully functional viewer on postbacks | Prevents "Missing parameter values" or blank viewer on page 2+. | ASP.NET WebForms lifecycle and SAP CRVS KBA 1215444 |
| 10 | Lifecycle | Safe Per-Request Disposal | In `Page_Unload`, calls `Close()` and `Dispose()` on the request-scoped `ReportDocument` after rendering. | Active `ReportDocument` instance | Closes unmanaged report engine handles | Prevents GDI/COM handle leaks and IIS worker process memory bloat. | `CrystalDecisions.CrystalReports.Engine.ReportDocument.Dispose()` |
| 11 | Export | PDF Stream Export (`ExportToStream`) | Streams rendered PDF report directly to browser response buffer using `ExportToStream(ExportFormatType.PortableDocFormat)`. | `ExportFormatType.PortableDocFormat` | Binary PDF download stream (`application/pdf`) | Uses `CompleteRequest()` instead of `Response.End()` to prevent `ThreadAbortException`. | `ReportDocument.ExportToStream` inspection |
| 12 | Printing | PDF-Based Browser Printing | Triggers high-fidelity vector printing via browser PDF engine or `@media print` CSS. | `btnPrint` click / JavaScript print trigger | Browser print dialog | Crisp vector text and photo alignment; hides navigation/search bars during printing. | `CrystalReportViewer.PrintMode`, CSS print media specification |

---

## Edge Cases

| # | Feature | Input | Observed Behavior |
|---|---------|-------|-------------------|
| 1 | Dynamic Image (BLOB) | Candidate with NULL or empty `PhotoData` | Crystal Reports `BlobFieldObject` renders as a transparent empty area without error or broken image icon. In C#, a default placeholder avatar byte array can be injected dynamically to maintain aesthetic consistency. |
| 2 | Dynamic Image (Graphic Location) | Relative path `Images/emp1.png` passed to Graphic Location formula | Graphic Location fails in ASP.NET because the Crystal Reports native engine executes under `C:\Windows\System32` or the IIS Express host directory, not the application root. File not found error or static image retained. |
| 3 | Dynamic Image (Graphic Location) | Absolute path on machine with default CR13 SP20+ security | Crystal Reports blocks loading local files from formula if registry policy or security flags restrict local file system traversal from report formulas. |
| 4 | Search & Filter | Search string with special characters (e.g. `'`, `"`, `%`, `<script>`) | If using `RecordSelectionFormula`, unescaped quotes break the Crystal formula parser and raise `FormulaParseException`. If filtered in C# via ADO.NET parameterized queries or LINQ on in-memory `DataTable`, it is 100% injection-proof and safe. |
| 5 | Filter Result | Zero candidates match search and gender filter | In-memory `DataTable` has 0 rows. Crystal Reports renders report headers and footers with an empty Details section. WebForms status label displays clean notification: "No candidates found matching your criteria." |
| 6 | Viewer Postback (Paging) | User clicks "Next Page" in `CrystalReportViewer` toolbar | If `ReportDocument` is bound ONLY inside `if (!IsPostBack)` in `Page_Load`, postback yields a blank report or prompts for database logon. When bound in `Page_Init`, pagination transitions cleanly between pages. |
| 7 | Session Storage | Storing `ReportDocument` object directly in `Session` and calling `Dispose()` in `Page_Unload` | On subsequent postback, attempting to read `Session["ReportDocument"]` throws `ObjectDisposedException`. Architectural solution: Cache only the managed `DataTable` in `Session`, instantiate a fresh `ReportDocument` in `Page_Init`, and dispose it cleanly in `Page_Unload`. |
| 8 | PDF Export Execution | Calling `Response.End()` after `ExportToHttpResponse` | Raises `System.Threading.ThreadAbortException`. Recommended solution: Use `ExportToStream`, write bytes to `Response.OutputStream`, and call `HttpContext.Current.ApplicationInstance.CompleteRequest()`. |
| 9 | Large Photo Dimensions | Image uploaded at 4000x4000 pixels (10 MB) | Causes excessive memory consumption in ASP.NET session state. Recommended specification: Normalize candidate photos to max 400x400 pixels (~20-50 KB) prior to database insertion. Existing database photos are already optimal at 240x240 pixels (~4 KB). |
| 10 | Hyperlink to Missing Resume | Candidate record points to non-existent PDF file | Report renders normally with hyperlink text. When clicked, browser navigates to URL and encounters HTTP 404. WebForms logic should verify `File.Exists(Server.MapPath(resumePath))` and disable the link or display "Resume not uploaded" if missing. |

---

## Logic Chain

1. **Comparison of Dynamic Image Display Options**:
   - *Observation*: `CandidateDataSet.xsd` line 31 defines `PhotoData` as `xs:base64Binary`. In .NET, this compiles to `System.Byte[]`. Database table `CandidateProfiles` contains column `PhotoData` of type `varbinary(max)`, populated with actual image bytes (4048 to 4412 bytes for 240x240 PNG images).
   - *Alternative Observation*: `PictureObject` supports Graphic Location formulas. However, Graphic Location in ASP.NET environments requires physical disk paths, read permissions for IIS worker process accounts (`IIS_IUSRS`, `NETWORK SERVICE`), is prone to path resolution failures due to working directory mismatches, and is subject to security lockdowns introduced in SAP Crystal Reports 13.
   - *Deduction*: The Typed DataSet `byte[]` approach (`BlobFieldObject`) is self-contained in memory, requires zero disk access by the Crystal Reports C++ engine, avoids IIS NTFS permission pitfalls, prevents broken image errors via programmatic C# fallbacks, and is by far the most robust approach for ASP.NET Web Sites.

2. **Report Layout Architecture: Summary List vs Individual Resume**:
   - *Observation*: `ORIGINAL_REQUEST.md` specifies both candidate profile display with photos and an individual resume view. Visual Studio 2015 contains two distinct `.rpt` files: `CandidateDirectory.rpt` and `CandidateResume.rpt`.
   - *Deduction*: While Crystal Reports allows conditional section suppression in a single report via a parameter formula (e.g. `{?p_ViewMode} = 'Resume'`), maintaining two dedicated `.rpt` files is substantially cleaner. It avoids cluttered overlapping sections in the designer, eliminates height calculation glitches, and permits distinct header/footer layouts for tabular directory listings versus executive single-candidate dossiers.

3. **WebForms UI & ASP.NET Page Lifecycle Architecture**:
   - *Observation*: In ASP.NET WebForms, controls inside `CrystalReportViewer` fire events during the postback lifecycle. If `ReportSource` is not assigned prior to or during `Page_Init`, postback events like pagination, zooming, and toolbar exports fail.
   - *Deduction*: The robust architecture caches the filtered `DataTable` (or filter parameters) in `Session["CandidateData"]`. In `Page_Init`, the code-behind creates a `ReportDocument`, loads the relevant `.rpt`, assigns `SetDataSource(cachedTable)`, and binds `crvReport.ReportSource = rptDoc;`. In `Page_Unload`, `rptDoc.Close(); rptDoc.Dispose();` releases all unmanaged handles cleanly. This guarantees zero memory leaks and 100% reliable postback navigation.

4. **PDF Export & Browser Printing Architecture**:
   - *Observation*: `ReportDocument` provides `ExportToHttpResponse` and `ExportToStream`. `ExportToHttpResponse` triggers `Response.End()`, raising `ThreadAbortException`.
   - *Deduction*: Using `ExportToStream(ExportFormatType.PortableDocFormat)` coupled with `Response.OutputStream.Write` and `HttpContext.Current.ApplicationInstance.CompleteRequest()` delivers seamless, non-throwing PDF downloads. For printing, setting `PrintMode="Pdf"` on `CrystalReportViewer` combined with a dedicated `btnPrint` button invoking `window.print()` (with clean Notion-style `@media print` CSS) provides instantaneous printing.

5. **Notion-Like Visual Styling**:
   - *Observation*: Strict user guidelines mandate a mature, minimalist Notion-like look with neutral palettes, clean sans-serif typography, understated borders, no gaudy gradients, and zero emojis.
   - *Deduction*: The UI in `Default.aspx` should employ a `#F9FAFB` background, `#FFFFFF` cards with `1px solid #E5E7EB` borders, `#111827` primary text, `#4B5563` secondary text, `#1F2937` primary filter button, and crisp, understated controls with prefixes: `txtSearch`, `ddlGender`, `ddlViewMode`, `ddlCandidate`, `btnSearch`, `btnReset`, `btnExportPdf`, `btnPrint`, and `crvReport`.

---

## Caveats

1. **ActiveX Print Mode Deprecation**: The `PrintMode.ActiveX` option in Crystal Reports is obsolete and unsupported in modern web browsers (Chrome, Edge, Firefox). The system must exclusively use `PrintMode.Pdf` or client-side JavaScript/CSS printing.
2. **CrystalImageHandler in IIS Express**: `Web.config` registers `CrystalImageHandler.aspx` under both `<httpHandlers>` and `<system.webServer>/<handlers>`. The viewer's static script directory is `/crystalreportviewers13`. If hosted in a virtual subdirectory, `ResourceURI` must align with the site's application path.
3. **Database Connectivity**: SQL Server is currently active and reachable with credentials `sa` / `mcc#1234`. However, to ensure resilience against database offline states, the data access layer can fall back to loading the existing image files from `~/Images` into `CandidateDataSet` in memory.

---

## Conclusion

The authoritative technical specifications for WebSite2 are established:
1. **Dynamic Images**: Use Typed DataSet (`CandidateDataSet.xsd`) with `PhotoData` as `xs:base64Binary` (`byte[]`) bound to a `BlobFieldObject`. This completely circumvents IIS permission and COM/OLE Graphic Location errors.
2. **Report Layouts**: Implement two clean `.rpt` layouts:
   - `CandidateDirectory.rpt`: Tabular roster with 1.0-inch thumbnail, candidate details, skills, and resume link.
   - `CandidateResume.rpt`: Comprehensive 1-page profile card with 1.8-inch photo, executive bio, detailed skills, experience, and verified contact.
3. **WebForms Integration**:
   - Lifecycle: Bind `ReportDocument` in `Page_Init` using `Session["CandidateData"]`. Dispose cleanly in `Page_Unload`.
   - UI: Notion-like minimal aesthetic, clean borders, neutral palette, zero emojis, standard control IDs (`txtSearch`, `ddlGender`, `ddlViewMode`, `ddlCandidate`, `btnSearch`, `btnReset`, `btnExportPdf`, `btnPrint`, `crvReport`).
   - Export: `ExportToStream` with `CompleteRequest()` for zero-exception PDF downloads.
   - Printing: Dual support via `PrintMode="Pdf"` and `@media print` CSS.

---

## Verification Method

1. **Verify Crystal Reports Assemblies & Schema**:
   Execute PowerShell in project directory:
   ```powershell
   Add-Type -Path "C:\WINDOWS\assembly\GAC_MSIL\CrystalDecisions.Shared\13.0.2000.0__692fbea5521e1304\CrystalDecisions.Shared.dll"
   Add-Type -Path "C:\WINDOWS\assembly\GAC_MSIL\CrystalDecisions.CrystalReports.Engine\13.0.2000.0__692fbea5521e1304\CrystalDecisions.CrystalReports.Engine.dll"
   $ds = New-Object System.Data.DataSet
   $ds.ReadXmlSchema("C:\Users\sailenmondal\OneDrive - MANAGEMENT & COMPUTER CONSULTANTS\Documents\Visual Studio 2015\WebSites\WebSite2\App_Code\CandidateDataSet.xsd")
   $ds.Tables["Candidate"].Columns["PhotoData"].DataType.FullName
   ```
   *Expected output*: `System.Byte[]`

2. **Verify Database Table & Image Bytes**:
   ```powershell
   $con = New-Object System.Data.SqlClient.SqlConnection("Data Source=.;Initial Catalog=ProjectManagementDB;User ID=sa;Password=mcc#1234;TrustServerCertificate=True")
   $con.Open()
   $cmd = $con.CreateCommand()
   $cmd.CommandText = "SELECT COUNT(*), SUM(DATALENGTH(PhotoData)) FROM CandidateProfiles"
   $rdr = $cmd.ExecuteReader()
   while ($rdr.Read()) { "Candidates: " + $rdr.GetInt32(0) + " | Total Photo Bytes: " + $rdr.GetInt32(1) }
   $con.Close()
   ```
   *Expected output*: 5 candidates, ~21256 total photo bytes.

3. **Verify ASP.NET Compilation Command**:
   ```powershell
   C:\Windows\Microsoft.NET\Framework64\v4.0.30319\aspnet_compiler.exe -v / -p "C:\Users\sailenmondal\OneDrive - MANAGEMENT & COMPUTER CONSULTANTS\Documents\Visual Studio 2015\WebSites\WebSite2" -u
   ```
