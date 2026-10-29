# Technical Analysis: Mobile Drawer Overlay Bug & CSS Stacking Audit

**Date**: 2026-10-29  
**Investigator**: explorer_m1_fix_1  
**Target Milestone**: Milestone 1 Remediation (Shared Design System & Layout Shell)  
**Primary Artifact**: `D:\.NET\ViewModelDemo\Content\site.css`  
**Secondary Artifact**: `D:\.NET\ViewModelDemo\Scripts\app.js`  
**Reference Test Harness**: `D:\.NET\ViewModelDemo\Tests\E2E\TestChallengerM1.ps1`  

---

## 1. Executive Summary

Milestone 1 verification by `challenger_m1_1` identified a blocking defect in mobile navigation: when viewed on screens <= 768px wide, physical user clicks or taps on the mobile hamburger toggle (`#mobileNavToggle`) or any page controls are intercepted and absorbed by an invisible overlay (`#mobileNavOverlay`). This prevents the navigation drawer from ever opening.

Our investigation traced this bug directly to `site.css` line 1245 under `@media (max-width: 768px)`, where `.nav-drawer-overlay` is unconditionally assigned `display: block;`. Because the base overlay has `position: fixed; width: 100vw; height: 100vh; z-index: 999; opacity: 0;` and default `pointer-events: auto;`, it covers the entire mobile viewport above the sticky header `.top-nav` (`z-index: 900`). The invisible layer drops all user clicks.

This document details the exact CSS fix to make `.nav-drawer-overlay` completely inert to pointer events when closed (`pointer-events: none; display: none;`), ensuring it only becomes visible and clickable when explicitly assigned the `.open` class. Additionally, this analysis provides an audit of all stacking contexts in `site.css` and outlines the companion fix in `app.js` to address the mobile drawer resize overflow leak.

---

## 2. Examination of CSS Component Definitions

### 2.1 `.top-nav` (Lines 161-171)
```css
.top-nav {
    background-color: var(--surface-card);
    border-bottom: 1px solid var(--border-color);
    position: sticky;
    top: 0;
    z-index: 900;
    height: var(--nav-height);
    display: flex;
    align-items: center;
    box-shadow: var(--shadow-subtle);
}
```
- **Positioning**: `position: sticky; top: 0;`
- **Stacking Level**: `z-index: 900;`
- **Descendants**: Contains `#mobileNavToggle` (`.nav-mobile-toggle`), which inherits the `z-index: 900` stacking context.
- **Role**: Keeps header navigation fixed at the top of the viewport during scrolling.

### 2.2 `.nav-drawer-overlay` (Lines 422-437)
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
- **Positioning**: `position: fixed; top: 0; left: 0; width: 100vw; height: 100vh;`
- **Stacking Level**: `z-index: 999;`
- **Flaw**: Does not specify `pointer-events: none;`. It defaults to `pointer-events: auto;`.

### 2.3 Mobile Breakpoint Override for Overlay (Lines 1245-1247)
```css
@media (max-width: 768px) {
    ...
    .nav-drawer-overlay {
        display: block;
    }
```
- **Flaw**: Overrides `display: none` to `display: block` unconditionally on all screens <= 768px, regardless of whether the drawer is open or closed.
- **Combined Effect**: On mobile, `#mobileNavOverlay` is `display: block`, `opacity: 0`, `z-index: 999`, and `pointer-events: auto`. It creates a 100vw x 100vh invisible pane above `.top-nav` (z-index 900), capturing all clicks before they can reach `#mobileNavToggle`.

