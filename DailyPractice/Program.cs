using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Threading.Tasks;
using ConsoleAppForPractice;
using ThirdADO;

namespace DailyPractice
{
    /// <summary>
    /// Application entry point and orchestrator.
    /// Provides access to:
    /// 1. Interactive Bike Shop Management System (CRUD: Insert, Read, Update, Delete)
    /// 2. Daily Practice Demonstrations (Collections, Types, Async DB)
    /// </summary>
    internal class Program
    {
        /// <summary>
        /// Main asynchronous entry point.
        /// </summary>
        /// <param name="args">Command line arguments passed to the application.</param>
        static async Task Main(string[] args)
        {
            // If "--all-demos" argument is provided or non-interactive, run demos directly
            if (args.Length > 0 && args[0].Equals("--demos", StringComparison.OrdinalIgnoreCase))
            {
                await RunDemonstrationsAsync();
                return;
            }

            bool exit = false;
            while (!exit)
            {
                Console.Clear();
                Console.ForegroundColor = ConsoleColor.Cyan;
                Console.WriteLine("==================================================");
                Console.WriteLine("        .NET DAILY PRACTICE & MANAGEMENT          ");
                Console.WriteLine("==================================================");
                Console.ResetColor();
                Console.WriteLine(" [1] Open Bike Shop Management System (CRUD)");
                Console.WriteLine(" [2] Run Daily Practice Demonstrations");
                Console.WriteLine(" [0] Exit Application");
                Console.WriteLine("==================================================");
                Console.Write("Select an option (0-2): ");

                string choice = Console.ReadLine()?.Trim();
                Console.WriteLine();

                switch (choice)
                {
                    case "1":
                        // Launch full interactive Bike Shop Management System
                        BikeManagementSystem managementSystem = new BikeManagementSystem();
                        managementSystem.Run();
                        break;

                    case "2":
                        // Run all practice modules (Collections, Type conversions, Async DB)
                        await RunDemonstrationsAsync();
                        Console.WriteLine("\nPress Enter to return to main menu...");
                        Console.ReadLine();
                        break;

                    case "0":
                        Console.WriteLine("Thank you for using the application. Goodbye!");
                        exit = true;
                        break;

                    default:
                        Console.ForegroundColor = ConsoleColor.Yellow;
                        Console.WriteLine("Invalid option. Please choose 0, 1, or 2.");
                        Console.ResetColor();
                        Console.WriteLine("Press Enter to continue...");
                        Console.ReadLine();
                        break;
                }
            }
        }

        /// <summary>
        /// Executes all daily practice demonstrations in sequence.
        /// </summary>
        public static async Task RunDemonstrationsAsync()
        {
            Console.Clear();
            Console.WriteLine("==================================================");
            Console.WriteLine("           .NET DAILY PRACTICE DEMOS              ");
            Console.WriteLine("==================================================\n");

            // MODULE 1: Practice from 28-09-2026 (Dictionary & ArrayList)
            Class_28_09_26 dicDemo = new Class_28_09_26();
            Console.WriteLine();

            // MODULE 2: Practice from 30-09-2026 (Type Conversions & Dynamic)
            Sept_30 sept30Demo = new Sept_30();
            Console.WriteLine();

            // MODULE 3: Asynchronous Programming with async/await
            Console.WriteLine("---------- Asynchronous Database Query (async/await) ----------");
            Console.WriteLine("Fetching department data asynchronously...");
            string asyncResult = await FetchDataAsync();
            Console.WriteLine($"Async Operation Result: {asyncResult}\n");

            // MODULE 4: Quick Preview of Bikeshop Repo
            Console.WriteLine("---------- ADO.NET Repository: Quick Preview ----------");
            BikeshopRepo repo = new BikeshopRepo();
            var bikes = repo.GetAllBikeshops();
            Console.WriteLine($"Total Bikes in DB: {bikes.Count}");
            if (bikes.Count > 0)
            {
                Console.WriteLine($"First Bike: [ID {bikes[0].Id}] {bikes[0].Name} ({bikes[0].price:C})");
                Console.WriteLine($"Last Bike:  [ID {bikes[bikes.Count - 1].Id}] {bikes[bikes.Count - 1].Name} ({bikes[bikes.Count - 1].price:C})");
            }
        }

        /// <summary>
        /// Asynchronously fetches department records from the database.
        /// Demonstrates non-blocking I/O using async ADO.NET methods (OpenAsync, ExecuteReaderAsync, ReadAsync).
        /// </summary>
        /// <returns>A status string detailing the result of the asynchronous query.</returns>
        static async Task<string> FetchDataAsync()
        {
            await Task.Delay(500);

            string connectString = ConfigurationManager.ConnectionStrings["DBConn"].ConnectionString;
            int count = 0;

            using (SqlConnection connection = new SqlConnection(connectString))
            {
                await connection.OpenAsync();

                string query = "SELECT TOP (5) [department_id], [department_name], [head_of_department], [phone_extension] FROM [BikeStores].[dbo].[Departments]";

                using (SqlCommand command = new SqlCommand(query, connection))
                {
                    using (SqlDataReader reader = await command.ExecuteReaderAsync())
                    {
                        while (await reader.ReadAsync())
                        {
                            count++;
                            Console.WriteLine($"  [Dept ID: {reader["department_id"]}] {reader["department_name"]} - Head: {reader["head_of_department"]} (Ext: {reader["phone_extension"]})");
                        }
                    }
                }
            }

            return $"Successfully loaded {count} departments asynchronously.";
        }
    }
}
