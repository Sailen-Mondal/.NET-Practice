$webSession = New-Object Microsoft.PowerShell.Commands.WebRequestSession

# Step 1: GET initial page
$getRes = Invoke-WebRequest -Uri "http://localhost:8188/Default.aspx" -WebSession $webSession -UseBasicParsing

function Extract-Field($html, $name) {
    $pattern = 'id="' + $name + '"\s+value="([^"]*)"'
    if ($html -match $pattern) {
        return $matches[1]
    }
    return ""
}

$vs = Extract-Field $getRes.Content "__VIEWSTATE"
$vsg = Extract-Field $getRes.Content "__VIEWSTATEGENERATOR"
$ev = Extract-Field $getRes.Content "__EVENTVALIDATION"

Write-Host "Initial GET: Length $($getRes.Content.Length), ViewState length $($vs.Length)"

# Step 2: POST btnPDF to export CandidateDirectory.pdf
$bodyDir = @{
    "__VIEWSTATE" = $vs
    "__VIEWSTATEGENERATOR" = $vsg
    "__EVENTVALIDATION" = $ev
    "txtFirstName" = ""
    "DropDownList1" = ""
    "ddlViewMode" = "Directory"
    "btnPDF" = "Convert To PDF"
}

$pdfDirRes = Invoke-WebRequest -Uri "http://localhost:8188/Default.aspx" -Method POST -Body $bodyDir -WebSession $webSession -UseBasicParsing

Write-Host "`n--- CandidateDirectory.pdf Export Audit ---"
Write-Host "Status Code: $($pdfDirRes.StatusCode)"
Write-Host "Content-Type: $($pdfDirRes.Headers['Content-Type'])"
Write-Host "Content-Disposition: $($pdfDirRes.Headers['Content-Disposition'])"
Write-Host "Length: $($pdfDirRes.Content.Length) bytes"

$pdfHeader = [System.Text.Encoding]::ASCII.GetString($pdfDirRes.Content[0..9])
Write-Host "Header: $pdfHeader"

$pdfRawText = [System.Text.Encoding]::ASCII.GetString($pdfDirRes.Content)
$producerMatch = [regex]::Match($pdfRawText, '/Producer\s*\(([^)]+)\)')
if ($producerMatch.Success) {
    Write-Host "PDF Producer: $($producerMatch.Groups[1].Value)"
} else {
    Write-Host "PDF Producer match: Not found"
}

$creatorMatch = [regex]::Match($pdfRawText, '/Creator\s*\(([^)]+)\)')
if ($creatorMatch.Success) {
    Write-Host "PDF Creator: $($creatorMatch.Groups[1].Value)"
}

$fontsMatch = [regex]::Matches($pdfRawText, '/BaseFont\s*/([^ /]+)')
Write-Host "Fonts referenced: $($fontsMatch.Count)"
foreach ($fm in $fontsMatch) {
    Write-Host "  Font: $($fm.Groups[1].Value)"
}

# Step 3: Switch to Resume mode, then export CandidateResume.pdf
# First POST to switch to Resume mode
$bodyResumeSwitch = @{
    "__VIEWSTATE" = $vs
    "__VIEWSTATEGENERATOR" = $vsg
    "__EVENTVALIDATION" = $ev
    "txtFirstName" = ""
    "DropDownList1" = ""
    "ddlViewMode" = "Resume"
    "__EVENTTARGET" = "ddlViewMode"
    "__EVENTARGUMENT" = ""
}

$resumePageRes = Invoke-WebRequest -Uri "http://localhost:8188/Default.aspx" -Method POST -Body $bodyResumeSwitch -WebSession $webSession -UseBasicParsing

$vsResume = Extract-Field $resumePageRes.Content "__VIEWSTATE"
$vsgResume = Extract-Field $resumePageRes.Content "__VIEWSTATEGENERATOR"
$evResume = Extract-Field $resumePageRes.Content "__EVENTVALIDATION"

# Now POST btnPDF in Resume mode
$bodyResumePdf = @{
    "__VIEWSTATE" = $vsResume
    "__VIEWSTATEGENERATOR" = $vsgResume
    "__EVENTVALIDATION" = $evResume
    "txtFirstName" = ""
    "DropDownList1" = ""
    "ddlViewMode" = "Resume"
    "ddlCandidate" = "1"
    "btnPDF" = "Convert To PDF"
}

$pdfResumeRes = Invoke-WebRequest -Uri "http://localhost:8188/Default.aspx" -Method POST -Body $bodyResumePdf -WebSession $webSession -UseBasicParsing

Write-Host "`n--- CandidateResume.pdf Export Audit ---"
Write-Host "Status Code: $($pdfResumeRes.StatusCode)"
Write-Host "Content-Type: $($pdfResumeRes.Headers['Content-Type'])"
Write-Host "Content-Disposition: $($pdfResumeRes.Headers['Content-Disposition'])"
Write-Host "Length: $($pdfResumeRes.Content.Length) bytes"

$pdfResumeHeader = [System.Text.Encoding]::ASCII.GetString($pdfResumeRes.Content[0..9])
Write-Host "Header: $pdfResumeHeader"

$pdfResumeRawText = [System.Text.Encoding]::ASCII.GetString($pdfResumeRes.Content)
$producerMatchResume = [regex]::Match($pdfResumeRawText, '/Producer\s*\(([^)]+)\)')
if ($producerMatchResume.Success) {
    Write-Host "PDF Producer: $($producerMatchResume.Groups[1].Value)"
}
