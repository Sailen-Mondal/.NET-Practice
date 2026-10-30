# Forensic Verification Script for Milestone 2
$ErrorActionPreference = "Stop"

$targetFiles = @(
    "D:\.NET\ViewModelDemo\Controllers\AccountController.cs",
    "D:\.NET\ViewModelDemo\Views\Account\Login.cshtml",
    "D:\.NET\ViewModelDemo\Views\Account\Register.cshtml",
    "D:\.NET\ViewModelDemo\Views\Admin\Dashboard.cshtml",
    "D:\.NET\ViewModelDemo\Views\Admin\Users.cshtml"
)

Write-Host "=== 1. SOURCE FILE EMOJI & NON-ASCII SCAN ==="
$emojiRegex = '[\uD83C-\uDBFF\uDC00-\uDFFF]|[\u2600-\u27BF]|[\u2300-\u23FF]|[\u2B50-\u2B55]|[\u203C\u2049\u2122\u2139\u2194-\u2199\u21A9-\u21AA\u2934-\u2935\u25AA-\u25AB\u25B6\u25C0\u25FB-\u25FE]'

foreach ($file in $targetFiles) {
    if (-not (Test-Path $file)) {
        Write-Error "File not found: $file"
    }
    $content = [System.IO.File]::ReadAllText($file, [System.Text.Encoding]::UTF8)
    $charCount = $content.Length
    $emojiMatches = [regex]::Matches($content, $emojiRegex)
    
    # Also find any character > 127
    $nonAscii = [System.Collections.Generic.List[object]]::new()
    for ($i = 0; $i -lt $content.Length; $i++) {
        $cp = [char]::ConvertToUtf32($content, $i)
        if ($cp -gt 127) {
            $charStr = [char]::ConvertFromUtf32($cp)
            $nonAscii.Add([PSCustomObject]@{
                Index = $i
                Char = $charStr
                CodePoint = ("U+{0:X4}" -f $cp)
            })
        }
        if ([char]::IsHighSurrogate($content[$i])) {
            $i++ # skip low surrogate in loop step
        }
    }

    Write-Host "File: $file"
    Write-Host "  Total Chars: $charCount"
    Write-Host "  Emoji Matches: $($emojiMatches.Count)"
    if ($emojiMatches.Count -gt 0) {
        foreach ($m in $emojiMatches) {
            Write-Host "    Found emoji: '$($m.Value)' at index $($m.Index)"
        }
    }
    Write-Host "  Non-ASCII Chars Count: $($nonAscii.Count)"
    if ($nonAscii.Count -gt 0) {
        $distinctCp = $nonAscii | Group-Object CodePoint
        foreach ($g in $distinctCp) {
            Write-Host "    CodePoint: $($g.Name) ('$($g.Group[0].Char)') Count: $($g.Count)"
        }
    }
}

Write-Host "`n=== 2. CODE INTEGRITY & ANTI-CHEATING PATTERNS ==="
foreach ($file in $targetFiles) {
    Write-Host "Checking $file..."
    $lines = [System.IO.File]::ReadAllLines($file)
    for ($i = 0; $i -lt $lines.Length; $i++) {
        $line = $lines[$i]
        # Look for hardcoded test results, fake bypasses
        if ($line -match '(?i)(bypass|mock|fake|stub|hardcode|shortcircuit|if\s*\(.*test.*\))') {
            Write-Host "  Line $($i+1): $line"
        }
    }
}

Write-Host "`n=== 3. ACCOUNT CONTROLLER LOGOUT AUDIT ==="
$accFile = "D:\.NET\ViewModelDemo\Controllers\AccountController.cs"
$accText = [System.IO.File]::ReadAllText($accFile)
if ($accText -match 'public ActionResult Logout\(\)[\s\S]*?\{([\s\S]*?)\}') {
    Write-Host "Logout Method Body:"
    Write-Host $matches[1]
    $hasSessionClear = $matches[1] -match 'Session\.Clear\(\)'
    $hasSessionAbandon = $matches[1] -match 'Session\.Abandon\(\)'
    $hasTempData = $matches[1] -match 'TempData\["InfoMessage"\]'
    Write-Host "  Session.Clear(): $hasSessionClear"
    Write-Host "  Session.Abandon(): $hasSessionAbandon"
    Write-Host "  TempData['InfoMessage']: $hasTempData"
}

Write-Host "`n=== 4. DYNAMIC VIEWMODEL BINDING AUDIT ==="
$views = @(
    "D:\.NET\ViewModelDemo\Views\Account\Login.cshtml",
    "D:\.NET\ViewModelDemo\Views\Account\Register.cshtml",
    "D:\.NET\ViewModelDemo\Views\Admin\Dashboard.cshtml",
    "D:\.NET\ViewModelDemo\Views\Admin\Users.cshtml"
)
foreach ($v in $views) {
    $vContent = [System.IO.File]::ReadAllText($v)
    $hasModelDecl = $vContent -match '@model\s+([^\r\n]+)'
    $modelType = if ($hasModelDecl) { $matches[1] } else { "NONE" }
    $dynamicRefs = [regex]::Matches($vContent, '@(Model\.[A-Za-z0-9_]+|Html\.[A-Za-z0-9_]+For\([^\)]+\))')
    Write-Host "View: $(Split-Path $v -Leaf)"
    Write-Host "  Model Declaration: $modelType"
    Write-Host "  Dynamic Model / Html Helper Bindings Count: $($dynamicRefs.Count)"
}
