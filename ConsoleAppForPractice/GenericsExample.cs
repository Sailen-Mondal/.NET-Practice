using System;
using System.Collections.Generic;
using System.Text;

namespace ConsoleAppForPractice
{
    class Box<T>
    {
        public T Value;

        public Box(T value)
        {
            Value = value;
        }

        public void Display()
        {
            Console.WriteLine(Value);
        }
    }
}
