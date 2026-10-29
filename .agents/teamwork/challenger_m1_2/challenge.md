# Challenge Report: Milestone 1 Verification

**Agent**: challenger_m1_2  
**Role**: critic, specialist  
**Target Solution**: `D:\.NET\ViewModelDemo`  
**Target Host**: `http://localhost:9979`  
**Timestamp**: 2026-10-29T13:45:00Z  

---

## Challenge Summary

**Overall risk assessment**: LOW

Empirical testing across 20 adversarial test scenarios confirms that Milestone 1 (`_Layout.cshtml`, `_Navigation.cshtml`, `Content/site.css`, `Scripts/app.js`) introduces zero regressions to backend routing, ADO.NET query execution, session authentication, or model binding. All core routes resolve with expected HTTP statuses against live IIS Express (port 9979) and SQL Server (`ViewModelDB`).

---

## Challenges

### [Low] Challenge 1: Session Abandonment Impact on TempData Flash Messages

- **Assumption challenged**: Calling `/Account/Logout` preserves `TempData["InfoMessage"] = "You have been logged out safely."` on the redirected `/Account/Login` page.
- **Attack scenario**: In `AccountController.cs` (lines 86-88), `Session.Clear()`, `Session.Abandon()`, and `TempData["InfoMessage"] = ...` are executed sequentially. Because ASP.NET MVC 5 utilizes Session state as the default backing store for `TempData`, invoking `Session.Abandon()` causes the session identifier to be discarded, resulting in the loss of `TempData` upon redirection to `/Account/Login`.
- **Blast radius**: Minimal / cosmetic only. Authentication is safely cleared and redirection to `/Account/Login` (HTTP 302) functions reliably. `_Layout.cshtml` correctly renders `.notion-alerts-container` whenever `TempData` is present.
- **Mitigation**: In Milestone 2 (Account modernization), if persistent logout notifications are required, either remove `Session.Abandon()` (relying on `Session.Clear()` and cookie clearance) or pass a query parameter (`/Account/Login?loggedOut=true`).

### [Low] Challenge 2: Visual CSS Uppercase vs Literal HTML Case in Role Badges

- **Assumption challenged**: Role badges in the navigation bar emit uppercase text in raw HTML.
- **Attack scenario**: In `_Navigation.cshtml` (line 34), `@currentUser.Role` outputs `"Admin"` or `"User"` matching database values. The design system stylesheet (`site.css`) applies `.role-badge { text-transform: uppercase; }` to render `ADMIN` or `USER` visually in the browser. Tests expecting uppercase raw HTML strings fail.
- **Blast radius**: Zero runtime failure. Purely an artifact of test assertion design.
- **Mitigation**: Downstream automated tests should assert against CSS class presence (`.badge-admin`, `.badge-user`) or evaluate text content case-insensitively.

### [Info] Challenge 3: Built-in ASP.NET Request Validation on Raw Markup Inputs

- **Assumption challenged**: Passing raw HTML tags to the directory search query parameter (`/Employee/Index?search=<script>`) could cause reflected XSS or bypass filters.
- **Attack scenario**: Sent raw `<script>` in the query string. ASP.NET Framework request validation immediately intercepted the request with `HttpRequestValidationException` (HTTP 500), preventing the unencoded input from reaching the controller. Standard alphanumeric searches (e.g., `search=Rahul`) execute with parameterized SQL queries and return HTTP 200.
- **Blast radius**: Zero vulnerability. Input is rejected before execution.
- **Mitigation**: None required; default ASP.NET security model functions as designed.

---

## Stress Test Results

