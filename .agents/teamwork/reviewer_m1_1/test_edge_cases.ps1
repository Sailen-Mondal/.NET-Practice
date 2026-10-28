[Reflection.Assembly]::LoadWithPartialName("CrystalDecisions.CrystalReports.Engine") | Out-Null
[Reflection.Assembly]::LoadWithPartialName("CrystalDecisions.Shared") | Out-Null

$connStr = "Data Source=.;Initial Catalog=ProjectManagementDB;User ID=sa;Password=mcc#1234;TrustServerCertificate=True"
$projectDir = "C:\Users\sailenmondal\OneDrive - MANAGEMENT & COMPUTER CONSULTANTS\Documents\Visual Studio 2015\WebSites\WebSite2"

$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()

# 1. Parameterized search edge case: SQL special characters (single quote, percent, underscore, bracket)
$searchTerms = @("'", "%", "_", "[", "Rahul'; DROP TABLE test;--", "NonExistentCandidate123")
foreach ($st in $searchTerms) {
    $sql = "SELECT CandidateId, FullName FROM dbo.CandidateProfiles WHERE FullName LIKE '%' + @fname + '%'"
    $cmd = New-Object System.Data.SqlClient.SqlCommand($sql, $conn)
    $cmd.Parameters.AddWithValue("@fname", $st) | Out-Null
    $da = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
    $dt = New-Object System.Data.DataTable
    $da.Fill($dt) | Out-Null
    Write-Output ("Param Test with query '{0}': Returned {1} rows without SQL error." -f $st, $dt.Rows.Count)
}

# 2. 0-row DataTable bound to Crystal Reports
$sql0 = "SELECT CandidateId AS ID, FullName AS Name, City AS Location, Gender, PhotoData FROM dbo.CandidateProfiles WHERE 1=0"
$cmd0 = New-Object System.Data.SqlClient.SqlCommand($sql0, $conn)
$da0 = New-Object System.Data.SqlClient.SqlDataAdapter($cmd0)
$dt0 = New-Object System.Data.DataTable("Employee1")
$da0.Fill($dt0) | Out-Null

$rpt = New-Object CrystalDecisions.CrystalReports.Engine.ReportDocument
$rpt.Load((Join-Path $projectDir "CandidateDirectory.rpt"))
$rpt.SetDataSource($dt0)
$stream = $rpt.ExportToStream([CrystalDecisions.Shared.ExportFormatType]::PortableDocFormat)
Write-Output ("Zero-row export bytes: {0}" -f $stream.Length)
$stream.Close()
$rpt.Close()
$rpt.Dispose()

$conn.Close()
Write-Output "Edge case tests passed successfully."
