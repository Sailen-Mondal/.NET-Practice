<%@ Page Title="Database Reference" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Contact.aspx.cs" Inherits="CRUDUsingLINQ.Contact" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="notion-header-group">
        <h1 class="notion-page-title">Database Schema Reference</h1>
        <p class="notion-page-desc">T-SQL script and table schemas stored in SQLQuery_26_10_26.sql</p>
    </div>

    <div class="notion-callout">
        <div class="notion-callout-header">[Target Database] ProjectManagementDB</div>
        <div class="notion-callout-body">
            Script path: <code class="notion-badge">C:\Users\sailenmondal\OneDrive - MANAGEMENT &amp; COMPUTER CONSULTANTS\Documents\SQL Server Management Studio 22\SQLQuery_26_10_26.sql</code>
        </div>
    </div>

    <h2 class="notion-section-title">Created Tables &amp; Stored Procedures</h2>
    <ul>
        <li><code class="notion-badge">dbo.Students</code> - ID, FirstName, LastName, Gender</li>
        <li><code class="notion-badge">dbo.Departments</code> - ID, Name</li>
        <li><code class="notion-badge">dbo.Employees</code> - ID, FirstName, LastName, Gender, Salary, DepartmentId</li>
        <li><code class="notion-badge">dbo.Employee1</code> - ID, Name, Location, Gender</li>
        <li><code class="notion-badge">dbo.GetEmployees</code> - Stored procedure returning employees</li>
        <li><code class="notion-badge">dbo.InsertEmployee</code> - Stored procedure inserting an employee</li>
        <li><code class="notion-badge">dbo.UpdateEmployee</code> - Stored procedure updating employee details</li>
        <li><code class="notion-badge">dbo.DeleteEmployee</code> - Stored procedure deleting an employee</li>
        <li><code class="notion-badge">dbo.GetEmployeesByDepartment</code> - Stored procedure with <code class="notion-badge">OUTPUT</code> department name</li>
    </ul>
</asp:Content>
