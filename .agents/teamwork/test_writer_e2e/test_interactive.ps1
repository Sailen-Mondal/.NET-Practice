$ErrorActionPreference = 'Stop'
$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$url = "http://localhost:8188/Default.aspx"

function Send-Postback {
    param(
        [hashtable]$Fields,
        [string]$HtmlContent
    )
    $vsMatch = [regex]::Match($HtmlContent, 'id="__VIEWSTATE"\s+value="([^"]*)"')
    $vs = if ($vsMatch.Success) { $vsMatch.Groups[1].Value } else { "" }
    
    $postBody = @{
        "__VIEWSTATE" = $vs
    }
    foreach ($k in $Fields.Keys) {
        $postBody[$k] = $Fields[$k]
    }
    
    return Invoke-WebRequest -Uri $url -Method Post -Body $postBody -WebSession $session -UseBasicParsing
}

# 1. Reset first
$r0 = Invoke-WebRequest -Uri $url -WebSession $session -UseBasicParsing
$rReset = Send-Postback -Fields @{ "btnReset" = "Reset Filters" } -HtmlContent $r0.Content

# 2. Select Candidate 2 (Priya) in Resume view
$rResume = Send-Postback -Fields @{
    "ddlViewMode" = "Resume"
    "__EVENTTARGET" = "ddlViewMode"
    "ddlCandidate" = "2"
} -HtmlContent $rReset.Content

# Also postback for ddlCandidate selection if needed
$rCand2 = Send-Postback -Fields @{
    "ddlViewMode" = "Resume"
    "ddlCandidate" = "2"
    "__EVENTTARGET" = "ddlCandidate"
} -HtmlContent $rResume.Content

$cand2Count = ([regex]::Matches($rCand2.Content, '<div class="profile-card">')).Count
Write-Host "Candidate 2 selected - Cards count: $cand2Count"
Write-Host "Has Priya: $($rCand2.Content.Contains('Priya Mukherjee'))"
Write-Host "Has Rahul: $($rCand2.Content.Contains('Rahul Sharma'))"

# 3. Export PDF in Resume mode
$rExport = Send-Postback -Fields @{
    "btnPDF" = "Convert To PDF"
    "ddlViewMode" = "Resume"
    "ddlCandidate" = "2"
} -HtmlContent $rCand2.Content

Write-Host "Export Status: $($rExport.StatusCode)"
Write-Host "Export Disposition: $($rExport.Headers['Content-Disposition'])"
Write-Host "Export Content-Type: $($rExport.Headers['Content-Type'])"
$pdfBytes = if ($rExport.Content -is [byte[]]) { $rExport.Content } else { [System.Text.Encoding]::ASCII.GetBytes($rExport.Content) }
$isPdf = ($pdfBytes.Length -ge 4 -and $pdfBytes[0] -eq 0x25 -and $pdfBytes[1] -eq 0x50 -and $pdfBytes[2] -eq 0x44 -and $pdfBytes[3] -eq 0x46)
Write-Host "Exported PDF Valid Header: $isPdf (Length: $($pdfBytes.Length))"
