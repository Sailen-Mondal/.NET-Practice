# Milestone 2 Exploration Report: Admin Views Modernization (Dashboard.cshtml & Users.cshtml)

**Agent**: explorer_m2_2 (Admin Views Explorer)  
**Assigned Directory**: `D:\.NET\.agents\teamwork\explorer_m2_2`  
**Target Views**:
1. `D:\.NET\ViewModelDemo\Views\Admin\Dashboard.cshtml`
2. `D:\.NET\ViewModelDemo\Views\Admin\Users.cshtml`  
**Target ViewModels / Models**:
1. `D:\.NET\ViewModelDemo\ViewModels\AdminDashboardViewModel.cs`
2. `D:\.NET\ViewModelDemo\ViewModels\EmployeeListItemViewModel.cs`
3. `D:\.NET\ViewModelDemo\Models\User.cs`
4. `D:\.NET\ViewModelDemo\Models\UserSession.cs`  
**Status**: COMPLETE (Read-Only Analysis & Ready-to-Implement Blueprint)

---

## 1. Observation

### 1.1 Existing Layout & Markup Analysis

#### View 1: `D:\.NET\ViewModelDemo\Views\Admin\Dashboard.cshtml` (126 lines)
- **Model Binding**: `@model ViewModelDemo.ViewModels.AdminDashboardViewModel`
- **Page Header**:
  - Title: `<h1 class="page-title">Administrator Dashboard</h1>` (line 10)
  - Subtitle: `<p class="page-subtitle">Real-time metrics, workforce analytics, and system management</p>` (line 11)
  - Action buttons: `<a href="/Employee/Create" class="btn btn-primary">+ Add New Employee</a>` (line 14) and `<a href="/Admin/Users" class="btn btn-secondary" style="margin-left: 8px;">View All Users</a>` (line 15)
- **KPI Metrics Display**:
  - Encapsulated in `<div class="metrics-grid">` (line 20) with 4 `.metric-card` items:
    1. Total Employees: `<div class="metric-label">Total Employees</div><div class="metric-value">@Model.TotalEmployees</div>` (lines 21-24)
    2. Registered Users: `<div class="metric-label">Registered Users</div><div class="metric-value">@Model.TotalUsers</div>` (lines 25-28)
    3. Monthly Payroll: `<div class="metric-label">Monthly Payroll</div><div class="metric-value">@Model.FormattedTotalPayroll</div>` (lines 29-32)
    4. Average Salary: `<div class="metric-label">Average Salary</div><div class="metric-value">@Model.FormattedAverageSalary</div>` (lines 33-36)
  - **Defect/Gap**: Cards lack `.metric-header` with SVG icons and lack `.metric-meta` notes defined in `site.css` (lines 989-1043).
- **Workforce by Department**:
  - Container: `<div class="card"><h2 class="card-header">Workforce by Department</h2>...</div>` (lines 40-50)
  - Renders raw flex-wrap pills: `<span class="tag" style="padding: 6px 12px; font-size: 13px;"><strong>@dept.Key:</strong> @dept.Value employee@(dept.Value > 1 ? "s" : "")</span>` (lines 45-47)
  - **Defect/Gap**: Lacks visual progress indicator tracks or proportion bars; lacks empty state handling if `DepartmentCounts` is empty.
- **Recent Employees Table**:
  - Container: `<div class="card">` (line 53)
  - Section Header: `<h2 class="card-header" style="margin: 0; padding: 0; border: none;">Recent Employee Additions</h2>` (line 56) with link `<a href="/Employee/Index" class="action-link">View Full Directory &rarr;</a>` (line 57)
  - **Critical Test Fragility**: E2E test `T2_F11_04` checks `Assert-ContainsText -Content $res.Content -ExpectedText "Recent Employees"`. In existing code, the text `Recent Employees` is NOT in the `<h2>` heading (which says `Recent Employee Additions` singular); it ONLY passed because of the HTML comment `<!-- Recent Employees Table -->` at line 52! If comments are stripped or removed, the test fails.
  - Table: `<table>` rendered directly inside `.card` without a scroll container (`.notion-table-container` or `.table-responsive`) (line 58). On mobile/tablet viewports, table columns overflow and cause card layout breakages.
  - Table actions: View (`/Employee/Details/@emp.EmployeeId`), Edit (`/Employee/Edit/@emp.EmployeeId`), Delete (`/Employee/Delete/@emp.EmployeeId`).
  - **Defect/Gap**: Missing `.table-empty-state` if `Model.RecentEmployees` is empty.
- **Recent Users Table**:
  - Container: `<div class="card">` (line 92)
  - Header: `<h2 class="card-header" style="margin: 0; padding: 0; border: none;">Recent User Registrations</h2>` (line 94) with link `<a href="/Admin/Users" class="action-link">Manage Users &rarr;</a>` (line 95)
  - Table: `<table>` without scroll wrapper (line 97).
  - Columns: User ID, Username (`<code>@u.Username</code>`), Full Name, Email, Assigned Role (`<span class="role-badge @(u.Role == "Admin" ? "badge-admin" : "badge-user")">@u.Role</span>`), Registration Date (`@u.CreatedAt.ToString("MMM dd, yyyy")`).
  - **Defect/Gap**: Missing `.table-empty-state` if `Model.RecentUsers` is empty.

