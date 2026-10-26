using System;
using System.Linq;
using System.Text;
using System.Web.UI;
using CRUDUsingLINQ.Models;

namespace CRUDUsingLINQ
{
    public partial class LINQGroupingJoins : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                btnGroupCount_Click(null, null);
                btnJoinMethod_Click(null, null);
            }
        }

        protected void btnGroupCount_Click(object sender, EventArgs e)
        {
            // Example 1: Get Employee Count By Department
            var employeeGroup = from employee in Employee.GetAllEmployees()
                                where !string.IsNullOrEmpty(employee.Department)
                                group employee by employee.Department;

            StringBuilder sb = new StringBuilder();
            sb.AppendLine("Department Employee Count:");
            sb.AppendLine("--------------------------");
            foreach (var group in employeeGroup)
            {
                sb.AppendLine(string.Format("{0} - {1}", group.Key, group.Count()));
            }

            lblGroupOutput.Text = sb.ToString();
        }

        protected void btnGroupDetails_Click(object sender, EventArgs e)
        {
            // Example 2: Count and list employees per department
            var employeeGroup = from employee in Employee.GetAllEmployees()
                                where !string.IsNullOrEmpty(employee.Department)
                                group employee by employee.Department;

            StringBuilder sb = new StringBuilder();
            foreach (var group in employeeGroup)
            {
                sb.AppendLine(string.Format("Department: {0} (Count: {1})", group.Key, group.Count()));
                sb.AppendLine("----------------------------------------");
                foreach (var employee in group)
                {
                    sb.AppendLine(employee.Name + "\t" + employee.Department + "\tSalary: " + employee.Salary);
                }
                sb.AppendLine();
            }

            lblGroupOutput.Text = sb.ToString();
        }

        protected void btnGroupSorted_Click(object sender, EventArgs e)
        {
            // Example 3: Sorted first by Department ascending, then by Employee Name ascending
            var employeeGroup = from employee in Employee.GetAllEmployees()
                                where !string.IsNullOrEmpty(employee.Department)
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
                sb.AppendLine(string.Format("Department: {0} (Count: {1})", group.Key, group.Employees.Count()));
                sb.AppendLine("----------------------------------------");
                foreach (var employee in group.Employees)
                {
                    sb.AppendLine(employee.Name + "\t" + employee.Department);
                }
                sb.AppendLine();
            }

            lblGroupOutput.Text = sb.ToString();
        }

        protected void btnJoinMethod_Click(object sender, EventArgs e)
        {
            // Inner join using Method syntax
            var result = Employee.GetAllEmployees().Join(
                Department.GetAllDepartments(),
                emp => emp.DepartmentId,
                dept => dept.ID,
                (emp, dept) => new
                {
                    EmployeeID = emp.ID,
                    EmployeeName = emp.Name,
                    Gender = emp.Gender,
                    DepartmentID = dept.ID,
                    DepartmentName = dept.Name
                }).ToList();

            gvJoinResult.DataSource = result;
            gvJoinResult.DataBind();
        }

        protected void btnJoinQuery_Click(object sender, EventArgs e)
        {
            // Inner join using Query syntax
            var result = (from emp in Employee.GetAllEmployees()
                          join dept in Department.GetAllDepartments()
                          on emp.DepartmentId equals dept.ID
                          select new
                          {
                              EmployeeID = emp.ID,
                              EmployeeName = emp.Name,
                              Gender = emp.Gender,
                              DepartmentID = dept.ID,
                              DepartmentName = dept.Name
                          }).ToList();

            gvJoinResult.DataSource = result;
            gvJoinResult.DataBind();
        }
    }
}
