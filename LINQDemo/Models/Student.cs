using System;
using System.Collections.Generic;

namespace LINQDemo.Models
{
    /// <summary>
    /// Student entity representing academic records for testing LINQ Ordering operators.
    /// </summary>
    public class Student
    {
        // Unique identifier for each student
        public int StudentID { get; set; }

        // Full name of the student
        public string Name { get; set; }

        // Total marks obtained across all subjects
        public int TotalMarks { get; set; }

        /// <summary>
        /// Provides a static in-memory list of students for demonstration purposes.
        /// </summary>
        public static List<Student> GetAllStudents()
        {
            return new List<Student>
            {
                new Student { StudentID = 101, Name = "Tom", TotalMarks = 800 },
                new Student { StudentID = 102, Name = "Mary", TotalMarks = 900 },
                new Student { StudentID = 103, Name = "Valarie", TotalMarks = 800 },
                new Student { StudentID = 104, Name = "John", TotalMarks = 800 }
            };
        }
    }
}