#### View 2: `D:\.NET\ViewModelDemo\Views\Admin\Users.cshtml` (47 lines)
- **Model Binding**: `@model IEnumerable<ViewModelDemo.Models.User>`
- **Page Header**:
  - Title: `<h1 class="page-title">Registered System Users</h1>` (line 9)
  - Subtitle: `<p class="page-subtitle">All user accounts with role permissions</p>` (line 10)
  - Action button: `<a href="/Admin/Dashboard" class="btn btn-secondary">&larr; Back to Dashboard</a>` (line 13)
- **Users Directory Table**:
  - Container: `<div class="card">` (line 17)
  - Table: `<table>` sitting directly inside `.card` without `.notion-table-container` or `.table-responsive` (line 18).
  - Header: `<th>` with hardcoded inline widths (`style="width: 80px;"`, `style="width: 120px;"`, `style="width: 160px;"`).
  - Columns: ID, Username (`<code>@user.Username</code>`), Full Name (`<strong>@user.FullName</strong>`), Email (`@user.Email`), Role (`<span class="role-badge @(user.Role == "Admin" ? "badge-admin" : "badge-user")">@user.Role</span>`), Created Date (`@user.CreatedAt.ToString("MMM dd, yyyy HH:mm")`).
  - **Defect/Gap**:
    1. No responsive scroll container (`.notion-table-container` or `.table-responsive`), violating Requirement R2.
    2. Table sits inside `.card` with standard 24px padding, leading to double border margins and inconsistent styling compared to `Employee/Index.cshtml`.
    3. Missing empty state handling (`.table-empty-state`) if `Model == null || !Model.Any()`.
    4. Missing user avatar initial circles, mailto links with mail icons, breadcrumb hierarchy, and account count tags.

---

### 1.2 Model & ViewModel Structure Inspection

#### `D:\.NET\ViewModelDemo\ViewModels\AdminDashboardViewModel.cs`
```csharp
namespace ViewModelDemo.ViewModels
{
    public class AdminDashboardViewModel
    {
        public int TotalEmployees { get; set; }
        public int TotalUsers { get; set; }
        public decimal TotalPayroll { get; set; }
        public decimal AverageSalary { get; set; }
        public Dictionary<string, int> DepartmentCounts { get; set; } = new Dictionary<string, int>();
        public List<EmployeeListItemViewModel> RecentEmployees { get; set; } = new List<EmployeeListItemViewModel>();
        public List<User> RecentUsers { get; set; } = new List<User>();

        public string FormattedTotalPayroll => "Rs. " + TotalPayroll.ToString("N2");
        public string FormattedAverageSalary => "Rs. " + AverageSalary.ToString("N2");
    }
}
```
*Key Property Mappings & Nuance*:
- The dispatch message conceptually mentions `TotalMonthlyPayroll` and `DepartmentDistribution`. The actual C# property names are `TotalPayroll` / `FormattedTotalPayroll` and `DepartmentCounts`.
- `FormattedTotalPayroll` automatically formats currency as `"Rs. " + TotalPayroll.ToString("N2")`.
- `FormattedAverageSalary` automatically formats currency as `"Rs. " + AverageSalary.ToString("N2")`.
- `RecentEmployees` elements are of type `EmployeeListItemViewModel` (`EmployeeId`, `Name`, `Gender`, `Department`, `Salary`, `AddressId`, `City`, `State`, `Country`, `FormattedSalary`, `Location`).
- `RecentUsers` elements are of type `User` (`UserId`, `Username`, `Email`, `FullName`, `Role`, `CreatedAt`).

#### `D:\.NET\ViewModelDemo\Models\User.cs`
```csharp
namespace ViewModelDemo.Models
{
    public class User
    {
        public int UserId { get; set; }
        public string Username { get; set; }
        public string Email { get; set; }
        public string FullName { get; set; }
        public string Role { get; set; }
        public DateTime CreatedAt { get; set; }
    }
}
```
*Crucial Safety Finding*:
- The dispatch message mentions `IsAdmin` in `List<ViewModelDemo.Models.User>`.
- In `User.cs`, **`IsAdmin` does NOT exist as a property!** `User.cs` only has `string Role`.
- `IsAdmin` only exists on `UserSession.cs` (`public bool IsAdmin => string.Equals(Role, "Admin", StringComparison.OrdinalIgnoreCase);`).
- Attempting to access `@user.IsAdmin` in `Users.cshtml` or in `Dashboard.cshtml` on `RecentUsers` will trigger a C# compilation error (`CS1061: 'User' does not contain a definition for 'IsAdmin'`). Role checks must use `user.Role == "Admin"` or `string.Equals(user.Role, "Admin", StringComparison.OrdinalIgnoreCase)`.

---

### 1.3 Design System & Asset Alignment (`site.css` and `app.js`)

Inspection of `D:\.NET\ViewModelDemo\Content\site.css`:
- **Canvas & Surface Tokens**:
  - `--canvas-bg: #fbfbfa`, `--surface-card: #ffffff`, `--surface-subtle: #f7f7f5`, `--surface-hover: #f1f1ef`
  - `--border-color: #e5e7eb`, `--border-subtle: #eaeaea`, `--border-medium: #d7d7d5`
  - `--text-primary: #37352f`, `--text-secondary: #6b7280`, `--text-tertiary: #9b9a97`, `--text-dark: #111827`
