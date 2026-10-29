# Deep verification script for emojis, resource links, and markup
$ErrorActionPreference = 'Stop'

$emojiRegex = '[\uD83C-\uDBFF\uDC00-\uDFFF\u2600-\u27BF]'

$urls = @(
    'http://localhost:9979/Content/site.css',
    'http://localhost:9979/Scripts/app.js',
    'http://localhost:9979/Employee/Index',
    'http://localhost:9979/Employee/Details',
    'http://localhost:9979/Student/getStud',
    'http://localhost:9979/Account/Login',
    'http://localhost:9979/Account/Register'
)

Write-Host "=== Deep Scan: Runtime Emoji Check ==="
foreach ($u in $urls) {
    $res = Invoke-WebRequest -Uri $u -UseBasicParsing
    $match = [regex]::Match($res.Content, $emojiRegex)
    if ($match.Success) {
        Write-Host "FAILED: Found emoji at $u : $($match.Value)"
        throw "Emoji found at $u"
    } else {
        Write-Host "PASS: Zero emojis at $u (Status: $($res.StatusCode), Length: $($res.Content.Length))"
    }
}

Write-Host "`n=== Deep Scan: Source Files Emoji Check ==="
$sourceFiles = Get-ChildItem -Path "D:\.NET\ViewModelDemo" -Recurse -Include *.cs,*.cshtml,*.css,*.js
$foundEmojiInSource = $false
foreach ($f in $sourceFiles) {
    $content = [System.IO.File]::ReadAllText($f.FullName)
    $m = [regex]::Match($content, $emojiRegex)
    if ($m.Success) {
        Write-Host "FAILED: Found emoji in file $($f.FullName) : $($m.Value)"
        $foundEmojiInSource = $true
    }
}
if (-not $foundEmojiInSource) {
    Write-Host "PASS: Zero emojis across all $($sourceFiles.Count) source files (.cs, .cshtml, .css, .js)!"
} else {
    throw "Emojis detected in source files!"
}

Write-Host "`n=== Deep Scan: Asset Reference 404 Check ==="
$pages = @(
    'http://localhost:9979/Employee/Index',
    'http://localhost:9979/Account/Login'
)

foreach ($page in $pages) {
    $res = Invoke-WebRequest -Uri $page -UseBasicParsing
    $html = $res.Content
    
    # Find all stylesheet links
    $cssMatches = [regex]::Matches($html, 'href="(/Content/[^"]+)"')
    foreach ($m in $cssMatches) {
        $assetUrl = "http://localhost:9979" + $m.Groups[1].Value
        $assetRes = Invoke-WebRequest -Uri $assetUrl -UseBasicParsing
        Write-Host "  Page $page links CSS $assetUrl -> Status $($assetRes.StatusCode)"
        if ($assetRes.StatusCode -ne 200) { throw "Broken link: $assetUrl" }
    }

    # Find all script tags
    $jsMatches = [regex]::Matches($html, 'src="(/Scripts/[^"]+)"')
    foreach ($m in $jsMatches) {
        $assetUrl = "http://localhost:9979" + $m.Groups[1].Value
        $assetRes = Invoke-WebRequest -Uri $assetUrl -UseBasicParsing
        Write-Host "  Page $page links JS $assetUrl -> Status $($assetRes.StatusCode)"
        if ($assetRes.StatusCode -ne 200) { throw "Broken link: $assetUrl" }
    }
}

Write-Host "`n=== All Deep Scan Checks PASSED ==="
