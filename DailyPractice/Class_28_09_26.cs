using System;
using System.Collections.Generic;

namespace ConsoleAppForPractice
{
    /// <summary>
    /// Partial definition of <see cref="Class_28_09_26"/>.
    /// Demonstrates passing dynamic maps and runtime late binding.
    /// </summary>
    internal partial class Class_28_09_26
    {
        private Dictionary<int, string> _internalMap = new Dictionary<int, string>();

        /// <summary>
        /// Demonstrates dynamic typing with dictionaries.
        /// Using 'dynamic' defers type checking and member resolution to runtime.
        /// </summary>
        /// <param name="map">A dynamic map/dictionary instance passed at runtime.</param>
        public void DicDemo(dynamic map)
        {
            this._internalMap = map as Dictionary<int, string> ?? new Dictionary<int, string>();

            // Adding elements dynamically
            map.Add(1, "Sailen");
            map.Add(2, "Arko");
            map.Add(3, "raja");

            Console.WriteLine("--- Iterating Dynamic Map Keys ---");
            foreach (var key in map.Keys)
            {
                Console.WriteLine($"Key: {key}, Value: {map[key]}");
            }
        }
    }
}