| Test ID | Category | Scenario | Expected Behavior | Actual Behavior | Result |
|---|---|---|---|---|---|
| C01_01 | Static Assets | GET `/Content/site.css` | HTTP 200, MIME `text/css`, design tokens present | HTTP 200, 29,151 bytes, tokens present | PASS |
| C01_02 | Static Assets | GET `/Scripts/app.js` | HTTP 200, MIME `javascript`, functions present | HTTP 200, 6,843 bytes, functions present | PASS |
| C02_01 | Routing | GET `/` | HTTP 200, resolves to `Employee/Details` | HTTP 200, Title "Employee Details Page" | PASS |
| C02_02 | Routing | GET `/Employee/Index` | HTTP 200, loads SQL Server employee records | HTTP 200, records loaded (`Dillip`, `Rahul`) | PASS |
| C02_03 | Routing | GET `/Student/Index` | HTTP 200, loads SQL Server student records | HTTP 200, students loaded (`Ankur`, `Priya`) | PASS |
| C02_04 | Routing | GET `/Student/getStud` | HTTP 200, ViewModel conditional green/red badges | HTTP 200, marks status badges verified | PASS |
| C02_05 | Routing | GET `/Account/Login` | HTTP 200, renders form and AntiForgeryToken | HTTP 200, CSRF token and fields present | PASS |
| C02_06 | Routing | GET `/Account/Register` | HTTP 200, renders form and AntiForgeryToken | HTTP 200, CSRF token and fields present | PASS |
| C02_07 | Routing | GET `/Admin/Dashboard` unauthenticated | HTTP 302 redirect to `/Account/Login?returnUrl=...` | HTTP 302 to `/Account/Login?returnUrl=...` | PASS |
| C02_08 | Routing | GET `/Admin/Users` unauthenticated | HTTP 302 redirect to `/Account/Login?returnUrl=...` | HTTP 302 to `/Account/Login?returnUrl=...` | PASS |
| C03_01 | Adversarial | Search with SQL injection `' OR 1=1--` | HTTP 200, parameterized SQL, no crash | HTTP 200 without SQL exception | PASS |
| C03_02 | Adversarial | Search with HTML `<script>` | Handled safely by framework validation | HTTP 500 `HttpRequestValidationException` | PASS |
| C03_03 | Adversarial | GET `/Employee/Details/99999` non-existent ID | Handled without server crash | HTTP 200, graceful handling | PASS |
| C04_01 | CSRF Protection | POST `/Account/Login` without CSRF token | HTTP 500 `HttpAntiForgeryException` | HTTP 500, forgery protection confirmed | PASS |
| C05_01 | Authentication | Admin login with credentials & token | HTTP 302 -> `/Admin/Dashboard`, admin chrome | HTTP 302, FullName, badge-admin, links | PASS |
| C05_02 | Authentication | User login with credentials & token | HTTP 302 -> `/Employee/Index`, user chrome | HTTP 302, FullName, badge-user, no admin | PASS |
| C05_03 | Authorization | Standard user accessing Admin routes | HTTP 302 redirect to Login | HTTP 302 redirect to Login | PASS |
| C06_01 | Accessibility | Mobile drawer accessibility attributes | `aria-expanded`, `aria-controls`, valid IDs | All ARIA contracts and IDs verified | PASS |
| C07_01 | Zero Emojis | Regex scan for Unicode emojis in deliverables | Zero matches across all 4 deliverable files | 0 matches found | PASS |
| C08_01 | Compilation | MSBuild of `ViewModelDemo.csproj` | Clean build with 0 warnings, 0 errors | 0 Warning(s), 0 Error(s) | PASS |

---

## Unchallenged Areas

- **Individual Feature View Markup Modernization**: Views under `Views/Account/`, `Views/Admin/`, `Views/Employee/`, and `Views/Student/` remain in their original markup formats from before the modernization project. Their internal restructuring is explicitly planned for Milestone 2 and Milestone 3.
- **Client-Side JavaScript DOM Execution**: Script syntax, function declarations, and event listener setups were verified via static analysis and HTTP delivery. Full headless browser evaluation (e.g. Playwright / Chrome DevTools) will be performed in Milestone 4.
