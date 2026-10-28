# Test DBNull.Value in PhotoData for Crystal Reports
$ErrorActionPreference = 'Stop'
$projDir = 'C:\Users\sailenmondal\OneDrive - MANAGEMENT & COMPUTER CONSULTANTS\Documents\Visual Studio 2015\WebSites\WebSite2'
$webConfigFile = Join-Path $projDir "Web.config"
[xml]$webConfig = Get-Content $webConfigFile
$conStr = ($webConfig.configuration.connectionStrings.add | Where-Object { $_.name -eq 'conStr' }).connectionString

Add-Type -Path 'C:\Program Files (x86)\SAP BusinessObjects\Crystal Reports for .NET Framework 4.0\Common\SAP BusinessObjects Enterprise XI 4.0\win32_x86\dotnet\CrystalDecisions.Shared.dll'
Add-Type -Path 'C:\Program Files (x86)\SAP BusinessObjects\Crystal Reports for .NET Framework 4.0\Common\SAP BusinessObjects Enterprise XI 4.0\win32_x86\dotnet\CrystalDecisions.CrystalReports.Engine.dll'

# Load FetchCandidateData
$csharpSource = @"
using System;
using System.Data;
using System.Data.SqlClient;

public class NullBlobTester
{
    public static DataTable GetTableWithNullBlob(string connStr)
    {
        var dt = new DataTable("Employee1");
        using (var conn = new SqlConnection(connStr))
        {
            conn.Open();
            string sql = @"SELECT TOP 1
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
                            CAST(NULL AS varbinary(max)) AS PhotoData 
                           FROM dbo.CandidateProfiles";
            using (var cmd = new SqlCommand(sql, conn))
            using (var da = new SqlDataAdapter(cmd))
            {
                da.Fill(dt);
            }
        }
        return dt;
    }
}
"@
Add-Type -TypeDefinition $csharpSource -ReferencedAssemblies "System.Data.dll", "System.Xml.dll"

$dtNull = [NullBlobTester]::GetTableWithNullBlob($conStr)
Write-Output "PhotoData in row 0 is DBNull: $([Convert]::IsDBNull($dtNull.Rows[0]['PhotoData']))"

$rptPath = Join-Path $projDir "CandidateDirectory.rpt"
$rptDoc = New-Object CrystalDecisions.CrystalReports.Engine.ReportDocument
$rptDoc.Load($rptPath)
$rptDoc.SetDataSource($dtNull)
$stream = $rptDoc.ExportToStream([CrystalDecisions.Shared.ExportFormatType]::PortableDocFormat)
Write-Output "Export with NULL PhotoData succeeded! PDF Length: $($stream.Length) bytes"
$stream.Close()
$stream.Dispose()
$rptDoc.Close()
$rptDoc.Dispose()
