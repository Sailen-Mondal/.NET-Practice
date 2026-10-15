using System;
using System.Data;
using System.Web.UI;
using System.Xml;

namespace WebServices
{
    public partial class UserDirectory : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindUserDetails(string.Empty);
            }
        }

        /// <summary>
        /// Consumes the UserService ASMX Web Service.
        /// Receives an XmlElement, loads it via XmlNodeReader into a DataSet,
        /// and binds it to gvUserDetails.
        /// </summary>
        /// <param name="userName">Prefix of username to filter by</param>
        protected void BindUserDetails(string userName)
        {
            try
            {
                // Instantiate the Web Service
                UserService service = new UserService();
                XmlElement exelement = service.GetUserDetails(userName);

                if (exelement != null)
                {
                    DataSet dsresult = new DataSet();
                    using (XmlNodeReader nodereader = new XmlNodeReader(exelement))
                    {
                        dsresult.ReadXml(nodereader, XmlReadMode.Auto);
                    }

                    gvUserDetails.DataSource = dsresult;
                    gvUserDetails.DataBind();

                    int count = dsresult.Tables.Count > 0 ? dsresult.Tables[0].Rows.Count : 0;
                    litCount.Text = $"{count} record(s) found";
                }
                else
                {
                    gvUserDetails.DataSource = null;
                    gvUserDetails.DataBind();
                    litCount.Text = "0 records found";
                }
            }
            catch (Exception ex)
            {
                litCount.Text = "Error communicating with Web Service: " + ex.Message;
                gvUserDetails.DataSource = null;
                gvUserDetails.DataBind();
            }
        }

        protected void btnSubmit_Click(object sender, EventArgs e)
        {
            BindUserDetails(txtUserName.Text.Trim());
        }

        protected void btnReset_Click(object sender, EventArgs e)
        {
            txtUserName.Text = string.Empty;
            BindUserDetails(string.Empty);
        }
    }
}
