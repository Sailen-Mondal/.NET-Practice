$ErrorActionPreference = 'Stop'

Add-Type -Path 'C:\Program Files (x86)\SAP BusinessObjects\Crystal Reports for .NET Framework 4.0\Common\SAP BusinessObjects Enterprise XI 4.0\win32_x86\dotnet\CrystalDecisions.Shared.dll'
Add-Type -Path 'C:\Program Files (x86)\SAP BusinessObjects\Crystal Reports for .NET Framework 4.0\Common\SAP BusinessObjects Enterprise XI 4.0\win32_x86\dotnet\CrystalDecisions.CrystalReports.Engine.dll'

$doc = New-Object CrystalDecisions.CrystalReports.Engine.ReportDocument
Write-Output "ReportDocument instantiated successfully: $($doc.GetType().FullName)"
Write-Output "Process Bitness: $([IntPtr]::Size * 8)-bit"
