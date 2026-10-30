using System.Collections.Generic;
using System.Web.Mvc;
using ViewModelDemo.Data;
using ViewModelDemo.Models;
using ViewModelDemo.ViewModels;

namespace ViewModelDemo.Controllers
{
    public class EmployeeController : Controller
    {
        private UserSession GetCurrentUser()
        {
            return Session["CurrentUser"] as UserSession;
        }

        // GET: /Employee/Index (Employee Directory Table)
        public ActionResult Index(string search)
        {
            UserSession user = GetCurrentUser();
            if (user == null)
            {
                TempData["InfoMessage"] = "Please sign in to access the employee directory.";
                return RedirectToAction("Login", "Account", new { returnUrl = "/Employee/Index" });
            }

            List<EmployeeListItemViewModel> employees = DatabaseHelper.GetAllEmployees(search);
            ViewBag.SearchTerm = search;
            ViewBag.CurrentUser = user;
            return View(employees);
        }

        // GET: /Employee/Details/101
        public ActionResult Details(int id = 101)
        {
            UserSession user = GetCurrentUser();
            if (user == null)
            {
                TempData["InfoMessage"] = "Please sign in to view employee details.";
                return RedirectToAction("Login", "Account", new { returnUrl = "/Employee/Details/" + id });
            }

            var data = DatabaseHelper.GetEmployeeWithAddress(id);
            Employee employee = data.employee;
            Address address = data.address;

            EmployeeDetailsViewModel employeeDetailsViewModel = new EmployeeDetailsViewModel
            {
                Employee = employee,
                Address = address,
                PageTitle = "Employee Details Page",
                PageHeader = "Employee Details"
            };

            ViewBag.CurrentUser = user;
            return View(employeeDetailsViewModel);
        }

        // GET: /Employee/Create
        [HttpGet]
        public ActionResult Create()
        {
            UserSession user = GetCurrentUser();
            if (user == null || !user.IsAdmin)
            {
                TempData["ErrorMessage"] = "Only Administrators can add new employees.";
                return RedirectToAction("Login", "Account", new { returnUrl = Request.RawUrl });
            }

            EmployeeFormViewModel model = new EmployeeFormViewModel();
            return View(model);
        }

        // POST: /Employee/Create
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Create(EmployeeFormViewModel model)
        {
            UserSession user = GetCurrentUser();
            if (user == null || !user.IsAdmin)
            {
                TempData["ErrorMessage"] = "Unauthorized. Administrator rights required.";
                return RedirectToAction("Login", "Account");
            }

            if (!ModelState.IsValid)
            {
                return View(model);
            }

            try
            {
                bool success = DatabaseHelper.SaveEmployee(model);
                if (success)
                {
                    TempData["SuccessMessage"] = "Employee " + model.Name + " was created successfully.";
                    return RedirectToAction("Index");
                }
            }
            catch (System.Exception ex)
            {
                ModelState.AddModelError("", "Database error saving employee: " + ex.Message);
            }

            return View(model);
        }

        // GET: /Employee/Edit/101
        [HttpGet]
        public ActionResult Edit(int id)
        {
            UserSession user = GetCurrentUser();
            if (user == null || !user.IsAdmin)
            {
                TempData["ErrorMessage"] = "Only Administrators can modify employee records.";
                return RedirectToAction("Login", "Account", new { returnUrl = Request.RawUrl });
            }

            EmployeeFormViewModel model = DatabaseHelper.GetEmployeeForEdit(id);
            if (model == null)
            {
                TempData["ErrorMessage"] = "Employee not found.";
                return RedirectToAction("Index");
            }

            return View(model);
        }

        // POST: /Employee/Edit/101
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Edit(EmployeeFormViewModel model)
        {
            UserSession user = GetCurrentUser();
            if (user == null || !user.IsAdmin)
            {
                TempData["ErrorMessage"] = "Unauthorized. Administrator rights required.";
                return RedirectToAction("Login", "Account");
            }

            if (!ModelState.IsValid)
            {
                return View(model);
            }

            try
            {
                bool success = DatabaseHelper.SaveEmployee(model);
                if (success)
                {
                    TempData["SuccessMessage"] = "Employee " + model.Name + " was updated successfully.";
                    return RedirectToAction("Index");
                }
            }
            catch (System.Exception ex)
            {
                ModelState.AddModelError("", "Database error updating employee: " + ex.Message);
            }

            return View(model);
        }

        // GET: /Employee/Delete/101
        [HttpGet]
        public ActionResult Delete(int id)
        {
            UserSession user = GetCurrentUser();
            if (user == null || !user.IsAdmin)
            {
                TempData["ErrorMessage"] = "Only Administrators can delete employee records.";
                return RedirectToAction("Login", "Account", new { returnUrl = Request.RawUrl });
            }

            EmployeeFormViewModel model = DatabaseHelper.GetEmployeeForEdit(id);
            if (model == null)
            {
                TempData["ErrorMessage"] = "Employee not found.";
                return RedirectToAction("Index");
            }

            return View(model);
        }

        // POST: /Employee/Delete/101
        [HttpPost]
        [ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public ActionResult DeleteConfirmed(int id)
        {
            UserSession user = GetCurrentUser();
            if (user == null || !user.IsAdmin)
            {
                TempData["ErrorMessage"] = "Unauthorized. Administrator rights required.";
                return RedirectToAction("Login", "Account");
            }

            try
            {
                bool success = DatabaseHelper.DeleteEmployee(id);
                if (success)
                {
                    TempData["SuccessMessage"] = "Employee #" + id + " was deleted successfully.";
                }
                else
                {
                    TempData["ErrorMessage"] = "Could not delete employee.";
                }
            }
            catch (System.Exception ex)
            {
                TempData["ErrorMessage"] = "Error deleting employee: " + ex.Message;
            }

            return RedirectToAction("Index");
        }
    }
}
