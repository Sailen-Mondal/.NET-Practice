# Specification Document: ViewModel Architecture Demo (ViewModelDemo)

**Target Application**: D:\.NET\ViewModelDemo  
**Specification Miner**: spec_miner_vmd_1  
**Generated Date**: 2026-10-29  
**Runtime Target**: .NET Framework 4.8.1 / ASP.NET MVC 5.2.9  
**Database**: Microsoft SQL Server (`ViewModelDB`)  

---

## 1. Overview and Architecture

`ViewModelDemo` is an ASP.NET MVC 5 web application demonstrating practical enterprise ViewModel patterns combined with direct ADO.NET data access. The application showcases how ViewModels decouple database domain entities from presentation requirements, support multi-model aggregation, enforce clean input validation, and handle role-based user authentication.

### Core Architectural Patterns
1. **Domain Model Separation**:
   - Entities (`Address`, `Employee`, `Student`, `User`) map directly to relational tables.
2. **ViewModel Patterns**:
   - **Multi-Model Aggregation**: Combining `Employee` and `Address` into `EmployeeDetailsViewModel`.
   - **Composite Multi-Table Form**: `EmployeeFormViewModel` encapsulates fields for both `Employees` and `Addresses` tables within a single form, handled through an atomic `SqlTransaction`.
   - **Presentation / UI Logic Encapsulation**: `vmStudMarks` calculates dynamic visual status (e.g., green for pass, red for fail) without polluting domain entities.
   - **Dashboard Aggregation**: `AdminDashboardViewModel` aggregates statistics, dictionary distributions, and recent record subsets.
   - **Authentication / Membership**: `LoginViewModel` and `RegisterViewModel` encapsulate credential collection and validation rules.
3. **Data Access Layer (DAL)**:
   - Direct ADO.NET (`System.Data.SqlClient`) encapsulated inside `DatabaseHelper`.
   - Parameterized SQL commands to eliminate SQL injection.
   - Deterministic connection lifetime with `using` blocks (`SqlConnection`, `SqlCommand`, `SqlDataReader`).
   - Transactional integrity using `SqlTransaction` with commit and rollback for multi-table mutations.
   - High-availability dev fallback: In the event of database connectivity interruption, graceful fallback datasets ensure continuous developer testing.
4. **Session Authentication & Role-Based Access Control**:
   - In-memory session authentication key: `Session["CurrentUser"]` holding a `UserSession` object.
   - Roles: `Admin` (full CRUD, user management, metrics dashboard) and `User` (read-only directory and student views).

---

## 2. Database Schema (ViewModelDB)

The database schema is defined in `App_Data\ViewModelDB_Setup.sql`. All tables reside under the `dbo` schema.

### 2.1 Table: dbo.Addresses
Stores residential and geographical location data for employees.

| Column | Data Type | Nullable | Constraints / Identity | Description |
|---|---|---|---|---|
| `AddressId` | `INT` | No | `PRIMARY KEY IDENTITY(1001, 1)` | Unique address identifier |
| `Country` | `NVARCHAR(100)` | No | None | Country name (default: 'India') |
| `State` | `NVARCHAR(100)` | No | None | State / Province |
| `City` | `NVARCHAR(100)` | No | None | City name |
| `Pin` | `NVARCHAR(20)` | No | None | Postal PIN code |

### 2.2 Table: dbo.Employees
Stores employee master records with a foreign key reference to `dbo.Addresses`.

| Column | Data Type | Nullable | Constraints / Identity | Description |
|---|---|---|---|---|
| `EmployeeId` | `INT` | No | `PRIMARY KEY IDENTITY(101, 1)` | Unique employee identifier |
| `Name` | `NVARCHAR(150)` | No | None | Employee full name |
| `Gender` | `NVARCHAR(20)` | No | None | Gender (Male, Female, Other) |
| `Department` | `NVARCHAR(100)` | No | None | Department name |
| `Salary` | `DECIMAL(18, 2)` | No | None | Monthly salary in INR |
| `AddressId` | `INT` | No | `FOREIGN KEY REFERENCES dbo.Addresses(AddressId)` | Linked address |

### 2.3 Table: dbo.Students
Demonstrates raw domain model vs ViewModel presentation layer.

| Column | Data Type | Nullable | Constraints / Identity | Description |
|---|---|---|---|---|
| `RollNo` | `INT` | No | `PRIMARY KEY` | Student roll number |
| `Name` | `NVARCHAR(150)` | No | None | Student full name |
| `Marks` | `FLOAT` | No | None | Academic score |

### 2.4 Table: dbo.Users
Stores credentials and authorization roles for session-based authentication.

| Column | Data Type | Nullable | Constraints / Identity | Description |
|---|---|---|---|---|
| `UserId` | `INT` | No | `PRIMARY KEY IDENTITY(1, 1)` | Unique user identifier |
| `Username` | `NVARCHAR(50)` | No | `UNIQUE` | Unique login username |
| `Email` | `NVARCHAR(100)` | No | `UNIQUE` | Unique email address |
| `PasswordHash` | `NVARCHAR(256)` | No | None | Stored credential |
| `FullName` | `NVARCHAR(100)` | No | None | User display name |
| `Role` | `NVARCHAR(20)` | No | `DEFAULT 'User'` | Role: 'Admin' or 'User' |
| `CreatedAt` | `DATETIME` | No | `DEFAULT GETDATE()` | Account creation timestamp |

---

## 3. ADO.NET Data Access Architecture and Query Catalog

The data access layer is located in `Data\DatabaseHelper.cs`. Connection strings are loaded from `ConfigurationManager.ConnectionStrings["ViewModelDB"]`.

```
Connection String:
Data Source=.;Initial Catalog=ViewModelDB;User ID=sa;Password=mcc#1234;TrustServerCertificate=True;Connect Timeout=3
```

