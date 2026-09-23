using System;
using System.Collections.Generic;
using System.Text;

namespace ConsoleAppForPractice
{
    sealed class Animal
    {
        public void Eat()
        {
            Console.WriteLine("Animal is eating");
        }

        //Can't do this-
        //class Dog : Animal
        //{
        //}
    }
}
