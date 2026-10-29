# Forensic Check Script for Milestone 1 (auditor_m1_1)
$ErrorActionPreference = "Stop"

$files = @(
    "D:\.NET\ViewModelDemo\Content\site.css",
    "D:\.NET\ViewModelDemo\Scripts\app.js",
    "D:\.NET\ViewModelDemo\Views\Shared\_Layout.cshtml",
    "D:\.NET\ViewModelDemo\Views\Shared\_Navigation.cshtml"
)

Write-Host "============================================================"
Write-Host "FORENSIC CHECK: Character-by-Character Unicode & Emoji Audit"
Write-Host "============================================================"

# Comprehensive regex matching all known emoji / surrogate ranges
$emojiRegex = [regex]'[\uD800-\uDBFF][\uDC00-\uDFFF]|[\u2600-\u27BF]|[\u2B50\u2B55\u231A\u231B\u23E9-\u23EC\u23F0\u23F3\u25FD\u25FE\u2B1B\u2B1C]'
$violations = @()

foreach ($file in $files) {
    if (-not (Test-Path $file)) {
        Write-Host "ERROR: File not found: $file"
        $violations += "Missing file: $file"
        continue
    }

    $rawText = [System.IO.File]::ReadAllText($file, [System.Text.Encoding]::UTF8)
    $matches = $emojiRegex.Matches($rawText)
    
    Write-Host "File: $file"
    Write-Host "  Character count: $($rawText.Length)"
    Write-Host "  Emoji matches: $($matches.Count)"

    # Also check surrogate characters explicitly
    $surrogateCount = 0
    for ($i = 0; $i -lt $rawText.Length; $i++) {
        $c = $rawText[$i]
        if ([char]::IsSurrogate($c)) {
            $surrogateCount++
            $codePoint = [char]::ConvertToUtf32($rawText, $i)
            $violations += "Surrogate codepoint U+$([Convert]::ToString($codePoint, 16).ToUpper()) in $file at offset $i"
            $i++ # skip low surrogate
        }
    }
    Write-Host "  Surrogate count: $surrogateCount"

    if ($matches.Count -gt 0) {
        foreach ($m in $matches) {
            $violations += "Regex match in $file at index $($m.Index): '$($m.Value)'"
        }
    }
}

Write-Host ""
if ($violations.Count -eq 0) {
    Write-Host "VERDICT ZERO-EMOJI: CLEAN (0 violations found across all files)"
} else {
    Write-Host "VERDICT ZERO-EMOJI: VIOLATION ($($violations.Count) violations found)"
    foreach ($v in $violations) {
        Write-Host "  - $v"
    }
}
