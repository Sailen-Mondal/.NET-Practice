namespace ConsoleAppCURD
{
    public class Employee
    {
        public int ID { get; set; }
        public string LastName { get; set; } = string.Empty;
        public string FirstName { get; set; } = string.Empty;
        public int Age { get; set; }
        public string City { get; set; } = string.Empty;
        public DateTime DateOfJoining { get; set; }
        public decimal Salary { get; set; }
    }
}
