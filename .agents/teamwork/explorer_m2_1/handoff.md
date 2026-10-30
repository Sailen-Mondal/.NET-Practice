# Handoff Report: Account Views Exploration & Modernization Blueprint (Milestone 2)

**Author**: Account Views Explorer (`explorer_m2_1`)  
**Target Views**:  
- `D:\.NET\ViewModelDemo\Views\Account\Login.cshtml`  
- `D:\.NET\ViewModelDemo\Views\Account\Register.cshtml`  
**Working Directory**: `D:\.NET\.agents\teamwork\explorer_m2_1`  
**Date**: 2026-10-29  
**Status**: Investigation Complete & Blueprint Ready for Implementation  

---

## 1. Observation

### 1.1 Existing File Inventory & Direct Code Inspection

#### A. `D:\.NET\ViewModelDemo\Views\Account\Login.cshtml` (66 lines)
- **Model**: `@model ViewModelDemo.ViewModels.LoginViewModel`
- **Form Begin**: `@using (Html.BeginForm("Login", "Account", FormMethod.Post))` (Line 10)
- **Anti-Forgery & Hidden Fields**:
  - Line 12: `@Html.AntiForgeryToken()`
  - Line 13: `@Html.HiddenFor(m => m.ReturnUrl)`
- **Validation Summary Block**:
  ```cshtml
  15: if (!ViewData.ModelState.IsValid)
  16: {
  17:     <div class="alert alert-danger" style="margin-bottom: 16px;">
  18:         @Html.ValidationSummary(true, "")
  19:     </div>
  20: }
  ```
- **Form Fields**:
  - `UsernameOrEmail` (Lines 22-26): `<label class="form-label" for="UsernameOrEmail">Username or Email</label>`, `@Html.TextBoxFor(m => m.UsernameOrEmail, new { @class = "form-control", placeholder = "e.g. admin or rahul" })`, `@Html.ValidationMessageFor(m => m.UsernameOrEmail, "", new { @class = "text-danger" })`
  - `Password` (Lines 28-32): `<label class="form-label" for="Password">Password</label>`, `@Html.PasswordFor(m => m.Password, new { @class = "form-control", placeholder = "Enter your password" })`, `@Html.ValidationMessageFor(m => m.Password, "", new { @class = "text-danger" })`
  - `RememberMe` (Lines 34-39): Raw `<label style="font-size: 13px; color: #4b5563; display: flex; align-items: center; gap: 6px; cursor: pointer;">`, `@Html.CheckBoxFor(m => m.RememberMe) Remember me</label>`
- **Submit Action**: `<button type="submit" class="btn btn-primary" style="width: 100%; margin-top: 8px;">Sign In</button>` (Line 41)
- **Account Alternate Link**: `<a href="/Account/Register" style="color: var(--primary); text-decoration: none; font-weight: 500;">Register here</a>` (Line 45)
- **Demo Credentials Callout** (Lines 49-64): Hardcoded inline styling with dashed border (`style="background-color: #f9fafb; border-style: dashed;"`), raw code blocks (`style="background: #e5e7eb; padding: 2px 5px; border-radius: 3px;"`), and text without Notion badges.

#### B. `D:\.NET\ViewModelDemo\Views\Account\Register.cshtml` (59 lines)
- **Model**: `@model ViewModelDemo.ViewModels.RegisterViewModel`
- **Form Begin**: `@using (Html.BeginForm("Register", "Account", FormMethod.Post))` (Line 10)
- **Anti-Forgery**: `@Html.AntiForgeryToken()` (Line 12)
- **Validation Summary Block**:
  ```cshtml
  14: if (!ViewData.ModelState.IsValid)
  15: {
  16:     <div class="alert alert-danger" style="margin-bottom: 16px;">
  17:         @Html.ValidationSummary(true, "")
  18:     </div>
  19: }
  ```
