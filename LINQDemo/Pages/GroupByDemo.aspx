<%@ Page Title="GroupBy in LINQ" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="GroupByDemo.aspx.cs" Inherits="LINQDemo.Pages.GroupByDemo" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="page-title">GroupBy in LINQ</div>
    <div class="page-subtitle">Organizing sequences into IGrouping&lt;TKey, TElement&gt; collections based on a key</div>

    <!-- Example 1: Count by Department -->
    <div class="notion-card">
        <div class="card-title">Example 1: Employee Count By Department</div>
        <p style="font-size: 0.9rem; color: #787774;">
            Groups employees by their Department and projects the key with total employee count.
        </p>

        <div class="code-box">
var employeeGroup = from employee in Employee.GetAllEmployees()
                    group employee by employee.Department;

foreach (var group in employeeGroup) {
    Console.WriteLine("{0} - {1}", group.Key, group.Count());
}
        </div>

        <div class="button-row">
            <asp:Button ID="btnGroupExample1" runat="server" Text="Execute Example 1" CssClass="btn-notion btn-notion-primary" OnClick="btnGroupExample1_Click" />
        </div>

        <asp:Panel ID="pnlResult1" runat="server" Visible="false">
            <div class="terminal-output"><asp:Literal ID="litResult1" runat="server" /></div>
        </asp:Panel>
    </div>

    <!-- Example 2: Count and Details -->
    <div class="notion-card">
        <div class="card-title">Example 2: Employee Count and Employee List by Department</div>
        <p style="font-size: 0.9rem; color: #787774;">
            Iterates through each group and prints the department header, employee count, followed by individual employee names.
        </p>

        <div class="code-box">
var employeeGroup = from employee in Employee.GetAllEmployees()
                    group employee by employee.Department;

foreach (var group in employeeGroup) {
    Console.WriteLine("{0} - {1}", group.Key, group.Count());
    Console.WriteLine("----------");
    foreach (var employee in group) {
        Console.WriteLine(employee.Name + "\t" + employee.Department);
    }
}
        </div>

        <div class="button-row">
            <asp:Button ID="btnGroupExample2" runat="server" Text="Execute Example 2" CssClass="btn-notion btn-notion-primary" OnClick="btnGroupExample2_Click" />
        </div>

        <asp:Panel ID="pnlResult2" runat="server" Visible="false">
            <div class="terminal-output"><asp:Literal ID="litResult2" runat="server" /></div>
        </asp:Panel>
    </div>

    <!-- Example 3: Sorted Groups and Employees -->
    <div class="notion-card">
        <div class="card-title">Example 3: Sorted Groups (Department ASC) and Sorted Employees (Name ASC)</div>
        <p style="font-size: 0.9rem; color: #787774;">
            Uses query continuation with the <code>into</code> keyword to order departments alphabetically, then sorts employees inside each department.
        </p>

        <div class="code-box">
var employeeGroup = from employee in Employee.GetAllEmployees()
                    group employee by employee.Department into eGroup
                    orderby eGroup.Key
                    select new
                    {
                        Key = eGroup.Key,
                        Employees = eGroup.OrderBy(x => x.Name)
                    };

foreach (var group in employeeGroup) {
    Console.WriteLine("{0} - {1}", group.Key, group.Employees.Count());
    Console.WriteLine("----------");
    foreach (var employee in group.Employees) {
        Console.WriteLine(employee.Name + "\t" + employee.Department);
    }
}
        </div>

        <div class="button-row">
            <asp:Button ID="btnGroupExample3" runat="server" Text="Execute Example 3" CssClass="btn-notion btn-notion-primary" OnClick="btnGroupExample3_Click" />
        </div>

        <asp:Panel ID="pnlResult3" runat="server" Visible="false">
            <div class="terminal-output"><asp:Literal ID="litResult3" runat="server" /></div>
        </asp:Panel>
    </div>
</asp:Content>
