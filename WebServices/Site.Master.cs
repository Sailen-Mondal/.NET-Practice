using System;
using System.Web.UI;
using System.Web.UI.HtmlControls;

namespace WebServices
{
    public partial class SiteMaster : MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            HighlightActiveNav();
        }

        private void HighlightActiveNav()
        {
            string path = Request.AppRelativeCurrentExecutionFilePath.ToLowerInvariant();

            SetNavState(navHome, path == "~/" || path.Contains("default"));
            SetNavState(navUser, path.Contains("userdirectory"));
            SetNavState(navStudent, path.Contains("studentportal"));
            SetNavState(navEndpoints, path.Contains("endpoints"));
            SetNavState(navConcepts, path.Contains("concepts"));
        }

        private void SetNavState(HtmlAnchor anchor, bool isActive)
        {
            if (anchor == null) return;
            if (isActive)
            {
                anchor.Attributes["class"] = "active";
            }
            else
            {
                anchor.Attributes.Remove("class");
            }
        }
    }
}