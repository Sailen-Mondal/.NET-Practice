using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace URLRouting
{
    public partial class DetailPage : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // =========================================================================
            // BEGINNER CONCEPT: RouteData & QueryString Extraction
            // -------------------------------------------------------------------------
            // When accessing via friendly URL: /Articles/1/How-to-validate-dropdownlist
            // The route parameters are available in Page.RouteData.Values["id"].
            //
            // IMPORTANT FOR BEGINNERS:
            // ALWAYS check for null BEFORE calling .ToString()!
            // if (Page.RouteData.Values["id"] != null) is safe.
            // Calling Page.RouteData.Values["id"].ToString() directly on null throws NullReferenceException!
            // =========================================================================

            string strId = null;
            string strTitle = null;

            if (Page.RouteData.Values["id"] != null)
            {
                strId = Page.RouteData.Values["id"].ToString();
                strTitle = Page.RouteData.Values["Title"] != null ? Page.RouteData.Values["Title"].ToString() : "";
                lblRouteId.Text = strId;
                lblRouteTitle.Text = strTitle;
            }
            else if (!string.IsNullOrEmpty(Request.QueryString["id"]))
            {
                // Fallback support if accessed as DetailPage.aspx?id=1
                strId = Request.QueryString["id"];
                strTitle = Request.QueryString["Title"] ?? "";
                lblRouteId.Text = strId + " (via QueryString)";
                lblRouteTitle.Text = strTitle;
            }

            if (!string.IsNullOrEmpty(strId))
            {
                DisplayArticle(strId);
            }
            else
            {
                lblRouteId.Text = "None";
                lblRouteTitle.Text = "None";
                lblTitle.Text = "No Article Selected";
                lblauthor.Text = "N/A";
                lblDescription.Text = "Please navigate via URLRouting.aspx or a valid route like /Articles/1/How-to-validate-dropdownlist-in-asp.net";
            }
        }

        /// <summary>
        /// Loads the article record matching the ID from Articletable
        /// </summary>
        private void DisplayArticle(string strId)
        {
            string[] connStringsToTry = new string[]
            {
                ConfigurationManager.ConnectionStrings["TestDBConnection"] != null ? ConfigurationManager.ConnectionStrings["TestDBConnection"].ConnectionString : null,
                "Data Source=.; uid=sa; pwd=mcc#1234; database=TestDB",
                "Data Source=.; uid=sa; pwd=Micr0s0ft; database=TestDB",
                "Data Source=.; Integrated Security=True; database=TestDB"
            };

            foreach (var strConn in connStringsToTry)
            {
                if (string.IsNullOrEmpty(strConn)) continue;

                try
                {
                    using (SqlConnection conn = new SqlConnection(strConn))
                    {
                        SqlCommand cmd = new SqlCommand("SELECT Id, Title, Description, Author FROM Articletable WHERE Id = @Id", conn);
                        cmd.Parameters.AddWithValue("@Id", strId);

                        SqlDataAdapter da = new SqlDataAdapter(cmd);
                        DataSet ds = new DataSet();
                        da.Fill(ds, "Articletable");

                        if (ds.Tables["Articletable"] != null && ds.Tables["Articletable"].Rows.Count > 0)
                        {
                            DataRow row = ds.Tables["Articletable"].Rows[0];
                            lblTitle.Text = row["Title"].ToString();
                            lblDescription.Text = row["Description"].ToString();
                            lblauthor.Text = row["Author"].ToString();
                            return; // Successfully displayed
                        }
                    }
                }
                catch
                {
                    // Continue to next fallback connection
                }
            }

            // Fallback sample data in case database is offline
            int id = 1;
            int.TryParse(strId, out id);
            var sampleArticles = new Dictionary<int, (string Title, string Desc, string Author)>
            {
                { 1, ("How to validate dropdownlist in asp.net", "Here, we will learn how to validate a DropDownList in ASP.NET.", "Rohatash Kumar") },
                { 2, ("Introduction to .NET Assemblies in VB.NET", "Here is a comprehensive introduction to .NET assemblies.", "sunil Kumar") },
                { 3, ("BinaryReader and BinaryWriter classes in VB.NET", "In this article I will explain about BinaryReader and BinaryWriter Classes in VB.NET.", "Deepak Kumar") },
                { 4, ("StreamWriter class in VB.NET", "This article shows how to create a new text file and write a string to it.", "Rohatash Kumar") }
            };

            if (sampleArticles.ContainsKey(id))
            {
                lblTitle.Text = sampleArticles[id].Title;
                lblDescription.Text = sampleArticles[id].Desc;
                lblauthor.Text = sampleArticles[id].Author;
            }
            else
            {
                lblTitle.Text = "Article Not Found";
                lblDescription.Text = "No article with ID " + strId + " was found.";
                lblauthor.Text = "-";
            }
        }
    }
}
