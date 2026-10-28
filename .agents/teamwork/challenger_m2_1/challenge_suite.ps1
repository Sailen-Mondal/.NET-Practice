# Empirical Challenge Suite for Milestone 2 (WebSite2)
# Strictly zero emojis.

param(
    [string]$BaseUrl = "http://localhost:8188"
)

$ErrorActionPreference = "Continue"

Write-Host "================================================================="
Write-Host "Empirical Challenge Test Suite - Milestone 2"
Write-Host "Base URL: $BaseUrl"
Write-Host "Time: $(Get-Date -Format 'yyyy-MM-ddTHH:mm:ssZ')"
Write-Host "================================================================="

function Extract-HiddenFields {
    param([string]$Html)
    $hidden = @{}
    $matches = [regex]::Matches($Html, '<input[^>]+type="hidden"[^>]*>')
    foreach ($m in $matches) {
        $nameMatch = [regex]::Match($m.Value, 'name="([^"]+)"')
        $valMatch = [regex]::Match($m.Value, 'value="([^"]*)"')
        if ($nameMatch.Success) {
            $name = $nameMatch.Groups[1].Value
            $val = if ($valMatch.Success) { [System.Net.WebUtility]::HtmlDecode($valMatch.Groups[1].Value) } else { "" }
            $hidden[$name] = $val
        }
    }
    return $hidden
}

function Send-Post {
    param(
        [string]$Url,
        [Microsoft.PowerShell.Commands.WebRequestSession]$Session,
        [string]$PreviousHtml,
        [hashtable]$Fields
    )
    $body = Extract-HiddenFields -Html $PreviousHtml
    foreach ($k in $Fields.Keys) {
        $body[$k] = $Fields[$k]
    }
    return Invoke-WebRequest -Uri $Url -Method Post -Body $body -WebSession $Session -UseBasicParsing
}

# =====================================================================
# CHALLENGE 1: RAPID POSTBACK PAGINATION & STATE TRANSITIONS
# =====================================================================
Write-Host "`n>>> CHALLENGE 1: Rapid Postback Pagination & State Transitions <<<"

$s = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$url = "$BaseUrl/Default.aspx"
$res = Invoke-WebRequest -Uri $url -WebSession $s -UseBasicParsing
$html = $res.Content

$rapidSuccess = 0
$rapidFailure = 0

