$conn = New-Object System.Data.SqlClient.SqlConnection("Data Source=.;Initial Catalog=ProjectManagementDB;User ID=sa;Password=mcc#1234;TrustServerCertificate=True")
$conn.Open()
$cmd = $conn.CreateCommand()
$cmd.CommandText = "SELECT CandidateId, FullName, Gender, City, DATALENGTH(PhotoData) AS PhotoBytes, PhotoPath, ResumePath FROM dbo.CandidateProfiles"
$r = $cmd.ExecuteReader()
while ($r.Read()) {
    Write-Host "$($r['CandidateId']) | $($r['FullName']) | $($r['Gender']) | $($r['City']) | $($r['PhotoBytes']) bytes | $($r['PhotoPath']) | $($r['ResumePath'])"
}
$conn.Close()
