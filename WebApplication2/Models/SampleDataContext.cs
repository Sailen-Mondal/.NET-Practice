using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.Linq;
using System.Data.Linq.Mapping;
using System.Reflection;

namespace CRUDUsingLINQ.Models
{
    [Table(Name = "dbo.Students")]
    public class Student
    {
        [Column(IsPrimaryKey = true, IsDbGenerated = true, AutoSync = AutoSync.OnInsert)]
        public int ID { get; set; }

        [Column(CanBeNull = false)]
        public string FirstName { get; set; }

        [Column(CanBeNull = false)]
        public string LastName { get; set; }

        [Column(CanBeNull = false)]
        public string Gender { get; set; }

        // In-memory demo helper
        public int StudentID { get { return ID; } set { ID = value; } }
        public string Name { get { return FirstName + " " + LastName; } set { FirstName = value; } }
        public int TotalMarks { get; set; }

        public static List<Student> GetAllStudents()
        {
            return new List<Student>
            {
                new Student { ID = 101, FirstName = "Tom", LastName = "Hardy", Gender = "Male", TotalMarks = 800 },
                new Student { ID = 102, FirstName = "Mary", LastName = "Lambeth", Gender = "Female", TotalMarks = 900 },
                new Student { ID = 103, FirstName = "Valarie", LastName = "Hoskins", Gender = "Female", TotalMarks = 800 },
                new Student { ID = 104, FirstName = "John", LastName = "Doe", Gender = "Male", TotalMarks = 800 }
            };
        }
    }

    [Table(Name = "dbo.Departments")]
    public class Department
    {
        [Column(IsPrimaryKey = true, IsDbGenerated = true, AutoSync = AutoSync.OnInsert)]
        public int ID { get; set; }

        [Column(CanBeNull = false)]
        public string Name { get; set; }

        public static List<Department> GetAllDepartments()
        {
            return new List<Department>
            {
                new Department { ID = 1, Name = "IT" },
                new Department { ID = 2, Name = "HR" },
                new Department { ID = 3, Name = "Payroll" }
            };
        }
    }

    [Table(Name = "dbo.Employees")]
    public class Employee
    {
        [Column(IsPrimaryKey = true, IsDbGenerated = true, AutoSync = AutoSync.OnInsert)]
        public int ID { get; set; }

        [Column(CanBeNull = false)]
        public string FirstName { get; set; }

        [Column(CanBeNull = true)]
        public string LastName { get; set; }

        [Column(CanBeNull = false)]
        public string Gender { get; set; }

        [Column(CanBeNull = true)]
        public int? Salary { get; set; }

        [Column(CanBeNull = true)]
        public int? DepartmentId { get; set; }

        // Helpers for in-memory and display queries
        public string Name
        {
            get
            {
                return string.IsNullOrEmpty(LastName) ? FirstName : (FirstName + " " + LastName);
            }
            set
            {
                if (string.IsNullOrWhiteSpace(value))
                {
                    FirstName = "";
                    LastName = "";
                }
                else
                {
                    string[] parts = value.Trim().Split(new char[] { ' ' }, 2);
                    FirstName = parts[0];
                    LastName = parts.Length > 1 ? parts[1] : "";
                }
            }
        }

        public string Department { get; set; }

        public static List<Employee> GetAllEmployees()
        {
            return new List<Employee>
            {
                new Employee { ID = 1, FirstName = "Mark", LastName = "Hastings", Gender = "Male", Department = "IT", DepartmentId = 1, Salary = 45000 },
                new Employee { ID = 2, FirstName = "Steve", LastName = "Pound", Gender = "Male", Department = "HR", DepartmentId = 2, Salary = 55000 },
                new Employee { ID = 3, FirstName = "Ben", LastName = "Hoskins", Gender = "Male", Department = "IT", DepartmentId = 1, Salary = 65000 },
                new Employee { ID = 4, FirstName = "Philip", LastName = "Hastings", Gender = "Male", Department = "IT", DepartmentId = 1, Salary = 55000 },
                new Employee { ID = 5, FirstName = "Mary", LastName = "Lambeth", Gender = "Female", Department = "HR", DepartmentId = 2, Salary = 48000 },
                new Employee { ID = 6, FirstName = "Valarie", LastName = "Hoskins", Gender = "Female", Department = "HR", DepartmentId = 2, Salary = 70000 },
                new Employee { ID = 7, FirstName = "John", LastName = "Doe", Gender = "Male", Department = "IT", DepartmentId = 1, Salary = 64000 },
                new Employee { ID = 8, FirstName = "Pam", LastName = "Beesly", Gender = "Female", Department = "IT", DepartmentId = 1, Salary = 54000 },
                new Employee { ID = 9, FirstName = "Stacey", LastName = "Adams", Gender = "Female", Department = "HR", DepartmentId = 2, Salary = 84000 },
                new Employee { ID = 10, FirstName = "Andy", LastName = "Bernard", Gender = "Male", Department = null, DepartmentId = null, Salary = 36000 }
            };
        }
    }

