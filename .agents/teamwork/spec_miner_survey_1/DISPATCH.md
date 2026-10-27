# Task Assignment: Survey 3 - Crystal Reports Dynamic Images, Parameters & WebForms Integration Spec

## Target Project Directory
C:\Users\sailenmondal\OneDrive - MANAGEMENT & COMPUTER CONSULTANTS\Documents\Visual Studio 2015\WebSites\WebSite2

## Working Directory
d:\.NET\.agents\teamwork\spec_miner_survey_1

## Objective
Extract technical specifications, constraints, and integration patterns for:
1. Dynamic photo display in Crystal Reports:
   - In Crystal Reports (.rpt), how dynamic images are rendered (e.g. byte[] / BLOB column in typed DataSet / DataTable vs Graphic Location formula pointing to file path or URL).
   - What approach works best and most reliably for Crystal Reports in ASP.NET Web Site.
2. Resume view & details:
   - Showing candidate resume details (education, experience, skills, contact) and links in Crystal Reports and/or WebForms.
3. WebForms UI (Default.aspx / Default.aspx.cs):
   - CrystalReportViewer setup in ASP.NET (registration of CrystalDecisions.Web tag, session state handling, report document lifecycle: Page_Init / Page_Load, disposing ReportDocument in Page_Unload).
   - Filter controls: Search textbox (txtSearch), Gender dropdown/radio (ddlGender), Search/Filter button (btnSearch).
   - Parameter passing to Crystal Report (RecordSelectionFormula vs ReportParameters / SetParameterValue).
   - PDF Export implementation (ExportToDisk, ExportToStream, ExportToHttpResponse with Application/pdf).
   - Client-side printing mechanism (PrintMode, javascript print, or PDF direct print).
   - UI styling: Notion-like minimal aesthetic (understated borders, neutral color palettes, clean sans-serif typography, no gaudy gradients, zero emojis).
   - Conventional control prefixes (btnSubmit, lblMessage, txtSearch, gvCandidates, crvReport).

## Requirements
- Read ORIGINAL_REQUEST.md at `d:\.NET\.agents\teamwork\ORIGINAL_REQUEST.md`.
- Produce a structured `handoff.md` in your working directory `d:\.NET\.agents\teamwork\spec_miner_survey_1\handoff.md`.
- STRICT: Zero emojis in files and messages.
- Report back to the orchestrator via send_message when complete.


## 2026-10-27T13:48:16Z
Sender: e5858265-aff7-4221-b161-81b87279d352
Priority: MESSAGE_PRIORITY_HIGH
Content:
You are a Specification Miner agent for the WebSite2 Crystal Reports solution.
Your Working Directory: d:\.NET\.agents\teamwork\spec_miner_survey_1
Target Project Directory: C:\Users\sailenmondal\OneDrive - MANAGEMENT & COMPUTER CONSULTANTS\Documents\Visual Studio 2015\WebSites\WebSite2
Original Request: d:\.NET\.agents\teamwork\ORIGINAL_REQUEST.md
Your Dispatch Task: d:\.NET\.agents\teamwork\spec_miner_survey_1\DISPATCH.md

Investigate and document:
1. Crystal Reports dynamic image display options in ASP.NET Web Site:
   - Typed DataSet with byte[] (System.Byte[]) column vs Graphic Location formula (file path or file:/// URL).
   - Which approach is most robust in Crystal Reports for Visual Studio without external COM/ole issues.
2. Crystal Reports Resume & Candidate details layout:
   - Summary/list view vs individual Resume view.
   - Subreports or parameter-driven conditional section suppressing.
3. WebForms UI specifications (Default.aspx & Default.aspx.cs):
   - Controls: search box (txtSearch), gender filter (ddlGender), submit button (btnSearch), reset button (btnReset), PDF export button (btnExportPdf), print button (btnPrint), CrystalReportViewer (crvReport).
   - Notion-like minimal aesthetic: CSS styling, clean borders, neutral palette, typography, no gaudy gradients.
   - ASP.NET lifecycle management for Crystal Reports: Page_Init vs Page_Load, Session caching, Page_Unload report disposal.
   - Parameter passing methods (RecordSelectionFormula vs ReportDocument.SetParameterValue).
   - PDF export implementation (ExportToHttpResponse or ExportToStream).
   - Printing support in browser.

Output:
Write a comprehensive report to `d:\.NET\.agents\teamwork\spec_miner_survey_1\handoff.md`.
STRICT RULE: Zero emojis anywhere in files or messages.
When done, notify the orchestrator via send_message with a summary and the path to your handoff.md.
