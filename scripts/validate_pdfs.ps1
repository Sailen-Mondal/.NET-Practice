$ErrorActionPreference = 'Stop'
$projDir = 'C:\Users\sailenmondal\OneDrive - MANAGEMENT & COMPUTER CONSULTANTS\Documents\Visual Studio 2015\WebSites\WebSite2'
$resumesDir = Join-Path $projDir "Resumes"

$files = Get-ChildItem -Path $resumesDir -Filter "*.pdf"
$sha = [System.Security.Cryptography.SHA256]::Create()

foreach ($f in $files) {
    $bytes = [System.IO.File]::ReadAllBytes($f.FullName)
    $hash = [BitConverter]::ToString($sha.ComputeHash($bytes)).Replace("-", "")
    
    # Check magic bytes '%PDF-'
    $headerBytes = $bytes[0..4]
    $headerStr = [System.Text.Encoding]::ASCII.GetString($headerBytes)
    $isPdf = ($headerStr -eq "%PDF-")
    
    # Check for EOF marker in last 1024 bytes
    $tailLen = [Math]::Min(1024, $bytes.Length)
    $tailBytes = $bytes[($bytes.Length - $tailLen)..($bytes.Length - 1)]
    $tailStr = [System.Text.Encoding]::ASCII.GetString($tailBytes)
    $hasEof = $tailStr.Contains("%%EOF")
    
    # Check PDF version
    $firstLine = [System.Text.Encoding]::ASCII.GetString($bytes[0..15])
    
    Write-Output "File: $($f.Name)"
    Write-Output "  Size: $($bytes.Length) bytes"
    Write-Output "  Header: $headerStr (Valid %PDF-: $isPdf)"
    Write-Output "  First 16 chars: $firstLine"
    Write-Output "  Has %%EOF marker: $hasEof"
    Write-Output "  SHA256: $hash"
    Write-Output ""
}
