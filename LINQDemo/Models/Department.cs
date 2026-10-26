using System;
using System.Collections.Generic;
using System.Data.Linq.Mapping;

namespace LINQDemo.Models
{
    /// <summary>
    /// Department entity mapped for both in-memory LINQ queries and LINQ to SQL database operations.
    /// </summary>
    [Table(Name = "Departments")]
    public class Department
    {
        // Primary key mapped to database identity column
        [Column(IsPrimaryKey = true, IsDbGenerated = true)]
        public int ID { get; set; }

        [Column]
        public string Name { get; set; }

        // Navigation collection representing the employees belonging to this department
        public List<Employee> Employees { get; set; }

        public Department()
        {
            Employees = new List<Employee>();
        }

        /// <summary>
        /// Provides flat department records for Inner Join demonstrations.
        /// </summary>
        public static List<Department> GetAllDepartments()
        {
            return new List<Department>
            {
                new Department { ID = 1, Name = "IT" },
                new Department { ID = 2, Name = "HR" },
                new Department { ID = 3, Name = "Payroll" } // Notice: Payroll has no employees assigned
            };
        }

        /// <summary>
        /// Provides nested department and employee structures for Restriction Operator demonstrations.
        /// </summary>
        public static List<Department> GetDepartmentsWithEmployees()
        {
            Department it = new Department { ID = 1, Name = "IT" };
            it.Employees.Add(new Employee { ID = 1, FirstName = "Mark", LastName = "Wood", Gender = "Male", DepartmentID = 1, Salary = 45000 });
            it.Employees.Add(new Employee { ID = 3, FirstName = "Ben", LastName = "Stokes", Gender = "Male", DepartmentID = 1, Salary = 65000 });
            it.Employees.Add(new Employee { ID = 4, FirstName = "Philip", LastName = "Hughes", Gender = "Male", DepartmentID = 1, Salary = 55000 });
            it.Employees.Add(new Employee { ID = 7, FirstName = "John", LastName = "Doe", Gender = "Male", DepartmentID = 1, Salary = 64000 });
            it.Employees.Add(new Employee { ID = 8, FirstName = "Pam", LastName = "Beesly", Gender = "Female", DepartmentID = 1, Salary = 54000 });

            Department hr = new Department { ID = 2, Name = "HR" };
            hr.Employees.Add(new Employee { ID = 2, FirstName = "Steve", LastName = "Smith", Gender = "Male", DepartmentID = 2, Salary = 55000 });
            hr.Employees.Add(new Employee { ID = 5, FirstName = "Mary", LastName = "Kom", Gender = "Female", DepartmentID = 2, Salary = 48000 });
            hr.Employees.Add(new Employee { ID = 6, FirstName = "Valarie", LastName = "Adams", Gender = "Female", DepartmentID = 2, Salary = 70000 });
            hr.Employees.Add(new Employee { ID = 9, FirstName = "Stacey", LastName = "Jones", Gender = "Female", DepartmentID = 2, Salary = 84000 });

            Department payroll = new Department { ID = 3, Name = "Payroll" };
            // Payroll has no employees assigned

            return new List<Department> { it, hr, payroll };
        }
    }
}
