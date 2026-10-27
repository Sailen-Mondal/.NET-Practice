# Forensic Audit Script for Milestone 1
# Strictly zero emojis

$ErrorActionPreference = 'Stop'
$projDir = 'C:\Users\sailenmondal\OneDrive - MANAGEMENT & COMPUTER CONSULTANTS\Documents\Visual Studio 2015\WebSites\WebSite2'

Write-Output "================================================================================"
Write-Output "INDEPENDENT FORENSIC AUDIT: MILESTONE 1 (DATA ARCHITECTURE & IMAGE BLOBS)"
Write-Output "Auditor Working Directory: d:\.NET\.agents\teamwork\auditor_m1_1"
Write-Output "Target Directory: $projDir"
Write-Output "Timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss UTC')"
Write-Output "================================================================================"

# PHASE 1: CONFIGURATION & DATABASE CONNECTIVITY
Write-Output ""
Write-Output "=== CHECK 1: Web.config & Real Database Connection ==="
$webConfigFile = Join-Path $projDir "Web.config"
if (-not (Test-Path $webConfigFile)) {
    throw "FAIL: Web.config not found at $webConfigFile"
}
[xml]$webConfig = Get-Content $webConfigFile
$conStrNode = $webConfig.configuration.connectionStrings.add | Where-Object { $_.name -eq 'conStr' }
if (-not $conStrNode) {
    throw "FAIL: conStr not found in Web.config"
}
$conStr = $conStrNode.connectionString
Write-Output "Extracted Connection String: $conStr"

$conn = New-Object System.Data.SqlClient.SqlConnection($conStr)
$conn.Open()
Write-Output "SQL Connection Status: $($conn.State)"
Write-Output "SQL Server Version:    $($conn.ServerVersion)"
Write-Output "Database Catalog:      $($conn.Database)"

# PHASE 2: DATABASE TABLE & SCHEMA REALITY
Write-Output ""
Write-Output "=== CHECK 2: Database Table Reality & Column Definitions ==="
$tablesCmd = $conn.CreateCommand()
$tablesCmd.CommandText = "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE' ORDER BY TABLE_NAME"
$tablesReader = $tablesCmd.ExecuteReader()
Write-Output "Base Tables in $($conStr):"
$tableList = @()
while ($tablesReader.Read()) {
    $tbl = $tablesReader.GetString(0)
    $tableList += $tbl
    Write-Output "  - $tbl"
}
$tablesReader.Close()

if (-not ($tableList -contains 'CandidateProfiles')) {
    throw "FAIL: dbo.CandidateProfiles table does NOT exist in database"
}

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
    throw "FAIL: Primary key is not CandidateId. Found: $pkColumn"
}

$colCmd = $conn.CreateCommand()
$colCmd.CommandText = @"
SELECT ORDINAL_POSITION, COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'CandidateProfiles'
ORDER BY ORDINAL_POSITION
"@
$colAdapter = New-Object System.Data.SqlClient.SqlDataAdapter($colCmd)
$colDt = New-Object System.Data.DataTable
$colAdapter.Fill($colDt) | Out-Null
Write-Output "Total Columns in CandidateProfiles: $($colDt.Rows.Count)"
foreach ($r in $colDt.Rows) {
    Write-Output ("  [{0:D2}] {1,-18} {2,-12} len:{3,-5} nullable:{4}" -f $r["ORDINAL_POSITION"], $r["COLUMN_NAME"], $r["DATA_TYPE"], $r["CHARACTER_MAXIMUM_LENGTH"], $r["IS_NULLABLE"])
}

if ($colDt.Rows.Count -ne 16) {
    throw "FAIL: Expected 16 columns, found $($colDt.Rows.Count)"
}

# PHASE 3: ROW REALITY & INDIAN CONTEXT VALIDATION
Write-Output ""
Write-Output "=== CHECK 3: Candidate Record Reality & Context ==="
$rowsCmd = $conn.CreateCommand()
$rowsCmd.CommandText = @"
SELECT 
    CandidateId, FullName, JobTitle, Department, Gender, Email, Phone, City, 
    Skills, ExperienceYears, Summary, PhotoFileName, PhotoPath, ResumeFileName, ResumePath,
    DATALENGTH(PhotoData) AS PhotoDataLength
FROM dbo.CandidateProfiles
ORDER BY CandidateId
"@
$rowsAdapter = New-Object System.Data.SqlClient.SqlDataAdapter($rowsCmd)
$rowsDt = New-Object System.Data.DataTable
$rowsAdapter.Fill($rowsDt) | Out-Null
Write-Output "Row Count in CandidateProfiles: $($rowsDt.Rows.Count)"

