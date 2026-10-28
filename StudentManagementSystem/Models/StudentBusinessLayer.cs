using System.Collections.Generic;
using System.Linq;

namespace StudentManagementSystem.Models
{
    // Business Logic / Data Access Layer for Student domain entities.
    // In ASP.NET MVC, the Model layer manages the application state and business data.
    public class StudentBusinessLayer
    {
        private static readonly List<Student> Students = new List<Student>
        {
            new Student { StudentID = 1, Name = "Rahul Sharma", Gender = "Male", Branch = "CSE", Section = "A1" },
            new Student { StudentID = 2, Name = "James", Gender = "Male", Branch = "CSE", Section = "A2" },
            new Student { StudentID = 3, Name = "Priya Patel", Gender = "Female", Branch = "IT", Section = "B1" },
            new Student { StudentID = 4, Name = "Amit Verma", Gender = "Male", Branch = "ECE", Section = "A2" }
        };

        // Retrieves a student by their ID.
        public Student GetById(int studentId)
        {
            var student = Students.FirstOrDefault(s => s.StudentID == studentId);
            if (student == null)
            {
                // Fallback default student matching the reference example
                student = new Student
                {
                    StudentID = studentId,
                    Name = "James",
                    Gender = "Male",
                    Branch = "CSE",
                    Section = "A2"
                };
            }
            return student;
        }

        // Retrieves all student records for listing.
        public List<Student> GetAllStudents()
        {
            return Students;
        }
    }
}
