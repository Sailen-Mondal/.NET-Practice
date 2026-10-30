USE ViewModelDB;
GO

-- 1. Validate User
IF OBJECT_ID('dbo.sp_ValidateUser', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_ValidateUser;
GO
CREATE PROCEDURE dbo.sp_ValidateUser
    @Input NVARCHAR(100),
    @Password NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT UserId, Username, Email, FullName, Role
    FROM dbo.Users
    WHERE (Username = @Input OR Email = @Input)
      AND PasswordHash = @Password;
END;
GO

-- 2. Register User
IF OBJECT_ID('dbo.sp_RegisterUser', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_RegisterUser;
GO
CREATE PROCEDURE dbo.sp_RegisterUser
    @Username NVARCHAR(50),
    @Email NVARCHAR(100),
    @Password NVARCHAR(255),
    @FullName NVARCHAR(100),
    @NewUserId INT OUTPUT,
    @ErrorMessage NVARCHAR(255) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @NewUserId = 0;
    SET @ErrorMessage = NULL;

    IF EXISTS (SELECT 1 FROM dbo.Users WHERE Username = @Username OR Email = @Email)
    BEGIN
        SET @ErrorMessage = 'A user with this username or email already exists.';
        RETURN;
    END

    INSERT INTO dbo.Users (Username, Email, PasswordHash, FullName, Role, CreatedAt)
    VALUES (@Username, @Email, @Password, @FullName, 'User', GETDATE());

    SET @NewUserId = SCOPE_IDENTITY();
END;
GO

-- 3. Get All Users
IF OBJECT_ID('dbo.sp_GetAllUsers', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_GetAllUsers;
GO
CREATE PROCEDURE dbo.sp_GetAllUsers
AS
BEGIN
    SET NOCOUNT ON;
    SELECT UserId, Username, Email, FullName, Role, CreatedAt
    FROM dbo.Users
    ORDER BY UserId DESC;
END;
GO

-- 4. Get All Employees (With Search)
IF OBJECT_ID('dbo.sp_GetAllEmployees', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_GetAllEmployees;
GO
CREATE PROCEDURE dbo.sp_GetAllEmployees
    @Search NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT e.EmployeeId, e.Name, e.Gender, e.Department, e.Salary, e.AddressId,
           a.City, a.State, a.Country
    FROM dbo.Employees e
    INNER JOIN dbo.Addresses a ON e.AddressId = a.AddressId
    WHERE (@Search IS NULL OR @Search = '' OR 
           e.Name LIKE '%' + @Search + '%' OR 
           e.Department LIKE '%' + @Search + '%' OR 
           a.City LIKE '%' + @Search + '%')
    ORDER BY e.EmployeeId ASC;
END;
GO

-- 5. Get Employee With Address Details
IF OBJECT_ID('dbo.sp_GetEmployeeWithAddress', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_GetEmployeeWithAddress;
GO
CREATE PROCEDURE dbo.sp_GetEmployeeWithAddress
    @EmployeeId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT e.EmployeeId, e.Name, e.Gender, e.Department, e.Salary, e.AddressId,
           a.Country, a.State, a.City, a.Pin
    FROM dbo.Employees e
    INNER JOIN dbo.Addresses a ON e.AddressId = a.AddressId
    WHERE e.EmployeeId = @EmployeeId;
END;
GO

-- 6. Save Employee (Insert or Update with Transactions)
IF OBJECT_ID('dbo.sp_SaveEmployee', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_SaveEmployee;
GO
CREATE PROCEDURE dbo.sp_SaveEmployee
    @EmployeeId INT OUTPUT,
    @AddressId INT OUTPUT,
    @Name NVARCHAR(150),
    @Gender NVARCHAR(20),
    @Department NVARCHAR(100),
    @Salary DECIMAL(18, 2),
    @Country NVARCHAR(100),
    @State NVARCHAR(100),
    @City NVARCHAR(100),
    @Pin NVARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    BEGIN TRY
        IF (@EmployeeId = 0 OR @EmployeeId IS NULL)
        BEGIN
            -- INSERT Address
            INSERT INTO dbo.Addresses (Country, State, City, Pin)
            VALUES (@Country, @State, @City, @Pin);
            SET @AddressId = SCOPE_IDENTITY();

            -- INSERT Employee
            INSERT INTO dbo.Employees (Name, Gender, Department, Salary, AddressId)
            VALUES (@Name, @Gender, @Department, @Salary, @AddressId);
            SET @EmployeeId = SCOPE_IDENTITY();
        END
        ELSE
        BEGIN
            -- UPDATE Address
            UPDATE dbo.Addresses
            SET Country = @Country, State = @State, City = @City, Pin = @Pin
            WHERE AddressId = @AddressId;

            -- UPDATE Employee
            UPDATE dbo.Employees
            SET Name = @Name, Gender = @Gender, Department = @Department, Salary = @Salary
            WHERE EmployeeId = @EmployeeId;
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- 7. Delete Employee
IF OBJECT_ID('dbo.sp_DeleteEmployee', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_DeleteEmployee;
GO
CREATE PROCEDURE dbo.sp_DeleteEmployee
    @EmployeeId INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    BEGIN TRY
        DECLARE @LinkedAddressId INT;
        SELECT @LinkedAddressId = AddressId FROM dbo.Employees WHERE EmployeeId = @EmployeeId;

        DELETE FROM dbo.Employees WHERE EmployeeId = @EmployeeId;

        IF (@LinkedAddressId IS NOT NULL AND @LinkedAddressId > 0)
        BEGIN
            DELETE FROM dbo.Addresses WHERE AddressId = @LinkedAddressId;
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- 8. Get Students
IF OBJECT_ID('dbo.sp_GetStudents', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_GetStudents;
GO
CREATE PROCEDURE dbo.sp_GetStudents
AS
BEGIN
    SET NOCOUNT ON;
    SELECT RollNo, Name, Marks
    FROM dbo.Students
    ORDER BY RollNo ASC;
END;
GO

-- 9. Get Admin Dashboard Aggregates
IF OBJECT_ID('dbo.sp_GetAdminDashboardStats', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_GetAdminDashboardStats;
GO
CREATE PROCEDURE dbo.sp_GetAdminDashboardStats
AS
BEGIN
    SET NOCOUNT ON;
    -- Result 1: Aggregate employee stats & total users
    SELECT 
        (SELECT COUNT(1) FROM dbo.Employees) AS TotalEmployees,
        (SELECT ISNULL(SUM(Salary), 0) FROM dbo.Employees) AS TotalPayroll,
        (SELECT ISNULL(AVG(Salary), 0) FROM dbo.Employees) AS AvgSalary,
        (SELECT COUNT(1) FROM dbo.Users) AS TotalUsers;

    -- Result 2: Department Breakdown
    SELECT Department, COUNT(1) AS Cnt
    FROM dbo.Employees
    GROUP BY Department;

    -- Result 3: Recent Employees (Top 5)
    SELECT TOP 5 e.EmployeeId, e.Name, e.Gender, e.Department, e.Salary, e.AddressId,
                 a.City, a.State, a.Country
    FROM dbo.Employees e
    INNER JOIN dbo.Addresses a ON e.AddressId = a.AddressId
    ORDER BY e.EmployeeId DESC;

    -- Result 4: Recent Users (Top 5)
    SELECT TOP 5 UserId, Username, Email, FullName, Role, CreatedAt
    FROM dbo.Users
    ORDER BY UserId DESC;
END;
GO
