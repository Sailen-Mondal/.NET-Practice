[Reflection.Assembly]::LoadWithPartialName("CrystalDecisions.CrystalReports.Engine") | Out-Null
[Reflection.Assembly]::LoadWithPartialName("CrystalDecisions.Shared") | Out-Null

$connStr = "Data Source=.;Initial Catalog=ProjectManagementDB;User ID=sa;Password=mcc#1234;TrustServerCertificate=True"
$projectDir = "C:\Users\sailenmondal\OneDrive - MANAGEMENT & COMPUTER CONSULTANTS\Documents\Visual Studio 2015\WebSites\WebSite2"

$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()
$sql = @"
SELECT 
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
ORDER BY CandidateId
"@

$cmd = New-Object System.Data.SqlClient.SqlCommand($sql, $conn)
$da = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
$dt = New-Object System.Data.DataTable("Employee1")
$da.Fill($dt) | Out-Null
$conn.Close()

Write-Output "Loaded $($dt.Rows.Count) rows into DataTable 'Employee1'."

# Test CandidateDirectory.rpt
$rptDir = New-Object CrystalDecisions.CrystalReports.Engine.ReportDocument
$rptDir.Load((Join-Path $projectDir "CandidateDirectory.rpt"))
$rptDir.SetDataSource($dt)
$stream = $rptDir.ExportToStream([CrystalDecisions.Shared.ExportFormatType]::PortableDocFormat)
Write-Output "CandidateDirectory.rpt PDF Export stream bytes: $($stream.Length)"
$stream.Close()
$rptDir.Close()
$rptDir.Dispose()

# Test CandidateResume.rpt
$rptResume = New-Object CrystalDecisions.CrystalReports.Engine.ReportDocument
$rptResume.Load((Join-Path $projectDir "CandidateResume.rpt"))
$rptResume.SetDataSource($dt)
$stream2 = $rptResume.ExportToStream([CrystalDecisions.Shared.ExportFormatType]::PortableDocFormat)
Write-Output "CandidateResume.rpt PDF Export stream bytes: $($stream2.Length)"
$stream2.Close()
$rptResume.Close()
$rptResume.Dispose()

Write-Output "Both Crystal Reports loaded, bound to DataTable, and exported to PDF successfully!"
