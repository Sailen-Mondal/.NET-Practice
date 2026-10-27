# Handoff Report: WebSite2 Structure, Build, and Crystal Reports Runtime Survey

## 1. Observation

### Target Environment & Paths
- **Project Directory**: `C:\Users\sailenmondal\OneDrive - MANAGEMENT & COMPUTER CONSULTANTS\Documents\Visual Studio 2015\WebSites\WebSite2`
- **Solution File**: `C:\Users\sailenmondal\OneDrive - MANAGEMENT & COMPUTER CONSULTANTS\Documents\Visual Studio 2015\Projects\WebSite2\WebSite2.sln`
- **Project Type**: ASP.NET Web Site Project (WSP), project type GUID `{E24C65DC-7377-472B-9ABA-BC803B73C61A}` (no `.csproj` file).
- **Target Framework**: `.NETFramework,Version=v4.5.2` (configured in `WebSite2.sln` line 8 and `Web.config` lines 23 and 35).

### Directory & File Structure
```
WebSite2/
|-- App_Code/
|   `-- CandidateDataSet.xsd                 [Schema defining Candidate DataTable with PhotoData base64Binary/BLOB]
|-- crystalreportviewers13/                   [SAP Crystal Reports JavaScript/CSS/HTML viewer runtime assets]
|   |-- css/
|   |-- html/
|   |-- images/
|   |-- js/
|   |-- prompting/
|   |-- urlreporting/
|   |-- ActiveXControls/
|   `-- allInOne.js, crv.js, processindicator.js, promptengine-compressed.js
|-- Images/                                  [Sample profile photos & assets]
|   |-- emp1.png, emp2.png, emp3.png, emp4.png, emp5.png, logo.png
|-- Resumes/                                 [Sample candidate resume PDF documents]
|   |-- amit_verma_resume.pdf, priya_mukherjee_resume.pdf, rahul_sharma_resume.pdf, sneha_patel_resume.pdf, vikram_singh_resume.pdf
|-- CandidateBase.rpt                        [Crystal Report file, 11,264 bytes]
|-- CandidateDirectory.rpt                   [Crystal Report file, 336,896 bytes]
|-- CandidateResume.rpt                      [Crystal Report file, 102,400 bytes]
|-- TestReportWithPicture.rpt                [Crystal Report file, 102,400 bytes, bound to Employee1 table]
|-- Default.aspx                             [ASP.NET WebForms UI with search, gender dropdown, report selector, PDF export, print]
|-- Default.aspx.cs                          [WebForms code-behind managing CrystalReportViewer binding, data fetching, export]
|-- TestExport.pdf                           [Valid exported PDF test artifact, 37,488 bytes, PDF-1.7 format]
|-- Web.config                               [ASP.NET configuration with Crystal handlers, assemblies, connection strings]
`-- Web.Debug.config                         [XDT transformation configuration for debug builds]
```

### Web.config Configuration Analysis
- **Target .NET Framework**: `4.5.2`
  - Line 23: `<compilation debug="true" targetFramework="4.5.2">`
  - Line 35: `<httpRuntime targetFramework="4.5.2"/>`
- **CrystalDecisions Assembly References (lines 24-30)**:
  - `CrystalDecisions.CrystalReports.Engine, Version=13.0.2000.0, Culture=neutral, PublicKeyToken=692fbea5521e1304`
  - `CrystalDecisions.ReportSource, Version=13.0.2000.0, Culture=neutral, PublicKeyToken=692fbea5521e1304`
  - `CrystalDecisions.Shared, Version=13.0.2000.0, Culture=neutral, PublicKeyToken=692fbea5521e1304`
  - `CrystalDecisions.Web, Version=13.0.2000.0, Culture=neutral, PublicKeyToken=692fbea5521e1304`
  - `CrystalDecisions.ReportAppServer.ClientDoc, Version=13.0.2000.0, Culture=neutral, PublicKeyToken=692fbea5521e1304`
- **Build Providers (lines 31-33)**:
  - `<add extension=".rpt" type="CrystalDecisions.Web.Compilation.RptBuildProvider, CrystalDecisions.Web, Version=13.0.2000.0, Culture=neutral, PublicKeyToken=692fbea5521e1304"/>`
- **Image Cleaner & Settings (lines 16-20)**:
  - `CrystalImageCleaner-AutoStart` = `true`
  - `CrystalImageCleaner-Sleep` = `60000` (60 seconds)
  - `CrystalImageCleaner-Age` = `120000` (120 seconds)
- **HTTP Handlers**:
  - Classic IIS (line 37): `<add verb="GET" path="CrystalImageHandler.aspx" type="CrystalDecisions.Web.CrystalImageHandler, CrystalDecisions.Web, Version=13.0.2000.0, Culture=neutral, PublicKeyToken=692fbea5521e1304"/>`
  - Integrated IIS (line 60): `<add name="CrystalImageHandler.aspx_GET" verb="GET" path="CrystalImageHandler.aspx" type="CrystalDecisions.Web.CrystalImageHandler, CrystalDecisions.Web, Version=13.0.2000.0, Culture=neutral, PublicKeyToken=692fbea5521e1304" preCondition="integratedMode"/>`
  - Integrated Validation (line 62): `<validation validateIntegratedModeConfiguration="false"/>`
- **Viewer Resource URI (lines 46-48)**:
  - `<crystalReportViewer><add key="ResourceURI" value="/crystalreportviewers13" /></crystalReportViewer>`
- **Database Connection String (line 13)**:
  - `Data Source=.;Initial Catalog=ProjectManagementDB;User ID=sa;Password=mcc#1234;TrustServerCertificate=True`
  - Database is online and verified: contains `dbo.CandidateProfiles` (5 rows with BLOB `PhotoData` and paths) and `dbo.Employee1`.

