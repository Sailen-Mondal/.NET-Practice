using System.Web.Mvc;
using ViewModelDemo.Data;
using ViewModelDemo.Models;
using ViewModelDemo.ViewModels;

namespace ViewModelDemo.Controllers
{
    public class AccountController : Controller
    {
        // GET: /Account/Login
        [HttpGet]
        public ActionResult Login(string returnUrl)
        {
            ViewBag.ReturnUrl = returnUrl;
            return View(new LoginViewModel { ReturnUrl = returnUrl });
        }

        // POST: /Account/Login
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Login(LoginViewModel model)
        {
            if (!ModelState.IsValid)
            {
                return View(model);
            }

            UserSession user = DatabaseHelper.ValidateUser(model.UsernameOrEmail, model.Password);
            if (user == null)
            {
                ModelState.AddModelError("", "Invalid username/email or password.");
                return View(model);
            }

            // Store in Session
            Session["CurrentUser"] = user;

            // Route based on role
            if (!string.IsNullOrEmpty(model.ReturnUrl) && Url.IsLocalUrl(model.ReturnUrl))
            {
                return Redirect(model.ReturnUrl);
            }

            if (user.IsAdmin)
            {
                return RedirectToAction("Dashboard", "Admin");
            }

            return RedirectToAction("Index", "Employee");
        }

        // GET: /Account/Register
        [HttpGet]
        public ActionResult Register()
        {
            return View(new RegisterViewModel());
        }

        // POST: /Account/Register
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Register(RegisterViewModel model)
        {
            if (!ModelState.IsValid)
            {
                return View(model);
            }

            var result = DatabaseHelper.RegisterUser(model);
            if (!result.Success)
            {
                ModelState.AddModelError("", result.ErrorMessage);
                return View(model);
            }

            // Automatically log the new user in
            Session["CurrentUser"] = result.Session;
            TempData["SuccessMessage"] = "Registration successful! Welcome to ViewModel Architecture Demo.";

            return RedirectToAction("Index", "Employee");
        }

        // GET: /Account/Logout
        public ActionResult Logout()
        {
            Session.Clear();
            TempData["InfoMessage"] = "You have been logged out safely.";
            return RedirectToAction("Login", "Account");
        }
    }
}
