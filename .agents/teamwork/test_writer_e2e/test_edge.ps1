$ErrorActionPreference = 'Stop'
$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$url = "http://localhost:8188/Default.aspx"

function Send-Postback {
    param(
        [hashtable]$Fields,
        [string]$HtmlContent
    )
    $vsMatch = [regex]::Match($HtmlContent, 'id="__VIEWSTATE"\s+value="([^"]*)"')
    $vs = if ($vsMatch.Success) { $vsMatch.Groups[1].Value } else { "" }
    
    $postBody = @{
        "__VIEWSTATE" = $vs
    }
    foreach ($k in $Fields.Keys) {
        $postBody[$k] = $Fields[$k]
    }
    
    try {
        return Invoke-WebRequest -Uri $url -Method Post -Body $postBody -WebSession $session -UseBasicParsing
    } catch {
        return $_.Exception.Response
    }
}

$r0 = Invoke-WebRequest -Uri $url -WebSession $session -UseBasicParsing

# Test single quote
$rQuote = Send-Postback -Fields @{ "btnSearch" = "Search"; "txtFirstName" = "O'Connor" } -HtmlContent $r0.Content
Write-Host "Single Quote Status: $($rQuote.StatusCode)"
$quoteCards = ([regex]::Matches($rQuote.Content, '<div class="profile-card">')).Count
Write-Host "Single Quote Cards: $quoteCards"

# Test percent sign
$rPercent = Send-Postback -Fields @{ "btnSearch" = "Search"; "txtFirstName" = "%" } -HtmlContent $r0.Content
Write-Host "Percent Sign Status: $($rPercent.StatusCode)"
$percentCards = ([regex]::Matches($rPercent.Content, '<div class="profile-card">')).Count
Write-Host "Percent Sign Cards: $percentCards"

# Test whitespace
$rWhite = Send-Postback -Fields @{ "btnSearch" = "Search"; "txtFirstName" = "   Rahul   " } -HtmlContent $r0.Content
Write-Host "Whitespace Status: $($rWhite.StatusCode)"
$whiteCards = ([regex]::Matches($rWhite.Content, '<div class="profile-card">')).Count
Write-Host "Whitespace Cards: $whiteCards (Has Rahul: $($rWhite.Content.Contains('Rahul Sharma')))"

# Test case insensitivity
$rLower = Send-Postback -Fields @{ "btnSearch" = "Search"; "txtFirstName" = "rahul" } -HtmlContent $r0.Content
Write-Host "Lowercase Status: $($rLower.StatusCode)"
$lowerCards = ([regex]::Matches($rLower.Content, '<div class="profile-card">')).Count
Write-Host "Lowercase Cards: $lowerCards (Has Rahul: $($rLower.Content.Contains('Rahul Sharma')))"

$rUpper = Send-Postback -Fields @{ "btnSearch" = "Search"; "txtFirstName" = "RAHUL" } -HtmlContent $r0.Content
Write-Host "Uppercase Status: $($rUpper.StatusCode)"
$upperCards = ([regex]::Matches($rUpper.Content, '<div class="profile-card">')).Count
Write-Host "Uppercase Cards: $upperCards (Has Rahul: $($rUpper.Content.Contains('Rahul Sharma')))"

# Test script tag
$rScript = Send-Postback -Fields @{ "btnSearch" = "Search"; "txtFirstName" = "<script>alert(1)</script>" } -HtmlContent $r0.Content
Write-Host "Script Tag Status: $($rScript.StatusCode)"
