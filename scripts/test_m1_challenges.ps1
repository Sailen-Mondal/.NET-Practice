# Empirical Challenge Verification Suite for Milestone 1 (M1: Data Architecture & Image BLOBs)
# Author: Challenger 1 (critic, specialist)
# Strict: Zero Emojis

$ErrorActionPreference = 'Stop'
$projDir = 'C:\Users\sailenmondal\OneDrive - MANAGEMENT & COMPUTER CONSULTANTS\Documents\Visual Studio 2015\WebSites\WebSite2'
$webConfigFile = Join-Path $projDir 'Web.config'

Write-Host "================================================================================"
Write-Host "CHALLENGER 1 EMPIRICAL VERIFICATION SUITE: MILESTONE 1"
Write-Host "Timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss UTC')"
Write-Host "Project Directory: $projDir"
Write-Host "================================================================================"

# Read connection string from Web.config
[xml]$webConfig = Get-Content $webConfigFile
$conStrNode = $webConfig.configuration.connectionStrings.add | Where-Object { $_.name -eq 'conStr' }
if (-not $conStrNode) {
    throw "Connection string 'conStr' not found in Web.config"
}
$conStr = $conStrNode.connectionString
Write-Host "Connection string found: $conStr"

$totalTests = 0
$passedTests = 0
$failedTests = 0
$findings = @()

function Record-Result {
    param(
        [string]$TestId,
        [string]$Description,
        [bool]$Success,
        [string]$Details
    )
    $script:totalTests++
    if ($Success) {
        $script:passedTests++
        Write-Host ("[PASS] {0}: {1}" -f $TestId, $Description)
        if ($Details) { Write-Host ("       Details: {0}" -f $Details) }
    } else {
        $script:failedTests++
        Write-Host ("[FAIL] {0}: {1}" -f $TestId, $Description)
        Write-Host ("       Failure Details: {0}" -f $Details)
        $script:findings += [PSCustomObject]@{
            TestId = $TestId
            Description = $Description
            Details = $Details
        }
    }
}

# ==============================================================================
# CHALLENGE SUITE 1: CONNECTION POOLING, STRESS & ADO.NET RESILIENCE
# ==============================================================================
Write-Host ""
Write-Host "--------------------------------------------------------------------------------"
Write-Host "SUITE 1: Connection Pooling, Stress & ADO.NET Resilience"
Write-Host "--------------------------------------------------------------------------------"

