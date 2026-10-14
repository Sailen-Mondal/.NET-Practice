using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Optimization;
using System.Web.Routing;
using System.Web.Security;
using System.Web.SessionState;

namespace URLRouting
{
    public class Global : HttpApplication
    {
        void Application_Start(object sender, EventArgs e)
        {
            // Code that runs on application startup
            // Step 1: Register our URL routing definitions into RouteTable.Routes
            RouteConfig.RegisterRoutes(RouteTable.Routes);

            // Register script and style bundles
            BundleConfig.RegisterBundles(BundleTable.Bundles);
        }
    }
}