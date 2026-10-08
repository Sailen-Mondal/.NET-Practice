using VehiclesManagementSystem.Models;
using VehiclesManagementSystem.Repositories;

namespace VehiclesManagementSystem.Services;

/// <summary>
/// Business logic and validation layer for vehicle operations.
/// Decouples console presentation from data access and enforces
/// domain rules before any database call.
/// </summary>
public class VehicleService
{
    private readonly IRepository<Vehicle> _repository;

    public VehicleService(IRepository<Vehicle> repository)
    {
        _repository = repository ?? throw new ArgumentNullException(nameof(repository));
    }

    /// <summary>Retrieves a vehicle by its primary key.</summary>
    public async Task<Vehicle?> GetVehicleByIdAsync(int id)
    {
        if (id <= 0)
            throw new ArgumentException("Vehicle ID must be a positive integer.", nameof(id));

        return await _repository.GetByIdAsync(id);
    }

    /// <summary>Retrieves all vehicles in the fleet.</summary>
    public async Task<List<Vehicle>> GetAllVehiclesAsync()
    {
        return await _repository.GetAllAsync();
    }

    /// <summary>Validates and adds a new vehicle to the fleet.</summary>
    public async Task<bool> AddVehicleAsync(Vehicle vehicle)
    {
        ValidateVehicle(vehicle);
        int rows = await _repository.AddAsync(vehicle);
        return rows > 0;
    }

    /// <summary>Validates and updates an existing vehicle's data.</summary>
    public async Task<bool> UpdateVehicleAsync(Vehicle vehicle)
    {
        if (vehicle.Id <= 0)
            throw new ArgumentException("Vehicle ID must be set for update.", nameof(vehicle));

        ValidateVehicle(vehicle);
        int rows = await _repository.UpdateAsync(vehicle);
        return rows > 0;
    }

    /// <summary>Permanently deletes a vehicle from the fleet (hard delete).</summary>
    public async Task<bool> DeleteVehicleAsync(int id)
    {
        if (id <= 0)
            throw new ArgumentException("Vehicle ID must be a positive integer.", nameof(id));

        int rows = await _repository.DeleteAsync(id);
        return rows > 0;
    }

    /// <summary>
    /// Common field-level validations applied before any write operation.
    /// </summary>
    private static void ValidateVehicle(Vehicle vehicle)
    {
        if (string.IsNullOrWhiteSpace(vehicle.VIN) || vehicle.VIN.Length != 17)
            throw new ArgumentException("VIN must be exactly 17 characters.");

        if (string.IsNullOrWhiteSpace(vehicle.Make))
            throw new ArgumentException("Make is required.");

        if (string.IsNullOrWhiteSpace(vehicle.Model))
            throw new ArgumentException("Model is required.");

        if (vehicle.Year < 1886 || vehicle.Year > DateTime.Now.Year + 1)
            throw new ArgumentException($"Year must be between 1886 and {DateTime.Now.Year + 1}.");

        if (vehicle.OdometerReading < 0)
            throw new ArgumentException("Odometer reading cannot be negative.");
    }
}
