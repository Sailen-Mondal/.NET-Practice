$ErrorActionPreference = 'Stop'
try {
    $req = [System.Net.HttpWebRequest]::Create('http://localhost:8188/Default.aspx')
    $res = $req.GetResponse()
    Write-Output "Status: $($res.StatusCode)"
} catch [System.Net.WebException] {
    $res = $_.Exception.Response
    if ($res) {
        $stream = $res.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($stream)
        $body = $reader.ReadToEnd()
        Write-Output "Response Length: $($body.Length)"
        # Extract title or h2 or stack trace from yellow screen of death
        if ($body -match "<title>(.*?)</title>") {
            Write-Output "Title: $($matches[1])"
        }
        if ($body -match "<h2>\s*<i>(.*?)</i>\s*</h2>") {
            Write-Output "Error: $($matches[1])"
        }
        if ($body -match "<b> Description: </b>(.*?)<br>") {
            Write-Output "Description: $($matches[1])"
        }
        if ($body -match "<b> Exception Details: </b>(.*?)<br>") {
            Write-Output "Details: $($matches[1])"
        }
        if ($body -match "<b>Source Error:</b>.*?<code><pre>(.*?)</pre></code>") {
            Write-Output "Source Error: $($matches[1])"
        }
        if ($body -match "<b>Stack Trace:</b>.*?<code><pre>(.*?)</pre></code>") {
            Write-Output "Stack Trace: $($matches[1])"
        }
    } else {
        Write-Output "No response: $($_.Exception.Message)"
    }
}
