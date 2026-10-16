USE GridViewDB;
GO

-- 1. Drop existing objects if they exist
IF OBJECT_ID('spGetProductDetailsByID', 'P') IS NOT NULL DROP PROCEDURE spGetProductDetailsByID;
IF OBJECT_ID('spGetBasicProductDetails', 'P') IS NOT NULL DROP PROCEDURE spGetBasicProductDetails;
IF OBJECT_ID('spGetEmployees_by_PageIndex', 'P') IS NOT NULL DROP PROCEDURE spGetEmployees_by_PageIndex;
IF OBJECT_ID('spGetEmployees_by_PageIndex_and_PageSize', 'P') IS NOT NULL DROP PROCEDURE spGetEmployees_by_PageIndex_and_PageSize;

IF OBJECT_ID('ProductDetails', 'U') IS NOT NULL DROP TABLE ProductDetails;
IF OBJECT_ID('Products', 'U') IS NOT NULL DROP TABLE Products;
IF OBJECT_ID('tblEmployee', 'U') IS NOT NULL DROP TABLE tblEmployee;
IF OBJECT_ID('Customers', 'U') IS NOT NULL DROP TABLE Customers;
GO

-- 2. Customers Table
CREATE TABLE Customers
(
    CustomerID nvarchar(10) PRIMARY KEY,
    ContactName nvarchar(50) NOT NULL,
    City nvarchar(50) NOT NULL,
    Country nvarchar(50) NOT NULL
);
GO

INSERT INTO Customers (CustomerID, ContactName, City, Country) VALUES
('CUST001', 'Maria Anders', 'Berlin', 'Germany'),
('CUST002', 'Ana Trujillo', 'Mexico D.F.', 'Mexico'),
('CUST003', 'Antonio Moreno', 'Mexico D.F.', 'Mexico'),
('CUST004', 'Thomas Hardy', 'London', 'UK'),
('CUST005', 'Christina Berglund', 'Luleå', 'Sweden'),
('CUST006', 'Hanna Moos', 'Mannheim', 'Germany'),
('CUST007', 'Frédérique Citeaux', 'Strasbourg', 'France'),
('CUST008', 'Martín Sommer', 'Madrid', 'Spain'),
('CUST009', 'Laurence Lebihan', 'Marseille', 'France'),
('CUST010', 'Elizabeth Lincoln', 'Tsawwassen', 'Canada'),
('CUST011', 'Victoria Ashworth', 'London', 'UK'),
('CUST012', 'Patricio Simpson', 'Buenos Aires', 'Argentina'),
('CUST013', 'Francisco Chang', 'México D.F.', 'Mexico'),
('CUST014', 'Yang Wang', 'Bern', 'Switzerland'),
('CUST015', 'Pedro Afonso', 'São Paulo', 'Brazil');
GO

-- 3. tblEmployee Table
CREATE TABLE tblEmployee
(
    EmployeeId int IDENTITY(1,1) PRIMARY KEY,
    FirstName nvarchar(50),
    LastName nvarchar(50),
    Name nvarchar(100),
    DateOfBirth datetime,
    Salary int,
    AnnualSalary int,
    Gender nvarchar(20),
    DepartmentName nvarchar(50),
    Country nvarchar(50),
    CountryCulture nvarchar(20),
    City nvarchar(50)
);
GO

INSERT INTO tblEmployee (FirstName, LastName, Name, DateOfBirth, Salary, AnnualSalary, Gender, DepartmentName, Country, CountryCulture, City) VALUES
('John', 'Johnson', 'John Johnson', '1982-08-10', 55000, 55000, 'Male', 'IT', 'US', 'en-US', 'New York'),
('Pam', 'Roberts', 'Pam Roberts', '1979-11-11', 62000, 62000, 'Female', 'HR', 'UK', 'en-GB', 'London'),
('David', 'John', 'David John', '1980-01-15', 45000, 45000, 'Male', 'IT', 'US', 'en-US', 'San Francisco'),
('Rose', 'Mary', 'Rose Mary', '1967-08-18', 78000, 78000, 'Female', 'Payroll', 'UK', 'en-GB', 'Manchester'),
('Mark', 'Mell', 'Mark Mell', '1974-12-10', 69000, 69000, 'Male', 'HR', 'India', 'en-IN', 'Mumbai'),
('Priya', 'Sharma', 'Priya Sharma', '1988-04-22', 85000, 85000, 'Female', 'IT', 'India', 'en-IN', 'Bengaluru'),
('Thabo', 'Mbeki', 'Thabo Mbeki', '1978-06-15', 52000, 52000, 'Male', 'Payroll', 'South Africa', 'en-ZA', 'Johannesburg'),
('Ahmad', 'Razak', 'Ahmad Razak', '1985-09-30', 73000, 73000, 'Male', 'IT', 'Malaysia', 'en-MY', 'Kuala Lumpur'),
('Sarah', 'Connor', 'Sarah Connor', '1983-02-14', 92000, 92000, 'Female', 'IT', 'US', 'en-US', 'Chicago'),
('Liam', 'Smith', 'Liam Smith', '1990-11-05', 48000, 48000, 'Male', 'HR', 'UK', 'en-GB', 'Birmingham'),
('Ananya', 'Sen', 'Ananya Sen', '1992-07-19', 71000, 71000, 'Female', 'Payroll', 'India', 'en-IN', 'Kolkata'),
('Kagiso', 'Rabada', 'Kagiso Rabada', '1995-05-25', 64000, 64000, 'Male', 'IT', 'South Africa', 'en-ZA', 'Cape Town'),
('Siti', 'Nur', 'Siti Nur', '1991-03-12', 61000, 61000, 'Female', 'HR', 'Malaysia', 'en-MY', 'Penang');
GO

