# ==============================================================================
# TestChallengerM1.ps1 - Empirical Challenger Test Harness for Milestone 1
# Strict Zero Emojis - Verifies Responsiveness, Interactions, Accessibility
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
Write-Host "STARTING EMPIRICAL CHALLENGER VERIFICATION FOR MILESTONE 1"
Write-Host "======================================================================"

# ------------------------------------------------------------------------------
# TEST SUITE 1: STRICT ZERO EMOJIS SCAN
# ------------------------------------------------------------------------------
Write-Host "`n--- [SUITE 1] Strict Zero Emojis Verification ---"

$filesToScan = @(
    "D:\.NET\ViewModelDemo\Content\site.css",
    "D:\.NET\ViewModelDemo\Scripts\app.js",
    "D:\.NET\ViewModelDemo\Views\Shared\_Layout.cshtml",
    "D:\.NET\ViewModelDemo\Views\Shared\_Navigation.cshtml"
)

$emojiPattern = '[\uD83C-\uDBFF\uDC00-\uDFFF\u2600-\u27BF\u2300-\u23FF\u2B50-\u2B55\u203C\u2049\u2139\u2194-\u21AA]'

foreach ($file in $filesToScan) {
    if (-not (Test-Path $file)) {
        Record-Result "ZeroEmoji" "FileExists: $file" $false "File not found"
        continue
    }
    $content = [System.IO.File]::ReadAllText($file)
    $hasEmoji = [System.Text.RegularExpressions.Regex]::IsMatch($content, $emojiPattern)
    $fileName = [System.IO.Path]::GetFileName($file)
    if ($hasEmoji) {
        $match = [System.Text.RegularExpressions.Regex]::Match($content, $emojiPattern).Value
        Record-Result "ZeroEmoji" "Scan $fileName" $false "Found emoji character: $match"
    } else {
        Record-Result "ZeroEmoji" "Scan $fileName" $true "Clean. Zero emojis detected."
    }
}

# ------------------------------------------------------------------------------
# TEST SUITE 2: REDUCED MOTION VERIFICATION
# ------------------------------------------------------------------------------
Write-Host "`n--- [SUITE 2] Prefers Reduced Motion Verification ---"

$cssPath = "D:\.NET\ViewModelDemo\Content\site.css"
$cssText = [System.IO.File]::ReadAllText($cssPath)

$hasReducedMotion = $cssText -match '@media\s*\(prefers-reduced-motion:\s*reduce\)'
Record-Result "ReducedMotion" "MediaQueryExists" $hasReducedMotion "Checked for @media (prefers-reduced-motion: reduce)"

if ($hasReducedMotion) {
    $hasUniversalSelector = $cssText -match '@media\s*\(prefers-reduced-motion:\s*reduce\)[\s\S]*?\*[\s\S]*?\*::before[\s\S]*?\*::after'
    Record-Result "ReducedMotion" "UniversalTargeting" $hasUniversalSelector "Targeted *, *::before, *::after"

    $hasAnimDuration = $cssText -match 'animation-duration:\s*0\.01ms\s*!important'
    Record-Result "ReducedMotion" "AnimationDurationReset" $hasAnimDuration "animation-duration set to 0.01ms !important"

    $hasTransitionDuration = $cssText -match 'transition-duration:\s*0\.01ms\s*!important'
    Record-Result "ReducedMotion" "TransitionDurationReset" $hasTransitionDuration "transition-duration set to 0.01ms !important"

    $hasScrollBehavior = $cssText -match 'scroll-behavior:\s*auto\s*!important'
    Record-Result "ReducedMotion" "ScrollBehaviorReset" $hasScrollBehavior "scroll-behavior set to auto !important"
}

# ------------------------------------------------------------------------------
# TEST SUITE 3: STATIC CSS RULES VERIFICATION
# ------------------------------------------------------------------------------
Write-Host "`n--- [SUITE 3] CSS Breakpoint & Responsive Rules Inspection ---"

$hasTabletBreakpoint = $cssText -match '@media\s*\(max-width:\s*1024px\)'
Record-Result "CSSRules" "TabletBreakpoint" $hasTabletBreakpoint "Tablet breakpoint @media (max-width: 1024px) defined"

