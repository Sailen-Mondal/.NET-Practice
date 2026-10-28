[Reflection.Assembly]::LoadWithPartialName("CrystalDecisions.CrystalReports.Engine") | Out-Null
[Reflection.Assembly]::LoadWithPartialName("CrystalDecisions.Shared") | Out-Null

$projectDir = "C:\Users\sailenmondal\OneDrive - MANAGEMENT & COMPUTER CONSULTANTS\Documents\Visual Studio 2015\WebSites\WebSite2"
$rpts = @("CandidateDirectory.rpt", "CandidateResume.rpt")

foreach ($r in $rpts) {
    $path = Join-Path $projectDir $r
    if (Test-Path $path) {
        $doc = New-Object CrystalDecisions.CrystalReports.Engine.ReportDocument
        try {
            $doc.Load($path)
            Write-Output "=== Report: $r ==="
            Write-Output "RecordSelectionFormula: $($doc.RecordSelectionFormula)"
            Write-Output "Database Tables Count: $($doc.Database.Tables.Count)"
            foreach ($t in $doc.Database.Tables) {
                Write-Output "  Table Name: $($t.Name), Location: $($t.Location)"
                foreach ($f in $t.Fields) {
                    Write-Output "    Field: $($f.Name) ($($f.ValueType))"
                }
            }
        } catch {
            Write-Output "Error inspecting ${r} - $_"
        } finally {
            $doc.Close()
            $doc.Dispose()
        }
    }
}
