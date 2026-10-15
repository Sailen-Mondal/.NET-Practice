using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.Services;
using System.Xml;

namespace WebServices
{
    /// <summary>
    /// Classical SOAP/XML Web Service demonstration.
    /// Exposes methods returning XmlElement over SOAP and HTTP protocols.
    /// </summary>
    [WebService(Namespace = "http://tempuri.org/")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    [System.ComponentModel.ToolboxItem(false)]
    public class UserService : System.Web.Services.WebService
    {
        private readonly string connectionString = ConfigurationManager.ConnectionStrings["dbconnection"].ConnectionString;

        /// <summary>
        /// Retrieves user details by username prefix and returns the result as an XmlElement.
        /// Demonstrates XML-based communication between incompatible systems over HTTP.
        /// </summary>
        /// <param name="userName">Prefix of username to match (empty returns all)</param>
        /// <returns>XmlElement containing serialized DataSet rows</returns>
        [WebMethod(Description = "Retrieves user details matching the given username prefix as an XmlElement.")]
        public XmlElement GetUserDetails(string userName)
        {
            using (SqlConnection con = new SqlConnection(connectionString))
            {
                con.Open();
                string query = "SELECT userID, UserName, FirstName, LastName, Location FROM UserInformation WHERE UserName LIKE @userName + '%'";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@userName", string.IsNullOrWhiteSpace(userName) ? string.Empty : userName.Trim());
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataSet ds = new DataSet("UserResults");
                        da.Fill(ds, "User");

                        // If no records found, return null or empty element
                        if (ds.Tables["User"].Rows.Count == 0)
                        {
                            return null;
                        }

                        XmlDocument xmlDoc = new XmlDocument();
                        xmlDoc.LoadXml(ds.GetXml());
                        return xmlDoc.DocumentElement;
                    }
                }
            }
        }

        /// <summary>
        /// Helper method to return all users from the UserInformation table.
        /// </summary>
        [WebMethod(Description = "Returns all users in the UserInformation table as an XmlElement.")]
        public XmlElement GetAllUsers()
        {
            return GetUserDetails(string.Empty);
        }
    }
}