### 2.4 `.nav-drawer` (Lines 336-356 and 1242-1244)
```css
.nav-drawer {
    display: none;
    position: fixed;
    top: 0;
    left: 0;
    width: 280px;
    height: 100vh;
    background-color: var(--surface-card);
    border-right: 1px solid var(--border-color);
    box-shadow: var(--shadow-modal);
    z-index: 1000;
    transform: translateX(-100%);
    transition: transform var(--transition-base);
    flex-direction: column;
    padding: 20px;
    overflow-y: auto;
}

.nav-drawer.open {
    transform: translateX(0);
}

@media (max-width: 768px) {
    .nav-drawer {
        display: flex;
    }
}
```
- **Positioning**: `position: fixed; top: 0; left: 0; z-index: 1000;`
- **Closed State**: `transform: translateX(-100%);` (parked off-screen at -280px). Because `html, body` has `overflow-x: hidden;`, it causes no scrollbars.
- **Open State**: `transform: translateX(0);` (slides into view).
- **Stacking Level**: `z-index: 1000` is strictly higher than `.nav-drawer-overlay` (`z-index: 999`). This allows user interactions inside the open drawer without overlay interference.

### 2.5 `.notion-modal-overlay` (Lines 1073-1090)
```css
.notion-modal-overlay {
    display: none;
    position: fixed;
    top: 0;
    left: 0;
    width: 100vw;
    height: 100vh;
    background-color: rgba(15, 15, 15, 0.45);
    backdrop-filter: blur(2px);
    z-index: 1000;
    align-items: center;
    justify-content: center;
    padding: 16px;
}

.notion-modal-overlay.active {
    display: flex;
}
```
- **Positioning**: `position: fixed; top: 0; left: 0; z-index: 1000;`
- **Closed State**: Correctly uses `display: none;`. It is completely absent from formatting and hit-testing when closed.
- **Active State**: Displays via `display: flex;` only when `.active` is added.
- **Stacking Level Consideration**: Currently shares `z-index: 1000` with `.nav-drawer`. Upgrading to `z-index: 1050` establishes a clean, conflict-free hierarchy.

---

## 3. Full Audit of Z-Index and Positioning Across `Content/site.css`

A complete scan of `Content/site.css` reveals exactly four positioned elements with `z-index`:

| Selector | Position | Z-Index | Current State | Potential Hazard | Recommended Action |
|---|---|---|---|---|---|
| `.top-nav` (line 166) | `sticky` | 900 | Sticky header | Covered by overlay on mobile | Keep 900; fix overlay pointer-events |
| `.nav-drawer-overlay` (line 430) | `fixed` | 999 | Backdrop | Blocks mobile viewport when closed | Add `pointer-events: none;`, remove unconditional mobile display |
| `.nav-drawer` (line 346) | `fixed` | 1000 | Slide drawer | Clean; slides offscreen | Retain 1000 |
| `.notion-modal-overlay` (line 1082) | `fixed` | 1000 | Modal backdrop | Tied with drawer z-index | Promote to `z-index: 1050` |

### Stacking Scale Hierarchy (Calibrated):
```
Level 0 (auto):  Standard flow content, cards, tables, footer
Level 900:       .top-nav (Sticky navigation bar)
Level 999:       .nav-drawer-overlay (Mobile drawer backdrop, pointer-events: auto only when .open)
Level 1000:      .nav-drawer (Mobile slide-out drawer panel)
Level 1050:      .notion-modal-overlay (Modal dialog backdrop and container)
```

No other elements in `site.css` declare `z-index`, `position: absolute`, or `position: relative`.

---

## 4. Root Cause of the Empirical Test Failure

In `TestChallengerM1.ps1`:
1. Under viewport 375x667, `document.elementFromPoint(centerX, centerY)` at the hamburger button coordinates (341, 29) returned `<div id="mobileNavOverlay" class="nav-drawer-overlay">`.
2. CDP command `Input.dispatchMouseEvent` sent a physical left click at (341, 29). The event target was `#mobileNavOverlay`.
3. In `Scripts/app.js` line 53:
   ```javascript
   overlay.addEventListener("click", function () {
       closeDrawer();
   });
   ```
   The overlay click listener called `closeDrawer()`, which performs no action if the drawer is already closed.
4. `#mobileNavToggle` never received the click event. The drawer remained closed (`drawerOpen=False, ariaExpanded=false`).
5. Similarly, hit-testing against the search input on the main page returned `#mobileNavOverlay`, proving the entire page was unclickable for mobile users.

