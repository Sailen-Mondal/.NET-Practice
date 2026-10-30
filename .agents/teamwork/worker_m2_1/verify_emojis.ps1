$emojiPattern = '[\uD83C-\uDBFF\uDC00-\uDFFF\u2600-\u27BF\u2300-\u23FF\u2B50-\u2B55\u203C\u2049\u2139\u2194-\u21AA]'
$files = @(
    "D:\.NET\ViewModelDemo\Controllers\AccountController.cs",
    "D:\.NET\ViewModelDemo\Views\Account\Login.cshtml",
    "D:\.NET\ViewModelDemo\Views\Account\Register.cshtml",
    "D:\.NET\ViewModelDemo\Views\Admin\Dashboard.cshtml",
    "D:\.NET\ViewModelDemo\Views\Admin\Users.cshtml"
)

$allClean = $true
foreach ($file in $files) {
    $content = [System.IO.File]::ReadAllText($file)
    if ([System.Text.RegularExpressions.Regex]::IsMatch($content, $emojiPattern)) {
        Write-Error "Emoji detected in $file"
        $allClean = $false
    } else {
        Write-Host "CLEAN (Zero Emojis): $file (Length: $($content.Length) chars)"
    }
}

if ($allClean) {
    Write-Host "SUCCESS: All 5 files are verified 100% emoji-free."
} else {
    exit 1
}