- **Form Fields**:
  - `FullName` (Lines 21-25): `@Html.TextBoxFor(m => m.FullName, new { @class = "form-control", placeholder = "e.g. Sneha Roy" })`
  - `Username` (Lines 27-31): `@Html.TextBoxFor(m => m.Username, new { @class = "form-control", placeholder = "e.g. sneha_roy" })`
  - `Email` (Lines 33-37): `@Html.TextBoxFor(m => m.Email, new { @class = "form-control", placeholder = "name@example.com", type = "email" })`
  - `Password` (Lines 39-43): `@Html.PasswordFor(m => m.Password, new { @class = "form-control", placeholder = "Choose a strong password" })`
  - `ConfirmPassword` (Lines 45-49): `@Html.PasswordFor(m => m.ConfirmPassword, new { @class = "form-control", placeholder = "Re-type password" })`
- **Submit Action**: `<button type="submit" class="btn btn-primary" style="width: 100%; margin-top: 12px;">Create Account</button>` (Line 51)
- **Account Alternate Link**: `<a href="/Account/Login" style="color: var(--primary); text-decoration: none; font-weight: 500;">Sign in here</a>` (Line 55)

#### C. `D:\.NET\ViewModelDemo\ViewModels\LoginViewModel.cs` & `RegisterViewModel.cs`
- `LoginViewModel`:
  - `[Required(ErrorMessage = "Username or Email is required")]` -> `UsernameOrEmail`
  - `[Required(ErrorMessage = "Password is required")]`, `[DataType(DataType.Password)]` -> `Password`
  - `[Display(Name = "Remember Me")]` -> `RememberMe`
  - `public string ReturnUrl { get; set; }`
- `RegisterViewModel`:
  - `[Required(ErrorMessage = "Full Name is required")]`, `[StringLength(100, ErrorMessage = "Full Name cannot exceed 100 characters")]` -> `FullName`
  - `[Required(ErrorMessage = "Username is required")]`, `[StringLength(50, MinimumLength = 3, ErrorMessage = "Username must be between 3 and 50 characters")]`, `[RegularExpression(@"^[a-zA-Z0-9_]+$", ErrorMessage = "Username can only contain letters, numbers, and underscores")]` -> `Username`
  - `[Required(ErrorMessage = "Email address is required")]`, `[EmailAddress(ErrorMessage = "Please provide a valid email address")]` -> `Email`
  - `[Required(ErrorMessage = "Password is required")]`, `[StringLength(100, MinimumLength = 6, ErrorMessage = "Password must be at least 6 characters")]`, `[DataType(DataType.Password)]` -> `Password`
  - `[Required(ErrorMessage = "Please confirm your password")]`, `[Compare("Password", ErrorMessage = "Passwords do not match")]` -> `ConfirmPassword`

#### D. `D:\.NET\ViewModelDemo\Controllers\AccountController.cs`
- `Login(string returnUrl)` (GET): sets `ViewBag.ReturnUrl = returnUrl` and initializes `LoginViewModel { ReturnUrl = returnUrl }`.
- `Login(LoginViewModel model)` (POST): validates `ModelState.IsValid`. Validates credentials against `DatabaseHelper.ValidateUser(...)`. If invalid, adds `ModelState.AddModelError("", "Invalid username/email or password.");`. On success, sets `Session["CurrentUser"] = user`, checks `Url.IsLocalUrl(model.ReturnUrl)` to redirect, or redirects to `/Admin/Dashboard` (if `user.IsAdmin`) or `/Employee/Index`.
- `Register()` (GET): initializes `RegisterViewModel`.
- `Register(RegisterViewModel model)` (POST): validates `ModelState.IsValid`. Invokes `DatabaseHelper.RegisterUser(model)`. If fails (e.g. duplicate username or email), adds `ModelState.AddModelError("", result.ErrorMessage);`. On success, auto-logs user in (`Session["CurrentUser"] = result.Session`), sets `TempData["SuccessMessage"]`, and redirects to `/Employee/Index`.
- `Logout()` (GET): clears session, sets `TempData["InfoMessage"] = "You have been logged out safely."`, and redirects to `/Account/Login`.

