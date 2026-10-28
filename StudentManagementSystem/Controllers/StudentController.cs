using System.Web.Mvc;
using StudentManagementSystem.Models;

namespace StudentManagementSystem.Controllers
{
    // The Controller handles incoming HTTP requests, interacts with the Model layer,
    // and selects the appropriate View to render the model data.
    public class StudentController : Controller
    {
        private readonly StudentBusinessLayer studentBL = new StudentBusinessLayer();

        // GET: /Student or /Student/Index
        public ActionResult Index()
        {
            var students = studentBL.GetAllStudents();
            return View(students);
        }

        // GET: /Student/Details/2 or /Student/Details?studentId=2
        public ActionResult Details(int? id)
        {
            // Default to student ID 2 as referenced in the presentation
            int studentId = id ?? 2;
            Student studentDetail = studentBL.GetById(studentId);
            return View(studentDetail);
        }
    }
}
