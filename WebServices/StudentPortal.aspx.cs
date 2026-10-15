using System;
using System.Web.UI;

namespace WebServices
{
    public partial class StudentPortal : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // Set the page render timestamp.
                // In an AJAX-enabled page, this timestamp remains constant because
                // JavaScript calls to StudentService do not cause a full page postback.
                lblPageTime.Text = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss.fff");

                LoadStudentReferenceList();
            }
        }

        private void LoadStudentReferenceList()
        {
            try
            {
                StudentService service = new StudentService();
                gvStudentList.DataSource = service.GetAllStudents();
                gvStudentList.DataBind();
            }
            catch (Exception ex)
            {
                lblPageTime.Text += $" (List load error: {ex.Message})";
            }
        }
    }
}
