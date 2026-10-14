using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace URLRouting
{
    public partial class PageRedirectionDemo : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        /// <summary>
        /// Demonstrates intercepting a click on the server and calling Response.Redirect
        /// for an internal page on the same web server.
        /// </summary>
        protected void btnRedirectInternal_Click(object sender, EventArgs e)
        {
            // Server-side processing before redirecting:
            // Storing user's input in Session
            if (!string.IsNullOrWhiteSpace(txtUserName.Text))
            {
                Session["UserName"] = txtUserName.Text;
            }

            // Response.Redirect sends an HTTP 302 Found response to the browser.
            // The browser then issues a new GET request to URLRouting.aspx.
            Response.Redirect("URLRouting.aspx");
        }

        /// <summary>
        /// Demonstrates a LinkButton intercepting click on server before redirecting
        /// </summary>
        protected void lnkBtnArticles_Click(object sender, EventArgs e)
        {
            Response.Redirect("URLRouting.aspx");
        }

        /// <summary>
        /// Demonstrates redirecting to an external website on a different web server.
        /// </summary>
        protected void btnRedirectExternal_Click(object sender, EventArgs e)
        {
            // Navigating to a different web server
            Response.Redirect("https://www.microsoft.com");
        }
    }
}
