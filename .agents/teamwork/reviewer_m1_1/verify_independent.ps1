# Independent verification script for Milestone 1
# Strictly zero emojis in output.

$connStr = "Data Source=.;Initial Catalog=ProjectManagementDB;User ID=sa;Password=mcc#1234;TrustServerCertificate=True"
$projectDir = "C:\Users\sailenmondal\OneDrive - MANAGEMENT & COMPUTER CONSULTANTS\Documents\Visual Studio 2015\WebSites\WebSite2"
$imagesDir = Join-Path $projectDir "Images"
$xsdPath = Join-Path $projectDir "App_Code\CandidateDataSet.xsd"

Write-Output "=== 1. DATABASE CONNECTIVITY ==="
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
try {
    $conn.Open()
    Write-Output "Connection State: $($conn.State)"
    Write-Output "Server Version: $($conn.ServerVersion)"
    Write-Output "Database: $($conn.Database)"
} catch {
    Write-Error "Failed to connect to SQL Server: $_"
    exit 1
}

Write-Output "`n=== 2. TABLE SCHEMA & CONSTRAINTS ==="
$cmd = $conn.CreateCommand()
$cmd.CommandText = @"
SELECT 
    COLUMN_NAME, 
    DATA_TYPE, 
    ISNULL(CAST(CHARACTER_MAXIMUM_LENGTH AS VARCHAR(20)), '') AS MAX_LEN, 
    IS_NULLABLE 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'CandidateProfiles' 
ORDER BY ORDINAL_POSITION
"@
$reader = $cmd.ExecuteReader()
$colCount = 0
while ($reader.Read()) {
    $colCount++
    Write-Output ("{0,-4} {1,-18} {2,-12} {3,-8} {4,-6}" -f $colCount, $reader["COLUMN_NAME"], $reader["DATA_TYPE"], $reader["MAX_LEN"], $reader["IS_NULLABLE"])
}
$reader.Close()
Write-Output "Total Columns: $colCount"

$cmd.CommandText = @"
SELECT 
    tc.CONSTRAINT_TYPE, 
    ccu.COLUMN_NAME 
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu 
    ON tc.CONSTRAINT_NAME = ccu.CONSTRAINT_NAME
WHERE tc.TABLE_NAME = 'CandidateProfiles'
"@
$reader = $cmd.ExecuteReader()
while ($reader.Read()) {
    Write-Output "Constraint: $($reader["CONSTRAINT_TYPE"]) on Column: $($reader["COLUMN_NAME"])"
}
$reader.Close()

Write-Output "`n=== 3. CANDIDATE RECORDS & INDIAN CONTEXT ==="
$cmd.CommandText = @"
SELECT 
    CandidateId, 
    FullName, 
    JobTitle, 
    Department, 
    Gender, 
    City, 
    Email, 
    Phone, 
    Skills, 
    ExperienceYears, 
    PhotoFileName, 
    ResumeFileName, 
    DATALENGTH(PhotoData) AS PhotoDataBytes 