#### E. `D:\.NET\ViewModelDemo\Content\site.css` Tokens & Components
- Container tokens: `.container-narrow` has `max-width: var(--max-narrow-width);` (480px).
- Surface tokens: `--canvas-bg: #fbfbfa;`, `--surface-card: #ffffff;`, `--surface-subtle: #f7f7f5;`, `--border-color: #e5e7eb;`, `--border-subtle: #eaeaea;`.
- Card classes: `.card`, `.card-header`, `.card-subtitle`.
- Form classes: `.form-group`, `.form-label`, `.required-indicator`, `.form-control`, `.form-hint`, `.form-checkbox-label`, `input[type="checkbox"]` with `accent-color: var(--accent-dark)`.
- Button classes: `.notion-btn`, `.btn`, `.btn-primary`, `.btn-secondary`, `.btn-sm`, `.btn-lg`.
- Validation classes: `.input-validation-error`, `.field-validation-error`, `.text-danger`, `.validation-summary-errors`, `.validation-summary-valid { display: none; }`.
- Badges: `.role-badge`, `.badge-admin`, `.badge-user`.

#### F. Test Assertions in `D:\.NET\ViewModelDemo\Tests\E2E\`
- `T1_F01_01`: Login page returns HTTP 200, contains text "Login", contains inputs `name="UsernameOrEmail"`, `name="Password"`.
- `T1_F01_02`: Admin credentials (`admin` / `Admin@123`) redirect to `/Admin/Dashboard`.
- `T1_F01_03`: User credentials (`rahul` / `User@123`) redirect to `/Employee/Index`.
- `T1_F01_04`: ReturnUrl parameter redirect works on authentication.
- `T1_F01_05`: Email identifier login (`admin@viewmodeldemo.com`) works.
- `T1_F02_01`: Register page returns HTTP 200, contains text "Register", contains inputs `name="FullName"`, `name="Username"`.
- `T1_F02_02` - `T1_F02_05`: User registration, auto-login, username regex validation, and user role assignment.
- `T2_F01_01` & `T2_F01_02`: Invalid credentials check for verbatim error: `"Invalid username/email or password."`.
- `T2_F01_03`: Missing username checks for verbatim error: `"Username or Email is required"`.
- `T2_F01_04`: Missing password checks for verbatim error: `"Password is required"`.
- `T2_F02_01` & `T2_F02_02`: Duplicate username/email checks for verbatim substring: `"already exists"`.
- `T2_F02_03`: Invalid username regex checks for: `"can only contain letters, numbers, and underscores"`.
- `T2_F02_04`: Short password checks for: `"Password must be at least 6 characters"`.
- `T2_F02_05`: Mismatched passwords check for: `"Passwords do not match"`.
- `AdversarialSuite_M1.ps1` C02_05 & C02_06: Both Login and Register must output `__RequestVerificationToken`.
- `TestChallengerM1.ps1`: Zero emojis across all scanned files and outputs.

---

## 2. Logic Chain

1. **Model Binding Integrity**:
   - `LoginViewModel` expects form inputs named `UsernameOrEmail`, `Password`, `RememberMe`, and `ReturnUrl`.
   - `RegisterViewModel` expects `FullName`, `Username`, `Email`, `Password`, and `ConfirmPassword`.
   - Using standard Razor helpers (`@Html.TextBoxFor`, `@Html.PasswordFor`, `@Html.CheckBoxFor`, `@Html.HiddenFor`, and `@Html.AntiForgeryToken()`) guarantees that ASP.NET MVC model binders and anti-forgery filters function without regression.

2. **Validation Display Logic & Empty Red Box Bug Elimination**:
   - In both existing views, `if (!ViewData.ModelState.IsValid)` wrapped `@Html.ValidationSummary(true, "")` inside a `<div class="alert alert-danger">`.
   - Because `ValidationSummary(true, "")` sets `excludePropertyErrors = true`, property-level errors (such as missing username) are excluded from the summary. If only property-level errors exist, `ModelState.IsValid` is `false`, but `ValidationSummary` emits no list items, resulting in an empty red alert box.
   - By refining the check to:
     `if (!ViewData.ModelState.IsValid && ViewData.ModelState[string.Empty] != null && ViewData.ModelState[string.Empty].Errors.Count > 0)`
     the top-level alert box renders exclusively when there are model-level errors (such as "Invalid username/email or password." or "A user with username 'admin' already exists.").
   - Property errors continue to be rendered precisely below each input control via `@Html.ValidationMessageFor(...)` styled with `.field-validation-error text-danger`.

