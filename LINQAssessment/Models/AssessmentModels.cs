using System.Collections.Generic;

namespace LINQAssessment.Models
{
    // Task 1: Student entity
    public class Student
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public string Department { get; set; }
        public bool IsEnrolled { get; set; }
    }

    // Task 1: Department grouping result
    public class DepartmentGroupResult
    {
        public string Department { get; set; }
        public int StudentCount { get; set; }
    }

    // Task 2: Graph vertex and its connected neighbor nodes
    public class GraphNode
    {
        public string Vertex { get; set; }
        public List<string> Connections { get; set; } = new List<string>();
    }

    // Task 2: Graph node degree result
    public class GraphNodeResult
    {
        public string Vertex { get; set; }
        public int Degree { get; set; }
        public string ConnectedTo { get; set; }
    }

    // Task 3: Course with required prerequisite course codes
    public class Course
    {
        public string CourseCode { get; set; }
        public string Title { get; set; }
        public List<string> Prerequisites { get; set; } = new List<string>();
    }

    // Realistic sample dataset (Indian context)
    public static class MockData
    {
        public static List<Student> GetStudents()
        {
            return new List<Student>
            {
                new Student { Id = 101, Name = "Rahul Sharma", Department = "Computer Science", IsEnrolled = true },
                new Student { Id = 102, Name = "Priya Patel", Department = "Information Technology", IsEnrolled = true },
                new Student { Id = 103, Name = "Amit Verma", Department = "Computer Science", IsEnrolled = true },
                new Student { Id = 104, Name = "Sneha Banerjee", Department = "Electronics", IsEnrolled = true },
                new Student { Id = 105, Name = "Vikram Singh", Department = "Information Technology", IsEnrolled = false },
                new Student { Id = 106, Name = "Ananya Sen", Department = "Computer Science", IsEnrolled = true },
                new Student { Id = 107, Name = "Rohan Gupta", Department = "Mechanical", IsEnrolled = true },
                new Student { Id = 108, Name = "Neha Mukherjee", Department = "Electronics", IsEnrolled = true },
                new Student { Id = 109, Name = "Arjun Das", Department = "Information Technology", IsEnrolled = true }
            };
        }

        public static List<GraphNode> GetGraphNodes()
        {
            return new List<GraphNode>
            {
                new GraphNode { Vertex = "Node-A", Connections = new List<string> { "Node-B", "Node-C", "Node-D", "Node-E" } },
                new GraphNode { Vertex = "Node-B", Connections = new List<string> { "Node-A", "Node-C" } },
                new GraphNode { Vertex = "Node-C", Connections = new List<string> { "Node-A", "Node-B", "Node-D", "Node-E", "Node-F" } },
                new GraphNode { Vertex = "Node-D", Connections = new List<string> { "Node-A", "Node-C", "Node-E" } },
                new GraphNode { Vertex = "Node-E", Connections = new List<string> { "Node-A", "Node-C", "Node-D", "Node-F" } },
                new GraphNode { Vertex = "Node-F", Connections = new List<string> { "Node-C", "Node-E" } }
            };
        }

        public static List<Course> GetEnrolledCourses()
        {
            return new List<Course>
            {
                new Course
                {
                    CourseCode = "CS301",
                    Title = "Data Structures and Algorithms",
                    Prerequisites = new List<string> { "CS101", "CS201" }
                },
                new Course
                {
                    CourseCode = "CS302",
                    Title = "Database Management Systems",
                    Prerequisites = new List<string> { "CS101", "MA101" }
                },
                new Course
                {
                    CourseCode = "CS303",
                    Title = "Operating Systems",
                    Prerequisites = new List<string> { "CS201", "CS202" }
                },
                new Course
                {
                    CourseCode = "CS304",
                    Title = "Computer Networks",
                    Prerequisites = new List<string> { "CS201", "MA101" }
                }
            };
        }
    }
}