- **KPI Metrics Components** (`site.css` lines 989-1043):
  - `.metrics-grid`: CSS Grid with `repeat(auto-fit, minmax(200px, 1fr))`, collapses to 2 columns on tablet (<1024px) and 1 column on mobile (<768px).
  - `.metric-card`: White card surface, 1px border, shadow-card, padding 18px 20px.
  - `.metric-header`: Flex row, space-between alignment for label + SVG icon.
  - `.metric-label`: 12.5px font, color `--text-secondary`, font-weight 500.
  - `.metric-icon`: 16px x 16px SVG icon, color `--text-secondary`.
  - `.metric-value`: 26px bold font, color `--text-dark`, tracking -0.025em.
  - `.metric-meta`: 11.5px subtle contextual note, color `--text-tertiary`.
- **Table Components** (`site.css` lines 871-985):
  - `.notion-table-container`, `.table-responsive`: `overflow-x: auto; -webkit-overflow-scrolling: touch; border: 1px solid var(--border-color); border-radius: var(--radius-lg); background-color: var(--surface-card); box-shadow: var(--shadow-subtle);`
  - `.notion-table`, `table`: `width: 100%; min-width: 600px; border-collapse: collapse; font-size: 13.5px;`
  - `th`: Sticky styled, uppercase 12px, font-weight 600, letter-spacing 0.04em, background `--surface-subtle`, border-bottom `--border-color`.
  - `td`: 11px 14px padding, border-bottom `--border-subtle`, vertical-align middle.
  - `tbody tr:hover`: background `--surface-subtle`.
  - `.action-links`: Inline-flex with 6px gap.
  - `.action-link`: Notion-styled button link with hover state.
  - `.action-link-danger`: Red text with subtle red hover pill.
  - `.table-empty-state`: Centered container with 36px SVG icon and 13.5px message.
- **Badges & Role Indicators** (`site.css` lines 287-308, 1047-1072):
  - `.role-badge`: 10.5px uppercase, letter-spacing 0.04em, radius-sm.
  - `.badge-admin`: Light blue background (`--badge-admin-bg`), dark blue text (`--badge-admin-text`).
  - `.badge-user`: Neutral gray background (`--badge-user-bg`), dark neutral text (`--badge-user-text`).
  - `.tag`: Pill badge with rounded full radius (`--radius-full`).
- **User Avatar Pill**:
  - `.user-avatar`: 22-24px circle, background `--accent-dark`, text white, uppercase initial.

---

### 1.4 E2E Test Suite Contract Inventory (F11 & F12)

Every test covering Admin Dashboard and Users was inspected across the test suite:

| Test ID | File | Test Title | Exact Verification Assertions |
|---|---|---|---|
| `T1_F11_01` | `Tier1_FeatureCoverage.ps1:680` | Admin Dashboard loads with HTTP 200 | HTTP 200; `Administrator Dashboard` heading present |
| `T1_F11_02` | `Tier1_FeatureCoverage.ps1:688` | Total Employees metric card | Contains text `Total Employees` |
| `T1_F11_03` | `Tier1_FeatureCoverage.ps1:695` | Registered Users metric card | Contains text `Registered Users` |
| `T1_F11_04` | `Tier1_FeatureCoverage.ps1:702` | Total Monthly Payroll in INR | Contains text `Monthly Payroll`; Matches regex `Rs\.\s*[0-9,]+` |
| `T1_F11_05` | `Tier1_FeatureCoverage.ps1:710` | Average Salary in INR | Contains text `Average Salary`; Matches regex `Rs\.\s*[0-9,]+` |
| `T2_F11_01` | `Tier2_BoundaryCorner.ps1:641` | Unauthenticated Dashboard access | HTTP 302; Location matches `/Account/Login\?returnUrl=` |
| `T2_F11_02` | `Tier2_BoundaryCorner.ps1:648` | Standard User blocked from Dashboard | Contains text `Access restricted` |
| `T2_F11_03` | `Tier2_BoundaryCorner.ps1:656` | Department breakdown pill badges | Contains text `Workforce by Department`; Matches regex `class="tag"` |
| `T2_F11_04` | `Tier2_BoundaryCorner.ps1:664` | Recent Employees table limit <= 5 | Contains text `Recent Employees` |
| `T2_F11_05` | `Tier2_BoundaryCorner.ps1:671` | Recent Users table limit <= 5 | Contains text `Recent User Registrations` |
| `T3_CROSS_02`| `Tier3_CrossFeature.ps1:36` | User Dashboard interception | HTTP 302 redirect with access restricted alert |
| `T3_CROSS_11`| `Tier3_CrossFeature.ps1:275` | Added Employee increments counts | Contains text `Total Employees` on reload |
| `T4_SCENARIO_02`| `Tier4_ApplicationScenarios.ps1:56` | Compensation Review & Payroll Audit | Matches regex `Monthly Payroll` |
| `T1_F12_01` | `Tier1_FeatureCoverage.ps1:722` | Admin Users directory loads | HTTP 200; Contains text `System Users` |
| `T1_F12_02` | `Tier1_FeatureCoverage.ps1:730` | Displays admin user account | Contains text `admin`, `admin@viewmodeldemo.com` |
| `T1_F12_03` | `Tier1_FeatureCoverage.ps1:738` | Displays standard user account | Contains text `rahul`, `rahul.sharma@example.com` |
| `T1_F12_04` | `Tier1_FeatureCoverage.ps1:746` | User role formatted as badge | Contains text `Admin`, `User` |
| `T1_F12_05` | `Tier1_FeatureCoverage.ps1:754` | Created Date timestamp column | Contains text `Created Date` |
| `T2_F12_01` | `Tier2_BoundaryCorner.ps1:682` | Unauthenticated Users access | HTTP 302; Location matches `/Account/Login\?returnUrl=` |
| `T2_F12_02` | `Tier2_BoundaryCorner.ps1:689` | Standard User blocked from Users | Contains text `Administrator privileges required.` |
| `T2_F12_03` | `Tier2_BoundaryCorner.ps1:697` | Password security in HTML | Must NOT contain plaintext password `Admin@123` or `User@123` |
| `T2_F12_04` | `Tier2_BoundaryCorner.ps1:705` | Newly registered user appears in table | Matches newly registered user audit handle |
| `T2_F12_05` | `Tier2_BoundaryCorner.ps1:723` | Formatted email addresses | Contains `admin@viewmodeldemo.com`, `rahul.sharma@example.com` |
| `T3_CROSS_03`| `Tier3_CrossFeature.ps1:58` | User Users directory interception | HTTP 302 redirect with privileges required alert |
| `T3_CROSS_06`| `Tier3_CrossFeature.ps1:112` | Admin discovers newly registered user | Registered user handle found in `/Admin/Users` |