3. **Notion Minimalist Aesthetic & Layout Constraints**:
   - Centered container constrained to `max-width: 420px;` (for Login) and `max-width: 440px;` (for Register) nested inside `.container-narrow`.
   - Card container combines `.card` and `.notion-card`, ensuring automatic adherence to `site.css` tokens (`--surface-card`, `--border-color`, `--shadow-card`, `--radius-lg`) while establishing the `.notion-card` hook.
   - Clean sans-serif typographic hierarchy: brand/security icon badge in neutral `--surface-subtle`, 20px semi-bold heading, 13px muted subtitle.
   - Input controls combine `.form-control` and `.notion-form-input` with accessible HTML5 attributes: `autocomplete`, `spellcheck="false"`, `autocapitalize="none"`, `required="required"`, and `aria-required="true"`.
   - Custom Notion checkbox utilizes the pre-calibrated `.form-checkbox-label` class and dark accent color from `site.css` (line 815).
   - Test credentials section transformed into an understated Notion callout using `--surface-subtle`, monospace code chips, and role badges (`.role-badge.badge-admin` and `.role-badge.badge-user`).

4. **Zero Emojis & Authentic Indian Context**:
   - All visual markers utilize crisp, accessible inline SVGs with `aria-hidden="true"`. Strictly zero emoji glyphs.
   - Input placeholders and sample data incorporate realistic Indian names and domains: `"e.g. rahul.sharma or admin"`, `"e.g. Rahul Sharma"`, `"e.g. rahul_sharma"`, `"e.g. rahul.sharma@example.in"`.

---

## 3. Caveats

1. **Read-Only Explorer Scope**: As an explorer subagent, I do not directly overwrite `Login.cshtml` or `Register.cshtml`. Complete, production-grade drop-in markup is supplied in Section 4 below for the implementer agent.
2. **Client-Side Scripts**: The application does not bundle client-side jQuery Unobtrusive Validation in `_Layout.cshtml`. Validation errors are handled via ASP.NET MVC server-side round-trips with `ModelState` re-rendering. This architecture must remain intact.
3. **Open Redirect Mitigation**: Controller action `AccountController.Login` enforces `Url.IsLocalUrl(model.ReturnUrl)`. Preserving `@Html.HiddenFor(m => m.ReturnUrl)` and passing `ReturnUrl` in the action parameters preserves both local redirection and malicious open-redirect prevention (verified in test `T2_F01_05`).
4. **CSS Token Complement**: `site.css` contains `.card` and `.form-control`. Using both classes (`class="card notion-card"` and `class="form-control notion-form-input"`) provides full backwards and forward compatibility. A supplementary 10-line CSS enhancement is documented in Section 4.3.

---

## 4. Conclusion & Ready-to-Implement Proposals

### 4.1 Modernized `D:\.NET\ViewModelDemo\Views\Account\Login.cshtml`

