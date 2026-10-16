using System;
using System.Configuration;
using System.Data.SqlClient;
using System.IO;
using System.Text.RegularExpressions;
using System.Web;

namespace GridViewDemo.DataAccess
{
    public static class DatabaseHelper
    {
        public static void ResetDatabase()
        {
            string scriptPath = HttpContext.Current.Server.MapPath("~/App_Data/GridViewDB_Setup.sql");
            if (!File.Exists(scriptPath))
            {
                throw new FileNotFoundException("Setup script not found at " + scriptPath);
            }

            string script = File.ReadAllText(scriptPath);
            string connectionString = ConfigurationManager.ConnectionStrings["constr"].ConnectionString;

            // Split by GO statements
            string[] commands = Regex.Split(script, @"^\s*GO\s*$", RegexOptions.Multiline | RegexOptions.IgnoreCase);

            using (SqlConnection con = new SqlConnection(connectionString))
            {
                con.Open();
                foreach (string commandText in commands)
                {
                    string trimmed = commandText.Trim();
                    if (string.IsNullOrWhiteSpace(trimmed)) continue;

                    // Remove USE statement as connection string already specifies DB
                    if (trimmed.StartsWith("USE ", StringComparison.OrdinalIgnoreCase)) continue;

                    using (SqlCommand cmd = new SqlCommand(trimmed, con))
                    {
                        cmd.ExecuteNonQuery();
                    }
                }
            }
        }
    }
}
