# Technical Analysis: Empirical Test Harness Investigation (TestChallengerM1.ps1)

**Investigator**: explorer_m1_fix_3  
**Target File**: `D:\.NET\ViewModelDemo\Tests\E2E\TestChallengerM1.ps1`  
**Execution Target**: `http://localhost:9979/Employee/Index`  
**Timestamp**: 2026-10-29T13:54:00Z  
**Status**: Completed  

---

## 1. Executive Summary

An investigation was conducted on the automated E2E challenger test harness `D:\.NET\ViewModelDemo\Tests\E2E\TestChallengerM1.ps1`. The harness evaluates 32 distinct assertions across static file validation, CSS design tokens, headless Chrome DevTools Protocol (CDP) viewport rendering, adversarial click hit-testing, and client JavaScript lifecycle states.

Direct execution of the test harness against the active IIS Express instance produced:
- **Total Tests**: 32
- **Passed**: 26
- **Failed**: 6
- **Success Rate**: 81.25%

While the previous challenger report highlighted two defect groups (AdversarialHitTest and ResponsiveEdgeCase), the empirical run reveals **six specific assertion failures across three distinct root causes**. If an implementation worker only addresses the overlay and the resize leak, the test suite will remain in a failing state due to an unaddressed flex blockification issue on `#mobileNavToggle`.

---

## 2. Architecture of TestChallengerM1.ps1

The test script is written in PowerShell 5.1/7+ with strict error handling (`Set-StrictMode -Version Latest`, `$ErrorActionPreference = "Stop"`).

### 2.1 Execution Mechanics
1. **Static Regex Suite**: Inspects local files for zero emoji conformance and required CSS rules.
2. **Headless Chrome CDP Host**:
   - Launches Chrome or Edge in headless mode with flags `--headless=new --remote-debugging-port=9223 --disable-gpu --window-size=1280,800`.
   - Queries `http://localhost:9223/json` to discover the WebSocket debugger target for `http://localhost:9979/Employee/Index`.
   - Connects via .NET `ClientWebSocket` (`System.Net.WebSockets.ClientWebSocket`).
   - Sends commands via CDP JSON payloads and parses asynchronous responses.
3. **Viewport Emulation**: Calls `Emulation.setDeviceMetricsOverride` to simulate:
   - Desktop: 1280 x 800 (`mobile = $false`)
   - Tablet: 800 x 1024 (`mobile = $false`)
   - Mobile: 375 x 667 (`mobile = $true`, `deviceScaleFactor = 2`)
   - Breakpoint Boundary: 769 x 1024 (`mobile = $false`)
4. **Adversarial Input Dispatch**: Dispatches real OS-level mouse events via `Input.dispatchMouseEvent` (`mousePressed` and `mouseReleased`) targeting the computed center of `#mobileNavToggle`.
5. **DOM Hit-Testing**: Executes `document.elementFromPoint(x, y)` to determine whether underlying buttons or inputs receive user interaction or are blocked by overlying layers.

---

## 3. Inventory of All 32 Tests

