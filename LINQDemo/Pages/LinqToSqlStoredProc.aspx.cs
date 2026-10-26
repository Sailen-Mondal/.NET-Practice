using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI;
using LINQDemo.Data;
using LINQDemo.Models;

namespace LINQDemo.Pages
{
    public partial class LinqToSqlStoredProc : Page
    {
        // Mock fallback list for stored procedure testing in case SQL Server is offline
        private static List<Employee> _mockEmployees;

        static LinqToSqlStoredProc()
        {
            _mockEmployees = new List<Employee>
            {
                new Employee { ID = 1, FirstName = "Mark", LastName = "Wood", Gender = "Male", Salary = 45000, DepartmentID = 1 },
                new Employee { ID = 2, FirstName = "Steve", LastName = "Smith", Gender = "Male", Salary = 55000, DepartmentID = 2 },
                new Employee { ID = 3, FirstName = "Ben", LastName = "Stokes", Gender = "Male", Salary = 65000, DepartmentID = 1 },
                new Employee { ID = 4, FirstName = "Philip", LastName = "Hughes", Gender = "Male", Salary = 55000, DepartmentID = 1 },
                new Employee { ID = 5, FirstName = "Mary", LastName = "Kom", Gender = "Female", Salary = 48000, DepartmentID = 2 },
                new Employee { ID = 6, FirstName = "Valarie", LastName = "Adams", Gender = "Female", Salary = 70000, DepartmentID = 2 }
            };
        }

        protected void Page_Load(object sender, EventArgs e)
        {
        }

        /// <summary>
        /// Calls GetEmployees() stored procedure mapped via DataContext and binds to GridView1.
        /// </summary>
        protected void btnGetEmployeesSp_Click(object sender, EventArgs e)
        {
            try
            {
                using (SampleDataContext dbContext = new SampleDataContext())
                {
                    // Invokes the stored procedure GetEmployees mapped in SampleDataContext
                    // Return type is ISingleResult<Employee>
                    var employees = dbContext.GetEmployees().ToList();
                    GridView1.DataSource = employees;
                    GridView1.DataBind();
                    lblDept.Text = "Result of GetEmployees() Stored Procedure (All Departments)";
                    ShowNotification("Executed GetEmployees() stored procedure successfully.", true);
                }
            }
            catch (Exception ex)
            {
                // Fallback simulation
                GridView1.DataSource = _mockEmployees.ToList();
                GridView1.DataBind();
                lblDept.Text = "Result of GetEmployees() Stored Procedure (In-Memory Simulation)";
                ShowNotification("Displaying in-memory simulation (Database offline: " + ex.Message + ")", false);
            }
        }

        /// <summary>
        /// Calls GetEmployeesByDepartment() stored procedure with an OUTPUT parameter.
        /// </summary>
        protected void btnGetEmployeesByDepartment_Click(object sender, EventArgs e)
        {
            int departmentId = Convert.ToInt32(ddlDepartmentId.SelectedValue);

            try
            {
                using (SampleDataContext dbContext = new SampleDataContext())
                {
                    string deptName = string.Empty;

                    // Execute stored procedure with output parameter passed as ref
                    var employees = dbContext.GetEmployeesByDepartment(departmentId, ref deptName).ToList();

                    GridView1.DataSource = employees;
                    GridView1.DataBind();

                    // Display the output parameter populated by the stored procedure
                    lblDept.Text = "Department Name = " + deptName;
                    ShowNotification("Executed GetEmployeesByDepartment() stored procedure. Output parameter captured.", true);
                }
            }
            catch (Exception ex)
            {
                // Fallback simulation
                string deptName = departmentId == 1 ? "IT" : (departmentId == 2 ? "HR" : "Payroll");
                var employees = _mockEmployees.Where(emp => emp.DepartmentID == departmentId).ToList();

                GridView1.DataSource = employees;
                GridView1.DataBind();

                lblDept.Text = "Department Name = " + deptName + " (In-Memory Simulation)";
                ShowNotification("Executed stored procedure (In-memory simulation: " + ex.Message + ")", false);
            }
        }

        /// <summary>
        /// Calls InsertEmployee stored procedure.
        /// </summary>
        protected void btnInsertSp_Click(object sender, EventArgs e)
        {
            try
            {
                using (SampleDataContext dbContext = new SampleDataContext())
                {
                    dbContext.InsertEmployee("Alex", "Morgan", "Female", 62000, 1);
                    ShowNotification("Executed InsertEmployee stored procedure for Alex Morgan.", true);
                }
            }
            catch (Exception)
            {
                int nextId = _mockEmployees.Count > 0 ? _mockEmployees.Max(x => x.ID) + 1 : 1;
                _mockEmployees.Add(new Employee
                {
                    ID = nextId,
                    FirstName = "Alex",
                    LastName = "Morgan",
                    Gender = "Female",
                    Salary = 62000,
                    DepartmentID = 1
                });
                ShowNotification("Executed InsertEmployee stored procedure for Alex Morgan (in-memory simulation).", true);
            }

            btnGetEmployeesSp_Click(sender, e);
        }

        /// <summary>
        /// Calls UpdateEmployee stored procedure.
        /// </summary>
        protected void btnUpdateSp_Click(object sender, EventArgs e)
        {
            try
            {
                using (SampleDataContext dbContext = new SampleDataContext())
                {
                    dbContext.UpdateEmployee(1, "Mark", "Wood", "Male", 72000, 1);
                    ShowNotification("Executed UpdateEmployee stored procedure: Updated Mark Wood salary to 72000.", true);
                }
            }
            catch (Exception)
            {
                Employee emp = _mockEmployees.FirstOrDefault(x => x.ID == 1);
                if (emp != null)
                {
                    emp.Salary = 72000;
                }
                ShowNotification("Executed UpdateEmployee stored procedure: Updated Mark Wood salary to 72000 (in-memory simulation).", true);
            }

            btnGetEmployeesSp_Click(sender, e);
        }

        /// <summary>
        /// Calls DeleteEmployee stored procedure.
        /// </summary>
        protected void btnDeleteSp_Click(object sender, EventArgs e)
        {
            try
            {
                using (SampleDataContext dbContext = new SampleDataContext())
                {
                    dbContext.DeleteEmployee(6);
                    ShowNotification("Executed DeleteEmployee stored procedure for Employee ID 6.", true);
                }
            }
            catch (Exception)
            {
                Employee emp = _mockEmployees.FirstOrDefault(x => x.ID == 6);
                if (emp != null)
                {
                    _mockEmployees.Remove(emp);
                }
                ShowNotification("Executed DeleteEmployee stored procedure for Employee ID 6 (in-memory simulation).", true);
            }

            btnGetEmployeesSp_Click(sender, e);
        }

        private void ShowNotification(string message, bool isSuccess)
        {
            lblStatusMessage.Text = message;
            pnlStatus.CssClass = isSuccess ? "notion-alert notion-alert-success" : "notion-alert notion-alert-info";
            pnlStatus.Visible = true;
        }
    }
}
