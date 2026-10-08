namespace VehiclesManagementSystem.Models;

/// <summary>
/// Represents a commercial vehicle in the fleet.
/// Maps 1:1 to the dbo.Vehicles table.
/// </summary>
public class Vehicle
{
    public int Id { get; set; }

    /// <summary>17-character Vehicle Identification Number.</summary>
    public string VIN { get; set; } = string.Empty;

    public string Make { get; set; } = string.Empty;

    public string Model { get; set; } = string.Empty;

    public int Year { get; set; }

    /// <summary>Cumulative distance traveled (miles or km).</summary>
    public decimal OdometerReading { get; set; }

    /// <summary>True if the vehicle is operationally available.</summary>
    public bool IsActive { get; set; } = true;

    public DateTime CreatedAt { get; set; }

    public DateTime? UpdatedAt { get; set; }

    public override string ToString()
    {
        string status = IsActive ? "Active" : "Inactive";
        return $"[{Id}] {Year} {Make} {Model} | VIN: {VIN} | " +
               $"Odometer: {OdometerReading:N2} | Status: {status}";
    }
}
