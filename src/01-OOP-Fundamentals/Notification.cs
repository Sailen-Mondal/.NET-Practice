namespace Assignment;

// Question 5: Runtime polymorphism.
public class Notification
{
    public virtual void SendNotification(string message)
    {
        Console.WriteLine("Notification: " + message);
    }
}

public class EmailNotification : Notification
{
    public override void SendNotification(string message)
    {
        Console.WriteLine("Email sent: " + message);
    }
}

public class SmsNotification : Notification
{
    public override void SendNotification(string message)
    {
        Console.WriteLine("SMS sent: " + message);
    }
}

public class WhatsAppNotification : Notification
{
    public override void SendNotification(string message)
    {
        Console.WriteLine("WhatsApp message sent: " + message);
    }
}

public class PushNotification : Notification
{
    public override void SendNotification(string message)
    {
        Console.WriteLine("Push notification sent: " + message);
    }
}