| # | Suite | Test Name | Target / Query | Expected | Current Status |
|---|---|---|---|---|---|
| 1 | ZeroEmoji | Scan site.css | Regex UTF-8 emoji pattern | Clean (No match) | PASS |
| 2 | ZeroEmoji | Scan app.js | Regex UTF-8 emoji pattern | Clean (No match) | PASS |
| 3 | ZeroEmoji | Scan _Layout.cshtml | Regex UTF-8 emoji pattern | Clean (No match) | PASS |
| 4 | ZeroEmoji | Scan _Navigation.cshtml | Regex UTF-8 emoji pattern | Clean (No match) | PASS |
| 5 | ReducedMotion | MediaQueryExists | `@media (prefers-reduced-motion: reduce)` | Matched | PASS |
| 6 | ReducedMotion | UniversalTargeting | `*, *::before, *::after` inside media query | Matched | PASS |
| 7 | ReducedMotion | AnimationDurationReset | `animation-duration: 0.01ms !important` | Matched | PASS |
| 8 | ReducedMotion | TransitionDurationReset | `transition-duration: 0.01ms !important` | Matched | PASS |
| 9 | ReducedMotion | ScrollBehaviorReset | `scroll-behavior: auto !important` | Matched | PASS |
| 10 | CSSRules | TabletBreakpoint | `@media (max-width: 1024px)` | Matched | PASS |
| 11 | CSSRules | MobileBreakpoint | `@media (max-width: 768px)` | Matched | PASS |
| 12 | CSSRules | FormRowMobileRule | `.form-row ... grid-template-columns: 1fr` | Matched | PASS |
| 13 | CSSRules | TableScrollContainerRule | `.notion-table-container ... overflow-x: auto` | Matched | PASS |
| 14 | Browser | ChromeLaunch | Chrome CDP WebSocket attached | Connected | PASS |
| 15 | DesktopLayout | NavMenuVisible | `.nav-menu` computed display at 1280px | `flex` | PASS |
| 16 | DesktopLayout | NavToggleHidden | `#mobileNavToggle` computed display at 1280px | `none` | PASS |
| 17 | TabletLayout | NavMenuVisible | `.nav-menu` computed display at 800px | `flex` | PASS |
| 18 | TabletLayout | NavToggleHidden | `#mobileNavToggle` computed display at 800px | `none` | PASS |
| 19 | MobileLayout | NavMenuHidden | `.nav-menu` computed display at 375px | `none` | PASS |
| 20 | MobileLayout | NavToggleVisible | `#mobileNavToggle` computed display at 375px | `inline-flex` | FAIL |
| 21 | AdversarialHitTest | MobileOverlayDisplay | `#mobileNavOverlay` display and pointer-events | `display == none` OR `pointer-events == none` | FAIL |
| 22 | AdversarialHitTest | ToggleReachableByClick | `document.elementFromPoint(centerX, centerY)` on toggle | `topElement === toggle` | FAIL |
| 23 | AdversarialHitTest | UserClickOpensDrawer | `Input.dispatchMouseEvent` at toggle center | `drawer.classList.contains('open') == true` | FAIL |
| 24 | AdversarialHitTest | MainContentClickable | `document.elementFromPoint(cx, cy)` on search input | Top element != `#mobileNavOverlay` | FAIL |
| 25 | JSInteractions | DrawerOpenOnClick | Script `toggle.click()` | `drawer.open`, `overlay.open`, `aria-expanded=true`, `overflow=hidden` | PASS |
| 26 | JSInteractions | DrawerCloseOnButton | Script `closeBtn.click()` | `!drawer.open`, `!overlay.open`, `aria-expanded=false`, `overflow=""` | PASS |
| 27 | JSInteractions | DrawerCloseOnEscape | Escape key event on document | `!drawer.open`, `aria-expanded=false` | PASS |
| 28 | JSInteractions | AlertDismissal | Script click on `.alert-close` | Element faded (`opacity: 0`) and removed from DOM | PASS |
| 29 | JSInteractions | ModalOpenAndFocus | `ViewModelDemoModal.open(modalId)` | `modal.active`, `aria-hidden=false`, focus trapped, `overflow=hidden` | PASS |
| 30 | JSInteractions | ModalEscapeClose | Escape key event on document | `!modal.active`, `aria-hidden=true`, `overflow=""` | PASS |
| 31 | BreakpointBoundary | NavOverflowAt769px | `.nav-container` `scrollWidth > clientWidth` at 769px | `False` (no overflow) | PASS |
| 32 | ResponsiveEdgeCase | BodyOverflowClearedOnResize | Mobile drawer open, viewport resized to 1280px | `document.body.style.overflow == ""` | FAIL |

---

## 4. Deep-Dive: The 6 Failing Tests & Root Causes

### Defect Area 1: Invisible Overlay Pointer Event Interception (4 Failures)
- **Failing Tests**:
  - `AdversarialHitTest :: MobileOverlayDisplay` (line 280)
  - `AdversarialHitTest :: ToggleReachableByClick` (line 283)
  - `AdversarialHitTest :: UserClickOpensDrawer` (line 322)
  - `AdversarialHitTest :: MainContentClickable` (line 342)
