using System;

namespace UpdatePannel
{
    public partial class About : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e) { }

        // btnSave_Click: simulates a slow server operation (2 sec)
        // Only UpdatePanel1's ContentTemplate re-renders — page does NOT flicker
        protected void btnSave_Click(object sender, EventArgs e)
        {
            System.Threading.Thread.Sleep(2000); // simulate slow work
            lblResult.Text = "Record saved! Server time: " + DateTime.Now.ToLongTimeString();
        }
    }
}