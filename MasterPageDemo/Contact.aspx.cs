using System;
using System.Collections.Generic;
using System.Web.UI;

namespace MasterPageDemo
{
    public partial class Contact : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Read the search term from the query string (set by Site.Master search bar)
            string query = (Request.QueryString["q"] ?? string.Empty).Trim();

            // Fetch contacts filtered by the query (returns all if query is empty)
            List<ContactEntry> contacts = SampleData.GetContacts(query);

            // Bind to GridView
            ContactGrid.DataSource = contacts;
            ContactGrid.DataBind();

            // Show the search badge and update labels when a filter is active
            if (!string.IsNullOrEmpty(query))
            {
                SearchBadge.Visible = true;
                LitQuery.Text       = Server.HtmlEncode(query);
                LitCount.Text       = $"{contacts.Count} result{(contacts.Count == 1 ? "" : "s")} found";
            }
            else
            {
                LitCount.Text = $"{contacts.Count} contacts";
            }
        }
    }
}