$ErrorActionPreference = 'Stop'
$projDir = 'C:\Users\sailenmondal\OneDrive - MANAGEMENT & COMPUTER CONSULTANTS\Documents\Visual Studio 2015\WebSites\WebSite2'
$webConfigFile = Join-Path $projDir "Web.config"
[xml]$webConfig = Get-Content $webConfigFile
$conStr = ($webConfig.configuration.connectionStrings.add | Where-Object { $_.name -eq 'conStr' }).connectionString

try {
    $testQueries = @(
        @{ Name = "Q01_AllCandidates"; Mode = "Directory"; FilterName = ""; FilterGender = ""; CandId = "" },
        @{ Name = "Q02_ResumeCand1";   Mode = "Resume";    FilterName = ""; FilterGender = ""; CandId = "1" }
    )
    
    [System.Threading.Tasks.Parallel]::For(0, $testQueries.Count, [Action[int]]{
        param($idx)
        try {
            $q = $testQueries[$idx]
            Write-Output "Running $idx"
        } catch {
            Write-Error $_
        }
    })
} catch [System.AggregateException] {
    foreach ($inner in $_.Exception.InnerExceptions) {
        Write-Output "Inner error: $($inner.Message)"
        Write-Output "Stack trace: $($inner.StackTrace)"
    }
}
