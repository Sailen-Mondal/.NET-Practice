# Auto Git Commit and Push Script for D:\.NET
$gitPath = "C:\Users\sailenmondal\AppData\Local\Programs\Git\cmd"
if ($env:PATH -notlike "*$gitPath*") {
    $env:PATH = "$gitPath;$env:PATH"
}

$repoPath = "D:\.NET"
$logFile = "$repoPath\auto_git_push.log"

Set-Location -Path $repoPath

$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
"[$timestamp] Starting auto git push check..." | Out-File -FilePath $logFile -Append -Encoding utf8

try {
    $status = git status --porcelain
    if ($status) {
        "[$timestamp] Changes detected:" | Out-File -FilePath $logFile -Append -Encoding utf8
        $status | Out-File -FilePath $logFile -Append -Encoding utf8
        
        git add . 2>&1 | Out-File -FilePath $logFile -Append -Encoding utf8
        
        $commitMsg = "Auto commit: $timestamp"
        git commit -m "$commitMsg" 2>&1 | Out-File -FilePath $logFile -Append -Encoding utf8
        
        $pushOutput = git push origin main 2>&1
        $pushOutput | Out-File -FilePath $logFile -Append -Encoding utf8
        
        "[$timestamp] Git commit and push process completed." | Out-File -FilePath $logFile -Append -Encoding utf8
    } else {
        "[$timestamp] No changes detected in $repoPath. Skipping push." | Out-File -FilePath $logFile -Append -Encoding utf8
    }
} catch {
    "[$timestamp] ERROR during execution: $_" | Out-File -FilePath $logFile -Append -Encoding utf8
}
