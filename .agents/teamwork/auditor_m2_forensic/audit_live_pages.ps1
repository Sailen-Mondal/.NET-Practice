# Live HTML Inspection & Forensic Analysis using TestHarness
. "D:\.NET\ViewModelDemo\Tests\E2E\TestHarness.ps1"

$sess = New-E2ESession

# 1. Fetch /Account/Login
$loginPage = Invoke-E2EGet -Session $sess -Path "/Account/Login" -FollowRedirects $false
$loginHtml = $loginPage.Content

# 2. Fetch /Account/Register
$regPage = Invoke-E2EGet -Session $sess -Path "/Account/Register" -FollowRedirects $false
$regHtml = $regPage.Content

# 3. Log in as admin
$loginRes = Invoke-E2ELogin -Session $sess -UsernameOrEmail "admin" -Password "Admin@123"

# 4. Fetch /Admin/Dashboard
$dashPage = Invoke-E2EGet -Session $sess -Path "/Admin/Dashboard" -FollowRedirects $false
$dashHtml = $dashPage.Content

# 5. Fetch /Admin/Users
$usersPage = Invoke-E2EGet -Session $sess -Path "/Admin/Users" -FollowRedirects $false
$usersHtml = $usersPage.Content

$pages = @(
    @{ Name = "Account/Login"; Html = $loginHtml },
    @{ Name = "Account/Register"; Html = $regHtml },
    @{ Name = "Admin/Dashboard"; Html = $dashHtml },
    @{ Name = "Admin/Users"; Html = $usersHtml }
)

$emojiRegex = '[\uD83C-\uDBFF\uDC00-\uDFFF]|[\u2600-\u27BF]|[\u2300-\u23FF]|[\u2B50-\u2B55]|[\u203C\u2049\u2122\u2139\u2194-\u2199\u21A9-\u21AA\u2934-\u2935\u25AA-\u25AB\u25B6\u25C0\u25FB-\u25FE]'

Write-Host "=== LIVE HTML FORENSIC REPORT ==="
foreach ($p in $pages) {
    Write-Host "`n--- Page: $($p.Name) ---"
    $html = $p.Html
    Write-Host "Length: $($html.Length) chars"
    
    # Emoji Check
    $matches = [regex]::Matches($html, $emojiRegex)
    Write-Host "Emoji Matches: $($matches.Count)"
    if ($matches.Count -gt 0) {
        foreach ($m in $matches) {
            Write-Host "  EMOJI DETECTED: '$($m.Value)' at index $($m.Index)"
        }
    }
    
    # Non-ASCII scan
    $nonAscii = [System.Collections.Generic.List[object]]::new()
    for ($i = 0; $i -lt $html.Length; $i++) {
        $cp = [char]::ConvertToUtf32($html, $i)
        if ($cp -gt 127) {
            $charStr = [char]::ConvertFromUtf32($cp)
            $nonAscii.Add([PSCustomObject]@{
                Index = $i
                Char = $charStr
                CodePoint = ("U+{0:X4}" -f $cp)
            })
        }
        if ([char]::IsHighSurrogate($html[$i])) {
            $i++
        }
    }
    Write-Host "Non-ASCII Chars Count: $($nonAscii.Count)"
    if ($nonAscii.Count -gt 0) {
        $distinctCp = $nonAscii | Group-Object CodePoint
        foreach ($g in $distinctCp) {
            Write-Host "  CodePoint: $($g.Name) ('$($g.Group[0].Char)') Count: $($g.Count)"
        }
    }
    
    # Check for Indian Context
    $indianMatches = [regex]::Matches($html, '(?i)(rahul|priya|sneha|amit|sharma|patel|roy|verma|bengaluru|kolkata|delhi|mumbai|pune|Rs\.)')
    Write-Host "Indian Context Tokens Found: $($indianMatches.Count)"
    $foundTokens = ($indianMatches | ForEach-Object { $_.Value.ToLower() }) | Select-Object -Unique
    Write-Host "Distinct Tokens: $($foundTokens -join ', ')"
    
    # Check Notion Design Markers
    $hasNotionClass = $html -match 'notion-(card|form|table|btn|breadcrumb|alerts)'
    $hasCleanTypography = $html -match 'var\(--font-sans\)|-apple-system|Segoe UI'
    $hasSvg = $html -match '<svg'
    Write-Host "Notion CSS Classes: $hasNotionClass"
    Write-Host "Clean Typography: $hasCleanTypography"
    Write-Host "Inline SVGs used: $hasSvg"
}
