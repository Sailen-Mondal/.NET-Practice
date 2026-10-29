$files = @(
  'D:\.NET\ViewModelDemo\Views\Shared\_Layout.cshtml',
  'D:\.NET\ViewModelDemo\Views\Shared\_Navigation.cshtml',
  'D:\.NET\ViewModelDemo\Content\site.css',
  'D:\.NET\ViewModelDemo\Scripts\app.js'
)

$pattern = '[\uD800-\uDBFF][\uDC00-\uDFFF]|[\u2600-\u27BF]|[\u2300-\u23FF]|[\u2B50]'

foreach ($file in $files) {
    $text = [System.IO.File]::ReadAllText($file)
    $hasEmoji = [System.Text.RegularExpressions.Regex]::IsMatch($text, $pattern)
    Write-Host "$file : $hasEmoji"
}
