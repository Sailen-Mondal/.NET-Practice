using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Optimization;
using System.Web.Routing;
using System.Web.Security;
using System.Web.SessionState;

namespace WebApplication1
{
    public class Global : HttpApplication
    {
        // Runs when the application starts
        void Application_Start(object sender, EventArgs e)
        {
            // Existing application configuration
            RouteConfig.RegisterRoutes(RouteTable.Routes);
            BundleConfig.RegisterBundles(BundleTable.Bundles);

            // Initialize online user count
            Application["OnlineUsers"] = 0;
        }

        // Runs when a new user session starts
        void Session_Start(object sender, EventArgs e)
        {
            Application.Lock();

            try
            {
                Application["OnlineUsers"] =
                    (int)Application["OnlineUsers"] + 1;
            }
            finally
            {
                Application.UnLock();
            }
        }

        // Runs when a session ends
        void Session_End(object sender, EventArgs e)
        {
            Application.Lock();

            try
            {
                Application["OnlineUsers"] =
                    (int)Application["OnlineUsers"] - 1;
            }
            finally
            {
                Application.UnLock();
            }
        }
    }
}
