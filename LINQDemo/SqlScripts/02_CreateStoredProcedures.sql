-- =====================================================================
-- 02_CreateStoredProcedures.sql
-- Stored Procedures for LINQ to SQL Operations (Get, CRUD & Output Parameter)
-- =====================================================================

USE SampleDB;
GO

-- 1. GetEmployees: Selects all employee columns for binding
IF OBJECT_ID('dbo.GetEmployees', 'P') IS NOT NULL
    DROP PROCEDURE dbo.GetEmployees;
GO

CREATE PROCEDURE dbo.GetEmployees
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ID, FirstName, LastName, Gender, Salary, DepartmentId
    FROM dbo.Employees;
END
GO

-- 2. InsertEmployee: Inserts a new employee record
IF OBJECT_ID('dbo.InsertEmployee', 'P') IS NOT NULL
    DROP PROCEDURE dbo.InsertEmployee;
GO

CREATE PROCEDURE dbo.InsertEmployee
    @FirstName NVARCHAR(50),
    @LastName NVARCHAR(50),
    @Gender NVARCHAR(50),
    @Salary INT,
    @DepartmentId INT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.Employees (FirstName, LastName, Gender, Salary, DepartmentId)
    VALUES (@FirstName, @LastName, @Gender, @Salary, @DepartmentId);
END
GO

-- 3. UpdateEmployee: Updates existing employee by ID
IF OBJECT_ID('dbo.UpdateEmployee', 'P') IS NOT NULL
    DROP PROCEDURE dbo.UpdateEmployee;
GO

CREATE PROCEDURE dbo.UpdateEmployee
    @ID INT,
    @FirstName NVARCHAR(50),
    @LastName NVARCHAR(50),
    @Gender NVARCHAR(50),
    @Salary INT,
    @DepartmentId INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.Employees
    SET FirstName = @FirstName,
        LastName = @LastName,
        Gender = @Gender,
        Salary = @Salary,
        DepartmentId = @DepartmentId
    WHERE ID = @ID;
END
GO

-- 4. DeleteEmployee: Deletes an employee record by ID
IF OBJECT_ID('dbo.DeleteEmployee', 'P') IS NOT NULL
    DROP PROCEDURE dbo.DeleteEmployee;
GO

CREATE PROCEDURE dbo.DeleteEmployee
    @ID INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM dbo.Employees
    WHERE ID = @ID;
END
GO

-- 5. GetEmployeesByDepartment: Stored procedure with an OUTPUT parameter
-- Retrieves the department name into @DepartmentName (OUTPUT)
-- and returns a result set of employees belonging to that department.
IF OBJECT_ID('dbo.GetEmployeesByDepartment', 'P') IS NOT NULL
    DROP PROCEDURE dbo.GetEmployeesByDepartment;
GO

CREATE PROCEDURE dbo.GetEmployeesByDepartment
    @DepartmentId INT,
    @DepartmentName NVARCHAR(50) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    -- Assign department name to output parameter
    SELECT @DepartmentName = Name
    FROM dbo.Departments
    WHERE ID = @DepartmentId;

    -- Return the result set of employees for this department
    SELECT ID, FirstName, LastName, Gender, Salary, DepartmentId
    FROM dbo.Employees
    WHERE DepartmentId = @DepartmentId;
END
GO

PRINT 'Stored procedures created successfully.';
