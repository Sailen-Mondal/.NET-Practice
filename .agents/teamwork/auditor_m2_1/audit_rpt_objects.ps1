[System.Reflection.Assembly]::LoadWithPartialName("CrystalDecisions.CrystalReports.Engine") | Out-Null

$rptFiles = @(
    "C:\Users\sailenmondal\OneDrive - MANAGEMENT & COMPUTER CONSULTANTS\Documents\Visual Studio 2015\WebSites\WebSite2\CandidateDirectory.rpt",
    "C:\Users\sailenmondal\OneDrive - MANAGEMENT & COMPUTER CONSULTANTS\Documents\Visual Studio 2015\WebSites\WebSite2\CandidateResume.rpt"
)

$emojiPattern = '[\uD83C-\uDBFF\uDC00-\uDFFF\u2600-\u26FF\u2700-\u27BF]'

foreach ($path in $rptFiles) {
    Write-Host "Inspecting RPT: $([System.IO.Path]::GetFileName($path))"
    $doc = New-Object CrystalDecisions.CrystalReports.Engine.ReportDocument
    $doc.Load($path)
    
    # Check report title, author, comments
    Write-Host "  Report Title: '$($doc.SummaryInfo.ReportTitle)'"
    Write-Host "  Report Comments: '$($doc.SummaryInfo.ReportComments)'"
    
    # Check all text objects
    $textObjects = 0
    foreach ($section in $doc.ReportDefinition.Sections) {
        foreach ($obj in $section.ReportObjects) {
            if ($obj -is [CrystalDecisions.CrystalReports.Engine.TextObject]) {
                $textObjects++
                $text = $obj.Text
                if ($text -match $emojiPattern) {
                    Write-Host "  EMOJI in TextObject '$($obj.Name)': $text"
                }
            }
        }
    }
    Write-Host "  Inspected $textObjects TextObjects. No emojis found."
    $doc.Close()
    $doc.Dispose()
}
