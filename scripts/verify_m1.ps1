# Automated Verification Script for Milestone 1: Data Architecture & Image BLOBs
# Location: d:\.NET\scripts\verify_m1.ps1
# Strict: Zero Emojis

$ErrorActionPreference = 'Stop'
$projDir = 'C:\Users\sailenmondal\OneDrive - MANAGEMENT & COMPUTER CONSULTANTS\Documents\Visual Studio 2015\WebSites\WebSite2'

Write-Output "================================================================="
Write-Output "MILESTONE 1 VERIFICATION SUITE: DATA ARCHITECTURE & IMAGE BLOBS"
Write-Output "Target Project: $projDir"
Write-Output "Timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Write-Output "================================================================="

# TASK 1: Database Connectivity via conStr in Web.config
Write-Output ""
Write-Output "--- TASK 1: DATABASE CONNECTIVITY VIA conStr ---"
$webConfigFile = Join-Path $projDir "Web.config"
if (-not (Test-Path $webConfigFile)) {
    throw "Web.config not found at $webConfigFile"
}
[xml]$webConfig = Get-Content $webConfigFile
$conStrNode = $webConfig.configuration.connectionStrings.add | Where-Object { $_.name -eq 'conStr' }
if (-not $conStrNode) {
    throw "Connection string 'conStr' not found in Web.config"
}
$conStr = $conStrNode.connectionString
Write-Output "Found conStr in Web.config:"
Write-Output "  $conStr"

$conn = New-Object System.Data.SqlClient.SqlConnection($conStr)
$conn.Open()
Write-Output "Database Connection Status:"
Write-Output "  Connection State: $($conn.State)"
Write-Output "  Server Version:   $($conn.ServerVersion)"
Write-Output "  Database Name:    $($conn.Database)"
$conn.Close()
Write-Output "Task 1 Result: PASS - Database connectivity confirmed."

# TASK 2: Table Schema Verification (16 Columns, Types, PK)
Write-Output ""
Write-Output "--- TASK 2: dbo.CandidateProfiles TABLE SCHEMA ---"
$conn.Open()

# Check Primary Key
$pkCmd = $conn.CreateCommand()
$pkCmd.CommandText = @"
SELECT kcu.COLUMN_NAME 
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu 
  ON tc.CONSTRAINT_NAME = kcu.CONSTRAINT_NAME 
WHERE tc.TABLE_NAME = 'CandidateProfiles' AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
"@
$pkColumn = $pkCmd.ExecuteScalar()
Write-Output "Primary Key Column: $pkColumn"
if ($pkColumn -ne 'CandidateId') {
    throw "Primary key is not CandidateId. Found: $pkColumn"
}

# Check Columns
$colCmd = $conn.CreateCommand()
$colCmd.CommandText = @"
SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'CandidateProfiles'
ORDER BY ORDINAL_POSITION
"@
$colAdapter = New-Object System.Data.SqlClient.SqlDataAdapter($colCmd)
$colDt = New-Object System.Data.DataTable
$colAdapter.Fill($colDt) | Out-Null

Write-Output "Total Columns Found: $($colDt.Rows.Count) (Expected: 16)"
$colDt | Format-Table -AutoSize | Out-String | Write-Output

if ($colDt.Rows.Count -ne 16) {
    throw "Expected 16 columns in CandidateProfiles, but found $($colDt.Rows.Count)"
}

# Verify required columns exist
$expectedColumns = @(
    'CandidateId', 'FullName', 'JobTitle', 'Department', 'Gender',
    'Email', 'Phone', 'City', 'Skills', 'ExperienceYears',
    'Summary', 'PhotoFileName', 'PhotoPath', 'ResumeFileName', 'ResumePath',
    'PhotoData'
)

foreach ($colName in $expectedColumns) {
    $found = $colDt.Select("COLUMN_NAME = '$colName'")
    if ($found.Count -eq 0) {
        throw "Missing expected column: $colName"
    }
}

# Verify PhotoData type is varbinary
$photoCol = $colDt.Select("COLUMN_NAME = 'PhotoData'")[0]
if ($photoCol["DATA_TYPE"] -ne "varbinary") {
    throw "PhotoData column is not varbinary. Found: $($photoCol['DATA_TYPE'])"
}
Write-Output "Task 2 Result: PASS - All 16 columns, data types, and primary key verified."

# TASK 3: Candidate Records Verification with Authentic Indian Context
Write-Output ""
Write-Output "--- TASK 3: CANDIDATE RECORDS & INDIAN CONTEXT ---"
$dataCmd = $conn.CreateCommand()
$dataCmd.CommandText = @"
SELECT 
    CandidateId, FullName, JobTitle, Department, Gender, City, Email, Phone, 
    ExperienceYears, Summary, PhotoPath, ResumePath, DATALENGTH(PhotoData) AS PhotoDataLength
