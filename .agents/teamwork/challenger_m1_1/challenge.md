# Adversarial Challenge Report: Milestone 1 (Shared Design System & Layout Shell)

**Agent**: challenger_m1_1  
**Timestamp**: 2026-10-29T13:48:00Z  
**Target Solution**: D:\.NET\ViewModelDemo  
**Overall Risk Assessment**: CRITICAL  
**Verdict**: REJECT  

---

## Challenge Summary

During adversarial stress-testing of Milestone 1 (Shared Design System & Layout Shell), an empirical test harness (`TestChallengerM1.ps1`) using headless Chrome DevTools Protocol (CDP) and DOM hit-testing was executed against the running IIS Express instance (port 9979).

While desktop layouts, tablet navigation, alert dismissal, modal dialog helpers, prefers-reduced-motion, and strict zero-emoji requirements passed verification, a **CRITICAL flaw** was empirically discovered in the responsive mobile CSS rules:
On any screen width <= 768px, `#mobileNavOverlay` is given unconditional `display: block` with `z-index: 999` and default `pointer-events: auto`. This creates an invisible 100vw x 100vh layer that blocks ALL user touch and pointer clicks across the entire application — including the hamburger toggle button itself and all main page content.

Additionally, a **MEDIUM flaw** was found where opening the mobile drawer locks `body.style.overflow = "hidden"` with no resize listener to clean up state if the user rotates or resizes their viewport.

---

## Challenges

### [Critical] Challenge 1: Invisible `#mobileNavOverlay` intercepts all pointer events on mobile (<768px), preventing hamburger menu from opening and bricking all page interactions

- **Assumption Challenged**:  
  The worker assumed that setting `.nav-drawer-overlay { display: block; }` inside `@media (max-width: 768px)` while `opacity: 0` allows CSS opacity transitions without interfering with normal page interactions.
- **Attack Scenario / Empirical Reproduction**:
  1. Configure browser viewport to mobile dimensions (width: 375px, height: 667px).
  2. Inspect computed styles and DOM hit-testing at the coordinates of `#mobileNavToggle` (e.g. x: 341, y: 29):
     - `getComputedStyle(overlay).display` = `"block"`
     - `getComputedStyle(overlay).pointerEvents` = `"auto"` (CSS default)
     - `getComputedStyle(overlay).zIndex` = `"999"`
     - `getComputedStyle(overlay).opacity` = `"0"`
     - `getComputedStyle(toggle).zIndex` = `"auto"` (inside `.top-nav` with `z-index: 900`)
  3. Query `document.elementFromPoint(341, 29)`:
     - Expected: `<button id="mobileNavToggle" ...>`
     - Actual: `<div id="mobileNavOverlay" class="nav-drawer-overlay">`
  4. Dispatch a real user mouse click (`Input.dispatchMouseEvent` via CDP) at the hamburger coordinates:
     - The click is intercepted by `#mobileNavOverlay`.
     - `#mobileNavOverlay`'s click listener in `app.js` runs `closeDrawer()` (a no-op when already closed).
     - The click never reaches `#mobileNavToggle`.
     - Result: `drawer.classList.contains("open")` remains `false`. The drawer CANNOT BE OPENED by a user.
  5. Query `document.elementFromPoint` at any other page element (e.g., search input, table links):
     - All return `<div id="mobileNavOverlay">`. The user cannot interact with ANY form, link, or button on mobile.
- **Blast Radius**:
  100% of mobile users (< 768px) cannot use navigation or interact with any page controls.
