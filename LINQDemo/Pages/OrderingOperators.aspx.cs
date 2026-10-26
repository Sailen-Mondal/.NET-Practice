using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI;
using LINQDemo.Models;

namespace LINQDemo.Pages
{
    public partial class OrderingOperators : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // Display the original unaltered dataset on initial load
                gvOriginalStudents.DataSource = Student.GetAllStudents();
                gvOriginalStudents.DataBind();
            }
        }

        /// <summary>
        /// Example 1: Sort by Name ascending using Method Syntax.
        /// </summary>
        protected void btnOrderAscMethod_Click(object sender, EventArgs e)
        {
            // OrderBy extension method sorts items in ascending order based on the key selector lambda
            IEnumerable<Student> result = Student.GetAllStudents().OrderBy(s => s.Name);

            gvAscStudents.DataSource = result;
            gvAscStudents.DataBind();
            pnlAscResult.Visible = true;
        }

        /// <summary>
        /// Example 2: Sort by Name ascending using SQL-like Query Syntax.
        /// </summary>
        protected void btnOrderAscQuery_Click(object sender, EventArgs e)
        {
            // SQL-like syntax uses the 'orderby' keyword (defaults to ascending)
            IEnumerable<Student> result = from student in Student.GetAllStudents()
                                          orderby student.Name
                                          select student;

            gvAscStudents.DataSource = result;
            gvAscStudents.DataBind();
            pnlAscResult.Visible = true;
        }

        /// <summary>
        /// Example 3: Sort by Name descending using Method Syntax.
        /// </summary>
        protected void btnOrderDescMethod_Click(object sender, EventArgs e)
        {
            // OrderByDescending sorts items from largest to smallest (Z to A)
            IEnumerable<Student> result = Student.GetAllStudents().OrderByDescending(s => s.Name);

            gvDescStudents.DataSource = result;
            gvDescStudents.DataBind();
            pnlDescResult.Visible = true;
        }

        /// <summary>
        /// Example 4: Sort by Name descending using SQL-like Query Syntax.
        /// </summary>
        protected void btnOrderDescQuery_Click(object sender, EventArgs e)
        {
            // Query syntax specifies 'descending' after the ordering property
            IEnumerable<Student> result = from student in Student.GetAllStudents()
                                          orderby student.Name descending
                                          select student;

            gvDescStudents.DataSource = result;
            gvDescStudents.DataBind();
            pnlDescResult.Visible = true;
        }

        /// <summary>
        /// Example 5: Multi-level sorting with ThenBy.
        /// </summary>
        protected void btnThenBy_Click(object sender, EventArgs e)
        {
            // OrderBy sorts primarily by TotalMarks; ThenBy breaks ties by sorting on Name ascending
            var result = Student.GetAllStudents()
                .OrderBy(s => s.TotalMarks)
                .ThenBy(s => s.Name);

            lblSpecialTitle.Text = "Multi-Level Sort: TotalMarks ASC, then Name ASC (Notice students with 800 marks are alphabetized):";
            gvSpecialStudents.DataSource = result;
            gvSpecialStudents.DataBind();
            pnlSpecialResult.Visible = true;
        }

        /// <summary>
        /// Example 6: Reverse operator inverts collection items.
        /// </summary>
        protected void btnReverse_Click(object sender, EventArgs e)
        {
            // Reverse inverts the position of all items in the sequence
            List<Student> list = Student.GetAllStudents();
            list.Reverse();

            lblSpecialTitle.Text = "Reverse Operator Result (Order inverted from original):";
            gvSpecialStudents.DataSource = list;
            gvSpecialStudents.DataBind();
            pnlSpecialResult.Visible = true;
        }
    }
}
