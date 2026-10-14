using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace CookieDemo
{
    public partial class WebForm2 : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Point to remember:
            // Always check if the session variable is null before calling .ToString().
            // If the user navigates directly to WebForm2 without visiting WebForm1,
            // or if the session has timed out, calling Session["Name"].ToString()
            // would throw a runtime NullReferenceException!

            if (Session["Name"] != null)
            {
                lblName.Text = Session["Name"].ToString();
            }
            else
            {
                lblName.Text = "No Session Data Found";
            }

            if (Session["Email"] != null)
            {
                lblEmail.Text = Session["Email"].ToString();
            }
            else
            {
                lblEmail.Text = "No Session Data Found";
            }
        }
    }
}
