using System;
using System.Collections.Generic;
using System.Linq;
using LINQDemo.Models;

namespace LINQDemo.Demos
{
    /// <summary>
    /// Implements the exact console demo code snippets from the learning modules.
    /// Can be executed from unit tests, console entry points, or Web Form triggers.
    /// </summary>
    public static class ConsoleDemos
    {
        #region Topic 1: Restriction Operators

        /// <summary>
        /// Demonstrates Restriction operators (Where clause) with numbers and collections.
        /// </summary>
        public static void RunRestrictionDemo()
        {
            Console.WriteLine("=== Topic 1: Restriction Operators in LINQ ===");

            List<int> numbers = new List<int> { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 };

            // Example 1a: Method syntax using a Func predicate
            Func<int, bool> predicate = i => i % 2 == 0;
            IEnumerable<int> evenNumbersWithFunc = numbers.Where(predicate);

            // Example 1b: Method syntax with inline lambda expression
            IEnumerable<int> evenNumbers = numbers.Where(num => num % 2 == 0);
            Console.WriteLine("Even numbers (Method Syntax):");
            foreach (int evenNumber in evenNumbers)
            {
                Console.WriteLine(evenNumber);
            }

            // Example 1c: SQL-like query syntax
            IEnumerable<int> evenNumbersQuery = from num in numbers
                                                where num % 2 == 0
                                                select num;
            Console.WriteLine("\nEven numbers (SQL-like Query Syntax):");
            foreach (int evenNumber in evenNumbersQuery)
            {
                Console.WriteLine(evenNumber);
            }

            // Example 2: Filtering nested entity collections (IT and HR departments, male employees)
            Console.WriteLine("\nFiltering IT and HR departments with male employees:");
            List<Department> departmentsData = Department.GetDepartmentsWithEmployees();

            IEnumerable<Department> departments = departmentsData
                .Where(dept => dept.Name == "IT" || dept.Name == "HR");

            foreach (Department department in departments)
            {
                Console.WriteLine("Department Name = " + department.Name);
                foreach (Employee employee in department.Employees.Where(emp => emp.Gender == "Male"))
                {
                    Console.WriteLine("\tEmployee Name = " + employee.FirstName + " " + employee.LastName);
                }
                Console.WriteLine();
            }
        }

        #endregion

        #region Topic 2: Ordering Operators

        /// <summary>
        /// Demonstrates Ordering operators: OrderBy, OrderByDescending, ThenBy, ThenByDescending, and Reverse.
        /// </summary>
        public static void RunOrderingDemo()
        {
            Console.WriteLine("=== Topic 2: Ordering Operators in LINQ ===");

            // Example 1: Sort Students by Name in ascending order (Method Syntax)
            Console.WriteLine("Example 1: Sort by Name Ascending (Method Syntax):");
            IEnumerable<Student> result1 = Student.GetAllStudents().OrderBy(s => s.Name);
            foreach (Student student in result1)
            {
                Console.WriteLine(student.Name);
            }

            // Example 2: Rewrite Example 1 using SQL-like syntax
            Console.WriteLine("\nExample 2: Sort by Name Ascending (SQL-like Query Syntax):");
            IEnumerable<Student> result2 = from student in Student.GetAllStudents()
                                           orderby student.Name
                                           select student;
            foreach (Student student in result2)
            {
                Console.WriteLine(student.Name);
            }

            // Example 3: Sort Students by Name in descending order (Method Syntax)
            Console.WriteLine("\nExample 3: Sort by Name Descending (Method Syntax):");
            IEnumerable<Student> result3 = Student.GetAllStudents().OrderByDescending(s => s.Name);
            foreach (Student student in result3)
            {
                Console.WriteLine(student.Name);
            }

            // Example 4: Rewrite Example 3 using SQL-like syntax
            Console.WriteLine("\nExample 4: Sort by Name Descending (SQL-like Query Syntax):");
            IEnumerable<Student> result4 = from student in Student.GetAllStudents()
                                           orderby student.Name descending
                                           select student;
            foreach (Student student in result4)
            {
                Console.WriteLine(student.Name);
            }

            // Example 5: Secondary Sorting with ThenBy (TotalMarks ascending, then Name ascending)
            Console.WriteLine("\nExample 5: TotalMarks ascending, ThenBy Name ascending:");
            var result5 = Student.GetAllStudents()
                .OrderBy(s => s.TotalMarks)
                .ThenBy(s => s.Name);
            foreach (var student in result5)
            {
                Console.WriteLine("{0}\t{1}", student.TotalMarks, student.Name);
            }

            // Example 6: Reverse Operator
            Console.WriteLine("\nExample 6: Reverse list items:");
            var studentsList = Student.GetAllStudents();
            studentsList.Reverse();
            foreach (var student in studentsList)
            {
                Console.WriteLine("{0} - {1}", student.StudentID, student.Name);
            }
        }

