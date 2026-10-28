$dir = "C:\Users\sailenmondal\OneDrive - MANAGEMENT & COMPUTER CONSULTANTS\Documents\Visual Studio 2015\WebSites\WebSite2"
$files = Get-ChildItem -Path $dir -Recurse -File -Include "*.aspx", "*.cs", "*.config", "*.xsd", "*.html", "*.css", "*.js"
$count = 0
foreach ($f in $files) {
    $content = Get-Content -Path $f.FullName -Raw -Encoding UTF8 -ErrorAction SilentlyContinue
    if ($content -match '[\uD83C-\uDBFF\uDC00-\uDFFF\u2600-\u26FF\u2700-\u27BF]') {
        Write-Host "Match in $($f.FullName)"
        $count++
    }
}
Write-Host "WebSite2 text/code files emoji count: $count"
