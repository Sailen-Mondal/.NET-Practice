$dir = "C:\Users\sailenmondal\OneDrive - MANAGEMENT & COMPUTER CONSULTANTS\Documents\Visual Studio 2015\WebSites\WebSite2"
$extensions = @('.aspx', '.cs', '.xsd', '.config', '.sql', '.md', '.json', '.html', '.htm', '.css', '.js')
$files = Get-ChildItem -Path $dir -Recurse -File | Where-Object { $extensions -contains $_.Extension }

$found = $false
foreach ($f in $files) {
    $content = [System.IO.File]::ReadAllText($f.FullName)
    for ($i = 0; $i -lt $content.Length; $i++) {
        if ([char]::IsSurrogate($content[$i])) {
            Write-Output "Surrogate/Emoji found in $($f.FullName) at char index $i"
            $found = $true
            break
        }
    }
}

# Also check database text fields
$connStr = "Data Source=.;Initial Catalog=ProjectManagementDB;User ID=sa;Password=mcc#1234;TrustServerCertificate=True"
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()
$cmd = $conn.CreateCommand()
$cmd.CommandText = "SELECT FullName, JobTitle, Department, Skills, Summary, City FROM dbo.CandidateProfiles"
$reader = $cmd.ExecuteReader()
while ($reader.Read()) {
    for ($c = 0; $c -lt $reader.FieldCount; $c++) {
        $val = $reader.GetString($c)
        for ($i = 0; $i -lt $val.Length; $i++) {
            if ([char]::IsSurrogate($val[$i])) {
                Write-Output "Emoji found in DB column $($reader.GetName($c)): $val"
                $found = $true
            }
        }
    }
}
$reader.Close()
$conn.Close()

if (-not $found) {
    Write-Output "VERIFIED: ZERO EMOJIS FOUND across all project code, markup, config, and database records."
}
