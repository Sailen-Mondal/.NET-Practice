# Project: ViewModelDemo Frontend Modernization

## Architecture
ViewModelDemo is an ASP.NET MVC 5 application targeting .NET Framework 4.8.1 with direct ADO.NET data access against Microsoft SQL Server (ViewModelDB). The frontend architecture is being overhauled into a modern, responsive, highly interactive Notion-like experience while strictly preserving backend controller logic, session authentication, and validation contracts.

### Frontend Architectural System
1. **Design System & Visual Identity**:
   - Palette: Neutral off-white page canvas (`#fbfbfa`), pure white cards (`#ffffff`), subtle borders (`#e5e7eb`, hover `#d1d5db`), dark gray typography (`#37352f`, secondary `#6b7280`).
   - Typography: Clean sans-serif stack (`-apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial, sans-serif`).
   - Strict Zero Emojis: All iconography implemented via clean inline SVG or crisp typography labels.
   - Indian Context: Authentic Indian naming conventions (Rahul Sharma, Priya Patel, Sneha Roy, Amit Verma) and locations (Bengaluru, Kolkata, New Delhi, Mumbai, Pune) with INR (`Rs.`) currency formatting.
2. **Modular Assets**:
   - `Content/site.css`: Complete Notion design system stylesheet with CSS variables, component classes, utility classes, and media queries.
   - `Scripts/app.js`: Lightweight vanilla JavaScript for interactive drawer, dismissible alert banners, confirmation modal dialogs, and smooth transitions.
3. **Layout & Chrome**:
   - Responsive navbar: Brand identity, route links, active page indicators, session pill (`FullName` + role badge), and mobile hamburger drawer.
   - Notification banner: Global dismissible alert component rendering `TempData["SuccessMessage"]`, `TempData["ErrorMessage"]`, and `TempData["InfoMessage"]`.
   - Notion-style footer: Clean metadata, session role status, and system links.
4. **Interactive Controls & Accessibility**:
   - Focus rings: 2px offset focus states for keyboard accessibility (`focus-visible`).
   - State feedback: Hover, active, loading, and disabled states across buttons and inputs.
   - Responsive tables: Horizontal scrolling containers with sticky headers and responsive card fallbacks.
   - Prefers-reduced-motion: All CSS animations and transitions respect user reduced-motion preferences.

---

## Feature Inventory
Every feature identified during the survey phase is mapped to an implementation milestone.

| # | Feature | Description | Milestone | Source |
|---|---------|-------------|-----------|--------|
| F01 | User Authentication & Login | Credential login with ReturnUrl support, validation feedback, and session establishment | M2 | Survey / Spec Miner |
| F02 | User Registration | New account registration with regex username validation and auto-login | M2 | Survey / Spec Miner |
| F03 | Session Management & Logout | Session termination, abandonment, and redirection with info alert | M2 | Survey / Spec Miner |
| F04 | Role-Based Access Control | Interception and redirection for restricted Admin routes and actions | M2 | Survey / Spec Miner |
| F05 | Global Navigation & User Pill | Responsive top navigation, user status pill, and mobile drawer | M1 | Survey / Spec Miner |
| F06 | Employee Directory & Search | Employee listing table with search filter, salary formatting, and role action links | M3 | Survey / Spec Miner |
| F07 | Aggregated Employee Details View | Multi-model presentation combining Employee and Address details cards | M3 | Survey / Spec Miner |
| F08 | Employee Creation Form | Multi-table composite form with atomic transaction insertion and validation | M3 | Survey / Spec Miner |
| F09 | Employee Editing Form | Pre-populated composite form with hidden ID bindings and update transaction | M3 | Survey / Spec Miner |
| F10 | Transactional Employee Deletion | Delete confirmation view and atomic multi-table record removal | M3 | Survey / Spec Miner |
| F11 | Admin Workforce Dashboard | Metric cards, department distribution pills, and recent records tables | M2 | Survey / Spec Miner |
| F12 | System User Management Directory | Complete user directory table with role badges and registration timestamps | M2 | Survey / Spec Miner |
| F13 | Student Domain Model Raw Listing | Direct student entity listing demonstrating baseline presentation | M3 | Survey / Spec Miner |
| F14 | Student Marks Presentation (getStud) | ViewModel presentation mapping dynamic pass/fail status badges | M3 | Survey / Spec Miner |
| F15 | Offline Resiliency & Fallback Data | Graceful fallback data handling for offline resilience | M3 | Survey / Spec Miner |

