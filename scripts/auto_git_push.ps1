##############################################################################
# auto_git_push.ps1
# Automated daily Git commit & push for D:\.NET -> GitHub
# Handles: retry logic, exit-code checks, log rotation, missed-run recovery
##############################################################################

# ── CONFIG ────────────────────────────────────────────────────────────────────
$GIT_EXE   = "C:\Users\sailenmondal\AppData\Local\Programs\Git\cmd\git.exe"
$REPO_PATH = "D:\.NET"
$LOG_FILE  = "$REPO_PATH\scripts\auto_git_push.log"
$MAX_LOG_LINES = 500          # rotate log beyond this
$MAX_PUSH_RETRIES = 3         # retry push on transient network errors
$PUSH_RETRY_WAIT_SEC = 30     # wait between retries
$BRANCH = "main"

# ── GUARD: verify git binary exists ──────────────────────────────────────────
if (-not (Test-Path $GIT_EXE)) {
    $msg = "[$(Get-Date -f 'yyyy-MM-dd HH:mm:ss')] FATAL: git.exe not found at $GIT_EXE"
    Add-Content -Path $LOG_FILE -Value $msg -Encoding utf8
    Write-EventLog -LogName Application -Source "AutoGitPush" -EntryType Error `
        -EventId 1001 -Message $msg -ErrorAction SilentlyContinue
    exit 1
}

# ── GUARD: verify repo exists ─────────────────────────────────────────────────
if (-not (Test-Path "$REPO_PATH\.git")) {
    $msg = "[$(Get-Date -f 'yyyy-MM-dd HH:mm:ss')] FATAL: $REPO_PATH is not a git repository."
    Add-Content -Path $LOG_FILE -Value $msg -Encoding utf8
    exit 1
}

# ── LOG ROTATION ──────────────────────────────────────────────────────────────
if (Test-Path $LOG_FILE) {
    $lines = Get-Content $LOG_FILE
    if ($lines.Count -gt $MAX_LOG_LINES) {
        # Keep the last MAX_LOG_LINES lines
        $lines | Select-Object -Last $MAX_LOG_LINES | Set-Content $LOG_FILE -Encoding utf8
    }
}

# ── HELPER ────────────────────────────────────────────────────────────────────
function Log($msg) {
    $entry = "[$(Get-Date -f 'yyyy-MM-dd HH:mm:ss')] $msg"
    Add-Content -Path $LOG_FILE -Value $entry -Encoding utf8
    Write-Host $entry
}

function Run-Git {
    param([string[]]$Args)
    $output = & $GIT_EXE @Args 2>&1
    return @{ Output = $output; ExitCode = $LASTEXITCODE }
}

# ── MAIN ──────────────────────────────────────────────────────────────────────
Set-Location -Path $REPO_PATH
Log "=========================================="
Log "Auto Git Push started."

# 1. Check for changes
$statusResult = Run-Git @("status", "--porcelain")
if ($statusResult.ExitCode -ne 0) {
    Log "ERROR: 'git status' failed (exit $($statusResult.ExitCode)): $($statusResult.Output)"
    exit 1
}

$changes = $statusResult.Output | Where-Object { $_.Trim() -ne "" }

if (-not $changes) {
    Log "No changes detected. Nothing to commit."
    Log "=========================================="
    exit 0
}

Log "Changes detected:"
$changes | ForEach-Object { Log "  $_" }

# 2. Stage all changes
$addResult = Run-Git @("add", ".")
if ($addResult.ExitCode -ne 0) {
    Log "ERROR: 'git add .' failed (exit $($addResult.ExitCode)): $($addResult.Output)"
    exit 1
}
Log "Staged all changes."

# 3. Commit
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$commitMsg = "chore: auto daily commit [$timestamp]"
$commitResult = Run-Git @("commit", "-m", $commitMsg)
if ($commitResult.ExitCode -ne 0) {
    Log "ERROR: 'git commit' failed (exit $($commitResult.ExitCode)): $($commitResult.Output)"
    exit 1
}
Log "Committed: $commitMsg"
Log ($commitResult.Output -join " ")

# 4. Push with retry logic
$pushed = $false
for ($attempt = 1; $attempt -le $MAX_PUSH_RETRIES; $attempt++) {
    Log "Push attempt $attempt of $MAX_PUSH_RETRIES..."
    $pushResult = Run-Git @("push", "origin", $BRANCH)
    if ($pushResult.ExitCode -eq 0) {
        Log "Push succeeded."
        Log ($pushResult.Output -join " ")
        $pushed = $true
        break
    }
    else {
        Log "Push attempt $attempt FAILED (exit $($pushResult.ExitCode)): $($pushResult.Output)"
        if ($attempt -lt $MAX_PUSH_RETRIES) {
            Log "Waiting $PUSH_RETRY_WAIT_SEC seconds before retry..."
            Start-Sleep -Seconds $PUSH_RETRY_WAIT_SEC
        }
    }
}

if (-not $pushed) {
    $errMsg = "All $MAX_PUSH_RETRIES push attempts failed. Check network or token."
    Log "FATAL: $errMsg"
    # Write to Windows Event Log for monitoring
    try {
        New-EventLog -LogName Application -Source "AutoGitPush" -ErrorAction SilentlyContinue
        Write-EventLog -LogName Application -Source "AutoGitPush" -EntryType Error `
            -EventId 1002 -Message $errMsg -ErrorAction SilentlyContinue
    } catch {}
    exit 1
}

Log "Auto Git Push completed successfully."
Log "=========================================="
exit 0
