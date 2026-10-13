using System;
using System.Web.UI;

namespace WebApplication1
{
    public partial class WebForm1 : System.Web.UI.Page
    {
        int ClicksCount = 0;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                TextBox1.Text = "0";
                TextBox2.Text = "0";
            }
        }

        // 1. Without ViewState (stays at 1)
        protected void Button1_Click(object sender, EventArgs e)
        {
            ClicksCount = ClicksCount + 1;
            TextBox1.Text = ClicksCount.ToString();
        }

        // 2. With ViewState (increments 1, 2, 3...)
        protected void Button2_Click(object sender, EventArgs e)
        {
            int ClicksCount = 1;

            if (ViewState["Clicks"] != null)
            {
                ClicksCount = (int)ViewState["Clicks"] + 1;
            }

            TextBox2.Text = ClicksCount.ToString();
            ViewState["Clicks"] = ClicksCount;
        }
    }
}