- **Root Cause File & Line**:
  `D:\.NET\ViewModelDemo\Content\site.css`:
  - Line 422-433:
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
    ```
  - Line 1245-1247:
    ```css
    @media (max-width: 768px) {
        ...
        .nav-drawer-overlay {
            display: block;
        }
    ```
- **Proposed Mitigation**:
  Either:
  1. Remove `.nav-drawer-overlay { display: block; }` from `@media (max-width: 768px)` and display it only when `.open`:
     ```css
     .nav-drawer-overlay {
         display: none;
         pointer-events: none;
         opacity: 0;
     }
     .nav-drawer-overlay.open {
         display: block;
         pointer-events: auto;
         opacity: 1;
     }
     ```
  2. OR keep `pointer-events: none;` on `.nav-drawer-overlay` by default and enable `pointer-events: auto;` only on `.nav-drawer-overlay.open`:
     ```css
     .nav-drawer-overlay {
         pointer-events: none;
     }
     .nav-drawer-overlay.open {
         pointer-events: auto;
         opacity: 1;
     }
     ```

---

### [Medium] Challenge 2: Mobile drawer opens with `body.style.overflow = "hidden"` which leaks on orientation change or viewport resize

- **Assumption Challenged**:  
  The worker assumed mobile drawer closure is always explicitly triggered via close button, overlay tap, or Escape key.
- **Attack Scenario / Empirical Reproduction**:
  1. Open mobile drawer on mobile viewport (375x667). `openDrawer()` in `app.js` executes `document.body.style.overflow = "hidden"`.
  2. Rotate device or resize viewport to desktop (>768px, e.g. 1280x800).
  3. Media query `@media (max-width: 768px)` no longer applies, hiding drawer via CSS (`display: none`).
  4. However, `document.body.style.overflow` remains `"hidden"`.
  5. The desktop page is now permanently locked and cannot be scrolled vertically.
- **Blast Radius**:
  Users switching orientations on mobile/tablet devices or resizing desktop windows.
- **Root Cause File & Line**:
  `D:\.NET\ViewModelDemo\Scripts\app.js`: Missing resize event listener to reset body overflow when width exceeds 768px.
- **Proposed Mitigation**:
  In `Scripts/app.js`:
  ```javascript
  window.addEventListener("resize", function () {
      if (window.innerWidth > 768 && drawer && drawer.classList.contains("open")) {
          closeDrawer();
      }
  });
  ```

---

## Stress Test Results

| Test ID | Scenario | Expected Behavior | Actual Behavior | Result |
|---------|----------|-------------------|-----------------|--------|
| T01 | Strict Zero Emoji Scan across 4 files | No emojis or surrogate pairs detected | Clean (0 emojis found) | PASS |
| T02 | Reduced Motion Media Query (`site.css`) | Resets animation and transition durations to 0.01ms | Resets durations to 0.01ms !important, scroll-behavior auto | PASS |
| T03 | Breakpoints CSS rules | 1024px tablet & 768px mobile breakpoints defined | Defined in site.css lines 1218 & 1232 | PASS |
| T04 | Desktop Layout (>1024px) | `.nav-menu` visible (`flex`), `#mobileNavToggle` hidden (`none`) | display: flex and none | PASS |
| T05 | Tablet Layout (800px) | `.nav-menu` visible (`flex`), `#mobileNavToggle` hidden (`none`) | display: flex and none | PASS |
| T06 | Breakpoint Boundary (769px) | No horizontal nav clipping or overflow | navScrollWidth = 754px, clientWidth = 754px | PASS |
| T07 | Mobile Layout (<768px) NavMenu | `.nav-menu` hidden (`none`) | display: none | PASS |
| T08 | Mobile Overlay Display & Pointer Events | Overlay inactive (`display: none` or `pointer-events: none`) | `display: block`, `pointer-events: auto` at z-index 999 | **FAIL** |
| T09 | Mobile Hamburger Hit-Testing | `document.elementFromPoint` at toggle returns toggle button | Returns `<div id="mobileNavOverlay">` | **FAIL** |
| T10 | Mobile Hamburger User Click | Synthetic mouse click at toggle opens drawer | Click intercepted by overlay; drawer remains closed | **FAIL** |
| T11 | Mobile Main Content Hit-Testing | `document.elementFromPoint` on input returns input element | Returns `<div id="mobileNavOverlay">` | **FAIL** |
| T12 | JS Drawer Toggle (direct call) | `openDrawer()` sets open, aria-expanded=true, body overflow=hidden | All attributes set correctly | PASS |
| T13 | JS Drawer Close Button | `closeBtn.click()` removes open, aria-expanded=false, clears body overflow | All attributes reset correctly | PASS |
| T14 | JS Drawer Escape Key | Pressing Escape key closes open drawer | Drawer closed, aria-expanded=false | PASS |
| T15 | Alert Banner Dismissal | Clicking `.alert-close` fades out and removes alert from DOM | Opacity set to 0, removed within 150ms | PASS |
| T16 | Modal Dialog Helper | `ViewModelDemoModal.open` sets active, aria-hidden=false, traps focus | Active, aria-hidden=false, focused button | PASS |
| T17 | Modal Dialog Escape Key | Pressing Escape closes active modal | Active removed, aria-hidden=true | PASS |
| T18 | Mobile Drawer Resize Edge Case | Resizing mobile -> desktop with open drawer clears body overflow lock | `body.style.overflow` remains `'hidden'` | **FAIL** |

---

## Unchallenged Areas

- Individual feature views (`Account/Login`, `Account/Register`, `Admin/Dashboard`, `Admin/Users`, `Employee/Details`, `Student/getStud`) were not evaluated for page-specific semantics because they are scoped to downstream milestones (M2 and M3).