### 3.1 SQL Query Catalog

#### Q01: User Validation (`DatabaseHelper.ValidateUser`)
- **Query Type**: Parameterized SELECT
- **Parameters**: `@Input` (string), `@Password` (string)
- **SQL Text**:
  ```sql
  SELECT UserId, Username, Email, FullName, Role
  FROM dbo.Users
  WHERE (Username = @Input OR Email = @Input)
    AND PasswordHash = @Password
  ```
- **Returns**: Populated `UserSession` object or `null`.

#### Q02: Check User Exists (`DatabaseHelper.RegisterUser`)
- **Query Type**: Parameterized SELECT COUNT
- **Parameters**: `@Username` (string), `@Email` (string)
- **SQL Text**:
  ```sql
  SELECT COUNT(1) FROM dbo.Users WHERE Username = @Username OR Email = @Email
  ```

#### Q03: Insert User (`DatabaseHelper.RegisterUser`)
- **Query Type**: Parameterized INSERT with `SCOPE_IDENTITY()`
- **Parameters**: `@Username`, `@Email`, `@Password`, `@FullName`
- **SQL Text**:
  ```sql
  INSERT INTO dbo.Users (Username, Email, PasswordHash, FullName, Role, CreatedAt)
  VALUES (@Username, @Email, @Password, @FullName, 'User', GETDATE());
  SELECT SCOPE_IDENTITY();
  ```

#### Q04: Select All Users (`DatabaseHelper.GetAllUsers`)
- **Query Type**: Parameterized SELECT
- **SQL Text**:
  ```sql
  SELECT UserId, Username, Email, FullName, Role, CreatedAt FROM dbo.Users ORDER BY UserId DESC
  ```

#### Q05: Admin Dashboard Aggregates (`DatabaseHelper.GetAdminDashboardData`)
- **Query Type**: Aggregate SELECTs & Group By
- **SQL Text 1 (Employee Metrics)**:
  ```sql
  SELECT COUNT(1) AS TotalCount,
         ISNULL(SUM(Salary), 0) AS TotalSalary,
         ISNULL(AVG(Salary), 0) AS AvgSalary
  FROM dbo.Employees
  ```
- **SQL Text 2 (Total Users)**:
  ```sql
  SELECT COUNT(1) FROM dbo.Users
  ```
- **SQL Text 3 (Department Breakdown)**:
  ```sql
  SELECT Department, COUNT(1) AS Cnt FROM dbo.Employees GROUP BY Department
  ```
- **SQL Text 4 (Recent Employees - Top 5)**:
  ```sql
  SELECT TOP 5 e.EmployeeId, e.Name, e.Gender, e.Department, e.Salary, e.AddressId,
               a.City, a.State, a.Country
  FROM dbo.Employees e
  INNER JOIN dbo.Addresses a ON e.AddressId = a.AddressId
  ORDER BY e.EmployeeId DESC
  ```
- **SQL Text 5 (Recent Users - Top 5)**:
  ```sql
  SELECT TOP 5 UserId, Username, Email, FullName, Role, CreatedAt FROM dbo.Users ORDER BY UserId DESC
  ```

#### Q06: Directory Search and Listing (`DatabaseHelper.GetAllEmployees`)
- **Query Type**: Parameterized INNER JOIN SELECT with dynamic WHERE
- **Parameters**: `@Search` (optional string with `%` wildcards)
- **SQL Text**:
  ```sql
  SELECT e.EmployeeId, e.Name, e.Gender, e.Department, e.Salary, e.AddressId,
         a.City, a.State, a.Country
  FROM dbo.Employees e
  INNER JOIN dbo.Addresses a ON e.AddressId = a.AddressId
  [WHERE e.Name LIKE @Search OR e.Department LIKE @Search OR a.City LIKE @Search]
  ORDER BY e.EmployeeId ASC
  ```

#### Q07: Employee For Edit / Delete (`DatabaseHelper.GetEmployeeForEdit`)
- **Query Type**: Parameterized INNER JOIN SELECT
- **Parameters**: `@EmployeeId` (int)
- **SQL Text**:
  ```sql
  SELECT e.EmployeeId, e.Name, e.Gender, e.Department, e.Salary, e.AddressId,
         a.Country, a.State, a.City, a.Pin
  FROM dbo.Employees e
  INNER JOIN dbo.Addresses a ON e.AddressId = a.AddressId
  WHERE e.EmployeeId = @EmployeeId
  ```

#### Q08: Employee Create - Multi-Table Transaction (`DatabaseHelper.SaveEmployee` when `EmployeeId == 0`)
- **Transaction**: Managed by `conn.BeginTransaction()`
- **Step 1: Insert Address**:
  ```sql
  INSERT INTO dbo.Addresses (Country, State, City, Pin)
  VALUES (@Country, @State, @City, @Pin);
  SELECT SCOPE_IDENTITY();
  ```
- **Step 2: Insert Employee**:
  ```sql
  INSERT INTO dbo.Employees (Name, Gender, Department, Salary, AddressId)
  VALUES (@Name, @Gender, @Department, @Salary, @AddressId);
  SELECT SCOPE_IDENTITY();
  ```

#### Q09: Employee Update - Multi-Table Transaction (`DatabaseHelper.SaveEmployee` when `EmployeeId > 0`)
- **Transaction**: Managed by `conn.BeginTransaction()`
- **Step 1: Update Address**:
  ```sql
  UPDATE dbo.Addresses
  SET Country = @Country, State = @State, City = @City, Pin = @Pin
  WHERE AddressId = @AddressId
  ```
- **Step 2: Update Employee**:
  ```sql
  UPDATE dbo.Employees
  SET Name = @Name, Gender = @Gender, Department = @Department, Salary = @Salary
  WHERE EmployeeId = @EmployeeId
  ```

