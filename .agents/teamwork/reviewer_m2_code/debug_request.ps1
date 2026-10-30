try {
    $req = [System.Net.HttpWebRequest]::Create("http://localhost:9979/")
    $res = $req.GetResponse()
    Write-Host "Success: $([int]$res.StatusCode)"
} catch [System.Net.WebException] {
    Write-Host "WebException: $($_.Exception.Message)"
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $body = $reader.ReadToEnd()
        if ($body -match "<title>(.*?)</title>") {
            Write-Host "Title: $($matches[1])"
        }
        $lines = $body -split "`n"
        $lines | Where-Object { $_ -match "Exception" -or $_ -match "Error" } | Select-Object -First 10 | ForEach-Object { Write-Host "Line: $($_.Trim())" }
    }
}
