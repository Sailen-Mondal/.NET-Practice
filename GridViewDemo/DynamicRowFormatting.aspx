<%@ Page Title="Dynamic Rows & Highlighting" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="DynamicRowFormatting.aspx.cs" Inherits="GridViewDemo.DynamicRowFormatting" ResponseEncoding="utf-8" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="notion-breadcrumb">
        <a href="Default.aspx">Overview</a> / <span>Topic 04 &amp; 05: Dynamic Rows &amp; Conditional Highlight</span>
    </div>

    <div class="notion-page-header">
        <span class="notion-page-badge">Topic 04 &amp; 05</span>
        <h1 class="notion-page-title">Data-Driven Formatting &amp; Conditional Highlighting</h1>
        <p class="notion-page-desc">
            Use the RowDataBound event to dynamically hide technical columns (CountryCulture) in both Header &amp; DataRow, format salary currencies per culture, and highlight high compensation records (&gt; $70,000).
        </p>
    </div>

    <!-- Concept Callout -->
    <div class="notion-callout">
        <div class="notion-callout-title">RowDataBound Evaluation Mechanics</div>
        <ul style="margin: 4px 0 0 16px; padding: 0;">
            <li><strong>Technical Column Hiding:</strong> Hide <code>e.Row.Cells[4].Visible = false</code> for both <code>DataControlRowType.Header</code> and <code>DataRow</code>.</li>
            <li><strong>Runtime Conditional Styling:</strong> Read <code>DataBinder.Eval(e.Row.DataItem, "AnnualSalary")</code> and if <code>salary &gt; 70000</code>, assign <code>e.Row.BackColor</code> and <code>e.Row.ForeColor</code>.</li>
        </ul>
    </div>

    <!-- Live GridView Card -->
    <div class="notion-card">
        <div class="notion-card-header">
            <h3 class="notion-card-title">Compensation Records</h3>
            <div style="display: flex; gap: 8px; align-items: center;">
                <span class="notion-tag notion-tag-alert">Highlight: Salary &gt; 70,000</span>
                <span class="notion-tag notion-tag-neutral">CountryCulture: Hidden</span>
            </div>
        </div>

        <asp:SqlDataSource ID="SqlDataSource1" runat="server" 
            ConnectionString="<%$ ConnectionStrings:DBConnectionString %>" 
            SelectCommand="SELECT EmployeeId, FirstName, AnnualSalary, Country, CountryCulture FROM [tblEmployee] ORDER BY EmployeeId">
        </asp:SqlDataSource>

        <div class="notion-grid-wrapper">
            <asp:GridView ID="GridView1" runat="server" 
                AutoGenerateColumns="False" 
                DataKeyNames="EmployeeId" 
                DataSourceID="SqlDataSource1" 
                ShowFooter="True"
                CssClass="notion-grid"
                GridLines="None"
                OnRowDataBound="GridView1_RowDataBound">
                <Columns>
                    <asp:BoundField DataField="EmployeeId" HeaderText="Employee ID" InsertVisible="False" ReadOnly="True" />
                    <asp:BoundField DataField="FirstName" HeaderText="First Name" />
                    <asp:BoundField DataField="AnnualSalary" HeaderText="Annual Salary" />
                    <asp:BoundField DataField="Country" HeaderText="Country" />
                    <asp:BoundField DataField="CountryCulture" HeaderText="CountryCulture" />
                </Columns>
            </asp:GridView>
        </div>
    </div>

    <!-- Code Explanation Drawer -->
    <details class="notion-toggle">
        <summary>View RowDataBound C# Implementation</summary>
        <div class="notion-toggle-content">
            <pre class="notion-code-block"><code>protected void GridView1_RowDataBound(object sender, GridViewRowEventArgs e)
{
    // 1. If Header Row: Hide the technical CountryCulture column header
    if (e.Row.RowType == DataControlRowType.Header)
    {
        e.Row.Cells[4].Visible = false;
    }
    // 2. If Data Row: Format salary, hide technical cell, and conditionally highlight
    else if (e.Row.RowType == DataControlRowType.DataRow)
    {
        int salary = Convert.ToInt32(DataBinder.Eval(e.Row.DataItem, "AnnualSalary"));
        string countryCulture = e.Row.Cells[4].Text.Trim();

        e.Row.Cells[4].Visible = false;

        if (!string.IsNullOrEmpty(countryCulture))
        {
            e.Row.Cells[2].Text = string.Format(new CultureInfo(countryCulture), "{0:c}", salary);
        }

        if (salary > 70000)
        {
            e.Row.BackColor = System.Drawing.Color.Red;
            e.Row.ForeColor = System.Drawing.Color.White;
        }
    }
    else if (e.Row.RowType == DataControlRowType.Footer)
    {
        e.Row.Cells[4].Visible = false;
    }
}</code></pre>
        </div>
    </details>
</asp:Content>
