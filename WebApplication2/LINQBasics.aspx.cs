using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web.UI;
using CRUDUsingLINQ.Models;

namespace CRUDUsingLINQ
{
    public partial class LINQBasics : Page
    {
        private List<int> integerList = new List<int> { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 };

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindStudentsDefault();
            }
        }

        private void BindStudentsDefault()
        {
            gvStudents.DataSource = Student.GetAllStudents();
            gvStudents.DataBind();
        }

        protected void btnRunQuerySyntax_Click(object sender, EventArgs e)
        {
            lblSyntaxCode.Text =
@"// LINQ Query Syntax (SQL-Like)
var query = from obj in integerList
            where obj > 5
            select obj;

foreach (var item in query) {
    Console.Write(item + "" "");
}";

            var query = from obj in integerList
                        where obj > 5
                        select obj;

            lblSyntaxOutput.Text = string.Join(" ", query);
        }

        protected void btnRunMethodSyntax_Click(object sender, EventArgs e)
        {
            lblSyntaxCode.Text =
@"// LINQ Method Syntax (Chaining with Lambda)
var query = integerList.Where(obj => obj > 5).ToList();

foreach (var item in query) {
    Console.Write(item + "" "");
}";

            var query = integerList.Where(obj => obj > 5).ToList();
            lblSyntaxOutput.Text = string.Join(" ", query);
        }

        protected void btnRunMixedSyntax_Click(object sender, EventArgs e)
        {
            lblSyntaxCode.Text =
@"// LINQ Mixed Syntax (Query Syntax combined with Aggregate Method)
var sum = (from obj in integerList
           where obj > 5
           select obj).Sum();

Console.Write(""Sum Is : "" + sum);";

            var sum = (from obj in integerList
                       where obj > 5
                       select obj).Sum();

            lblSyntaxOutput.Text = "Sum Is : " + sum;
        }

        protected void btnFilterEven_Click(object sender, EventArgs e)
        {
            // Lambda syntax
            IEnumerable<int> evenNumbers = integerList.Where(num => num % 2 == 0);
            lblRestrictionOutput.Text = "// numbers.Where(num => num % 2 == 0)\nResult: " + string.Join(", ", evenNumbers);
        }

        protected void btnFilterPredicate_Click(object sender, EventArgs e)
        {
            // Explicit Func<int, bool> predicate
            Func<int, bool> predicate = i => i % 2 == 0;
            IEnumerable<int> evenNumbers = integerList.Where(predicate);
            lblRestrictionOutput.Text = "// Func<int, bool> predicate = i => i % 2 == 0;\n// numbers.Where(predicate)\nResult: " + string.Join(", ", evenNumbers);
        }

        protected void btnFilterDeptEmp_Click(object sender, EventArgs e)
        {
            // Example from slide: IT & HR departments and male employees
            var employees = Employee.GetAllEmployees();
            var departments = Department.GetAllDepartments();

            var query = departments
                .Where(dept => dept.Name == "IT" || dept.Name == "HR")
                .Select(dept => new
                {
                    DepartmentName = dept.Name,
                    MaleEmployees = employees.Where(emp => emp.Department == dept.Name && emp.Gender == "Male")
                });

            StringBuilder sb = new StringBuilder();
            foreach (var dept in query)
            {
                sb.AppendLine("Department Name = " + dept.DepartmentName);
                foreach (var emp in dept.MaleEmployees)
                {
                    sb.AppendLine("\tEmployee Name = " + emp.FirstName + " " + emp.LastName);
                }
                sb.AppendLine();
            }

            lblRestrictionOutput.Text = sb.ToString();
        }

        protected void btnOrderAsc_Click(object sender, EventArgs e)
        {
            // OrderBy ascending
            var result = Student.GetAllStudents().OrderBy(s => s.Name).ToList();
            gvStudents.DataSource = result;
            gvStudents.DataBind();
        }

        protected void btnOrderDesc_Click(object sender, EventArgs e)
        {
            // OrderByDescending
            var result = Student.GetAllStudents().OrderByDescending(s => s.Name).ToList();
            gvStudents.DataSource = result;
            gvStudents.DataBind();
        }

        protected void btnReverse_Click(object sender, EventArgs e)
        {
            // Reverse
            var list = Student.GetAllStudents();
            list.Reverse();
            gvStudents.DataSource = list;
            gvStudents.DataBind();
        }
    }
}