FROM dbo.CandidateProfiles 
ORDER BY CandidateId
"@
$reader = $cmd.ExecuteReader()
$rowCount = 0
$rows = @()
while ($reader.Read()) {
    $rowCount++
    $obj = [PSCustomObject]@{
        Id = $reader["CandidateId"]
        Name = $reader["FullName"]
        Job = $reader["JobTitle"]
        Dept = $reader["Department"]
        Gender = $reader["Gender"]
        City = $reader["City"]
        Email = $reader["Email"]
        Phone = $reader["Phone"]
        Skills = $reader["Skills"]
        Exp = $reader["ExperienceYears"]
        PhotoFile = $reader["PhotoFileName"]
        ResumeFile = $reader["ResumeFileName"]
        BlobBytes = $reader["PhotoDataBytes"]
    }
    $rows += $obj
    Write-Output ("Row {0}: ID={1}, Name='{2}', Gender='{3}', City='{4}', Title='{5}', BLOB={6} bytes" -f `
        $rowCount, $obj.Id, $obj.Name, $obj.Gender, $obj.City, $obj.Job, $obj.BlobBytes)
}
$reader.Close()
Write-Output "Total Rows: $rowCount"

Write-Output "`n=== 4. IMAGE BLOB BYTE-FOR-BYTE & SHA256 VERIFICATION ==="
$sha256 = [System.Security.Cryptography.SHA256]::Create()

foreach ($r in $rows) {
    $cmd.CommandText = "SELECT PhotoData FROM dbo.CandidateProfiles WHERE CandidateId = " + $r.Id
    $sqlBytes = [byte[]]$cmd.ExecuteScalar()
    
    $diskFilePath = Join-Path $imagesDir $r.PhotoFile
    if (-not (Test-Path $diskFilePath)) {
        Write-Output "FAILED: Disk file not found: $diskFilePath"
        continue
    }
    $diskBytes = [System.IO.File]::ReadAllBytes($diskFilePath)
    
    $sqlHashBytes = $sha256.ComputeHash($sqlBytes)
    $diskHashBytes = $sha256.ComputeHash($diskBytes)
    $sqlHash = [BitConverter]::ToString($sqlHashBytes) -replace '-'
    $diskHash = [BitConverter]::ToString($diskHashBytes) -replace '-'
    
    $isMatch = ($sqlHash -eq $diskHash) -and ($sqlBytes.Length -eq $diskBytes.Length)
    
    # Check PNG magic bytes: 0x89, 0x50, 0x4E, 0x47
    $isPng = ($diskBytes[0] -eq 0x89 -and $diskBytes[1] -eq 0x50 -and $diskBytes[2] -eq 0x4E -and $diskBytes[3] -eq 0x47)
    
    Write-Output ("Candidate {0} ({1}):" -f $r.Id, $r.Name)
    Write-Output ("  Disk File: {0} ({1} bytes, PNG magic: {2})" -f $r.PhotoFile, $diskBytes.Length, $isPng)
    Write-Output ("  Disk SHA256: {0}" -f $diskHash)
    Write-Output ("  SQL SHA256:  {0}" -f $sqlHash)
    Write-Output ("  Exact Match: {0}" -f $isMatch)
}

$conn.Close()

Write-Output "`n=== 5. CHECK LOGO AND OTHER IMAGE ASSETS ==="
Get-ChildItem -Path $imagesDir | ForEach-Object {
    $fileBytes = [System.IO.File]::ReadAllBytes($_.FullName)
    $hash = [BitConverter]::ToString($sha256.ComputeHash($fileBytes)) -replace '-'
    Write-Output ("Image Asset: {0} ({1} bytes, SHA256: {2})" -f $_.Name, $_.Length, $hash)
}

Write-Output "`n=== 6. XSD SCHEMA PARSING & DATASET RUNTIME TYPE ==="
$ds = New-Object System.Data.DataSet
$ds.ReadXmlSchema($xsdPath)
Write-Output "DataSet Name: $($ds.DataSetName)"
foreach ($t in $ds.Tables) {
    Write-Output "Table: $($t.TableName) (Columns: $($t.Columns.Count))"
    foreach ($c in $t.Columns) {
        if ($c.ColumnName -eq "PhotoData") {
            Write-Output ("  Column: {0,-15} .NET DataType: {1}" -f $c.ColumnName, $c.DataType.FullName)
        }
    }
}

Write-Output "`n=== 7. ASP.NET COMPILATION VIA ASPNET_COMPILER ==="
$compilerPath = "C:\Windows\Microsoft.NET\Framework64\v4.0.30319\aspnet_compiler.exe"
$pinfo = New-Object System.Diagnostics.ProcessStartInfo
$pinfo.FileName = $compilerPath
$pinfo.Arguments = "-v / -p `"$projectDir`""
$pinfo.RedirectStandardOutput = $true
$pinfo.RedirectStandardError = $true
$pinfo.UseShellExecute = $false
$p = [System.Diagnostics.Process]::Start($pinfo)
$stdout = $p.StandardOutput.ReadToEnd()
$stderr = $p.StandardError.ReadToEnd()
$p.WaitForExit()

Write-Output "aspnet_compiler ExitCode: $($p.ExitCode)"
if ($stdout) { Write-Output "STDOUT: $stdout" }
if ($stderr) { Write-Output "STDERR: $stderr" }
Write-Output "=== INDEPENDENT VERIFICATION COMPLETED ==="
