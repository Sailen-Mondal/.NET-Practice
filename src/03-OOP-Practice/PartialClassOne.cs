using System;
using System.Collections.Generic;
using System.Text;

namespace ConsoleApp2
{
    public partial class PartialClass
    {
        public int num;
        public PartialClass(int num)
        {
            this.num = num;
            Console.Out.WriteLine("Called form Partial class one: ");
        }
    }
}