---

## 2. Logic Chain

1. **KPI Metric Card Modernization**:
   - *Observation*: `site.css` lines 989-1043 defines `.metrics-grid`, `.metric-card`, `.metric-header`, `.metric-label`, `.metric-icon`, `.metric-value`, and `.metric-meta`. Current `Dashboard.cshtml` only uses `.metric-label` and `.metric-value`.
   - *Reasoning*: Upgrading each metric card to include `.metric-header` with an inline SVG icon (team icon, shield icon, wallet/payroll icon, trend/salary icon) and `.metric-meta` context notes delivers the authentic Notion workspace aesthetic.
   - *Safety*: Preserving the exact strings `"Total Employees"`, `"Registered Users"`, `"Monthly Payroll"`, `"Average Salary"`, and `@Model.FormattedTotalPayroll` / `@Model.FormattedAverageSalary` (which output `"Rs. {0:N2}"`) ensures 100% compliance with `T1_F11_02`, `T1_F11_03`, `T1_F11_04`, `T1_F11_05`, and `T4_SCENARIO_02`.

2. **Workforce Department Breakdown Enhancement**:
   - *Observation*: Test `T2_F11_03` asserts `Assert-ContainsText -Content $res.Content -ExpectedText "Workforce by Department"` and `Assert-MatchesPattern -Content $res.Content -RegexPattern 'class="tag"'`.
   - *Reasoning*: To deliver a modern Notion-style visual breakdown, we retain the exact section title `"Workforce by Department"` and wrap each department in `<span class="tag"><strong>@dept.Key</strong></span>`. In addition, we compute the percentage share `(dept.Value * 100) / TotalEmployees` and render a sleek horizontal progress bar track (`height: 6px; background-color: var(--surface-subtle); border-radius: var(--radius-full);` with an inner fill `background-color: var(--accent-dark);`).
   - *Safety*: If `Model.TotalEmployees` is 0 or `Model.DepartmentCounts` is empty, graceful division-by-zero protection (`Model.TotalEmployees > 0 ? ... : 0`) and `.table-empty-state` ensure zero crashes.

3. **Eliminating Test Fragility in Recent Employees Section**:
   - *Observation*: `T2_F11_04` checks `Assert-ContainsText -Content $res.Content -ExpectedText "Recent Employees"`. In existing code, the visible title was `Recent Employee Additions` (singular "Employee"), and the test passed solely due to the HTML comment `<!-- Recent Employees Table -->`.
   - *Reasoning*: Relying on an HTML comment for a test assertion is fragile. The modernized section heading should be explicitly titled `"Recent Employees"` with subtitle `"Latest additions to the workforce roster (Top 5)"` and retain the HTML comment.
   - *Safety*: Fully satisfies `T2_F11_04` regardless of comment stripping or minification.

4. **Eliminating Table Overflow on Mobile/Tablet**:
   - *Observation*: Existing `Dashboard.cshtml` and `Users.cshtml` place `<table>` directly inside `<div class="card">` without scroll containers. On mobile (<768px), table columns break viewport boundaries.
   - *Reasoning*: Wrapping tables in `<div class="notion-table-container">` (or `.table-responsive`) inside `<div class="card" style="padding: 0; overflow: hidden;">` enables fluid horizontal scrolling on mobile while maintaining crisp edge-to-edge Notion table styling on desktop, fulfilling Requirement R2.