-- 4. Products & ProductDetails Tables
CREATE TABLE Products
(
    ID int PRIMARY KEY,
    Name nvarchar(50) NOT NULL,
    Price int NOT NULL
);
GO

CREATE TABLE ProductDetails
(
    ProductID int PRIMARY KEY FOREIGN KEY REFERENCES Products(ID) ON DELETE CASCADE,
    Color nvarchar(20),
    Size nvarchar(10),
    Weight decimal(8,2),
    QuantityInStock int,
    Discontinued bit,
    Supplier nvarchar(50)
);
GO

INSERT INTO Products (ID, Name, Price) VALUES
(1, 'DVD', 10),
(2, 'Clips', 20),
(3, 'USB', 35),
(4, 'CD Player', 25),
(5, 'LCD', 99),
(6, 'Wireless Mouse', 45),
(7, 'Mechanical Keyboard', 85),
(8, 'Noise Cancelling Headphones', 150);
GO

INSERT INTO ProductDetails (ProductID, Color, Size, Weight, QuantityInStock, Discontinued, Supplier) VALUES
(1, 'White', 'Normal', 10.00, 250, 0, 'ABC Supplier'),
(2, 'White', 'Large', 12.56, 350, 0, 'XYZ Supplier'),
(3, 'Black', 'Small', 5.50, 550, 0, 'Pragim Technologies'),
(4, 'Silver', 'Medium', 55.00, 750, 0, 'ABC Supplier'),
(5, 'Silver', 'Normal', 15.50, 250, 0, 'XYZ Supplier'),
(6, 'Matte Black', 'Small', 8.20, 180, 0, 'LogiTech Dist'),
(7, 'Dark Gray', 'Large', 42.00, 95, 0, 'Keychron Labs'),
(8, 'Midnight Blue', 'Normal', 28.50, 40, 1, 'AudioPhile Pro');
GO

-- 5. Stored Procedures
CREATE PROCEDURE spGetEmployees_by_PageIndex_and_PageSize
    @PageIndex int, 
    @PageSize int,
    @TotalRows int OUTPUT
AS 
BEGIN 
    SET NOCOUNT ON;
    DECLARE @StartRowIndex int = (@PageIndex * @PageSize) + 1;
    DECLARE @EndRowIndex int = (@PageIndex + 1) * @PageSize;

    SELECT EmployeeId, Name, Gender, City FROM 
    (
        SELECT ROW_NUMBER() OVER (ORDER BY EmployeeId) AS RowNumber, EmployeeId, Name, Gender, City 
        FROM tblEmployee
    ) Employees 
    WHERE RowNumber >= @StartRowIndex AND RowNumber <= @EndRowIndex;

    SELECT @TotalRows = COUNT(*) FROM tblEmployee;
END;
GO

CREATE PROCEDURE spGetEmployees_by_PageIndex
    @PageIndex int, 
    @PageSize int,
    @TotalRows int OUTPUT
AS 
BEGIN 
    EXEC spGetEmployees_by_PageIndex_and_PageSize @PageIndex, @PageSize, @TotalRows OUTPUT;
END;
GO

CREATE PROCEDURE spGetBasicProductDetails
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ID, Name, Price FROM Products;
END;
GO

CREATE PROCEDURE spGetProductDetailsByID
    @ID int
AS
BEGIN
    SET NOCOUNT ON;
    SELECT Products.ID, Products.Name, Products.Price,
           ProductDetails.Color, ProductDetails.Size, ProductDetails.Weight,
           ProductDetails.QuantityInStock, ProductDetails.Discontinued, ProductDetails.Supplier
    FROM Products
    LEFT JOIN ProductDetails ON Products.ID = ProductDetails.ProductID
    WHERE Products.ID = @ID;
END;
GO
