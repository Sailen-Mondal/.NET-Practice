$targetPaths = @(
    "C:\Users\sailenmondal\OneDrive - MANAGEMENT & COMPUTER CONSULTANTS\Documents\Visual Studio 2015\WebSites\WebSite2",
    "d:\.NET\.agents\teamwork"
)

# Regex matching Unicode Emoji ranges (Surrogate pairs, Miscellaneous Symbols, Dingbats, Emoticons, Transport, etc.)
$emojiPattern = '[\uD83C-\uDBFF\uDC00-\uDFFF\u2600-\u26FF\u2700-\u27BF]'

$totalViolations = 0

foreach ($p in $targetPaths) {
    Write-Host "Scanning path: $p"
    $files = Get-ChildItem -Path $p -Recurse -File -Include "*.aspx", "*.cs", "*.config", "*.md", "*.ps1", "*.xsd", "*.json"
    foreach ($f in $files) {
        $lines = Get-Content -Path $f.FullName -Encoding UTF8 -ErrorAction SilentlyContinue
        $lineNum = 0
        foreach ($line in $lines) {
            $lineNum++
            if ($line -match $emojiPattern) {
                # Ignore if matched within an audit script pattern definition itself
                if ($line -match 'emojiPattern' -or $line -match '[\\]uD83C') {
                    continue
                }
                Write-Host "EMOJI VIOLATION in $($f.FullName) at line $lineNum : $line"
                $totalViolations++
            }
        }
    }
}

Write-Host "`nTotal emoji violations found: $totalViolations"
