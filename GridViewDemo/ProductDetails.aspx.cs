using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;

namespace GridViewDemo
{
    public partial class ProductDetails : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                string productId = Request.QueryString["ID"];
                if (string.IsNullOrEmpty(productId))
                {
                    Response.Redirect("Products.aspx");
                    return;
                }

                string cs = ConfigurationManager.ConnectionStrings["CS"].ConnectionString;
                using (SqlConnection con = new SqlConnection(cs))
                {
                    SqlCommand cmd = new SqlCommand("spGetProductDetailsByID", con);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add(new SqlParameter("@ID", productId));
                    con.Open();

                    using (SqlDataReader rdr = cmd.ExecuteReader())
                    {
                        if (rdr.Read())
                        {
                            lblID.Text = rdr["ID"].ToString();
                            lblName.Text = rdr["Name"].ToString();
                            lblNameHeader.Text = rdr["Name"].ToString();
                            lblPrice.Text = rdr["Price"].ToString();
                            lblColor.Text = rdr["Color"] != DBNull.Value ? rdr["Color"].ToString() : "N/A";
                            lblSize.Text = rdr["Size"] != DBNull.Value ? rdr["Size"].ToString() : "N/A";
                            lblWeight.Text = rdr["Weight"] != DBNull.Value ? rdr["Weight"].ToString() : "0";
                            lblQuantityInStock.Text = rdr["QuantityInStock"] != DBNull.Value ? rdr["QuantityInStock"].ToString() : "0";
                            
                            bool discontinued = rdr["Discontinued"] != DBNull.Value && Convert.ToBoolean(rdr["Discontinued"]);
                            if (discontinued)
                            {
                                lblDiscontinued.Text = "<span class='notion-tag notion-tag-alert'>Discontinued</span>";
                            }
                            else
                            {
                                lblDiscontinued.Text = "<span class='notion-tag notion-tag-it'>Active in Stock</span>";
                            }

                            lblSupplier.Text = rdr["Supplier"] != DBNull.Value ? rdr["Supplier"].ToString() : "N/A";
                        }
                        else
                        {
                            Response.Redirect("Products.aspx");
                        }
                    }
                }
            }
        }
    }
}
