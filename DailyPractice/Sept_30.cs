using System;

namespace DailyPractice
{
    /// Practice class for 30-09-2026.
    /// Covers type conversions (string to int/long), character arithmetic (ASCII addition), and dynamic typing.
    internal class Sept_30
    {
        /// Initializes a new instance of <see cref="Sept_30"/> and executes fundamental C# practice exercises.
        public Sept_30()
        {
            Console.WriteLine("---------- Practice Date: 30-09-2026 ----------");

            // 1. Explicit Type Conversion: String to 32-bit Integer
            // Convert.ToInt32 parses the string representation of a number to a 32-bit signed integer.
            string str = "123";
            int num = Convert.ToInt32(str);
            Console.WriteLine($"[Convert.ToInt32] Original String: \"{str}\", Converted Integer: {num}");

            // 2. Explicit Type Conversion: String to 64-bit Integer (Long)
            // Useful for numbers exceeding the 32-bit integer range (-2,147,483,648 to 2,147,483,647).
            string str2 = "349587934857349";
            long num2 = Convert.ToInt64(str2);
            Console.WriteLine($"[Convert.ToInt64] Original String: \"{str2}\", Converted Long: {num2}");

            // 3. Character Arithmetic & ASCII Code Point Addition
            // In C#, char represents a UTF-16 code unit. Applying arithmetic operators (+) promotes
            // char operands to int based on their underlying ASCII/Unicode numeric values:
            // 'a' = 97, 'd' = 100 -> 97 + 100 = 197.
            char char1 = 'a';
            char char2 = 'd';
            int sum = char1 + char2;
            Console.WriteLine($"[Char Arithmetic] Char1: '{char1}' (ASCII { (int)char1 }), Char2: '{char2}' (ASCII { (int)char2 }), Sum: {sum}");

            // 4. Dynamic Typing (Dynamic Language Runtime - DLR)
            // 'dynamic' bypasses static compile-time type checking. Type resolution is deferred to runtime.
            dynamic dynamicVar = 10;
            Console.WriteLine($"[Dynamic Variable] Initial (int): {dynamicVar}, Type: {dynamicVar.GetType().Name}");

            // Dynamic variables can change underlying types at runtime:
            dynamicVar = "Now I am a string!";
            Console.WriteLine($"[Dynamic Variable] Reassigned (string): \"{dynamicVar}\", Type: {dynamicVar.GetType().Name}");
        }
    }
}