- **Code Location**:
  - `D:\.NET\ViewModelDemo\Content\site.css`: Lines 422-433 and Lines 1245-1247
- **Observed Behavior**:
  ```css
  /* site.css:422 */
  .nav-drawer-overlay {
      display: none;
      position: fixed;
      top: 0;
      left: 0;
      width: 100vw;
      height: 100vh;
      background-color: rgba(15, 15, 15, 0.4);
      z-index: 999;
      opacity: 0;
      transition: opacity var(--transition-base);
  }

  /* site.css:1245 */
  @media (max-width: 768px) {
      ...
      .nav-drawer-overlay {
          display: block;
      }
  }
  ```
- **Root Cause Logic Chain**:
  1. Under mobile viewports (`max-width: 768px`), `.nav-drawer-overlay` is unconditionally assigned `display: block`.
  2. Because the base style does not define `pointer-events: none`, pointer events default to `auto`.
  3. The overlay has `position: fixed`, `width: 100vw`, `height: 100vh`, and `z-index: 999`.
  4. The top navigation header `.top-nav` has `z-index: 900`.
  5. The overlay layer rests physically above the top header and above the main page content, covering all 375x667 pixels.
  6. Although visually transparent (`opacity: 0`), it intercepts all mouse and touch events.
  7. When CDP hit-tests the hamburger toggle at (341, 29), `document.elementFromPoint` returns `<div id="mobileNavOverlay">`, causing `ToggleReachableByClick` to fail.
  8. When CDP sends `Input.dispatchMouseEvent` at (341, 29), the click targets `#mobileNavOverlay` instead of `#mobileNavToggle`. The click handler for the overlay executes `closeDrawer()`, which is a no-op when closed. The drawer never opens, causing `UserClickOpensDrawer` to fail.
  9. When CDP hit-tests the search input `input[name="search"]`, `document.elementFromPoint` returns `#mobileNavOverlay`, causing `MainContentClickable` to fail.
- **Pass Conditions**:
  - `overlayDisplay` must be `"none"` OR `overlayPointerEvents` must be `"none"` when the drawer is closed.
  - `document.elementFromPoint` at toggle coordinates must return `#mobileNavToggle` or one of its descendants.
  - Physical mouse click at toggle coordinates must open the drawer (`#mobileNavDrawer.open`).
  - Search input must not be blocked by `#mobileNavOverlay`.

---

### Defect Area 2: Mobile Toggle Computed Style Blockification (1 Failure)
- **Failing Test**:
  - `MobileLayout :: NavToggleVisible` (line 245)
- **Verbatim Error**:
  `[FAIL] MobileLayout :: NavToggleVisible - Mobile (375px) #mobileNavToggle display is: flex (expected: inline-flex)`
- **Code Location**:
  - `D:\.NET\ViewModelDemo\Content\site.css`: Line 245 and Line 1239
- **Observed Behavior**:
  ```css
  /* site.css:245 */
  .nav-right {
      display: flex;
      align-items: center;
      gap: 10px;
  }

  /* site.css:1239 */
  @media (max-width: 768px) {
      .nav-mobile-toggle {
          display: inline-flex;
      }
  }
  ```
- **Root Cause Logic Chain**:
  1. In `_Navigation.cshtml`, `#mobileNavToggle` is a child element of `<div class="nav-right">`.
  2. In `site.css:245`, `.nav-right` is defined with `display: flex;`.
  3. Under the CSS Flexible Box Layout Module specification (Section 4: Flex Items), the `display` value of any direct child of a flex container is blockified:
     - `inline`, `inline-block` -> `block`
     - `inline-flex` -> `flex`
     - `inline-grid` -> `grid`
  4. Even though `.nav-mobile-toggle` explicitly declares `display: inline-flex;`, the browser's computed style engine blockifies it to `flex` because its parent `.nav-right` is a flex container.
  5. `TestChallengerM1.ps1` line 245 evaluates:
     `$mobileToggleDisplay = (Eval-Script "window.getComputedStyle(document.getElementById('mobileNavToggle')).display").Value`
     and strictly asserts:
     `$mobileToggleDisplay -eq "inline-flex"`
  6. Because `$mobileToggleDisplay` evaluates to `"flex"`, the assertion fails.
