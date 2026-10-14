using System;

namespace UpdatePannel
{
    public partial class Contact : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e) { }

        // Fires from btnBoth — updates both panels
        // Panel 2 updates because btnBoth is in its AsyncPostBackTrigger
        protected void btnBoth_Click(object sender, EventArgs e)
        {
            lbl1.Text = "Panel 1 time: " + DateTime.Now.ToLongTimeString();
            lbl2.Text = "Panel 2 time: " + DateTime.Now.ToLongTimeString();
        }

        // Fires from btnThis — only Panel 1 updates
        // Panel 2 has no trigger for this button, so it stays unchanged
        protected void btnThis_Click(object sender, EventArgs e)
        {
            lbl1.Text = "Panel 1 time: " + DateTime.Now.ToLongTimeString();
            lbl2.Text = "Panel 2 time: " + DateTime.Now.ToLongTimeString(); // set but NOT re-rendered
        }
    }
}