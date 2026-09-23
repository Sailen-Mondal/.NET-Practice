namespace Assignment;

// Question 7: Abstraction.
public abstract class SmartDevice
{
    public abstract void TurnOn();
    public abstract void TurnOff();
    public abstract double GetEnergyConsumption();
}

public class SmartLight : SmartDevice
{
    public override void TurnOn()
    {
        Console.WriteLine("Smart light turned on.");
    }

    public override void TurnOff()
    {
        Console.WriteLine("Smart light turned off.");
    }

    public override double GetEnergyConsumption()
    {
        return 0.05;
    }
}

public class SmartThermostat : SmartDevice
{
    public override void TurnOn()
    {
        Console.WriteLine("Smart thermostat turned on.");
    }

    public override void TurnOff()
    {
        Console.WriteLine("Smart thermostat turned off.");
    }

    public override double GetEnergyConsumption()
    {
        return 0.10;
    }
}

public class SmartAC : SmartDevice
{
    public override void TurnOn()
    {
        Console.WriteLine("Smart AC turned on.");
    }

    public override void TurnOff()
    {
        Console.WriteLine("Smart AC turned off.");
    }

    public override double GetEnergyConsumption()
    {
        return 1.50;
    }
}
