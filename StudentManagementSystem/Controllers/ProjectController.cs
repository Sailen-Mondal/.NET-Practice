using System;
using System.Web.Mvc;
using StudentManagementSystem.Models;

namespace StudentManagementSystem.Controllers
{
    // Controller orchestrating full CRUD operations for Project entities.
    // Encapsulates presentation logic while delegating persistence to ProjectDataAccess.
    public class ProjectController : Controller
    {
        private readonly ProjectDataAccess dataAccess = new ProjectDataAccess();

        // GET: /Project
        public ActionResult Index(string search, string status)
        {
            var projects = dataAccess.GetAllProjects(search, status);
            var metrics = dataAccess.GetProjectMetrics();

            var viewModel = new ProjectIndexViewModel
            {
                Projects = projects,
                Metrics = metrics,
                SearchTerm = search,
                SelectedStatus = string.IsNullOrWhiteSpace(status) ? "All" : status
            };

            return View(viewModel);
        }

        // GET: /Project/Details/5
        public ActionResult Details(int? id)
        {
            if (!id.HasValue)
            {
                return RedirectToAction("Index");
            }

            var project = dataAccess.GetProjectById(id.Value);
            if (project == null)
            {
                return HttpNotFound("Project not found.");
            }

            return View(project);
        }

        // GET: /Project/Create
        public ActionResult Create()
        {
            var project = new Project
            {
                StartDate = DateTime.Today,
                Status = "Planning",
                Priority = "Medium",
                Category = "Web App"
            };
            return View(project);
        }

        // POST: /Project/Create
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Create(Project project)
        {
            if (ModelState.IsValid)
            {
                try
                {
                    int newId = dataAccess.InsertProject(project);
                    TempData["SuccessMessage"] = $"Project #{newId} '{project.Title}' created successfully.";
                    return RedirectToAction("Index");
                }
                catch (Exception ex)
                {
                    ModelState.AddModelError("", "Database error while creating project: " + ex.Message);
                }
            }

            return View(project);
        }

        // GET: /Project/Edit/5
        public ActionResult Edit(int? id)
        {
            if (!id.HasValue)
            {
                return RedirectToAction("Index");
            }

            var project = dataAccess.GetProjectById(id.Value);
            if (project == null)
            {
                return HttpNotFound("Project not found.");
            }

            return View(project);
        }

        // POST: /Project/Edit/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Edit(Project project)
        {
            if (ModelState.IsValid)
            {
                try
                {
                    bool updated = dataAccess.UpdateProject(project);
                    if (updated)
                    {
                        TempData["SuccessMessage"] = $"Project #{project.ProjectID} updated successfully.";
                        return RedirectToAction("Index");
                    }
                    else
                    {
                        ModelState.AddModelError("", "Project was not found or could not be updated.");
                    }
                }
                catch (Exception ex)
                {
                    ModelState.AddModelError("", "Database error while updating project: " + ex.Message);
                }
            }

            return View(project);
        }

        // GET: /Project/Delete/5
        public ActionResult Delete(int? id)
        {
            if (!id.HasValue)
            {
                return RedirectToAction("Index");
            }

            var project = dataAccess.GetProjectById(id.Value);
            if (project == null)
            {
                return HttpNotFound("Project not found.");
            }

            return View(project);
        }

        // POST: /Project/Delete/5
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public ActionResult DeleteConfirmed(int id)
        {
            try
            {
                bool deleted = dataAccess.DeleteProject(id);
                if (deleted)
                {
                    TempData["SuccessMessage"] = $"Project #{id} was successfully deleted.";
                }
                else
                {
                    TempData["ErrorMessage"] = $"Project #{id} could not be deleted.";
                }
            }
            catch (Exception ex)
            {
                TempData["ErrorMessage"] = "Database error while deleting project: " + ex.Message;
            }

            return RedirectToAction("Index");
        }
    }
}