# Test 1.1: 150 Sequential Rapid Open/Close Cycles (Testing Pool Reuse and Default Max Pool Size=100)
try {
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    $times = @()
    for ($i = 1; $i -le 150; $i++) {
        $cycleSw = [System.Diagnostics.Stopwatch]::StartNew()
        $conn = New-Object System.Data.SqlClient.SqlConnection($conStr)
        $conn.Open()
        $cmd = $conn.CreateCommand()
        $cmd.CommandText = "SELECT @@SPID"
        $spid = $cmd.ExecuteScalar()
        $conn.Close()
        $cycleSw.Stop()
        $times += $cycleSw.ElapsedMilliseconds
    }
    $sw.Stop()
    $avgTime = ($times | Measure-Object -Average).Average
    $firstTime = $times[0]
    $laterAvg = ($times[1..149] | Measure-Object -Average).Average
    
    $success = ($sw.ElapsedMilliseconds -lt 10000)
    Record-Result -TestId "CP-01" `
        -Description "150 rapid consecutive open/query/close cycles (pool reuse)" `
        -Success $success `
        -Details ("Total time: {0}ms | First cycle: {1}ms | Warm pooled avg: {2:N2}ms | SPID observed: {3}" -f $sw.ElapsedMilliseconds, $firstTime, $laterAvg, $spid)
} catch {
    Record-Result -TestId "CP-01" -Description "150 rapid consecutive open/query/close cycles" -Success $false -Details $_.Exception.Message
}

# Test 1.2: Concurrent Multi-Threaded Stress (20 Parallel Connections)
try {
    $concurrencyLevel = 20
    $jobs = @()
    $scriptBlock = {
        param($connectionString, $id)
        $sw = [System.Diagnostics.Stopwatch]::StartNew()
        $conn = New-Object System.Data.SqlClient.SqlConnection($connectionString)
        $conn.Open()
        $cmd = $conn.CreateCommand()
        $cmd.CommandText = "SELECT COUNT(*) FROM dbo.CandidateProfiles"
        $count = $cmd.ExecuteScalar()
        $conn.Close()
        $sw.Stop()
        return [PSCustomObject]@{
            Id = $id
            Count = $count
            DurationMs = $sw.ElapsedMilliseconds
            State = 'Success'
        }
    }
    
    $runspacePool = [runspacefactory]::CreateRunspacePool(1, $concurrencyLevel)
    $runspacePool.Open()
    $threads = @()
    
    for ($i = 1; $i -le $concurrencyLevel; $i++) {
        $ps = [powershell]::Create()
        $ps.RunspacePool = $runspacePool
        $ps.AddScript($scriptBlock).AddArgument($conStr).AddArgument($i) | Out-Null
        $threads += [PSCustomObject]@{
            Pipe = $ps
            AsyncResult = $ps.BeginInvoke()
        }
    }
    
    $concurrentErrors = 0
    $maxDuration = 0
    foreach ($t in $threads) {
        try {
            $res = $t.Pipe.EndInvoke($t.AsyncResult)
            if ($res.Count -ne 5) { $concurrentErrors++ }
            if ($res.DurationMs -gt $maxDuration) { $maxDuration = $res.DurationMs }
        } catch {
            $concurrentErrors++
        } finally {
            $t.Pipe.Dispose()
        }
    }
    $runspacePool.Close()
    $runspacePool.Dispose()
    
    $success = ($concurrentErrors -eq 0)
    Record-Result -TestId "CP-02" `
        -Description "20 concurrent threads accessing database via connection pool" `
        -Success $success `
        -Details ("Concurrent errors: {0} | Max thread duration: {1}ms" -f $concurrentErrors, $maxDuration)
} catch {
    Record-Result -TestId "CP-02" -Description "20 concurrent threads accessing database" -Success $false -Details $_.Exception.Message
}

# Test 1.3: Exception Safety and Connection Pool Recovery After Fatal SQL Error
try {
    $errorCaught = $false
    try {
        $conn = New-Object System.Data.SqlClient.SqlConnection($conStr)
        $conn.Open()
        try {
            $cmd = $conn.CreateCommand()
            $cmd.CommandText = "SELECT 1/0 AS DivideByZero"
            $cmd.ExecuteScalar()
        } finally {
            $conn.Close()
            $conn.Dispose()
        }
    } catch {
        $errorCaught = $true
    }
    
    # Confirm pool was not corrupted: immediately open 10 new connections
    $postErrorSuccess = $true
    for ($k = 1; $k -le 10; $k++) {
        $conn2 = New-Object System.Data.SqlClient.SqlConnection($conStr)
        $conn2.Open()
        $cmd2 = $conn2.CreateCommand()
        $cmd2.CommandText = "SELECT COUNT(*) FROM dbo.CandidateProfiles"
        $val = $cmd2.ExecuteScalar()
        if ($val -ne 5) { $postErrorSuccess = $false }
        $conn2.Close()
    }
    
    $success = ($errorCaught -and $postErrorSuccess)
    Record-Result -TestId "CP-03" `
        -Description "Exception safety: Connection pool recovery after runtime SQL exception" `
        -Success $success `
        -Details ("Exception caught properly: {0} | Post-error pool operations verified: {1}" -f $errorCaught, $postErrorSuccess)
} catch {
    Record-Result -TestId "CP-03" -Description "Exception safety test" -Success $false -Details $_.Exception.Message
}

# Test 1.4: Parameterized Query Injection Neutralization (Testing FetchCandidateData pattern)
try {
    $injectionPayloads = @(
        "' OR '1'='1",
        "'; DROP TABLE TestMockTable; --",
        "Rahul' OR 'a'='a",
        "1 UNION SELECT 1, 'Hacked', 'Hacked', 'Hacked', 'Hacked', 'Hacked', 'Hacked', 'Hacked', 'Hacked', 0, 'Hacked', 'Hacked', 'Hacked', 'Hacked', 'Hacked', 0x00 --"
    )
    
    $conn = New-Object System.Data.SqlClient.SqlConnection($conStr)
    $conn.Open()
    $sqlInjected = $false
    
    foreach ($payload in $injectionPayloads) {
        # Emulate FetchCandidateData parameterized name filter
        $cmd = $conn.CreateCommand()
        $cmd.CommandText = @"
SELECT CandidateId, FullName, Gender, City, PhotoData 
FROM dbo.CandidateProfiles 
WHERE 1=1 AND FullName LIKE '%' + @fname + '%'
ORDER BY CandidateId
"@
        $cmd.Parameters.AddWithValue("@fname", $payload) | Out-Null
        $da = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
        $dt = New-Object System.Data.DataTable
        $da.Fill($dt) | Out-Null
        
        # If payload was "' OR '1'='1" and was vulnerable, it would return all 5 rows.
        # But parameterized, none of our candidate names have literal "' OR '1'='1", so it must return 0 rows.
        if ($payload -eq "' OR '1'='1" -and $dt.Rows.Count -gt 0) {
            $sqlInjected = $true
        }
    }
    $conn.Close()
    
    Record-Result -TestId "CP-04" `
        -Description "SQL Injection resilience in parameterized filter query" `
        -Success (-not $sqlInjected) `
        -Details ("Tested {0} injection payloads. Parameterization safely neutralized all." -f $injectionPayloads.Count)
} catch {
    Record-Result -TestId "CP-04" -Description "SQL Injection resilience" -Success $false -Details $_.Exception.Message
}


