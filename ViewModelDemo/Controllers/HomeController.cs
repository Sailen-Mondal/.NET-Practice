using System.Web.Mvc;
using ViewModelDemo.Models;

namespace ViewModelDemo.Controllers
{
    public class HomeController : Controller
    {
        // GET: / (Landing Page)
        public ActionResult Index()
        {
            ViewBag.CurrentUser = Session["CurrentUser"] as UserSession;
            return View();
        }
    }
}