### Crystal Reports Installation & GAC Survey
- **Installed Software Products (from Registry Uninstall keys)**:
  1. `SAP Crystal Reports runtime engine for .NET Framework (64-bit)`, Version: `13.0.20.2399`, Publisher: `SAP`
  2. `SAP Crystal Reports, version for Microsoft Visual Studio`, Version: `13.0.20.2399`, Publisher: `SAP`
- **GAC Discovery**:
  - Core assemblies reside in `C:\Windows\assembly\GAC_MSIL\`:
    - `CrystalDecisions.CrystalReports.Engine.dll` (Version `13.0.2000.0`, FileVersion `13.0.20.2399`, Token `692fbea5521e1304`)
    - `CrystalDecisions.Shared.dll` (Version `13.0.2000.0`, FileVersion `13.0.20.2399`, Token `692fbea5521e1304`)
    - `CrystalDecisions.Web.dll` (Version `13.0.2000.0`, FileVersion `13.0.20.2399`, Token `692fbea5521e1304`)
    - `CrystalDecisions.ReportSource.dll` (Version `13.0.2000.0`, FileVersion `13.0.20.2399`, Token `692fbea5521e1304`)
    - `CrystalDecisions.ReportAppServer.ClientDoc.dll` (Version `13.0.2000.0`, FileVersion `13.0.20.2399`, Token `692fbea5521e1304`)
  - 64-bit native/interop assemblies reside in `C:\Windows\assembly\GAC_64\`:
    - `CrystalDecisions.ReportAppServer.ClientDoc.dll`
    - `CrystalDecisions.ReportAppServer.CommLayer.dll`
    - `CrystalDecisions.ReportAppServer.CommonControls.dll`
    - `CrystalDecisions.ReportAppServer.CommonObjectModel.dll`
    - `CrystalDecisions.ReportAppServer.Controllers.dll`
    - `CrystalDecisions.ReportAppServer.CubeDefModel.dll`
    - `CrystalDecisions.ReportAppServer.DataDefModel.dll`
    - `CrystalDecisions.ReportAppServer.ObjectFactory.dll`
    - `CrystalDecisions.ReportAppServer.Prompting.dll`
    - `CrystalDecisions.ReportAppServer.ReportDefModel.dll`
    - `CrystalDecisions.ReportAppServer.XmlSerialize.dll`
- **Dynamic Load Verification**:
  - Running `[System.Reflection.Assembly]::LoadWithPartialName('CrystalDecisions.CrystalReports.Engine')` successfully resolved `Version=13.0.2000.0, Culture=neutral, PublicKeyToken=692fbea5521e1304`.
  - Instantiating `New-Object CrystalDecisions.CrystalReports.Engine.ReportDocument` and loading `TestReportWithPicture.rpt` succeeded without error.

### Compilation & Build Verification
- **aspnet_compiler (In-place validation)**:
  - Command: `C:\Windows\Microsoft.NET\Framework64\v4.0.30319\aspnet_compiler.exe -v / -p "C:\Users\sailenmondal\OneDrive - MANAGEMENT & COMPUTER CONSULTANTS\Documents\Visual Studio 2015\WebSites\WebSite2"`
  - Result: Exit code 0, 0 errors, 0 warnings.
  - 32-bit compiler (`C:\Windows\Microsoft.NET\Framework\v4.0.30319\aspnet_compiler.exe`) also succeeded with exit code 0.
- **MSBuild on WebSite2.sln**:
  - Command: `"C:\Program Files\Microsoft Visual Studio\18\Community\MSBuild\Current\Bin\MSBuild.exe" "C:\Users\sailenmondal\OneDrive - MANAGEMENT & COMPUTER CONSULTANTS\Documents\Visual Studio 2015\Projects\WebSite2\WebSite2.sln" /t:Build /p:Configuration=Debug`
  - Result: Exit code 0, `Build succeeded. 0 Warning(s), 0 Error(s). Time Elapsed 00:00:02.35`.
  - MSBuild triggers `aspnet_compiler.exe -v /localhost_8188 -p ..\..\WebSites\WebSite2\ -u -f -d PrecompiledWeb\localhost_8188\`.

### Runtime Hosting & Server Status
- **Active Web Server**:
  - Process PID 5612: `"C:\Program Files\IIS Express\iisexpress.exe" "/path:C:\Users\sailenmondal\OneDrive - MANAGEMENT & COMPUTER CONSULTANTS\Documents\Visual Studio 2015\WebSites\WebSite2" /port:8188`
  - Port 8188 is actively listening.
  - HTTP GET `http://localhost:8188/Default.aspx` returned `HTTP/1.1 200 OK` (Content-Length: 34939).
  - Viewer static assets at `http://localhost:8188/crystalreportviewers13/js/crviewer/crv.js` returned `HTTP/1.1 200 OK`.