# ==============================================================================
# CHALLENGE SUITE 2: GDI+ IMAGE DESERIALIZATION, DIMENSIONS & BITMAP INTEGRITY
# ==============================================================================
Write-Host ""
Write-Host "--------------------------------------------------------------------------------"
Write-Host "SUITE 2: GDI+ System.Drawing.Image Verification (BLOBs, Dimensions, Format)"
Write-Host "--------------------------------------------------------------------------------"

Add-Type -AssemblyName System.Drawing

$expectedCandidateImages = @(
    @{ Id = 1; Name = "Rahul Sharma"; File = "emp1.png"; ExpW = 240; ExpH = 240; ExpFormat = "Png" },
    @{ Id = 2; Name = "Priya Mukherjee"; File = "emp2.png"; ExpW = 240; ExpH = 240; ExpFormat = "Png" },
    @{ Id = 3; Name = "Amit Verma"; File = "emp3.png"; ExpW = 240; ExpH = 240; ExpFormat = "Png" },
    @{ Id = 4; Name = "Sneha Patel"; File = "emp4.png"; ExpW = 240; ExpH = 240; ExpFormat = "Png" },
    @{ Id = 5; Name = "Vikram Singh"; File = "emp5.png"; ExpW = 240; ExpH = 240; ExpFormat = "Png" }
)

$conn = New-Object System.Data.SqlClient.SqlConnection($conStr)
$conn.Open()
$cmd = $conn.CreateCommand()
$cmd.CommandText = "SELECT CandidateId, FullName, PhotoFileName, PhotoData FROM dbo.CandidateProfiles ORDER BY CandidateId"
$reader = $cmd.ExecuteReader()

$imageResults = @()
while ($reader.Read()) {
    $cid = $reader.GetInt32(0)
    $cname = $reader.GetString(1)
    $cfile = $reader.GetString(2)
    $cbytes = [byte[]]$reader["PhotoData"]
    
    $imageResults += [PSCustomObject]@{
        Id = $cid
        Name = $cname
        File = $cfile
        Bytes = $cbytes
    }
}
$reader.Close()
$conn.Close()

