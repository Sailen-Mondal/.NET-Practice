using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DailyPractice
{
    internal class Sept_30
    {
        public Sept_30() {
            Console.WriteLine("----------Date : 30-09-2026----------");

            //Type Conversion
            string str = "123";
            int num = Convert.ToInt32(str);
            Console.WriteLine($"String: {str}, Integer: {num}");

            string str2 = "349587934857349";
            long num2 = Convert.ToInt64(str2);
            Console.WriteLine($"String: {str2}, Long: {num2}");

            //Adding two char
            char char1 = 'a';
            char char2 = 'd';
            int sum = char1 + char2; // This will add the ASCII values of the characters
            Console.WriteLine($"Char1: {char1}, Char2: {char2}, Sum: {sum}");

            dynamic dynamicVar = 10;
            
        }
    }
}
