using System;
using System.Globalization;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace GridViewDemo
{
    public partial class CurrencyCulture : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                RenderCultures("");
            }
        }

        protected void GridView1_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            // Check if the row that is being bound, is a datarow
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                string country = e.Row.Cells[3].Text.Trim();
                int salary;
                if (int.TryParse(e.Row.Cells[2].Text, out salary))
                {
                    string formattedString = "";

                    if (country == "US")
                    {
                        formattedString = string.Format(new CultureInfo("en-US"), "{0:c}", salary);
                    }
                    else if (country == "UK")
                    {
                        formattedString = string.Format(new CultureInfo("en-GB"), "{0:c}", salary);
                    }
                    else if (country == "India")
                    {
                        formattedString = string.Format(new CultureInfo("en-IN"), "{0:c}", salary);
                    }
                    else if (country == "South Africa")
                    {
                        formattedString = string.Format(new CultureInfo("en-ZA"), "{0:c}", salary);
                    }
                    else if (country == "Malaysia")
                    {
                        formattedString = string.Format(new CultureInfo("en-MY"), "{0:c}", salary);
                    }
                    else
                    {
                        formattedString = string.Format(CultureInfo.InvariantCulture, "{0:c}", salary);
                    }

                    e.Row.Cells[2].Text = formattedString;
                }
            }
        }

        protected void btnSearchCulture_Click(object sender, EventArgs e)
        {
            RenderCultures(txtCultureSearch.Text.Trim());
        }

        private void RenderCultures(string filter)
        {
            StringBuilder sb = new StringBuilder();
            sb.Append("<div style='display: grid; grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); gap: 8px; font-size: 13px;'>");

            int count = 0;
            foreach (CultureInfo ci in CultureInfo.GetCultures(CultureTypes.SpecificCultures))
            {
                if (string.IsNullOrEmpty(filter) ||
                    ci.Name.IndexOf(filter, StringComparison.OrdinalIgnoreCase) >= 0 ||
                    ci.DisplayName.IndexOf(filter, StringComparison.OrdinalIgnoreCase) >= 0)
                {
                    string symbol = ci.NumberFormat.CurrencySymbol;
                    sb.AppendFormat("<div style='background: #f7f6f5; padding: 6px 10px; border-radius: 4px; display: flex; justify-content: space-between;'>")
                      .AppendFormat("<span><strong>{0}</strong> ({1})</span>", ci.Name, ci.EnglishName)
                      .AppendFormat("<span class='notion-tag notion-tag-neutral'>{0}</span>", symbol)
                      .Append("</div>");
                    count++;
                    if (count >= 40) break; // Keep display responsive
                }
            }
            sb.Append("</div>");
            litCultures.Text = sb.ToString();
        }
    }
}