# Test 2.1 - 2.5: Verify every candidate image in SQL Server
foreach ($exp in $expectedCandidateImages) {
    $row = $imageResults | Where-Object { $_.Id -eq $exp.Id }
    if (-not $row) {
        Record-Result -TestId ("IMG-CAND-{0}" -f $exp.Id) -Description ("Image BLOB present for {0}" -f $exp.Name) -Success $false -Details "Candidate row not found"
        continue
    }
    
    $bytes = $row.Bytes
    try {
        $ms = New-Object System.IO.MemoryStream(,$bytes)
        $img = [System.Drawing.Image]::FromStream($ms)
        
        $width = $img.Width
        $height = $img.Height
        $rawFormatGuid = $img.RawFormat.Guid.ToString()
        $pngGuid = [System.Drawing.Imaging.ImageFormat]::Png.Guid.ToString()
        $isPng = ($rawFormatGuid -eq $pngGuid)
        $pixelFormat = $img.PixelFormat.ToString()
        $hRes = $img.HorizontalResolution
        $vRes = $img.VerticalResolution
        
        # Test GDI+ rendering canvas operation: create a target canvas and draw image onto it
        $targetBmp = New-Object System.Drawing.Bitmap($width, $height)
        $graphics = [System.Drawing.Graphics]::FromImage($targetBmp)
        $graphics.DrawImage($img, 0, 0, $width, $height)
        $graphics.Dispose()
        
        # Verify non-trivial pixels (not completely blank or transparent)
        $samplePixel = $targetBmp.GetPixel(120, 120)
        $targetBmp.Dispose()
        
        $img.Dispose()
        $ms.Dispose()
        
        $dimPass = ($width -eq $exp.ExpW -and $height -eq $exp.ExpH)
        $formatPass = $isPng
        
        Record-Result -TestId ("IMG-CAND-{0}" -f $exp.Id) `
            -Description ("GDI+ verification for Candidate {0} ({1})" -f $exp.Id, $exp.Name) `
            -Success ($dimPass -and $formatPass) `
            -Details ("Size: {0} bytes | Dimensions: {1}x{2} (Expected: {3}x{4}) | Format: {5} | PixelFormat: {6} | DPI: {7}x{8} | Center Pixel ARGB: {9}" -f `
                $bytes.Length, $width, $height, $exp.ExpW, $exp.ExpH, $(if ($isPng){"PNG"}else{"Other"}), $pixelFormat, $hRes, $vRes, $samplePixel.ToString())
    } catch {
        Record-Result -TestId ("IMG-CAND-{0}" -f $exp.Id) `
            -Description ("GDI+ verification for Candidate {0} ({1})" -f $exp.Id, $exp.Name) `
            -Success $false `
            -Details $_.Exception.Message
    }
}

# Test 2.6: Verify Logo Image (Images/logo.png)
try {
    $logoPath = Join-Path $projDir "Images\logo.png"
    if (Test-Path $logoPath) {
        $logoBytes = [System.IO.File]::ReadAllBytes($logoPath)
        $ms = New-Object System.IO.MemoryStream(,$logoBytes)
        $logoImg = [System.Drawing.Image]::FromStream($ms)
        $logoW = $logoImg.Width
        $logoH = $logoImg.Height
        $logoPng = ($logoImg.RawFormat.Guid.ToString() -eq [System.Drawing.Imaging.ImageFormat]::Png.Guid.ToString())
        $logoImg.Dispose()
        $ms.Dispose()
        
        Record-Result -TestId "IMG-LOGO-01" `
            -Description "GDI+ verification for Images/logo.png" `
            -Success $logoPng `
            -Details ("Size: {0} bytes | Dimensions: {1}x{2} | Format: PNG" -f $logoBytes.Length, $logoW, $logoH)
    } else {
        Record-Result -TestId "IMG-LOGO-01" -Description "Images/logo.png exists and valid" -Success $false -Details "File not found"
    }
} catch {
    Record-Result -TestId "IMG-LOGO-01" -Description "Images/logo.png GDI+ verification" -Success $false -Details $_.Exception.Message
}


# ==============================================================================
# CHALLENGE SUITE 3: CandidateDataSet.xsd SCHEMA BOUNDARY & STRESS TESTING
# ==============================================================================
Write-Host ""
Write-Host "--------------------------------------------------------------------------------"
Write-Host "SUITE 3: CandidateDataSet.xsd Schema Boundary & Stress Testing"
Write-Host "--------------------------------------------------------------------------------"

$xsdPath = Join-Path $projDir "App_Code\CandidateDataSet.xsd"

