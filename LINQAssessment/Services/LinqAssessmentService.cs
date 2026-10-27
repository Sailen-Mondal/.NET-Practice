using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using LINQAssessment.Models;

namespace LINQAssessment.Services
{
    public static class LinqAssessmentService
    {
        /// <summary>
        /// Task 1: Group enrolled students by their department and count how many students belong to each department.
        /// </summary>
        public static List<DepartmentGroupResult> GetEnrolledStudentCountByDepartment(List<Student> students)
        {
            // Method Syntax:
            // 1. Where filters only students who are actively enrolled.
            // 2. GroupBy groups the matching students by Department.
            // 3. Select projects each group key and count of students in that group.
            var result = students
                .Where(student => student.IsEnrolled)
                .GroupBy(student => student.Department)
                .Select(group => new DepartmentGroupResult
                {
                    Department = group.Key,
                    StudentCount = group.Count()
                })
                .OrderByDescending(r => r.StudentCount)
                .ThenBy(r => r.Department)
                .ToList();

            /* Equivalent SQL-like Query Syntax:
            var resultQuery = from student in students
                              where student.IsEnrolled
                              group student by student.Department into deptGroup
                              orderby deptGroup.Count() descending, deptGroup.Key
                              select new DepartmentGroupResult
                              {
                                  Department = deptGroup.Key,
                                  StudentCount = deptGroup.Count()
                              };
            */  

            return result;
        }

        /// <summary>
        /// Task 2: Find all graph nodes (vertices) that have a degree (number of connections) greater than 3.
        /// </summary>
        public static List<GraphNodeResult> GetHighDegreeNodes(List<GraphNode> nodes, int threshold = 3)
        {
            // Method Syntax:
            // Filters graph nodes where the count of connections exceeds the specified threshold (3).
            var result = nodes
                .Where(node => node.Connections.Count > threshold)
                .Select(node => new GraphNodeResult
                {
                    Vertex = node.Vertex,
                    Degree = node.Connections.Count,
                    ConnectedTo = string.Join(", ", node.Connections)
                })
                .OrderByDescending(node => node.Degree)
                .ThenBy(node => node.Vertex)
                .ToList();

            /* Equivalent SQL-like Query Syntax:
            var resultQuery = from node in nodes
                              where node.Connections.Count > threshold
                              orderby node.Connections.Count descending, node.Vertex
                              select new GraphNodeResult
                              {
                                  Vertex = node.Vertex,
                                  Degree = node.Connections.Count,
                                  ConnectedTo = string.Join(", ", node.Connections)
                              };
            */

            return result;
        }

        /// <summary>
        /// Task 3: Given a student's enrolled courses for the year, extract a flat, deduplicated list 
        /// of every unique prerequisite course code they need to clear.
        /// </summary>
        public static List<string> GetUniquePrerequisites(List<Course> enrolledCourses)
        {
            // Method Syntax:
            // 1. SelectMany flattens the nested List<string> Prerequisites from each Course into a single sequence.
            // 2. Distinct eliminates duplicate course codes.
            // 3. OrderBy sorts the course codes alphabetically for neat display.
            var result = enrolledCourses
                .SelectMany(course => course.Prerequisites)
                .Distinct()
                .OrderBy(code => code)
                .ToList();

            /* Equivalent SQL-like Query Syntax:
            var resultQuery = (from course in enrolledCourses
                               from prereq in course.Prerequisites
                               select prereq).Distinct().OrderBy(c => c).ToList();
            */

            return result;
        }

        /// <summary>
        /// Generates a clean, Apple-style terminal formatted summary of all three tasks.
        /// </summary>
        public static string GenerateConsoleOutput(
            List<Student> students, 
            List<GraphNode> graphNodes, 
            List<Course> enrolledCourses)
        {
            var sb = new StringBuilder();

            sb.AppendLine("================================================================");
            sb.AppendLine("                   LINQ ASSESSMENT EXECUTION");
            sb.AppendLine("================================================================");
            sb.AppendLine();

            // Task 1 Output
            sb.AppendLine("TASK 1: Enrolled Students Grouped by Department");
            sb.AppendLine("----------------------------------------------------------------");
            var task1Results = GetEnrolledStudentCountByDepartment(students);
            sb.AppendLine(string.Format("{0,-28} | {1,13}", "Department", "Student Count"));
            sb.AppendLine(new string('-', 45));
            foreach (var item in task1Results)
            {
                sb.AppendLine(string.Format("{0,-28} | {1,13}", item.Department, item.StudentCount));
            }
            sb.AppendLine();

            // Task 2 Output
            sb.AppendLine("TASK 2: Graph Nodes with Degree > 3");
            sb.AppendLine("----------------------------------------------------------------");
            var task2Results = GetHighDegreeNodes(graphNodes, 3);
            sb.AppendLine(string.Format("{0,-10} | {1,8} | {2}", "Vertex", "Degree", "Connections"));
            sb.AppendLine(new string('-', 55));
            foreach (var node in task2Results)
            {
                sb.AppendLine(string.Format("{0,-10} | {1,8} | {2}", node.Vertex, node.Degree, node.ConnectedTo));
            }
            sb.AppendLine();

            // Task 3 Output
            sb.AppendLine("TASK 3: Unique Flat Prerequisite Course Codes to Clear");
            sb.AppendLine("----------------------------------------------------------------");
            var task3Results = GetUniquePrerequisites(enrolledCourses);
            sb.AppendLine("Courses Enrolled: " + string.Join(", ", enrolledCourses.Select(c => c.CourseCode)));
            sb.AppendLine("Unique Prerequisites: " + string.Join(", ", task3Results));
            sb.AppendLine();
            sb.AppendLine("================================================================");

            return sb.ToString();
        }
    }
}
