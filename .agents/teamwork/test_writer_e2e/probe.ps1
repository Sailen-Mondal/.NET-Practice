$ErrorActionPreference = 'Stop'
$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$url = "http://localhost:8188/Default.aspx"

$response = Invoke-WebRequest -Uri $url -WebSession $session -UseBasicParsing
Write-Host "Initial GET Status: $($response.StatusCode)"
Write-Host "Initial Content Length: $($response.Content.Length)"

# Check dynamic image
$imgMatch = [regex]::Match($response.Content, 'CrystalImageHandler\.aspx\?dynamicimage=[^"''\s<>]+')
if ($imgMatch.Success) {
    $imgUrl = "http://localhost:8188/" + $imgMatch.Value
    Write-Host "Testing Image URL: $imgUrl"
    $imgRes = Invoke-WebRequest -Uri $imgUrl -WebSession $session -UseBasicParsing
    Write-Host "Image Status: $($imgRes.StatusCode)"
    Write-Host "Image Content-Type: $($imgRes.Headers['Content-Type'])"
    Write-Host "Image Content Length: $($imgRes.RawContentLength)"
    $isPng = ($imgRes.Content.Length -ge 8 -and $imgRes.Content[1] -eq 80 -and $imgRes.Content[2] -eq 78 -and $imgRes.Content[3] -eq 71)
    Write-Host "Image is valid PNG: $isPng"
} else {
    Write-Host "No dynamic image found in initial response"
}

# Check resume link
$resumeMatch = [regex]::Match($response.Content, 'Resumes/[a-zA-Z0-9_\.]+\.pdf')
if ($resumeMatch.Success) {
    $resUrl = "http://localhost:8188/" + $resumeMatch.Value
    Write-Host "Testing Resume URL: $resUrl"
    $resRes = Invoke-WebRequest -Uri $resUrl -WebSession $session -UseBasicParsing
    Write-Host "Resume Status: $($resRes.StatusCode)"
    Write-Host "Resume Content-Type: $($resRes.Headers['Content-Type'])"
    $pdfBytes = if ($resRes.Content -is [byte[]]) { $resRes.Content } else { [System.Text.Encoding]::ASCII.GetBytes($resRes.Content) }
    $isPdf = ($pdfBytes.Length -ge 4 -and $pdfBytes[0] -eq 0x25 -and $pdfBytes[1] -eq 0x50 -and $pdfBytes[2] -eq 0x44 -and $pdfBytes[3] -eq 0x46)
    Write-Host "Resume is valid PDF: $isPdf"
}

# Test PDF Export via POST
# Extract ViewState and EventValidation
$vsMatch = [regex]::Match($response.Content, 'id="__VIEWSTATE"\s+value="([^"]*)"')
$evMatch = [regex]::Match($response.Content, 'id="__EVENTVALIDATION"\s+value="([^"]*)"')
$vs = if ($vsMatch.Success) { $vsMatch.Groups[1].Value } else { "" }
$ev = if ($evMatch.Success) { $evMatch.Groups[1].Value } else { "" }

Write-Host "ViewState found: $($vsMatch.Success) (Length: $($vs.Length))"
Write-Host "EventValidation found: $($evMatch.Success) (Length: $($ev.Length))"

$pdfPostData = @{
    "__VIEWSTATE" = $vs
    "__EVENTVALIDATION" = $ev
    "btnPDF" = "Convert To PDF"
    "txtFirstName" = ""
    "DropDownList1" = ""
    "ddlViewMode" = "Directory"
}

$pdfRes = Invoke-WebRequest -Uri $url -Method Post -Body $pdfPostData -WebSession $session -UseBasicParsing
Write-Host "PDF Export Status: $($pdfRes.StatusCode)"
Write-Host "PDF Content-Type: $($pdfRes.Headers['Content-Type'])"
Write-Host "PDF Content-Disposition: $($pdfRes.Headers['Content-Disposition'])"
$exportedPdfBytes = if ($pdfRes.Content -is [byte[]]) { $pdfRes.Content } else { [System.Text.Encoding]::ASCII.GetBytes($pdfRes.Content) }
$isExportedPdf = ($exportedPdfBytes.Length -ge 4 -and $exportedPdfBytes[0] -eq 0x25 -and $exportedPdfBytes[1] -eq 0x50 -and $exportedPdfBytes[2] -eq 0x44 -and $exportedPdfBytes[3] -eq 0x46)
Write-Host "Exported PDF Valid Header: $isExportedPdf (Size: $($exportedPdfBytes.Length) bytes)"