$actions = @(
    @{ Name = "Search Rahul"; Fields = @{ "btnSearch" = "Search"; "txtFirstName" = "Rahul" } },
    @{ Name = "Filter Male"; Fields = @{ "btnFilterGender" = "Filter"; "DropDownList1" = "Male" } },
    @{ Name = "Switch Resume"; Fields = @{ "ddlViewMode" = "Resume"; "__EVENTTARGET" = "ddlViewMode" } },
    @{ Name = "Select Cand 2"; Fields = @{ "ddlViewMode" = "Resume"; "ddlCandidate" = "2"; "__EVENTTARGET" = "ddlCandidate" } },
    @{ Name = "Select Cand 4"; Fields = @{ "ddlViewMode" = "Resume"; "ddlCandidate" = "4"; "__EVENTTARGET" = "ddlCandidate" } },
    @{ Name = "Viewer Refresh"; Fields = @{ "__EVENTTARGET" = "CrystalReportViewer1"; "__EVENTARGUMENT" = "refresh" } },
    @{ Name = "Link Cand 1"; Fields = @{ "__EVENTTARGET" = "rptProfiles`$ctl01`$lnkViewReport"; "__EVENTARGUMENT" = "" } },
    @{ Name = "Link Cand 3"; Fields = @{ "__EVENTTARGET" = "rptProfiles`$ctl03`$lnkViewReport"; "__EVENTARGUMENT" = "" } },
    @{ Name = "Reset Filters"; Fields = @{ "btnReset" = "Reset Filters" } },
    @{ Name = "Search Priya"; Fields = @{ "btnSearch" = "Search"; "txtFirstName" = "Priya" } },
    @{ Name = "Filter Female"; Fields = @{ "btnFilterGender" = "Filter"; "DropDownList1" = "Female" } },
    @{ Name = "Viewer Page 1"; Fields = @{ "__EVENTTARGET" = "CrystalReportViewer1"; "__EVENTARGUMENT" = "page=1" } },
    @{ Name = "Switch Directory"; Fields = @{ "ddlViewMode" = "Directory"; "__EVENTTARGET" = "ddlViewMode" } },
    @{ Name = "Search Vikram"; Fields = @{ "btnSearch" = "Search"; "txtFirstName" = "Vikram" } },
    @{ Name = "Reset 2"; Fields = @{ "btnReset" = "Reset Filters" } },
    @{ Name = "Search Amit"; Fields = @{ "btnSearch" = "Search"; "txtFirstName" = "Amit" } },
    @{ Name = "Viewer Drill"; Fields = @{ "__EVENTTARGET" = "CrystalReportViewer1"; "__EVENTARGUMENT" = "drill=0" } },
    @{ Name = "Switch Resume 2"; Fields = @{ "ddlViewMode" = "Resume"; "__EVENTTARGET" = "ddlViewMode" } },
    @{ Name = "Select Cand 5"; Fields = @{ "ddlViewMode" = "Resume"; "ddlCandidate" = "5"; "__EVENTTARGET" = "ddlCandidate" } },
    @{ Name = "Link Cand 5"; Fields = @{ "__EVENTTARGET" = "rptProfiles`$ctl05`$lnkViewReport"; "__EVENTARGUMENT" = "" } },
    @{ Name = "Filter Male 2"; Fields = @{ "btnFilterGender" = "Filter"; "DropDownList1" = "Male" } },
    @{ Name = "Switch Directory 2"; Fields = @{ "ddlViewMode" = "Directory"; "__EVENTTARGET" = "ddlViewMode" } },
    @{ Name = "Search Sneha"; Fields = @{ "btnSearch" = "Search"; "txtFirstName" = "Sneha" } },
    @{ Name = "Reset 3"; Fields = @{ "btnReset" = "Reset Filters" } },
    @{ Name = "Viewer Final"; Fields = @{ "__EVENTTARGET" = "CrystalReportViewer1"; "__EVENTARGUMENT" = "last" } }
)

$sw = [System.Diagnostics.Stopwatch]::StartNew()
for ($i = 0; $i -lt $actions.Count; $i++) {
    $act = $actions[$i]
    $stepSw = [System.Diagnostics.Stopwatch]::StartNew()
    try {
        $pRes = Send-Post -Url $url -Session $s -PreviousHtml $html -Fields $act.Fields
        $stepSw.Stop()
        if ($pRes.StatusCode -eq 200 -and $pRes.Content.Length -gt 1000) {
            $rapidSuccess++
            $html = $pRes.Content
            Write-Host "  Step $($i+1)/$($actions.Count) [$($act.Name)]: HTTP 200 ($($stepSw.ElapsedMilliseconds)ms, $($pRes.Content.Length) bytes)"
        } else {
            $rapidFailure++
            Write-Host "  Step $($i+1)/$($actions.Count) [$($act.Name)]: UNEXPECTED STATUS $($pRes.StatusCode)"
        }
    } catch {
        $stepSw.Stop()
        $rapidFailure++
        Write-Host "  Step $($i+1)/$($actions.Count) [$($act.Name)]: ERROR: $($_.Exception.Message) ($($stepSw.ElapsedMilliseconds)ms)"
    }
}
$sw.Stop()
Write-Host "Rapid Postback Summary: Total=$($actions.Count), Success=$rapidSuccess, Fail=$rapidFailure, TotalTime=$($sw.ElapsedMilliseconds)ms, AvgTime=$([math]::Round($sw.ElapsedMilliseconds/$actions.Count, 1))ms/req"

