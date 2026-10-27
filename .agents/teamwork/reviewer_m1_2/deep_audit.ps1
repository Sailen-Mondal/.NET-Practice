$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$projDir = 'C:\Users\sailenmondal\OneDrive - MANAGEMENT & COMPUTER CONSULTANTS\Documents\Visual Studio 2015\WebSites\WebSite2'
$webConfigFile = Join-Path $projDir "Web.config"

[xml]$webConfig = Get-Content $webConfigFile
$conStr = ($webConfig.configuration.connectionStrings.add | Where-Object { $_.name -eq 'conStr' }).connectionString

$conn = New-Object System.Data.SqlClient.SqlConnection($conStr)
$conn.Open()

Write-Output "========================================================="
Write-Output "1. AUDITING IMAGE ASSETS & BLOB VALIDITY"
Write-Output "========================================================="
$imagesDir = Join-Path $projDir "Images"
$imageFiles = Get-ChildItem -Path $imagesDir -Filter "*.png"
Write-Output "Files in Images directory: $($imageFiles.Count)"
foreach ($f in $imageFiles) {
    Write-Output "  $($f.Name) : $($f.Length) bytes"
}

$sha = [System.Security.Cryptography.SHA256]::Create()

$cmd = $conn.CreateCommand()
$cmd.CommandText = "SELECT CandidateId, FullName, PhotoFileName, PhotoPath, PhotoData FROM dbo.CandidateProfiles ORDER BY CandidateId"
$reader = $cmd.ExecuteReader()

while ($reader.Read()) {
    $cid = $reader.GetInt32(0)
    $name = $reader.GetString(1)
    $pfile = $reader.GetString(2)
    $ppath = $reader.GetString(3)
    $blobBytes = [byte[]]$reader["PhotoData"]
    
    $diskPath = Join-Path $imagesDir $pfile
    $diskBytes = [System.IO.File]::ReadAllBytes($diskPath)
    
    $dbHash = [BitConverter]::ToString($sha.ComputeHash($blobBytes)).Replace("-", "")
    $diskHash = [BitConverter]::ToString($sha.ComputeHash($diskBytes)).Replace("-", "")
    
    # Try decoding image to verify image integrity
    $ms = New-Object System.IO.MemoryStream(,$blobBytes)
    $img = [System.Drawing.Image]::FromStream($ms)
    $dimensions = "$($img.Width)x$($img.Height)"
    $rawFormat = $img.RawFormat.ToString()
    $pixelFormat = $img.PixelFormat.ToString()
    $img.Dispose()
    $ms.Dispose()

    # Also verify disk image decoding
    $diskImg = [System.Drawing.Image]::FromFile($diskPath)
    $diskDimensions = "$($diskImg.Width)x$($diskImg.Height)"
    $diskImg.Dispose()

    Write-Output "Candidate ${cid}: $name"
    Write-Output "  File: $pfile, Path: $ppath"
    Write-Output "  BLOB size: $($blobBytes.Length) bytes, Disk size: $($diskBytes.Length) bytes"
    Write-Output "  BLOB SHA256: $dbHash"
    Write-Output "  Disk SHA256: $diskHash"
    Write-Output "  Image format: $rawFormat, Dimensions: $dimensions, PixelFormat: $pixelFormat"
    Write-Output "  Hash match: $($dbHash -eq $diskHash), Dimensions match: $($dimensions -eq $diskDimensions)"
}
$reader.Close()

Write-Output "`nChecking logo.png on disk:"
$logoPath = Join-Path $imagesDir "logo.png"
if (Test-Path $logoPath) {
    $logoBytes = [System.IO.File]::ReadAllBytes($logoPath)
    $logoHash = [BitConverter]::ToString($sha.ComputeHash($logoBytes)).Replace("-", "")
    $logoImg = [System.Drawing.Image]::FromFile($logoPath)
    Write-Output "  logo.png: $($logoBytes.Length) bytes, $($logoImg.Width)x$($logoImg.Height), SHA256: $logoHash"
    $logoImg.Dispose()
}

Write-Output "`n========================================================="
Write-Output "2. SCHEMA COMPARISON: DB vs CandidateDataSet.xsd"
Write-Output "========================================================="
$cmdSchema = $conn.CreateCommand()
$cmdSchema.CommandText = @"
SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'CandidateProfiles'
ORDER BY ORDINAL_POSITION
"@
$daSchema = New-Object System.Data.SqlClient.SqlDataAdapter($cmdSchema)
$dtDbCols = New-Object System.Data.DataTable
$daSchema.Fill($dtDbCols) | Out-Null

$xsdPath = Join-Path $projDir "App_Code\CandidateDataSet.xsd"
[xml]$xsdXml = Get-Content $xsdPath
$candidateElement = $xsdXml.schema.element | Where-Object { $_.name -eq 'CandidateDataSet' }
$tableElement = $candidateElement.complexType.choice.element | Where-Object { $_.name -eq 'Candidate' }
$xsdElements = $tableElement.complexType.sequence.element

