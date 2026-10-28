IF DB_ID('ProjectManagementDB') IS NULL
BEGIN
    CREATE DATABASE [ProjectManagementDB];
END
GO

USE [ProjectManagementDB];
GO

IF OBJECT_ID('dbo.Projects', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Projects (
        ProjectID INT IDENTITY(1,1) PRIMARY KEY,
        Title NVARCHAR(150) NOT NULL,
        Description NVARCHAR(500) NULL,
        Category NVARCHAR(50) NOT NULL,
        LeadStudent NVARCHAR(100) NOT NULL,
        Status NVARCHAR(50) NOT NULL,
        Priority NVARCHAR(20) NOT NULL,
        Budget DECIMAL(18,2) NOT NULL DEFAULT 0.00,
        StartDate DATETIME NOT NULL DEFAULT GETDATE(),
        EndDate DATETIME NULL
    );

    INSERT INTO dbo.Projects (Title, Description, Category, LeadStudent, Status, Priority, Budget, StartDate, EndDate)
    VALUES
    ('Smart Campus Navigation System', 'Indoor beacon navigation and campus mapping portal for students and visitors.', 'Mobile App', 'Rahul Sharma', 'In Progress', 'High', 75000.00, '2026-08-01', '2026-12-15'),
    ('Autonomous Agro-Drone Telemetry', 'Multispectral crop health monitoring drone with real-time cloud data pipeline.', 'AI/Robotics', 'James', 'In Progress', 'High', 120000.00, '2026-07-15', '2026-11-30'),
    ('Library Resource Inventory Grid', 'Automated RFID checkout and real-time catalogue indexing platform.', 'Web App', 'Priya Patel', 'Completed', 'Medium', 45000.00, '2026-05-10', '2026-09-20'),
    ('High-Throughput Exam Portal', 'Scalable distributed testing portal supporting concurrent proctored assessments.', 'Cloud Platform', 'Amit Verma', 'Planning', 'Critical', 180000.00, '2026-09-01', '2027-01-30'),
    ('Hostel Power Consumption Optimizer', 'IoT power meter network with peak-load shedding and analytics dashboard.', 'IoT/Embedded', 'Sneha Roy', 'In Progress', 'Medium', 60000.00, '2026-08-10', '2026-12-20');
END
GO