```cshtml
@model ViewModelDemo.ViewModels.LoginViewModel
@{
    ViewBag.Title = "Login";
}

<div class="container-narrow" style="max-width: 420px; margin: 32px auto 48px auto;">
    <!-- Main Login Card -->
    <div class="card notion-card">
        <!-- Card Brand / Header -->
        <div style="text-align: center; margin-bottom: 24px;">
            <div style="width: 44px; height: 44px; margin: 0 auto 12px auto; background-color: var(--surface-subtle); border: 1px solid var(--border-subtle); border-radius: var(--radius-md); display: flex; align-items: center; justify-content: center; color: var(--text-dark);">
                <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
                    <rect x="3" y="11" width="18" height="11" rx="2" ry="2"></rect>
                    <path d="M7 11V7a5 5 0 0 1 10 0v4"></path>
                </svg>
            </div>
            <h1 class="page-title" style="font-size: 20px; font-weight: 600; margin: 0 0 6px 0; color: var(--text-dark); letter-spacing: -0.02em;">Sign in to your account</h1>
            <p class="page-subtitle" style="font-size: 13px; color: var(--text-secondary); margin: 0;">Enter your credentials to access your workspace</p>
        </div>

        @using (Html.BeginForm("Login", "Account", new { ReturnUrl = Model != null ? Model.ReturnUrl : ViewBag.ReturnUrl }, FormMethod.Post, new { role = "form", @class = "notion-form", id = "loginForm" }))
        {
            @Html.AntiForgeryToken()
            @Html.HiddenFor(m => m.ReturnUrl)

            if (!ViewData.ModelState.IsValid && ViewData.ModelState[string.Empty] != null && ViewData.ModelState[string.Empty].Errors.Count > 0)
            {
                <div class="alert alert-danger" role="alert" style="margin-bottom: 18px;">
                    <div class="alert-content">
                        <svg class="alert-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
                            <circle cx="12" cy="12" r="10"></circle>
                            <line x1="12" y1="8" x2="12" y2="12"></line>
                            <line x1="12" y1="16" x2="12.01" y2="16"></line>
                        </svg>
                        <div>
                            @Html.ValidationSummary(true, "")
                        </div>
                    </div>
                </div>
            }

            <div class="form-group">
                <label class="form-label" for="UsernameOrEmail">
                    Username or Email <span class="required-indicator" aria-hidden="true">*</span>
                </label>
                @Html.TextBoxFor(m => m.UsernameOrEmail, new {
                    @class = "form-control notion-form-input",
                    placeholder = "e.g. rahul.sharma or admin",
                    autocomplete = "username",
                    autocapitalize = "none",
                    spellcheck = "false",
                    required = "required",
                    aria_required = "true"
                })
                @Html.ValidationMessageFor(m => m.UsernameOrEmail, "", new { @class = "field-validation-error text-danger" })
            </div>

            <div class="form-group">
                <label class="form-label" for="Password">
                    Password <span class="required-indicator" aria-hidden="true">*</span>
                </label>
                @Html.PasswordFor(m => m.Password, new {
                    @class = "form-control notion-form-input",
                    placeholder = "Enter your password",
                    autocomplete = "current-password",
                    required = "required",
                    aria_required = "true"
                })
                @Html.ValidationMessageFor(m => m.Password, "", new { @class = "field-validation-error text-danger" })
            </div>

            <div class="form-group" style="display: flex; align-items: center; justify-content: space-between; margin-top: 14px; margin-bottom: 22px;">
                <label class="form-checkbox-label" for="RememberMe">
                    @Html.CheckBoxFor(m => m.RememberMe, new { id = "RememberMe" })
                    <span>Remember me on this device</span>
                </label>
            </div>

            <button type="submit" class="btn btn-primary notion-btn notion-btn-primary" style="width: 100%; justify-content: center; padding: 9px 16px; font-weight: 500;">
                <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" style="margin-right: 4px;">
                    <path d="M15 3h4a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2h-4"></path>
                    <polyline points="10 17 15 12 10 7"></polyline>
                    <line x1="15" y1="12" x2="3" y2="12"></line>
                </svg>
                <span>Sign In</span>
            </button>
        }

        <!-- Registration Link -->
        <div style="margin-top: 24px; padding-top: 18px; border-top: 1px solid var(--border-subtle); font-size: 13px; color: var(--text-secondary); text-align: center;">
            Don't have an account? <a href="/Account/Register" style="color: var(--text-dark); text-decoration: underline; text-underline-offset: 3px; font-weight: 500;">Register here</a>
        </div>
    </div>

    <!-- Demo Credentials Card -->
    <div class="card notion-card" style="background-color: var(--surface-subtle); border: 1px solid var(--border-subtle); padding: 18px 20px;">
        <div style="display: flex; align-items: center; gap: 8px; margin-bottom: 12px;">
            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" style="color: var(--text-secondary);">
                <circle cx="12" cy="12" r="10"></circle>
                <line x1="12" y1="16" x2="12" y2="12"></line>
                <line x1="12" y1="8" x2="12.01" y2="8"></line>
            </svg>
            <span style="font-size: 11.5px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em; color: var(--text-secondary);">
                Pre-Configured Test Accounts
            </span>
        </div>
        <div style="font-size: 12.5px; line-height: 1.5; display: flex; flex-direction: column; gap: 10px;">
            <div style="padding: 10px 12px; background-color: var(--surface-card); border: 1px solid var(--border-light); border-radius: var(--radius-sm);">
                <div style="display: flex; align-items: center; justify-content: space-between; margin-bottom: 4px;">
                    <span style="font-weight: 600; color: var(--text-dark);">Administrator</span>
                    <span class="role-badge badge-admin">Admin</span>
                </div>
                <div style="color: var(--text-secondary); font-size: 12px; margin-bottom: 6px;">Full CRUD operations and administrative dashboard</div>
                <div style="font-family: var(--font-mono); font-size: 11.5px; color: var(--text-primary); display: flex; gap: 6px; align-items: center;">
                    <code style="background-color: var(--surface-hover); padding: 2px 6px; border-radius: 3px;">admin</code>
                    <span style="color: var(--text-tertiary);">&bull;</span>
                    <code style="background-color: var(--surface-hover); padding: 2px 6px; border-radius: 3px;">Admin@123</code>
                </div>
            </div>
            <div style="padding: 10px 12px; background-color: var(--surface-card); border: 1px solid var(--border-light); border-radius: var(--radius-sm);">
                <div style="display: flex; align-items: center; justify-content: space-between; margin-bottom: 4px;">
                    <span style="font-weight: 600; color: var(--text-dark);">Standard User</span>
                    <span class="role-badge badge-user">User</span>
                </div>
                <div style="color: var(--text-secondary); font-size: 12px; margin-bottom: 6px;">Employee directory and student marks presentation</div>
                <div style="font-family: var(--font-mono); font-size: 11.5px; color: var(--text-primary); display: flex; gap: 6px; align-items: center;">
                    <code style="background-color: var(--surface-hover); padding: 2px 6px; border-radius: 3px;">rahul</code>
                    <span style="color: var(--text-tertiary);">&bull;</span>
                    <code style="background-color: var(--surface-hover); padding: 2px 6px; border-radius: 3px;">User@123</code>
                </div>
            </div>
        </div>
    </div>
</div>
```

