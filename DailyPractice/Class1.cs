using System;
using System.Collections;
using System.Collections.Generic;

namespace ConsoleAppForPractice
{
    /// Practice class for 28-09-2026.
    /// Demonstrates generic Dictionary operations, iteration, and conversion to non-generic ArrayList.
    internal partial class Class_28_09_26
    {
        /// Initializes a new instance of <see cref="Class_28_09_26"/> and runs collection demonstrations.
        public Class_28_09_26()
        {
            Console.WriteLine("---------- Practice Date: 28-09-2026 ----------");

            // 1. Initializing a generic Dictionary<TKey, TValue>
            // Dictionaries store key-value pairs and offer O(1) average lookup time via hashing.
            Dictionary<int, string> map = new Dictionary<int, string>();

            // Adding entries to the dictionary
            map.Add(1, "Sailen");
            map.Add(2, "Arko");
            map.Add(3, "raja");

            Console.WriteLine("--- Iterating Dictionary Keys and Values ---");
            foreach (var key in map.Keys)
            {
                Console.WriteLine($"Key : {key}  Value : {map[key]}");
            }

            // 2. Converting generic Dictionary to non-generic ArrayList
            // ArrayList is an untyped collection from System.Collections.
            // When a Dictionary is passed to its constructor, each entry is boxed as a KeyValuePair<int, string>.
            ArrayList list = new ArrayList(map);

            Console.WriteLine("\n--- Iterating Converted ArrayList ---");
            foreach (var item in list)
            {
                Console.WriteLine(item);
            }
        }
    }
}
