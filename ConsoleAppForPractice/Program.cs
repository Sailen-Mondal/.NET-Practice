using System;
using System.Collections.Generic;
using System.Linq;

class Student
{
    public string RollNo { get; set; }
    public string Name { get; set; }
    public int Semester { get; set; }
    public double Cgpa { get; set; }

    public Student(string rollNo, string name, int semester, double cgpa)
    {
        RollNo = rollNo;
        Name = name;
        Semester = semester;
        Cgpa = cgpa;
    }

    public void Display()
    {
        Console.WriteLine($"Roll No : {RollNo}");
        Console.WriteLine($"Name    : {Name}");
        Console.WriteLine($"Semester: {Semester}");
        Console.WriteLine($"CGPA    : {Cgpa}");
    }
}

class Program
{
    static List<Student> students = new List<Student>();

    // Add Student
    static void AddStudent()
    {
        Console.Write("Enter Roll No: ");
        string rollNo = Console.ReadLine();

        Console.Write("Enter Name: ");
        string name = Console.ReadLine();

        Console.Write("Enter Semester: ");
        int semester = int.Parse(Console.ReadLine());

        Console.Write("Enter CGPA: ");
        double cgpa = double.Parse(Console.ReadLine());

        students.Add(new Student(rollNo, name, semester, cgpa));

        Console.WriteLine("Student added successfully.");
    }

    // Remove Student
    static void RemoveStudent()
    {
        Console.Write("Enter Roll No to remove: ");
        string rollNo = Console.ReadLine();

        Student student = students.FirstOrDefault(s => s.RollNo == rollNo);

        if (student != null)
        {
            students.Remove(student);
            Console.WriteLine("Student removed successfully.");
        }
        else
        {
            Console.WriteLine("Student not found.");
        }
    }

    // Search Student
    static void SearchStudent()
    {
        Console.Write("Enter Roll No to search: ");
        string rollNo = Console.ReadLine();

        Student student = students.FirstOrDefault(s => s.RollNo == rollNo);

        if (student != null)
        {
            Console.WriteLine("\nStudent Profile:");
            student.Display();
        }
        else
        {
            Console.WriteLine("Student not found.");
        }
    }

    // Placement Eligibility
    static void ShowEligibleStudents()
    {
        var eligibleStudents = students
            .Where(s => s.Cgpa >= 8.0 && s.Semester >= 6)
            .OrderByDescending(s => s.Cgpa)
            .ToList();

        Console.WriteLine("\nPlacement Eligible Students:");

        if (eligibleStudents.Count == 0)
        {
            Console.WriteLine("No eligible students found.");
            return;
        }

        foreach (Student student in eligibleStudents)
        {
            Console.WriteLine(
                $"{student.RollNo} | {student.Name} | " +
                $"Semester: {student.Semester} | CGPA: {student.Cgpa}"
            );
        }
    }

    // Batch Statistics
    static void ShowStatistics()
    {
        int totalStudents = students.Count;

        if (totalStudents == 0)
        {
            Console.WriteLine("No students enrolled.");
            return;
        }

        double averageCgpa = students.Average(s => s.Cgpa);

        Console.WriteLine("\nBatch Statistics:");
        Console.WriteLine($"Total Students : {totalStudents}");
        Console.WriteLine($"Average CGPA   : {averageCgpa:F2}");
    }

    static void Main()
    {
        while (true)
        {
            Console.WriteLine("\n===== Student Management System =====");
            Console.WriteLine("1. Add Student");
            Console.WriteLine("2. Remove Student");
            Console.WriteLine("3. Search Student");
            Console.WriteLine("4. Show Placement Eligible Students");
            Console.WriteLine("5. Show Batch Statistics");
            Console.WriteLine("6. Exit");

            Console.Write("Enter your choice: ");
            int choice = int.Parse(Console.ReadLine());

            switch (choice)
            {
                case 1:
                    AddStudent();
                    break;

                case 2:
                    RemoveStudent();
                    break;

                case 3:
                    SearchStudent();
                    break;

                case 4:
                    ShowEligibleStudents();
                    break;

                case 5:
                    ShowStatistics();
                    break;

                case 6:
                    Console.WriteLine("Program exited.");
                    return;

                default:
                    Console.WriteLine("Invalid choice.");
                    break;
            }
        }
    }
}
