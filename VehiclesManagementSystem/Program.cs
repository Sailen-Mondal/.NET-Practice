using Microsoft.Extensions.Configuration;
using VehiclesManagementSystem.Data;
using VehiclesManagementSystem.Helpers;
using VehiclesManagementSystem.Models;
using VehiclesManagementSystem.Repositories;
using VehiclesManagementSystem.Services;

// ── Configuration ──────────────────────────────────────────────
var configuration = new ConfigurationBuilder()
    .SetBasePath(AppContext.BaseDirectory)
    .AddJsonFile("appsettings.json", optional: false, reloadOnChange: false)
    .Build();

string connectionString = configuration.GetConnectionString("DBConn")
    ?? throw new InvalidOperationException("Connection string 'DBConn' not found in appsettings.json.");

// ── Dependency Wiring (Poor Man's DI) ──────────────────────────
var factory    = new DbConnectionFactory(connectionString);
var sqlHelper  = new SqlHelper(factory);
var repository = new VehicleRepository(sqlHelper);
var service    = new VehicleService(repository);

// ── Main Menu Loop ─────────────────────────────────────────────
bool running = true;

while (running)
{
    ConsoleHelper.PrintHeader("VEHICLE FLEET MANAGEMENT SYSTEM");
    Console.WriteLine("  1. Add New Vehicle        (Fleet Onboarding)");
    Console.WriteLine("  2. View All Vehicles      (Inventory Retrieval)");
    Console.WriteLine("  3. View Vehicle by ID     (Lookup)");
    Console.WriteLine("  4. Update Vehicle         (Telemetry Logging)");
    Console.WriteLine("  5. Delete Vehicle         (Decommissioning)");
    Console.WriteLine("  0. Exit");
    Console.WriteLine();

    int choice = ConsoleHelper.ReadInt("Enter your choice");

    try
    {
        switch (choice)
        {
            case 1: await AddVehicle(); break;
            case 2: await ViewAllVehicles(); break;
            case 3: await ViewVehicleById(); break;
            case 4: await UpdateVehicle(); break;
            case 5: await DeleteVehicle(); break;
            case 0:
                running = false;
                ConsoleHelper.PrintSuccess("Goodbye! Fleet system shutting down.");
                break;
            default:
                ConsoleHelper.PrintWarning("Invalid choice. Please select 0-5.");
                break;
        }
    }
    catch (ArgumentException ex)
    {
        ConsoleHelper.PrintError($"Validation Error: {ex.Message}");
    }
    catch (Exception ex)
    {
        ConsoleHelper.PrintError($"Unexpected Error: {ex.Message}");
    }
}

// ── Menu Handlers ──────────────────────────────────────────────

async Task AddVehicle()
{
    ConsoleHelper.PrintHeader("ADD NEW VEHICLE");

    var vehicle = new Vehicle
    {
        VIN             = ConsoleHelper.ReadString("VIN (17 characters)"),
        Make            = ConsoleHelper.ReadString("Make (e.g., Toyota)"),
        Model           = ConsoleHelper.ReadString("Model (e.g., Camry)"),
        Year            = ConsoleHelper.ReadInt("Year"),
        OdometerReading = ConsoleHelper.ReadDecimal("Initial Odometer Reading"),
        IsActive        = true
    };

    bool success = await service.AddVehicleAsync(vehicle);

    if (success)
        ConsoleHelper.PrintSuccess("Vehicle added to fleet successfully!");
    else
        ConsoleHelper.PrintError("Failed to add vehicle.");
}

async Task ViewAllVehicles()
{
    ConsoleHelper.PrintHeader("FLEET INVENTORY");
    var vehicles = await service.GetAllVehiclesAsync();
    ConsoleHelper.PrintVehicleTable(vehicles);
}

async Task ViewVehicleById()
{
    ConsoleHelper.PrintHeader("VEHICLE LOOKUP");
    int id = ConsoleHelper.ReadInt("Enter Vehicle ID");
    var vehicle = await service.GetVehicleByIdAsync(id);

    if (vehicle is not null)
    {
        ConsoleHelper.PrintVehicleTable(new List<Vehicle> { vehicle });
    }
    else
    {
        ConsoleHelper.PrintWarning($"No vehicle found with ID {id}.");
    }
}

async Task UpdateVehicle()
{
    ConsoleHelper.PrintHeader("UPDATE VEHICLE");
    int id = ConsoleHelper.ReadInt("Enter Vehicle ID to update");
    var vehicle = await service.GetVehicleByIdAsync(id);

    if (vehicle is null)
    {
        ConsoleHelper.PrintWarning($"No vehicle found with ID {id}.");
        return;
    }

    Console.WriteLine($"\n  Current: {vehicle}\n");

    vehicle.OdometerReading = ConsoleHelper.ReadDecimal($"New Odometer Reading (current: {vehicle.OdometerReading:N2})");
    vehicle.IsActive = ConsoleHelper.ReadYesNo("Is vehicle active?");

    bool success = await service.UpdateVehicleAsync(vehicle);

    if (success)
        ConsoleHelper.PrintSuccess("Vehicle updated successfully!");
    else
        ConsoleHelper.PrintError("Failed to update vehicle.");
}

async Task DeleteVehicle()
{
    ConsoleHelper.PrintHeader("DECOMMISSION VEHICLE");
    int id = ConsoleHelper.ReadInt("Enter Vehicle ID to decommission");
    var vehicle = await service.GetVehicleByIdAsync(id);

    if (vehicle is null)
    {
        ConsoleHelper.PrintWarning($"No vehicle found with ID {id}.");
        return;
    }

    Console.WriteLine($"\n  Vehicle to remove: {vehicle}\n");

    if (!ConsoleHelper.ReadYesNo("Are you sure you want to permanently delete this vehicle?"))
    {
        ConsoleHelper.PrintWarning("Deletion cancelled.");
        return;
    }

    bool success = await service.DeleteVehicleAsync(id);

    if (success)
        ConsoleHelper.PrintSuccess("Vehicle decommissioned and removed from fleet.");
    else
        ConsoleHelper.PrintError("Failed to delete vehicle.");
}
