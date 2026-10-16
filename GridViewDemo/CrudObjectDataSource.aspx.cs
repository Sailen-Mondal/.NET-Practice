using System;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace GridViewDemo
{
    public partial class CrudObjectDataSource : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
        }

        protected void lbInsert_Click(object sender, EventArgs e)
        {
            if (Page.IsValid)
            {
                TextBox txtName = GridView1.FooterRow.FindControl("txtName") as TextBox;
                DropDownList ddlInsertGender = GridView1.FooterRow.FindControl("ddlInsertGender") as DropDownList;
                TextBox txtCity = GridView1.FooterRow.FindControl("txtCity") as TextBox;

                if (txtName != null && ddlInsertGender != null && txtCity != null)
                {
                    ObjectDataSource1.InsertParameters["Name"].DefaultValue = txtName.Text.Trim();
                    ObjectDataSource1.InsertParameters["Gender"].DefaultValue = ddlInsertGender.SelectedValue;
                    ObjectDataSource1.InsertParameters["City"].DefaultValue = txtCity.Text.Trim();
                    ObjectDataSource1.Insert();
                }
            }
        }
    }
}
