using System;
using System.Collections.Generic;
using System.Web;
using System.Web.Routing;
using Microsoft.AspNet.FriendlyUrls;

namespace URLRouting
{
    public static class RouteConfig
    {
        public static void RegisterRoutes(RouteCollection routes)
        {
            // =========================================================================
            // URL ROUTING DEFINITIONS:
            // -------------------------------------------------------------------------
            // MapPageRoute takes:
            // 1. routeName: Unique name for this route
            // 2. routeUrl: The URL pattern to match
            // 3. physicalFile: The Web Form that will process the request
            // =========================================================================

            // Route 1: Articles with ID and SEO Title (e.g. /Articles/1/How-to-validate-dropdownlist)
            routes.MapPageRoute(
                "RouteForArticle",
                "Articles/{id}/{Title}",
                "~/DetailPage.aspx"
            );

            // Route 2: Fallback route for ID only (e.g. /Articles/1)
            routes.MapPageRoute(
                "RouteForArticleById",
                "Articles/{id}",
                "~/DetailPage.aspx"
            );

            // FriendlyUrls configuration (Set AutoRedirectMode to Off so both .aspx and routed URLs work)
            var settings = new FriendlyUrlSettings();
            settings.AutoRedirectMode = RedirectMode.Off;
            routes.EnableFriendlyUrls(settings);
        }
    }
}
