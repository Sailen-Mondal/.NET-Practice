using System;
using System.Web.UI;
using System.Web.UI.WebControls;
using Demo;

namespace GridViewDemo
{
    public partial class CrudCodeBehind : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindGridViewData();
            }
        }

        private void BindGridViewData()
        {
            GridView1.DataSource = EmployeeDataAccessLayer.GetAllEmployees();
            GridView1.DataBind();
        }

        protected void GridView1_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "EditRow")
            {
                int rowIndex = ((GridViewRow)((LinkButton)e.CommandSource).NamingContainer).RowIndex;
                GridView1.EditIndex = rowIndex;
                BindGridViewData();
            }
            else if (e.CommandName == "DeleteRow")
            {
                int employeeId = Convert.ToInt32(e.CommandArgument);
                EmployeeDataAccessLayer.DeleteEmployee(employeeId);
                BindGridViewData();
            }
            else if (e.CommandName == "CancelUpdate")
            {
                GridView1.EditIndex = -1;
                BindGridViewData();
            }
            else if (e.CommandName == "UpdateRow")
            {
                if (Page.IsValid)
                {
                    int rowIndex = ((GridViewRow)((LinkButton)e.CommandSource).NamingContainer).RowIndex;
                    int employeeId = Convert.ToInt32(e.CommandArgument);

                    TextBox txtName = GridView1.Rows[rowIndex].FindControl("TextBox1") as TextBox;
                    DropDownList ddlGender = GridView1.Rows[rowIndex].FindControl("DropDownList1") as DropDownList;
                    TextBox txtCity = GridView1.Rows[rowIndex].FindControl("TextBox3") as TextBox;

                    if (txtName != null && ddlGender != null && txtCity != null)
                    {
                        string name = txtName.Text.Trim();
                        string gender = ddlGender.SelectedValue;
                        string city = txtCity.Text.Trim();

                        EmployeeDataAccessLayer.UpdateEmployee(employeeId, name, gender, city);
                        GridView1.EditIndex = -1;
                        BindGridViewData();
                    }
                }
            }
            else if (e.CommandName == "InsertRow")
            {
                if (Page.IsValid)
                {
                    TextBox txtName = GridView1.FooterRow.FindControl("txtName") as TextBox;
                    DropDownList ddlGender = GridView1.FooterRow.FindControl("ddlGender") as DropDownList;
                    TextBox txtCity = GridView1.FooterRow.FindControl("txtCity") as TextBox;

                    if (txtName != null && ddlGender != null && txtCity != null)
                    {
                        string name = txtName.Text.Trim();
                        string gender = ddlGender.SelectedValue;
                        string city = txtCity.Text.Trim();

                        EmployeeDataAccessLayer.InsertEmployee(name, gender, city);
                        BindGridViewData();
                    }
                }
            }
        }
    }
}