5. **Users Directory Table Polish**:
   - *Observation*: `Users.cshtml` lacks avatar circles, mailto links, breadcrumbs, account count tags, and empty states.
   - *Reasoning*:
     - Add Notion breadcrumbs: `Home / Admin / Users`.
     - Add user count tag in header: `<span class="tag">@(Model != null ? Model.Count() : 0) Accounts</span>`.
     - Replace raw text with user avatar initials `<span class="user-avatar">` next to `@user.FullName`.
     - Add monospace badge `<code>@user.Username</code>`.
     - Add mailto link with SVG email icon for `@user.Email`.
     - Retain exact column header `<th>Created Date</th>` to satisfy `T1_F12_05`.
     - Retain role badge `<span class="role-badge @(string.Equals(user.Role, "Admin", StringComparison.OrdinalIgnoreCase) ? "badge-admin" : "badge-user")">@user.Role</span>` to satisfy `T1_F12_04`.
     - Add empty state handling (`.table-empty-state`) for empty directory.

6. **Strict Zero Emojis Compliance**:
   - *Observation*: Global project rule STRICT: Zero Emojis throughout.
   - *Reasoning*: All visual symbols are clean inline SVGs (`stroke="currentColor"`, `stroke-width="2"`, `fill="none"`) or standard typography entities (`&bull;`, `&rarr;`, `&larr;`, `+`).

---

## 3. Caveats

1. **Model Property Names**: As discovered in Section 1.2, the view must bind to `Model.TotalPayroll` (not `TotalMonthlyPayroll`), `Model.DepartmentCounts` (not `DepartmentDistribution`), and must NOT access `@user.IsAdmin` on `User.cs` (which only possesses `string Role`).
2. **Backend Controller Contracts**: `AdminController.cs` and `DatabaseHelper.cs` are functioning and verified. The views must not change action routes or expect different query parameters.
3. **Seed Data State**: E2E tests expect specific seed users (`admin`, `admin@viewmodeldemo.com`, `rahul`, `rahul.sharma@example.com`). The view markup cleanly presents whoever is in the model without hardcoding.
4. **Scope Limitation**: Explorer is strictly read-only. Proposed markup files are provided in full below for the implementer agent (`worker_m2`).

---

## 4. Conclusion & Proposed Razor Markup

Both views can be completely overhauled into clean, responsive, Notion-style masterpieces while maintaining 100% backward compatibility and test compliance.

### Proposal 1: `D:\.NET\ViewModelDemo\Views\Admin\Dashboard.cshtml`