---

## Milestones

| # | Name | Scope | Dependencies | Status |
|---|------|-------|-------------|--------|
| M1 | Shared Design System & Layout Shell | Layout, navigation, design tokens, CSS, JS, responsive drawer, alerts, and footer | none | PLANNED |
| M2 | Account & Admin Modules Modernization | Login, Register, Admin Dashboard, and User Directory views | M1 | PLANNED |
| M3 | Employee & Student Modules Modernization | Employee CRUD views (Index, Details, Create, Edit, Delete) and Student views (Index, getStud) | M1 | PLANNED |
| M4 | Final E2E Verification & Adversarial Hardening | Pass 100% of E2E test suite (Tiers 1-4) and complete Tier 5 adversarial stress testing | M2, M3, Test Track | PLANNED |

---

## Interface Contracts

### Shared Layout ↔ Feature Views
- **Stylesheet**: `<link rel="stylesheet" href="~/Content/site.css" />` included in `<head>` of `_Layout.cshtml`.
- **Client Script**: `<script src="~/Scripts/app.js"></script>` included before `</body>` in `_Layout.cshtml`.
- **Body Rendering**: `@RenderBody()` rendered inside `<main class="notion-main"><div class="notion-content">...</div></main>`.
- **Alert Banners**: Render `TempData["SuccessMessage"]`, `TempData["ErrorMessage"]`, `TempData["InfoMessage"]` inside `.notion-alerts-container`.
- **Session Identity**: `Session["CurrentUser"]` of type `ViewModelDemo.Models.UserSession` exposing `FullName`, `Username`, `Role`, `IsAdmin`.

### Form Model Binding Contracts
- **Account Login**: POST `/Account/Login` expects `UsernameOrEmail`, `Password`, `RememberMe`, `ReturnUrl` with `@Html.AntiForgeryToken()`.
- **Account Register**: POST `/Account/Register` expects `FullName`, `Username`, `Email`, `Password`, `ConfirmPassword` with `@Html.AntiForgeryToken()`.
- **Employee Search**: GET `/Employee/Index` accepts query parameter `search`.
- **Employee Create/Edit**: POST `/Employee/Create` and POST `/Employee/Edit` expect `EmployeeId`, `AddressId`, `Name`, `Gender`, `Department`, `Salary`, `Country`, `State`, `City`, `Pin` with `@Html.AntiForgeryToken()`.
- **Employee Delete**: POST `/Employee/Delete/{id}` with `@Html.AntiForgeryToken()`.
- **Student Presentation**: View receives `List<ViewModelDemo.ViewModels.vmStudMarks>` with `RollNo`, `Name`, `Marks`, `colorname`.

---

## Code Layout

- `D:\.NET\ViewModelDemo\Views\Shared\_Layout.cshtml`: Master shell layout
- `D:\.NET\ViewModelDemo\Views\Shared\_Navigation.cshtml`: Header and navigation partial
- `D:\.NET\ViewModelDemo\Content\site.css`: Complete Notion design system stylesheet
- `D:\.NET\ViewModelDemo\Scripts\app.js`: Accessible vanilla JavaScript interactive behaviors
- `D:\.NET\ViewModelDemo\Views\Account\Login.cshtml`: Modernized login view
- `D:\.NET\ViewModelDemo\Views\Account\Register.cshtml`: Modernized register view
- `D:\.NET\ViewModelDemo\Views\Admin\Dashboard.cshtml`: Modernized analytics dashboard view
- `D:\.NET\ViewModelDemo\Views\Admin\Users.cshtml`: Modernized user directory view
- `D:\.NET\ViewModelDemo\Views\Employee\Index.cshtml`: Modernized employee directory view
- `D:\.NET\ViewModelDemo\Views\Employee\Details.cshtml`: Modernized employee details view
- `D:\.NET\ViewModelDemo\Views\Employee\Create.cshtml`: Modernized employee creation view
- `D:\.NET\ViewModelDemo\Views\Employee\Edit.cshtml`: Modernized employee editing view
- `D:\.NET\ViewModelDemo\Views\Employee\Delete.cshtml`: Modernized employee deletion view
- `D:\.NET\ViewModelDemo\Views\Student\Index.cshtml`: Modernized raw student listing view
- `D:\.NET\ViewModelDemo\Views\Student\getStud.cshtml`: Modernized student marks ViewModel view
- `D:\.NET\ViewModelDemo\Tests\E2E\`: E2E test suite and runner scripts