- **Pass Conditions**:
  - `window.getComputedStyle(document.getElementById('mobileNavToggle')).display` must evaluate to `"inline-flex"`.
  - To prevent blockification, `.nav-right` under `@media (max-width: 768px)` must not be a flex container. Setting `.nav-right { display: block; }` on mobile ensures that `.nav-right` (a flex child of `.nav-container`) is blockified to `block`, while its child `#mobileNavToggle` remains an un-blockified `inline-flex` element inside a standard block container.

---

### Defect Area 3: Viewport Resize Body Overflow Leak (1 Failure)
- **Failing Test**:
  - `ResponsiveEdgeCase :: BodyOverflowClearedOnResize` (line 565)
- **Verbatim Error**:
  `[FAIL] ResponsiveEdgeCase :: BodyOverflowClearedOnResize - After resizing mobile -> desktop with drawer open: body.style.overflow='hidden' (expected: '')`
- **Code Location**:
  - `D:\.NET\ViewModelDemo\Scripts\app.js`: Lines 14-63
- **Observed Behavior**:
  ```javascript
  /* Scripts/app.js:24 */
  function openDrawer() {
      drawer.classList.add("open");
      overlay.classList.add("open");
      toggleBtn.setAttribute("aria-expanded", "true");
      document.body.style.overflow = "hidden";
  }
  ```
  `Scripts/app.js` lacks any `window.addEventListener("resize", ...)` or `window.matchMedia` change handler.
- **Root Cause Logic Chain**:
  1. In `TestChallengerM1.ps1` lines 537-545, the test emulates mobile viewport (375x667), simulates an open drawer, and sets `document.body.style.overflow = 'hidden'`.
  2. In lines 548-554, the test emulates window resize to desktop (1280x800) and waits 200 milliseconds.
  3. Because there is no resize listener in `app.js` to detect that the viewport has transitioned past the 768px breakpoint, `closeDrawer()` is never triggered.
  4. The drawer is hidden by CSS media query (`@media (max-width: 768px)`), but `document.body.style.overflow` remains locked at `'hidden'`.
  5. Line 565 checks:
     `Record-Result "ResponsiveEdgeCase" "BodyOverflowClearedOnResize" ($resizeCheck.bodyOverflow -eq "")`
     which fails because `bodyOverflow` is `'hidden'`.
- **Timing Constraint**:
  - Line 554 in the test script sleeps for only **200 milliseconds** (`Start-Sleep -Milliseconds 200`) before evaluating `document.body.style.overflow`.
  - If a worker uses a debounced resize listener with a delay greater than ~100ms (e.g. 250ms or 300ms debounce), the assertion will execute BEFORE the debounced function runs, and the test will continue to FAIL.
  - The resize listener must execute immediately or with a near-zero throttle/debounce (<= 50ms).
- **Pass Conditions**:
  - Upon window resize where `window.innerWidth > 768`, if `drawer.classList.contains("open")` or if `body.style.overflow === "hidden"` (and no modal is open), `document.body.style.overflow` must be reset to `""` within 200ms.

---

## 5. Required Implementation Specifications

To achieve 100% test pass (32/32 Passed, 0 Failed), the implementation worker must apply the following precise modifications.

### 5.1 Modifications to `D:\.NET\ViewModelDemo\Content\site.css`

#### Change 1: Configure `.nav-drawer-overlay` with `pointer-events: none` and state-scoped activation
- **Current Lines 422-437**:
  ```css
  .nav-drawer-overlay {
      display: none;
      position: fixed;
      top: 0;
      left: 0;
      width: 100vw;
      height: 100vh;
      background-color: rgba(15, 15, 15, 0.4);
      z-index: 999;
      opacity: 0;
      transition: opacity var(--transition-base);
  }

  .nav-drawer-overlay.open {
      opacity: 1;
  }
  ```