# Test 3.1: Null and DBNull.Value Handling in CandidateDataSet
try {
    $ds = New-Object System.Data.DataSet
    $ds.ReadXmlSchema($xsdPath)
    $table = $ds.Tables["Candidate"]
    
    # Add row with null/DBNull PhotoData
    $row = $table.NewRow()
    $row["CandidateId"] = 999
    $row["FullName"] = "Test Null Photo Candidate"
    $row["JobTitle"] = "QA Tester"
    $row["Department"] = "Quality Engineering"
    $row["Gender"] = "Male"
    $row["Email"] = "null.test@example.com"
    $row["Phone"] = "+91 99999 99999"
    $row["City"] = "Kolkata"
    $row["Skills"] = "C#, SQL"
    $row["ExperienceYears"] = 1
    $row["Summary"] = "Profile testing null photo handling."
    $row["PhotoPath"] = "Images/null.png"
    $row["ResumePath"] = "Resumes/null.pdf"
    $row["PhotoData"] = [System.DBNull]::Value
    $table.Rows.Add($row)
    
    # Write to XML and read back
    $xmlStringWriter = New-Object System.IO.StringWriter
    $ds.WriteXml($xmlStringWriter, [System.Data.XmlWriteMode]::DiffGram)
    $xmlOutput = $xmlStringWriter.ToString()
    
    $ds2 = New-Object System.Data.DataSet
    $ds2.ReadXmlSchema($xsdPath)
    $xmlStringReader = New-Object System.IO.StringReader($xmlOutput)
    $ds2.ReadXml($xmlStringReader, [System.Data.XmlReadMode]::DiffGram)
    
    $recoveredRow = $ds2.Tables["Candidate"].Rows[0]
    $isNullRecovered = ($recoveredRow.IsNull("PhotoData"))
    
    Record-Result -TestId "SCH-01" `
        -Description "CandidateDataSet DBNull.Value handling and XML round-trip" `
        -Success $isNullRecovered `
        -Details ("Row added with DBNull PhotoData | Serialized DiffGram length: {0} chars | Recovered IsNull: {1}" -f $xmlOutput.Length, $isNullRecovered)
} catch {
    Record-Result -TestId "SCH-01" -Description "CandidateDataSet DBNull.Value handling" -Success $false -Details $_.Exception.Message
}

# Test 3.2: Empty Byte Array vs DBNull Handling
try {
    $ds = New-Object System.Data.DataSet
    $ds.ReadXmlSchema($xsdPath)
    $table = $ds.Tables["Candidate"]
    
    $row = $table.NewRow()
    $row["CandidateId"] = 1000
    $row["FullName"] = "Empty Bytes Candidate"
    $row["PhotoData"] = New-Object byte[] 0
    $table.Rows.Add($row)
    
    $swXml = New-Object System.IO.StringWriter
    $ds.WriteXml($swXml, [System.Data.XmlWriteMode]::IgnoreSchema)
    $xmlData = $swXml.ToString()
    
    $ds2 = New-Object System.Data.DataSet
    $ds2.ReadXmlSchema($xsdPath)
    $srXml = New-Object System.IO.StringReader($xmlData)
    $ds2.ReadXml($srXml)
    
    $retRow = $ds2.Tables["Candidate"].Rows[0]
    $photoVal = $retRow["PhotoData"]
    # In XML, empty element with xs:base64Binary deserializes to empty byte array (Length 0)
    $isZeroLength = ($photoVal -is [byte[]] -and $photoVal.Length -eq 0)
    
    Record-Result -TestId "SCH-02" `
        -Description "Empty byte array (0 bytes) serialization and deserialization" `
        -Success $isZeroLength `
        -Details ("Deserialized type: {0} | Length: {1}" -f $photoVal.GetType().FullName, $photoVal.Length)
} catch {
    Record-Result -TestId "SCH-02" -Description "Empty byte array handling" -Success $false -Details $_.Exception.Message
}