Write-Output "DB Columns ($($dtDbCols.Rows.Count)) vs XSD Elements ($($xsdElements.Count)):"
foreach ($dbRow in $dtDbCols.Rows) {
    $cname = $dbRow["COLUMN_NAME"]
    $ctype = $dbRow["DATA_TYPE"]
    $clen = $dbRow["CHARACTER_MAXIMUM_LENGTH"]
    $cnull = $dbRow["IS_NULLABLE"]
    
    $xsdMatch = $xsdElements | Where-Object { $_.name -eq $cname }
    if ($xsdMatch) {
        Write-Output "  [MATCH] $cname : DB($ctype, len=$clen, null=$cnull) <-> XSD(type=$($xsdMatch.type), minOccurs=$($xsdMatch.minOccurs))"
    } else {
        Write-Output "  [MISSING IN XSD] $cname : DB($ctype, len=$clen, null=$cnull)"
    }
}

foreach ($xe in $xsdElements) {
    $dbMatch = $dtDbCols.Select("COLUMN_NAME = '$($xe.name)'")
    if ($dbMatch.Count -eq 0) {
        Write-Output "  [EXTRA IN XSD] $($xe.name) : XSD(type=$($xe.type))"
    }
}

Write-Output "`n========================================================="
Write-Output "3. TESTING ADO.NET PARAMETERIZATION & SQL INJECTION SAFETY"
Write-Output "========================================================="
# Let's simulate FetchCandidateData queries directly
$sqlBase = @"
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
WHERE 1=1
"@

function Test-FetchQuery($label, $mode, $nameFilter, $genderFilter, $candidateId) {
    $sql = $sqlBase
    if ($mode -eq "Resume" -and -not [string]::IsNullOrEmpty($candidateId)) {
        $sql += " AND CandidateId = @candId"
    } else {
        if (-not [string]::IsNullOrEmpty($nameFilter)) {
            $sql += " AND FullName LIKE '%' + @fname + '%'"
        }
        if (-not [string]::IsNullOrEmpty($genderFilter)) {
            $sql += " AND Gender = @gender"
        }
    }
    $sql += " ORDER BY CandidateId"
    
    $testCmd = $conn.CreateCommand()
    $testCmd.CommandText = $sql
    
    try {
        if ($mode -eq "Resume" -and -not [string]::IsNullOrEmpty($candidateId)) {
            $testCmd.Parameters.AddWithValue("@candId", [Convert]::ToInt32($candidateId)) | Out-Null
        } else {
            if (-not [string]::IsNullOrEmpty($nameFilter)) {
                $testCmd.Parameters.AddWithValue("@fname", $nameFilter) | Out-Null
            }
            if (-not [string]::IsNullOrEmpty($genderFilter)) {
                $testCmd.Parameters.AddWithValue("@gender", $genderFilter) | Out-Null
            }
        }
        
        $testDa = New-Object System.Data.SqlClient.SqlDataAdapter($testCmd)
        $testDt = New-Object System.Data.DataTable("Employee1")
        $testDa.Fill($testDt) | Out-Null
        Write-Output "  [PASS] $label : Returned $($testDt.Rows.Count) rows"
    } catch {
        Write-Output "  [EXCEPTION] $label : $($_.Exception.Message)"
    }
}

Write-Output "Running Injection & Boundary Tests:"
Test-FetchQuery "Baseline All" "Directory" $null $null $null
Test-FetchQuery "SQLi Name: ' OR '1'='1" "Directory" "' OR '1'='1" $null $null
Test-FetchQuery "SQLi Name: '; DROP TABLE dummy; --" "Directory" "'; DROP TABLE dummy; --" $null $null
Test-FetchQuery "SQLi Name: ' UNION SELECT null, null... --" "Directory" "' UNION SELECT 1, 'a', 'b', 'c', 1, 'a', 'b', 'c', 'd', 'e', 'f', 'g', 1, 'h', 'i', 'j', null --" $null $null
Test-FetchQuery "Special Chars Name: %" "Directory" "%" $null $null
Test-FetchQuery "Special Chars Name: [a-z]" "Directory" "[a-z]" $null $null
Test-FetchQuery "Special Chars Name: _" "Directory" "_" $null $null
Test-FetchQuery "Non-existent Name" "Directory" "NonExistentPersonXYZ" $null $null
Test-FetchQuery "Valid Male Gender" "Directory" $null "Male" $null
Test-FetchQuery "Valid Female Gender" "Directory" $null "Female" $null
Test-FetchQuery "Invalid Gender: Other" "Directory" $null "Other" $null
Test-FetchQuery "SQLi Gender: ' OR '1'='1" "Directory" $null "' OR '1'='1" $null
Test-FetchQuery "Valid CandidateId: 1" "Resume" $null $null "1"
Test-FetchQuery "Valid CandidateId: 5" "Resume" $null $null "5"
Test-FetchQuery "Non-existent CandidateId: 9999" "Resume" $null $null "9999"
Test-FetchQuery "Non-numeric CandidateId: abc" "Resume" $null $null "abc"
Test-FetchQuery "SQLi CandidateId: 1 OR 1=1" "Resume" $null $null "1 OR 1=1"

$conn.Close()