---

### 4.2 Modernized `D:\.NET\ViewModelDemo\Views\Account\Register.cshtml`

```cshtml
@model ViewModelDemo.ViewModels.RegisterViewModel
@{
    ViewBag.Title = "Register";
}

<div class="container-narrow" style="max-width: 440px; margin: 32px auto 48px auto;">
    <!-- Main Registration Card -->
    <div class="card notion-card">
        <!-- Card Header -->
        <div style="text-align: center; margin-bottom: 24px;">
            <div style="width: 44px; height: 44px; margin: 0 auto 12px auto; background-color: var(--surface-subtle); border: 1px solid var(--border-subtle); border-radius: var(--radius-md); display: flex; align-items: center; justify-content: center; color: var(--text-dark);">
                <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
                    <path d="M16 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path>
                    <circle cx="8.5" cy="7" r="4"></circle>
                    <line x1="20" y1="8" x2="20" y2="14"></line>
                    <line x1="23" y1="11" x2="17" y2="11"></line>
                </svg>
            </div>
            <h1 class="page-title" style="font-size: 20px; font-weight: 600; margin: 0 0 6px 0; color: var(--text-dark); letter-spacing: -0.02em;">Create a New Account</h1>
            <p class="page-subtitle" style="font-size: 13px; color: var(--text-secondary); margin: 0;">Register to access the ViewModel Architecture portal</p>
        </div>

        @using (Html.BeginForm("Register", "Account", FormMethod.Post, new { role = "form", @class = "notion-form", id = "registerForm" }))
        {
            @Html.AntiForgeryToken()

            if (!ViewData.ModelState.IsValid && ViewData.ModelState[string.Empty] != null && ViewData.ModelState[string.Empty].Errors.Count > 0)
            {
                <div class="alert alert-danger" role="alert" style="margin-bottom: 18px;">
                    <div class="alert-content">
                        <svg class="alert-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
                            <circle cx="12" cy="12" r="10"></circle>
                            <line x1="12" y1="8" x2="12" y2="12"></line>
                            <line x1="12" y1="16" x2="12.01" y2="16"></line>
                        </svg>
                        <div>
                            @Html.ValidationSummary(true, "")
                        </div>
                    </div>
                </div>
            }

            <div class="form-group">
                <label class="form-label" for="FullName">
                    Full Name <span class="required-indicator" aria-hidden="true">*</span>
                </label>
                @Html.TextBoxFor(m => m.FullName, new {
                    @class = "form-control notion-form-input",
                    placeholder = "e.g. Rahul Sharma",
                    autocomplete = "name",
                    required = "required",
                    aria_required = "true"
                })
                @Html.ValidationMessageFor(m => m.FullName, "", new { @class = "field-validation-error text-danger" })
            </div>

            <div class="form-group">
                <label class="form-label" for="Username">
                    Username <span class="required-indicator" aria-hidden="true">*</span>
                </label>
                @Html.TextBoxFor(m => m.Username, new {
                    @class = "form-control notion-form-input",
                    placeholder = "e.g. rahul_sharma",
                    autocomplete = "username",
                    autocapitalize = "none",
                    spellcheck = "false",
                    required = "required",
                    aria_required = "true"
                })
                <div class="form-hint" style="font-size: 11.5px; color: var(--text-tertiary); margin-top: 4px;">
                    3-50 characters: letters, numbers, and underscores only
                </div>
                @Html.ValidationMessageFor(m => m.Username, "", new { @class = "field-validation-error text-danger" })
            </div>

            <div class="form-group">
                <label class="form-label" for="Email">
                    Email Address <span class="required-indicator" aria-hidden="true">*</span>
                </label>
                @Html.TextBoxFor(m => m.Email, new {
                    @class = "form-control notion-form-input",
                    placeholder = "e.g. rahul.sharma@example.in",
                    type = "email",
                    autocomplete = "email",
                    autocapitalize = "none",
                    spellcheck = "false",
                    required = "required",
                    aria_required = "true"
                })
                @Html.ValidationMessageFor(m => m.Email, "", new { @class = "field-validation-error text-danger" })
            </div>

            <div class="form-group">
                <label class="form-label" for="Password">
                    Password <span class="required-indicator" aria-hidden="true">*</span>
                </label>
                @Html.PasswordFor(m => m.Password, new {
                    @class = "form-control notion-form-input",
                    placeholder = "Choose a strong password (min 6 characters)",
                    autocomplete = "new-password",
                    required = "required",
                    aria_required = "true"
                })
                @Html.ValidationMessageFor(m => m.Password, "", new { @class = "field-validation-error text-danger" })
            </div>

            <div class="form-group">
                <label class="form-label" for="ConfirmPassword">
                    Confirm Password <span class="required-indicator" aria-hidden="true">*</span>
                </label>
                @Html.PasswordFor(m => m.ConfirmPassword, new {
                    @class = "form-control notion-form-input",
                    placeholder = "Re-enter your password",
                    autocomplete = "new-password",
                    required = "required",
                    aria_required = "true"
                })
                @Html.ValidationMessageFor(m => m.ConfirmPassword, "", new { @class = "field-validation-error text-danger" })
            </div>

            <button type="submit" class="btn btn-primary notion-btn notion-btn-primary" style="width: 100%; justify-content: center; padding: 9px 16px; font-weight: 500; margin-top: 6px;">
                <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" style="margin-right: 4px;">
                    <path d="M16 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path>
                    <circle cx="8.5" cy="7" r="4"></circle>
                    <line x1="20" y1="8" x2="20" y2="14"></line>
                    <line x1="23" y1="11" x2="17" y2="11"></line>
                </svg>
                <span>Create Account</span>
            </button>
        }

        <!-- Login Link -->
        <div style="margin-top: 24px; padding-top: 18px; border-top: 1px solid var(--border-subtle); font-size: 13px; color: var(--text-secondary); text-align: center;">
            Already registered? <a href="/Account/Login" style="color: var(--text-dark); text-decoration: underline; text-underline-offset: 3px; font-weight: 500;">Sign in here</a>
        </div>
    </div>
</div>
```

