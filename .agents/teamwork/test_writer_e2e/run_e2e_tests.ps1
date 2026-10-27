<#
.SYNOPSIS
    Automated E2E Test Suite for WebSite2 Crystal Reports Solution.
.DESCRIPTION
    Executes comprehensive 4-tier opaque-box HTTP test automation against
    the live ASP.NET WebForms application at http://localhost:8188/Default.aspx.
    Tiers covered:
      Tier 1: Feature Coverage (7 features, >=5 tests each = 35 tests)
      Tier 2: Boundary & Corner Cases (5 areas, >=5 tests each = 25 tests)
      Tier 3: Cross-Feature Combinations (10 pairwise tests)
      Tier 4: Real-World Application Scenarios (5 multi-step workflows, 24 sub-checks)
    Strictly zero emojis in all outputs and code.
#>

[CmdletBinding()]
param(
    [string]$BaseUrl = "http://localhost:8188"
)

$ErrorActionPreference = "Stop"

# Test execution state
$script:PassCount = 0
$script:FailCount = 0
$script:TestResults = [System.Collections.Generic.List[PSObject]]::new()

function Get-Timestamp {
    return (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
}

function Record-TestResult {
    param(
        [string]$TestId,
        [string]$Tier,
        [string]$Category,
        [string]$Description,
        [bool]$Passed,
        [string]$Details = ""
    )
    $statusStr = if ($Passed) { "PASS" } else { "FAIL" }
    if ($Passed) {
        $script:PassCount++
    } else {
        $script:FailCount++
    }

    $resultObj = [PSCustomObject]@{
        TestId      = $TestId
        Tier        = $Tier
        Category    = $Category
        Description = $Description
        Status      = $statusStr
        Details     = $Details
        Timestamp   = (Get-Timestamp)
    }
    $script:TestResults.Add($resultObj)

    $prefix = "[$statusStr] $TestId"
    $msg = "$prefix - $Description"
    if (-not $Passed -and $Details) {
        $msg += " | Error: $Details"
    }
    Write-Host $msg
}

function New-FreshSession {
    return New-Object Microsoft.PowerShell.Commands.WebRequestSession
}

function Extract-HiddenField {
    param(
        [string]$Html,
        [string]$FieldName
    )
    $pattern = 'id="' + [regex]::Escape($FieldName) + '"\s+value="([^"]*)"'
    $match = [regex]::Match($Html, $pattern)
    if ($match.Success) {
        return $match.Groups[1].Value
    }
    # Fallback to name pattern
    $pattern2 = 'name="' + [regex]::Escape($FieldName) + '"\s+value="([^"]*)"'
    $match2 = [regex]::Match($Html, $pattern2)
    if ($match2.Success) {
        return $match2.Groups[1].Value
    }
    return ""
}

function Send-WebFormsPost {
    param(
        [string]$Url,
        [Microsoft.PowerShell.Commands.WebRequestSession]$Session,
        [string]$PreviousHtml,
        [hashtable]$FieldValues
    )
    $vs = Extract-HiddenField -Html $PreviousHtml -FieldName "__VIEWSTATE"
    $ev = Extract-HiddenField -Html $PreviousHtml -FieldName "__EVENTVALIDATION"
    $vsg = Extract-HiddenField -Html $PreviousHtml -FieldName "__VIEWSTATEGENERATOR"

    $body = @{}
    if ($vs) { $body["__VIEWSTATE"] = $vs }
    if ($ev) { $body["__EVENTVALIDATION"] = $ev }
    if ($vsg) { $body["__VIEWSTATEGENERATOR"] = $vsg }

    foreach ($k in $FieldValues.Keys) {
        $body[$k] = $FieldValues[$k]
    }

    try {
        return Invoke-WebRequest -Uri $Url -Method Post -Body $body -WebSession $Session -UseBasicParsing
    } catch {
        if ($_.Exception.Response) {
            return $_.Exception.Response
        }
        throw $_
    }
}

function Get-CardCount {
    param([string]$Html)
    return ([regex]::Matches($Html, '<div class="profile-card">')).Count
}

function Get-CardNames {
    param([string]$Html)
    $names = @()
    $matches = [regex]::Matches($Html, '<div class="profile-name">([^<]+)</div>')
    foreach ($m in $matches) {
        $names += $m.Groups[1].Value.Trim()
    }
    return $names
}

function Test-IsPdfBytes {
    param($Content)
    if (-not $Content) { return $false }
    $bytes = if ($Content -is [byte[]]) { $Content } else { [System.Text.Encoding]::ASCII.GetBytes($Content) }
    if ($bytes.Length -lt 4) { return $false }
    return ($bytes[0] -eq 0x25 -and $bytes[1] -eq 0x50 -and $bytes[2] -eq 0x44 -and $bytes[3] -eq 0x46)
}

function Test-IsPngBytes {
    param($Content)
    if (-not $Content) { return $false }
    $bytes = if ($Content -is [byte[]]) { $Content } else { [System.Text.Encoding]::ASCII.GetBytes($Content) }
    if ($bytes.Length -lt 4) { return $false }
    return ($bytes[0] -eq 0x89 -and $bytes[1] -eq 0x50 -and $bytes[2] -eq 0x4E -and $bytes[3] -eq 0x47)
}

# --- BEGIN TEST SUITE EXECUTION ---

Write-Host "================================================================="
Write-Host "WebSite2 E2E Automated Test Suite"
Write-Host "Target URL : $BaseUrl/Default.aspx"
Write-Host "Start Time : $(Get-Timestamp)"
Write-Host "================================================================="
Write-Host ""

$targetUrl = "$BaseUrl/Default.aspx"

# -----------------------------------------------------------------
# TIER 1: FEATURE COVERAGE (7 features, >=5 tests each = 35 tests)
# -----------------------------------------------------------------
Write-Host "--- TIER 1: FEATURE COVERAGE ---"

# Feature 1.1: Multi-Field Search (5 tests)
$s1 = New-FreshSession
$initRes = Invoke-WebRequest -Uri $targetUrl -WebSession $s1 -UseBasicParsing

# T1.1.1: Search Rahul
$resRahul = Send-WebFormsPost -Url $targetUrl -Session $s1 -PreviousHtml $initRes.Content -FieldValues @{
    "btnSearch" = "Search"; "txtFirstName" = "Rahul"
}
$namesRahul = Get-CardNames -Html $resRahul.Content
$pass1_1_1 = ($namesRahul.Count -eq 1 -and $namesRahul[0] -eq "Rahul Sharma")
Record-TestResult -TestId "T1.1.1" -Tier "Tier 1" -Category "Search" -Description "Search candidate 'Rahul' returns Rahul Sharma" -Passed $pass1_1_1 -Details "Found: $($namesRahul -join ', ')"

# T1.1.2: Search Priya
$resPriya = Send-WebFormsPost -Url $targetUrl -Session $s1 -PreviousHtml $resRahul.Content -FieldValues @{
    "btnSearch" = "Search"; "txtFirstName" = "Priya"
}
$namesPriya = Get-CardNames -Html $resPriya.Content
$pass1_1_2 = ($namesPriya.Count -eq 1 -and $namesPriya[0] -eq "Priya Mukherjee")
Record-TestResult -TestId "T1.1.2" -Tier "Tier 1" -Category "Search" -Description "Search candidate 'Priya' returns Priya Mukherjee" -Passed $pass1_1_2 -Details "Found: $($namesPriya -join ', ')"

# T1.1.3: Search Amit
$resAmit = Send-WebFormsPost -Url $targetUrl -Session $s1 -PreviousHtml $resPriya.Content -FieldValues @{
    "btnSearch" = "Search"; "txtFirstName" = "Amit"
}
$namesAmit = Get-CardNames -Html $resAmit.Content
$pass1_1_3 = ($namesAmit.Count -eq 1 -and $namesAmit[0] -eq "Amit Verma")
Record-TestResult -TestId "T1.1.3" -Tier "Tier 1" -Category "Search" -Description "Search candidate 'Amit' returns Amit Verma" -Passed $pass1_1_3 -Details "Found: $($namesAmit -join ', ')"

# T1.1.4: Search Sneha
$resSneha = Send-WebFormsPost -Url $targetUrl -Session $s1 -PreviousHtml $resAmit.Content -FieldValues @{
    "btnSearch" = "Search"; "txtFirstName" = "Sneha"
}
$namesSneha = Get-CardNames -Html $resSneha.Content
$pass1_1_4 = ($namesSneha.Count -eq 1 -and $namesSneha[0] -eq "Sneha Patel")
Record-TestResult -TestId "T1.1.4" -Tier "Tier 1" -Category "Search" -Description "Search candidate 'Sneha' returns Sneha Patel" -Passed $pass1_1_4 -Details "Found: $($namesSneha -join ', ')"

# T1.1.5: Search Vikram
$resVikram = Send-WebFormsPost -Url $targetUrl -Session $s1 -PreviousHtml $resSneha.Content -FieldValues @{
    "btnSearch" = "Search"; "txtFirstName" = "Vikram"
}
$namesVikram = Get-CardNames -Html $resVikram.Content
$pass1_1_5 = ($namesVikram.Count -eq 1 -and $namesVikram[0] -eq "Vikram Singh")
Record-TestResult -TestId "T1.1.5" -Tier "Tier 1" -Category "Search" -Description "Search candidate 'Vikram' returns Vikram Singh" -Passed $pass1_1_5 -Details "Found: $($namesVikram -join ', ')"

# Feature 1.2: Gender Filter (5 tests)
$s2 = New-FreshSession
$initRes2 = Invoke-WebRequest -Uri $targetUrl -WebSession $s2 -UseBasicParsing

# T1.2.1: Filter All Genders
$resAll = Send-WebFormsPost -Url $targetUrl -Session $s2 -PreviousHtml $initRes2.Content -FieldValues @{
    "btnFilterGender" = "Filter"; "DropDownList1" = ""
}
$cardsAll = Get-CardCount -Html $resAll.Content
$pass1_2_1 = ($cardsAll -eq 5)
Record-TestResult -TestId "T1.2.1" -Tier "Tier 1" -Category "Gender Filter" -Description "Filter 'All Genders' returns all 5 candidates" -Passed $pass1_2_1 -Details "Count: $cardsAll"

# T1.2.2: Filter Male
$resMale = Send-WebFormsPost -Url $targetUrl -Session $s2 -PreviousHtml $resAll.Content -FieldValues @{
    "btnFilterGender" = "Filter"; "DropDownList1" = "Male"
}
$cardsMale = Get-CardCount -Html $resMale.Content
$namesMale = Get-CardNames -Html $resMale.Content
$pass1_2_2 = ($cardsMale -eq 3 -and $namesMale -contains "Rahul Sharma" -and $namesMale -contains "Amit Verma" -and $namesMale -contains "Vikram Singh")
Record-TestResult -TestId "T1.2.2" -Tier "Tier 1" -Category "Gender Filter" -Description "Filter 'Male' returns exactly 3 male candidates" -Passed $pass1_2_2 -Details "Count: $cardsMale"

# T1.2.3: Filter Female
$resFemale = Send-WebFormsPost -Url $targetUrl -Session $s2 -PreviousHtml $resMale.Content -FieldValues @{
    "btnFilterGender" = "Filter"; "DropDownList1" = "Female"
}
$cardsFemale = Get-CardCount -Html $resFemale.Content
$namesFemale = Get-CardNames -Html $resFemale.Content
$pass1_2_3 = ($cardsFemale -eq 2 -and $namesFemale -contains "Priya Mukherjee" -and $namesFemale -contains "Sneha Patel")
Record-TestResult -TestId "T1.2.3" -Tier "Tier 1" -Category "Gender Filter" -Description "Filter 'Female' returns exactly 2 female candidates" -Passed $pass1_2_3 -Details "Count: $cardsFemale"

# T1.2.4: Transition Male to Female
$pass1_2_4 = ($cardsMale -eq 3 -and $cardsFemale -eq 2)
Record-TestResult -TestId "T1.2.4" -Tier "Tier 1" -Category "Gender Filter" -Description "Gender transition dynamically updates counts from 3 to 2" -Passed $pass1_2_4 -Details "Male: $cardsMale, Female: $cardsFemale"

# T1.2.5: Filter State Persistence
$dropdownSelected = $resFemale.Content -match 'value="Female"\s+selected="selected"'
Record-TestResult -TestId "T1.2.5" -Tier "Tier 1" -Category "Gender Filter" -Description "Selected gender persists across postbacks" -Passed $dropdownSelected -Details "Selected attribute present: $dropdownSelected"

# Feature 1.3: View Mode Switching (5 tests)
$s3 = New-FreshSession
$initRes3 = Invoke-WebRequest -Uri $targetUrl -WebSession $s3 -UseBasicParsing

# T1.3.1: Initial mode is Directory
$pass1_3_1 = ($initRes3.Content -match 'value="Directory"\s+selected="selected"' -or $initRes3.Content -match 'All Candidates Directory')
Record-TestResult -TestId "T1.3.1" -Tier "Tier 1" -Category "View Mode" -Description "Initial view mode defaults to All Candidates Directory" -Passed $pass1_3_1

# T1.3.2: Switch to Resume view mode
$resResumeMode = Send-WebFormsPost -Url $targetUrl -Session $s3 -PreviousHtml $initRes3.Content -FieldValues @{
    "ddlViewMode" = "Resume"; "__EVENTTARGET" = "ddlViewMode"
}
$hasCandidateSelector = ($resResumeMode.Content.Contains("ddlCandidate") -and -not $resResumeMode.Content.Contains('pnlCandidateSelector" style="display:none'))
Record-TestResult -TestId "T1.3.2" -Tier "Tier 1" -Category "View Mode" -Description "Switch to Resume mode activates candidate selector dropdown" -Passed $hasCandidateSelector

# T1.3.3: Report header updates in Resume mode
$headerMatch = [regex]::Match($resResumeMode.Content, 'id="lblReportTitle"[^>]*>([^<]+)<')
$pass1_3_3 = ($headerMatch.Success -and $headerMatch.Groups[1].Value -match "Resume")
Record-TestResult -TestId "T1.3.3" -Tier "Tier 1" -Category "View Mode" -Description "Report header label updates to Individual Resume mode" -Passed $pass1_3_3 -Details "Header: $($headerMatch.Groups[1].Value)"

# T1.3.4: Select Candidate 2 in Resume mode
$resCand2 = Send-WebFormsPost -Url $targetUrl -Session $s3 -PreviousHtml $resResumeMode.Content -FieldValues @{
    "ddlViewMode" = "Resume"; "ddlCandidate" = "2"; "__EVENTTARGET" = "ddlCandidate"
}
$namesCand2 = Get-CardNames -Html $resCand2.Content
$pass1_3_4 = ($namesCand2.Count -eq 1 -and $namesCand2[0] -eq "Priya Mukherjee")
Record-TestResult -TestId "T1.3.4" -Tier "Tier 1" -Category "View Mode" -Description "Selecting Candidate 2 in Resume mode displays Priya Mukherjee" -Passed $pass1_3_4 -Details "Found: $($namesCand2 -join ', ')"

# T1.3.5: Switch back to Directory mode
$resDirMode = Send-WebFormsPost -Url $targetUrl -Session $s3 -PreviousHtml $resCand2.Content -FieldValues @{
    "ddlViewMode" = "Directory"; "__EVENTTARGET" = "ddlViewMode"
}
$cardsRestored = Get-CardCount -Html $resDirMode.Content
$pass1_3_5 = ($cardsRestored -eq 5)
Record-TestResult -TestId "T1.3.5" -Tier "Tier 1" -Category "View Mode" -Description "Switching back to Directory mode restores all 5 candidates" -Passed $pass1_3_5 -Details "Restored count: $cardsRestored"

# Feature 1.4: PDF Export (5 tests)
$s4 = New-FreshSession
$initRes4 = Invoke-WebRequest -Uri $targetUrl -WebSession $s4 -UseBasicParsing

# T1.4.1: Directory PDF HTTP Status 200
$resPdfDir = Send-WebFormsPost -Url $targetUrl -Session $s4 -PreviousHtml $initRes4.Content -FieldValues @{
    "btnPDF" = "Convert To PDF"; "ddlViewMode" = "Directory"
}
$pass1_4_1 = ($resPdfDir.StatusCode -eq 200)
Record-TestResult -TestId "T1.4.1" -Tier "Tier 1" -Category "PDF Export" -Description "Directory PDF export returns HTTP 200 OK" -Passed $pass1_4_1 -Details "Status: $($resPdfDir.StatusCode)"

# T1.4.2: Directory PDF Content-Type
$contentTypeDir = $resPdfDir.Headers["Content-Type"]
$pass1_4_2 = ($contentTypeDir -match "application/pdf")
Record-TestResult -TestId "T1.4.2" -Tier "Tier 1" -Category "PDF Export" -Description "Directory PDF Content-Type is application/pdf" -Passed $pass1_4_2 -Details "Content-Type: $contentTypeDir"

# T1.4.3: Directory PDF Content-Disposition filename
$dispositionDir = $resPdfDir.Headers["Content-Disposition"]
$pass1_4_3 = ($dispositionDir -match "filename=CandidateDirectory\.pdf")
Record-TestResult -TestId "T1.4.3" -Tier "Tier 1" -Category "PDF Export" -Description "Directory PDF Content-Disposition contains CandidateDirectory.pdf" -Passed $pass1_4_3 -Details "Disposition: $dispositionDir"

# T1.4.4: Directory PDF Magic Header
$isPdfDirValid = Test-IsPdfBytes -Content $resPdfDir.Content
Record-TestResult -TestId "T1.4.4" -Tier "Tier 1" -Category "PDF Export" -Description "Directory PDF contains valid binary %PDF- magic header" -Passed $isPdfDirValid

# T1.4.5: Resume Mode PDF Export Filename and Header
$s4b = New-FreshSession
$initRes4b = Invoke-WebRequest -Uri $targetUrl -WebSession $s4b -UseBasicParsing
$resResumeSwitch = Send-WebFormsPost -Url $targetUrl -Session $s4b -PreviousHtml $initRes4b.Content -FieldValues @{
    "ddlViewMode" = "Resume"; "__EVENTTARGET" = "ddlViewMode"
}
$resPdfResume = Send-WebFormsPost -Url $targetUrl -Session $s4b -PreviousHtml $resResumeSwitch.Content -FieldValues @{
    "btnPDF" = "Convert To PDF"; "ddlViewMode" = "Resume"
}
$dispositionResume = $resPdfResume.Headers["Content-Disposition"]
$isPdfResumeValid = Test-IsPdfBytes -Content $resPdfResume.Content
$pass1_4_5 = ($dispositionResume -match "filename=CandidateResume\.pdf" -and $isPdfResumeValid)
Record-TestResult -TestId "T1.4.5" -Tier "Tier 1" -Category "PDF Export" -Description "Resume view PDF export produces CandidateResume.pdf with valid binary header" -Passed $pass1_4_5 -Details "Disposition: $dispositionResume"

# Feature 1.5: Client-Side Printing (5 tests)
$s5 = New-FreshSession
$initRes5 = Invoke-WebRequest -Uri $targetUrl -WebSession $s5 -UseBasicParsing

# T1.5.1: Print Button Presence
$hasPrintBtn = ($initRes5.Content -match '<input[^>]+id="btnPrint"')
Record-TestResult -TestId "T1.5.1" -Tier "Tier 1" -Category "Client Printing" -Description "DOM contains input element with id='btnPrint'" -Passed $hasPrintBtn

# T1.5.2: Print Button Value Caption
$btnValueMatch = [regex]::Match($initRes5.Content, '<input[^>]+id="btnPrint"[^>]+value="([^"]+)"')
$pass1_5_2 = ($btnValueMatch.Success -and $btnValueMatch.Groups[1].Value -eq "Print Report")
Record-TestResult -TestId "T1.5.2" -Tier "Tier 1" -Category "Client Printing" -Description "Print button caption equals 'Print Report'" -Passed $pass1_5_2

# T1.5.3: JavaScript printClientReport Function Definition
$hasPrintFunc = ($initRes5.Content -match 'function\s+printClientReport\s*\(')
Record-TestResult -TestId "T1.5.3" -Tier "Tier 1" -Category "Client Printing" -Description "Page defines JavaScript function printClientReport()" -Passed $hasPrintFunc

# T1.5.4: Report Preview Container dvReport
$hasDvReport = ($initRes5.Content -match '<div\s+id="dvReport"')
Record-TestResult -TestId "T1.5.4" -Tier "Tier 1" -Category "Client Printing" -Description "Report container dvReport is defined for print targeting" -Passed $hasDvReport

# T1.5.5: Print Button Event Handler Binding
$hasPrintOnClick = ($initRes5.Content -match '<input[^>]+id="btnPrint"[^>]+onclick="printClientReport\(\)"')
Record-TestResult -TestId "T1.5.5" -Tier "Tier 1" -Category "Client Printing" -Description "Print button onclick binds directly to printClientReport()" -Passed $hasPrintOnClick

# Feature 1.6: Dynamic Profile Photos via CrystalImageHandler (5 tests)
# T1.6.1: Dynamic Image URL Rendered in Viewer
$dynamicImageMatch = [regex]::Match($initRes5.Content, 'CrystalImageHandler\.aspx\?dynamicimage=([^"''\s<>]+)')
$pass1_6_1 = $dynamicImageMatch.Success
Record-TestResult -TestId "T1.6.1" -Tier "Tier 1" -Category "Dynamic Photos" -Description "CrystalReportViewer renders CrystalImageHandler.aspx dynamic image URL" -Passed $pass1_6_1 -Details "Found: $($dynamicImageMatch.Value)"

# T1.6.2: Dynamic Image Request Returns HTTP 200
$imageUrl = "$BaseUrl/" + $dynamicImageMatch.Value
$imgResponse = Invoke-WebRequest -Uri $imageUrl -WebSession $s5 -UseBasicParsing
$pass1_6_2 = ($imgResponse.StatusCode -eq 200)
Record-TestResult -TestId "T1.6.2" -Tier "Tier 1" -Category "Dynamic Photos" -Description "CrystalImageHandler returns HTTP 200 OK" -Passed $pass1_6_2 -Details "Status: $($imgResponse.StatusCode)"

# T1.6.3: Dynamic Image Content-Type is image/png
$imgContentType = $imgResponse.Headers["Content-Type"]
$pass1_6_3 = ($imgContentType -match "image/png")
Record-TestResult -TestId "T1.6.3" -Tier "Tier 1" -Category "Dynamic Photos" -Description "CrystalImageHandler response Content-Type is image/png" -Passed $pass1_6_3 -Details "Type: $imgContentType"

# T1.6.4: Dynamic Image PNG Magic Bytes
$isPngValid = Test-IsPngBytes -Content $imgResponse.Content
Record-TestResult -TestId "T1.6.4" -Tier "Tier 1" -Category "Dynamic Photos" -Description "CrystalImageHandler returns valid PNG binary stream" -Passed $isPngValid

# T1.6.5: Dynamic Image Stream Size Validation
$rawLength = if ($imgResponse.RawContentLength -gt 0) { $imgResponse.RawContentLength } else { $imgResponse.Content.Length }
$pass1_6_5 = ($rawLength -gt 1000)
Record-TestResult -TestId "T1.6.5" -Tier "Tier 1" -Category "Dynamic Photos" -Description "Dynamic photo byte stream is non-empty (>1000 bytes)" -Passed $pass1_6_5 -Details "Length: $rawLength bytes"

# Feature 1.7: Resume Document Hyperlinks (5 tests)
$candidates = @(
    @{ Id = 1; Name = "Rahul";  File = "Resumes/rahul_sharma_resume.pdf" },
    @{ Id = 2; Name = "Priya";  File = "Resumes/priya_mukherjee_resume.pdf" },
    @{ Id = 3; Name = "Amit";   File = "Resumes/amit_verma_resume.pdf" },
    @{ Id = 4; Name = "Sneha";  File = "Resumes/sneha_patel_resume.pdf" },
    @{ Id = 5; Name = "Vikram"; File = "Resumes/vikram_singh_resume.pdf" }
)

foreach ($c in $candidates) {
    $rUrl = "$BaseUrl/$($c.File)"
    $rRes = Invoke-WebRequest -Uri $rUrl -UseBasicParsing
    $isPdf = Test-IsPdfBytes -Content $rRes.Content
    $pass1_7 = ($rRes.StatusCode -eq 200 -and $isPdf)
    Record-TestResult -TestId "T1.7.$($c.Id)" -Tier "Tier 1" -Category "Resume Links" -Description "Candidate $($c.Name) resume link returns HTTP 200 with valid PDF" -Passed $pass1_7 -Details "Status: $($rRes.StatusCode), Valid PDF: $isPdf"
}

Write-Host ""

# -----------------------------------------------------------------
# TIER 2: BOUNDARY & CORNER CASES (5 areas, >=5 tests each = 25 tests)
# -----------------------------------------------------------------
Write-Host "--- TIER 2: BOUNDARY & CORNER CASES ---"

# Area 2.1: Empty Search Input (5 tests)
$s2_1 = New-FreshSession
$rInit2_1 = Invoke-WebRequest -Uri $targetUrl -WebSession $s2_1 -UseBasicParsing

# T2.1.1: Blank search initially returns 5 cards
$rBlank1 = Send-WebFormsPost -Url $targetUrl -Session $s2_1 -PreviousHtml $rInit2_1.Content -FieldValues @{
    "btnSearch" = "Search"; "txtFirstName" = ""
}
$count2_1_1 = Get-CardCount -Html $rBlank1.Content
Record-TestResult -TestId "T2.1.1" -Tier "Tier 2" -Category "Empty Search" -Description "Empty search input returns all 5 candidate cards" -Passed ($count2_1_1 -eq 5) -Details "Count: $count2_1_1"

# T2.1.2: Search filter then empty search restores 5 cards
$rSearchThenBlank = Send-WebFormsPost -Url $targetUrl -Session $s2_1 -PreviousHtml $rBlank1.Content -FieldValues @{
    "btnSearch" = "Search"; "txtFirstName" = "Rahul"
}
$rBlankRestored = Send-WebFormsPost -Url $targetUrl -Session $s2_1 -PreviousHtml $rSearchThenBlank.Content -FieldValues @{
    "btnSearch" = "Search"; "txtFirstName" = ""
}
$count2_1_2 = Get-CardCount -Html $rBlankRestored.Content
Record-TestResult -TestId "T2.1.2" -Tier "Tier 2" -Category "Empty Search" -Description "Empty search after keyword search restores all 5 candidates" -Passed ($count2_1_2 -eq 5) -Details "Count: $count2_1_2"

# T2.1.3: Empty search with Male filter returns 3 cards
$rMaleBlank = Send-WebFormsPost -Url $targetUrl -Session $s2_1 -PreviousHtml $rBlankRestored.Content -FieldValues @{
    "btnFilterGender" = "Filter"; "DropDownList1" = "Male"
}
$count2_1_3 = Get-CardCount -Html $rMaleBlank.Content
Record-TestResult -TestId "T2.1.3" -Tier "Tier 2" -Category "Empty Search" -Description "Empty search combined with Male filter preserves all 3 male candidates" -Passed ($count2_1_3 -eq 3) -Details "Count: $count2_1_3"

# T2.1.4: Empty search with Female filter returns 2 cards
$rFemaleBlank = Send-WebFormsPost -Url $targetUrl -Session $s2_1 -PreviousHtml $rMaleBlank.Content -FieldValues @{
    "btnFilterGender" = "Filter"; "DropDownList1" = "Female"
}
$count2_1_4 = Get-CardCount -Html $rFemaleBlank.Content
Record-TestResult -TestId "T2.1.4" -Tier "Tier 2" -Category "Empty Search" -Description "Empty search combined with Female filter preserves both 2 female candidates" -Passed ($count2_1_4 -eq 2) -Details "Count: $count2_1_4"

# T2.1.5: Reset restores directory view with empty search
$rReset2_1 = Send-WebFormsPost -Url $targetUrl -Session $s2_1 -PreviousHtml $rFemaleBlank.Content -FieldValues @{
    "btnReset" = "Reset Filters"
}
$count2_1_5 = Get-CardCount -Html $rReset2_1.Content
Record-TestResult -TestId "T2.1.5" -Tier "Tier 2" -Category "Empty Search" -Description "Reset filters restores default 5 candidates" -Passed ($count2_1_5 -eq 5) -Details "Count: $count2_1_5"

# Area 2.2: Whitespace Handling (5 tests)
$s2_2 = New-FreshSession
$rInit2_2 = Invoke-WebRequest -Uri $targetUrl -WebSession $s2_2 -UseBasicParsing

# T2.2.1: Leading whitespace "   Rahul"
$rLeadWhite = Send-WebFormsPost -Url $targetUrl -Session $s2_2 -PreviousHtml $rInit2_2.Content -FieldValues @{
    "btnSearch" = "Search"; "txtFirstName" = "   Rahul"
}
$namesLead = Get-CardNames -Html $rLeadWhite.Content
$pass2_2_1 = ($namesLead.Count -eq 1 -and $namesLead[0] -eq "Rahul Sharma")
Record-TestResult -TestId "T2.2.1" -Tier "Tier 2" -Category "Whitespace" -Description "Leading whitespace '   Rahul' matches Rahul Sharma" -Passed $pass2_2_1 -Details "Found: $($namesLead -join ', ')"

# T2.2.2: Trailing whitespace "Rahul   "
$rTrailWhite = Send-WebFormsPost -Url $targetUrl -Session $s2_2 -PreviousHtml $rLeadWhite.Content -FieldValues @{
    "btnSearch" = "Search"; "txtFirstName" = "Rahul   "
}
$namesTrail = Get-CardNames -Html $rTrailWhite.Content
$pass2_2_2 = ($namesTrail.Count -eq 1 -and $namesTrail[0] -eq "Rahul Sharma")
Record-TestResult -TestId "T2.2.2" -Tier "Tier 2" -Category "Whitespace" -Description "Trailing whitespace 'Rahul   ' matches Rahul Sharma" -Passed $pass2_2_2 -Details "Found: $($namesTrail -join ', ')"

# T2.2.3: Surrounding whitespace "   Rahul   "
$rSurrWhite = Send-WebFormsPost -Url $targetUrl -Session $s2_2 -PreviousHtml $rTrailWhite.Content -FieldValues @{
    "btnSearch" = "Search"; "txtFirstName" = "   Rahul   "
}
$namesSurr = Get-CardNames -Html $rSurrWhite.Content
$pass2_2_3 = ($namesSurr.Count -eq 1 -and $namesSurr[0] -eq "Rahul Sharma")
Record-TestResult -TestId "T2.2.3" -Tier "Tier 2" -Category "Whitespace" -Description "Surrounding whitespace '   Rahul   ' matches Rahul Sharma" -Passed $pass2_2_3 -Details "Found: $($namesSurr -join ', ')"

# T2.2.4: Full name with internal space "Rahul Sharma"
$rFullSpace = Send-WebFormsPost -Url $targetUrl -Session $s2_2 -PreviousHtml $rSurrWhite.Content -FieldValues @{
    "btnSearch" = "Search"; "txtFirstName" = "Rahul Sharma"
}
$namesFull = Get-CardNames -Html $rFullSpace.Content
$pass2_2_4 = ($namesFull.Count -eq 1 -and $namesFull[0] -eq "Rahul Sharma")
Record-TestResult -TestId "T2.2.4" -Tier "Tier 2" -Category "Whitespace" -Description "Search with internal space 'Rahul Sharma' matches correctly" -Passed $pass2_2_4 -Details "Found: $($namesFull -join ', ')"

# T2.2.5: Whitespace-only string "     "
$rWhiteOnly = Send-WebFormsPost -Url $targetUrl -Session $s2_2 -PreviousHtml $rFullSpace.Content -FieldValues @{
    "btnSearch" = "Search"; "txtFirstName" = "     "
}
$countWhiteOnly = Get-CardCount -Html $rWhiteOnly.Content
Record-TestResult -TestId "T2.2.5" -Tier "Tier 2" -Category "Whitespace" -Description "Whitespace-only input trims to empty and returns all 5 candidates" -Passed ($countWhiteOnly -eq 5) -Details "Count: $countWhiteOnly"

# Area 2.3: Special Characters & Injection Resilience (5 tests)
$s2_3 = New-FreshSession
$rInit2_3 = Invoke-WebRequest -Uri $targetUrl -WebSession $s2_3 -UseBasicParsing

# T2.3.1: Single quote search "O'Connor"
$rQuote = Send-WebFormsPost -Url $targetUrl -Session $s2_3 -PreviousHtml $rInit2_3.Content -FieldValues @{
    "btnSearch" = "Search"; "txtFirstName" = "O'Connor"
}
$pass2_3_1 = ($rQuote.StatusCode -eq 200 -and (Get-CardCount -Html $rQuote.Content) -eq 0)
Record-TestResult -TestId "T2.3.1" -Tier "Tier 2" -Category "Special Characters" -Description "Single quote in search returns HTTP 200 with 0 cards without SQL syntax crash" -Passed $pass2_3_1

# T2.3.2: SQL Wildcard Character "%"
$rPercent = Send-WebFormsPost -Url $targetUrl -Session $s2_3 -PreviousHtml $rQuote.Content -FieldValues @{
    "btnSearch" = "Search"; "txtFirstName" = "%"
}
$pass2_3_2 = ($rPercent.StatusCode -eq 200 -and (Get-CardCount -Html $rPercent.Content) -eq 5)
Record-TestResult -TestId "T2.3.2" -Tier "Tier 2" -Category "Special Characters" -Description "Wildcard character '%' is handled safely via SQL parameterization" -Passed $pass2_3_2

# T2.3.3: SQL Injection Payload "' OR '1'='1"
$rSqlInj = Send-WebFormsPost -Url $targetUrl -Session $s2_3 -PreviousHtml $rPercent.Content -FieldValues @{
    "btnSearch" = "Search"; "txtFirstName" = "' OR '1'='1"
}
$pass2_3_3 = ($rSqlInj.StatusCode -eq 200 -and (Get-CardCount -Html $rSqlInj.Content) -eq 0)
Record-TestResult -TestId "T2.3.3" -Tier "Tier 2" -Category "Special Characters" -Description "SQL injection attempt is neutralised by parameterization returning 0 cards" -Passed $pass2_3_3

# T2.3.4: Special Symbol "C# / .NET"
$rSym = Send-WebFormsPost -Url $targetUrl -Session $s2_3 -PreviousHtml $rSqlInj.Content -FieldValues @{
    "btnSearch" = "Search"; "txtFirstName" = "C# / .NET"
}
$pass2_3_4 = ($rSym.StatusCode -eq 200 -and (Get-CardCount -Html $rSym.Content) -eq 0)
Record-TestResult -TestId "T2.3.4" -Tier "Tier 2" -Category "Special Characters" -Description "Punctuation/symbol string returns HTTP 200 with 0 cards" -Passed $pass2_3_4

# T2.3.5: XSS Script Injection Trapped by RequestValidation
$rXss = Send-WebFormsPost -Url $targetUrl -Session $s2_3 -PreviousHtml $rSym.Content -FieldValues @{
    "btnSearch" = "Search"; "txtFirstName" = "<script>alert(1)</script>"
}
$pass2_3_5 = ($rXss.StatusCode -eq 500 -or $rXss.StatusCode -eq [System.Net.HttpStatusCode]::InternalServerError)
Record-TestResult -TestId "T2.3.5" -Tier "Tier 2" -Category "Special Characters" -Description "XSS script payload is intercepted by ASP.NET RequestValidation (HTTP 500)" -Passed $pass2_3_5

# Area 2.4: Zero Match Handling (5 tests)
$s2_4 = New-FreshSession
$rInit2_4 = Invoke-WebRequest -Uri $targetUrl -WebSession $s2_4 -UseBasicParsing

# T2.4.1: Non-Existent Name
$rZero1 = Send-WebFormsPost -Url $targetUrl -Session $s2_4 -PreviousHtml $rInit2_4.Content -FieldValues @{
    "btnSearch" = "Search"; "txtFirstName" = "NonExistentCandidate999"
}
$pass2_4_1 = ($rZero1.StatusCode -eq 200 -and (Get-CardCount -Html $rZero1.Content) -eq 0)
Record-TestResult -TestId "T2.4.1" -Tier "Tier 2" -Category "Zero Match" -Description "Non-existent candidate returns 0 cards with HTTP 200 OK" -Passed $pass2_4_1

# T2.4.2: Non-Existent Name with Male Filter
$rZero2 = Send-WebFormsPost -Url $targetUrl -Session $s2_4 -PreviousHtml $rZero1.Content -FieldValues @{
    "btnSearch" = "Search"; "txtFirstName" = "NonExistentCandidate999"; "DropDownList1" = "Male"
}
$pass2_4_2 = ($rZero2.StatusCode -eq 200 -and (Get-CardCount -Html $rZero2.Content) -eq 0)
Record-TestResult -TestId "T2.4.2" -Tier "Tier 2" -Category "Zero Match" -Description "Non-existent candidate with Male filter returns 0 cards" -Passed $pass2_4_2

# T2.4.3: Non-Existent Name with Female Filter
$rZero3 = Send-WebFormsPost -Url $targetUrl -Session $s2_4 -PreviousHtml $rZero2.Content -FieldValues @{
    "btnSearch" = "Search"; "txtFirstName" = "NonExistentCandidate999"; "DropDownList1" = "Female"
}
$pass2_4_3 = ($rZero3.StatusCode -eq 200 -and (Get-CardCount -Html $rZero3.Content) -eq 0)
Record-TestResult -TestId "T2.4.3" -Tier "Tier 2" -Category "Zero Match" -Description "Non-existent candidate with Female filter returns 0 cards" -Passed $pass2_4_3

# T2.4.4: Conflicting Criteria (Rahul + Female)
$rZero4 = Send-WebFormsPost -Url $targetUrl -Session $s2_4 -PreviousHtml $rZero3.Content -FieldValues @{
    "btnSearch" = "Search"; "txtFirstName" = "Rahul"; "DropDownList1" = "Female"
}
$pass2_4_4 = ($rZero4.StatusCode -eq 200 -and (Get-CardCount -Html $rZero4.Content) -eq 0)
Record-TestResult -TestId "T2.4.4" -Tier "Tier 2" -Category "Zero Match" -Description "Conflicting criteria (Rahul + Female filter) gracefully displays 0 cards" -Passed $pass2_4_4

# T2.4.5: Reset after Zero Match restores full list
$rZero5 = Send-WebFormsPost -Url $targetUrl -Session $s2_4 -PreviousHtml $rZero4.Content -FieldValues @{
    "btnReset" = "Reset Filters"
}
$pass2_4_5 = ($rZero5.StatusCode -eq 200 -and (Get-CardCount -Html $rZero5.Content) -eq 5)
Record-TestResult -TestId "T2.4.5" -Tier "Tier 2" -Category "Zero Match" -Description "Reset from zero-match state recovers all 5 candidate profiles" -Passed $pass2_4_5

# Area 2.5: Case Insensitivity (5 tests)
$s2_5 = New-FreshSession
$rInit2_5 = Invoke-WebRequest -Uri $targetUrl -WebSession $s2_5 -UseBasicParsing

# T2.5.1: Lowercase "rahul"
$rCase1 = Send-WebFormsPost -Url $targetUrl -Session $s2_5 -PreviousHtml $rInit2_5.Content -FieldValues @{
    "btnSearch" = "Search"; "txtFirstName" = "rahul"
}
$namesCase1 = Get-CardNames -Html $rCase1.Content
$pass2_5_1 = ($namesCase1.Count -eq 1 -and $namesCase1[0] -eq "Rahul Sharma")
Record-TestResult -TestId "T2.5.1" -Tier "Tier 2" -Category "Case Insensitivity" -Description "All lowercase 'rahul' resolves to Rahul Sharma" -Passed $pass2_5_1

# T2.5.2: Uppercase "RAHUL"
$rCase2 = Send-WebFormsPost -Url $targetUrl -Session $s2_5 -PreviousHtml $rCase1.Content -FieldValues @{
    "btnSearch" = "Search"; "txtFirstName" = "RAHUL"
}
$namesCase2 = Get-CardNames -Html $rCase2.Content
$pass2_5_2 = ($namesCase2.Count -eq 1 -and $namesCase2[0] -eq "Rahul Sharma")
Record-TestResult -TestId "T2.5.2" -Tier "Tier 2" -Category "Case Insensitivity" -Description "All uppercase 'RAHUL' resolves to Rahul Sharma" -Passed $pass2_5_2

# T2.5.3: Mixed inverted case "rAhUl"
$rCase3 = Send-WebFormsPost -Url $targetUrl -Session $s2_5 -PreviousHtml $rCase2.Content -FieldValues @{
    "btnSearch" = "Search"; "txtFirstName" = "rAhUl"
}
$namesCase3 = Get-CardNames -Html $rCase3.Content
$pass2_5_3 = ($namesCase3.Count -eq 1 -and $namesCase3[0] -eq "Rahul Sharma")
Record-TestResult -TestId "T2.5.3" -Tier "Tier 2" -Category "Case Insensitivity" -Description "Mixed inverted case 'rAhUl' resolves to Rahul Sharma" -Passed $pass2_5_3

# T2.5.4: Lowercase female "priya"
$rCase4 = Send-WebFormsPost -Url $targetUrl -Session $s2_5 -PreviousHtml $rCase3.Content -FieldValues @{
    "btnSearch" = "Search"; "txtFirstName" = "priya"
}
$namesCase4 = Get-CardNames -Html $rCase4.Content
$pass2_5_4 = ($namesCase4.Count -eq 1 -and $namesCase4[0] -eq "Priya Mukherjee")
Record-TestResult -TestId "T2.5.4" -Tier "Tier 2" -Category "Case Insensitivity" -Description "All lowercase 'priya' resolves to Priya Mukherjee" -Passed $pass2_5_4

# T2.5.5: Uppercase female "PRIYA"
$rCase5 = Send-WebFormsPost -Url $targetUrl -Session $s2_5 -PreviousHtml $rCase4.Content -FieldValues @{
    "btnSearch" = "Search"; "txtFirstName" = "PRIYA"
}
$namesCase5 = Get-CardNames -Html $rCase5.Content
$pass2_5_5 = ($namesCase5.Count -eq 1 -and $namesCase5[0] -eq "Priya Mukherjee")
Record-TestResult -TestId "T2.5.5" -Tier "Tier 2" -Category "Case Insensitivity" -Description "All uppercase 'PRIYA' resolves to Priya Mukherjee" -Passed $pass2_5_5

Write-Host ""

# -----------------------------------------------------------------
# TIER 3: CROSS-FEATURE COMBINATIONS (10 Pairwise Tests)
# -----------------------------------------------------------------
Write-Host "--- TIER 3: CROSS-FEATURE COMBINATIONS ---"

$s3_comb = New-FreshSession
$rInit3 = Invoke-WebRequest -Uri $targetUrl -WebSession $s3_comb -UseBasicParsing

# T3.1: Search "Rahul" + Filter "Male"
$rPair1 = Send-WebFormsPost -Url $targetUrl -Session $s3_comb -PreviousHtml $rInit3.Content -FieldValues @{
    "btnSearch" = "Search"; "txtFirstName" = "Rahul"
}
$rPair1b = Send-WebFormsPost -Url $targetUrl -Session $s3_comb -PreviousHtml $rPair1.Content -FieldValues @{
    "btnFilterGender" = "Filter"; "DropDownList1" = "Male"
}
$namesP1 = Get-CardNames -Html $rPair1b.Content
$pass3_1 = ($namesP1.Count -eq 1 -and $namesP1[0] -eq "Rahul Sharma")
Record-TestResult -TestId "T3.1" -Tier "Tier 3" -Category "Pairwise Combination" -Description "Search 'Rahul' + Filter 'Male' yields exactly Rahul Sharma" -Passed $pass3_1

# T3.2: Search "Rahul" + Filter "Female" (Conflict)
$rPair2 = Send-WebFormsPost -Url $targetUrl -Session $s3_comb -PreviousHtml $rPair1b.Content -FieldValues @{
    "btnFilterGender" = "Filter"; "DropDownList1" = "Female"
}
$countP2 = Get-CardCount -Html $rPair2.Content
$pass3_2 = ($countP2 -eq 0)
Record-TestResult -TestId "T3.2" -Tier "Tier 3" -Category "Pairwise Combination" -Description "Search 'Rahul' + Filter 'Female' yields 0 candidates" -Passed $pass3_2

# T3.3: Reset + Search "Priya" + Filter "Female"
$rPair3Reset = Send-WebFormsPost -Url $targetUrl -Session $s3_comb -PreviousHtml $rPair2.Content -FieldValues @{ "btnReset" = "Reset Filters" }
$rPair3a = Send-WebFormsPost -Url $targetUrl -Session $s3_comb -PreviousHtml $rPair3Reset.Content -FieldValues @{ "btnSearch" = "Search"; "txtFirstName" = "Priya" }
$rPair3b = Send-WebFormsPost -Url $targetUrl -Session $s3_comb -PreviousHtml $rPair3a.Content -FieldValues @{ "btnFilterGender" = "Filter"; "DropDownList1" = "Female" }
$namesP3 = Get-CardNames -Html $rPair3b.Content
$pass3_3 = ($namesP3.Count -eq 1 -and $namesP3[0] -eq "Priya Mukherjee")
Record-TestResult -TestId "T3.3" -Tier "Tier 3" -Category "Pairwise Combination" -Description "Search 'Priya' + Filter 'Female' yields exactly Priya Mukherjee" -Passed $pass3_3

# T3.4: Search "Priya" + Filter "Male" (Conflict)
$rPair4 = Send-WebFormsPost -Url $targetUrl -Session $s3_comb -PreviousHtml $rPair3b.Content -FieldValues @{ "btnFilterGender" = "Filter"; "DropDownList1" = "Male" }
$countP4 = Get-CardCount -Html $rPair4.Content
$pass3_4 = ($countP4 -eq 0)
Record-TestResult -TestId "T3.4" -Tier "Tier 3" -Category "Pairwise Combination" -Description "Search 'Priya' + Filter 'Male' yields 0 candidates" -Passed $pass3_4

# T3.5: Filter "Male" + Switch View Mode to "Resume"
$rPair5Reset = Send-WebFormsPost -Url $targetUrl -Session $s3_comb -PreviousHtml $rPair4.Content -FieldValues @{ "btnReset" = "Reset Filters" }
$rPair5a = Send-WebFormsPost -Url $targetUrl -Session $s3_comb -PreviousHtml $rPair5Reset.Content -FieldValues @{ "btnFilterGender" = "Filter"; "DropDownList1" = "Male" }
$rPair5b = Send-WebFormsPost -Url $targetUrl -Session $s3_comb -PreviousHtml $rPair5a.Content -FieldValues @{ "ddlViewMode" = "Resume"; "__EVENTTARGET" = "ddlViewMode" }
$pass3_5 = ($rPair5b.Content.Contains("ddlCandidate") -and $rPair5b.Content -match "Resume")
Record-TestResult -TestId "T3.5" -Tier "Tier 3" -Category "Pairwise Combination" -Description "Filter 'Male' + Switch to Resume view displays candidate selector" -Passed $pass3_5

# T3.6: Filter "Female" + Switch View Mode to "Resume"
$rPair6Reset = Send-WebFormsPost -Url $targetUrl -Session $s3_comb -PreviousHtml $rPair5b.Content -FieldValues @{ "btnReset" = "Reset Filters" }
$rPair6a = Send-WebFormsPost -Url $targetUrl -Session $s3_comb -PreviousHtml $rPair6Reset.Content -FieldValues @{ "btnFilterGender" = "Filter"; "DropDownList1" = "Female" }
$rPair6b = Send-WebFormsPost -Url $targetUrl -Session $s3_comb -PreviousHtml $rPair6a.Content -FieldValues @{ "ddlViewMode" = "Resume"; "__EVENTTARGET" = "ddlViewMode" }
$pass3_6 = ($rPair6b.Content.Contains("ddlCandidate") -and $rPair6b.Content -match "Resume")
Record-TestResult -TestId "T3.6" -Tier "Tier 3" -Category "Pairwise Combination" -Description "Filter 'Female' + Switch to Resume view displays candidate selector" -Passed $pass3_6

# T3.7: Filter "Male" + PDF Export
$rPair7Reset = Send-WebFormsPost -Url $targetUrl -Session $s3_comb -PreviousHtml $rPair6b.Content -FieldValues @{ "btnReset" = "Reset Filters" }
$rPair7a = Send-WebFormsPost -Url $targetUrl -Session $s3_comb -PreviousHtml $rPair7Reset.Content -FieldValues @{ "btnFilterGender" = "Filter"; "DropDownList1" = "Male" }
$rPair7b = Send-WebFormsPost -Url $targetUrl -Session $s3_comb -PreviousHtml $rPair7a.Content -FieldValues @{ "btnPDF" = "Convert To PDF"; "DropDownList1" = "Male" }
$pass3_7 = ($rPair7b.StatusCode -eq 200 -and (Test-IsPdfBytes -Content $rPair7b.Content))
Record-TestResult -TestId "T3.7" -Tier "Tier 3" -Category "Pairwise Combination" -Description "Filter 'Male' + PDF Export returns valid PDF stream" -Passed $pass3_7

# T3.8: Filter "Female" + PDF Export
$rPair8Reset = Send-WebFormsPost -Url $targetUrl -Session $s3_comb -PreviousHtml $rPair7a.Content -FieldValues @{ "btnReset" = "Reset Filters" }
$rPair8a = Send-WebFormsPost -Url $targetUrl -Session $s3_comb -PreviousHtml $rPair8Reset.Content -FieldValues @{ "btnFilterGender" = "Filter"; "DropDownList1" = "Female" }
$rPair8b = Send-WebFormsPost -Url $targetUrl -Session $s3_comb -PreviousHtml $rPair8a.Content -FieldValues @{ "btnPDF" = "Convert To PDF"; "DropDownList1" = "Female" }
$pass3_8 = ($rPair8b.StatusCode -eq 200 -and (Test-IsPdfBytes -Content $rPair8b.Content))
Record-TestResult -TestId "T3.8" -Tier "Tier 3" -Category "Pairwise Combination" -Description "Filter 'Female' + PDF Export returns valid PDF stream" -Passed $pass3_8

# T3.9: Search "Amit" + PDF Export
$rPair9Reset = Send-WebFormsPost -Url $targetUrl -Session $s3_comb -PreviousHtml $rPair8a.Content -FieldValues @{ "btnReset" = "Reset Filters" }
$rPair9a = Send-WebFormsPost -Url $targetUrl -Session $s3_comb -PreviousHtml $rPair9Reset.Content -FieldValues @{ "btnSearch" = "Search"; "txtFirstName" = "Amit" }
$rPair9b = Send-WebFormsPost -Url $targetUrl -Session $s3_comb -PreviousHtml $rPair9a.Content -FieldValues @{ "btnPDF" = "Convert To PDF"; "txtFirstName" = "Amit" }
$pass3_9 = ($rPair9b.StatusCode -eq 200 -and (Test-IsPdfBytes -Content $rPair9b.Content))
Record-TestResult -TestId "T3.9" -Tier "Tier 3" -Category "Pairwise Combination" -Description "Search 'Amit' + PDF Export returns valid PDF stream" -Passed $pass3_9

# T3.10: Resume View Mode + Candidate 3 + PDF Export
$rPair10Reset = Send-WebFormsPost -Url $targetUrl -Session $s3_comb -PreviousHtml $rPair9a.Content -FieldValues @{ "btnReset" = "Reset Filters" }
$rPair10a = Send-WebFormsPost -Url $targetUrl -Session $s3_comb -PreviousHtml $rPair10Reset.Content -FieldValues @{ "ddlViewMode" = "Resume"; "__EVENTTARGET" = "ddlViewMode" }
$rPair10b = Send-WebFormsPost -Url $targetUrl -Session $s3_comb -PreviousHtml $rPair10a.Content -FieldValues @{ "ddlViewMode" = "Resume"; "ddlCandidate" = "3"; "__EVENTTARGET" = "ddlCandidate" }
$rPair10c = Send-WebFormsPost -Url $targetUrl -Session $s3_comb -PreviousHtml $rPair10b.Content -FieldValues @{ "btnPDF" = "Convert To PDF"; "ddlViewMode" = "Resume"; "ddlCandidate" = "3" }
$disposition3_10 = $rPair10c.Headers["Content-Disposition"]
$pass3_10 = ($rPair10c.StatusCode -eq 200 -and $disposition3_10 -match "CandidateResume\.pdf" -and (Test-IsPdfBytes -Content $rPair10c.Content))
Record-TestResult -TestId "T3.10" -Tier "Tier 3" -Category "Pairwise Combination" -Description "Resume Mode + Candidate 3 + PDF Export generates CandidateResume.pdf" -Passed $pass3_10 -Details "Disposition: $disposition3_10"

Write-Host ""

# -----------------------------------------------------------------
# TIER 4: REAL-WORLD APPLICATION SCENARIOS (5 Workflows, 24 Sub-Checks)
# -----------------------------------------------------------------
Write-Host "--- TIER 4: REAL-WORLD APPLICATION SCENARIOS ---"

# Scenario 4.1: Recruiter Candidate Sourcing Workflow (Rahul Sharma)
$s4_1 = New-FreshSession
$rw1_init = Invoke-WebRequest -Uri $targetUrl -WebSession $s4_1 -UseBasicParsing
Record-TestResult -TestId "T4.1.1" -Tier "Tier 4" -Category "Workflow: Recruiter Sourcing" -Description "Step 1: Recruiter lands on candidate directory" -Passed ($rw1_init.StatusCode -eq 200)

$rw1_search = Send-WebFormsPost -Url $targetUrl -Session $s4_1 -PreviousHtml $rw1_init.Content -FieldValues @{ "btnSearch" = "Search"; "txtFirstName" = "Rahul" }
$rw1_names = Get-CardNames -Html $rw1_search.Content
$pass4_1_2 = ($rw1_names.Count -eq 1 -and $rw1_names[0] -eq "Rahul Sharma")
Record-TestResult -TestId "T4.1.2" -Tier "Tier 4" -Category "Workflow: Recruiter Sourcing" -Description "Step 2: Recruiter searches for candidate Rahul Sharma" -Passed $pass4_1_2

$pass4_1_3 = ($rw1_search.Content -match "Senior \.NET Developer" -and $rw1_search.Content -match "Kolkata")
Record-TestResult -TestId "T4.1.3" -Tier "Tier 4" -Category "Workflow: Recruiter Sourcing" -Description "Step 3: Verifies candidate role (Senior .NET Developer) and location (Kolkata)" -Passed $pass4_1_3

$imgMatch4_1 = [regex]::Match($rw1_search.Content, 'CrystalImageHandler\.aspx\?dynamicimage=[^"''\s<>]+')
$pass4_1_4 = $false
if ($imgMatch4_1.Success) {
    $imgRes4_1 = Invoke-WebRequest -Uri "$BaseUrl/$($imgMatch4_1.Value)" -WebSession $s4_1 -UseBasicParsing
    $pass4_1_4 = ($imgRes4_1.StatusCode -eq 200 -and (Test-IsPngBytes -Content $imgRes4_1.Content))
}
Record-TestResult -TestId "T4.1.4" -Tier "Tier 4" -Category "Workflow: Recruiter Sourcing" -Description "Step 4: Verifies live dynamic profile photo served via CrystalImageHandler" -Passed $pass4_1_4

$resumeRes4_1 = Invoke-WebRequest -Uri "$BaseUrl/Resumes/rahul_sharma_resume.pdf" -UseBasicParsing
$pass4_1_5 = ($resumeRes4_1.StatusCode -eq 200 -and (Test-IsPdfBytes -Content $resumeRes4_1.Content))
Record-TestResult -TestId "T4.1.5" -Tier "Tier 4" -Category "Workflow: Recruiter Sourcing" -Description "Step 5: Downloads and validates Rahul Sharma's PDF resume" -Passed $pass4_1_5

# Scenario 4.2: HR Diversity & Inclusion Screening Workflow
$s4_2 = New-FreshSession
$rw2_init = Invoke-WebRequest -Uri $targetUrl -WebSession $s4_2 -UseBasicParsing
$rw2_female = Send-WebFormsPost -Url $targetUrl -Session $s4_2 -PreviousHtml $rw2_init.Content -FieldValues @{ "btnFilterGender" = "Filter"; "DropDownList1" = "Female" }
$rw2_cards = Get-CardCount -Html $rw2_female.Content
$rw2_names = Get-CardNames -Html $rw2_female.Content
$pass4_2_1 = ($rw2_cards -eq 2 -and $rw2_names -contains "Priya Mukherjee" -and $rw2_names -contains "Sneha Patel")
Record-TestResult -TestId "T4.2.1" -Tier "Tier 4" -Category "Workflow: HR Diversity" -Description "Step 1: HR manager filters female candidates (Priya & Sneha)" -Passed $pass4_2_1 -Details "Found: $($rw2_names -join ', ')"

$rw2_resumeMode = Send-WebFormsPost -Url $targetUrl -Session $s4_2 -PreviousHtml $rw2_female.Content -FieldValues @{ "ddlViewMode" = "Resume"; "__EVENTTARGET" = "ddlViewMode" }
$pass4_2_2 = ($rw2_resumeMode.Content.Contains("ddlCandidate"))
Record-TestResult -TestId "T4.2.2" -Tier "Tier 4" -Category "Workflow: HR Diversity" -Description "Step 2: Switches to Resume mode for individual dossier inspection" -Passed $pass4_2_2

$rw2_header = [regex]::Match($rw2_resumeMode.Content, 'id="lblReportTitle"[^>]*>([^<]+)<')
$pass4_2_3 = ($rw2_header.Success -and $rw2_header.Groups[1].Value -match "Resume")
Record-TestResult -TestId "T4.2.3" -Tier "Tier 4" -Category "Workflow: HR Diversity" -Description "Step 3: Confirms report header reflects individual biodata & resume" -Passed $pass4_2_3

$rw2_selectPriya = Send-WebFormsPost -Url $targetUrl -Session $s4_2 -PreviousHtml $rw2_resumeMode.Content -FieldValues @{ "ddlViewMode" = "Resume"; "ddlCandidate" = "2"; "__EVENTTARGET" = "ddlCandidate" }
$rw2_priyaCard = Get-CardNames -Html $rw2_selectPriya.Content
$pass4_2_4 = ($rw2_priyaCard.Count -eq 1 -and $rw2_priyaCard[0] -eq "Priya Mukherjee")
Record-TestResult -TestId "T4.2.4" -Tier "Tier 4" -Category "Workflow: HR Diversity" -Description "Step 4: Inspects candidate Priya Mukherjee profile dossier" -Passed $pass4_2_4

$rw2_backDir = Send-WebFormsPost -Url $targetUrl -Session $s4_2 -PreviousHtml $rw2_selectPriya.Content -FieldValues @{ "ddlViewMode" = "Directory"; "__EVENTTARGET" = "ddlViewMode" }
$pass4_2_5 = ((Get-CardCount -Html $rw2_backDir.Content) -eq 5)
Record-TestResult -TestId "T4.2.5" -Tier "Tier 4" -Category "Workflow: HR Diversity" -Description "Step 5: Returns to full Directory mode cleanly" -Passed $pass4_2_5

# Scenario 4.3: Hiring Committee Dossier PDF Export
$s4_3 = New-FreshSession
$rw3_init = Invoke-WebRequest -Uri $targetUrl -WebSession $s4_3 -UseBasicParsing
$rw3_male = Send-WebFormsPost -Url $targetUrl -Session $s4_3 -PreviousHtml $rw3_init.Content -FieldValues @{ "btnFilterGender" = "Filter"; "DropDownList1" = "Male" }
$rw3_searchVikram = Send-WebFormsPost -Url $targetUrl -Session $s4_3 -PreviousHtml $rw3_male.Content -FieldValues @{ "btnSearch" = "Search"; "txtFirstName" = "Vikram" }
$rw3_names = Get-CardNames -Html $rw3_searchVikram.Content
$pass4_3_1 = ($rw3_names.Count -eq 1 -and $rw3_names[0] -eq "Vikram Singh")
Record-TestResult -TestId "T4.3.1" -Tier "Tier 4" -Category "Workflow: Dossier Export" -Description "Step 1: Director searches for finalist Vikram Singh (Male)" -Passed $pass4_3_1

$pass4_3_2 = ($rw3_searchVikram.Content -match "Cloud Solutions Architect" -and $rw3_searchVikram.Content -match "Delhi")
Record-TestResult -TestId "T4.3.2" -Tier "Tier 4" -Category "Workflow: Dossier Export" -Description "Step 2: Verifies candidate details (Cloud Solutions Architect, Delhi)" -Passed $pass4_3_2

$rw3_pdf = Send-WebFormsPost -Url $targetUrl -Session $s4_3 -PreviousHtml $rw3_searchVikram.Content -FieldValues @{ "btnPDF" = "Convert To PDF" }
$pass4_3_3 = ($rw3_pdf.StatusCode -eq 200)
Record-TestResult -TestId "T4.3.3" -Tier "Tier 4" -Category "Workflow: Dossier Export" -Description "Step 3: Triggers PDF export for hiring committee dossier (HTTP 200)" -Passed $pass4_3_3

$pass4_3_4 = (Test-IsPdfBytes -Content $rw3_pdf.Content)
Record-TestResult -TestId "T4.3.4" -Tier "Tier 4" -Category "Workflow: Dossier Export" -Description "Step 4: Validates binary %PDF- integrity of generated dossier" -Passed $pass4_3_4

$pass4_3_5 = ($rw3_pdf.Headers["Content-Disposition"] -match "CandidateDirectory\.pdf")
Record-TestResult -TestId "T4.3.5" -Tier "Tier 4" -Category "Workflow: Dossier Export" -Description "Step 5: Verifies attachment filename header on exported dossier" -Passed $pass4_3_5

# Scenario 4.4: Candidate Screening Multi-Profile Inspection Workflow
$s4_4 = New-FreshSession
$rw4_init = Invoke-WebRequest -Uri $targetUrl -WebSession $s4_4 -UseBasicParsing
$rw4_resumeMode = Send-WebFormsPost -Url $targetUrl -Session $s4_4 -PreviousHtml $rw4_init.Content -FieldValues @{ "ddlViewMode" = "Resume"; "__EVENTTARGET" = "ddlViewMode" }

$expectedCandidates = @(
    @{ Id = "1"; Name = "Rahul Sharma" },
    @{ Id = "2"; Name = "Priya Mukherjee" },
    @{ Id = "3"; Name = "Amit Verma" },
    @{ Id = "4"; Name = "Sneha Patel" },
    @{ Id = "5"; Name = "Vikram Singh" }
)

$prevHtml4 = $rw4_resumeMode.Content
foreach ($ec in $expectedCandidates) {
    $rw4_step = Send-WebFormsPost -Url $targetUrl -Session $s4_4 -PreviousHtml $prevHtml4 -FieldValues @{
        "ddlViewMode" = "Resume"; "ddlCandidate" = $ec.Id; "__EVENTTARGET" = "ddlCandidate"
    }
    $cNames = Get-CardNames -Html $rw4_step.Content
    $pass4_4 = ($cNames.Count -eq 1 -and $cNames[0] -eq $ec.Name)
    Record-TestResult -TestId "T4.4.$($ec.Id)" -Tier "Tier 4" -Category "Workflow: Multi-Profile Inspection" -Description "Step $($ec.Id): Evaluator inspects Candidate $($ec.Id) ($($ec.Name))" -Passed $pass4_4 -Details "Found: $($cNames -join ', ')"
    $prevHtml4 = $rw4_step.Content
}

# Scenario 4.5: Rapid Multi-Filter Reset & Re-query Workflow
$s4_5 = New-FreshSession
$rw5_init = Invoke-WebRequest -Uri $targetUrl -WebSession $s4_5 -UseBasicParsing

# Step 1: Search Amit and Filter Male
$rw5_step1 = Send-WebFormsPost -Url $targetUrl -Session $s4_5 -PreviousHtml $rw5_init.Content -FieldValues @{ "btnSearch" = "Search"; "txtFirstName" = "Amit" }
$rw5_step1b = Send-WebFormsPost -Url $targetUrl -Session $s4_5 -PreviousHtml $rw5_step1.Content -FieldValues @{ "btnFilterGender" = "Filter"; "DropDownList1" = "Male" }
$names5_1 = Get-CardNames -Html $rw5_step1b.Content
$pass4_5_1 = ($names5_1.Count -eq 1 -and $names5_1[0] -eq "Amit Verma")
Record-TestResult -TestId "T4.5.1" -Tier "Tier 4" -Category "Workflow: Rapid Reset" -Description "Step 1: Rapid query for Amit (Male)" -Passed $pass4_5_1

# Step 2: Immediate Reset
$rw5_step2 = Send-WebFormsPost -Url $targetUrl -Session $s4_5 -PreviousHtml $rw5_step1b.Content -FieldValues @{ "btnReset" = "Reset Filters" }
$pass4_5_2 = ((Get-CardCount -Html $rw5_step2.Content) -eq 5)
Record-TestResult -TestId "T4.5.2" -Tier "Tier 4" -Category "Workflow: Rapid Reset" -Description "Step 2: Immediate reset restores 5 candidate roster" -Passed $pass4_5_2

# Step 3: Re-query Sneha and Filter Female
$rw5_step3 = Send-WebFormsPost -Url $targetUrl -Session $s4_5 -PreviousHtml $rw5_step2.Content -FieldValues @{ "btnSearch" = "Search"; "txtFirstName" = "Sneha" }
$rw5_step3b = Send-WebFormsPost -Url $targetUrl -Session $s4_5 -PreviousHtml $rw5_step3.Content -FieldValues @{ "btnFilterGender" = "Filter"; "DropDownList1" = "Female" }
$names5_3 = Get-CardNames -Html $rw5_step3b.Content
$pass4_5_3 = ($names5_3.Count -eq 1 -and $names5_3[0] -eq "Sneha Patel")
Record-TestResult -TestId "T4.5.3" -Tier "Tier 4" -Category "Workflow: Rapid Reset" -Description "Step 3: Rapid re-query for Sneha (Female)" -Passed $pass4_5_3

# Step 4: Final Reset verification
$rw5_step4 = Send-WebFormsPost -Url $targetUrl -Session $s4_5 -PreviousHtml $rw5_step3b.Content -FieldValues @{ "btnReset" = "Reset Filters" }
$pass4_5_4 = ((Get-CardCount -Html $rw5_step4.Content) -eq 5)
Record-TestResult -TestId "T4.5.4" -Tier "Tier 4" -Category "Workflow: Rapid Reset" -Description "Step 4: Final reset cleanly restores baseline state" -Passed $pass4_5_4

Write-Host ""
Write-Host "================================================================="
Write-Host "Test Suite Execution Summary"
Write-Host "End Time    : $(Get-Timestamp)"
Write-Host "Total Tests : $($script:TestResults.Count)"
Write-Host "Passed      : $($script:PassCount)"
Write-Host "Failed      : $($script:FailCount)"
$passRate = [math]::Round(($script:PassCount / $script:TestResults.Count) * 100, 2)
Write-Host "Pass Rate   : $passRate%"
Write-Host "================================================================="

if ($script:FailCount -gt 0) {
    Write-Host "TEST SUITE FAILED: $($script:FailCount) test(s) failed."
    exit 1
} else {
    Write-Host "TEST SUITE PASSED: All $($script:PassCount) tests succeeded (100% pass rate)."
    exit 0
}