# =====================================================================
# CHALLENGE 2: EMPIRICAL VERIFICATION OF PDF BINARY STRUCTURES
# =====================================================================
Write-Host "`n>>> CHALLENGE 2: PDF Binary Structure Analysis <<<"

function Analyze-Pdf {
    param(
        [string]$ModeName,
        [byte[]]$PdfBytes,
        [string]$Disposition
    )
    Write-Host "--- PDF Analysis: $ModeName ---"
    Write-Host "  Payload Size: $($PdfBytes.Length) bytes"
    Write-Host "  Content-Disposition: $Disposition"
    
    # Check Magic Bytes
    $magic = [System.Text.Encoding]::ASCII.GetString($PdfBytes, 0, [Math]::Min(10, $PdfBytes.Length))
    $validMagic = $magic.StartsWith("%PDF-")
    Write-Host "  Magic Bytes: '$($magic.Trim())' (Valid: $validMagic)"
    
    # Extract raw ASCII text for structural tokens
    $ascii = [System.Text.Encoding]::ASCII.GetString($PdfBytes)
    
    # Check EOF
    $hasEof = $ascii.Contains("%%EOF")
    Write-Host "  Trailer / EOF: Has %%EOF = $hasEof"
    
    # Object counts
    $objMatches = [regex]::Matches($ascii, '(\d+)\s+(\d+)\s+obj')
    $endobjMatches = [regex]::Matches($ascii, 'endobj')
    Write-Host "  PDF Objects: Defined = $($objMatches.Count), Closed = $($endobjMatches.Count)"
    
    # Stream counts
    $streamMatches = [regex]::Matches($ascii, 'stream\r?\n')
    $endstreamMatches = [regex]::Matches($ascii, 'endstream')
    Write-Host "  Data Streams: Start = $($streamMatches.Count), End = $($endstreamMatches.Count)"
    
    # Filter Types
    $flateMatches = [regex]::Matches($ascii, '/Filter\s*/FlateDecode')
    Write-Host "  FlateDecode Filters: $($flateMatches.Count)"
    
    # Font Resources
    $fontMatches = [regex]::Matches($ascii, '/Type\s*/Font\b')
    $fontDescMatches = [regex]::Matches($ascii, '/Type\s*/FontDescriptor\b')
    $baseFontMatches = [regex]::Matches($ascii, '/BaseFont\s*/([A-Za-z0-9+#]+)')
    $baseFonts = @($baseFontMatches | ForEach-Object { $_.Groups[1].Value } | Select-Object -Unique)
    Write-Host "  Font Dictionaries: $($fontMatches.Count)"
    Write-Host "  Font Descriptors: $($fontDescMatches.Count)"
    Write-Host "  Unique BaseFonts: $($baseFonts -join ', ')"
    
    # Images / XObjects
    $xobjMatches = [regex]::Matches($ascii, '/Type\s*/XObject')
    $imageSubtypeMatches = [regex]::Matches($ascii, '/Subtype\s*/Image')
    Write-Host "  XObjects: $($xobjMatches.Count), Image Subtypes: $($imageSubtypeMatches.Count)"
    
    # Pages
    $pageMatches = [regex]::Matches($ascii, '/Type\s*/Page\b')
    Write-Host "  Page Objects: $($pageMatches.Count)"
    
    $passed = ($validMagic -and $hasEof -and $objMatches.Count -gt 5 -and $streamMatches.Count -gt 0 -and $PdfBytes.Length -gt 5000)
    Write-Host "  Integrity Verdict: $(if ($passed) { 'PASS' } else { 'FAIL' })"
    return [PSCustomObject]@{
        Mode = $ModeName
        Size = $PdfBytes.Length
        Objects = $objMatches.Count
        Streams = $streamMatches.Count
        Fonts = $baseFonts.Count
        BaseFonts = ($baseFonts -join ', ')
        Images = $imageSubtypeMatches.Count
        Pages = $pageMatches.Count
        Passed = $passed
    }
}

