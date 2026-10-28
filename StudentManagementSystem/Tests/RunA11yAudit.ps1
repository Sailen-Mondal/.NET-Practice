# Accessibility (a11y) Automated Compliance Audit
# Verifies HTML semantics, landmarks, tables, headings, and labels across all endpoints

$urls = @(
    "http://localhost:12597/",
    "http://localhost:12597/Project",
    "http://localhost:12597/Project/Details/1",
    "http://localhost:12597/Project/Create",
    "http://localhost:12597/Project/Edit/1",
    "http://localhost:12597/Project/Delete/1",
    "http://localhost:12597/Student",
    "http://localhost:12597/Student/Details/2"
)

Write-Host "=========================================================="
Write-Host "STARTING ACCESSIBILITY (a11y) COMPLIANCE AUDIT"
Write-Host "=========================================================="

$totalChecks = 0
$passedChecks = 0
$issues = @()

foreach ($url in $urls) {
    $resp = Invoke-WebRequest -Uri $url -UseBasicParsing
    $html = $resp.Content
    $path = ([System.Uri]$url).PathAndQuery
    Write-Host "`nAuditing: $path" -ForegroundColor Cyan

    # 1. Lang attribute
    $totalChecks++
    if ($html -match '<html[^>]+lang="en"') {
        $passedChecks++
        Write-Host "  [PASS] HTML Lang attribute is defined ('en')" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] Missing or invalid lang attribute on <html>" -ForegroundColor Red
        $issues += "[$path] Missing lang attribute"
    }

    # 2. Page Title
    $totalChecks++
    if ($html -match '<title>([^<]+)</title>' -and $matches[1].Trim().Length -gt 0) {
        $passedChecks++
        Write-Host "  [PASS] Page Title: '$($matches[1].Trim())'" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] Empty or missing <title>" -ForegroundColor Red
        $issues += "[$path] Empty or missing title"
    }

    # 3. Viewport Meta tag
    $totalChecks++
    if ($html -match '<meta[^>]+name="viewport"') {
        $passedChecks++
        Write-Host "  [PASS] Responsive viewport meta tag present" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] Missing viewport meta tag" -ForegroundColor Red
        $issues += "[$path] Missing viewport meta tag"
    }

    # 4. Heading Hierarchy
    $totalChecks++
    $h1Count = ([regex]::Matches($html, '<h1[^>]*>')).Count
    if ($h1Count -eq 1) {
        $passedChecks++
        Write-Host "  [PASS] Exactly 1 <h1> landmark present" -ForegroundColor Green
    } elseif ($h1Count -eq 0) {
        Write-Host "  [WARN] No <h1> found on page" -ForegroundColor Yellow
    } else {
        Write-Host "  [INFO] $h1Count <h1> headings found" -ForegroundColor DarkGray
        $passedChecks++
    }

    # 5. Tables Accessibility (if table present)
    if ($html -match '<table[^>]*>') {
        $totalChecks++
        $hasAriaLabel = ($html -match '<table[^>]+aria-label=')
        $hasTh = ($html -match '<th[^>]*>')
        if ($hasAriaLabel -and $hasTh) {
            $passedChecks++
            Write-Host "  [PASS] Table has accessible labeling and <th> header cells" -ForegroundColor Green
        } else {
            Write-Host "  [WARN] Table missing aria-label or <th> header cells" -ForegroundColor Yellow
            $issues += "[$path] Incomplete table semantics"
        }
    }

    # 6. Form Inputs & Labels (if form present)
    if ($html -match '<form[^>]*>') {
        $totalChecks++
        $inputCount = ([regex]::Matches($html, '<input[^>]+type="(text|number|date)"[^>]*>')).Count
        $labelCount = ([regex]::Matches($html, '<label[^>]*>')).Count
        if ($labelCount -ge $inputCount) {
            $passedChecks++
            Write-Host "  [PASS] Form inputs have corresponding <label> elements ($labelCount labels for $inputCount inputs)" -ForegroundColor Green
        } else {
            Write-Host "  [WARN] Form inputs ($inputCount) exceed labels ($labelCount)" -ForegroundColor Yellow
            $issues += "[$path] Orphaned form inputs detected"
        }
    }
}

Write-Host "`n=========================================================="
Write-Host "ACCESSIBILITY AUDIT SUMMARY: Total: $totalChecks | Passed: $passedChecks | Issues: $($issues.Count)"
Write-Host "=========================================================="
