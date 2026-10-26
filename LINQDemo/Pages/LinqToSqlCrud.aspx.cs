using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI;
using LINQDemo.Data;
using LINQDemo.Models;

namespace LINQDemo.Pages
{
    public partial class LinqToSqlCrud : Page
    {
        // In-memory simulation fallback store for development without an active SQL Server connection
        private static List<Employee> _mockEmployees;

        static LinqToSqlCrud()
        {
            ResetMockData();
        }

        private static void ResetMockData()
        {
            _mockEmployees = new List<Employee>
            {
                new Employee { ID = 1, FirstName = "Mark", LastName = "Wood", Gender = "Male", Salary = 45000, DepartmentID = 1 },
                new Employee { ID = 2, FirstName = "Steve", LastName = "Smith", Gender = "Male", Salary = 55000, DepartmentID = 2 },
                new Employee { ID = 3, FirstName = "Ben", LastName = "Stokes", Gender = "Male", Salary = 65000, DepartmentID = 1 },
                new Employee { ID = 4, FirstName = "Philip", LastName = "Hughes", Gender = "Male", Salary = 55000, DepartmentID = 1 },
                new Employee { ID = 5, FirstName = "Mary", LastName = "Kom", Gender = "Female", Salary = 48000, DepartmentID = 2 },
                new Employee { ID = 6, FirstName = "Valarie", LastName = "Adams", Gender = "Female", Salary = 70000, DepartmentID = 2 },
                new Employee { ID = 7, FirstName = "John", LastName = "Doe", Gender = "Male", Salary = 64000, DepartmentID = 1 },
                new Employee { ID = 8, FirstName = "Pam", LastName = "Beesly", Gender = "Female", Salary = 54000, DepartmentID = 1 },
                new Employee { ID = 9, FirstName = "Stacey", LastName = "Jones", Gender = "Female", Salary = 84000, DepartmentID = 2 }
            };
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                GetData();
            }
        }

        /// <summary>
        /// Retrieves employees via LINQ to SQL DataContext and binds to GridView1.
        /// </summary>
        private void GetData()
        {
            try
            {
                using (SampleDataContext dbContext = new SampleDataContext())
                {
                    GridView1.DataSource = dbContext.Employees.ToList();
                    GridView1.DataBind();
                }
            }
            catch (Exception ex)
            {
                // Fallback to simulation store if SQL Server is not reachable
                GridView1.DataSource = _mockEmployees.ToList();
                GridView1.DataBind();
                ShowNotification("Displaying in-memory data (Database offline or not configured: " + ex.Message + ")", false);
            }
        }

        /// <summary>
        /// Button 1: Get Data click event handler.
        /// </summary>
        protected void btnGetData_Click(object sender, EventArgs e)
        {
            GetData();
            ShowNotification("Data refreshed successfully from DataContext.Employees.", true);
        }

        /// <summary>
        /// Button 2: Insert click event handler using dbContext.Employees.InsertOnSubmit().
        /// </summary>
        protected void btnInsert_Click(object sender, EventArgs e)
        {
            try
            {
                using (SampleDataContext dbContext = new SampleDataContext())
                {
                    Employee newEmployee = new Employee
                    {
                        FirstName = "Tim",
                        LastName = "T",
                        Gender = "Male",
                        Salary = 55000,
                        DepartmentID = 1
                    };

                    dbContext.Employees.InsertOnSubmit(newEmployee);
                    dbContext.SubmitChanges();
                }

                ShowNotification("Employee 'Tim T' inserted successfully into database.", true);
            }
            catch (Exception)
            {
                // In-memory simulation fallback
                int nextId = _mockEmployees.Count > 0 ? _mockEmployees.Max(x => x.ID) + 1 : 1;
                _mockEmployees.Add(new Employee
                {
                    ID = nextId,
                    FirstName = "Tim",
                    LastName = "T",
                    Gender = "Male",
                    Salary = 55000,
                    DepartmentID = 1
                });

                ShowNotification("Employee 'Tim T' inserted successfully (in-memory simulation).", true);
            }

            GetData();
        }

        /// <summary>
        /// Button 3: Update click event handler: finds employee with ID 8 and updates salary to 65000.
        /// </summary>
        protected void btnUpdate_Click(object sender, EventArgs e)
        {
            try
            {
                using (SampleDataContext dbContext = new SampleDataContext())
                {
                    Employee employee = dbContext.Employees.SingleOrDefault(x => x.ID == 8);
                    if (employee != null)
                    {
                        employee.Salary = 65000;
                        dbContext.SubmitChanges();
                        ShowNotification("Employee with ID 8 updated: Salary set to 65000.", true);
                    }
                    else
                    {
                        ShowNotification("Employee with ID 8 was not found in database.", false);
                    }
                }
            }
            catch (Exception)
            {
                // In-memory simulation fallback
                Employee employee = _mockEmployees.SingleOrDefault(x => x.ID == 8);
                if (employee != null)
                {
                    employee.Salary = 65000;
                    ShowNotification("Employee with ID 8 updated: Salary set to 65000 (in-memory simulation).", true);
                }
                else
                {
                    ShowNotification("Employee with ID 8 was not found.", false);
                }
            }

            GetData();
        }

        /// <summary>
        /// Button 4: Delete click event handler: finds employee with ID 8 and calls DeleteOnSubmit().
        /// </summary>
        protected void btnDelete_Click(object sender, EventArgs e)
        {
            try
            {
                using (SampleDataContext dbContext = new SampleDataContext())
                {
                    Employee employee = dbContext.Employees.SingleOrDefault(x => x.ID == 8);
                    if (employee != null)
                    {
                        dbContext.Employees.DeleteOnSubmit(employee);
                        dbContext.SubmitChanges();
                        ShowNotification("Employee with ID 8 deleted from database.", true);
                    }
                    else
                    {
                        ShowNotification("Employee with ID 8 was not found in database.", false);
                    }
                }
            }
            catch (Exception)
            {
                // In-memory simulation fallback
                Employee employee = _mockEmployees.SingleOrDefault(x => x.ID == 8);
                if (employee != null)
                {
                    _mockEmployees.Remove(employee);
                    ShowNotification("Employee with ID 8 deleted (in-memory simulation).", true);
                }
                else
                {
                    ShowNotification("Employee with ID 8 was not found.", false);
                }
            }

            GetData();
        }

        private void ShowNotification(string message, bool isSuccess)
        {
            lblStatusMessage.Text = message;
            pnlStatus.CssClass = isSuccess ? "notion-alert notion-alert-success" : "notion-alert notion-alert-info";
            pnlStatus.Visible = true;
        }
    }
}
