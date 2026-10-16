using System;
using System.Collections.Generic;
using System.Web.UI;
using System.Web.UI.WebControls;
using Demo;

namespace GridViewDemo
{
    public partial class CustomPaging : Page
    {
        private const int PageSizeValue = 3;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadPage(0);
            }
        }

        private void LoadPage(int pageIndex)
        {
            int totalRows = 0;
            GridView1.DataSource = EmployeeDataAccessLayer.GetEmployees(pageIndex, PageSizeValue, out totalRows);
            GridView1.DataBind();
            DatabindRepeater(pageIndex, PageSizeValue, totalRows);

            int start = (pageIndex * PageSizeValue) + 1;
            int end = Math.Min((pageIndex + 1) * PageSizeValue, totalRows);
            lblPageStats.Text = string.Format("Showing {0} - {1} of {2} employees", start, end, totalRows);
        }

        protected void linkButton_Click(object sender, EventArgs e)
        {
            LinkButton btn = sender as LinkButton;
            if (btn != null)
            {
                int pageNumber = int.Parse(btn.CommandArgument);
                int pageIndex = pageNumber - 1;
                LoadPage(pageIndex);
            }
        }

        private void DatabindRepeater(int pageIndex, int pageSize, int totalRows)
        {
            int totalPages = totalRows / pageSize;
            if ((totalRows % pageSize) != 0)
            {
                totalPages += 1;
            }

            List<ListItem> pages = new List<ListItem>();
            if (totalPages > 1)
            {
                for (int i = 1; i <= totalPages; i++)
                {
                    // Enabled is false for the active page so it is visually selected and unclickable
                    pages.Add(new ListItem(i.ToString(), i.ToString(), i != (pageIndex + 1)));
                }
            }

            repeaterPaging.DataSource = pages;
            repeaterPaging.DataBind();
        }
    }
}