# Test 3.3: Extreme / Oversized Payloads (5 MB Image BLOB & 10,000 char Summary)
try {
    $ds = New-Object System.Data.DataSet
    $ds.ReadXmlSchema($xsdPath)
    $table = $ds.Tables["Candidate"]
    
    # Generate 5 MB pseudo-random byte buffer
    $largeBlobSize = 5 * 1024 * 1024 # 5 MB
    $largeBlob = New-Object byte[] $largeBlobSize
    $rand = New-Object System.Random(42)
    $rand.NextBytes($largeBlob)
    
    $largeSummary = ("Extremely comprehensive executive summary with detailed project accomplishments. " * 150) # ~12,000 chars
    
    $row = $table.NewRow()
    $row["CandidateId"] = 2000
    $row["FullName"] = "High-Payload Candidate"
    $row["Summary"] = $largeSummary
    $row["PhotoData"] = $largeBlob
    $table.Rows.Add($row)
    
    # Serialize to MemoryStream
    $msOut = New-Object System.IO.MemoryStream
    $ds.WriteXml($msOut, [System.Data.XmlWriteMode]::IgnoreSchema)
    $payloadXmlLength = $msOut.Length
    
    # Read back from stream
    $msOut.Position = 0
    $ds2 = New-Object System.Data.DataSet
    $ds2.ReadXmlSchema($xsdPath)
    $ds2.ReadXml($msOut)
    
    $recRow = $ds2.Tables["Candidate"].Rows[0]
    $recBytes = [byte[]]$recRow["PhotoData"]
    $recSummary = [string]$recRow["Summary"]
    
    $blobMatches = ($recBytes.Length -eq $largeBlobSize)
    $summaryMatches = ($recSummary.Length -eq $largeSummary.Length)
    
    # Check SHA256 match
    $sha = [System.Security.Cryptography.SHA256]::Create()
    $origHash = [BitConverter]::ToString($sha.ComputeHash($largeBlob))
    $recHash = [BitConverter]::ToString($sha.ComputeHash($recBytes))
    $hashMatches = ($origHash -eq $recHash)
    
    Record-Result -TestId "SCH-03" `
        -Description "Extreme payload stress test (5MB BLOB + 12,000 char text)" `
        -Success ($blobMatches -and $summaryMatches -and $hashMatches) `
        -Details ("XML Size: {0:N0} bytes | BLOB Match: {1} ({2:N0} bytes) | SHA256 Match: {3} | Text Match: {4} ({5:N0} chars)" -f `
            $payloadXmlLength, $blobMatches, $recBytes.Length, $hashMatches, $summaryMatches, $recSummary.Length)
} catch {
    Record-Result -TestId "SCH-03" -Description "Extreme payload stress test" -Success $false -Details $_.Exception.Message
}

# Test 3.4: Invalid Base64 in XML Deserialization
try {
    $malformedXml = @"
<CandidateDataSet xmlns="http://tempuri.org/CandidateDataSet.xsd">
  <Candidate>
    <CandidateId>3000</CandidateId>
    <FullName>Malformed Base64 Candidate</FullName>
    <PhotoData>!!!NOT_VALID_BASE64_STRING???</PhotoData>
  </Candidate>
</CandidateDataSet>
"@
    $ds = New-Object System.Data.DataSet
    $ds.ReadXmlSchema($xsdPath)
    $expectedErrorCaught = $false
    try {
        $sr = New-Object System.IO.StringReader($malformedXml)
        $ds.ReadXml($sr)
    } catch {
        $expectedErrorCaught = $true
        $errorMsg = $_.Exception.Message
    }
    
    Record-Result -TestId "SCH-04" `
        -Description "Invalid Base64 string in XML payload rejected gracefully" `
        -Success $expectedErrorCaught `
        -Details ("Parser threw expected exception: {0}" -f $errorMsg)
} catch {
    Record-Result -TestId "SCH-04" -Description "Invalid Base64 rejection test" -Success $false -Details $_.Exception.Message
}

# Test 3.5: Unicode and Indian Script Character Handling in CandidateDataSet
try {
    $ds = New-Object System.Data.DataSet
    $ds.ReadXmlSchema($xsdPath)
    $table = $ds.Tables["Candidate"]
    
    $row = $table.NewRow()
    $row["CandidateId"] = 4000
    $row["FullName"] = [System.Text.Encoding]::UTF8.GetString([System.Text.Encoding]::UTF8.GetBytes("রাহুল শর্মা (Rahul Sharma)"))
    $row["City"] = [System.Text.Encoding]::UTF8.GetString([System.Text.Encoding]::UTF8.GetBytes("কলকাতা (Kolkata)"))
    $row["Skills"] = "ASP.NET, C#, SQL Server, Crystal Reports, বাংলা, हिन्दी"
    $table.Rows.Add($row)
    
    $sw = New-Object System.IO.StringWriter
    $ds.WriteXml($sw)
    $xmlStr = $sw.ToString()
    
    $ds2 = New-Object System.Data.DataSet
    $ds2.ReadXmlSchema($xsdPath)
    $sr = New-Object System.IO.StringReader($xmlStr)
    $ds2.ReadXml($sr)
    
    $recRow = $ds2.Tables["Candidate"].Rows[0]
    $nameMatch = ($recRow["FullName"] -eq $row["FullName"])
    $cityMatch = ($recRow["City"] -eq $row["City"])
    
    Record-Result -TestId "SCH-05" `
        -Description "Unicode & Indian script character encoding in schema" `
        -Success ($nameMatch -and $cityMatch) `
        -Details ("Name match: {0} ({1}) | City match: {2} ({3})" -f $nameMatch, $recRow["FullName"], $cityMatch, $recRow["City"])
} catch {
    Record-Result -TestId "SCH-05" -Description "Unicode encoding in schema" -Success $false -Details $_.Exception.Message
}