    [Table(Name = "dbo.Employee1")]
    public class Employee1
    {
        [Column(IsPrimaryKey = true, IsDbGenerated = true, AutoSync = AutoSync.OnInsert)]
        public int ID { get; set; }

        [Column(CanBeNull = false)]
        public string Name { get; set; }

        [Column(CanBeNull = false)]
        public string Location { get; set; }

        [Column(CanBeNull = false)]
        public string Gender { get; set; }
    }

    public class SampleDataContext : DataContext
    {
        public Table<Student> Students { get { return this.GetTable<Student>(); } }
        public Table<Department> Departments { get { return this.GetTable<Department>(); } }
        public Table<Employee> Employees { get { return this.GetTable<Employee>(); } }
        public Table<Employee1> Employee1 { get { return this.GetTable<Employee1>(); } }

        public SampleDataContext() 
            : base(ConfigurationManager.ConnectionStrings["conStr"] != null 
                  ? ConfigurationManager.ConnectionStrings["conStr"].ConnectionString 
                  : "Data Source=.;Initial Catalog=ProjectManagementDB;User ID=sa;Password=mcc#1234;TrustServerCertificate=True")
        {
        }

        public SampleDataContext(string fileOrServerOrConnection) : base(fileOrServerOrConnection)
        {
        }

        [Function(Name = "dbo.GetEmployees")]
        public ISingleResult<Employee> GetEmployees()
        {
            IExecuteResult result = this.ExecuteMethodCall(this, ((MethodInfo)(MethodInfo.GetCurrentMethod())));
            return (ISingleResult<Employee>)(result.ReturnValue);
        }

        [Function(Name = "dbo.InsertEmployee")]
        public int InsertEmployee(
            [Parameter(Name = "FirstName", DbType = "NVarChar(50)")] string firstName,
            [Parameter(Name = "LastName", DbType = "NVarChar(50)")] string lastName,
            [Parameter(Name = "Gender", DbType = "NVarChar(50)")] string gender,
            [Parameter(Name = "Salary", DbType = "Int")] int? salary,
            [Parameter(Name = "DepartmentId", DbType = "Int")] int? departmentId)
        {
            IExecuteResult result = this.ExecuteMethodCall(this, ((MethodInfo)(MethodInfo.GetCurrentMethod())), firstName, lastName, gender, salary, departmentId);
            return (int)result.ReturnValue;
        }

        [Function(Name = "dbo.UpdateEmployee")]
        public int UpdateEmployee(
            [Parameter(Name = "ID", DbType = "Int")] int id,
            [Parameter(Name = "FirstName", DbType = "NVarChar(50)")] string firstName,
            [Parameter(Name = "LastName", DbType = "NVarChar(50)")] string lastName,
            [Parameter(Name = "Gender", DbType = "NVarChar(50)")] string gender,
            [Parameter(Name = "Salary", DbType = "Int")] int? salary,
            [Parameter(Name = "DepartmentId", DbType = "Int")] int? departmentId)
        {
            IExecuteResult result = this.ExecuteMethodCall(this, ((MethodInfo)(MethodInfo.GetCurrentMethod())), id, firstName, lastName, gender, salary, departmentId);
            return (int)result.ReturnValue;
        }

        [Function(Name = "dbo.DeleteEmployee")]
        public int DeleteEmployee([Parameter(Name = "ID", DbType = "Int")] int id)
        {
            IExecuteResult result = this.ExecuteMethodCall(this, ((MethodInfo)(MethodInfo.GetCurrentMethod())), id);
            return (int)result.ReturnValue;
        }

        [Function(Name = "dbo.GetEmployeesByDepartment")]
        public ISingleResult<Employee> GetEmployeesByDepartment(
            [Parameter(Name = "DepartmentId", DbType = "Int")] int departmentId,
            [Parameter(Name = "DepartmentName", DbType = "NVarChar(50)")] ref string departmentName)
        {
            IExecuteResult result = this.ExecuteMethodCall(this, ((MethodInfo)(MethodInfo.GetCurrentMethod())), departmentId, departmentName);
            departmentName = (string)result.GetParameterValue(1);
            return (ISingleResult<Employee>)(result.ReturnValue);
        }
    }
}
