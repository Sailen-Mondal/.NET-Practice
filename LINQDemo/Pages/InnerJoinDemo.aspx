<%@ Page Title="Inner Join in LINQ" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="InnerJoinDemo.aspx.cs" Inherits="LINQDemo.Pages.InnerJoinDemo" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="page-title">Inner Join in LINQ</div>
    <div class="page-subtitle">Matching elements between two collections while excluding non-matching records</div>

    <div class="notion-alert notion-alert-info">
        <strong>Inner Join Behavior:</strong> Only records with matching keys in BOTH collections appear in the final result.
        <ul style="margin-top: 6px; margin-bottom: 0; padding-left: 20px;">
            <li>Employee <strong>Andy</strong> (ID: 10) has no department assigned, so Andy is excluded.</li>
            <li>Department <strong>Payroll</strong> (ID: 3) has no assigned employees, so Payroll is excluded.</li>
        </ul>
    </div>

    <!-- Underlying Collections Overview -->
    <div class="row" style="display: flex; gap: 20px; margin-bottom: 20px;">
        <div style="flex: 1;" class="notion-card">
            <div class="card-title">Departments Collection</div>
            <asp:GridView ID="gvDepartments" runat="server" CssClass="notion-grid" AutoGenerateColumns="true" />
        </div>
        <div style="flex: 1;" class="notion-card">
            <div class="card-title">Employees Collection (Andy has no DepartmentID)</div>
            <asp:GridView ID="gvEmployees" runat="server" CssClass="notion-grid" AutoGenerateColumns="true" />
        </div>
    </div>

    <!-- Join Queries -->
    <div class="notion-card">
        <div class="card-title">Inner Join Execution</div>
        <div class="code-box">
// Example 1: Method Syntax
var result = Employee.GetAllEmployees().Join(
    Department.GetAllDepartments(),
    e => e.DepartmentID,
    d => d.ID,
    (employee, department) => new {
        EmployeeName = employee.Name,
        DepartmentName = department.Name
    });

// Example 2: SQL-like Query Syntax
var result = from e in Employee.GetAllEmployees()
             join d in Department.GetAllDepartments()
             on e.DepartmentID equals d.ID
             select new {
                 EmployeeName = e.Name,
                 DepartmentName = d.Name
             };
        </div>

        <div class="button-row">
            <asp:Button ID="btnJoinMethod" runat="server" Text="Execute Join (Method Syntax)" CssClass="btn-notion btn-notion-primary" OnClick="btnJoinMethod_Click" />
            <asp:Button ID="btnJoinQuery" runat="server" Text="Execute Join (Query Syntax)" CssClass="btn-notion" OnClick="btnJoinQuery_Click" />
        </div>

        <asp:Panel ID="pnlJoinResult" runat="server" Visible="false">
            <div style="font-weight: 600; font-size: 0.85rem; margin-top: 12px; color: #37352f;">
                <asp:Label ID="lblJoinTitle" runat="server" />
            </div>
            <asp:GridView ID="gvJoinResults" runat="server" CssClass="notion-grid" AutoGenerateColumns="true" />
        </asp:Panel>
    </div>
</asp:Content>
