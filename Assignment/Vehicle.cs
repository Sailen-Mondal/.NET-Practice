namespace Assignment;

// Question 4: Multilevel inheritance.
public class Vehicle
{
    protected string VehicleId;

    public Vehicle(string vehicleId)
    {
        VehicleId = vehicleId;
    }

    public void LogGPS()
    {
        Console.WriteLine(VehicleId + " GPS location logged.");
    }
}

public class MotorizedVehicle : Vehicle
{
    protected int FuelLevel;

    public MotorizedVehicle(string vehicleId, int fuelLevel)
        : base(vehicleId)
    {
        FuelLevel = fuelLevel;
    }

    public void StartEngine()
    {
        Console.WriteLine(VehicleId + " engine started.");
    }
}

public class ElectricTruck : MotorizedVehicle
{
    private int _batteryCapacity;

    public ElectricTruck(string vehicleId, int fuelLevel, int batteryCapacity)
        : base(vehicleId, fuelLevel)
    {
        _batteryCapacity = batteryCapacity;
    }

    public int CalculateRange()
    {
        return _batteryCapacity * 2;
    }
}
