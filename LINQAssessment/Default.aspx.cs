using System;
using System.Collections.Generic;
using System.Web.UI;
using LINQAssessment.Models;
using LINQAssessment.Services;

namespace LINQAssessment
{
    public partial class _Default : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                RunAndBindAssessmentTasks();
            }
        }

        protected void btnExecuteTasks_Click(object sender, EventArgs e)
        {
            RunAndBindAssessmentTasks();
            lblStatus.Text = "Executed at " + DateTime.Now.ToString("HH:mm:ss");
        }

        private void RunAndBindAssessmentTasks()
        {
            // 1. Retrieve realistic sample data
            List<Student> students = MockData.GetStudents();
            List<GraphNode> graphNodes = MockData.GetGraphNodes();
            List<Course> enrolledCourses = MockData.GetEnrolledCourses();

            // 2. Execute Task 1: Group enrolled students by department and count
            var departmentCounts = LinqAssessmentService.GetEnrolledStudentCountByDepartment(students);
            gvDepartmentCounts.DataSource = departmentCounts;
            gvDepartmentCounts.DataBind();

            // 3. Execute Task 2: Find graph nodes with degree > 3
            var highDegreeNodes = LinqAssessmentService.GetHighDegreeNodes(graphNodes, 3);
            gvHighDegreeNodes.DataSource = highDegreeNodes;
            gvHighDegreeNodes.DataBind();

            // 4. Execute Task 3: Extract unique flat prerequisites
            var uniquePrerequisites = LinqAssessmentService.GetUniquePrerequisites(enrolledCourses);
            gvPrerequisites.DataSource = uniquePrerequisites;
            gvPrerequisites.DataBind();

            // 5. Populate formatted terminal output
            litTerminalOutput.Text = LinqAssessmentService.GenerateConsoleOutput(students, graphNodes, enrolledCourses);
        }
    }
}
