using System;
using System.Linq;
using System.Web.UI;
using LINQDemo.Models;

namespace LINQDemo.Pages
{
    public partial class InnerJoinDemo : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // Show raw data collections so user sees the source data
                gvDepartments.DataSource = Department.GetAllDepartments();
                gvDepartments.DataBind();

                gvEmployees.DataSource = Employee.GetAllEmployees().Select(emp => new
                {
                    emp.ID,
                    emp.Name,
                    DepartmentID = emp.DepartmentID.HasValue ? emp.DepartmentID.Value.ToString() : "(None)"
                });
                gvEmployees.DataBind();
            }
        }

        /// <summary>
        /// Example 1: Join using Method Syntax.
        /// </summary>
        protected void btnJoinMethod_Click(object sender, EventArgs e)
        {
            // Join extension method parameters:
            // 1. Inner sequence: Department.GetAllDepartments()
            // 2. Outer key selector: emp => emp.DepartmentID
            // 3. Inner key selector: dept => dept.ID
            // 4. Result selector: projects combined anonymous object
            var result = Employee.GetAllEmployees().Join(
                Department.GetAllDepartments(),
                emp => emp.DepartmentID,
                dept => dept.ID,
                (employee, department) => new
                {
                    EmployeeName = employee.Name,
                    DepartmentName = department.Name
                }).ToList();

            lblJoinTitle.Text = "Result via Method Syntax (9 matched records, Andy excluded):";
            gvJoinResults.DataSource = result;
            gvJoinResults.DataBind();
            pnlJoinResult.Visible = true;
        }

        /// <summary>
        /// Example 2: Join using SQL-like Query Syntax.
        /// </summary>
        protected void btnJoinQuery_Click(object sender, EventArgs e)
        {
            // Query syntax uses 'join ... in ... on ... equals ...'
            var result = (from emp in Employee.GetAllEmployees()
                          join dept in Department.GetAllDepartments()
                          on emp.DepartmentID equals dept.ID
                          select new
                          {
                              EmployeeName = emp.Name,
                              DepartmentName = dept.Name
                          }).ToList();

            lblJoinTitle.Text = "Result via SQL-like Query Syntax (9 matched records, Andy excluded):";
            gvJoinResults.DataSource = result;
            gvJoinResults.DataBind();
            pnlJoinResult.Visible = true;
        }
    }
}
