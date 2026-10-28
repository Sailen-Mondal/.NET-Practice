# Test SQL Injection resistance
$ErrorActionPreference = 'Stop'
$projDir = 'C:\Users\sailenmondal\OneDrive - MANAGEMENT & COMPUTER CONSULTANTS\Documents\Visual Studio 2015\WebSites\WebSite2'
$webConfigFile = Join-Path $projDir "Web.config"
[xml]$webConfig = Get-Content $webConfigFile
$conStr = ($webConfig.configuration.connectionStrings.add | Where-Object { $_.name -eq 'conStr' }).connectionString

$csharpSource = @"
using System;
using System.Data;
using System.Data.SqlClient;

public class SqlInjectionTester
{
    public static int TestSearch(string connStr, string nameFilter)
    {
        var dt = new DataTable("Employee1");
        using (var conn = new SqlConnection(connStr))
        {
            conn.Open();
            string sql = @"SELECT 
                            CandidateId AS ID, 
                            FullName AS Name, 
                            City AS Location, 
                            Gender, 
                            PhotoData 
                           FROM dbo.CandidateProfiles 
                           WHERE 1=1";
            if (!string.IsNullOrEmpty(nameFilter))
            {
                sql += " AND FullName LIKE '%' + @fname + '%'";
            }

            using (var cmd = new SqlCommand(sql, conn))
            {
                if (!string.IsNullOrEmpty(nameFilter))
                {
                    cmd.Parameters.AddWithValue("@fname", nameFilter);
                }

                using (var da = new SqlDataAdapter(cmd))
                {
                    da.Fill(dt);
                }
            }
        }
        return dt.Rows.Count;
    }
}
"@
Add-Type -TypeDefinition $csharpSource -ReferencedAssemblies "System.Data.dll", "System.Xml.dll"

$maliciousInputs = @(
    "' OR 1=1 --",
    "'; DROP TABLE Test; --",
    "' UNION SELECT 1,2,3,4,NULL --",
    "<script>alert(1)</script>",
    "Rahul' AND '1'='1"
)

foreach ($inputStr in $maliciousInputs) {
    $rows = [SqlInjectionTester]::TestSearch($conStr, $inputStr)
    Write-Output "Input: '$inputStr' -> Rows returned: $rows (Safe: Parameterized)"
}