        #endregion

        #region Topic 3: GroupBy in LINQ

        /// <summary>
        /// Demonstrates GroupBy operators to organize flat records into IGrouping collections.
        /// </summary>
        public static void RunGroupByDemo()
        {
            Console.WriteLine("=== Topic 3: GroupBy in LINQ ===");

            // Example 1: Get Employee Count By Department
            Console.WriteLine("Example 1: Employee Count By Department:");
            var employeeGroup1 = from employee in Employee.GetAllEmployeesForGroupBy()
                                 group employee by employee.Department;

            foreach (var group in employeeGroup1)
            {
                Console.WriteLine("{0} - {1}", group.Key, group.Count());
            }

            // Example 2: Get Employee Count By Department and also each employee and department name
            Console.WriteLine("\nExample 2: Employee Count and details:");
            var employeeGroup2 = from employee in Employee.GetAllEmployeesForGroupBy()
                                 group employee by employee.Department;

            foreach (var group in employeeGroup2)
            {
                Console.WriteLine("{0} - {1}", group.Key, group.Count());
                Console.WriteLine("----------");
                foreach (var employee in group)
                {
                    Console.WriteLine(employee.Name + "\t" + employee.Department);
                }
                Console.WriteLine();
            }

            // Example 3: Sorted first by Department ascending, then by Employee Name ascending
            Console.WriteLine("\nExample 3: Sorted by Department ascending, then Employee Name ascending:");
            var employeeGroup3 = from employee in Employee.GetAllEmployeesForGroupBy()
                                 group employee by employee.Department into eGroup
                                 orderby eGroup.Key
                                 select new
                                 {
                                     Key = eGroup.Key,
                                     Employees = eGroup.OrderBy(x => x.Name)
                                 };

            foreach (var group in employeeGroup3)
            {
                Console.WriteLine("{0} - {1}", group.Key, group.Employees.Count());
                Console.WriteLine("----------");
                foreach (var employee in group.Employees)
                {
                    Console.WriteLine(employee.Name + "\t" + employee.Department);
                }
                Console.WriteLine();
            }
        }

        #endregion

        #region Topic 4: Inner Join in LINQ

        /// <summary>
        /// Demonstrates Inner Join between Employee and Department.
        /// Unmatched records (Andy without department, Payroll without employees) are excluded.
        /// </summary>
        public static void RunInnerJoinDemo()
        {
            Console.WriteLine("=== Topic 4: Inner Join in LINQ ===");

            // Example 1: Method syntax with Join extension method
            Console.WriteLine("Example 1: Join using Method Syntax:");
            var result1 = Employee.GetAllEmployees().Join(
                Department.GetAllDepartments(),
                e => e.DepartmentID,
                d => d.ID,
                (employee, department) => new
                {
                    EmployeeName = employee.Name,
                    DepartmentName = department.Name
                });

            foreach (var employee in result1)
            {
                Console.WriteLine(employee.EmployeeName + "\t" + employee.DepartmentName);
            }

            // Example 2: SQL-like query syntax
            Console.WriteLine("\nExample 2: Join using SQL-like Query Syntax:");
            var result2 = from e in Employee.GetAllEmployees()
                          join d in Department.GetAllDepartments()
                          on e.DepartmentID equals d.ID
                          select new
                          {
                              EmployeeName = e.Name,
                              DepartmentName = d.Name
                          };

            foreach (var employee in result2)
            {
                Console.WriteLine(employee.EmployeeName + "\t" + employee.DepartmentName);
            }

            Console.WriteLine("\nNotice: Andy (ID: 10, no DepartmentID) and Payroll (ID: 3, no Employees) are excluded from the Inner Join result.");
        }

        #endregion

        /// <summary>
        /// Runs all in-memory LINQ console demos sequentially.
        /// </summary>
        public static void RunAll()
        {
            RunRestrictionDemo();
            Console.WriteLine("\n--------------------------------------------------\n");
            RunOrderingDemo();
            Console.WriteLine("\n--------------------------------------------------\n");
            RunGroupByDemo();
            Console.WriteLine("\n--------------------------------------------------\n");
            RunInnerJoinDemo();
        }
    }
}