#### Q10: Employee Delete - Multi-Table Transaction (`DatabaseHelper.DeleteEmployee`)
- **Transaction**: Managed by `conn.BeginTransaction()`
- **Step 1: Lookup AddressId**:
  ```sql
  SELECT AddressId FROM dbo.Employees WHERE EmployeeId = @EmployeeId
  ```
- **Step 2: Delete Employee**:
  ```sql
  DELETE FROM dbo.Employees WHERE EmployeeId = @EmployeeId
  ```
- **Step 3: Delete Address**:
  ```sql
  DELETE FROM dbo.Addresses WHERE AddressId = @AddressId
  ```

#### Q11: Get Employee With Address (`DatabaseHelper.GetEmployeeWithAddress`)
- **Query Type**: Parameterized INNER JOIN SELECT
- **Parameters**: `@EmployeeId` (int, default 101)
- **SQL Text**:
  ```sql
  SELECT e.EmployeeId, e.Name, e.Gender, e.Department, e.Salary, e.AddressId,
         a.Country, a.State, a.City, a.Pin
  FROM dbo.Employees e
  INNER JOIN dbo.Addresses a ON e.AddressId = a.AddressId
  WHERE e.EmployeeId = @EmployeeId
  ```

#### Q12: Get Students List (`DatabaseHelper.GetStudents`)
- **Query Type**: Parameterized SELECT
- **SQL Text**:
  ```sql
  SELECT RollNo, Name, Marks FROM dbo.Students ORDER BY RollNo ASC
  ```

---

## 4. Models and ViewModels Specification

### 4.1 Domain Models (`ViewModelDemo.Models`)

#### `Address`
- `AddressId`: `int` (PK)
- `Country`: `string`
- `State`: `string`
- `City`: `string`
- `Pin`: `string`

#### `Employee`
- `EmployeeId`: `int` (PK)
- `Name`: `string`
- `Gender`: `string`
- `Department`: `string`
- `Salary`: `decimal`
- `AddressId`: `int` (FK)

#### `Student`
- `RollNo`: `int` (PK)
- `Name`: `string`
- `Marks`: `double`

#### `User`
- `UserId`: `int` (PK)
- `Username`: `string`
- `Email`: `string`
- `FullName`: `string`
- `Role`: `string`
- `CreatedAt`: `DateTime`

#### `UserSession`
- `UserId`: `int`
- `Username`: `string`
- `Email`: `string`
- `FullName`: `string`
- `Role`: `string`
- `IsAdmin`: `bool` (Computed: `string.Equals(Role, "Admin", StringComparison.OrdinalIgnoreCase)`)

---

### 4.2 ViewModels (`ViewModelDemo.ViewModels`)

#### `LoginViewModel`
| Property | Type | Attributes | Description |
|---|---|---|---|
| `UsernameOrEmail` | `string` | `[Required(ErrorMessage = "Username or Email is required")]`<br>`[Display(Name = "Username or Email")]` | Login identifier |
| `Password` | `string` | `[Required(ErrorMessage = "Password is required")]`<br>`[DataType(DataType.Password)]` | Secret credential |
| `RememberMe` | `bool` | `[Display(Name = "Remember Me")]` | Remember flag |
| `ReturnUrl` | `string` | None | Redirect destination upon successful sign-in |

#### `RegisterViewModel`
| Property | Type | Attributes | Description |
|---|---|---|---|
| `FullName` | `string` | `[Required(ErrorMessage = "Full Name is required")]`<br>`[StringLength(100, ErrorMessage = "Full Name cannot exceed 100 characters")]`<br>`[Display(Name = "Full Name")]` | User's complete display name |
| `Username` | `string` | `[Required(ErrorMessage = "Username is required")]`<br>`[StringLength(50, MinimumLength = 3, ErrorMessage = "Username must be between 3 and 50 characters")]`<br>`[RegularExpression(@"^[a-zA-Z0-9_]+$", ErrorMessage = "Username can only contain letters, numbers, and underscores")]` | Unique alphanumeric handle |
| `Email` | `string` | `[Required(ErrorMessage = "Email address is required")]`<br>`[EmailAddress(ErrorMessage = "Please provide a valid email address")]` | Valid RFC-compliant email |
| `Password` | `string` | `[Required(ErrorMessage = "Password is required")]`<br>`[StringLength(100, MinimumLength = 6, ErrorMessage = "Password must be at least 6 characters")]`<br>`[DataType(DataType.Password)]` | Account password |
| `ConfirmPassword` | `string` | `[Required(ErrorMessage = "Please confirm your password")]`<br>`[DataType(DataType.Password)]`<br>`[Compare("Password", ErrorMessage = "Passwords do not match")]`<br>`[Display(Name = "Confirm Password")]` | Password confirmation |

