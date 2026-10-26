<%@ Page Title="LINQ to SQL CRUD" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="LinqToSqlCrud.aspx.cs" Inherits="LINQDemo.Pages.LinqToSqlCrud" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="page-title">Insert, Update, Delete using LINQ to SQL</div>
    <div class="page-subtitle">Direct DataContext entity operations: InsertOnSubmit, SubmitChanges, and DeleteOnSubmit</div>

    <div class="notion-alert notion-alert-info">
        <strong>Setup Note:</strong> This page executes direct LINQ to SQL operations via <code>SampleDataContext</code>.
        Run the provided SQL script in <code>SqlScripts\01_CreateTablesAndSeedData.sql</code> to create the <code>SampleDB</code> database and tables.
    </div>

    <asp:Panel ID="pnlStatus" runat="server" Visible="false" CssClass="notion-alert notion-alert-success">
        <asp:Label ID="lblStatusMessage" runat="server" />
    </asp:Panel>

    <div class="notion-card">
        <div class="card-title">LINQ to SQL Control Panel</div>
        <p style="font-size: 0.9rem; color: #787774;">
            Use the four buttons below to perform LINQ to SQL operations against the <code>Employees</code> table:
        </p>

        <!-- 4 Button Controls as specified in tutorial -->
        <div class="button-row">
            <asp:Button ID="btnGetData" runat="server" Text="Get Data" CssClass="btn-notion btn-notion-primary" OnClick="btnGetData_Click" />
            <asp:Button ID="btnInsert" runat="server" Text="Insert" CssClass="btn-notion" OnClick="btnInsert_Click" />
            <asp:Button ID="btnUpdate" runat="server" Text="Update" CssClass="btn-notion" OnClick="btnUpdate_Click" />
            <asp:Button ID="btnDelete" runat="server" Text="Delete" CssClass="btn-notion btn-notion-danger" OnClick="btnDelete_Click" />
        </div>

        <div style="margin-top: 20px;">
            <div style="font-weight: 600; font-size: 0.9rem; margin-bottom: 8px;">Employees Data Table:</div>
            <asp:GridView ID="GridView1" runat="server" CssClass="notion-grid" AutoGenerateColumns="true" EmptyDataText="No records found in database." />
        </div>
    </div>

    <!-- Code Explanation Card -->
    <div class="notion-card">
        <div class="card-title">Underlying LINQ to SQL Code</div>
        <div class="code-box">
// 1. Insert Record
using (SampleDataContext dbContext = new SampleDataContext()) {
    Employee newEmployee = new Employee {
        FirstName = "Tim",
        LastName = "T",
        Gender = "Male",
        Salary = 55000,
        DepartmentID = 1
    };
    dbContext.Employees.InsertOnSubmit(newEmployee);
    dbContext.SubmitChanges();
}

// 2. Update Record
using (SampleDataContext dbContext = new SampleDataContext()) {
    Employee employee = dbContext.Employees.SingleOrDefault(x => x.ID == 8);
    if (employee != null) {
        employee.Salary = 65000;
        dbContext.SubmitChanges();
    }
}

// 3. Delete Record
using (SampleDataContext dbContext = new SampleDataContext()) {
    Employee employee = dbContext.Employees.SingleOrDefault(x => x.ID == 8);
    if (employee != null) {
        dbContext.Employees.DeleteOnSubmit(employee);
        dbContext.SubmitChanges();
    }
}
        </div>
    </div>
</asp:Content>
