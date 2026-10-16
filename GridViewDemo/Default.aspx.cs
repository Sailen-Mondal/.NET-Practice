using System;
using System.Web.UI;
using GridViewDemo.DataAccess;

namespace GridViewDemo
{
    public partial class _Default : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
        }

        protected void btnResetDB_Click(object sender, EventArgs e)
        {
            try
            {
                DatabaseHelper.ResetDatabase();
                lblAlertMessage.Text = "Database reset successfully! All tables and sample records have been restored.";
                pnlAlert.Visible = true;
            }
            catch (Exception ex)
            {
                lblAlertMessage.Text = "Database reset failed: " + ex.Message;
                lblAlertMessage.ForeColor = System.Drawing.Color.Red;
                pnlAlert.Visible = true;
            }
        }
    }
}