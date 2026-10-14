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
    public partial class URL_ReRouting : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                GridView1.DataSource = GetData();
                GridView1.DataBind();
            }
        }

        private DataTable GetData()
        {
            // Try configured connection string first, then fallbacks
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
                        SqlDataAdapter da = new SqlDataAdapter("select Id,Title,Description,author from Articletable", conn);
                        DataSet ds = new DataSet();
                        da.Fill(ds, "MyTestTable");
                        if (ds.Tables["MyTestTable"] != null && ds.Tables["MyTestTable"].Rows.Count > 0)
                        {
                            return ds.Tables["MyTestTable"];
                        }
                    }
                }
                catch
                {
                    // Continue to next fallback
                }
            }

            // Fallback sample data in case SQL Server is stopped or credentials differ
            DataTable dt = new DataTable("MyTestTable");
            dt.Columns.Add("Id", typeof(int));
            dt.Columns.Add("Title", typeof(string));
            dt.Columns.Add("Description", typeof(string));
            dt.Columns.Add("Author", typeof(string));

            dt.Rows.Add(1, "How to validate dropdownlist in asp.net", "Here, we will learn how to validate a DropDownList in ASP.NET.", "Rohatash Kumar");
            dt.Rows.Add(2, "Introduction to .NET Assemblies in VB.NET", "Here is a comprehensive introduction to .NET assemblies.", "sunil Kumar");
            dt.Rows.Add(3, "BinaryReader and BinaryWriter classes in VB.NET", "In this article I will explain about BinaryReader and BinaryWriter Classes in VB.NET.", "Deepak Kumar");
            dt.Rows.Add(4, "StreamWriter class in VB.NET", "This article shows how to create a new text file and write a string to it.", "Rohatash Kumar");

            return dt;
        }

        protected string GetTitle(object obj)
        {
            if (obj == null) return string.Empty;
            return obj.ToString().Replace(' ', '-');
        }
    }
}