# 1. Directory Mode PDF
$sPdf1 = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$initResPdf1 = Invoke-WebRequest -Uri $url -WebSession $sPdf1 -UseBasicParsing
$pdfResDir = Send-Post -Url $url -Session $sPdf1 -PreviousHtml $initResPdf1.Content -Fields @{
    "btnPDF" = "Convert To PDF"; "ddlViewMode" = "Directory"
}
$dirAnalysis = Analyze-Pdf -ModeName "Directory Mode (CandidateDirectory.rpt)" -PdfBytes $pdfResDir.Content -Disposition $pdfResDir.Headers["Content-Disposition"]

# 2. Resume Mode PDF (Candidate 2 - Priya Mukherjee)
$sPdf2 = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$initResPdf2 = Invoke-WebRequest -Uri $url -WebSession $sPdf2 -UseBasicParsing
$resModeSwitch = Send-Post -Url $url -Session $sPdf2 -PreviousHtml $initResPdf2.Content -Fields @{
    "ddlViewMode" = "Resume"; "__EVENTTARGET" = "ddlViewMode"
}
$resSelectCand2 = Send-Post -Url $url -Session $sPdf2 -PreviousHtml $resModeSwitch.Content -Fields @{
    "ddlViewMode" = "Resume"; "ddlCandidate" = "2"; "__EVENTTARGET" = "ddlCandidate"
}
$pdfResResume = Send-Post -Url $url -Session $sPdf2 -PreviousHtml $resSelectCand2.Content -Fields @{
    "btnPDF" = "Convert To PDF"; "ddlViewMode" = "Resume"; "ddlCandidate" = "2"
}
$resumeAnalysis = Analyze-Pdf -ModeName "Resume Mode - Priya Mukherjee (CandidateResume.rpt)" -PdfBytes $pdfResResume.Content -Disposition $pdfResResume.Headers["Content-Disposition"]

# 3. Resume Mode PDF (Candidate 5 - Vikram Singh)
$resSelectCand5 = Send-Post -Url $url -Session $sPdf2 -PreviousHtml $resSelectCand2.Content -Fields @{
    "ddlViewMode" = "Resume"; "ddlCandidate" = "5"; "__EVENTTARGET" = "ddlCandidate"
}
$pdfResResume5 = Send-Post -Url $url -Session $sPdf2 -PreviousHtml $resSelectCand5.Content -Fields @{
    "btnPDF" = "Convert To PDF"; "ddlViewMode" = "Resume"; "ddlCandidate" = "5"
}
$resume5Analysis = Analyze-Pdf -ModeName "Resume Mode - Vikram Singh (CandidateResume.rpt)" -PdfBytes $pdfResResume5.Content -Disposition $pdfResResume5.Headers["Content-Disposition"]


# =====================================================================
# CHALLENGE 3: CONCURRENT DYNAMIC IMAGE SERVING (CrystalImageHandler)
# =====================================================================
Write-Host "`n>>> CHALLENGE 3: Concurrent Dynamic Image Serving <<<"

# Test 3A: Concurrent Multi-Session Dynamic Image Fetching
Write-Host "Test 3A: Concurrency across 10 independent user sessions..."
$numSessions = 10
$sessionImages = @()

for ($k = 0; $k -lt $numSessions; $k++) {
    $sess = New-Object Microsoft.PowerShell.Commands.WebRequestSession
    $p = Invoke-WebRequest -Uri $url -WebSession $sess -UseBasicParsing
    $m = [regex]::Match($p.Content, 'CrystalImageHandler\.aspx\?dynamicimage=([^"''\s<>]+)')
    if ($m.Success) {
        $sessionImages += @{
            Session = $sess
            Url = "$BaseUrl/$($m.Value)"
        }
    }
}

Write-Host "Harvested $($sessionImages.Count) active image tokens across $numSessions sessions."