- **Replacement Specification**:
  ```css
  .nav-drawer-overlay {
      display: none;
      position: fixed;
      top: 0;
      left: 0;
      width: 100vw;
      height: 100vh;
      background-color: rgba(15, 15, 15, 0.4);
      z-index: 999;
      opacity: 0;
      pointer-events: none;
      transition: opacity var(--transition-base);
  }

  .nav-drawer-overlay.open {
      display: block;
      opacity: 1;
      pointer-events: auto;
  }
  ```

#### Change 2: Remove unconditional overlay display and set `.nav-right { display: block; }` on mobile
- **Current Lines 1232-1248**:
  ```css
  @media (max-width: 768px) {
      .nav-menu {
          display: none;
      }
      .nav-right .btn {
          display: none;
      }
      .nav-mobile-toggle {
          display: inline-flex;
      }
      .nav-drawer {
          display: flex;
      }
      .nav-drawer-overlay {
          display: block;
      }
  ```
- **Replacement Specification**:
  ```css
  @media (max-width: 768px) {
      .nav-menu {
          display: none;
      }
      .nav-right {
          display: block;
      }
      .nav-right .btn {
          display: none;
      }
      .nav-mobile-toggle {
          display: inline-flex;
      }
      .nav-drawer {
          display: flex;
      }
  ```
  *(Note: `.nav-drawer-overlay { display: block; }` is removed entirely from `@media (max-width: 768px)` because display is controlled by `.nav-drawer-overlay.open`)*.

---

### 5.2 Modifications to `D:\.NET\ViewModelDemo\Scripts\app.js`

#### Change 3: Add Window Resize Event Listener in `initMobileNav()`
Inside `function initMobileNav()`, after the Escape key listener (around line 63):
```javascript
        // Reset body overflow and drawer state on desktop resize
        window.addEventListener("resize", function () {
            if (window.innerWidth > 768) {
                if (drawer.classList.contains("open")) {
                    closeDrawer();
                } else if (document.body.style.overflow === "hidden" && !document.querySelector(".notion-modal-overlay.active")) {
                    document.body.style.overflow = "";
                }
            }
        });
```
- **Critical Requirement**: Do NOT add a debounce > 50ms. The test executes after a 200ms delay. Executing the handler directly without debounce guarantees synchronous or near-instantaneous reset within the 200ms window.

---

## 6. Implementation Worker Verification Checklist

| Item | Requirement | Verification Method |
|---|---|---|
| C1 | `Content/site.css` line 422 has `pointer-events: none;` on `.nav-drawer-overlay` | Text inspection / regex |
| C2 | `Content/site.css` line 435 has `.nav-drawer-overlay.open { display: block; opacity: 1; pointer-events: auto; }` | Text inspection / regex |
| C3 | `Content/site.css` line 1245 no longer contains unconditional `.nav-drawer-overlay { display: block; }` | Text inspection / regex |
| C4 | `Content/site.css` `@media (max-width: 768px)` defines `.nav-right { display: block; }` | Text inspection / regex |
| C5 | `Scripts/app.js` contains a `window.addEventListener("resize", ...)` listener resetting drawer and body overflow when `window.innerWidth > 768` | Text inspection / regex |
| C6 | Strict zero emojis: no emojis introduced into `site.css` or `app.js` | Suite 1 regex in `TestChallengerM1.ps1` |
| C7 | Test execution produces 32 passed, 0 failed | `powershell -NoProfile -ExecutionPolicy Bypass -File "D:\.NET\ViewModelDemo\Tests\E2E\TestChallengerM1.ps1"` |

---

## 7. Reviewer Verification Procedure

1. Verify that neither `TestChallengerM1.ps1` nor backend files (`.cs`, `.csproj`, `Web.config`) were altered.
2. Verify that IIS Express is active on port 9979.
3. Run:
   ```powershell
   powershell -NoProfile -ExecutionPolicy Bypass -File "D:\.NET\ViewModelDemo\Tests\E2E\TestChallengerM1.ps1"
   ```
4. Confirm summary output matches:
   ```
   Total Tests: 32
   Passed:      32
   Failed:      0
   ```
