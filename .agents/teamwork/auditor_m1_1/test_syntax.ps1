# Forensic syntax & adversarial stress test script
$cssText = [System.IO.File]::ReadAllText('D:\.NET\ViewModelDemo\Content\site.css')
$openBraces = ($cssText.ToCharArray() | Where-Object { $_ -eq '{' }).Count
$closeBraces = ($cssText.ToCharArray() | Where-Object { $_ -eq '}' }).Count
Write-Host "site.css Open Braces: $openBraces, Close Braces: $closeBraces"
if ($openBraces -eq $closeBraces) {
    Write-Host "site.css Brace Balance: BALANCED"
} else {
    Write-Host "site.css Brace Balance: MISMATCH!"
}

$jsText = [System.IO.File]::ReadAllText('D:\.NET\ViewModelDemo\Scripts\app.js')
$jsOpenBraces = ($jsText.ToCharArray() | Where-Object { $_ -eq '{' }).Count
$jsCloseBraces = ($jsText.ToCharArray() | Where-Object { $_ -eq '}' }).Count
$jsOpenParens = ($jsText.ToCharArray() | Where-Object { $_ -eq '(' }).Count
$jsCloseParens = ($jsText.ToCharArray() | Where-Object { $_ -eq ')' }).Count
Write-Host "app.js Open Braces: $jsOpenBraces, Close Braces: $jsCloseBraces"
Write-Host "app.js Open Parens: $jsOpenParens, Close Parens: $jsCloseParens"
if ($jsOpenBraces -eq $jsCloseBraces -and $jsOpenParens -eq $jsCloseParens) {
    Write-Host "app.js Syntax Structure: BALANCED"
} else {
    Write-Host "app.js Syntax Structure: MISMATCH!"
}

# Verify node syntax if node is installed
if (Get-Command node -ErrorAction SilentlyContinue) {
    $nodeCheck = node --check "D:\.NET\ViewModelDemo\Scripts\app.js" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "app.js Node --check: VALID SYNTAX"
    } else {
        Write-Host "app.js Node --check: SYNTAX ERROR: $nodeCheck"
    }
}