---

## 2. Logic Chain

1. **Project Nature**:
   - Observation: `WebSite2` contains no `.csproj` file, but `WebSite2.sln` declares project type `{E24C65DC-7377-472B-9ABA-BC803B73C61A}` with `Debug.AspNetCompiler` properties.
   - Inference: `WebSite2` is an ASP.NET Web Site Project (WSP), which relies on folder-based compilation (`App_Code` for classes, dynamic compilation for `.aspx` pages and `.rpt` reports) rather than pre-compilation into a single project DLL.
2. **Assembly Resolution**:
   - Observation: `Web.config` references CrystalDecisions version `13.0.2000.0` with token `692fbea5521e1304`. The GAC survey revealed assemblies with this exact assembly version and token in `C:\Windows\assembly\GAC_MSIL` and `GAC_64`. No `bin` folder is present in `WebSite2`.
   - Inference: Assemblies are resolved directly from the system GAC at compilation and runtime. No local `bin` deployment is required.
3. **Bitness & Execution Compatibility**:
   - Observation: Both 32-bit and 64-bit `aspnet_compiler.exe` tools compiled the site without errors. The running IIS Express process is 64-bit (`C:\Program Files\IIS Express\iisexpress.exe`), and 64-bit Crystal Report native assemblies (`GAC_64`) are present.
   - Inference: The project runs stably in 64-bit mode under 64-bit IIS Express.
