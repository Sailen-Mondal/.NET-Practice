using System;
using System.Collections.Generic;
using System.Text;

namespace ConsoleAppForPractice
{
    internal class Student
    {
        public string RollNo { get; set; }
        public string Name { get; set; }
        public int Semester {  get; set; }
        public double Cgpa { get; set; }

        public Student(string RollNo, string Name, int Semester, double Cgpa) {
            this.RollNo = RollNo;
            this.Cgpa = Cgpa;
            this.Semester = Semester;
            this.Name = Name;

        }

        public void Display()
        {
            Console.WriteLine($"Roll number: {RollNo}");
            Console.WriteLine($"Name: {Name}");
            Console.WriteLine($"Semester: {Semester}");
            Console.WriteLine($"CGPA: {Cgpa}");
        }

    }
}
