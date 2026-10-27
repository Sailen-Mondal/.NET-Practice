$ErrorActionPreference = 'Stop'
$projDir = 'C:\Users\sailenmondal\OneDrive - MANAGEMENT & COMPUTER CONSULTANTS\Documents\Visual Studio 2015\WebSites\WebSite2'
$webConfigFile = Join-Path $projDir "Web.config"
[xml]$webConfig = Get-Content $webConfigFile
$conStr = ($webConfig.configuration.connectionStrings.add | Where-Object { $_.name -eq 'conStr' }).connectionString

$conn = New-Object System.Data.SqlClient.SqlConnection($conStr)
$conn.Open()
$cmd = $conn.CreateCommand()
$cmd.CommandText = "SELECT CandidateId, FullName, ResumeFileName, ResumePath, PhotoFileName, PhotoPath FROM dbo.CandidateProfiles ORDER BY CandidateId"
$adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
$dt = New-Object System.Data.DataTable
$adapter.Fill($dt) | Out-Null
$conn.Close()

$dt | Format-Table -AutoSize | Out-String | Write-Output