---

### 4.3 Supplementary CSS Enhancement (Optional in `site.css`)

To formalize `.notion-card` and `.notion-form-input` as standard aliases alongside `.card` and `.form-control` in `D:\.NET\ViewModelDemo\Content\site.css`:

```css
/* Card alias */
.notion-card {
    background-color: var(--surface-card);
    border: 1px solid var(--border-color);
    border-radius: var(--radius-lg);
    padding: 24px;
    box-shadow: var(--shadow-card);
    margin-bottom: 20px;
    transition: border-color var(--transition-fast);
}

/* Form input alias */
.notion-form-input {
    width: 100%;
    padding: 8px 12px;
    font-size: 13.5px;
    line-height: 1.45;
    color: var(--text-dark);
    background-color: var(--surface-card);
    border: 1px solid var(--border-medium);
    border-radius: var(--radius-md);
    transition: border-color var(--transition-fast), box-shadow var(--transition-fast);
    outline: none;
    font-family: inherit;
}
```

---

## 5. Verification Method

### 5.1 Compilation Verification
To confirm that the Razor syntax and model binding compile cleanly without any syntax errors:
```powershell
& "C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe" "D:\.NET\ViewModelDemo\ViewModelDemo.csproj" /p:Configuration=Debug /t:Build /v:m
```
*Expected Result*: Build succeeded with 0 Errors, 0 Warnings.

