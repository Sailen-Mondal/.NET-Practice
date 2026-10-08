# 🚛 Vehicle Fleet Management System

A high-performance, enterprise-grade C# Console Application for managing commercial vehicle fleets using **pure ADO.NET** — designed for lightweight services where ORM overhead is unacceptable.

[![.NET](https://img.shields.io/badge/.NET-10.0-512BD4?logo=dotnet)](https://dotnet.microsoft.com/)
[![SQL Server](https://img.shields.io/badge/SQL%20Server-2019+-CC2927?logo=microsoftsqlserver)](https://www.microsoft.com/sql-server)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

---

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Architecture](#architecture)
- [Tech Stack](#tech-stack)
- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
  - [Database Setup](#1-database-setup)
  - [Configuration](#2-configuration)
  - [Build & Run](#3-build--run)
- [Project Structure](#project-structure)
- [Usage Guide](#usage-guide)
- [Design Patterns & Principles](#design-patterns--principles)
- [Security](#security)
- [Database Schema](#database-schema)
- [Contributing](#contributing)
- [License](#license)

---

## Overview

Logistics and transport enterprises manage large fleets of commercial vehicles daily. Operations managers need to log new vehicles entering the fleet, track cumulative mileage (odometer readings) after long-distance trips, toggle operational availability, and decommission retired vehicles.

This application replaces heavy ORM frameworks (e.g., Entity Framework Core) with a hand-crafted, performance-first data access layer built on **ADO.NET** (`Microsoft.Data.SqlClient`), making it ideal for:

- 🔧 Lightweight background services
- ⚡ High-throughput terminal applications
- 💰 Low-cost server infrastructure

---

## Features

| Feature | Description |
|---|---|
| **Fleet Onboarding** | Add new vehicles with unique VINs, model details, initial odometer readings, and default active status |
| **Inventory Retrieval** | View real-time fleet details — all vehicles or lookup by primary key |
| **Telemetry Logging** | Update odometer readings and operational status after dispatch routes |
| **Decommissioning** | Permanently remove retired vehicles with confirmation safeguard |
| **Input Validation** | VIN length (17 chars), year range, non-negative odometer enforcement |
| **SQL Injection Prevention** | 100% parameterized queries — zero string concatenation |
| **Connection Safety** | `await using` on all ADO.NET objects — zero connection leaks |

---

## Architecture

The application follows a **clean layered architecture** with strict separation of concerns:

```
┌─────────────────────────────────────────────────────┐
│                  Presentation Layer                  │
│             Program.cs  •  ConsoleHelper             │
├─────────────────────────────────────────────────────┤
│                  Business Logic Layer                │
│                   VehicleService                     │
│           (Validation & Domain Rules)                │
├─────────────────────────────────────────────────────┤
│                  Data Access Layer                   │
│   IRepository<T> → Repository<T> → VehicleRepo      │
├─────────────────────────────────────────────────────┤
│                 Infrastructure Layer                 │
│            SqlHelper  •  DbConnectionFactory         │
├─────────────────────────────────────────────────────┤
│                    Database Layer                    │
│          SQL Server  •  ADOPractice  •  dbo.Vehicles │
└─────────────────────────────────────────────────────┘
```

**Data Flow (Add Vehicle Example):**

```
User Input → Program.cs → VehicleService.ValidateVehicle()
          → VehicleRepository.AddAsync()
          → SqlHelper.ExecuteNonQueryAsync(sql, SqlParameter[])
          → SqlConnection (await using) → SQL Server INSERT
          → Rows Affected → Success/Failure → Console Output
```

---

## Tech Stack

| Component | Technology | Purpose |
|---|---|---|
| **Runtime** | .NET 10.0 | Latest LTS runtime |
| **Language** | C# 13 | Modern language features (`await using`, pattern matching, top-level statements) |
| **Data Access** | Microsoft.Data.SqlClient 6.x | High-performance ADO.NET provider |
| **Configuration** | Microsoft.Extensions.Configuration | JSON-based settings management |
| **Database** | SQL Server 2019+ | Relational data store |
| **IDE** | Visual Studio 2022+ | Development environment |

---

## Prerequisites

- [.NET 10 SDK](https://dotnet.microsoft.com/download/dotnet/10.0) or later
- [SQL Server 2019+](https://www.microsoft.com/sql-server) (LocalDB, Express, or Developer Edition)
- [SQL Server Management Studio (SSMS)](https://learn.microsoft.com/sql/ssms/) — optional, for manual database inspection

---

## Getting Started

### 1. Database Setup

Execute the provided SQL script to create the `dbo.Vehicles` table and seed 10 test records:

**Option A — Using SSMS:**
1. Open SSMS and connect to your local SQL Server instance
2. Open `SQLFile_For_ vehicle_management.sql`
3. Press **F5** to execute

**Option B — Using Command Line:**
```bash
sqlcmd -S . -U sa -P "your_password" -d ADOPractice -i "SQLFile_For_ vehicle_management.sql" -C
```

> **Note:** The `ADOPractice` database must already exist. Create it first if needed:
> ```sql
> CREATE DATABASE [ADOPractice];
> ```

### 2. Configuration

Update the connection string in [`appsettings.json`](appsettings.json):

```json
{
  "ConnectionStrings": {
    "DBConn": "Data Source=.;Initial Catalog=ADOPractice;Persist Security Info=True;User ID=sa;Password=YOUR_PASSWORD;TrustServerCertificate=True"
  }
}
```

| Parameter | Description |
|---|---|
| `Data Source` | SQL Server instance (`.` = localhost) |
| `Initial Catalog` | Target database name |
| `User ID` / `Password` | SQL Server authentication credentials |
| `TrustServerCertificate` | Set `True` for local dev only |

> ⚠️ **Security Warning:** Never commit credentials to source control. For production, use [User Secrets](https://learn.microsoft.com/aspnet/core/security/app-secrets), environment variables, or Azure Key Vault.

### 3. Build & Run

```bash
# Navigate to the project directory
cd D:\.NET\VehiclesManagementSystem

# Restore NuGet packages
dotnet restore

# Build the project
dotnet build

# Run the application
dotnet run
```

---

## Project Structure

```
VehiclesManagementSystem/
│
├── Program.cs                          # Application entry point & console menu loop
├── appsettings.json                    # Connection string configuration
├── VehiclesManagementSystem.csproj      # Project file with NuGet dependencies
├── VehiclesManagementSystem.slnx        # Solution file
│
├── Models/
│   └── Vehicle.cs                      # POCO entity (maps to dbo.Vehicles)
│
├── Data/
│   ├── DbConnectionFactory.cs         # SqlConnection factory (isolates creation)
│   └── SqlHelper.cs                    # Generic async ADO.NET command executor
│
├── Repositories/
│   ├── IRepository.cs                  # Generic CRUD interface
│   ├── Repository.cs                   # Abstract base with SqlHelper injection
│   └── VehicleRepository.cs            # Concrete Vehicle CRUD (parameterized SQL)
│
├── Services/
│   └── VehicleService.cs              # Business logic & input validation
│
└── Helpers/
    └── ConsoleHelper.cs               # Console I/O utilities & display formatting
```

---

## Usage Guide

When launched, the application presents an interactive menu:

```
==================================================
  VEHICLE FLEET MANAGEMENT SYSTEM
==================================================
  1. Add New Vehicle        (Fleet Onboarding)
  2. View All Vehicles      (Inventory Retrieval)
  3. View Vehicle by ID     (Lookup)
  4. Update Vehicle         (Telemetry Logging)
  5. Delete Vehicle         (Decommissioning)
  0. Exit
```

### Add a Vehicle (Option 1)

```
  VIN (17 characters): 1N4AL3AP8JC123456
  Make (e.g., Toyota): Nissan
  Model (e.g., Camry): Maxima
  Year: 2023
  Initial Odometer Reading: 5200.50
  ✓ Vehicle added to fleet successfully!
```

### View Fleet Inventory (Option 2)

```
  Id    VIN                  Make         Model              Year   Odometer     Status
  -------------------------------------------------------------------------------------
  1     1HGBH41JXMN109186   Honda        Civic              2021     34,500.75  Active
  2     5YJSA1DG9DFP14705   Tesla        Model S            2023     12,000.00  Active
  ...
```

### Update Telemetry (Option 4)

```
  Enter Vehicle ID to update: 1
  Current: [1] 2021 Honda Civic | VIN: 1HGBH41JXMN109186 | Odometer: 34,500.75 | Status: Active

  New Odometer Reading (current: 34,500.75): 38200.00
  Is vehicle active? (y/n): y
  ✓ Vehicle updated successfully!
```

### Decommission a Vehicle (Option 5)

```
  Enter Vehicle ID to decommission: 7
  Vehicle to remove: [7] 2017 Volkswagen Passat | VIN: WVWZZZ3CZWE345678 | ...

  Are you sure you want to permanently delete this vehicle? (y/n): y
  ✓ Vehicle decommissioned and removed from fleet.
```

---

## Design Patterns & Principles

| Pattern / Principle | Implementation |
|---|---|
| **Repository Pattern** | `IRepository<T>` → `Repository<T>` → `VehicleRepository` — abstracts data access behind a clean interface |
| **Generic Base Class** | `Repository<T>` provides shared `SqlHelper` access to all derived repositories |
| **Factory Pattern** | `DbConnectionFactory` isolates `SqlConnection` creation for testability |
| **Separation of Concerns** | Each layer has a single responsibility: UI → Validation → Data Access → SQL Execution |
| **Dependency Injection (Manual)** | Dependencies wired in `Program.cs` via constructor injection ("Poor Man's DI") |
| **Async/Await** | All database operations are fully asynchronous (`Task<T>`) |
| **IAsyncDisposable** | `await using` ensures deterministic disposal of all ADO.NET objects |
| **Parameterized Queries** | `SqlParameter[]` on every command — no string concatenation |
| **Fail-Fast Validation** | `VehicleService` validates inputs before any database call |
| **DRY (Don't Repeat Yourself)** | `SqlHelper` centralizes connection/command lifecycle; `ConsoleHelper` centralizes I/O |

---

## Security

| Threat Vector | Mitigation |
|---|---|
| **SQL Injection** | All queries use `SqlParameter[]` — zero dynamic SQL concatenation |
| **Connection Pool Exhaustion** | Every `SqlConnection`, `SqlCommand`, `SqlDataReader` wrapped in `await using` |
| **Credential Exposure** | Connection string externalized to `appsettings.json` (not hardcoded) |
| **Invalid Input** | `VehicleService.ValidateVehicle()` enforces VIN length, year range, odometer sign |
| **Unhandled Exceptions** | Global `try/catch` in menu loop prevents crashes from propagating |

---

## Database Schema

### `dbo.Vehicles`

| Column | Type | Constraints | Description |
|---|---|---|---|
| `Id` | `INT` | `IDENTITY(1,1) PRIMARY KEY` | Auto-incrementing surrogate key |
| `VIN` | `VARCHAR(17)` | `NOT NULL UNIQUE` | 17-character Vehicle Identification Number |
| `Make` | `NVARCHAR(50)` | `NOT NULL` | Manufacturer name |
| `Model` | `NVARCHAR(50)` | `NOT NULL` | Vehicle model name |
| `Year` | `INT` | `NOT NULL` | Manufacturing year |
| `OdometerReading` | `DECIMAL(12,2)` | `NOT NULL DEFAULT 0.00` | Cumulative mileage |
| `IsActive` | `BIT` | `NOT NULL DEFAULT 1` | Operational availability flag |
| `CreatedAt` | `DATETIME2` | `NOT NULL DEFAULT SYSDATETIME()` | Record creation timestamp |
| `UpdatedAt` | `DATETIME2` | `NULL` | Last modification timestamp |

### Seed Data (10 Records)

The SQL script pre-loads 10 vehicles covering these test scenarios:

- **6 active** vehicles (sedans, trucks, heavy-duty)
- **2 inactive** vehicles (status toggle testing)
- **1 zero-odometer** vehicle (brand-new edge case)
- **1 high-mileage** vehicle (320K+ reading)
- **1 pre-updated** record (non-null `UpdatedAt` column)

---

## Contributing

Contributions are welcome! Please follow these steps:

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/add-fuel-tracking`)
3. **Commit** your changes (`git commit -m 'feat: add fuel tracking module'`)
4. **Push** to the branch (`git push origin feature/add-fuel-tracking`)
5. **Open** a Pull Request

### Coding Standards

- Follow [Microsoft C# Coding Conventions](https://learn.microsoft.com/dotnet/csharp/fundamentals/coding-style/coding-conventions)
- All SQL must use `SqlParameter[]` — no exceptions
- All `SqlConnection` / `SqlCommand` / `SqlDataReader` must use `await using`
- Add XML documentation comments (`///`) to all public members
- Keep methods small and focused — single responsibility

---

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

<p align="center">
  Built with ❤️ using .NET 10 and ADO.NET
</p>
