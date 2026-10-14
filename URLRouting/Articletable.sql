-- =============================================
-- SQL Script for URL Routing Article Table
-- Database: TestDB
-- =============================================

-- Step 1: Create Database if it does not exist
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'TestDB')
BEGIN
    CREATE DATABASE TestDB;
END
GO

USE TestDB;
GO

-- Step 2: Create Articletable
IF OBJECT_ID('dbo.Articletable', 'U') IS NOT NULL
    DROP TABLE dbo.Articletable;
GO

CREATE TABLE [dbo].[Articletable]( 
    [ID] [int] NOT NULL, 
    [Title] [varchar](200) NULL, 
    [Description] [varchar](400) NULL, 
    [Author] [varchar](50) NULL 
);
GO

-- Step 3: Insert Sample Articles
INSERT INTO Articletable VALUES(1,'How to validate dropdownlist in asp.net','Here, we will learn how to validate a DropDownList in ASP.NET.','Rohatash Kumar'); 
INSERT INTO Articletable VALUES(2,'Introduction to .NET Assemblies in VB.NET',' Here is a comprehensive introduction to .NET assemblies.','sunil Kumar'); 
INSERT INTO Articletable VALUES(3,'BinaryReader and BinaryWriter classes in VB.NET','In this article I will explain about BinaryReader and BinaryWriter Classes in VB.NET.','Deepak Kumar'); 
INSERT INTO Articletable VALUES(4,'StreamWriter class in VB.NET','This article shows how to create a new text file and write a string to it.','Rohatash Kumar'); 
GO

-- Step 4: Verify Records
SELECT * FROM Articletable;
GO
