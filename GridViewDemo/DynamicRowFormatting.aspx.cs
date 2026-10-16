using System;
using System.Drawing;
using System.Globalization;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace GridViewDemo
{
    public partial class DynamicRowFormatting : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
        }

        protected void GridView1_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            // If the row being databound is a header row
            if (e.Row.RowType == DataControlRowType.Header)
            {
                // Hide CountryCulture header table cell 
                e.Row.Cells[4].Visible = false;
            }
            // If the row being databound is a data row
            else if (e.Row.RowType == DataControlRowType.DataRow)
            {
                // Retrieve salary safely using DataBinder.Eval
                int salary = Convert.ToInt32(DataBinder.Eval(e.Row.DataItem, "AnnualSalary"));

                // Retrieve the culture 
                string countryCulture = e.Row.Cells[4].Text.Trim();

                // Turn off the visibility of CountryCulture cell
                e.Row.Cells[4].Visible = false;

                // Format the currency using specific country culture
                if (!string.IsNullOrEmpty(countryCulture) && countryCulture != "&nbsp;")
                {
                    try
                    {
                        string formattedString = string.Format(new CultureInfo(countryCulture), "{0:c}", salary);
                        e.Row.Cells[2].Text = formattedString;
                    }
                    catch
                    {
                        e.Row.Cells[2].Text = salary.ToString("C");
                    }
                }

                // If Salary > 70000, set your styles dynamically
                if (salary > 70000)
                {
                    // Use a clean Notion-red shade (matches slide's Red + White text)
                    e.Row.BackColor = Color.FromArgb(235, 87, 87);
                    e.Row.ForeColor = Color.White;
                }
            }
            else if (e.Row.RowType == DataControlRowType.Footer)
            {
                e.Row.Cells[4].Visible = false;
                e.Row.Cells[1].Text = "Total Count: " + GridView1.Rows.Count.ToString();
            }
        }
    }
}
