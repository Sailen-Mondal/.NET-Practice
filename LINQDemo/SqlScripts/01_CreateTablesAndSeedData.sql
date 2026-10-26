-- =====================================================================
-- 01_CreateTablesAndSeedData.sql
-- LINQ to SQL Database Setup: Departments & Employees Tables with Seed Data
-- =====================================================================

-- Step 1: Create Database if not exists
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'SampleDB')
BEGIN
    CREATE DATABASE SampleDB;
END
GO

USE SampleDB;
GO

-- Step 2: Drop existing tables if present to allow clean re-runs
IF OBJECT_ID('dbo.Employees', 'U') IS NOT NULL
    DROP TABLE dbo.Employees;
GO

IF OBJECT_ID('dbo.Departments', 'U') IS NOT NULL
    DROP TABLE dbo.Departments;
GO

-- Step 3: Create Departments Table
CREATE TABLE dbo.Departments
(
    ID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Name NVARCHAR(50) NOT NULL
);
GO

-- Step 4: Create Employees Table
CREATE TABLE dbo.Employees
(
    ID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NULL,
    Gender NVARCHAR(50) NOT NULL,
    Salary INT NOT NULL,
    DepartmentId INT NULL CONSTRAINT FK_Employees_Departments FOREIGN KEY REFERENCES dbo.Departments(ID)
);
GO

-- Step 5: Insert Seed Data for Departments
INSERT INTO dbo.Departments (Name)
VALUES 
    (N'IT'),
    (N'HR'),
    (N'Payroll');
GO

-- Step 6: Insert Seed Data for Employees
-- Notice: ID 10 (Andy) has NULL DepartmentId to demonstrate Inner Join exclusion
INSERT INTO dbo.Employees (FirstName, LastName, Gender, Salary, DepartmentId)
VALUES 
    (N'Mark',    N'Wood',    N'Male',   45000, 1),
    (N'Steve',   N'Smith',   N'Male',   55000, 2),
    (N'Ben',     N'Stokes',  N'Male',   65000, 1),
    (N'Philip',  N'Hughes',  N'Male',   55000, 1),
    (N'Mary',    N'Kom',     N'Female', 48000, 2),
    (N'Valarie', N'Adams',   N'Female', 70000, 2),
    (N'John',    N'Doe',     N'Male',   64000, 1),
    (N'Pam',     N'Beesly',  N'Female', 54000, 1),
    (N'Stacey',  N'Jones',   N'Female', 84000, 2),
    (N'Andy',    N'Bernard', N'Male',   36000, NULL);
GO

PRINT 'SampleDB tables and seed data created successfully.';
