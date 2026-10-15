using System;
using System.Collections.Generic;
using System.Web.UI;

namespace MasterPageDemo
{
    public partial class _Default : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Read the search term from the query string (set by Site.Master search bar)
            string query = (Request.QueryString["q"] ?? string.Empty).Trim();

            // Fetch articles filtered by the query (returns all if query is empty)
            List<Article> articles = SampleData.GetArticles(query);

            // Bind to GridView
            ArticleGrid.DataSource = articles;
            ArticleGrid.DataBind();

            // Show the search badge and update labels when a filter is active
            if (!string.IsNullOrEmpty(query))
            {
                SearchBadge.Visible = true;
                LitQuery.Text       = Server.HtmlEncode(query);
                LitCount.Text       = $"{articles.Count} result{(articles.Count == 1 ? "" : "s")} found";
            }
            else
            {
                LitCount.Text = $"{articles.Count} articles";
            }
        }
    }
}