#### `EmployeeFormViewModel` (Composite Create & Edit Model)
| Property | Type | Attributes | Description |
|---|---|---|---|
| `EmployeeId` | `int` | None | Primary Key (0 indicates Create, >0 indicates Edit) |
| `Name` | `string` | `[Required(ErrorMessage = "Employee Name is required")]`<br>`[StringLength(150, ErrorMessage = "Name cannot exceed 150 characters")]`<br>`[Display(Name = "Full Name")]` | Full name of employee |
| `Gender` | `string` | `[Required(ErrorMessage = "Gender is required")]` | Selection: Male, Female, Other |
| `Department` | `string` | `[Required(ErrorMessage = "Department is required")]`<br>`[StringLength(100, ErrorMessage = "Department cannot exceed 100 characters")]` | Selection: Engineering, IT, HR, Finance, Marketing, Operations |
| `Salary` | `decimal` | `[Required(ErrorMessage = "Salary is required")]`<br>`[Range(1000, 10000000, ErrorMessage = "Salary must be between Rs. 1,000 and Rs. 10,000,000")]` | Monthly compensation |
| `AddressId` | `int` | None | Associated Address Foreign Key |
| `Country` | `string` | `[Required(ErrorMessage = "Country is required")]`<br>`[StringLength(100)]` | Country (default: "India") |
| `State` | `string` | `[Required(ErrorMessage = "State is required")]`<br>`[StringLength(100)]` | State / Region |
| `City` | `string` | `[Required(ErrorMessage = "City is required")]`<br>`[StringLength(100)]` | City |
| `Pin` | `string` | `[Required(ErrorMessage = "PIN Code is required")]`<br>`[StringLength(20)]`<br>`[Display(Name = "PIN Code")]` | Postal code |
| `IsEditMode` | `bool` | Computed: `EmployeeId > 0` | Edit state detector |
| `PageTitle` | `string` | Computed: `IsEditMode ? "Edit Employee" : "Add New Employee"` | Dynamic view title |
| `PageHeader` | `string` | Computed: `IsEditMode ? "Update Employee Details" : "Create Employee Record"` | Dynamic heading |
| `SubmitButtonText` | `string` | Computed: `IsEditMode ? "Save Changes" : "Create Employee"` | Dynamic button caption |

#### `EmployeeListItemViewModel` (Directory and Dashboard List)
| Property | Type | Attributes / Computed | Description |
|---|---|---|---|
| `EmployeeId` | `int` | None | Primary Key |
| `Name` | `string` | None | Full Name |
| `Gender` | `string` | None | Gender |
| `Department` | `string` | None | Department |
| `Salary` | `decimal` | None | Raw Decimal Salary |
| `AddressId` | `int` | None | Address ID |
| `City` | `string` | None | City |
| `State` | `string` | None | State |
| `Country` | `string` | None | Country |
| `FormattedSalary` | `string` | Computed: `"Rs. " + Salary.ToString("N2")` | Formatted Indian Rupee currency |
| `Location` | `string` | Computed: `City + ", " + State` | Combined geographical location |

#### `EmployeeDetailsViewModel` (Model Aggregation)
| Property | Type | Description |
|---|---|---|
| `Employee` | `Employee` | Domain model instance for employee record |
| `Address` | `Address` | Domain model instance for linked address record |
| `PageTitle` | `string` | Page title string (defaults: "Employee Details Page") |
| `PageHeader` | `string` | Page header string (defaults: "Employee Details") |

#### `AdminDashboardViewModel`
| Property | Type | Description |
|---|---|---|
| `TotalEmployees` | `int` | Count of records in `dbo.Employees` |
| `TotalUsers` | `int` | Count of records in `dbo.Users` |
| `TotalPayroll` | `decimal` | Sum of salaries across all employees |
| `AverageSalary` | `decimal` | Average salary across all employees |
| `DepartmentCounts` | `Dictionary<string, int>` | Employee headcounts grouped by Department |
| `RecentEmployees` | `List<EmployeeListItemViewModel>` | 5 most recent employee additions |
| `RecentUsers` | `List<User>` | 5 most recent user registrations |
| `FormattedTotalPayroll` | `string` | Computed: `"Rs. " + TotalPayroll.ToString("N2")` |
| `FormattedAverageSalary` | `string` | Computed: `"Rs. " + AverageSalary.ToString("N2")` |

#### `vmStudMarks` (Presentation / UI Logic)
| Property | Type | Description |
|---|---|---|
| `RollNo` | `int` | Student roll number |
| `Name` | `string` | Student name |
| `Marks` | `string` | Score formatted as string |
| `colorname` | `string` | Computed in controller: `stud.Marks > 35 ? "green" : "red"` |

---

## 5. Behavioral Specifications and Workflows

### 5.1 Route and Controller Mapping

Default route: `{controller = "Employee", action = "Details", id = UrlParameter.Optional}`.

| Controller | Action | HTTP Verb | Authorization | Purpose / Returned View |
|---|---|---|---|---|
| `AccountController` | `Login` | GET | Anonymous | Renders login card with pre-configured credentials box |
| `AccountController` | `Login` | POST | Anonymous (`[ValidateAntiForgeryToken]`) | Validates user, stores session, redirects to ReturnUrl or Role destination |
| `AccountController` | `Register` | GET | Anonymous | Renders user registration form |
| `AccountController` | `Register` | POST | Anonymous (`[ValidateAntiForgeryToken]`) | Checks duplicates, inserts User with 'User' role, stores session |
| `AccountController` | `Logout` | GET | Anonymous | Clears and abandons session, redirects to Login with info notice |
| `AdminController` | `Dashboard` | GET | Admin Only (`user.IsAdmin`) | Renders executive metric cards, department tags, and top 5 recent lists |
| `AdminController` | `Users` | GET | Admin Only (`user.IsAdmin`) | Renders table of registered system users |
| `EmployeeController` | `Index` | GET | Public / All | Renders employee table with search filter |
| `EmployeeController` | `Details` | GET | Public / All | Renders aggregated employee and address cards (default ID 101) |
| `EmployeeController` | `Create` | GET | Admin Only | Renders empty multi-table `EmployeeFormViewModel` |
| `EmployeeController` | `Create` | POST | Admin Only (`[ValidateAntiForgeryToken]`) | Validates model, executes dual-insert transaction, redirects to Index |
| `EmployeeController` | `Edit` | GET | Admin Only | Loads `EmployeeFormViewModel` by ID; redirects if not found |
| `EmployeeController` | `Edit` | POST | Admin Only (`[ValidateAntiForgeryToken]`) | Validates model, executes dual-update transaction, redirects to Index |
| `EmployeeController` | `Delete` | GET | Admin Only | Renders confirmation card with summary of record to be deleted |
| `EmployeeController` | `Delete` (`DeleteConfirmed`) | POST | Admin Only (`[ValidateAntiForgeryToken]`) | Executes transactional delete of employee and address, redirects to Index |
| `StudentController` | `Index` | GET | Public / All | Renders raw domain `Student` model list |
| `StudentController` | `getStud` | GET | Public / All | Evaluates marks condition (> 35 green, <= 35 red), renders `vmStudMarks` table |

