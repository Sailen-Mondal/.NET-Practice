$ErrorActionPreference = 'Stop'
$projDir = 'C:\Users\sailenmondal\OneDrive - MANAGEMENT & COMPUTER CONSULTANTS\Documents\Visual Studio 2015\WebSites\WebSite2'

# Load Crystal Decisions assembly
[System.Reflection.Assembly]::LoadWithPartialName("CrystalDecisions.CrystalReports.Engine") | Out-Null
[System.Reflection.Assembly]::LoadWithPartialName("CrystalDecisions.Shared") | Out-Null

$reports = @("CandidateDirectory.rpt", "CandidateResume.rpt")

foreach ($rptName in $reports) {
    $rptPath = Join-Path $projDir $rptName
    Write-Output "=== Report: $rptName ==="
    $doc = New-Object CrystalDecisions.CrystalReports.Engine.ReportDocument
    $doc.Load($rptPath)
    
    Write-Output "Database Tables in report ${rptName}:"
    foreach ($tbl in $doc.Database.Tables) {
        Write-Output "  Table Name: '$($tbl.Name)', Location: '$($tbl.Location)'"
        Write-Output "  Fields in Table $($tbl.Name):"
        foreach ($f in $tbl.Fields) {
            Write-Output "    $($f.Name) (Type: $($f.Kind))"
        }
    }
    
    Write-Output "Report Objects:"
    foreach ($sec in $doc.ReportDefinition.Sections) {
        foreach ($obj in $sec.ReportObjects) {
            Write-Output "  Section: $($sec.Name), Object: $($obj.Name) (Kind: $($obj.Kind))"
        }
    }

    $doc.Close()
    $doc.Dispose()
}
