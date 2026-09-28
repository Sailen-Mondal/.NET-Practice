using System;
using System.Collections;
using System.Collections.Generic;
using System.Net.WebSockets;
using System.Text;

namespace ConsoleAppForPractice
{
    internal class Class_28_09_26
    {

        public Class_28_09_26()
        {
            Dictionary<int, string> map = new Dictionary<int, string>();

            map.Add(1, "Sailen");
            map.Add(2, "Arko");
            map.Add(3, "raja");

            foreach (var key in map.Keys)
            {
                Console.WriteLine($"Key : {key}  Value : {map[key]}");

            }

            // Converting dictionary to Arraylist
            ArrayList list = new ArrayList(map);

            //Printing the ArrayList
            foreach (var item in list)
            {
                Console.WriteLine(item);
            }
        }


    }

}