### 5.2 Session Management and Authorization Rules

1. **Session State Storage**:
   - `Session["CurrentUser"]` holds the active `UserSession` instance.
   - `UserSession.IsAdmin` evaluates `string.Equals(Role, "Admin", StringComparison.OrdinalIgnoreCase)`.
2. **Access Control Enforcement**:
   - Non-admin attempting to access `Admin/Dashboard` or `Admin/Users` is redirected to `/Account/Login?returnUrl=[CurrentUrl]` with `TempData["ErrorMessage"] = "Access restricted. Please log in with an Administrator account."` or `"Access restricted. Administrator privileges required."`.
   - Non-admin attempting to access `Employee/Create`, `Employee/Edit/{id}`, or `Employee/Delete/{id}` is redirected to `/Account/Login?returnUrl=[CurrentUrl]` with `TempData["ErrorMessage"] = "Only Administrators can..."`.
3. **UI Element Visibility Rules**:
   - Navigation bar:
     - When `currentUser == null`: Displays "Login" and "Register" buttons.
     - When `currentUser != null`: Displays user pill with `FullName` and role badge (`badge-admin` or `badge-user`), plus "Logout" button.
     - "Admin Dashboard" and "Users" navigation links are only visible when `currentUser.IsAdmin` is true.
   - Employee Directory:
     - "+ Add New Employee" is shown to Admins; "+ Add Employee (Admin)" linking to Login is shown to non-admins.
     - "Edit" and "Delete" table row actions are only shown to Admins; "View" is available to all users.

### 5.3 User Feedback / Messaging Contract
- `TempData["SuccessMessage"]`: Displayed as `.alert.alert-success` below the top navigation bar.
- `TempData["ErrorMessage"]`: Displayed as `.alert.alert-danger` below the top navigation bar.
- `TempData["InfoMessage"]`: Displayed as `.alert.alert-info` below the top navigation bar.
- `ModelState` Errors: Rendered via `@Html.ValidationSummary(true, "")` within `.alert.alert-danger` cards and inline `@Html.ValidationMessageFor` elements in `.text-danger`.

---

## 6. Realistic Indian Context Mapping

The application uses an authentic Indian context for all demo records, test data, and placeholder examples.

### 6.1 Geographical & Address Reference
- **Country**: India
- **States & Major Cities**:
  - West Bengal: Kolkata (PIN: 700091)
  - Karnataka: Bengaluru (PIN: 560001)
  - Delhi: New Delhi (PIN: 110001)
  - Odisha: Bhubaneswar (PIN: 751024)
  - Maharashtra: Mumbai (PIN: 400001), Pune (PIN: 411001)
  - Telangana: Hyderabad (PIN: 500081)
  - Tamil Nadu: Chennai (PIN: 600001)

### 6.2 Seed Profiles and Identity Reference
| Name | Gender | Role / Dept | Salary | City | State | PIN |
|---|---|---|---|---|---|---|
| Dillip Mohapatra | Male | IT | Rs. 65,000.00 | Bhubaneswar | Odisha | 751024 |
| Priya Patel | Female | HR | Rs. 58,000.00 | Kolkata | West Bengal | 700091 |
| Rahul Sharma | Male | Engineering | Rs. 82,000.00 | Bengaluru | Karnataka | 560001 |
| Sneha Roy | Female | Finance | Rs. 71,000.00 | New Delhi | Delhi | 110001 |
| Rajesh Nair | Male | Operations | Rs. 62,000.00 | Mumbai | Maharashtra | 400001 |
| Ananya Sen | Female | Marketing | Rs. 68,000.00 | Pune | Maharashtra | 411001 |

### 6.3 Student Score Reference (Threshold 35)
| Roll No | Name | Marks | Condition Result | Badge Color |
|---|---|---|---|---|
| 1 | Ankur | 34.0 | <= 35.0 (Fail) | Red |
| 2 | Dhrumit | 79.0 | > 35.0 (Pass) | Green |
| 3 | Mannan | 67.0 | > 35.0 (Pass) | Green |
| 4 | Priya Sharma | 88.5 | > 35.0 (Pass) | Green |
| 5 | Amit Verma | 31.0 | <= 35.0 (Fail) | Red |

### 6.4 Strict Zero Emoji Verification
No emojis, glyphs, or emoticons are permitted anywhere in markup, code, console outputs, logs, or documentation.

---

## 7. Features Discovered