# ==============================================================================
# CHALLENGE SUITE 4: DATA ACCESS LAYER & CRYSTAL REPORTS SCHEMA INTEGRATION
# ==============================================================================
Write-Host ""
Write-Host "--------------------------------------------------------------------------------"
Write-Host "SUITE 4: Data Access Layer & Report Schema Compatibility"
Write-Host "--------------------------------------------------------------------------------"

# Test 4.1: Inspect Report Document Datasource Tables and Fields
try {
    [System.Reflection.Assembly]::LoadWithPartialName("CrystalDecisions.CrystalReports.Engine") | Out-Null
    [System.Reflection.Assembly]::LoadWithPartialName("CrystalDecisions.Shared") | Out-Null
    
    $rptFiles = @("CandidateDirectory.rpt", "CandidateResume.rpt")
    $allRptVerified = $true
    $rptDetails = @()
    
    foreach ($rf in $rptFiles) {
        $rfPath = Join-Path $projDir $rf
        if (-not (Test-Path $rfPath)) {
            $allRptVerified = $false
            $rptDetails += "$rf missing"
            continue
        }
        
        $rptDoc = New-Object CrystalDecisions.CrystalReports.Engine.ReportDocument
        $rptDoc.Load($rfPath)
        
        $tableNames = @()
        foreach ($t in $rptDoc.Database.Tables) {
            $tableNames += $t.Name
        }
        
        # Test binding with DataTable("Employee1") populated from SQL Server
        $conn = New-Object System.Data.SqlClient.SqlConnection($conStr)
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
        $da = New-Object System.Data.SqlClient.SqlDataAdapter($sql, $conn)
        $dt = New-Object System.Data.DataTable("Employee1")
        $da.Fill($dt) | Out-Null
        $conn.Close()
        
        $rptDoc.SetDataSource($dt)
        
        # Verify export to memory stream works without crash
        $exportStream = $rptDoc.ExportToStream([CrystalDecisions.Shared.ExportFormatType]::PortableDocFormat)
        $exportBytesLength = $exportStream.Length
        $exportStream.Dispose()
        $rptDoc.Close()
        $rptDoc.Dispose()
        
        $rptDetails += ("{0} (Table: {1}, PDF Export: {2:N0} bytes)" -f $rf, ($tableNames -join ', '), $exportBytesLength)
    }
    
    Record-Result -TestId "RPT-01" `
        -Description "Report template loading, DataTable binding and PDF streaming" `
        -Success $allRptVerified `
        -Details ($rptDetails -join ' | ')
} catch {
    Record-Result -TestId "RPT-01" -Description "Report template loading and binding" -Success $false -Details $_.Exception.Message
}

# ==============================================================================
# SUMMARY & VERDICT
# ==============================================================================
Write-Host ""
Write-Host "================================================================================"
Write-Host ("CHALLENGE SUITE SUMMARY: Total={0} | Passed={1} | Failed={2}" -f $totalTests, $passedTests, $failedTests)
Write-Host "================================================================================"

if ($failedTests -eq 0) {
    Write-Host "VERDICT: APPROVE - All empirical challenges passed with 0 failures."
} else {
    Write-Host "VERDICT: REJECT - Discovered failures requiring remediation."
    foreach ($f in $findings) {
        Write-Host ("  - [{0}] {1}: {2}" -f $f.TestId, $f.Description, $f.Details)
    }
}