```html
@model ViewModelDemo.ViewModels.AdminDashboardViewModel
@{
    ViewBag.Title = "Admin Dashboard";
    var currentUser = Session["CurrentUser"] as ViewModelDemo.Models.UserSession;
}

<div class="container">
    <!-- Breadcrumb Navigation -->
    <nav class="notion-breadcrumb" aria-label="Breadcrumb" style="display: flex; align-items: center; gap: 6px; font-size: 12.5px; color: var(--text-tertiary); margin-bottom: 12px;">
        <a href="/Employee/Index" style="color: var(--text-secondary); text-decoration: none;">Home</a>
        <span aria-hidden="true">/</span>
        <span style="color: var(--text-secondary);">Admin</span>
        <span aria-hidden="true">/</span>
        <span style="color: var(--text-dark); font-weight: 500;">Dashboard</span>
    </nav>

    <!-- Page Header -->
    <div class="page-header">
        <div>
            <div style="display: flex; align-items: center; gap: 8px; margin-bottom: 6px;">
                <span class="tag" style="font-size: 11px;">Workforce Intelligence</span>
                <span class="tag" style="font-size: 11px;">Live Metrics</span>
            </div>
            <h1 class="page-title">Administrator Dashboard</h1>
            <p class="page-subtitle">Real-time metrics, workforce analytics, and system management</p>
        </div>
        <div style="display: flex; align-items: center; gap: 8px; flex-wrap: wrap;">
            <a href="/Employee/Create" class="btn btn-primary">
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
                    <line x1="12" y1="5" x2="12" y2="19"></line>
                    <line x1="5" y1="12" x2="19" y2="12"></line>
                </svg>
                <span>Add New Employee</span>
            </a>
            <a href="/Admin/Users" class="btn btn-secondary">
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
                    <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path>
                    <circle cx="9" cy="7" r="4"></circle>
                    <path d="M23 21v-2a4 4 0 0 0-3-3.87"></path>
                    <path d="M16 3.13a4 4 0 0 1 0 7.75"></path>
                </svg>
                <span>View All Users</span>
            </a>
            <a href="/Employee/Index" class="btn btn-secondary">
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
                    <rect x="3" y="3" width="7" height="7"></rect>
                    <rect x="14" y="3" width="7" height="7"></rect>
                    <rect x="14" y="14" width="7" height="7"></rect>
                    <rect x="3" y="14" width="7" height="7"></rect>
                </svg>
                <span>Manage Employees</span>
            </a>
        </div>
    </div>

    <!-- 4 Prominent KPI Metric Cards -->
    <div class="metrics-grid">
        <!-- 1. Total Employees -->
        <div class="metric-card">
            <div class="metric-header">
                <span class="metric-label">Total Employees</span>
                <svg class="metric-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
                    <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path>
                    <circle cx="9" cy="7" r="4"></circle>
                    <path d="M23 21v-2a4 4 0 0 0-3-3.87"></path>
                    <path d="M16 3.13a4 4 0 0 1 0 7.75"></path>
                </svg>
            </div>
            <div class="metric-value">@Model.TotalEmployees</div>
            <div class="metric-meta">Active workforce records in database</div>
        </div>

        <!-- 2. Registered Users -->
        <div class="metric-card">
            <div class="metric-header">
                <span class="metric-label">Registered Users</span>
                <svg class="metric-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
                    <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path>
                    <circle cx="12" cy="7" r="4"></circle>
                </svg>
            </div>
            <div class="metric-value">@Model.TotalUsers</div>
            <div class="metric-meta">System user accounts with login access</div>
        </div>

        <!-- 3. Monthly Payroll -->
        <div class="metric-card">
            <div class="metric-header">
                <span class="metric-label">Monthly Payroll</span>
                <svg class="metric-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
                    <rect x="2" y="4" width="20" height="16" rx="2"></rect>
                    <line x1="2" y1="10" x2="22" y2="10"></line>
                </svg>
            </div>
            <div class="metric-value">@Model.FormattedTotalPayroll</div>
            <div class="metric-meta">Aggregated monthly compensation outlay</div>
        </div>

        <!-- 4. Average Salary -->
        <div class="metric-card">
            <div class="metric-header">
                <span class="metric-label">Average Salary</span>
                <svg class="metric-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
                    <polyline points="23 6 13.5 15.5 8.5 10.5 1 18"></polyline>
                    <polyline points="17 6 23 6 23 12"></polyline>
                </svg>
            </div>
            <div class="metric-value">@Model.FormattedAverageSalary</div>
            <div class="metric-meta">Mean compensation across all departments</div>
        </div>
    </div>

    <!-- Department Distribution Card -->
    <div class="card" style="margin-bottom: 24px;">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px; padding-bottom: 12px; border-bottom: 1px solid var(--border-subtle);">
            <div>
                <h2 class="card-header" style="margin: 0; padding: 0; border: none; font-size: 15px;">Workforce by Department</h2>
                <p class="card-subtitle" style="margin: 2px 0 0 0;">Headcount allocation and proportional department distribution</p>
            </div>
            <span class="tag" style="font-size: 11.5px;">@(Model.DepartmentCounts != null ? Model.DepartmentCounts.Count : 0) Departments</span>
        </div>

        @if (Model.DepartmentCounts == null || !Model.DepartmentCounts.Any())
        {
            <div class="table-empty-state" style="padding: 24px;">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
                    <rect x="2" y="7" width="20" height="14" rx="2" ry="2"></rect>
                    <path d="M16 21V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v16"></path>
                </svg>
                <p>No department allocation data available.</p>
            </div>
        }
        else
        {
            <!-- Summary Tags for Test Compatibility & Quick Scanning -->
            <div style="display: flex; flex-wrap: wrap; gap: 8px; margin-bottom: 20px;">
                @foreach (var dept in Model.DepartmentCounts)
                {
                    <span class="tag" style="padding: 5px 12px; font-size: 12.5px;">
                        <strong>@dept.Key:</strong> @dept.Value employee@(dept.Value > 1 ? "s" : "")
                    </span>
                }
            </div>

            <!-- Modern Proportional Progress Bars -->
            <div style="display: flex; flex-direction: column; gap: 14px;">
                @foreach (var dept in Model.DepartmentCounts)
                {
                    int count = dept.Value;
                    int pct = Model.TotalEmployees > 0 ? (int)Math.Round((double)count * 100 / Model.TotalEmployees) : 0;
                    <div>
                        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 6px; font-size: 13px;">
                            <div style="display: flex; align-items: center; gap: 8px;">
                                <span class="tag" style="font-weight: 600;">@dept.Key</span>
                                <span style="color: var(--text-secondary); font-size: 12.5px;">@count employee@(count > 1 ? "s" : "")</span>
                            </div>
                            <span style="font-weight: 600; color: var(--text-dark); font-size: 12.5px;">@pct%</span>
                        </div>
                        <div style="height: 6px; background-color: var(--surface-subtle); border-radius: var(--radius-full); overflow: hidden; border: 1px solid var(--border-subtle);">
                            <div style="height: 100%; background-color: var(--accent-dark); border-radius: var(--radius-full); width: @pct%; transition: width var(--transition-base);"></div>
                        </div>
                    </div>
                }
            </div>
        }
    </div>

    <!-- Recent Employees Table -->
    <div class="card" style="padding: 0; overflow: hidden; margin-bottom: 24px;">
        <!-- Recent Employees Table -->
        <div style="padding: 16px 20px; border-bottom: 1px solid var(--border-subtle); display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 10px;">
            <div>
                <h2 class="card-header" style="margin: 0; padding: 0; border: none; font-size: 15px;">Recent Employees</h2>
                <p class="card-subtitle" style="margin: 2px 0 0 0;">Latest additions to the workforce roster (Top 5)</p>
            </div>
            <a href="/Employee/Index" class="action-link" style="font-size: 13px;">View Full Directory &rarr;</a>
        </div>
        <div class="notion-table-container" style="margin-bottom: 0; border: none; border-radius: 0;">
            <table class="notion-table">
                <thead>
                    <tr>
                        <th style="width: 70px;">ID</th>
                        <th>Name</th>
                        <th style="width: 140px;">Department</th>
                        <th style="width: 140px;">Salary</th>
                        <th>Location</th>
                        <th style="width: 170px; text-align: right;">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    @if (Model.RecentEmployees == null || !Model.RecentEmployees.Any())
                    {
                        <tr>
                            <td colspan="6">
                                <div class="table-empty-state">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
                                        <circle cx="12" cy="12" r="10"></circle>
                                        <line x1="12" y1="8" x2="12" y2="12"></line>
                                        <line x1="12" y1="16" x2="12.01" y2="16"></line>
                                    </svg>
                                    <p>No recent employee records found.</p>
                                </div>
                            </td>
                        </tr>
                    }
                    else
                    {
                        foreach (var emp in Model.RecentEmployees)
                        {
                            <tr>
                                <td>@emp.EmployeeId</td>
                                <td><strong>@emp.Name</strong></td>
                                <td><span class="tag">@emp.Department</span></td>
                                <td>@emp.FormattedSalary</td>
                                <td>@emp.Location</td>
                                <td style="text-align: right;">
                                    <div class="action-links" style="justify-content: flex-end;">
                                        <a href="/Employee/Details/@emp.EmployeeId" class="action-link">View</a>
                                        <a href="/Employee/Edit/@emp.EmployeeId" class="action-link">Edit</a>
                                        <a href="/Employee/Delete/@emp.EmployeeId" class="action-link action-link-danger">Delete</a>
                                    </div>
                                </td>
                            </tr>
                        }
                    }
                </tbody>
            </table>
        </div>
    </div>

    <!-- Recent Users Table -->
    <div class="card" style="padding: 0; overflow: hidden; margin-bottom: 24px;">
        <!-- Recent Users Table -->
        <div style="padding: 16px 20px; border-bottom: 1px solid var(--border-subtle); display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 10px;">
            <div>
                <h2 class="card-header" style="margin: 0; padding: 0; border: none; font-size: 15px;">Recent User Registrations</h2>
                <p class="card-subtitle" style="margin: 2px 0 0 0;">Latest system account creations and credentials (Top 5)</p>
            </div>
            <a href="/Admin/Users" class="action-link" style="font-size: 13px;">Manage Users &rarr;</a>
        </div>
        <div class="notion-table-container" style="margin-bottom: 0; border: none; border-radius: 0;">
            <table class="notion-table">
                <thead>
                    <tr>
                        <th style="width: 80px;">User ID</th>
                        <th style="width: 140px;">Username</th>
                        <th>Full Name</th>
                        <th>Email</th>
                        <th style="width: 130px;">Assigned Role</th>
                        <th style="width: 150px;">Registration Date</th>
                    </tr>
                </thead>
                <tbody>
                    @if (Model.RecentUsers == null || !Model.RecentUsers.Any())
                    {
                        <tr>
                            <td colspan="6">
                                <div class="table-empty-state">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
                                        <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path>
                                        <circle cx="12" cy="7" r="4"></circle>
                                    </svg>
                                    <p>No recent user registrations found.</p>
                                </div>
                            </td>
                        </tr>
                    }
                    else
                    {
                        foreach (var u in Model.RecentUsers)
                        {
                            <tr>
                                <td>@u.UserId</td>
                                <td><code>@u.Username</code></td>
                                <td><strong>@u.FullName</strong></td>
                                <td><a href="mailto:@u.Email" style="color: inherit; text-decoration: none;">@u.Email</a></td>
                                <td>
                                    <span class="role-badge @(string.Equals(u.Role, "Admin", System.StringComparison.OrdinalIgnoreCase) ? "badge-admin" : "badge-user")">@u.Role</span>
                                </td>
                                <td>@u.CreatedAt.ToString("MMM dd, yyyy")</td>
                            </tr>
                        }
                    }
                </tbody>
            </table>
        </div>
    </div>
</div>
```