| # | Category | Feature | Description | Inputs | Outputs | Error Behavior | Discovered Via |
|---|---|---|---|---|---|---|---|
| 1 | Auth | User Login | Form authentication using username/email and password | Username/Email, Password, RememberMe, ReturnUrl | Stores UserSession in `Session["CurrentUser"]`, redirects to Dashboard or Index | Model error: "Invalid username/email or password." | `AccountController.cs:28` |
| 2 | Auth | User Registration | Registration of standard User accounts with unique constraint checks | FullName, Username, Email, Password, ConfirmPassword | Creates record in `dbo.Users`, initializes session, redirects | Model error: "A user with this username or email already exists." | `AccountController.cs:69` |
| 3 | Auth | User Logout | Clears and abandons active session | None | Cleared session, redirect to `/Account/Login` | None | `AccountController.cs:85` |
| 4 | Security | Role-Based Access Control | Restricts Admin routes and actions (Dashboard, Users, Create, Edit, Delete) | `Session["CurrentUser"]` | Granted access or redirect to Login | Redirects to `/Account/Login` with contextual error alert | `AdminController.cs:20`, `EmployeeController.cs:49` |
| 5 | Navigation | Responsive Top Navigation | Header with brand, navigation links, user status pill, and auth action buttons | Session state | Rendered HTML navigation bar | Falls back to Login/Register buttons when unauthenticated | `_Navigation.cshtml:6` |
| 6 | Employee | Directory Listing & Search | Lists all employees with salary, department, and location; supports name/dept/city search | `search` query parameter | Filtered `List<EmployeeListItemViewModel>` table | Displays "No employee records found matching your search." | `EmployeeController.cs:17`, `Index.cshtml:54` |
| 7 | Employee | Aggregated Details View | Displays unified employee card combining `Employee` and `Address` domain models | `id` route parameter (default: 101) | Rendered `EmployeeDetailsViewModel` with personal & address cards | Falls back to static default employee (Dillip Mohapatra) if DB offline | `EmployeeController.cs:26`, `Details.cshtml:23` |
| 8 | Employee | Create Employee Form | Multi-table insert capturing personal and residential address details | `EmployeeFormViewModel` fields | New address & employee in DB, redirect to Index with success alert | Model validation error summary and field-level error messages | `EmployeeController.cs:46`, `Create.cshtml:17` |
| 9 | Employee | Edit Employee Form | Multi-table atomic update of employee and address records | `id` route parameter, updated `EmployeeFormViewModel` fields | Updated DB records, redirect to Index with success alert | Error alert: "Employee not found." if invalid ID; DB error message on failure | `EmployeeController.cs:95`, `Edit.cshtml:17` |
| 10 | Employee | Delete Confirmation & Action | Two-step deletion of employee and referenced address record | `id` route parameter, POST confirmation | Deleted DB records, redirect to Index with success alert | Error alert: "Could not delete employee." | `EmployeeController.cs:150`, `Delete.cshtml:37` |
| 11 | Admin | Executive Dashboard | Workforce KPIs (Total Employees, Registered Users, Total Payroll, Avg Salary), Department counts, and Recent 5 lists | None (requires Admin session) | Rendered `AdminDashboardViewModel` with metrics grid and tables | Redirects non-admin to Login | `AdminController.cs:17`, `Dashboard.cshtml:20` |
| 12 | Admin | System Users Directory | Displays all registered user accounts with roles and registration dates | None (requires Admin session) | Rendered `List<User>` table | Redirects non-admin to Login | `AdminController.cs:31`, `Users.cshtml:18` |
| 13 | Student | Domain Model Listing | Displays student records directly from domain entity (`Student`) | None | Rendered `List<Student>` table | Falls back to offline student list if DB offline | `StudentController.cs:17`, `Index.cshtml:18` |
| 14 | Student | Marks UI Logic (getStud) | Demonstrates ViewModel presentation logic formatting marks (>35 green, <=35 red) | None | Rendered `List<vmStudMarks>` table with status badges | Falls back to offline student list with color mapping if DB offline | `StudentController.cs:25`, `getStud.cshtml:33` |
| 15 | Resilience | Offline Fallback Mechanism | Built-in fallback datasets in `DatabaseHelper` ensuring offline demo operability | DB connection failure | Fallback users, employees, students, and dashboard metrics | Graceful execution without HTTP 500 crashes | `DatabaseHelper.cs:63,169,278,351,404,635,680` |

---

## 8. Edge Cases and Boundary Conditions

| # | Feature | Input / Condition | Observed / Documented Behavior |
|---|---|---|---|
| 1 | Directory Search | Search with non-existent term (e.g., `search=XYZ999`) | Returns empty list; table displays centered empty state: "No employee records found matching your search." |
| 2 | Directory Search | Search with whitespace or empty string (`search="   "`) | `string.IsNullOrWhiteSpace` check ignores filter; returns complete employee directory. |
| 3 | Employee Edit | Non-existent employee ID (e.g. `/Employee/Edit/9999`) | `GetEmployeeForEdit(9999)` returns `null`; controller sets `TempData["ErrorMessage"] = "Employee not found."` and redirects to `/Employee/Index`. |
| 4 | Employee Delete | Non-existent employee ID (e.g. `/Employee/Delete/9999`) | Returns null; sets `TempData["ErrorMessage"] = "Employee not found."` and redirects to `/Employee/Index`. |
| 5 | Employee Create | Salary below minimum (`Salary = 500`) | Fails validation with error: "Salary must be between Rs. 1,000 and Rs. 10,000,000". Form re-renders with invalid value. |
| 6 | Employee Create | Salary above maximum (`Salary = 15000000`) | Fails validation with error: "Salary must be between Rs. 1,000 and Rs. 10,000,000". Form re-renders. |
| 7 | User Registration | Username with special characters (e.g., `user@name!`) | Fails regex `^[a-zA-Z0-9_]+$` with error: "Username can only contain letters, numbers, and underscores". |
| 8 | User Registration | Username shorter than 3 characters (`ab`) | Fails `StringLength` with error: "Username must be between 3 and 50 characters". |
| 9 | User Registration | Password shorter than 6 characters (`12345`) | Fails `StringLength` with error: "Password must be at least 6 characters". |
| 10 | User Registration | Mismatched password and confirm password | Fails `Compare("Password")` validation with error: "Passwords do not match". |
| 11 | User Registration | Duplicate username or email | `COUNT(1)` returns > 0; controller adds model error: "A user with this username or email already exists." |
| 12 | Student Marks | Marks exactly 35.0 | Evaluated as `stud.Marks > 35 ? "green" : "red"`. 35.0 is NOT strictly greater than 35, hence assigned "red" (fail status). |
| 13 | Student Marks | Marks 35.1 | Evaluated as `stud.Marks > 35`. 35.1 is strictly greater than 35, hence assigned "green" (pass status). |
| 14 | Admin Access | Unauthenticated user accessing `/Admin/Dashboard` | `user == null`; sets `TempData["ErrorMessage"] = "Access restricted. Please log in with an Administrator account."` and redirects to `/Account/Login?returnUrl=/Admin/Dashboard`. |
| 15 | Admin Access | Standard user (`Role = 'User'`) accessing `/Employee/Create` | `!user.IsAdmin`; sets `TempData["ErrorMessage"] = "Only Administrators can add new employees."` and redirects to Login. |
| 16 | Login Redirection | Valid `ReturnUrl` provided (e.g., `returnUrl=/Employee/Create`) | Controller validates with `Url.IsLocalUrl(model.ReturnUrl)`; redirects to `/Employee/Create` upon successful authentication. |
| 17 | Login Redirection | Malicious / external `ReturnUrl` (e.g., `http://evil.com`) | `Url.IsLocalUrl` returns `false`; application ignores ReturnUrl and routes based on user role (Admin -> Dashboard, User -> Employee Index). |
| 18 | Multi-table Transaction | Database failure during employee insert after address insert | `trans.Rollback()` is invoked in catch block; address insert is cleanly rolled back, ensuring no orphaned addresses. |

