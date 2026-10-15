using System;
using System.Web.UI;

namespace MasterPageDemo
{
    public partial class SiteMaster : MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Pre-fill the search box if the current page has a ?q= parameter,
            // so the user can see what they searched for after the redirect.
            if (!IsPostBack)
            {
                string q = Request.QueryString["q"];
                if (!string.IsNullOrEmpty(q))
                    SearchBox.Text = q;
            }
        }

        protected void SearchButton_Click(object sender, EventArgs e)
        {
            string query = SearchBox.Text.Trim();

            // Redirect to the same page with the query string appended.
            // This keeps the search scoped to the current page's dataset.
            string currentPage = Request.AppRelativeCurrentExecutionFilePath;
            Response.Redirect(currentPage + "?q=" + Server.UrlEncode(query));
        }
    }
}