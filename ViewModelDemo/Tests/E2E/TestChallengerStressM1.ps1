# ==============================================================================
# TestChallengerStressM1.ps1 - Empirical Adversarial Stress Harness for M1
# Tests: Modal/Drawer Interleaving, Breakpoint Sweep, Rapid Toggling, CSS Tokens
# ==============================================================================

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$results = [System.Collections.Generic.List[PSCustomObject]]::new()

function Record-Result {
    param(
        [string]$Category,
        [string]$Name,
        [bool]$Passed,
        [string]$Details
    )
    $obj = [PSCustomObject]@{
        Category = $Category
        Name     = $Name
        Passed   = $Passed
        Details  = $Details
    }
    $results.Add($obj)
    $status = if ($Passed) { "[PASS]" } else { "[FAIL]" }
    Write-Host "$status $Category :: $Name - $Details"
}

Write-Host "======================================================================"
Write-Host "STARTING ADVERSARIAL STRESS TEST HARNESS FOR MILESTONE 1"
Write-Host "======================================================================"

$chromePath = "C:\Program Files\Google\Chrome\Application\chrome.exe"
if (-not (Test-Path $chromePath)) {
    $chromePath = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
}

$port = 9224
$targetUrl = "http://localhost:9979/Employee/Index"

$psi = New-Object System.Diagnostics.ProcessStartInfo
$psi.FileName = $chromePath
$psi.Arguments = "--headless=new --remote-debugging-port=$port --disable-gpu --window-size=1280,800 `"$targetUrl`""
$psi.UseShellExecute = $false
$psi.CreateNoWindow = $true

$chromeProc = [System.Diagnostics.Process]::Start($psi)

try {
    Start-Sleep -Milliseconds 2000
    $pages = Invoke-RestMethod -Uri "http://localhost:$port/json"
    $page = $pages | Where-Object { $_.url -like "*Employee*" } | Select-Object -First 1

    if ($null -eq $page) {
        Record-Result "Browser" "ChromeLaunch" $false "Failed to find page target on port $port"
    } else {
        Record-Result "Browser" "ChromeLaunch" $true "Chrome running and attached to page: $($page.url)"
        $wsUrl = [System.Uri]$page.webSocketDebuggerUrl

        $ws = New-Object System.Net.WebSockets.ClientWebSocket
        $cts = New-Object System.Threading.CancellationTokenSource(10000)
        $ws.ConnectAsync($wsUrl, $cts.Token).Wait()

        $script:reqId = 1

        function Invoke-Cdp {
            param([string]$Method, [hashtable]$Params = @{})
            $script:reqId++
            $id = $script:reqId
            $payload = @{
                id     = $id
                method = $Method
                params = $Params
            } | ConvertTo-Json -Depth 10 -Compress

            $bytes = [System.Text.Encoding]::UTF8.GetBytes($payload)
            $segment = New-Object System.ArraySegment[byte]($bytes, 0, $bytes.Length)
            $ws.SendAsync($segment, [System.Net.WebSockets.WebSocketMessageType]::Text, $true, [System.Threading.CancellationToken]::None).Wait()

            $buffer = New-Object byte[] 65536
            $recvSegment = New-Object System.ArraySegment[byte]($buffer, 0, $buffer.Length)
            
            $ms = New-Object System.IO.MemoryStream
            do {
                $recvResult = $ws.ReceiveAsync($recvSegment, [System.Threading.CancellationToken]::None).Result
                $ms.Write($buffer, 0, $recvResult.Count)
            } while (-not $recvResult.EndOfMessage)

            $respStr = [System.Text.Encoding]::UTF8.GetString($ms.ToArray())
            return ($respStr | ConvertFrom-Json)
        }

        function Eval-Script {
            param([string]$Expression)
            $res = Invoke-Cdp -Method "Runtime.evaluate" -Params @{
                expression = $Expression
                returnByValue = $true
                awaitPromise = $true
            }
            if ($res.PSObject.Properties['error']) {
                return [PSCustomObject]@{
                    Error = $res.error.message
                    Value = $null
                }
            }
            if ($res.result.PSObject.Properties['exceptionDetails']) {
                return [PSCustomObject]@{
                    Error = $res.result.exceptionDetails.text
                    Value = $null
                }
            }
            $val = if ($res.result.result.PSObject.Properties['value']) { $res.result.result.value } else { $null }
            return [PSCustomObject]@{
                Error = $null
                Value = $val
            }
        }

        # ----------------------------------------------------------------------
        # TEST 1: CSS Notion Tokens on Root
        # ----------------------------------------------------------------------
        Write-Host "`n--- [STRESS 1] Design Tokens on :root ---"
        $tokenCheck = (Eval-Script @"
        (function() {
            var style = window.getComputedStyle(document.documentElement);
            return {
                canvasBg: style.getPropertyValue('--canvas-bg').trim(),
                surfaceCard: style.getPropertyValue('--surface-card').trim(),
                textPrimary: style.getPropertyValue('--text-primary').trim(),
                borderColor: style.getPropertyValue('--border-color').trim()
            };
        })()
"@).Value

        Record-Result "DesignTokens" "CanvasBg" ($tokenCheck.canvasBg -eq "#fbfbfa") `
            "Canvas color: '$($tokenCheck.canvasBg)' (expected: #fbfbfa)"
        Record-Result "DesignTokens" "SurfaceCard" ($tokenCheck.surfaceCard -eq "#ffffff") `
            "Card surface: '$($tokenCheck.surfaceCard)' (expected: #ffffff)"
        Record-Result "DesignTokens" "TextPrimary" ($tokenCheck.textPrimary -eq "#37352f") `
            "Primary text: '$($tokenCheck.textPrimary)' (expected: #37352f)"
        Record-Result "DesignTokens" "BorderColor" ($tokenCheck.borderColor -eq "#e5e7eb") `
            "Border color: '$($tokenCheck.borderColor)' (expected: #e5e7eb)"

        # ----------------------------------------------------------------------
        # TEST 2: Multi-Breakpoint Viewport Sweep
        # ----------------------------------------------------------------------
        Write-Host "`n--- [STRESS 2] Multi-Breakpoint Viewport Sweep ---"
        $viewports = @(320, 375, 480, 768, 769, 1024, 1280)

        foreach ($w in $viewports) {
            Invoke-Cdp -Method "Emulation.setDeviceMetricsOverride" -Params @{
                width = $w
                height = 800
                deviceScaleFactor = 1
                mobile = ($w -le 768)
            } | Out-Null
            Start-Sleep -Milliseconds 150

            $bpCheck = (Eval-Script @"
            (function() {
                var docWidth = document.documentElement.clientWidth;
                var scrollWidth = document.documentElement.scrollWidth;
                var navMenuDisplay = window.getComputedStyle(document.querySelector('.nav-menu')).display;
                var toggleDisplay = window.getComputedStyle(document.getElementById('mobileNavToggle')).display;
                return {
                    docWidth: docWidth,
                    scrollWidth: scrollWidth,
                    noHScroll: scrollWidth <= docWidth,
                    navMenuDisplay: navMenuDisplay,
                    toggleDisplay: toggleDisplay
                };
            })()
"@).Value

            $expectedToggle = if ($w -le 768) { "inline-flex" } else { "none" }
            $expectedMenu = if ($w -le 768) { "none" } else { "flex" }

            Record-Result "ViewportSweep" "NoHScroll_${w}px" $bpCheck.noHScroll `
                "Width ${w}px: docWidth=$($bpCheck.docWidth), scrollWidth=$($bpCheck.scrollWidth) (No horizontal overflow: $($bpCheck.noHScroll))"
            Record-Result "ViewportSweep" "ToggleState_${w}px" ($bpCheck.toggleDisplay -eq $expectedToggle) `
                "Width ${w}px: toggleDisplay='$($bpCheck.toggleDisplay)' (expected: $expectedToggle)"
            Record-Result "ViewportSweep" "MenuState_${w}px" ($bpCheck.navMenuDisplay -eq $expectedMenu) `
                "Width ${w}px: navMenuDisplay='$($bpCheck.navMenuDisplay)' (expected: $expectedMenu)"
        }

        # ----------------------------------------------------------------------
        # TEST 3: Interleaving Drawer and Modal State Stress Test
        # ----------------------------------------------------------------------
        Write-Host "`n--- [STRESS 3] Interleaving Drawer and Modal State ---"
        # Reset to mobile viewport
        Invoke-Cdp -Method "Emulation.setDeviceMetricsOverride" -Params @{
            width = 375
            height = 800
            deviceScaleFactor = 1
            mobile = $true
        } | Out-Null
        Start-Sleep -Milliseconds 150

        # Step 3.1: Open drawer
        Eval-Script "document.getElementById('mobileNavToggle').click();" | Out-Null
        Start-Sleep -Milliseconds 100

        $drawerOpenCheck = (Eval-Script @"
        (function() {
            var drawer = document.getElementById('mobileNavDrawer');
            return {
                open: drawer.classList.contains('open'),
                bodyOverflow: document.body.style.overflow
            };
        })()
"@).Value

        Record-Result "Interleaving" "DrawerOpenInitially" ($drawerOpenCheck.open -and $drawerOpenCheck.bodyOverflow -eq "hidden") `
            "Drawer open: $($drawerOpenCheck.open), body.overflow: '$($drawerOpenCheck.bodyOverflow)'"

        # Step 3.2: Create and open modal while drawer is open
        Eval-Script @"
        (function() {
            var modal = document.createElement('div');
            modal.id = 'stressTestModal';
            modal.className = 'notion-modal-overlay';
            modal.innerHTML = '<div class=\"notion-modal-dialog\"><button id=\"stressModalBtn\">Action</button></div>';
            document.body.appendChild(modal);
            window.ViewModelDemoModal.open('stressTestModal');
        })()
"@ | Out-Null
        Start-Sleep -Milliseconds 100

        $modalOnDrawerCheck = (Eval-Script @"
        (function() {
            var modal = document.getElementById('stressTestModal');
            var drawer = document.getElementById('mobileNavDrawer');
            var modalZ = parseInt(window.getComputedStyle(modal).zIndex, 10);
            var drawerZ = parseInt(window.getComputedStyle(drawer).zIndex, 10);
            return {
                modalActive: modal.classList.contains('active'),
                modalZ: modalZ,
                drawerZ: drawerZ,
                modalOverDrawer: modalZ > drawerZ,
                bodyOverflow: document.body.style.overflow
            };
        })()
"@).Value

        Record-Result "Interleaving" "ModalStackedAboveDrawer" ($modalOnDrawerCheck.modalActive -and $modalOnDrawerCheck.modalOverDrawer) `
            "Modal active: $($modalOnDrawerCheck.modalActive), modalZ=$($modalOnDrawerCheck.modalZ) > drawerZ=$($modalOnDrawerCheck.drawerZ)"

        # Step 3.3: Close modal - drawer is STILL open, so body overflow must REMAIN hidden
        Eval-Script "window.ViewModelDemoModal.close('stressTestModal');" | Out-Null
        Start-Sleep -Milliseconds 100

        $afterModalCloseCheck = (Eval-Script @"
        (function() {
            var modal = document.getElementById('stressTestModal');
            var drawer = document.getElementById('mobileNavDrawer');
            return {
                modalActive: modal.classList.contains('active'),
                drawerOpen: drawer.classList.contains('open'),
                bodyOverflow: document.body.style.overflow
            };
        })()
"@).Value

        Record-Result "Interleaving" "BodyOverflowPreservedWhenDrawerStillOpen" `
            (-not $afterModalCloseCheck.modalActive -and $afterModalCloseCheck.drawerOpen -and $afterModalCloseCheck.bodyOverflow -eq "hidden") `
            "Modal closed: True, Drawer still open: $($afterModalCloseCheck.drawerOpen), body.overflow: '$($afterModalCloseCheck.bodyOverflow)'"

        # Step 3.4: Now close drawer - body overflow must now be restored to empty string ""
        Eval-Script "document.getElementById('mobileNavClose').click();" | Out-Null
        Start-Sleep -Milliseconds 100

        $afterDrawerCloseCheck = (Eval-Script @"
        (function() {
            var drawer = document.getElementById('mobileNavDrawer');
            return {
                drawerOpen: drawer.classList.contains('open'),
                bodyOverflow: document.body.style.overflow
            };
        })()
"@).Value

        Record-Result "Interleaving" "BodyOverflowRestoredWhenAllClosed" `
            (-not $afterDrawerCloseCheck.drawerOpen -and $afterDrawerCloseCheck.bodyOverflow -eq "") `
            "Drawer closed: True, body.overflow: '$($afterDrawerCloseCheck.bodyOverflow)'"

        # Clean up temporary modal
        Eval-Script "var m = document.getElementById('stressTestModal'); if(m) m.remove();" | Out-Null

        # ----------------------------------------------------------------------
        # TEST 4: Rapid Toggle Stress Test (5 cycles open/close)
        # ----------------------------------------------------------------------
        Write-Host "`n--- [STRESS 4] Rapid Toggle Stress Test ---"
        Eval-Script @"
        (function() {
            var toggle = document.getElementById('mobileNavToggle');
            var close = document.getElementById('mobileNavClose');
            for (var i = 0; i < 5; i++) {
                toggle.click();
                close.click();
            }
        })()
"@ | Out-Null
        Start-Sleep -Milliseconds 200

        $rapidToggleCheck = (Eval-Script @"
        (function() {
            var drawer = document.getElementById('mobileNavDrawer');
            var overlay = document.querySelector('.nav-drawer-overlay');
            return {
                drawerOpen: drawer.classList.contains('open'),
                overlayOpen: overlay.classList.contains('open'),
                bodyOverflow: document.body.style.overflow
            };
        })()
"@).Value

        Record-Result "RapidToggle" "DrawerConsistentAfter5Cycles" `
            (-not $rapidToggleCheck.drawerOpen -and -not $rapidToggleCheck.overlayOpen -and $rapidToggleCheck.bodyOverflow -eq "") `
            "After 5 rapid toggle cycles: drawerOpen=$($rapidToggleCheck.drawerOpen), overlayOpen=$($rapidToggleCheck.overlayOpen), bodyOverflow='$($rapidToggleCheck.bodyOverflow)'"

        $ws.CloseAsync([System.Net.WebSockets.WebSocketCloseStatus]::NormalClosure, "Done", [System.Threading.CancellationToken]::None).Wait()
    }
} finally {
    if ($chromeProc -and -not $chromeProc.HasExited) {
        $chromeProc.Kill()
        $chromeProc.WaitForExit(3000)
    }
}

Write-Host "`n======================================================================"
Write-Host "SUMMARY OF ADVERSARIAL STRESS TEST RESULTS"
Write-Host "======================================================================"

$passCount = @($results | Where-Object { $_.Passed }).Count
$failCount = @($results | Where-Object { -not $_.Passed }).Count
$totalCount = $results.Count

Write-Host "Total Tests: $totalCount"
Write-Host "Passed:      $passCount"
Write-Host "Failed:      $failCount"

if ($failCount -gt 0) {
    Write-Host "`nFAILED TESTS DETAILS:"
    $results | Where-Object { -not $_.Passed } | ForEach-Object {
        Write-Host "[$($_.Category)] $($_.Name) - $($_.Details)"
    }
    exit 1
} else {
    exit 0
}