$scriptBlockA = {
    param($TargetUrl)
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    try {
        $req = [System.Net.HttpWebRequest]::Create($TargetUrl)
        $req.Method = "GET"
        $req.Timeout = 10000
        $resp = $req.GetResponse()
        $stream = $resp.GetResponseStream()
        $ms = New-Object System.IO.MemoryStream
        $stream.CopyTo($ms)
        $bytes = $ms.ToArray()
        $sw.Stop()
        $resp.Close()
        
        $isPng = ($bytes.Length -ge 8 -and $bytes[0] -eq 0x89 -and $bytes[1] -eq 0x50 -and $bytes[2] -eq 0x4E -and $bytes[3] -eq 0x47)
        return [PSCustomObject]@{
            Url = $TargetUrl
            StatusCode = 200
            ContentType = $resp.ContentType
            Length = $bytes.Length
            IsPng = $isPng
            DurationMs = $sw.ElapsedMilliseconds
            Error = $null
        }
    } catch {
        $sw.Stop()
        return [PSCustomObject]@{
            Url = $TargetUrl
            StatusCode = -1
            ContentType = $null
            Length = 0
            IsPng = $false
            DurationMs = $sw.ElapsedMilliseconds
            Error = $_.Exception.Message
        }
    }
}

$jobsA = @()
$swA = [System.Diagnostics.Stopwatch]::StartNew()
foreach ($item in $sessionImages) {
    $jobsA += Start-Job -ScriptBlock $scriptBlockA -ArgumentList $item.Url
}
$resultsA = @()
foreach ($jb in $jobsA) {
    $resultsA += Wait-Job $jb | Receive-Job
    Remove-Job $jb
}
$swA.Stop()

$succA = 0
$failA = 0
$pngA = 0
$totalLatA = 0

foreach ($r in $resultsA) {
    if ($r.StatusCode -eq 200 -and $r.IsPng -and $r.Length -gt 1000) {
        $succA++
        $pngA++
    } else {
        $failA++
        Write-Host "  Failure: $($r.Url) - $($r.Error)"
    }
    $totalLatA += $r.DurationMs
}
$avgLatA = if ($resultsA.Count -gt 0) { [math]::Round($totalLatA / $resultsA.Count, 1) } else { 0 }

Write-Host "Multi-Session Concurrency Results:"
Write-Host "  Concurrent Requests: $($sessionImages.Count)"
Write-Host "  HTTP 200 OK: $succA"
Write-Host "  Valid PNGs (>1KB): $pngA"
Write-Host "  Failed: $failA"
Write-Host "  Wall Time: $($swA.ElapsedMilliseconds)ms"
Write-Host "  Average Latency: ${avgLatA}ms"
Write-Host "  Multi-Session Concurrency Verdict: $(if ($failA -eq 0) { 'PASS' } else { 'FAIL' })"

# Test 3B: Ephemeral Token Single-Use Cache Purge Characterization
Write-Host "`nTest 3B: Ephemeral token single-use cache purge behavior..."
$sessB = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$resB = Invoke-WebRequest -Uri $url -WebSession $sessB -UseBasicParsing
$matchB = [regex]::Match($resB.Content, 'CrystalImageHandler\.aspx\?dynamicimage=([^"''\s<>]+)')
if ($matchB.Success) {
    $imgTokenUrl = "$BaseUrl/$($matchB.Value)"
    $r1 = Invoke-WebRequest -Uri $imgTokenUrl -WebSession $sessB -UseBasicParsing
    Write-Host "  First Request: HTTP $($r1.StatusCode), Content-Type: $($r1.Headers['Content-Type']), Size: $($r1.Content.Length) bytes"
    
    $r2Status = "FAILED"
    try {
        $r2 = Invoke-WebRequest -Uri $imgTokenUrl -WebSession $sessB -UseBasicParsing
        $r2Status = "HTTP $($r2.StatusCode)"
    } catch {
        $r2Status = "404 Not Found (Ephemeral Cache Purged)"
    }
    Write-Host "  Second Request to Same Token: $r2Status"
}

Write-Host "`n================================================================="
Write-Host "Empirical Challenge Suite Completed"
Write-Host "================================================================="
