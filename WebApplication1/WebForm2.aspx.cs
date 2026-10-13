using System;
using System.Drawing;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using WebApplication1.BLL;
using WebApplication1.Models;

namespace WebApplication1
{
    // =========================================================================
    // PRESENTATION LAYER (UI / Code-Behind)
    // Interacts with user, validates inputs, calls BLL, and displays results
    // =========================================================================
    public partial class WebForm2 : System.Web.UI.Page
    {
        // Reference to the Business Logic Layer (3-Layer Architecture)
        private readonly EmployeeBLL bll = new EmployeeBLL();

        protected void Page_Load(object sender, EventArgs e)
        {
            // Only load data on the initial request (not on postback)
            if (!IsPostBack)
            {
                LoadEmployees();
            }
        }

        // =====================================================================
        // 5. CUSTOM VALIDATOR SERVER-SIDE EVENT HANDLER
        // Validates whether the entered city is an authorized company branch
        // =====================================================================
        protected void cvCity_ServerValidate(object source, ServerValidateEventArgs args)
        {
            string[] allowedBranches = { "Kolkata", "Delhi", "Mumbai", "Bengaluru", "Hyderabad", "Chennai", "Kochi", "Ahmedabad", "Lucknow" };

            if (!string.IsNullOrWhiteSpace(args.Value))
            {
                args.IsValid = allowedBranches.Any(city => string.Equals(city, args.Value.Trim(), StringComparison.OrdinalIgnoreCase));
            }
            else
            {
                args.IsValid = false;
            }
        }

        protected void btnSubmit_Click(object sender, EventArgs e)
        {
            // Validate the page using ASP.NET Validation engine
            // If any validator fails, Page.IsValid will be false
            if (!Page.IsValid)
            {
                lblMessage.Text = "Please fix the validation errors displayed above.";
                lblMessage.ForeColor = Color.Red;
                return;
            }

            try
            {
                // 1. Gather input from UI controls into the Model
                Employee emp = new Employee();
                emp.FirstName = txtFirstName.Text.Trim();
                emp.LastName = txtLastName.Text.Trim();
                emp.Age = Convert.ToInt32(txtAge.Text.Trim());
                emp.City = txtCity.Text.Trim();

                // Parse Date of Joining
                DateTime doj;
                if (DateTime.TryParse(txtDateOfJoining.Text.Trim(), out doj))
                {
                    emp.DateOfJoining = doj;
                }
                else
                {
                    emp.DateOfJoining = DateTime.Now;
                }

                emp.Salary = Convert.ToDecimal(txtSalary.Text.Trim());

                // 2. Call Business Logic Layer to process & insert
                int newId = bll.AddEmployee(emp);

                // 3. Show success message
                lblMessage.Text = "Employee registered successfully! Record ID: " + newId;
                lblMessage.ForeColor = Color.Green;

                // 4. Clear input fields for next entry
                ClearFields();

                // 5. Refresh GridView to reflect the change from database
                LoadEmployees();
            }
            catch (Exception ex)
            {
                // Display error message
                lblMessage.Text = "Error: " + ex.Message;
                lblMessage.ForeColor = Color.Red;
            }
        }

        // Helper method to bind GridView with latest data from DB via BLL
        private void LoadEmployees()
        {
            try
            {
                gvEmployees.DataSource = bll.GetEmployees();
                gvEmployees.DataBind();
            }
            catch (Exception ex)
            {
                lblMessage.Text = "Unable to load records: " + ex.Message;
                lblMessage.ForeColor = Color.Red;
            }
        }

        // Helper method to clear all textboxes
        private void ClearFields()
        {
            txtFirstName.Text = string.Empty;
            txtLastName.Text = string.Empty;
            txtEmail.Text = string.Empty;
            txtAge.Text = string.Empty;
            txtCity.Text = string.Empty;
            txtDateOfJoining.Text = string.Empty;
            txtSalary.Text = string.Empty;
            txtConfirmSalary.Text = string.Empty;
        }
    }
}
