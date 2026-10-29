-- =====================================================================
-- ViewModelDB_Setup.sql
-- Database schema and seed data for ViewModel architecture demo
-- Includes Employees, Addresses, Students, and Users with Role-based Auth
-- =====================================================================

IF DB_ID('ViewModelDB') IS NULL
BEGIN
    CREATE DATABASE [ViewModelDB];
END
GO

USE [ViewModelDB];
GO

-- Drop tables if they exist to allow clean re-runs
IF OBJECT_ID('dbo.Users', 'U') IS NOT NULL DROP TABLE dbo.Users;
IF OBJECT_ID('dbo.Employees', 'U') IS NOT NULL DROP TABLE dbo.Employees;
IF OBJECT_ID('dbo.Addresses', 'U') IS NOT NULL DROP TABLE dbo.Addresses;
IF OBJECT_ID('dbo.Students', 'U') IS NOT NULL DROP TABLE dbo.Students;
GO

-- 1. Addresses Table
CREATE TABLE dbo.Addresses
(
    AddressId INT IDENTITY(1001, 1) PRIMARY KEY,
    Country NVARCHAR(100) NOT NULL,
    State NVARCHAR(100) NOT NULL,
    City NVARCHAR(100) NOT NULL,
    Pin NVARCHAR(20) NOT NULL
);
GO

-- 2. Employees Table
CREATE TABLE dbo.Employees
(
    EmployeeId INT IDENTITY(101, 1) PRIMARY KEY,
    Name NVARCHAR(150) NOT NULL,
    Gender NVARCHAR(20) NOT NULL,
    Department NVARCHAR(100) NOT NULL,
    Salary DECIMAL(18, 2) NOT NULL,
    AddressId INT NOT NULL CONSTRAINT FK_Employees_Addresses FOREIGN KEY REFERENCES dbo.Addresses(AddressId)
);
GO

-- 3. Students Table
CREATE TABLE dbo.Students
(
    RollNo INT PRIMARY KEY,
    Name NVARCHAR(150) NOT NULL,
    Marks FLOAT NOT NULL
);
GO

-- 4. Users Table (Role-based Authentication: 'Admin' vs 'User')
CREATE TABLE dbo.Users
(
    UserId INT IDENTITY(1, 1) PRIMARY KEY,
    Username NVARCHAR(50) NOT NULL UNIQUE,
    Email NVARCHAR(100) NOT NULL UNIQUE,
    PasswordHash NVARCHAR(256) NOT NULL,
    FullName NVARCHAR(100) NOT NULL,
    Role NVARCHAR(20) NOT NULL DEFAULT 'User', -- 'Admin' or 'User'
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE()
);
GO

-- Insert Seed Data for Addresses
SET IDENTITY_INSERT dbo.Addresses ON;
INSERT INTO dbo.Addresses (AddressId, Country, State, City, Pin)
VALUES
(1001, N'India', N'Odisha', N'Bhubaneswar', N'751024'),
(1002, N'India', N'West Bengal', N'Kolkata', N'700091'),
(1003, N'India', N'Karnataka', N'Bengaluru', N'560001'),
(1004, N'India', N'Delhi', N'New Delhi', N'110001');
SET IDENTITY_INSERT dbo.Addresses OFF;
GO

-- Insert Seed Data for Employees
SET IDENTITY_INSERT dbo.Employees ON;
INSERT INTO dbo.Employees (EmployeeId, Name, Gender, Department, Salary, AddressId)
VALUES
(101, N'Dillip Mohapatra', N'Male', N'IT', 65000.00, 1001),
(102, N'Priya Patel', N'Female', N'HR', 58000.00, 1002),
(103, N'Rahul Sharma', N'Male', N'Engineering', 82000.00, 1003),
(104, N'Sneha Roy', N'Female', N'Finance', 71000.00, 1004);
SET IDENTITY_INSERT dbo.Employees OFF;
GO

-- Insert Seed Data for Students
INSERT INTO dbo.Students (RollNo, Name, Marks)
VALUES
(1, N'Ankur', 34.0),
(2, N'Dhrumit', 79.0),
(3, N'Mannan', 67.0),
(4, N'Priya Sharma', 88.5),
(5, N'Amit Verma', 31.0);
GO

-- Insert Seed Data for Users
INSERT INTO dbo.Users (Username, Email, PasswordHash, FullName, Role)
VALUES
(N'admin', N'admin@viewmodeldemo.com', N'Admin@123', N'System Administrator', N'Admin'),
(N'rahul', N'rahul.sharma@example.com', N'User@123', N'Rahul Sharma', N'User'),
(N'priya', N'priya.patel@example.com', N'Priya@123', N'Priya Patel', N'User');
GO
