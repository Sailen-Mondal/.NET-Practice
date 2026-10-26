using System;
using System.Collections.Generic;
using System.Data.Linq.Mapping;

namespace LINQDemo.Models
{
    /// <summary>
    /// Employee entity mapped for both in-memory LINQ queries and LINQ to SQL database operations.
    /// </summary>
    [Table(Name = "Employees")]
    public class Employee
    {
        // Primary key mapped to database identity column
        [Column(IsPrimaryKey = true, IsDbGenerated = true)]
        public int ID { get; set; }

        [Column]
        public string FirstName { get; set; }

        [Column]
        public string LastName { get; set; }

        private string _name;

        // Name property: returns stored name or combines FirstName and LastName
        public string Name
        {
            get
            {
                if (!string.IsNullOrEmpty(_name))
                {
                    return _name;
                }

                if (!string.IsNullOrEmpty(FirstName) || !string.IsNullOrEmpty(LastName))
                {
                    return (FirstName + " " + LastName).Trim();
                }

                return string.Empty;
            }
            set
            {
                _name = value;
                if (!string.IsNullOrEmpty(value) && string.IsNullOrEmpty(FirstName))
                {
                    string[] parts = value.Split(new[] { ' ' }, 2);
                    FirstName = parts[0];
                    if (parts.Length > 1)
                    {
                        LastName = parts[1];
                    }
                }
            }
        }

        [Column]
        public string Gender { get; set; }

        // Department name for grouping queries
        public string Department { get; set; }

        // Foreign key referencing Departments table (nullable to allow employees without a department)
        [Column(Name = "DepartmentId")]
        public int? DepartmentID { get; set; }

        [Column]
        public int Salary { get; set; }

        /// <summary>
        /// Seed dataset for GroupBy demonstrations (all employees assigned to departments).
        /// </summary>
        public static List<Employee> GetAllEmployeesForGroupBy()
        {
            return new List<Employee>
            {
                new Employee { ID = 1,  Name = "Mark",    FirstName = "Mark",    LastName = "Wood",     Gender = "Male",   Department = "IT", DepartmentID = 1, Salary = 45000 },
                new Employee { ID = 2,  Name = "Steve",   FirstName = "Steve",   LastName = "Smith",    Gender = "Male",   Department = "HR", DepartmentID = 2, Salary = 55000 },
                new Employee { ID = 3,  Name = "Ben",     FirstName = "Ben",     LastName = "Stokes",   Gender = "Male",   Department = "IT", DepartmentID = 1, Salary = 65000 },
                new Employee { ID = 4,  Name = "Philip",  FirstName = "Philip",  LastName = "Hughes",   Gender = "Male",   Department = "IT", DepartmentID = 1, Salary = 55000 },
                new Employee { ID = 5,  Name = "Mary",    FirstName = "Mary",    LastName = "Kom",      Gender = "Female", Department = "HR", DepartmentID = 2, Salary = 48000 },
                new Employee { ID = 6,  Name = "Valarie", FirstName = "Valarie", LastName = "Adams",    Gender = "Female", Department = "HR", DepartmentID = 2, Salary = 70000 },
                new Employee { ID = 7,  Name = "John",    FirstName = "John",    LastName = "Doe",      Gender = "Male",   Department = "IT", DepartmentID = 1, Salary = 64000 },
                new Employee { ID = 8,  Name = "Pam",     FirstName = "Pam",     LastName = "Beesly",   Gender = "Female", Department = "IT", DepartmentID = 1, Salary = 54000 },
                new Employee { ID = 9,  Name = "Stacey",  FirstName = "Stacey",  LastName = "Jones",    Gender = "Female", Department = "HR", DepartmentID = 2, Salary = 84000 },
                new Employee { ID = 10, Name = "Andy",    FirstName = "Andy",    LastName = "Bernard",  Gender = "Male",   Department = "IT", DepartmentID = 1, Salary = 36000 }
            };
        }

        /// <summary>
        /// Seed dataset for Inner Join demonstrations.
        /// Notice: Employee Andy has DepartmentID = null, so Andy is excluded in an Inner Join.
        /// </summary>
        public static List<Employee> GetAllEmployees()
        {
            return new List<Employee>
            {
                new Employee { ID = 1,  Name = "Mark",    FirstName = "Mark",    LastName = "Wood",    Gender = "Male",   DepartmentID = 1, Salary = 45000 },
                new Employee { ID = 2,  Name = "Steve",   FirstName = "Steve",   LastName = "Smith",   Gender = "Male",   DepartmentID = 2, Salary = 55000 },
                new Employee { ID = 3,  Name = "Ben",     FirstName = "Ben",     LastName = "Stokes",  Gender = "Male",   DepartmentID = 1, Salary = 65000 },
                new Employee { ID = 4,  Name = "Philip",  FirstName = "Philip",  LastName = "Hughes",  Gender = "Male",   DepartmentID = 1, Salary = 55000 },
                new Employee { ID = 5,  Name = "Mary",    FirstName = "Mary",    LastName = "Kom",     Gender = "Female", DepartmentID = 2, Salary = 48000 },
                new Employee { ID = 6,  Name = "Valarie", FirstName = "Valarie", LastName = "Adams",   Gender = "Female", DepartmentID = 2, Salary = 70000 },
                new Employee { ID = 7,  Name = "John",    FirstName = "John",    LastName = "Doe",     Gender = "Male",   DepartmentID = 1, Salary = 64000 },
                new Employee { ID = 8,  Name = "Pam",     FirstName = "Pam",     LastName = "Beesly",  Gender = "Female", DepartmentID = 1, Salary = 54000 },
                new Employee { ID = 9,  Name = "Stacey",  FirstName = "Stacey",  LastName = "Jones",   Gender = "Female", DepartmentID = 2, Salary = 84000 },
                new Employee { ID = 10, Name = "Andy",    FirstName = "Andy",    LastName = "Bernard", Gender = "Male",   DepartmentID = null, Salary = 36000 } // Unassigned department
            };
        }
    }
}
