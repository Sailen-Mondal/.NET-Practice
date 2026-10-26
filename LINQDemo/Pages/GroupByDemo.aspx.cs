using System;
using System.Linq;
using System.Text;
using System.Web.UI;
using LINQDemo.Models;

namespace LINQDemo.Pages
{
    public partial class GroupByDemo : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
        }

        /// <summary>
        /// Example 1: Count employees per department.
        /// </summary>
        protected void btnGroupExample1_Click(object sender, EventArgs e)
        {
            // Group employees by department; returns sequence of IGrouping<string, Employee>
            var employeeGroup = from employee in Employee.GetAllEmployeesForGroupBy()
                                 group employee by employee.Department;

            StringBuilder sb = new StringBuilder();
            sb.AppendLine("Department - Total Employees Count");
            sb.AppendLine("===================================");

            foreach (var group in employeeGroup)
            {
                // group.Key contains the grouping value (Department name)
                // group.Count() calculates the total items in this bucket
                sb.AppendLine(string.Format("{0} - {1}", group.Key, group.Count()));
            }

            litResult1.Text = sb.ToString();
            pnlResult1.Visible = true;
        }

        /// <summary>
        /// Example 2: Count and list employees for each department.
        /// </summary>
        protected void btnGroupExample2_Click(object sender, EventArgs e)
        {
            var employeeGroup = from employee in Employee.GetAllEmployeesForGroupBy()
                                 group employee by employee.Department;

            StringBuilder sb = new StringBuilder();

            foreach (var group in employeeGroup)
            {
                sb.AppendLine(string.Format("{0} - {1}", group.Key, group.Count()));
                sb.AppendLine("----------");

                // Each group itself implements IEnumerable<Employee>
                foreach (var employee in group)
                {
                    sb.AppendLine(employee.Name + "\t" + employee.Department);
                }

                sb.AppendLine();
            }

            litResult2.Text = sb.ToString();
            pnlResult2.Visible = true;
        }

        /// <summary>
        /// Example 3: Sorted by Department ascending, then by Employee Name ascending.
        /// </summary>
        protected void btnGroupExample3_Click(object sender, EventArgs e)
        {
            // 'into eGroup' continues the query pipeline
            // orderby eGroup.Key sorts the departments (HR before IT)
            // eGroup.OrderBy(x => x.Name) sorts the employees inside each department
            var employeeGroup = from employee in Employee.GetAllEmployeesForGroupBy()
                                 group employee by employee.Department into eGroup
                                 orderby eGroup.Key
                                 select new
                                 {
                                     Key = eGroup.Key,
                                     Employees = eGroup.OrderBy(x => x.Name)
                                 };

            StringBuilder sb = new StringBuilder();

            foreach (var group in employeeGroup)
            {
                sb.AppendLine(string.Format("{0} - {1}", group.Key, group.Employees.Count()));
                sb.AppendLine("----------");

                foreach (var employee in group.Employees)
                {
                    sb.AppendLine(employee.Name + "\t" + employee.Department);
                }

                sb.AppendLine();
            }

            litResult3.Text = sb.ToString();
            pnlResult3.Visible = true;
        }
    }
}
