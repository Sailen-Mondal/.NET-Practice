<%@ Page Title="Stored Procedures with LINQ to SQL" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="LinqToSqlStoredProc.aspx.cs" Inherits="LINQDemo.Pages.LinqToSqlStoredProc" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="page-title">Stored Procedures in LINQ to SQL</div>
    <div class="page-subtitle">Executing stored procedures, ISingleResult&lt;T&gt; return types, and OUTPUT parameters</div>

    <div class="notion-alert notion-alert-info">
        <strong>SQL Procedures:</strong> The stored procedures called here (<code>GetEmployees</code>, <code>InsertEmployee</code>, <code>UpdateEmployee</code>, <code>DeleteEmployee</code>, <code>GetEmployeesByDepartment</code>)
        are scripted in <code>SqlScripts\02_CreateStoredProcedures.sql</code>.
    </div>

    <asp:Panel ID="pnlStatus" runat="server" Visible="false" CssClass="notion-alert notion-alert-success">
        <asp:Label ID="lblStatusMessage" runat="server" />
    </asp:Panel>

    <!-- Part 1: GetEmployees Stored Procedure -->
    <div class="notion-card">
        <div class="card-title">1. Execute GetEmployees Stored Procedure</div>
        <p style="font-size: 0.9rem; color: #787774;">
            Calls <code>dbContext.GetEmployees()</code> which returns <code>ISingleResult&lt;Employee&gt;</code>.
        </p>

        <div class="code-box">
SampleDataContext dbContext = new SampleDataContext();
GridView1.DataSource = dbContext.GetEmployees();
GridView1.DataBind();
        </div>

        <div class="button-row">
            <asp:Button ID="btnGetEmployeesSp" runat="server" Text="Execute GetEmployees()" CssClass="btn-notion btn-notion-primary" OnClick="btnGetEmployeesSp_Click" />
        </div>
    </div>

    <!-- Part 2: Stored Procedure with Output Parameter -->
    <div class="notion-card">
        <div class="card-title">2. Stored Procedure with Output Parameter (GetEmployeesByDepartment)</div>
        <p style="font-size: 0.9rem; color: #787774;">
            Retrieves the department name into an <code>OUTPUT</code> parameter and returns employees belonging to that department.
        </p>

        <div class="code-box">
using (SampleDataContext dbContext = new SampleDataContext()) {
    string deptName = string.Empty;
    GridView1.DataSource = dbContext.GetEmployeesByDepartment(1, ref deptName);
    GridView1.DataBind();
    lblDept.Text = "Department Name = " + deptName;
}
        </div>

        <div class="button-row" style="align-items: center;">
            <asp:Label runat="server" Text="Select Department ID: " Style="font-size: 0.9rem;" />
            <asp:DropDownList ID="ddlDepartmentId" runat="server" CssClass="form-control" Style="display: inline-block; width: 100px; margin-right: 12px;">
                <asp:ListItem Text="1 (IT)" Value="1" Selected="True" />
                <asp:ListItem Text="2 (HR)" Value="2" />
                <asp:ListItem Text="3 (Payroll)" Value="3" />
            </asp:DropDownList>
            <asp:Button ID="btnGetEmployeesByDepartment" runat="server" Text="Get Employees By Department" CssClass="btn-notion btn-notion-primary" OnClick="btnGetEmployeesByDepartment_Click" />
        </div>

        <div style="margin-top: 16px; margin-bottom: 8px;">
            <asp:Label ID="lblDept" runat="server" Text="" Font-Bold="true" Style="font-size: 1rem; color: #2383e2;" />
        </div>

        <asp:GridView ID="GridView1" runat="server" CssClass="notion-grid" AutoGenerateColumns="true" EmptyDataText="No records returned from stored procedure." />
    </div>

    <!-- Part 3: Stored Procedure CRUD -->
    <div class="notion-card">
        <div class="card-title">3. Insert, Update, and Delete via Stored Procedures</div>
        <p style="font-size: 0.9rem; color: #787774;">
            Execute <code>InsertEmployee</code>, <code>UpdateEmployee</code>, and <code>DeleteEmployee</code> stored procedures.
        </p>

        <div class="button-row">
            <asp:Button ID="btnInsertSp" runat="server" Text="Execute InsertEmployee SP" CssClass="btn-notion" OnClick="btnInsertSp_Click" />
            <asp:Button ID="btnUpdateSp" runat="server" Text="Execute UpdateEmployee SP" CssClass="btn-notion" OnClick="btnUpdateSp_Click" />
            <asp:Button ID="btnDeleteSp" runat="server" Text="Execute DeleteEmployee SP" CssClass="btn-notion btn-notion-danger" OnClick="btnDeleteSp_Click" />
        </div>
    </div>
</asp:Content>