### 5.2 Test Suite Execution
Run the full E2E test harness covering features F01 (Login), F02 (Register), and F03 (Logout):
```powershell
powershell -ExecutionPolicy Bypass -File "D:\.NET\ViewModelDemo\Tests\E2E\Run-E2ETests.ps1"
```
Specific tests that must pass:
- `T1_F01_01` through `T1_F01_05` (Login HTTP 200, Admin redirect, User redirect, ReturnUrl redirect, Email identifier login)
- `T1_F02_01` through `T1_F02_05` (Register HTTP 200, Registration redirect, Auto-login, Username regex, User role assignment)
- `T1_F03_01` & `T1_F03_02` (Logout redirect and guest session confirmation)
- `T2_F01_01` through `T2_F01_05` (Invalid credentials, empty username, empty password, open redirect defense)
- `T2_F02_01` through `T2_F02_05` (Duplicate username/email, regex validation, min password length, mismatch password)
- `AdversarialSuite_M1.ps1` checks `C02_05` and `C02_06` (AntiForgeryToken presence on Login and Register)

### 5.3 Zero Emojis Scan
Verify zero emoji characters are present in the view files:
```powershell
$emojiPattern = '[\uD83C-\uDBFF\uDC00-\uDFFF\u2600-\u27BF\u2300-\u23FF\u2B50-\u2B55\u203C\u2049\u2139\u2194-\u21AA]'
$files = @("D:\.NET\ViewModelDemo\Views\Account\Login.cshtml", "D:\.NET\ViewModelDemo\Views\Account\Register.cshtml")
foreach ($f in $files) {
    $content = [System.IO.File]::ReadAllText($f)
    if ([System.Text.RegularExpressions.Regex]::IsMatch($content, $emojiPattern)) {
        Write-Error "Emoji detected in $f"
    } else {
        Write-Host "Verified clean: $f"
    }
}
```

### 5.4 Invalidation Conditions
The blueprint is invalidated if:
1. Form input names are modified (e.g. changing `UsernameOrEmail` or `ConfirmPassword`), causing ASP.NET MVC model binding to fail.
2. AntiForgeryToken helper `@Html.AntiForgeryToken()` is omitted or placed outside the `<form>` element.
3. ReturnUrl hidden input `@Html.HiddenFor(m => m.ReturnUrl)` is omitted, breaking post-login redirect routing.
4. Any emoji character is added.
