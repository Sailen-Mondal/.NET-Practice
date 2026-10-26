using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web.UI;
using LINQDemo.Models;

namespace LINQDemo.Pages
{
    public partial class RestrictionOperators : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
        }

        /// <summary>
        /// Demonstrates Restriction operator using Method Syntax with lambda expressions.
        /// </summary>
        protected void btnFilterMethod_Click(object sender, EventArgs e)
        {
            List<int> numbers = new List<int> { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 };

            // Step 1: Define restriction condition using Where extension method
            // Predicate is a lambda expression evaluating if num % 2 equals 0
            IEnumerable<int> evenNumbers = numbers.Where(num => num % 2 == 0);

            // Step 2: Format output for display
            StringBuilder sb = new StringBuilder();
            sb.AppendLine("Source: [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ]");
            sb.AppendLine("Condition: num => num % 2 == 0 (Method Syntax)\n");
            sb.AppendLine("Filtered Even Numbers:");

            foreach (int evenNumber in evenNumbers)
            {
                sb.AppendLine(evenNumber.ToString());
            }

            lblNumberResultTitle.Text = "Result via Method Syntax (numbers.Where(num => num % 2 == 0)):";
            litNumberOutput.Text = sb.ToString();
            pnlNumbersResult.Visible = true;
        }

        /// <summary>
        /// Demonstrates Restriction operator using SQL-like Query Syntax.
        /// </summary>
        protected void btnFilterQuery_Click(object sender, EventArgs e)
        {
            List<int> numbers = new List<int> { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 };

            // SQL-like query syntax uses 'from', 'where', and 'select' keywords
            IEnumerable<int> evenNumbers = from num in numbers
                                           where num % 2 == 0
                                           select num;

            StringBuilder sb = new StringBuilder();
            sb.AppendLine("Source: [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ]");
            sb.AppendLine("Condition: from num in numbers where num % 2 == 0 select num;\n");
            sb.AppendLine("Filtered Even Numbers:");

            foreach (int evenNumber in evenNumbers)
            {
                sb.AppendLine(evenNumber.ToString());
            }

            lblNumberResultTitle.Text = "Result via Query Syntax (from num in numbers where num % 2 == 0 select num):";
            litNumberOutput.Text = sb.ToString();
            pnlNumbersResult.Visible = true;
        }

        /// <summary>
        /// Demonstrates nested collection filtering on Departments and Employees.
        /// </summary>
        protected void btnFilterDepartments_Click(object sender, EventArgs e)
        {
            // Retrieve structured department records with their nested employees
            List<Department> departmentList = Department.GetDepartmentsWithEmployees();

            // Filter for IT and HR departments only
            IEnumerable<Department> departments = departmentList
                .Where(dept => dept.Name == "IT" || dept.Name == "HR");

            StringBuilder sb = new StringBuilder();

            foreach (Department department in departments)
            {
                sb.AppendLine("Department Name = " + department.Name);

                // Nested restriction: filter employees belonging to current department for Gender == "Male"
                IEnumerable<Employee> maleEmployees = department.Employees
                    .Where(emp => emp.Gender == "Male");

                foreach (Employee employee in maleEmployees)
                {
                    sb.AppendLine("    Employee Name = " + employee.FirstName + " " + employee.LastName);
                }

                sb.AppendLine();
            }

            litDeptOutput.Text = sb.ToString();
            pnlDeptResult.Visible = true;
        }
    }
}
