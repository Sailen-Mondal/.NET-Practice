using System;

namespace WebApplication1.Models
{
    // =========================================================================
    // MODEL / ENTITY: Employee
    // Represents the Employee table structure in the ADOPractice database
    // =========================================================================
    public class Employee
    {
        public int ID { get; set; }
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public int Age { get; set; }
        public string City { get; set; }
        public DateTime DateOfJoining { get; set; }
        public decimal Salary { get; set; }
    }
}
