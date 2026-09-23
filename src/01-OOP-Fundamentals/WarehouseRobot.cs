namespace Assignment;

// Question 10: One base class plus multiple interfaces.
public abstract class BaseRobot
{
    protected string RobotId;

    protected BaseRobot(string robotId)
    {
        RobotId = robotId;
    }

    public void Start()
    {
        Console.WriteLine(RobotId + " started.");
    }
}

public interface ISensorReadable
{
    void ReadSensor();
}

public interface INavigable
{
    void NavigateTo(string location);
}

public interface IChargeable
{
    void Charge();
}

public class WarehouseRobot : BaseRobot, ISensorReadable, INavigable, IChargeable
{
    public WarehouseRobot(string robotId) : base(robotId)
    {
    }

    public void ReadSensor()
    {
        Console.WriteLine("Sensor data read.");
    }

    public void NavigateTo(string location)
    {
        Console.WriteLine("Navigating to " + location);
    }

    public void Charge()
    {
        Console.WriteLine("Robot is charging.");
    }
}
