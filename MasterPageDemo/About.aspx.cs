using System;
using System.Collections.Generic;
using System.Web.UI;

namespace MasterPageDemo
{
    public partial class About : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Read the search term from the query string (set by Site.Master search bar)
            string query = (Request.QueryString["q"] ?? string.Empty).Trim();

            // Fetch team members filtered by the query (returns all if query is empty)
            List<TeamMember> members = SampleData.GetTeamMembers(query);

            // Bind to GridView
            TeamGrid.DataSource = members;
            TeamGrid.DataBind();

            // Show the search badge and update labels when a filter is active
            if (!string.IsNullOrEmpty(query))
            {
                SearchBadge.Visible = true;
                LitQuery.Text       = Server.HtmlEncode(query);
                LitCount.Text       = $"{members.Count} result{(members.Count == 1 ? "" : "s")} found";
            }
            else
            {
                LitCount.Text = $"{members.Count} team members";
            }
        }
    }
}