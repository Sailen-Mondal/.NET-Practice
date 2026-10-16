using System;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace GridViewDemo
{
    public partial class FormattingBasics : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
        }

        protected void ddlDateFormat_SelectedIndexChanged(object sender, EventArgs e)
        {
            BoundField dateField = GridView1.Columns[3] as BoundField;
            if (dateField != null)
            {
                dateField.DataFormatString = ddlDateFormat.SelectedValue;
                GridView1.DataBind();
            }
        }

        protected void ddlIdVisibility_SelectedIndexChanged(object sender, EventArgs e)
        {
            BoundField idField = GridView1.Columns[0] as BoundField;
            if (idField != null)
            {
                idField.Visible = (ddlIdVisibility.SelectedValue == "Visible");
                GridView1.DataBind();
            }
        }

        protected void GridView1_RowDataBound(object sender, GridViewRowEventArgs e)
        {
        }
    }
}
