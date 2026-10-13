using System;
using System.Data;
using WebApplication1.DAL;
using WebApplication1.Models;

namespace WebApplication1.BLL
{
    // =========================================================================
    // BUSINESS LOGIC LAYER (BLL)
    // Acts as a mediator between Presentation Layer (UI) and Data Access Layer (DAL)
    // Enforces validation and business rules
    // =========================================================================
    public class EmployeeBLL
    {
        private readonly EmployeeDAL dal = new EmployeeDAL();

        // Validate and insert employee
        public int AddEmployee(Employee emp)
        {
            // Business Validation Rules
            if (string.IsNullOrWhiteSpace(emp.FirstName))
            {
                throw new Exception("First Name is required.");
            }

            if (string.IsNullOrWhiteSpace(emp.LastName))
            {
                throw new Exception("Last Name is required.");
            }

            if (emp.Age <= 0 || emp.Age > 120)
            {
                throw new Exception("Please enter a valid age (between 1 and 120).");
            }

            if (emp.Salary < 0)
            {
                throw new Exception("Salary cannot be negative.");
            }

            // Call DAL to insert into database
            return dal.InsertEmployee(emp);
        }

        // Fetch all employees from DAL
        public DataTable GetEmployees()
        {
            return dal.GetAllEmployees();
        }
    }
}