---

## 5. Recommended Remediation

### 5.1 CSS Fix in `D:\.NET\ViewModelDemo\Content\site.css`

#### Edit 1: Configure Base Overlay with `pointer-events: none` and Scope Activation to `.open`
**Target**: `Content/site.css` lines 422-437

**Before**:
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

**After**:
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

#### Edit 2: Remove Unconditional Display Rule from Mobile Media Query
**Target**: `Content/site.css` lines 1245-1247

**Before**:
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

    .form-row {
```

**After**:
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

    .form-row {
```

#### Edit 3 (Stacking Order Enhancement): Promote Modal Overlay Z-Index
**Target**: `Content/site.css` line 1082

**Before**:
```css
.notion-modal-overlay {
    display: none;
    position: fixed;
    top: 0;
    left: 0;
    width: 100vw;
    height: 100vh;
    background-color: rgba(15, 15, 15, 0.45);
    backdrop-filter: blur(2px);
    z-index: 1000;
    align-items: center;
    justify-content: center;
    padding: 16px;
}
```

**After**:
```css
.notion-modal-overlay {
    display: none;
    position: fixed;
    top: 0;
    left: 0;
    width: 100vw;
    height: 100vh;
    background-color: rgba(15, 15, 15, 0.45);
    backdrop-filter: blur(2px);
    z-index: 1050;
    align-items: center;
    justify-content: center;
    padding: 16px;
}
```

---

### 5.2 Companion Fix in `D:\.NET\ViewModelDemo\Scripts\app.js`

To resolve Challenger Observation 4 (`BodyOverflowClearedOnResize` failure):

**Target**: `Scripts/app.js` lines 58-63

**Before**:
```javascript
        // Close on escape key
        document.addEventListener("keydown", function (e) {
            if (e.key === "Escape" && drawer.classList.contains("open")) {
                closeDrawer();
            }
        });
    }
```

**After**:
```javascript
        // Close on escape key
        document.addEventListener("keydown", function (e) {
            if (e.key === "Escape" && drawer.classList.contains("open")) {
                closeDrawer();
            }
        });

        // Close drawer and reset body overflow when resizing from mobile to desktop
        window.addEventListener("resize", function () {
            if (window.innerWidth > 768 && drawer.classList.contains("open")) {
                closeDrawer();
            }
        });
    }
```

---

## 6. Verification Against Challenger Test Assertions

When the above changes are applied:

1. **`MobileOverlayDisplay` (Line 280)**:
   - `overlayDisplay` is `"none"` and `overlayPointerEvents` is `"none"`.
   - Condition `($overlayState.overlayDisplay -eq "none" -or $overlayState.overlayPointerEvents -eq "none")` passes.
2. **`ToggleReachableByClick` (Line 283)**:
   - `document.elementFromPoint(341, 29)` skips the overlay because it is `display: none; pointer-events: none;`.
   - Returns `#mobileNavToggle` (`BUTTON`).
   - `isToggleReachable` is `true`. Passes.
3. **`UserClickOpensDrawer` (Line 322)**:
   - Physical mouse click at (341, 29) triggers `#mobileNavToggle` click listener.
   - `openDrawer()` runs, adding `.open` to drawer and overlay.
   - `drawerHasOpenClass` is `true`. Passes.
4. **`MainContentClickable` (Line 342)**:
   - Hit test on search input returns the input element.
   - `isBlocked` is `false`. Passes.
5. **`BodyOverflowClearedOnResize` (Line 565)**:
   - Resizing viewport from 375px to 1280px with drawer open triggers `window.resize`.
   - `window.innerWidth > 768 && drawer.classList.contains("open")` matches.
   - `closeDrawer()` executes, setting `document.body.style.overflow = ""`.
   - Passes.
6. **Zero Emojis & Reduced Motion**:
   - Neither change introduces emoji characters or alters reduced motion CSS rules.
