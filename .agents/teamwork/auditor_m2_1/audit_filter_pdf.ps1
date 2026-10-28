$webSession = New-Object Microsoft.PowerShell.Commands.WebRequestSession

function Extract-Field($html, $name) {
    $pattern = 'id="' + $name + '"\s+value="([^"]*)"'
    if ($html -match $pattern) {
        return $matches[1]
    }
    return ""
}

# 1. Search for Rahul
$get1 = Invoke-WebRequest -Uri "http://localhost:8188/Default.aspx" -WebSession $webSession -UseBasicParsing
$bodyRahul = @{
    "__VIEWSTATE" = Extract-Field $get1.Content "__VIEWSTATE"
    "__VIEWSTATEGENERATOR" = Extract-Field $get1.Content "__VIEWSTATEGENERATOR"
    "__EVENTVALIDATION" = Extract-Field $get1.Content "__EVENTVALIDATION"
    "txtFirstName" = "Rahul"
    "DropDownList1" = ""
    "ddlViewMode" = "Directory"
    "btnSearch" = "Search"
}
$postRahul = Invoke-WebRequest -Uri "http://localhost:8188/Default.aspx" -Method POST -Body $bodyRahul -WebSession $webSession -UseBasicParsing

$bodyRahulPdf = @{
    "__VIEWSTATE" = Extract-Field $postRahul.Content "__VIEWSTATE"
    "__VIEWSTATEGENERATOR" = Extract-Field $postRahul.Content "__VIEWSTATEGENERATOR"
    "__EVENTVALIDATION" = Extract-Field $postRahul.Content "__EVENTVALIDATION"
    "txtFirstName" = "Rahul"
    "DropDownList1" = ""
    "ddlViewMode" = "Directory"
    "btnPDF" = "Convert To PDF"
}
$pdfRahul = Invoke-WebRequest -Uri "http://localhost:8188/Default.aspx" -Method POST -Body $bodyRahulPdf -WebSession $webSession -UseBasicParsing
Write-Host "Rahul PDF Length: $($pdfRahul.Content.Length) bytes"

# 2. Search for Priya
$get2 = Invoke-WebRequest -Uri "http://localhost:8188/Default.aspx" -WebSession $webSession -UseBasicParsing
$bodyPriya = @{
    "__VIEWSTATE" = Extract-Field $get2.Content "__VIEWSTATE"
    "__VIEWSTATEGENERATOR" = Extract-Field $get2.Content "__VIEWSTATEGENERATOR"
    "__EVENTVALIDATION" = Extract-Field $get2.Content "__EVENTVALIDATION"
    "txtFirstName" = "Priya"
    "DropDownList1" = ""
    "ddlViewMode" = "Directory"
    "btnSearch" = "Search"
}
$postPriya = Invoke-WebRequest -Uri "http://localhost:8188/Default.aspx" -Method POST -Body $bodyPriya -WebSession $webSession -UseBasicParsing

$bodyPriyaPdf = @{
    "__VIEWSTATE" = Extract-Field $postPriya.Content "__VIEWSTATE"
    "__VIEWSTATEGENERATOR" = Extract-Field $postPriya.Content "__VIEWSTATEGENERATOR"
    "__EVENTVALIDATION" = Extract-Field $postPriya.Content "__EVENTVALIDATION"
    "txtFirstName" = "Priya"
    "DropDownList1" = ""
    "ddlViewMode" = "Directory"
    "btnPDF" = "Convert To PDF"
}
$pdfPriya = Invoke-WebRequest -Uri "http://localhost:8188/Default.aspx" -Method POST -Body $bodyPriyaPdf -WebSession $webSession -UseBasicParsing
Write-Host "Priya PDF Length: $($pdfPriya.Content.Length) bytes"

# Compare lengths and MD5 hashes
$md5 = [System.Security.Cryptography.MD5]::Create()
$hashRahul = [System.BitConverter]::ToString($md5.ComputeHash($pdfRahul.Content))
$hashPriya = [System.BitConverter]::ToString($md5.ComputeHash($pdfPriya.Content))

Write-Host "Rahul PDF MD5: $hashRahul"
Write-Host "Priya PDF MD5: $hashPriya"
Write-Host "Are PDF hashes different? $( $hashRahul -ne $hashPriya )"
