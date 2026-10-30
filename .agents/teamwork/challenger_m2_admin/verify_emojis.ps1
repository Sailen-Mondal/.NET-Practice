$emojiPattern = '[\uD83C-\uDBFF\uDC00-\uDFFF\u2600-\u26FF\u2700-\u27BF\uFE00-\uFE0F]'
$files = @(
    "D:\.NET\ViewModelDemo\Views\Admin\Dashboard.cshtml",
    "D:\.NET\ViewModelDemo\Views\Admin\Users.cshtml",
    "D:\.NET\ViewModelDemo\Views\Account\Login.cshtml",
    "D:\.NET\ViewModelDemo\Views\Account\Register.cshtml",
    "D:\.NET\ViewModelDemo\Controllers\AccountController.cs",
    "D:\.NET\ViewModelDemo\Controllers\AdminController.cs",
    "D:\.NET\ViewModelDemo\Content\site.css",
    "D:\.NET\ViewModelDemo\Scripts\app.js",
    "D:\.NET\.agents\teamwork\challenger_m2_admin\TestChallengerAdmin.ps1"
)

foreach ($f in $files) {
    if (Test-Path $f) {
        $text = [System.IO.File]::ReadAllText($f)
        $m = [System.Text.RegularExpressions.Regex]::Matches($text, $emojiPattern)
        Write-Host "$([System.IO.Path]::GetFileName($f)): Chars=$($text.Length), Emojis=$($m.Count)"
    } else {
        Write-Host "$f not found"
    }
}
