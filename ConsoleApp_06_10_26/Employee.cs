using System;

namespace ConsoleApp_06_10_26
{
    // ================================================================
    // Employee Model - Maps to the Employees table columns
    // ================================================================
    public class Employee
    {
        public int ID { get; set; }
        public string LastName { get; set; }
        public string FirstName { get; set; }
        public int? Age { get; set; }
        public string City { get; set; }
        public DateTime? DateOfJoining { get; set; }
        public decimal? Salary { get; set; }
    }
}