---

## 9. Enumerated Feature Inventory (F01 to F15)

### F01: User Authentication & Login
- **Identifier**: F01
- **Category**: Authentication
- **User Story**: As a registered user, I want to log into the application using my username or email and password so that I can access role-specific functionality.
- **Inputs**: `UsernameOrEmail` (string), `Password` (string), `RememberMe` (bool), `ReturnUrl` (string).
- **Validation**:
  - `UsernameOrEmail`: Required ("Username or Email is required").
  - `Password`: Required ("Password is required").
  - Anti-Forgery Token: Mandatory `[ValidateAntiForgeryToken]`.
- **States**:
  - *Idle*: Clean card with username, password, remember checkbox, and pre-configured test credentials box.
  - *Submitting*: Visual button state, form disabled during transit.
  - *Failure*: Summary alert with "Invalid username/email or password." or validation highlights.
  - *Success*: Sets `Session["CurrentUser"]`, routes to local `ReturnUrl`, `/Admin/Dashboard` for admins, or `/Employee/Index` for users.

### F02: User Registration
- **Identifier**: F02
- **Category**: Membership
- **User Story**: As a new user, I want to create an account with my full name, username, email, and password so that I can sign in as a standard user.
- **Inputs**: `FullName` (string), `Username` (string), `Email` (string), `Password` (string), `ConfirmPassword` (string).
- **Validation**:
  - `FullName`: Required, max 100 characters.
  - `Username`: Required, 3-50 chars, regex `^[a-zA-Z0-9_]+$`.
  - `Email`: Required, valid email format.
  - `Password`: Required, min 6 chars, max 100 chars.
  - `ConfirmPassword`: Required, matches `Password`.
- **States**:
  - *Idle*: Clean Notion-like registration form card.
  - *Error*: Field validation messages and alert card for duplicate handles.
  - *Success*: Automatically logs user in, sets `TempData["SuccessMessage"]`, redirects to `/Employee/Index`.

### F03: Session Management & Logout
- **Identifier**: F03
- **Category**: Session
- **User Story**: As an authenticated user, I want to securely log out to terminate my active session.
- **Behavior**: Calls `Session.Clear()`, `Session.Abandon()`, sets `TempData["InfoMessage"] = "You have been logged out safely."`, redirects to `/Account/Login`.

### F04: Role-Based Access Control (Admin vs Standard User)
- **Identifier**: F04
- **Category**: Security
- **User Story**: As the system owner, I want administrative routes and sensitive actions restricted so only verified administrators can modify workforce data.
- **Protected Endpoints**:
  - `/Admin/Dashboard` (GET)
  - `/Admin/Users` (GET)
  - `/Employee/Create` (GET/POST)
  - `/Employee/Edit/{id}` (GET/POST)
  - `/Employee/Delete/{id}` (GET/POST)
- **Behavior**: Intercepts unauthenticated or unauthorized access, sets contextual `TempData["ErrorMessage"]`, redirects to Login preserving return path.

### F05: Global Navigation & User Pill
- **Identifier**: F05
- **Category**: Navigation
- **User Story**: As a user navigating the application, I want a consistent, responsive header that indicates my current login status and provides easy navigation.
- **Elements**:
  - Brand link to `/Employee/Index`.
  - Links: Employees (CRUD), Details (Aggregation), Student Marks (UI Logic), Admin Dashboard (Admin only), Users (Admin only).
  - User pill showing `FullName` and uppercase role badge (`badge-admin` or `badge-user`).
  - Contextual action buttons (Login/Register or Logout).

### F06: Employee Directory Listing & Search Filter
- **Identifier**: F06
- **Category**: Employee
- **User Story**: As a user, I want to browse all employees in a clean table and search by name, department, or city.
- **Inputs**: `search` query parameter.
- **Columns**: ID, Employee Name, Gender, Department (tag), Formatted Salary (`Rs. XX,XXX.00`), Location (`City, State`), Actions.
- **Role Adapting**:
  - Standard User: Sees "+ Add Employee (Admin)" button and "View" action link.
  - Admin: Sees "+ Add New Employee" primary button and "View", "Edit", "Delete" action links.
- **Empty State**: Clear message when zero records match query.

### F07: Multi-Model Aggregated Employee Details View
- **Identifier**: F07
- **Category**: ViewModel Pattern
- **User Story**: As a user, I want to inspect complete employee and address information on a single page assembled from separate database models.
- **Inputs**: `id` route parameter (default: 101).
- **Cards**:
  - Card 1: Employee Basic Information (ID, Name, Gender, Department tag, Salary formatted in INR).
  - Card 2: Residential Address Information (Address ID, City, State, Country, PIN Code).
