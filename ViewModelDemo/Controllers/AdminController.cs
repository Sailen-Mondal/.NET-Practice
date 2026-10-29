using System.Collections.Generic;
using System.Web.Mvc;
using ViewModelDemo.Data;
using ViewModelDemo.Models;
using ViewModelDemo.ViewModels;

namespace ViewModelDemo.Controllers
{
    public class AdminController : Controller
    {
        private UserSession GetCurrentUser()
        {
            return Session["CurrentUser"] as UserSession;
        }

        // GET: /Admin/Dashboard
        public ActionResult Dashboard()
        {
            UserSession user = GetCurrentUser();
            if (user == null || !user.IsAdmin)
            {
                TempData["ErrorMessage"] = "Access restricted. Please log in with an Administrator account.";
                return RedirectToAction("Login", "Account", new { returnUrl = Request.RawUrl });
            }

            AdminDashboardViewModel viewModel = DatabaseHelper.GetAdminDashboardData();
            return View(viewModel);
        }

        // GET: /Admin/Users
        public ActionResult Users()
        {
            UserSession user = GetCurrentUser();
            if (user == null || !user.IsAdmin)
            {
                TempData["ErrorMessage"] = "Access restricted. Administrator privileges required.";
                return RedirectToAction("Login", "Account", new { returnUrl = Request.RawUrl });
            }

            List<User> users = DatabaseHelper.GetAllUsers();
            return View(users);
        }
    }
}
