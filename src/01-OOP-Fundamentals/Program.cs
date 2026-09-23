namespace Assignment;

internal class Program
{
    private static void Main()
    {
        //RunQuestion1();
        //RunQuestion2();
        //RunQuestion3();
        //RunQuestion4();
        //RunQuestion5();
        //RunQuestion6();
        //RunQuestion7();
        //RunQuestion8();
        RunQuestion9();
        RunQuestion10();
    }

    // Question 1: Encapsulation
    private static void RunQuestion1()
    {
        PrintHeading("QUESTION 1 - ENCAPSULATION");

        PaymentProcessor payment = new PaymentProcessor();
        payment.CardNumber = "1234567812345678";
        payment.AccountBalance = 5000;
        payment.SecurityToken = "bank-api-token";

        Console.WriteLine($"Masked card: {payment.CardNumber}");
        Console.WriteLine($"Balance: {payment.AccountBalance}");
    }

    // Question 2: Patient record
    private static void RunQuestion2()
    {
        PrintHeading("QUESTION 2 - PATIENT RECORD");

        PatientRecord patient = new PatientRecord("Asha", "No allergies");
        patient.UpdateVitalSigns(0, 0);
        patient.MarkBillAsPaid();

        Console.WriteLine($"{patient.PatientName}'s heart rate: {patient.GetHeartRate()}");
        Console.WriteLine($"Bill paid: {patient.BillingPaid}");
    }

    // Question 3: Employee payroll
    private static void RunQuestion3()
    {
        PrintHeading("QUESTION 3 - EMPLOYEE PAYROLL");

        Employee[] employees =
        {
            new FullTimeEmployee(1, "Ravi", 50000),
            new ContractEmployee(2, "Maya", 40000),
            new Freelancer(3, "Sam", 30000)
        };

        foreach (Employee employee in employees)
        {
            Console.WriteLine($"{employee.Name}'s net salary: {employee.CalculateNetSalary()}");
        }
    }

    // Question 4: Vehicle inheritance
    private static void RunQuestion4()
    {
        PrintHeading("QUESTION 4 - VEHICLE INHERITANCE");

        ElectricTruck truck = new ElectricTruck("TRK-101", 100, 300);
        truck.StartEngine();
        truck.LogGPS();

        Console.WriteLine($"Range: {truck.CalculateRange()} km");
    }

    // Question 5: Notifications
    private static void RunQuestion5()
    {
        PrintHeading("QUESTION 5 - NOTIFICATIONS");

        Notification[] notifications =
        {
            new EmailNotification(),
            new SmsNotification(),
            new WhatsAppNotification(),
            new PushNotification()
        };

        foreach (Notification notification in notifications)
        {
            notification.SendNotification("Server update available");
        }
    }

    // Question 6: Polymorphism
    private static void RunQuestion6()
    {
        PrintHeading("QUESTION 6 - POLYMORPHISM");

        AreaCalculator calculator = new AreaCalculator();
        Console.WriteLine($"Circle area: {calculator.CalculateArea(5)}");
        Console.WriteLine($"Rectangle area: {calculator.CalculateArea(4, 6)}");

        Shape[] shapes = { new Circle(), new Polygon() };
        foreach (Shape shape in shapes)
        {
            shape.Draw();
        }
    }

    // Question 7: Abstraction
    private static void RunQuestion7()
    {
        PrintHeading("QUESTION 7 - ABSTRACTION");

        SmartDevice[] devices = { new SmartLight(), new SmartThermostat(), new SmartAC() };
        foreach (SmartDevice device in devices)
        {
            device.TurnOn();
            Console.WriteLine($"Energy: {device.GetEnergyConsumption()} units");
            device.TurnOff();
        }
    }

    // Question 8: Loans
    private static void RunQuestion8()
    {
        PrintHeading("QUESTION 8 - LOANS");

        Loan[] loans = { new HomeLoan(), new CarLoan(), new EducationLoan() };
        foreach (Loan loan in loans)
        {
            loan.VerifyDocuments();
            Console.WriteLine($"{loan.GetType().Name} interest: {loan.CalculateInterestRate()}%");
            Console.WriteLine($"Eligible: {loan.CheckEligibility(700)}");
            loan.SanctionAmount(100000);
        }
    }

    // Question 9: Cloud storage
    private static void RunQuestion9()
    {
        PrintHeading("QUESTION 9 - CLOUD STORAGE");

        ICloudStorageProvider[] providers = { new S3Storage(), new AzureStorage() };
        foreach (ICloudStorageProvider provider in providers)
        {
            provider.UploadFile("photo.jpg");
            provider.DownloadFile("file-101");
            provider.DeleteFile("file-101");
        }
    }

    // Question 10: Robot interfaces
    private static void RunQuestion10()
    {
        PrintHeading("QUESTION 10 - ROBOT INTERFACES");

        WarehouseRobot robot = new WarehouseRobot("WR-01");
        robot.Start();
        robot.NavigateTo("Shelf A3");
        robot.ReadSensor();
        robot.Charge();
    }

    private static void PrintHeading(string title)
    {
        Console.WriteLine();
        Console.WriteLine(new string('=', 45));
        Console.WriteLine(title);
        Console.WriteLine(new string('=', 45));
    }

    //for testing purposes only
    public static void test()
    {

    }

}
