<%@ Page Title="Stored Procedures with LINQ" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="LINQStoredProcs.aspx.cs" Inherits="CRUDUsingLINQ.LINQStoredProcs" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="notion-header-group">
        <h1 class="notion-page-title">Stored Procedures with LINQ to SQL</h1>
        <p class="notion-page-desc">
            Invoke SQL Server stored procedures mapped to strongly-typed methods in <code class="notion-badge">SampleDataContext</code>, including handling <code class="notion-badge">OUTPUT</code> parameters.
        </p>
    </div>

    <div class="notion-callout">
        <div class="notion-callout-header">[Slide Concept] Stored Procedure Mapping</div>
        <div class="notion-callout-body">
            Tables and Views map to classes. Stored procedures and functions map to C# methods returning <code class="notion-badge">ISingleResult&lt;T&gt;</code>. Output parameters map to C# <code class="notion-badge">ref</code> parameters.
        </div>
    </div>

    <h2 class="notion-section-title">1. Execute Stored Procedure: GetEmployees</h2>
    <div style="display: flex; gap: 8px; margin-bottom: 16px;">
        <asp:Button ID="btnGetEmployeesSP" runat="server" Text="Execute GetEmployees()" CssClass="notion-btn notion-btn-primary" OnClick="btnGetEmployeesSP_Click" />
    </div>

    <div class="notion-table-wrapper">
        <asp:GridView ID="gvEmployeesSP" runat="server" AutoGenerateColumns="true" CssClass="notion-gridview" GridLines="None" />
    </div>

    <h2 class="notion-section-title">2. Stored Procedure with Output Parameter (GetEmployeesByDepartment)</h2>
    <p class="notion-page-desc">
        Stored procedure <code class="notion-badge">GetEmployeesByDepartment</code> returns both a result set of employees and an output parameter with the Department Name.
    </p>

    <div style="display: flex; align-items: center; gap: 12px; margin-bottom: 16px;">
        <label style="font-weight: 500; font-size: 13.5px;">Select Department ID:</label>
        <asp:DropDownList ID="ddlDepartments" runat="server" CssClass="notion-input" style="max-width: 140px;">
            <asp:ListItem Text="1 (IT)" Value="1" Selected="True" />
            <asp:ListItem Text="2 (HR)" Value="2" />
            <asp:ListItem Text="3 (Payroll)" Value="3" />
        </asp:DropDownList>
        <asp:Button ID="btnGetEmployeesByDepartment" runat="server" Text="Get Employees By Department" CssClass="notion-btn notion-btn-primary" OnClick="btnGetEmployeesByDepartment_Click" />
    </div>

    <div class="notion-callout">
        <asp:Label ID="lblDept" runat="server" Text="Department Name = " style="font-weight: 600; color: #1f1f1e;" />
    </div>

    <div class="notion-table-wrapper">
        <asp:GridView ID="gvDeptEmployees" runat="server" AutoGenerateColumns="true" CssClass="notion-gridview" GridLines="None" />
    </div>

    <h2 class="notion-section-title">3. Insert, Update, Delete via Stored Procedures</h2>
    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 16px; margin-bottom: 24px;">
        <!-- Insert Box -->
        <div style="border: 1px solid var(--border-color); border-radius: 4px; padding: 16px; background-color: var(--bg-surface);">
            <h3 class="notion-sub-title" style="margin-top: 0;">Insert via SP</h3>
            <div style="display: flex; flex-direction: column; gap: 8px;">
                <asp:TextBox ID="txtSpFirstName" runat="server" placeholder="First Name" CssClass="notion-input" />
                <asp:TextBox ID="txtSpLastName" runat="server" placeholder="Last Name" CssClass="notion-input" />
                <asp:TextBox ID="txtSpGender" runat="server" placeholder="Gender (Male/Female)" CssClass="notion-input" />
                <asp:TextBox ID="txtSpSalary" runat="server" placeholder="Salary (e.g. 55000)" CssClass="notion-input" />
                <asp:TextBox ID="txtSpDeptId" runat="server" placeholder="Department ID (1, 2, 3)" CssClass="notion-input" />
                <asp:Button ID="btnSpInsert" runat="server" Text="Execute InsertEmployee" CssClass="notion-btn" OnClick="btnSpInsert_Click" />
            </div>
        </div>

        <!-- Update Box -->
        <div style="border: 1px solid var(--border-color); border-radius: 4px; padding: 16px; background-color: var(--bg-surface);">
            <h3 class="notion-sub-title" style="margin-top: 0;">Update Salary via SP</h3>
            <div style="display: flex; flex-direction: column; gap: 8px;">
                <asp:TextBox ID="txtUpdEmpId" runat="server" placeholder="Employee ID to Update" CssClass="notion-input" />
                <asp:TextBox ID="txtUpdSalary" runat="server" placeholder="New Salary (e.g. 65000)" CssClass="notion-input" />
                <asp:Button ID="btnSpUpdate" runat="server" Text="Execute UpdateEmployee" CssClass="notion-btn" OnClick="btnSpUpdate_Click" />
            </div>
        </div>

        <!-- Delete Box -->
        <div style="border: 1px solid var(--border-color); border-radius: 4px; padding: 16px; background-color: var(--bg-surface);">
            <h3 class="notion-sub-title" style="margin-top: 0;">Delete via SP</h3>
            <div style="display: flex; flex-direction: column; gap: 8px;">
                <asp:TextBox ID="txtDelEmpId" runat="server" placeholder="Employee ID to Delete" CssClass="notion-input" />
                <asp:Button ID="btnSpDelete" runat="server" Text="Execute DeleteEmployee" CssClass="notion-btn notion-btn-danger" OnClick="btnSpDelete_Click" OnClientClick="return confirm('Are you sure you want to delete this employee via Stored Procedure?');" />
            </div>
        </div>
    </div>

    <asp:Label ID="lblSpResult" runat="server" CssClass="notion-status" Visible="false" />
</asp:Content>