$hasMobileBreakpoint = $cssText -match '@media\s*\(max-width:\s*768px\)'
Record-Result "CSSRules" "MobileBreakpoint" $hasMobileBreakpoint "Mobile breakpoint @media (max-width: 768px) defined"

$hasFormRowRule = $cssText -match '\.form-row[\s\S]*?grid-template-columns:\s*1fr'
Record-Result "CSSRules" "FormRowMobileRule" $hasFormRowRule "1-column form-row rule defined for mobile"

$hasTableScrollContainer = $cssText -match '\.notion-table-container[\s\S]*?overflow-x:\s*auto'
Record-Result "CSSRules" "TableScrollContainerRule" $hasTableScrollContainer "overflow-x: auto defined for table container"

# ------------------------------------------------------------------------------
# TEST SUITE 4: EMPIRICAL BROWSER HEADLESS CDP VERIFICATION
# ------------------------------------------------------------------------------
Write-Host "`n--- [SUITE 4] Empirical Chrome Headless CDP Verification ---"

$chromePath = "C:\Program Files\Google\Chrome\Application\chrome.exe"
if (-not (Test-Path $chromePath)) {
    $chromePath = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
}

$port = 9223
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
            
            # Read until message complete
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
            return [PSCustomObject]@{
                Error = $null
                Value = $res.result.result.value
            }
        }

        # ----------------------------------------------------------------------
        # TEST 4.1: Desktop Viewport Layout (>1024px)
        # ----------------------------------------------------------------------
        Invoke-Cdp -Method "Emulation.setDeviceMetricsOverride" -Params @{
            width = 1280
            height = 800
            deviceScaleFactor = 1
            mobile = $false
        } | Out-Null
        Start-Sleep -Milliseconds 300

        $desktopNavMenuDisplay = (Eval-Script "window.getComputedStyle(document.querySelector('.nav-menu')).display").Value
        $desktopToggleDisplay = (Eval-Script "window.getComputedStyle(document.getElementById('mobileNavToggle')).display").Value

        Record-Result "DesktopLayout" "NavMenuVisible" ($desktopNavMenuDisplay -eq "flex") "Desktop .nav-menu display is: $desktopNavMenuDisplay (expected: flex)"
        Record-Result "DesktopLayout" "NavToggleHidden" ($desktopToggleDisplay -eq "none") "Desktop #mobileNavToggle display is: $desktopToggleDisplay (expected: none)"

        # ----------------------------------------------------------------------
        # TEST 4.2: Tablet Viewport Layout (768px - 1024px)
        # ----------------------------------------------------------------------
        Invoke-Cdp -Method "Emulation.setDeviceMetricsOverride" -Params @{
            width = 800
            height = 1024
            deviceScaleFactor = 1
            mobile = $false
        } | Out-Null
        Start-Sleep -Milliseconds 300

        $tabletNavMenuDisplay = (Eval-Script "window.getComputedStyle(document.querySelector('.nav-menu')).display").Value
        $tabletToggleDisplay = (Eval-Script "window.getComputedStyle(document.getElementById('mobileNavToggle')).display").Value
        
        Record-Result "TabletLayout" "NavMenuVisible" ($tabletNavMenuDisplay -eq "flex") "Tablet (800px) .nav-menu display is: $tabletNavMenuDisplay (expected: flex)"
        Record-Result "TabletLayout" "NavToggleHidden" ($tabletToggleDisplay -eq "none") "Tablet (800px) #mobileNavToggle display is: $tabletToggleDisplay (expected: none)"

        # ----------------------------------------------------------------------
        # TEST 4.3: Mobile Viewport Layout (<768px) & Hamburger Toggle
        # ----------------------------------------------------------------------
        Invoke-Cdp -Method "Emulation.setDeviceMetricsOverride" -Params @{
            width = 375
            height = 667
            deviceScaleFactor = 2
            mobile = $true
        } | Out-Null
        Start-Sleep -Milliseconds 300

        $mobileNavMenuDisplay = (Eval-Script "window.getComputedStyle(document.querySelector('.nav-menu')).display").Value
        $mobileToggleDisplay = (Eval-Script "window.getComputedStyle(document.getElementById('mobileNavToggle')).display").Value

        Record-Result "MobileLayout" "NavMenuHidden" ($mobileNavMenuDisplay -eq "none") "Mobile (375px) .nav-menu display is: $mobileNavMenuDisplay (expected: none)"
        Record-Result "MobileLayout" "NavToggleVisible" ($mobileToggleDisplay -eq "inline-flex") "Mobile (375px) #mobileNavToggle display is: $mobileToggleDisplay (expected: inline-flex)"

        # ----------------------------------------------------------------------
        # CRITICAL TEST 4.4: OVERLAY CLICK INTERCEPTION & HIT-TESTING
        # ----------------------------------------------------------------------
        Write-Host "`n--- [CRITICAL AUDIT] Testing Hit-Testing and Pointer Events on Mobile ---"
        
        $overlayState = (Eval-Script @"
        (function() {
            var overlay = document.getElementById('mobileNavOverlay');
            var toggle = document.getElementById('mobileNavToggle');
            var toggleRect = toggle.getBoundingClientRect();
            var centerX = Math.round(toggleRect.left + toggleRect.width / 2);
            var centerY = Math.round(toggleRect.top + toggleRect.height / 2);
            var topElementAtToggle = document.elementFromPoint(centerX, centerY);

            return {
                overlayDisplay: window.getComputedStyle(overlay).display,
                overlayPointerEvents: window.getComputedStyle(overlay).pointerEvents,
                overlayZIndex: window.getComputedStyle(overlay).zIndex,
                overlayOpacity: window.getComputedStyle(overlay).opacity,
                toggleZIndex: window.getComputedStyle(toggle).zIndex,
                topNavZIndex: window.getComputedStyle(document.querySelector('.top-nav')).zIndex,
                topElementAtToggleId: topElementAtToggle ? topElementAtToggle.id : 'null',
                topElementAtToggleClass: topElementAtToggle ? topElementAtToggle.className : 'null',
                topElementTag: topElementAtToggle ? topElementAtToggle.tagName : 'null',
                isToggleReachable: (topElementAtToggle === toggle || toggle.contains(topElementAtToggle)),
                clickX: centerX,
                clickY: centerY
            };
        })()
"@).Value

        Write-Host "Overlay State JSON: $($overlayState | ConvertTo-Json -Depth 2)"
        
        Record-Result "AdversarialHitTest" "MobileOverlayDisplay" ($overlayState.overlayDisplay -eq "none" -or $overlayState.overlayPointerEvents -eq "none") `
            "Overlay display: $($overlayState.overlayDisplay), pointer-events: $($overlayState.overlayPointerEvents)"

        Record-Result "AdversarialHitTest" "ToggleReachableByClick" ($overlayState.isToggleReachable) `
            "Top element at hamburger center: <$($overlayState.topElementTag) id='$($overlayState.topElementAtToggleId)' class='$($overlayState.topElementAtToggleClass)'> Reachable: $($overlayState.isToggleReachable)"

        # Send actual user mouse click event via CDP to hamburger coordinates
        $clickX = [int]$overlayState.clickX
        $clickY = [int]$overlayState.clickY
        Write-Host "Dispatching user mouse click at ($clickX, $clickY)..."

        Invoke-Cdp -Method "Input.dispatchMouseEvent" -Params @{
            type = "mousePressed"
            x = $clickX
            y = $clickY
            button = "left"
            clickCount = 1
        } | Out-Null

        Invoke-Cdp -Method "Input.dispatchMouseEvent" -Params @{
            type = "mouseReleased"
            x = $clickX
            y = $clickY
            button = "left"
            clickCount = 1
        } | Out-Null

        Start-Sleep -Milliseconds 300

        $drawerAfterUserClick = (Eval-Script @"
        (function() {
            var drawer = document.getElementById('mobileNavDrawer');
            var overlay = document.getElementById('mobileNavOverlay');
            var toggle = document.getElementById('mobileNavToggle');
            return {
                drawerHasOpenClass: drawer.classList.contains('open'),
                overlayHasOpenClass: overlay.classList.contains('open'),
                ariaExpanded: toggle.getAttribute('aria-expanded')
            };
        })()
"@).Value

        Record-Result "AdversarialHitTest" "UserClickOpensDrawer" ($drawerAfterUserClick.drawerHasOpenClass -eq $true) `
            "After user click on hamburger coords: drawerOpen=$($drawerAfterUserClick.drawerHasOpenClass), ariaExpanded=$($drawerAfterUserClick.ariaExpanded)"

        # Check hit-testing on main page content (e.g. search input / body)
        $mainHitTest = (Eval-Script @"
        (function() {
            var searchInput = document.querySelector('input[name=\"search\"]');
            if (!searchInput) return { isBlocked: false, topElementId: 'no-input' };
            var r = searchInput.getBoundingClientRect();
            var cx = Math.round(r.left + r.width / 2);
            var cy = Math.round(r.top + r.height / 2);
            var el = document.elementFromPoint(cx, cy);
            return {
                isBlocked: el.id === 'mobileNavOverlay',
                topElementId: el ? el.id : 'null',
                topElementTag: el ? el.tagName : 'null'
            };
        })()
"@).Value

        Record-Result "AdversarialHitTest" "MainContentClickable" (-not $mainHitTest.isBlocked) `
            "Search input center hit-test: top element is <$($mainHitTest.topElementTag) id='$($mainHitTest.topElementId)'> (Blocked by overlay: $($mainHitTest.isBlocked))"

        # ----------------------------------------------------------------------
        # TEST 4.5: JavaScript Interactions (Drawer Open / Close / Escape)
        # ----------------------------------------------------------------------
        Write-Host "`n--- [SUITE 5] JavaScript Interactions Verification ---"

        # Click toggle button
        $toggleClickResult = (Eval-Script @"
        (function() {
            var toggle = document.getElementById('mobileNavToggle');
            var drawer = document.getElementById('mobileNavDrawer');
            var overlay = document.getElementById('mobileNavOverlay');
            
            toggle.click();

            return {
                drawerHasOpenClass: drawer.classList.contains('open'),
                overlayHasOpenClass: overlay.classList.contains('open'),
                ariaExpanded: toggle.getAttribute('aria-expanded'),
                bodyOverflow: document.body.style.overflow
            };
        })()
"@).Value

        Record-Result "JSInteractions" "DrawerOpenOnClick" `
            ($toggleClickResult.drawerHasOpenClass -and $toggleClickResult.overlayHasOpenClass -and $toggleClickResult.ariaExpanded -eq "true" -and $toggleClickResult.bodyOverflow -eq "hidden") `
            "Drawer open: $($toggleClickResult.drawerHasOpenClass), aria-expanded: $($toggleClickResult.ariaExpanded), body.overflow: $($toggleClickResult.bodyOverflow)"

        # Test Close button
        $closeClickResult = (Eval-Script @"
        (function() {
            var closeBtn = document.getElementById('mobileNavClose');
            var drawer = document.getElementById('mobileNavDrawer');
            var overlay = document.getElementById('mobileNavOverlay');
            var toggle = document.getElementById('mobileNavToggle');

            closeBtn.click();

            return {
                drawerHasOpenClass: drawer.classList.contains('open'),
                overlayHasOpenClass: overlay.classList.contains('open'),
                ariaExpanded: toggle.getAttribute('aria-expanded'),
                bodyOverflow: document.body.style.overflow
            };
        })()
"@).Value

        Record-Result "JSInteractions" "DrawerCloseOnButton" `
            (-not $closeClickResult.drawerHasOpenClass -and -not $closeClickResult.overlayHasOpenClass -and $closeClickResult.ariaExpanded -eq "false" -and $closeClickResult.bodyOverflow -eq "") `
            "Drawer closed: $(-not $closeClickResult.drawerHasOpenClass), aria-expanded: $($closeClickResult.ariaExpanded)"

        # Test Escape key listener
        $escapeKeyResult = (Eval-Script @"
        (function() {
            var toggle = document.getElementById('mobileNavToggle');
            var drawer = document.getElementById('mobileNavDrawer');

            // Open first
            toggle.click();
            var openBeforeEsc = drawer.classList.contains('open');

            // Dispatch Escape key
            var escEvent = new KeyboardEvent('keydown', { key: 'Escape', bubbles: true });
            document.dispatchEvent(escEvent);

            var closedAfterEsc = !drawer.classList.contains('open');

            return {
                openBeforeEsc: openBeforeEsc,
                closedAfterEsc: closedAfterEsc,
                ariaExpanded: toggle.getAttribute('aria-expanded')
            };
        })()
"@).Value

        Record-Result "JSInteractions" "DrawerCloseOnEscape" `
            ($escapeKeyResult.openBeforeEsc -and $escapeKeyResult.closedAfterEsc -and $escapeKeyResult.ariaExpanded -eq "false") `
            "Escape closes drawer: $($escapeKeyResult.closedAfterEsc), ariaExpanded: $($escapeKeyResult.ariaExpanded)"

        # ----------------------------------------------------------------------
        # TEST 4.6: Alert Banner Dismissal
        # ----------------------------------------------------------------------
        $alertDismissResult = (Eval-Script @"
        (function() {
            var container = document.querySelector('.notion-alerts-container') || document.body;
            var alertDiv = document.createElement('div');
            alertDiv.className = 'alert alert-info test-alert';
            alertDiv.innerHTML = '<div class=\"alert-content\">Test Flash Message</div><button type=\"button\" class=\"alert-close\" aria-label=\"Dismiss\"><svg><line x1=\"18\" y1=\"6\" x2=\"6\" y2=\"18\"></line></svg></button>';
            container.appendChild(alertDiv);

            var closeBtn = alertDiv.querySelector('.alert-close');
            closeBtn.click();

            var initialOpacity = alertDiv.style.opacity;

            return new Promise(function(resolve) {
                setTimeout(function() {
                    var inDoc = document.body.contains(alertDiv);
                    resolve({
                        initialOpacity: initialOpacity,
                        removedAfterTimeout: !inDoc
                    });
                }, 250);
            });
        })()
"@).Value

        Record-Result "JSInteractions" "AlertDismissal" `
            ($alertDismissResult.removedAfterTimeout -and $alertDismissResult.initialOpacity -eq "0") `
            "Alert faded (opacity: $($alertDismissResult.initialOpacity)) and removed from DOM: $($alertDismissResult.removedAfterTimeout)"

        # ----------------------------------------------------------------------
        # TEST 4.7: Modal Dialog Helpers (ViewModelDemoModal)
        # ----------------------------------------------------------------------
        $modalTestResult = (Eval-Script @"
        (function() {
            var modalId = 'adversarialTestModal';
            var modalOverlay = document.createElement('div');
            modalOverlay.id = modalId;
            modalOverlay.className = 'notion-modal-overlay';
            modalOverlay.setAttribute('aria-hidden', 'true');
            modalOverlay.innerHTML = '<div class=\"notion-modal-dialog\"><div class=\"notion-modal-header\"><h4 class=\"notion-modal-title\">Test Modal</h4></div><div class=\"notion-modal-body\"><button id=\"testModalFocusBtn\">Focusable</button><button data-modal-close>Close</button></div></div>';
            document.body.appendChild(modalOverlay);

            window.ViewModelDemoModal.open(modalId);
            var activeAfterOpen = modalOverlay.classList.contains('active');
            var ariaAfterOpen = modalOverlay.getAttribute('aria-hidden');
            var activeElementId = document.activeElement ? document.activeElement.id : '';
            var overflowAfterOpen = document.body.style.overflow;

            // Trigger close via Escape key
            var escEvent = new KeyboardEvent('keydown', { key: 'Escape', bubbles: true });
            document.dispatchEvent(escEvent);

            var inactiveAfterEsc = !modalOverlay.classList.contains('active');
            var ariaAfterEsc = modalOverlay.getAttribute('aria-hidden');
            var overflowAfterEsc = document.body.style.overflow;

            // Clean up
            modalOverlay.parentNode.removeChild(modalOverlay);

            return {
                activeAfterOpen: activeAfterOpen,
                ariaAfterOpen: ariaAfterOpen,
                focusedInput: activeElementId,
                overflowAfterOpen: overflowAfterOpen,
                inactiveAfterEsc: inactiveAfterEsc,
                ariaAfterEsc: ariaAfterEsc,
                overflowAfterEsc: overflowAfterEsc
            };
        })()
"@).Value

        Record-Result "JSInteractions" "ModalOpenAndFocus" `
            ($modalTestResult.activeAfterOpen -and $modalTestResult.ariaAfterOpen -eq "false" -and $modalTestResult.focusedInput -eq "testModalFocusBtn" -and $modalTestResult.overflowAfterOpen -eq "hidden") `
            "Modal active: $($modalTestResult.activeAfterOpen), focused button: $($modalTestResult.focusedInput), body.overflow: $($modalTestResult.overflowAfterOpen)"

        Record-Result "JSInteractions" "ModalEscapeClose" `
            ($modalTestResult.inactiveAfterEsc -and $modalTestResult.ariaAfterEsc -eq "true" -and $modalTestResult.overflowAfterEsc -eq "") `
            "Modal closed on Escape: $($modalTestResult.inactiveAfterEsc), aria-hidden: $($modalTestResult.ariaAfterEsc)"

        # ----------------------------------------------------------------------
        # TEST 4.9: Breakpoint Boundary (769px) Nav Overflow Check
        # ----------------------------------------------------------------------
        Invoke-Cdp -Method "Emulation.setDeviceMetricsOverride" -Params @{
            width = 769
            height = 1024
            deviceScaleFactor = 1
            mobile = $false
        } | Out-Null
        Start-Sleep -Milliseconds 300

        $boundaryNavCheck = (Eval-Script @"
        (function() {
            var nav = document.querySelector('.nav-container');
            return {
                navScrollWidth: nav.scrollWidth,
                navClientWidth: nav.clientWidth,
                navOverflows: nav.scrollWidth > nav.clientWidth,
                bodyScrollWidth: document.body.scrollWidth,
                bodyClientWidth: document.body.clientWidth,
                bodyOverflows: document.body.scrollWidth > document.body.clientWidth
            };
        })()
"@).Value

        Record-Result "BreakpointBoundary" "NavOverflowAt769px" (-not $boundaryNavCheck.navOverflows) `
            "At 769px: navScrollWidth=$($boundaryNavCheck.navScrollWidth)px, navClientWidth=$($boundaryNavCheck.navClientWidth)px (overflows: $($boundaryNavCheck.navOverflows))"

        # ----------------------------------------------------------------------
        # TEST 4.10: Mobile Drawer Resize Leak (Body Overflow Lock)
        # ----------------------------------------------------------------------
        # Switch to mobile, open drawer
        Invoke-Cdp -Method "Emulation.setDeviceMetricsOverride" -Params @{
            width = 375
            height = 667
            deviceScaleFactor = 2
            mobile = $true
        } | Out-Null
        Start-Sleep -Milliseconds 200

        Eval-Script "document.getElementById('mobileNavDrawer').classList.add('open'); document.body.style.overflow = 'hidden';" | Out-Null

        # Now resize to desktop (1280px) without manually closing
        Invoke-Cdp -Method "Emulation.setDeviceMetricsOverride" -Params @{
            width = 1280
            height = 800
            deviceScaleFactor = 1
            mobile = $false
        } | Out-Null
        Start-Sleep -Milliseconds 200

        $resizeCheck = (Eval-Script @"
        (function() {
            return {
                bodyOverflow: document.body.style.overflow,
                drawerDisplay: window.getComputedStyle(document.getElementById('mobileNavDrawer')).display
            };
        })()
"@).Value

        Record-Result "ResponsiveEdgeCase" "BodyOverflowClearedOnResize" ($resizeCheck.bodyOverflow -eq "") `
            "After resizing mobile -> desktop with drawer open: body.style.overflow='$($resizeCheck.bodyOverflow)' (expected: '')"

        # Clean up
        Eval-Script "document.getElementById('mobileNavDrawer').classList.remove('open'); document.body.style.overflow = '';" | Out-Null

        $ws.CloseAsync([System.Net.WebSockets.WebSocketCloseStatus]::NormalClosure, "Done", [System.Threading.CancellationToken]::None).Wait()
    }
} finally {
    if ($chromeProc -and -not $chromeProc.HasExited) {
        $chromeProc.Kill()
        $chromeProc.WaitForExit(3000)
    }
}

Write-Host "`n======================================================================"
Write-Host "SUMMARY OF EMPIRICAL TEST HARNESS RESULTS"
Write-Host "======================================================================"

$passCount = ($results | Where-Object { $_.Passed }).Count
$failCount = ($results | Where-Object { -not $_.Passed }).Count
$totalCount = $results.Count

Write-Host "Total Tests: $totalCount"
Write-Host "Passed:      $passCount"
Write-Host "Failed:      $failCount"

if ($failCount -gt 0) {
    Write-Host "`nFAILED TESTS DETAILS:"
    $results | Where-Object { -not $_.Passed } | ForEach-Object {
        Write-Host "[$($_.Category)] $($_.Name) - $($_.Details)"
    }
}
