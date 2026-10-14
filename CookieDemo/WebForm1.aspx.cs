using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace CookieDemo
{
    public partial class WebForm1 : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        protected void btnSendData_Click(object sender, EventArgs e)
        {
            // Session stores data as key/value pairs in server memory.
            // Unlike cookies (which store data on the client browser),
            // Session values reside securely on the web server.
            Session["Name"] = txtName.Text;
            Session["Email"] = txtEmail.Text;

            // Redirect the user to WebForm2.aspx where the stored session data will be retrieved
            Response.Redirect("WebForm2.aspx");
        }
    }
}
