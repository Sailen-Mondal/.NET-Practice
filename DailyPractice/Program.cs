using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using ConsoleAppForPractice;

namespace DailyPractice
{
    internal class Program
    {
        static async Task Main(string[] args)

        {
            //Example of Dictionary, Conversion of Dictionary to List and List to Dictionary
            //lass_28_09_26 dicDemo = new Class_28_09_26();
            var obj1 = new Sept_30();
            dynamic dynamicVar = 10;

            Console.WriteLine("Fetching data...");

            // 2. The 'await' keyword pauses Main until FetchDataAsync completes, 
            // without freezing the entire application.
            string data = await FetchDataAsync();

            Console.WriteLine($"Result: {data}");

        }
        static async Task<string> FetchDataAsync()
        {
            // Simulates a 2-second long-running network or database call
            //await Task.Delay(4000);

            return "Hello from the database!";

            string connectionString = "Data Source=.;Initial Catalog=BikeStore;User Id=sa;Password=mcc#1234";

            string connectString = ConfigurationManager.ConnectionStrings["DBConn"].ConnectionString;
            using (SqlConnection connection = new SqlConnection(connectString))
            {
                connection.Open();
                // Perform database operations here
                string query = "SELECT TOP (1000) [department_id],[department_name],[head_of_department],[phone_extension] FROM [BikeStores].[dbo].[Departments]\r\n";
                {
                    using (SqlCommand command = new SqlCommand(query, connection))
                    {
                        using (SqlDataReader reader = command.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                Console.WriteLine($"Department ID: {reader["department_id"]}, Name: {reader["department_name"]}, Head: {reader["head_of_department"]}, Phone: {reader["phone_extension"]}");
                            }
                        }

                        Console.WriteLine("Press any key to exit...");
                        Console.ReadKey(true);
                    }
                }
            }
        }
    }
}
