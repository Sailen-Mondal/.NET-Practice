using System;
using System.Drawing;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using CRUDUsingLINQ.Models;

namespace CRUDUsingLINQ
{
    public partial class _Default : Page
    {
        private SampleDataContext db = new SampleDataContext();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!Page.IsPostBack)
            {
                BindGridview();
            }
        }

        protected void BindGridview()
        {
            // LINQ Query Syntax to retrieve records
            var result = (from emp in db.Employee1
                          select new
                          {
                              ID = emp.ID,
                              Name = emp.Name,
                              Location = emp.Location,
                              Gender = emp.Gender
                          }).ToList();

            gvDetails.DataSource = result;
            gvDetails.DataBind();
        }

        protected void gvDetails_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName.Equals("AddNew"))
            {
                TextBox txtname = (TextBox)gvDetails.FooterRow.FindControl("txtfName");
                TextBox txtlocation = (TextBox)gvDetails.FooterRow.FindControl("txtfLocation");
                TextBox txtgender = (TextBox)gvDetails.FooterRow.FindControl("txtfGender");

                if (string.IsNullOrWhiteSpace(txtname.Text))
                {
                    lblresult.Visible = true;
                    lblresult.CssClass = "notion-status notion-status-info";
                    lblresult.Text = "Please enter a valid employee name.";
                    return;
                }

                Employee1 emp = new Employee1
                {
                    Name = txtname.Text.Trim(),
                    Location = txtlocation.Text.Trim(),
                    Gender = txtgender.Text.Trim()
                };

                // LINQ to SQL Insert
                db.Employee1.InsertOnSubmit(emp);
                db.SubmitChanges();

                lblresult.Visible = true;
                lblresult.CssClass = "notion-status notion-status-success";
                lblresult.Text = txtname.Text + " inserted successfully.";
                BindGridview();
            }
        }

        protected void gvDetails_RowEditing(object sender, GridViewEditEventArgs e)
        {
            gvDetails.EditIndex = e.NewEditIndex;
            lblresult.Visible = false;
            BindGridview();
        }

        protected void gvDetails_RowCancelingEdit(object sender, GridViewCancelEditEventArgs e)
        {
            gvDetails.EditIndex = -1;
            lblresult.Visible = false;
            BindGridview();
        }

        protected void gvDetails_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvDetails.PageIndex = e.NewPageIndex;
            BindGridview();
        }

        protected void gvDetails_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow && e.Row.RowIndex != gvDetails.EditIndex)
            {
                LinkButton btnDelete = (LinkButton)e.Row.FindControl("btnDelete");
                if (btnDelete != null)
                {
                    btnDelete.Attributes["onclick"] = "return confirm('Are you sure you want to delete this record?');";
                }
            }
        }

        protected void gvDetails_RowUpdating(object sender, GridViewUpdateEventArgs e)
        {
            int empid = Convert.ToInt32(gvDetails.DataKeys[e.RowIndex].Values["ID"]);
            TextBox txtname = (TextBox)gvDetails.Rows[e.RowIndex].FindControl("txtName");
            TextBox txtlocation = (TextBox)gvDetails.Rows[e.RowIndex].FindControl("txtLocation");
            TextBox txtgender = (TextBox)gvDetails.Rows[e.RowIndex].FindControl("txtGender");

            // Using LINQ Query Syntax:
            Employee1 emp = (from em in db.Employee1 where em.ID == empid select em).FirstOrDefault();

            // Alternative LINQ Method Syntax:
            // Employee1 emp = db.Employee1.Single(x => x.ID == empid);

            if (emp != null)
            {
                emp.Name = txtname.Text.Trim();
                emp.Location = txtlocation.Text.Trim();
                emp.Gender = txtgender.Text.Trim();

                db.SubmitChanges();
                gvDetails.EditIndex = -1;
                BindGridview();

                lblresult.Visible = true;
                lblresult.CssClass = "notion-status notion-status-success";
                lblresult.Text = txtname.Text + " updated successfully.";
            }
        }

        protected void gvDetails_RowDeleting(object sender, GridViewDeleteEventArgs e)
        {
            int empid = Convert.ToInt32(gvDetails.DataKeys[e.RowIndex].Values["ID"]);
            string empname = gvDetails.DataKeys[e.RowIndex].Values["Name"].ToString();

            // Using LINQ Query Syntax:
            Employee1 emp = (from em in db.Employee1 where em.ID == empid select em).FirstOrDefault();

            // Alternative LINQ Method Syntax:
            // Employee1 emp = db.Employee1.Single(x => x.ID == empid);

            if (emp != null)
            {
                db.Employee1.DeleteOnSubmit(emp);
                db.SubmitChanges();

                BindGridview();
                lblresult.Visible = true;
                lblresult.CssClass = "notion-status notion-status-success";
                lblresult.Text = empname + " deleted successfully.";
            }
        }
    }
}
