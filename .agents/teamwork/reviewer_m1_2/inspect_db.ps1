$ErrorActionPreference = 'Stop'
$projDir = 'C:\Users\sailenmondal\OneDrive - MANAGEMENT & COMPUTER CONSULTANTS\Documents\Visual Studio 2015\WebSites\WebSite2'
$webConfigFile = Join-Path $projDir "Web.config"

[xml]$webConfig = Get-Content $webConfigFile
$conStr = ($webConfig.configuration.connectionStrings.add | Where-Object { $_.name -eq 'conStr' }).connectionString

Write-Output "--- 1. Connection String from Web.config ---"
Write-Output $conStr

$conn = New-Object System.Data.SqlClient.SqlConnection($conStr)
$conn.Open()
Write-Output "Connection state: $($conn.State)"
Write-Output "Server version:   $($conn.ServerVersion)"
Write-Output "Database:         $($conn.Database)"

Write-Output "`n--- 2. Columns in dbo.CandidateProfiles ---"
$cmd = $conn.CreateCommand()
$cmd.CommandText = "SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, IS_NULLABLE FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'CandidateProfiles' ORDER BY ORDINAL_POSITION"
$adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
$dtCols = New-Object System.Data.DataTable
$adapter.Fill($dtCols) | Out-Null
$dtCols | Format-Table -AutoSize | Out-String | Write-Output

Write-Output "--- 3. Primary Key Constraint ---"
$pkCmd = $conn.CreateCommand()
$pkCmd.CommandText = @"
SELECT tc.CONSTRAINT_NAME, kcu.COLUMN_NAME 
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu 
  ON tc.CONSTRAINT_NAME = kcu.CONSTRAINT_NAME 
WHERE tc.TABLE_NAME = 'CandidateProfiles' AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
"@
$pkAdapter = New-Object System.Data.SqlClient.SqlDataAdapter($pkCmd)
$dtPk = New-Object System.Data.DataTable
$pkAdapter.Fill($dtPk) | Out-Null
$dtPk | Format-Table -AutoSize | Out-String | Write-Output

Write-Output "--- 4. Rows in dbo.CandidateProfiles ---"
$rowCmd = $conn.CreateCommand()
$rowCmd.CommandText = "SELECT CandidateId, FullName, JobTitle, Department, Gender, City, Email, Phone, Skills, ExperienceYears, PhotoFileName, PhotoPath, ResumeFileName, ResumePath, DATALENGTH(PhotoData) AS PhotoDataLength FROM dbo.CandidateProfiles ORDER BY CandidateId"
$rowAdapter = New-Object System.Data.SqlClient.SqlDataAdapter($rowCmd)
$dtRows = New-Object System.Data.DataTable
$rowAdapter.Fill($dtRows) | Out-Null
$dtRows | Format-Table CandidateId, FullName, Gender, City, JobTitle, ExperienceYears, PhotoDataLength -AutoSize | Out-String | Write-Output

Write-Output "--- 5. Checking for Nulls or Empty Values in Database ---"
foreach ($row in $dtRows.Rows) {
    Write-Output "Candidate $($row['CandidateId']) ($($row['FullName'])): PhotoFileName='$($row['PhotoFileName'])', PhotoPath='$($row['PhotoPath'])', ResumeFileName='$($row['ResumeFileName'])', ResumePath='$($row['ResumePath'])', PhotoDataLength=$($row['PhotoDataLength'])"
}

$conn.Close()
