using Microsoft.Extensions.Configuration;

namespace ConsoleAppCURD
{
    internal class Program
    {
        static void Main(string[] args)
        {
            // Load database configuration
            IConfiguration configuration = new ConfigurationBuilder()
                .SetBasePath(AppContext.BaseDirectory)
                .AddJsonFile("appsettings.json", optional: false)
                .Build();

            string connectionString =
                configuration.GetConnectionString("DBConn")
                ?? configuration.GetConnectionString("DefaultConnection")
                ?? throw new InvalidOperationException(
                    "Connection string not found.");

            // Create repository
            ProductRepo repo = new ProductRepo(connectionString);

            while (true)
            {
                Console.WriteLine("\n=== Employee CRUD Menu ===");
                Console.WriteLine("1. Insert Employee");
                Console.WriteLine("2. Display All Employees");
                Console.WriteLine("3. Search Employee by ID");
                Console.WriteLine("4. Update Employee");
                Console.WriteLine("5. Delete Employee");
                Console.WriteLine("0. Exit");
                Console.Write("Enter choice: ");

                string? choice = Console.ReadLine();

                switch (choice)
                {
                    case "1":
                        Employee newEmployee = ReadEmployee();
                        int newId = repo.Insert(newEmployee);
                        Console.WriteLine($"Employee inserted. ID: {newId}");
                        break;

                    case "2":
                        List<Employee> employees = repo.GetAll();

                        foreach (Employee employee in employees)
                        {
                            DisplayEmployee(employee);
                        }

                        if (employees.Count == 0)
                            Console.WriteLine("No employees found.");

                        break;

                    case "3":
                        int searchId = ReadInt("Enter employee ID: ");
                        Employee? foundEmployee = repo.GetById(searchId);

                        if (foundEmployee is not null)
                        {
                            DisplayEmployee(foundEmployee);
                        }
                        else
                        {
                            Console.WriteLine("Employee not found.");
                        }

                        break;

                    case "4":
                        int updateId = ReadInt("Enter employee ID to update: ");
                        Employee? existingEmployee = repo.GetById(updateId);

                        if (existingEmployee is null)
                        {
                            Console.WriteLine("Employee not found.");
                            break;
                        }

                        Employee updatedEmployee = ReadEmployee();
                        updatedEmployee.ID = updateId;

                        int updatedRows = repo.Update(updatedEmployee);
                        Console.WriteLine(updatedRows > 0
                            ? "Employee updated successfully."
                            : "Update failed.");
                        break;

                    case "5":
                        int deleteId = ReadInt("Enter employee ID to delete: ");
                        int deletedRows = repo.Delete(deleteId);
                        Console.WriteLine(deletedRows > 0
                            ? "Employee deleted successfully."
                            : "Employee not found.");
                        break;

                    case "0":
                        Console.WriteLine("Exiting...");
                        return;

                    default:
                        Console.WriteLine("Invalid choice. Please try again.");
                        break;
                }
            }
        }

        private static Employee ReadEmployee()
        {
            return new Employee
            {
                LastName = ReadString("Enter Last Name: "),
                FirstName = ReadString("Enter First Name: "),
                Age = ReadInt("Enter Age: "),
                City = ReadString("Enter City: "),
                DateOfJoining = ReadDate("Enter Date of Joining (yyyy-MM-dd): "),
                Salary = ReadDecimal("Enter Salary: ")
            };
        }

        private static string ReadString(string prompt)
        {
            while (true)
            {
                Console.Write(prompt);
                string? input = Console.ReadLine();

                if (!string.IsNullOrWhiteSpace(input))
                {
                    return input.Trim();
                }

                Console.WriteLine("Input cannot be empty. Please try again.");
            }
        }

        private static int ReadInt(string prompt)
        {
            while (true)
            {
                Console.Write(prompt);
                if (int.TryParse(Console.ReadLine(), out int value))
                {
                    return value;
                }

                Console.WriteLine("Invalid number. Please enter a valid integer.");
            }
        }

        private static DateTime ReadDate(string prompt)
        {
            while (true)
            {
                Console.Write(prompt);
                if (DateTime.TryParse(Console.ReadLine(), out DateTime value))
                {
                    return value.Date;
                }

                Console.WriteLine("Invalid date. Please use yyyy-MM-dd format.");
            }
        }

        private static decimal ReadDecimal(string prompt)
        {
            while (true)
            {
                Console.Write(prompt);
                if (decimal.TryParse(Console.ReadLine(), out decimal value))
                {
                    return value;
                }

                Console.WriteLine("Invalid amount. Please enter a valid decimal.");
            }
        }

        private static void DisplayEmployee(Employee employee)
        {
            Console.WriteLine(
                $"ID: {employee.ID} | Name: {employee.FirstName} {employee.LastName} | " +
                $"Age: {employee.Age} | City: {employee.City} | " +
                $"Joined: {employee.DateOfJoining:yyyy-MM-dd} | Salary: {employee.Salary:F2}");
        }
    }
}
