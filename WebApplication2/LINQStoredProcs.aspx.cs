using System;
using System.Linq;
using System.Web.UI;
using CRUDUsingLINQ.Models;

namespace CRUDUsingLINQ
{
    public partial class LINQStoredProcs : Page
    {
        private SampleDataContext dbContext = new SampleDataContext();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindAllEmployeesSP();
                btnGetEmployeesByDepartment_Click(null, null);
            }
        }

        private void BindAllEmployeesSP()
        {
            // Calling GetEmployees stored procedure
            var employees = dbContext.GetEmployees().ToList();
            gvEmployeesSP.DataSource = employees.Select(x => new
            {
                x.ID,
                x.FirstName,
                x.LastName,
                x.Gender,
                x.Salary,
                x.DepartmentId
            });
            gvEmployeesSP.DataBind();
        }

        protected void btnGetEmployeesSP_Click(object sender, EventArgs e)
        {
            BindAllEmployeesSP();
            lblSpResult.Visible = true;
            lblSpResult.CssClass = "notion-status notion-status-info";
            lblSpResult.Text = "Executed GetEmployees() stored procedure successfully.";
        }

        protected void btnGetEmployeesByDepartment_Click(object sender, EventArgs e)
        {
            int deptId = Convert.ToInt32(ddlDepartments.SelectedValue);
            string deptName = string.Empty;

            // Calling GetEmployeesByDepartment stored procedure with ref output parameter
            var list = dbContext.GetEmployeesByDepartment(deptId, ref deptName).ToList();

            gvDeptEmployees.DataSource = list.Select(x => new
            {
                x.ID,
                x.FirstName,
                x.LastName,
                x.Gender,
                x.Salary,
                x.DepartmentId
            });
            gvDeptEmployees.DataBind();

            lblDept.Text = "Department Name = " + (string.IsNullOrEmpty(deptName) ? "Not Found" : deptName);
        }

        protected void btnSpInsert_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtSpFirstName.Text))
            {
                lblSpResult.Visible = true;
                lblSpResult.CssClass = "notion-status notion-status-info";
                lblSpResult.Text = "Please enter employee First Name.";
                return;
            }

            int? salary = null;
            if (int.TryParse(txtSpSalary.Text, out int sVal))
            {
                salary = sVal;
            }

            int? deptId = null;
            if (int.TryParse(txtSpDeptId.Text, out int dVal))
            {
                deptId = dVal;
            }

            // Calling InsertEmployee stored procedure
            dbContext.InsertEmployee(
                txtSpFirstName.Text.Trim(),
                txtSpLastName.Text.Trim(),
                txtSpGender.Text.Trim(),
                salary,
                deptId);

            BindAllEmployeesSP();
            lblSpResult.Visible = true;
            lblSpResult.CssClass = "notion-status notion-status-success";
            lblSpResult.Text = "Employee inserted successfully via InsertEmployee stored procedure.";
            
            txtSpFirstName.Text = "";
            txtSpLastName.Text = "";
            txtSpSalary.Text = "";
        }

        protected void btnSpUpdate_Click(object sender, EventArgs e)
        {
            if (!int.TryParse(txtUpdEmpId.Text, out int empId))
            {
                lblSpResult.Visible = true;
                lblSpResult.CssClass = "notion-status notion-status-info";
                lblSpResult.Text = "Please enter a valid numeric Employee ID.";
                return;
            }

            if (!int.TryParse(txtUpdSalary.Text, out int newSalary))
            {
                lblSpResult.Visible = true;
                lblSpResult.CssClass = "notion-status notion-status-info";
                lblSpResult.Text = "Please enter a valid numeric salary.";
                return;
            }

            // Fetch existing employee
            Employee emp = dbContext.Employees.SingleOrDefault(x => x.ID == empId);
            if (emp != null)
            {
                // Calling UpdateEmployee stored procedure
                dbContext.UpdateEmployee(emp.ID, emp.FirstName, emp.LastName, emp.Gender, newSalary, emp.DepartmentId);
                BindAllEmployeesSP();

                lblSpResult.Visible = true;
                lblSpResult.CssClass = "notion-status notion-status-success";
                lblSpResult.Text = string.Format("Employee ID {0} salary updated to {1} via UpdateEmployee stored procedure.", empId, newSalary);
            }
            else
            {
                lblSpResult.Visible = true;
                lblSpResult.CssClass = "notion-status notion-status-info";
                lblSpResult.Text = "Employee ID " + empId + " not found.";
            }
        }

        protected void btnSpDelete_Click(object sender, EventArgs e)
        {
            if (!int.TryParse(txtDelEmpId.Text, out int empId))
            {
                lblSpResult.Visible = true;
                lblSpResult.CssClass = "notion-status notion-status-info";
                lblSpResult.Text = "Please enter a valid numeric Employee ID.";
                return;
            }

            Employee emp = dbContext.Employees.SingleOrDefault(x => x.ID == empId);
            if (emp != null)
            {
                // Calling DeleteEmployee stored procedure
                dbContext.DeleteEmployee(empId);
                BindAllEmployeesSP();

                lblSpResult.Visible = true;
                lblSpResult.CssClass = "notion-status notion-status-success";
                lblSpResult.Text = "Employee ID " + empId + " deleted successfully via DeleteEmployee stored procedure.";
                txtDelEmpId.Text = "";
            }
            else
            {
                lblSpResult.Visible = true;
                lblSpResult.CssClass = "notion-status notion-status-info";
                lblSpResult.Text = "Employee ID " + empId + " not found.";
            }
        }
    }
}
