<%@ Page Title="Grouping & Joins" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="LINQGroupingJoins.aspx.cs" Inherits="CRUDUsingLINQ.LINQGroupingJoins" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="notion-header-group">
        <h1 class="notion-page-title">GroupBy & Inner Join in LINQ</h1>
        <p class="notion-page-desc">
            Learn grouping operations using <code class="notion-badge">IGrouping&lt;K,V&gt;</code> and relational joining between collections or database tables.
        </p>
    </div>

    <h2 class="notion-section-title">1. GroupBy in LINQ</h2>
    <div class="notion-callout">
        <div class="notion-callout-header">[Concept] Grouping Operators</div>
        <div class="notion-callout-body">
            GroupBy organizes a flat sequence into groups of sequences (<code class="notion-badge">IGrouping&lt;K, V&gt;</code>) based on a specified key.
        </div>
    </div>

    <div style="display: flex; gap: 8px; margin-bottom: 16px;">
        <asp:Button ID="btnGroupCount" runat="server" Text="Employee Count By Department" CssClass="notion-btn" OnClick="btnGroupCount_Click" />
        <asp:Button ID="btnGroupDetails" runat="server" Text="Count and List Employees" CssClass="notion-btn" OnClick="btnGroupDetails_Click" />
        <asp:Button ID="btnGroupSorted" runat="server" Text="Sorted Department & Name" CssClass="notion-btn notion-btn-primary" OnClick="btnGroupSorted_Click" />
    </div>

    <pre class="notion-code-block"><asp:Label ID="lblGroupOutput" runat="server" Text="// Select a grouping query above to view results" /></pre>

    <h2 class="notion-section-title">2. Inner Join in LINQ</h2>
    <div class="notion-callout">
        <div class="notion-callout-header">[Join Behavior] Exclusion of Non-Matching Elements</div>
        <div class="notion-callout-body">
            In an inner join between <code class="notion-badge">Employees</code> and <code class="notion-badge">Departments</code>, only matching elements are included. Notice that employee <strong>Andy</strong> (who has no department assigned) is excluded from the result set.
        </div>
    </div>

    <div style="display: flex; gap: 8px; margin-bottom: 16px;">
        <asp:Button ID="btnJoinMethod" runat="server" Text="Inner Join (Method Syntax)" CssClass="notion-btn" OnClick="btnJoinMethod_Click" />
        <asp:Button ID="btnJoinQuery" runat="server" Text="Inner Join (Query Syntax)" CssClass="notion-btn notion-btn-primary" OnClick="btnJoinQuery_Click" />
    </div>

    <div class="notion-table-wrapper">
        <asp:GridView ID="gvJoinResult" runat="server" AutoGenerateColumns="true" CssClass="notion-gridview" GridLines="None" />
    </div>

    <h3 class="notion-sub-title">Query Comparison</h3>
    <pre class="notion-code-block">// Method Syntax:
var result = Employee.GetAllEmployees().Join(
    Department.GetAllDepartments(),
    e => e.DepartmentID,
    d => d.ID,
    (employee, department) => new {
        EmployeeName = employee.Name,
        DepartmentName = department.Name
    });

// Query Syntax:
var result = from e in Employee.GetAllEmployees()
             join d in Department.GetAllDepartments()
             on e.DepartmentID equals d.ID
             select new {
                 EmployeeName = e.Name,
                 DepartmentName = d.Name
             };</pre>
</asp:Content>