---

### Proposal 2: `D:\.NET\ViewModelDemo\Views\Admin\Users.cshtml`

```html
@model IEnumerable<ViewModelDemo.Models.User>
@{
    ViewBag.Title = "System Users";
    int userCount = Model != null ? Model.Count() : 0;
}

<div class="container">
    <!-- Breadcrumb Navigation -->
    <nav class="notion-breadcrumb" aria-label="Breadcrumb" style="display: flex; align-items: center; gap: 6px; font-size: 12.5px; color: var(--text-tertiary); margin-bottom: 12px;">
        <a href="/Employee/Index" style="color: var(--text-secondary); text-decoration: none;">Home</a>
        <span aria-hidden="true">/</span>
        <a href="/Admin/Dashboard" style="color: var(--text-secondary); text-decoration: none;">Admin</a>
        <span aria-hidden="true">/</span>
        <span style="color: var(--text-dark); font-weight: 500;">Users</span>
    </nav>

    <!-- Page Header -->
    <div class="page-header">
        <div>
            <div style="display: flex; align-items: center; gap: 8px; margin-bottom: 6px;">
                <span class="tag" style="font-size: 11px;">Access Control</span>
                <span class="tag" style="font-size: 11px;">@userCount Accounts</span>
            </div>
            <h1 class="page-title">System Users</h1>
            <p class="page-subtitle">All registered user accounts with role permissions and system access</p>
        </div>
        <div>
            <a href="/Admin/Dashboard" class="btn btn-secondary">
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
                    <line x1="19" y1="12" x2="5" y2="12"></line>
                    <polyline points="12 19 5 12 12 5"></polyline>
                </svg>
                <span>Back to Dashboard</span>
            </a>
        </div>
    </div>

    <!-- Users Directory Data Table Card -->
    <div class="card" style="padding: 0; overflow: hidden;">
        <div class="notion-table-container" style="margin-bottom: 0; border: none; border-radius: 0;">
            <table class="notion-table">
                <thead>
                    <tr>
                        <th style="width: 80px;">ID</th>
                        <th style="width: 150px;">Username</th>
                        <th>Full Name</th>
                        <th>Email</th>
                        <th style="width: 130px;">Role</th>
                        <th style="width: 170px;">Created Date</th>
                    </tr>
                </thead>
                <tbody>
                    @if (Model == null || !Model.Any())
                    {
                        <tr>
                            <td colspan="6">
                                <div class="table-empty-state">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
                                        <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path>
                                        <circle cx="12" cy="7" r="4"></circle>
                                    </svg>
                                    <p>No registered system users found.</p>
                                </div>
                            </td>
                        </tr>
                    }
                    else
                    {
                        foreach (var user in Model)
                        {
                            <tr>
                                <td>@user.UserId</td>
                                <td><code>@user.Username</code></td>
                                <td>
                                    <div style="display: flex; align-items: center; gap: 8px;">
                                        <span class="user-avatar" style="width: 24px; height: 24px; font-size: 11px;" aria-hidden="true">
                                            @(string.IsNullOrEmpty(user.FullName) ? "U" : user.FullName.Substring(0, 1).ToUpper())
                                        </span>
                                        <strong>@user.FullName</strong>
                                    </div>
                                </td>
                                <td>
                                    <a href="mailto:@user.Email" style="display: inline-flex; align-items: center; gap: 6px; color: inherit; text-decoration: none;">
                                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="color: var(--text-tertiary); flex-shrink: 0;" aria-hidden="true">
                                            <path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"></path>
                                            <polyline points="22,6 12,13 2,6"></polyline>
                                        </svg>
                                        <span>@user.Email</span>
                                    </a>
                                </td>
                                <td>
                                    <span class="role-badge @(string.Equals(user.Role, "Admin", System.StringComparison.OrdinalIgnoreCase) ? "badge-admin" : "badge-user")">@user.Role</span>
                                </td>
                                <td>
                                    <time datetime="@user.CreatedAt.ToString("yyyy-MM-ddTHH:mm:ss")" style="color: var(--text-secondary); font-size: 13px;">
                                        @user.CreatedAt.ToString("MMM dd, yyyy HH:mm")
                                    </time>
                                </td>
                            </tr>
                        }
                    }
                </tbody>
            </table>
        </div>
    </div>
</div>
```

