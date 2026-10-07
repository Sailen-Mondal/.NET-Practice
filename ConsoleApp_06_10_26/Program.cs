using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace ConsoleApp_06_10_26
{
    // ================================================================
    // Program - Interactive console menu for CRUD operations
    // ================================================================
    internal class Program
    {
        static void Main(string[] args)
        {
            string connectionString =
                ConfigurationManager.ConnectionStrings["DBConn"].ConnectionString;

            // Data access via interface
            IEmployeeRepository repository = new EmployeeRepository(connectionString);

            /* ==============================================================================
               PREVIOUS CODE (COMMENTED OUT) - DataTable & DataSet operations on Students
               ==============================================================================

            SqlDataAdapter dataAdapter =
                new SqlDataAdapter(
                    "SELECT * FROM Students",
                    connectionString
                );

            DataTable studentTable = new DataTable();

            dataAdapter.Fill(studentTable);

            Console.WriteLine("===== USING DATATABLE =====");

            foreach (DataRow row in studentTable.Rows)
            {
                Console.WriteLine(
                    row["Id"] + " | " +
                    row["Name"] + " | " +
                    row["Email"] + " | " +
                    row["Age"]
                );
            }

            Console.WriteLine();
            Console.WriteLine("===== USING DATASET + STORED PROCEDURE =====");

            DataSet dataSet = new DataSet();

            SqlDataAdapter procedureAdapter =
                new SqlDataAdapter(
                    "GetAllStudents",
                    connectionString
                );

            procedureAdapter.SelectCommand.CommandType =
                CommandType.StoredProcedure;

            procedureAdapter.Fill(dataSet, "Students");

            foreach (DataRow row in dataSet.Tables["Students"].Rows)
            {
                Console.WriteLine(
                    row["Id"] + " | " +
                    row["Name"] + " | " +
                    row["Email"] + " | " +
                    row["Age"]
                );
            }

            ============================================================================== */

            // Main menu loop
            bool running = true;
            while (running)
            {
                Console.WriteLine();
                Console.WriteLine("========== EMPLOYEE CRUD MENU ==========");
                Console.WriteLine("1. Add New Employee");
                Console.WriteLine("2. View All Employees");
                Console.WriteLine("3. View Employee By ID");
                Console.WriteLine("4. Update Employee");
                Console.WriteLine("5. Delete Employee");
                Console.WriteLine("6. Exit");
                Console.Write("Select an option: ");

                string choice = Console.ReadLine();

                switch (choice)
                {
                    case "1":
                        AddEmployee(repository);
                        break;
                    case "2":
                        ViewAllEmployees(repository);
                        break;
                    case "3":
                        ViewEmployeeById(repository);
                        break;
                    case "4":
                        UpdateEmployee(repository);
                        break;
                    case "5":
                        DeleteEmployee(repository);
                        break;
                    case "6":
                        running = false;
                        break;
                    default:
                        Console.WriteLine("Invalid option. Try again.");
                        break;
                }
            }
        }

        // Collects employee details from user and inserts via repository
        static void AddEmployee(IEmployeeRepository repo)
        {
            Employee emp = new Employee();

            Console.Write("Last Name (required): ");
            emp.LastName = Console.ReadLine();

            Console.Write("First Name: ");
            string firstName = Console.ReadLine();
            emp.FirstName = string.IsNullOrWhiteSpace(firstName) ? null : firstName;

            Console.Write("Age: ");
            string ageInput = Console.ReadLine();
            emp.Age = int.TryParse(ageInput, out int age) ? age : (int?)null;

            Console.Write("City: ");
            string city = Console.ReadLine();
            emp.City = string.IsNullOrWhiteSpace(city) ? null : city;

            Console.Write("Date of Joining (yyyy-MM-dd): ");
            string dateInput = Console.ReadLine();
            emp.DateOfJoining = DateTime.TryParse(dateInput, out DateTime doj) ? doj : (DateTime?)null;

            Console.Write("Salary: ");
            string salaryInput = Console.ReadLine();
            emp.Salary = decimal.TryParse(salaryInput, out decimal salary) ? salary : (decimal?)null;

            int newId = repo.AddEmployee(emp);
            Console.WriteLine($"Employee added successfully with ID: {newId}");
        }

        // Displays all employees in a formatted table
        static void ViewAllEmployees(IEmployeeRepository repo)
        {
            List<Employee> employees = repo.GetAllEmployees();

            if (employees.Count == 0)
            {
                Console.WriteLine("No employees found.");
                return;
            }

            Console.WriteLine(
                "\n{0,-5} {1,-15} {2,-15} {3,-5} {4,-15} {5,-15} {6,-12}",
                "ID", "Last Name", "First Name", "Age", "City", "Date Joined", "Salary"
            );
            Console.WriteLine(new string('-', 85));

            foreach (Employee emp in employees)
            {
                Console.WriteLine(
                    "{0,-5} {1,-15} {2,-15} {3,-5} {4,-15} {5,-15} {6,-12}",
                    emp.ID,
                    emp.LastName,
                    emp.FirstName ?? "-",
                    emp.Age?.ToString() ?? "-",
                    emp.City ?? "-",
                    emp.DateOfJoining?.ToString("yyyy-MM-dd") ?? "-",
                    emp.Salary?.ToString("F2") ?? "-"
                );
            }
        }

        // Looks up a single employee by ID
        static void ViewEmployeeById(IEmployeeRepository repo)
        {
            Console.Write("Enter Employee ID: ");
            if (!int.TryParse(Console.ReadLine(), out int id))
            {
                Console.WriteLine("Invalid ID.");
                return;
            }

            Employee emp = repo.GetEmployeeById(id);

            if (emp == null)
            {
                Console.WriteLine($"No employee found with ID: {id}");
                return;
            }

            Console.WriteLine($"\nID             : {emp.ID}");
            Console.WriteLine($"Last Name      : {emp.LastName}");
            Console.WriteLine($"First Name     : {emp.FirstName ?? "-"}");
            Console.WriteLine($"Age            : {emp.Age?.ToString() ?? "-"}");
            Console.WriteLine($"City           : {emp.City ?? "-"}");
            Console.WriteLine($"Date of Joining: {emp.DateOfJoining?.ToString("yyyy-MM-dd") ?? "-"}");
            Console.WriteLine($"Salary         : {emp.Salary?.ToString("F2") ?? "-"}");
        }

        // Collects updated details and modifies the employee record
        static void UpdateEmployee(IEmployeeRepository repo)
        {
            Console.Write("Enter Employee ID to update: ");
            if (!int.TryParse(Console.ReadLine(), out int id))
            {
                Console.WriteLine("Invalid ID.");
                return;
            }

            // Verify the employee exists before updating
            Employee existing = repo.GetEmployeeById(id);
            if (existing == null)
            {
                Console.WriteLine($"No employee found with ID: {id}");
                return;
            }

            Console.WriteLine($"Updating employee: {existing.FirstName} {existing.LastName}");
            Console.WriteLine("(Press Enter to keep current value)\n");

            Console.Write($"Last Name [{existing.LastName}]: ");
            string lastName = Console.ReadLine();
            existing.LastName = string.IsNullOrWhiteSpace(lastName) ? existing.LastName : lastName;

            Console.Write($"First Name [{existing.FirstName ?? "-"}]: ");
            string firstName = Console.ReadLine();
            if (!string.IsNullOrWhiteSpace(firstName))
                existing.FirstName = firstName;

            Console.Write($"Age [{existing.Age?.ToString() ?? "-"}]: ");
            string ageInput = Console.ReadLine();
            if (int.TryParse(ageInput, out int age))
                existing.Age = age;

            Console.Write($"City [{existing.City ?? "-"}]: ");
            string city = Console.ReadLine();
            if (!string.IsNullOrWhiteSpace(city))
                existing.City = city;

            Console.Write($"Date of Joining [{existing.DateOfJoining?.ToString("yyyy-MM-dd") ?? "-"}]: ");
            string dateInput = Console.ReadLine();
            if (DateTime.TryParse(dateInput, out DateTime doj))
                existing.DateOfJoining = doj;

            Console.Write($"Salary [{existing.Salary?.ToString("F2") ?? "-"}]: ");
            string salaryInput = Console.ReadLine();
            if (decimal.TryParse(salaryInput, out decimal salary))
                existing.Salary = salary;

            bool updated = repo.UpdateEmployee(existing);
            Console.WriteLine(updated ? "Employee updated successfully." : "Update failed.");
        }

        // Deletes an employee after confirmation
        static void DeleteEmployee(IEmployeeRepository repo)
        {
            Console.Write("Enter Employee ID to delete: ");
            if (!int.TryParse(Console.ReadLine(), out int id))
            {
                Console.WriteLine("Invalid ID.");
                return;
            }

            // Show employee before deleting for confirmation
            Employee emp = repo.GetEmployeeById(id);
            if (emp == null)
            {
                Console.WriteLine($"No employee found with ID: {id}");
                return;
            }

            Console.WriteLine($"Are you sure you want to delete: {emp.FirstName} {emp.LastName}? (y/n)");
            string confirm = Console.ReadLine();

            if (confirm?.ToLower() == "y")
            {
                bool deleted = repo.DeleteEmployee(id);
                Console.WriteLine(deleted ? "Employee deleted successfully." : "Delete failed.");
            }
            else
            {
                Console.WriteLine("Delete cancelled.");
            }
        }
    }
}
