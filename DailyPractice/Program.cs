using System;
using System.Collections.Generic;
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
            await Task.Delay(4000);

            return "Hello from the database!";
        }
    }
}
