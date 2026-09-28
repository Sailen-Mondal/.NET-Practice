using System;
using System.Collections.Generic;
using System.Net.WebSockets;
using System.Text;

namespace ConsoleAppForPractice
{
    internal class Class_28_09_26
    {

        Dictionary<int, string> map = new Dictionary<int, string>();


        public void dicDemo(dynamic map)
        {
            this.map = map;

            map.add(1, "Sailen");
            map.add(2, "Arko");
            map.add(3, "raja");

            foreach (var key in map.Keys)
            {
                Console.WriteLine(key);
            }
        }


    }

}
