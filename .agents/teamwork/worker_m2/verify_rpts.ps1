Add-Type -Path "C:\WINDOWS\assembly\GAC_MSIL\CrystalDecisions.Shared\13.0.2000.0__692fbea5521e1304\CrystalDecisions.Shared.dll"
Add-Type -Path "C:\WINDOWS\assembly\GAC_MSIL\CrystalDecisions.CrystalReports.Engine\13.0.2000.0__692fbea5521e1304\CrystalDecisions.CrystalReports.Engine.dll"

$rpts = @("CandidateDirectory.rpt", "CandidateResume.rpt")
$dir = "C:\Users\sailenmondal\OneDrive - MANAGEMENT & COMPUTER CONSULTANTS\Documents\Visual Studio 2015\WebSites\WebSite2"

foreach ($rptName in $rpts) {
    Write-Host ("=== Report: " + $rptName + " ===")
    $doc = New-Object CrystalDecisions.CrystalReports.Engine.ReportDocument
    $doc.Load((Join-Path $dir $rptName))
    Write-Host ("Tables: " + $doc.Database.Tables.Count)
    foreach ($t in $doc.Database.Tables) {
        Write-Host ("  Table Name: " + $t.Name)
    }
    Write-Host ("Sections: " + $doc.ReportDefinition.Sections.Count)
    $blobCount = 0
    $picCount = 0
    foreach ($sec in $doc.ReportDefinition.Sections) {
        foreach ($ro in $sec.ReportObjects) {
            if ($ro.Kind -eq [CrystalDecisions.Shared.ReportObjectKind]::BlobFieldObject) {
                $blobCount++
                Write-Host ("    BlobField: " + $ro.Name + " in " + $sec.Name)
            }
            if ($ro.Kind -eq [CrystalDecisions.Shared.ReportObjectKind]::PictureObject) {
                $picCount++
                Write-Host ("    Picture: " + $ro.Name + " in " + $sec.Name)
            }
        }
    }
    Write-Host ("  Total BlobFieldObjects: " + $blobCount + ", Total PictureObjects: " + $picCount)
    $doc.Close()
    $doc.Dispose()
}