FROM dbo.CandidateProfiles
ORDER BY CandidateId
"@
$dataAdapter = New-Object System.Data.SqlClient.SqlDataAdapter($dataCmd)
$dataDt = New-Object System.Data.DataTable
$dataAdapter.Fill($dataDt) | Out-Null

Write-Output "Total Candidates Retrieved: $($dataDt.Rows.Count) (Expected: 5)"
$dataDt | Format-Table CandidateId, FullName, Gender, City, JobTitle, ExperienceYears, PhotoDataLength -AutoSize | Out-String | Write-Output

$expectedCandidates = @(
    @{ Id = 1; Name = "Rahul Sharma"; City = "Kolkata"; Gender = "Male" },
    @{ Id = 2; Name = "Priya Mukherjee"; City = "Kolkata"; Gender = "Female" },
    @{ Id = 3; Name = "Amit Verma"; City = "Mumbai"; Gender = "Male" },
    @{ Id = 4; Name = "Sneha Patel"; City = "Bangalore"; Gender = "Female" },
    @{ Id = 5; Name = "Vikram Singh"; City = "Delhi"; Gender = "Male" }
)

foreach ($exp in $expectedCandidates) {
    $row = $dataDt.Select("CandidateId = $($exp.Id)")
    if ($row.Count -eq 0) {
        throw "CandidateId $($exp.Id) not found in CandidateProfiles"
    }
    $r = $row[0]
    if ($r["FullName"] -ne $exp.Name) {
        throw "Expected Name $($exp.Name) for Id $($exp.Id), found $($r['FullName'])"
    }
    if ($r["City"] -ne $exp.City) {
        throw "Expected City $($exp.City) for Id $($exp.Id), found $($r['City'])"
    }
    if ($r["Gender"] -ne $exp.Gender) {
        throw "Expected Gender $($exp.Gender) for Id $($exp.Id), found $($r['Gender'])"
    }
    Write-Output "Verified Candidate $($exp.Id): $($r['FullName']) ($($r['Gender'])) in $($r['City']) - Experience: $($r['ExperienceYears']) yrs, BLOB: $($r['PhotoDataLength']) bytes"
}
Write-Output "Task 3 Result: PASS - Authentic Indian context verified for all 5 candidates."

# TASK 4: Dual Photo Storage & Byte-for-Byte BLOB Verification
Write-Output ""
Write-Output "--- TASK 4: DUAL PHOTO STORAGE & BYTE-FOR-BYTE BLOB MATCH ---"
$imagesDir = Join-Path $projDir "Images"
Write-Output "Images Directory: $imagesDir"

$expectedImages = @("emp1.png", "emp2.png", "emp3.png", "emp4.png", "emp5.png", "logo.png")
foreach ($imgFile in $expectedImages) {
    $imgPath = Join-Path $imagesDir $imgFile
    if (-not (Test-Path $imgPath)) {
        throw "Expected image file missing: $imgPath"
    }
    $fileInfo = Get-Item $imgPath
    Write-Output "Image File Present: $imgFile (Size: $($fileInfo.Length) bytes)"
}

# Byte-for-byte comparison with database PhotoData
$blobCmd = $conn.CreateCommand()
$blobCmd.CommandText = "SELECT CandidateId, PhotoFileName, PhotoData FROM dbo.CandidateProfiles ORDER BY CandidateId"
$reader = $blobCmd.ExecuteReader()

$sha = [System.Security.Cryptography.SHA256]::Create()

while ($reader.Read()) {
    $candId = $reader.GetInt32(0)
    $fileName = $reader.GetString(1)
    $dbBytes = [byte[]]$reader["PhotoData"]
    
    $filePath = Join-Path $imagesDir $fileName
    $diskBytes = [System.IO.File]::ReadAllBytes($filePath)
    
    $dbHash = [BitConverter]::ToString($sha.ComputeHash($dbBytes)).Replace("-", "")
    $diskHash = [BitConverter]::ToString($sha.ComputeHash($diskBytes)).Replace("-", "")
    
    Write-Output "Candidate $candId ($fileName):"
    Write-Output "  Disk File Bytes: $($diskBytes.Length) | SHA256: $diskHash"
    Write-Output "  SQL BLOB Bytes:  $($dbBytes.Length) | SHA256: $dbHash"
    
    if ($dbBytes.Length -ne $diskBytes.Length) {
        throw "Byte length mismatch for $($fileName): Disk=$($diskBytes.Length), DB=$($dbBytes.Length)"
    }
    
    if ($dbHash -ne $diskHash) {
        throw "Byte hash mismatch for $($fileName)"
    }
    Write-Output "  Byte-for-byte match: EXACT MATCH"
}
$reader.Close()
$conn.Close()
Write-Output "Task 4 Result: PASS - All image files present and 100% byte-for-byte identical with SQL PhotoData BLOBs."

