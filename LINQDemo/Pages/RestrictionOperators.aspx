<%@ Page Title="Restriction Operators" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="RestrictionOperators.aspx.cs" Inherits="LINQDemo.Pages.RestrictionOperators" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="page-title">Restriction Operators in LINQ</div>
    <div class="page-subtitle">Filtering collections using the Where operator with method and query syntax</div>

    <!-- Example 1: Integer Array Filtering -->
    <div class="notion-card">
        <div class="card-title">1. Integer Collection Filtering (Even Numbers)</div>
        <p style="font-size: 0.9rem; color: #787774;">
            Filtering an in-memory list of numbers <code>[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]</code> to select only even numbers.
        </p>

        <div class="code-box">
// Method Syntax with Lambda Expression
IEnumerable&lt;int&gt; evenNumbers = numbers.Where(num => num % 2 == 0);

// Method Syntax with Func Delegate
Func&lt;int, bool&gt; predicate = i => i % 2 == 0;
IEnumerable&lt;int&gt; evenNumbers = numbers.Where(predicate);

// SQL-like Query Syntax
IEnumerable&lt;int&gt; evenNumbers = from num in numbers
                               where num % 2 == 0
                               select num;
        </div>

        <div class="button-row">
            <asp:Button ID="btnFilterMethod" runat="server" Text="Run Method Syntax" CssClass="btn-notion btn-notion-primary" OnClick="btnFilterMethod_Click" />
            <asp:Button ID="btnFilterQuery" runat="server" Text="Run Query Syntax" CssClass="btn-notion" OnClick="btnFilterQuery_Click" />
        </div>

        <asp:Panel ID="pnlNumbersResult" runat="server" Visible="false">
            <div style="font-weight: 600; font-size: 0.85rem; margin-top: 12px; color: #37352f;">
                <asp:Label ID="lblNumberResultTitle" runat="server" />
            </div>
            <div class="terminal-output"><asp:Literal ID="litNumberOutput" runat="server" /></div>
        </asp:Panel>
    </div>

    <!-- Example 2: Entity / Object Graph Filtering -->
    <div class="notion-card">
        <div class="card-title">2. Nested Department & Employee Filtering</div>
        <p style="font-size: 0.9rem; color: #787774;">
            Filters the <strong>Departments</strong> collection for "IT" and "HR", then filters the nested <strong>Employees</strong> where Gender is "Male".
        </p>

        <div class="code-box">
IEnumerable&lt;Department&gt; departments = context.Departments
    .Where(dept => dept.Name == "IT" || dept.Name == "HR");

foreach (Department department in departments) {
    Console.WriteLine("Department Name = " + department.Name);
    foreach (Employee employee in department.Employees.Where(emp => emp.Gender == "Male")) {
        Console.WriteLine("\tEmployee Name = " + employee.FirstName + " " + employee.LastName);
    }
}
        </div>

        <div class="button-row">
            <asp:Button ID="btnFilterDepartments" runat="server" Text="Execute Department & Employee Query" CssClass="btn-notion btn-notion-primary" OnClick="btnFilterDepartments_Click" />
        </div>

        <asp:Panel ID="pnlDeptResult" runat="server" Visible="false">
            <div style="font-weight: 600; font-size: 0.85rem; margin-top: 12px; color: #37352f;">Output Result:</div>
            <div class="terminal-output"><asp:Literal ID="litDeptOutput" runat="server" /></div>
        </asp:Panel>
    </div>
</asp:Content>
