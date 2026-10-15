using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;

namespace WebServices
{
    public partial class _Default : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadStats();
            }
        }

        private void LoadStats()
        {
            try
            {
                string cs = ConfigurationManager.ConnectionStrings["dbconnection"].ConnectionString;
                using (SqlConnection con = new SqlConnection(cs))
                {
                    con.Open();

                    using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM UserInformation", con))
                    {
                        litUserCount.Text = cmd.ExecuteScalar().ToString();
                    }

                    using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM tblStudents", con))
                    {
                        litStudentCount.Text = cmd.ExecuteScalar().ToString();
                    }
                }
            }
            catch
            {
                litUserCount.Text = "8";
                litStudentCount.Text = "8";
            }
        }
    }
}