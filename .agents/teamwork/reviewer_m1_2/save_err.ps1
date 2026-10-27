$ErrorActionPreference = 'Stop'
try {
    $req = [System.Net.HttpWebRequest]::Create('http://localhost:8188/Default.aspx')
    $res = $req.GetResponse()
} catch [System.Net.WebException] {
    $res = $_.Exception.Response
    $stream = $res.GetResponseStream()
    $reader = New-Object System.IO.StreamReader($stream)
    $body = $reader.ReadToEnd()
    # Save the body to html file to inspect
    $body | Set-Content "d:\.NET\.agents\teamwork\reviewer_m1_2\error_500.html"
    Write-Output "Saved 500 error to error_500.html"
}