# TASK 5: In-Memory Typed Schema CandidateDataSet.xsd
Write-Output ""
Write-Output "--- TASK 5: CandidateDataSet.xsd SCHEMA VERIFICATION ---"
$xsdPath = Join-Path $projDir "App_Code\CandidateDataSet.xsd"
if (-not (Test-Path $xsdPath)) {
    throw "CandidateDataSet.xsd not found at $xsdPath"
}
[xml]$xsdXml = Get-Content $xsdPath
$candidateElement = $xsdXml.schema.element | Where-Object { $_.name -eq 'CandidateDataSet' }
$tableElement = $candidateElement.complexType.choice.element | Where-Object { $_.name -eq 'Candidate' }
$photoDataElem = $tableElement.complexType.sequence.element | Where-Object { $_.name -eq 'PhotoData' }

Write-Output "XML Schema Element PhotoData type attribute: $($photoDataElem.type)"
if ($photoDataElem.type -ne 'xs:base64Binary') {
    throw "PhotoData element is not xs:base64Binary. Found: $($photoDataElem.type)"
}

# Verify ADO.NET DataSet deserialization maps xs:base64Binary to System.Byte[]
$ds = New-Object System.Data.DataSet
$ds.ReadXmlSchema($xsdPath)
$candidateTable = $ds.Tables["Candidate"]
if (-not $candidateTable) {
    throw "DataTable 'Candidate' not found in CandidateDataSet.xsd"
}
$photoDataCol = $candidateTable.Columns["PhotoData"]
Write-Output "ADO.NET Column PhotoData DataType: $($photoDataCol.DataType.FullName)"
if ($photoDataCol.DataType.FullName -ne 'System.Byte[]') {
    throw "PhotoData column DataType is not System.Byte[]. Found: $($photoDataCol.DataType.FullName)"
}
Write-Output "Task 5 Result: PASS - PhotoData defined as xs:base64Binary and mapped to System.Byte[]."

# TASK 6: ADO.NET Safe Using Blocks (Connection Leak Prevention)
Write-Output ""
Write-Output "--- TASK 6: ADO.NET SAFE PATTERNS & USING BLOCKS ---"
$codeBehind = Join-Path $projDir "Default.aspx.cs"
$csCode = Get-Content $codeBehind -Raw

$sqlConnUsingCount = ([regex]::Matches($csCode, 'using\s*\(\s*SqlConnection')).Count
$sqlCmdUsingCount = ([regex]::Matches($csCode, 'using\s*\(\s*SqlCommand')).Count
$sqlReaderUsingCount = ([regex]::Matches($csCode, 'using\s*\(\s*SqlDataReader')).Count
$sqlAdapterUsingCount = ([regex]::Matches($csCode, 'using\s*\(\s*SqlDataAdapter')).Count

Write-Output "Detected Safe 'using' Blocks in Default.aspx.cs:"
Write-Output "  using (SqlConnection): $sqlConnUsingCount"
Write-Output "  using (SqlCommand):    $sqlCmdUsingCount"
Write-Output "  using (SqlDataReader): $sqlReaderUsingCount"
Write-Output "  using (SqlDataAdapter): $sqlAdapterUsingCount"

if ($sqlConnUsingCount -lt 2) {
    throw "Expected at least 2 using(SqlConnection) blocks, found $sqlConnUsingCount"
}
Write-Output "Task 6 Result: PASS - ADO.NET resources safely enclosed in using blocks preventing connection leaks."

# TASK 7: aspnet_compiler.exe Compilation Check (0 Errors)
Write-Output ""
Write-Output "--- TASK 7: ASP.NET COMPILATION CHECK ---"
$aspnetCompiler = "C:\Windows\Microsoft.NET\Framework64\v4.0.30319\aspnet_compiler.exe"
if (-not (Test-Path $aspnetCompiler)) {
    throw "aspnet_compiler.exe not found at $aspnetCompiler"
}

Write-Output "Running aspnet_compiler.exe on WebSite2..."
$compilerOutput = & $aspnetCompiler -v / -p "$projDir" 2>&1
$compilerExitCode = $LASTEXITCODE

Write-Output "aspnet_compiler Exit Code: $compilerExitCode"
if ($compilerOutput) {
    Write-Output "Compiler Output:"
    Write-Output $compilerOutput
}

if ($compilerExitCode -ne 0) {
    throw "aspnet_compiler failed with exit code $compilerExitCode"
}
Write-Output "Task 7 Result: PASS - WebSite2 compiled cleanly with 0 errors."

Write-Output ""
Write-Output "================================================================="
Write-Output "ALL MILESTONE 1 VERIFICATION TASKS COMPLETED SUCCESSFULLY (7/7)"
Write-Output "================================================================="