---

## 5. Verification Method

### 5.1 Verification Commands

1. **Compilation Check**:
   ```powershell
   & "C:\Program Files\Microsoft Visual Studio\18\Community\MSBuild\Current\Bin\MSBuild.exe" "D:\.NET\ViewModelDemo\ViewModelDemo.csproj" /t:Build /p:Configuration=Debug /v:minimal
   ```
   *Expected Result*: Build succeeded with 0 errors, 0 warnings.

2. **E2E Test Suite Execution**:
   ```powershell
   powershell.exe -ExecutionPolicy Bypass -File D:\.NET\ViewModelDemo\Tests\E2E\Run-E2ETests.ps1
   ```
   *Expected Result*: All 173 tests pass (100% pass rate across Tiers 1-4).

3. **Adversarial & Regression Verification**:
   ```powershell
   powershell.exe -ExecutionPolicy Bypass -File D:\.NET\ViewModelDemo\Tests\E2E\AdversarialSuite_M1.ps1
   ```
   *Expected Result*: 20/20 PASS.

4. **Zero Emoji Verification**:
   ```powershell
   Get-ChildItem -Path "D:\.NET\ViewModelDemo\Views\Admin" -Recurse -Include *.cshtml | ForEach-Object {
       $content = Get-Content $_.FullName -Raw
       if ($content -match '[\uD83C-\uDBFF\uDC00-\uDFFF]') {
           throw "Emoji detected in $($_.FullName)"
       }
   }
   Write-Host "Zero emojis confirmed in Admin views."
   ```

### 5.2 Invalidation Conditions
- Any Razor syntax error or C# property mismatch (e.g. attempting to bind to `IsAdmin` on `User.cs`).
- Removal of critical test assertion strings:
  - `"Administrator Dashboard"`
  - `"Total Employees"`
  - `"Registered Users"`
  - `"Monthly Payroll"`
  - `"Average Salary"`
  - `"Workforce by Department"`
  - `"Recent Employees"`
  - `"Recent User Registrations"`
  - `"System Users"`
  - `"Created Date"`
  - `'class="tag"'`
  - Currency prefix regex `'Rs\.\s*[0-9,]+'`
- Presence of any emoji character anywhere in the markup.
- Missing responsive scroll container (`.notion-table-container` or `.table-responsive`) causing table overflow on small viewports.
