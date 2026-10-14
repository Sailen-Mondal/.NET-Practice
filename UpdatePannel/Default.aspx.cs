using System;

namespace UpdatePannel
{
    public partial class _Default : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e) { }

        // Fires when the LinkButton is clicked — full postback
        protected void LinkButton1_Click(object sender, EventArgs e)
        {
            Label1.Text = "Welcome to My Web World...!!";
        }
    }
}