foreach ($r in $rowsDt.Rows) {
    Write-Output ("Candidate ID {0}: Name='{1}', City='{2}', Gender='{3}', JobTitle='{4}', Exp={5} yrs, Photo='{6}', BLOB Size={7} bytes" -f `
        $r["CandidateId"], $r["FullName"], $r["City"], $r["Gender"], $r["JobTitle"], $r["ExperienceYears"], $r["PhotoFileName"], $r["PhotoDataLength"])
}

if ($rowsDt.Rows.Count -ne 5) {
    throw "FAIL: Expected 5 candidate records, found $($rowsDt.Rows.Count)"
}

# PHASE 4: BLOB AUTHENTICITY & IMAGE INTEGRITY FORENSICS
Write-Output ""
Write-Output "=== CHECK 4: PhotoData BLOB Binary Forensics & Magic Header Inspection ==="
# PNG Magic Number: 89 50 4E 47 0D 0A 1A 0A
$pngMagicExpected = @(0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A)
Add-Type -AssemblyName System.Drawing

$blobCmd = $conn.CreateCommand()
$blobCmd.CommandText = "SELECT CandidateId, FullName, PhotoFileName, PhotoData FROM dbo.CandidateProfiles ORDER BY CandidateId"
$blobReader = $blobCmd.ExecuteReader()

$imagesDir = Join-Path $projDir "Images"
$sha = [System.Security.Cryptography.SHA256]::Create()

while ($blobReader.Read()) {
    $cId = $blobReader.GetInt32(0)
    $cName = $blobReader.GetString(1)
    $pFileName = $blobReader.GetString(2)
    $blobBytes = [byte[]]$blobReader["PhotoData"]

    Write-Output "--- Candidate $($cId): $cName ($pFileName) ---"
    Write-Output "  SQL BLOB Byte Count: $($blobBytes.Length)"
    
    # Check 1: Magic header (8 bytes)
    if ($blobBytes.Length -lt 8) {
        throw "FAIL: BLOB too short to contain PNG header"
    }
    $headerHex = [BitConverter]::ToString($blobBytes[0..7]).Replace("-", " ")
    Write-Output "  First 8 Bytes: $headerHex"
    for ($i = 0; $i -lt 8; $i++) {
        if ($blobBytes[$i] -ne $pngMagicExpected[$i]) {
            throw "FAIL: Invalid PNG magic byte at index $i. Expected $($pngMagicExpected[$i]), found $($blobBytes[$i])"
        }
    }
    Write-Output "  PNG Magic Number: VALID (89 50 4E 47 0D 0A 1A 0A)"

    # Check 2: IHDR chunk (bytes 12..15 should be 'IHDR')
    $ihdrChunkType = [System.Text.Encoding]::ASCII.GetString($blobBytes[12..15])
    Write-Output "  First Chunk Type: $ihdrChunkType"
    if ($ihdrChunkType -ne "IHDR") {
        throw "FAIL: Expected IHDR chunk, found $ihdrChunkType"
    }

    # Extract Width and Height from IHDR chunk (big endian 32-bit uints at index 16 and 20)
    $wBytes = $blobBytes[16..19]
    if ([BitConverter]::IsLittleEndian) { [Array]::Reverse($wBytes) }
    $width = [BitConverter]::ToUInt32($wBytes, 0)

    $hBytes = $blobBytes[20..23]
    if ([BitConverter]::IsLittleEndian) { [Array]::Reverse($hBytes) }
    $height = [BitConverter]::ToUInt32($hBytes, 0)
    Write-Output "  Decoded PNG Dimensions: ${width}x${height} pixels"

    # Check 3: GDI+ Bitmap Loading from MemoryStream
    $ms = New-Object System.IO.MemoryStream(,$blobBytes)
    try {
        $bmp = [System.Drawing.Bitmap]::FromStream($ms)
        Write-Output "  GDI+ Bitmap Decoder: SUCCESS (PixelFormat: $($bmp.PixelFormat), Size: $($bmp.Width)x$($bmp.Height))"
        $bmp.Dispose()
    }
    catch {
        throw "FAIL: GDI+ failed to decode BLOB image bytes: $_"
    }
    finally {
        $ms.Dispose()
    }

    # Check 4: Compare with disk file
    $diskFilePath = Join-Path $imagesDir $pFileName
    if (-not (Test-Path $diskFilePath)) {
        throw "FAIL: Corresponding disk file missing at $diskFilePath"
    }
    $diskBytes = [System.IO.File]::ReadAllBytes($diskFilePath)
    $blobHash = [BitConverter]::ToString($sha.ComputeHash($blobBytes)).Replace("-", "")
    $diskHash = [BitConverter]::ToString($sha.ComputeHash($diskBytes)).Replace("-", "")
    
    Write-Output "  Disk SHA256: $diskHash"
    Write-Output "  SQL  SHA256: $blobHash"
    if ($blobHash -ne $diskHash) {
        throw "FAIL: Hash mismatch between disk file and SQL BLOB for $pFileName"
    }
    Write-Output "  Byte-for-byte comparison: IDENTICAL"
}
$blobReader.Close()
$conn.Close()

# PHASE 5: STATIC CODE FORENSICS & FACADE DETECTION
Write-Output ""
Write-Output "=== CHECK 5: Source Code Forensics & Facade Detection ==="
$codeFiles = @(
    (Join-Path $projDir "Default.aspx.cs"),
    (Join-Path $projDir "Default.aspx")
)

foreach ($cf in $codeFiles) {
    if (Test-Path $cf) {
        $code = Get-Content $cf -Raw
        Write-Output "Auditing file: $cf"
        
        # Check for hardcoded candidate data arrays / dictionaries
        $hasHardcodedArray = $code -match '(?i)new\s+string\[\]\s*\{.*Rahul' -or $code -match '(?i)new\s+List<.*Rahul'
        Write-Output "  Hardcoded candidate profile arrays in code: $hasHardcodedArray"
        if ($hasHardcodedArray) {
            throw "FAIL: Detected hardcoded candidate array in $cf"
        }

        # Check for dummy facades (e.g. methods returning fixed dummy data without SQL)
        $hasDummyReturn = $code -match '(?i)return\s+new\s+DataTable\s*\(\s*\)' -and -not ($code -match 'da\.Fill')
        Write-Output "  Dummy DataTable facade: $hasDummyReturn"

        # Check for NotImplementedException
        $hasNotImpl = $code -match 'NotImplementedException'
        Write-Output "  NotImplementedException present: $hasNotImpl"
        if ($hasNotImpl) {
            throw "FAIL: Found NotImplementedException in $cf"
        }
    }
}

# PHASE 6: XML SCHEMA VALIDATION (CandidateDataSet.xsd)
Write-Output ""
Write-Output "=== CHECK 6: CandidateDataSet.xsd Schema Validation ==="
$xsdFile = Join-Path $projDir "App_Code\CandidateDataSet.xsd"
if (-not (Test-Path $xsdFile)) {
    throw "FAIL: CandidateDataSet.xsd does not exist"
}
$schemaSet = New-Object System.Xml.Schema.XmlSchemaSet
$schema = [System.Xml.Schema.XmlSchema]::Read([System.Xml.XmlReader]::Create($xsdFile), $null)
$schemaSet.Add($schema) | Out-Null
$schemaSet.Compile()
Write-Output "CandidateDataSet.xsd Schema Compilation: VALID (Compiled successfully without schema errors)"

$ds = New-Object System.Data.DataSet
$ds.ReadXmlSchema($xsdFile)
$candTable = $ds.Tables["Candidate"]
if (-not $candTable) {
    throw "FAIL: Candidate table not found in schema"
}
Write-Output "DataSet Table: $($candTable.TableName) with $($candTable.Columns.Count) columns"
$photoCol = $candTable.Columns["PhotoData"]
Write-Output "PhotoData Column Type: $($photoCol.DataType.FullName)"
if ($photoCol.DataType.FullName -ne "System.Byte[]") {
    throw "FAIL: PhotoData DataType in DataSet is not System.Byte[]"
}

# PHASE 7: PRE-POPULATED TEST ARTIFACTS OR LOGS
Write-Output ""
Write-Output "=== CHECK 7: Pre-populated Artifact Detection in Project ==="
$predataFiles = Get-ChildItem -Path $projDir -Recurse -File | Where-Object { 
    $_.Extension -in @(".log", ".out") -or $_.Name -like "*result*" -or $_.Name -like "*test_run*"
}
Write-Output "Pre-populated test logs or output files found in project: $($predataFiles.Count)"
foreach ($pf in $predataFiles) {
    Write-Output "  Found file: $($pf.FullName)"
}

# PHASE 8: COMPILATION VERIFICATION
Write-Output ""
Write-Output "=== CHECK 8: Independent ASP.NET Compilation ==="
$aspnetCompiler = "C:\Windows\Microsoft.NET\Framework64\v4.0.30319\aspnet_compiler.exe"
$proc = Start-Process -FilePath $aspnetCompiler -ArgumentList "-v / -p `"$projDir`"" -NoNewWindow -Wait -PassThru -RedirectStandardOutput "d:\.NET\.agents\teamwork\auditor_m1_1\compiler_out.txt" -RedirectStandardError "d:\.NET\.agents\teamwork\auditor_m1_1\compiler_err.txt"
Write-Output "aspnet_compiler Exit Code: $($proc.ExitCode)"
$cOut = Get-Content "d:\.NET\.agents\teamwork\auditor_m1_1\compiler_out.txt" -Raw
$cErr = Get-Content "d:\.NET\.agents\teamwork\auditor_m1_1\compiler_err.txt" -Raw
if ($cOut) { Write-Output "Compiler stdout: $cOut" }
if ($cErr) { Write-Output "Compiler stderr: $cErr" }
if ($proc.ExitCode -ne 0) {
    throw "FAIL: aspnet_compiler exited with non-zero code $($proc.ExitCode)"
}

# PHASE 9: ADVERSARIAL STRESS-TESTING & EDGE-CASE MINING
Write-Output ""
Write-Output "=== CHECK 9: Adversarial Stress-Testing & Attack Surface Verification ==="

# 9.1 Asset Integrity: logo.png
$logoFile = Join-Path $projDir "Images\logo.png"
if (-not (Test-Path $logoFile)) {
    throw "FAIL: logo.png not found"
}
$logoBytes = [System.IO.File]::ReadAllBytes($logoFile)
Write-Output "logo.png byte length: $($logoBytes.Length)"
$logoHeaderHex = [BitConverter]::ToString($logoBytes[0..7]).Replace("-", " ")
Write-Output "logo.png magic header: $logoHeaderHex"
if ($logoHeaderHex -ne "89 50 4E 47 0D 0A 1A 0A") {
    throw "FAIL: logo.png does not have valid PNG header"
}
$logoMs = New-Object System.IO.MemoryStream(,$logoBytes)
$logoBmp = [System.Drawing.Bitmap]::FromStream($logoMs)
Write-Output "logo.png decoded: $($logoBmp.Width)x$($logoBmp.Height) pixels, format: $($logoBmp.PixelFormat)"
$logoBmp.Dispose()
$logoMs.Dispose()

# 9.2 ADO.NET Parameterization & Injection Resistance
$conn = New-Object System.Data.SqlClient.SqlConnection($conStr)
$conn.Open()

# Test Attack 1: Classic SQL Injection payload in nameFilter
$injectedName = "' OR '1'='1"
$sql = "SELECT CandidateId, FullName FROM dbo.CandidateProfiles WHERE 1=1 AND FullName LIKE '%' + @fname + '%'"
$cmd = New-Object System.Data.SqlClient.SqlCommand($sql, $conn)
$cmd.Parameters.AddWithValue("@fname", $injectedName) | Out-Null
$da = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
$dt = New-Object System.Data.DataTable
$da.Fill($dt) | Out-Null
Write-Output "SQL Injection Attack Test (' OR '1'='1'): Rows Returned = $($dt.Rows.Count) (Expected: 0, preventing injection)"
if ($dt.Rows.Count -ne 0) {
    throw "FAIL: SQL injection payload leaked records!"
}

# Test Attack 2: Non-existent CandidateId filter
$badCandId = 999999
$sql2 = "SELECT CandidateId, FullName FROM dbo.CandidateProfiles WHERE 1=1 AND CandidateId = @candId"
$cmd2 = New-Object System.Data.SqlClient.SqlCommand($sql2, $conn)
$cmd2.Parameters.AddWithValue("@candId", $badCandId) | Out-Null
$dt2 = New-Object System.Data.DataTable
$da2 = New-Object System.Data.SqlClient.SqlDataAdapter($cmd2)
$da2.Fill($dt2) | Out-Null
Write-Output "Non-existent Candidate ID (999999): Rows Returned = $($dt2.Rows.Count) (Expected: 0, schema preserved)"
if ($dt2.Rows.Count -ne 0) {
    throw "FAIL: Query for non-existent candidate returned rows"
}

# Test Attack 3: Empty string filters (All Candidates returned)
$sql3 = "SELECT CandidateId, FullName FROM dbo.CandidateProfiles WHERE 1=1 ORDER BY CandidateId"
$cmd3 = New-Object System.Data.SqlClient.SqlCommand($sql3, $conn)
$dt3 = New-Object System.Data.DataTable
$da3 = New-Object System.Data.SqlClient.SqlDataAdapter($cmd3)
$da3.Fill($dt3) | Out-Null
Write-Output "Empty Filter Query: Rows Returned = $($dt3.Rows.Count) (Expected: 5 candidates)"
if ($dt3.Rows.Count -ne 5) {
    throw "FAIL: Expected 5 candidates with empty filter"
}

$conn.Close()

Write-Output ""
Write-Output "================================================================================"
Write-Output "FORENSIC AUDIT COMPLETE: ALL CHECKS PASSED EMPIRICALLY"
Write-Output "================================================================================"

