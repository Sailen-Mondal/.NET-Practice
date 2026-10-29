$projectDir = 'D:\.NET\ViewModelDemo'
$pattern = '[\uD800-\uDBFF][\uDC00-\uDFFF]|[\u2600-\u27BF]|[\u2300-\u23FF]|[\u2B50]'
$extensions = @('*.cshtml', '*.css', '*.js')

$files = Get-ChildItem -Path $projectDir -Include $extensions -Recurse | Where-Object { $_.FullName -notmatch '\\(bin|obj|packages|\.git)\\' }

$found = 0
foreach ($file in $files) {
    $text = [System.IO.File]::ReadAllText($file.FullName)
    if ([System.Text.RegularExpressions.Regex]::IsMatch($text, $pattern)) {
        Write-Host "EMOJI FOUND in $($file.FullName)"
        $found++
    }
}

if ($found -eq 0) {
    Write-Host "ZERO EMOJIS CONFIRMED across all $($files.Count) project files."
} else {
    Write-Host "FAILED: $found files contain emojis."
}