4. **Build Tooling**:
   - Observation: Both standalone `aspnet_compiler.exe` and `MSBuild.exe` against `WebSite2.sln` succeeded with 0 errors.
   - Inference: Downstream testing and CI/automation can use either command to validate project integrity.

---

## 3. Caveats

- **No Caveats**. The environment, project structure, GAC assemblies, compilation mechanisms, and active IIS Express instances are fully identified and verified.

---

## 4. Conclusion

1. **WebSite2 is an ASP.NET Web Site Project (WSP)** targeting **.NET Framework 4.5.2** located at `C:\Users\sailenmondal\OneDrive - MANAGEMENT & COMPUTER CONSULTANTS\Documents\Visual Studio 2015\WebSites\WebSite2`.
2. **Crystal Reports runtime version 13.0.20.2399 (Service Pack 20)** is installed with assemblies matching `Version=13.0.2000.0, PublicKeyToken=692fbea5521e1304` in `C:\Windows\assembly\GAC_MSIL` and `GAC_64`.
3. **Web.config** is fully configured with assembly references, `.rpt` build provider, `CrystalImageHandler.aspx` (both classic and integrated pipeline modes), viewer resource URI (`/crystalreportviewers13`), and `CrystalImageCleaner`.
4. **Compilation Method**:
   - Primary validation command: `C:\Windows\Microsoft.NET\Framework64\v4.0.30319\aspnet_compiler.exe -v / -p "C:\Users\sailenmondal\OneDrive - MANAGEMENT & COMPUTER CONSULTANTS\Documents\Visual Studio 2015\WebSites\WebSite2"`
   - Solution build command: `"C:\Program Files\Microsoft Visual Studio\18\Community\MSBuild\Current\Bin\MSBuild.exe" "C:\Users\sailenmondal\OneDrive - MANAGEMENT & COMPUTER CONSULTANTS\Documents\Visual Studio 2015\Projects\WebSite2\WebSite2.sln" /t:Build /p:Configuration=Debug`
5. **Runtime Hosting**:
   - WebSite2 is hosted on 64-bit IIS Express at `http://localhost:8188/`. Default.aspx is live, serving candidates and the CrystalReportViewer component.

---

## 5. Verification Method

To independently verify the findings:

1. **Verify Compilation**:
   ```powershell
   C:\Windows\Microsoft.NET\Framework64\v4.0.30319\aspnet_compiler.exe -v / -p "C:\Users\sailenmondal\OneDrive - MANAGEMENT & COMPUTER CONSULTANTS\Documents\Visual Studio 2015\WebSites\WebSite2"
   ```
   *Expected outcome*: Exits with code 0.

2. **Verify Solution Build**:
   ```powershell
   & "C:\Program Files\Microsoft Visual Studio\18\Community\MSBuild\Current\Bin\MSBuild.exe" "C:\Users\sailenmondal\OneDrive - MANAGEMENT & COMPUTER CONSULTANTS\Documents\Visual Studio 2015\Projects\WebSite2\WebSite2.sln" /t:Build /p:Configuration=Debug
   ```
   *Expected outcome*: `Build succeeded. 0 Warning(s), 0 Error(s)`.

3. **Verify GAC Crystal Assembly Availability**:
   ```powershell
   [System.Reflection.Assembly]::LoadWithPartialName('CrystalDecisions.CrystalReports.Engine')
   ```
   *Expected outcome*: Returns `CrystalDecisions.CrystalReports.Engine, Version=13.0.2000.0, Culture=neutral, PublicKeyToken=692fbea5521e1304`.

4. **Verify HTTP Endpoint**:
   ```powershell
   curl.exe -I http://localhost:8188/Default.aspx
   ```
   *Expected outcome*: Returns `HTTP/1.1 200 OK`.