- **Header Actions**: "Edit Employee" (if Admin) and "Directory" back button.

### F08: Multi-Table Employee Creation Form
- **Identifier**: F08
- **Category**: Employee CRUD
- **User Story**: As an administrator, I want to register a new employee and their address in a single form with atomic database persistence.
- **Inputs**: Name, Gender, Department, Salary, City, State, Country, PIN Code.
- **Validation**: Enforced via DataAnnotations on `EmployeeFormViewModel`.
- **Database Action**: Atomic `SqlTransaction` inserting `dbo.Addresses` first, obtaining `SCOPE_IDENTITY()`, then inserting `dbo.Employees`.
- **Feedback**: Redirects to Directory with `TempData["SuccessMessage"] = "Employee [Name] was created successfully."`.

### F09: Multi-Table Employee Editing Form
- **Identifier**: F09
- **Category**: Employee CRUD
- **User Story**: As an administrator, I want to update an existing employee's details and residential address simultaneously.
- **Inputs**: Hidden `EmployeeId` and `AddressId`, updated personal and address fields.
- **Database Action**: Atomic `SqlTransaction` updating `dbo.Addresses` and `dbo.Employees`.
- **Feedback**: Redirects to Directory with `TempData["SuccessMessage"] = "Employee [Name] was updated successfully."`.

### F10: Transactional Employee Deletion
- **Identifier**: F10
- **Category**: Employee CRUD
- **User Story**: As an administrator, I want to delete an employee record along with their address after reviewing a confirmation screen.
- **Workflow**:
  - GET `/Employee/Delete/{id}`: Shows red-accented confirmation card with record summary.
  - POST `/Employee/Delete/{id}`: Finds `AddressId`, deletes employee record from `dbo.Employees`, deletes address from `dbo.Addresses` within an atomic `SqlTransaction`.
- **Feedback**: Redirects to Directory with `TempData["SuccessMessage"] = "Employee #[id] was deleted successfully."`.

### F11: Admin Metrics & Workforce Analytics Dashboard
- **Identifier**: F11
- **Category**: Admin
- **User Story**: As an administrator, I want an executive overview of workforce metrics and recent activity.
- **Components**:
  - 4 KPI Tiles: Total Employees, Registered Users, Monthly Payroll (`Rs. XX,XXX.00`), Average Salary (`Rs. XX,XXX.00`).
  - Department Distribution card showing pill tags with employee counts per department.
  - Recent Employee Additions table (top 5 by EmployeeId descending).
  - Recent User Registrations table (top 5 by UserId descending).

### F12: System User Management Directory
- **Identifier**: F12
- **Category**: Admin
- **User Story**: As an administrator, I want a complete view of registered system users to audit roles and account creation dates.
- **Columns**: ID, Username (`code` styled), Full Name, Email, Assigned Role (`badge-admin` or `badge-user`), Registration Date (`MMM dd, yyyy HH:mm`).

### F13: Student Domain Model Raw Listing
- **Identifier**: F13
- **Category**: Student
- **User Story**: As a student/instructor, I want to view student score records in raw domain format to understand the baseline before applying presentation ViewModels.
- **Columns**: Roll No, Student Name, Marks.
- **Action**: Button linking to `/Student/getStud` ("View with ViewModel Formatting").

### F14: Student Marks Presentation Logic (getStud)
- **Identifier**: F14
- **Category**: ViewModel Pattern
- **User Story**: As an instructor, I want student marks visually classified with status indicators (pass/fail) generated by the ViewModel without modifying the database.
- **Presentation Logic**:
  - Marks > 35: Highlighted in green (`colorname = "green"`).
  - Marks <= 35: Highlighted in red (`colorname = "red"`).
- **Columns**: Roll No, Student Name, Marks Status (badge styled with `colorname`).

### F15: Offline Resiliency & Fallback Data Access
- **Identifier**: F15
- **Category**: Reliability
- **User Story**: As a developer running tests in disconnected or isolated environments, I want the application to maintain operational readiness with realistic fallback datasets.
- **Behavior**: All `DatabaseHelper` query methods contain catch blocks that supply in-memory test data (Admin & User accounts, sample employees, sample students, and default dashboard figures) if SQL Server is temporarily unavailable.

---

## 10. Verification Guidelines for Downstream Phases

1. **Compilation Verification**:
   - Tool: `MSBuild.exe` from `C:\Program Files\Microsoft Visual Studio\18\Community\MSBuild\Current\Bin\MSBuild.exe`.
   - Command: `& "C:\Program Files\Microsoft Visual Studio\18\Community\MSBuild\Current\Bin\MSBuild.exe" "D:\.NET\ViewModelDemo\ViewModelDemo.csproj" /t:Build /p:Configuration=Debug`
   - Success Criterion: 0 Errors, 0 Warnings.
2. **Database Verification**:
   - Connection string in `Web.config`: `ViewModelDB`.
   - Seed script: `App_Data\ViewModelDB_Setup.sql`.
   - Verification of tables: `dbo.Addresses`, `dbo.Employees`, `dbo.Students`, `dbo.Users`.
3. **Frontend Redesign Guidelines (For Downstream Agents)**:
   - Adhere strictly to clean, Notion-like aesthetics: neutral palettes (whites, off-whites, neutral grays `#37352f`, `#6b7280`, `#111827`), subtle borders (`#e5e7eb`), clean sans-serif typography (`-apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial, sans-serif`).
   - Preserve all existing form field names, view model bindings, anti-forgery tokens, action names, and query parameters.
   - Strictly zero emojis in all code, HTML, CSS, JavaScript, and user-facing copy.
   - Use realistic Indian context for all demo examples and placeholders.
