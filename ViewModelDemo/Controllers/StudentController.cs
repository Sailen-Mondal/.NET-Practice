using System.Collections.Generic;
using System.Web.Mvc;
using ViewModelDemo.Data;
using ViewModelDemo.Models;
using ViewModelDemo.ViewModels;

namespace ViewModelDemo.Controllers
{
    public class StudentController : Controller
    {
        private UserSession GetCurrentUser()
        {
            return Session["CurrentUser"] as UserSession;
        }

        // GET: /Student/Index
        public ActionResult Index()
        {
            List<Student> studs = DatabaseHelper.GetStudents();
            ViewBag.CurrentUser = GetCurrentUser();
            return View(studs);
        }

        // GET: /Student/getStud
        public ActionResult getStud()
        {
            List<Student> studs = DatabaseHelper.GetStudents();
            List<vmStudMarks> vmSt = new List<vmStudMarks>();

            foreach (Student stud in studs)
            {
                vmStudMarks vm = new vmStudMarks
                {
                    RollNo = stud.RollNo,
                    Name = stud.Name,
                    Marks = stud.Marks.ToString(),
                    colorname = stud.Marks > 35 ? "green" : "red"
                };

                vmSt.Add(vm);
            }

            ViewBag.CurrentUser = GetCurrentUser();
            return View("getStud", vmSt);
        }
    }
}
