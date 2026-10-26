<%@ Page Title="LINQ Learning Suite" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="LINQDemo._Default" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="page-title">LINQ & LINQ to SQL Learning Suite</div>
    <div class="page-subtitle">A clean, interactive, didactic reference guide covering all core LINQ and LINQ to SQL concepts</div>

    <!-- Topics Grid -->
    <div class="row" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(320px, 1fr)); gap: 16px; margin-bottom: 24px;">
        
        <!-- Card 1 -->
        <div class="notion-card">
            <div class="card-title">1. Restriction Operators</div>
            <p style="font-size: 0.875rem; color: #787774; margin-bottom: 14px;">
                Filter sequences based on conditions using <code>Where()</code> with lambda expressions, Func delegates, or SQL-like query syntax.
            </p>
            <div style="font-size: 0.8rem; font-family: monospace; background: #f7f6f3; padding: 6px 10px; border-radius: 4px; margin-bottom: 14px;">
                numbers.Where(n => n % 2 == 0)
            </div>
            <a href="Pages/RestrictionOperators.aspx" class="btn-notion btn-notion-primary">Explore Restriction &raquo;</a>
        </div>

        <!-- Card 2 -->
        <div class="notion-card">
            <div class="card-title">2. Ordering Operators</div>
            <p style="font-size: 0.875rem; color: #787774; margin-bottom: 14px;">
                Sort data in ascending/descending order with <code>OrderBy</code>, <code>OrderByDescending</code>, <code>ThenBy</code>, and invert sequences with <code>Reverse</code>.
            </p>
            <div style="font-size: 0.8rem; font-family: monospace; background: #f7f6f3; padding: 6px 10px; border-radius: 4px; margin-bottom: 14px;">
                students.OrderBy(s => s.Name)
            </div>
            <a href="Pages/OrderingOperators.aspx" class="btn-notion btn-notion-primary">Explore Ordering &raquo;</a>
        </div>

        <!-- Card 3 -->
        <div class="notion-card">
            <div class="card-title">3. GroupBy in LINQ</div>
            <p style="font-size: 0.875rem; color: #787774; margin-bottom: 14px;">
                Organize sequences into <code>IGrouping&lt;K,V&gt;</code> buckets. Calculate group aggregations and apply secondary orderings.
            </p>
            <div style="font-size: 0.8rem; font-family: monospace; background: #f7f6f3; padding: 6px 10px; border-radius: 4px; margin-bottom: 14px;">
                group emp by emp.Department
            </div>
            <a href="Pages/GroupByDemo.aspx" class="btn-notion btn-notion-primary">Explore GroupBy &raquo;</a>
        </div>

        <!-- Card 4 -->
        <div class="notion-card">
            <div class="card-title">4. Inner Join</div>
            <p style="font-size: 0.875rem; color: #787774; margin-bottom: 14px;">
                Combine matching elements from two collections based on key equivalence. Understand why non-matching records are excluded.
            </p>
            <div style="font-size: 0.8rem; font-family: monospace; background: #f7f6f3; padding: 6px 10px; border-radius: 4px; margin-bottom: 14px;">
                join d in depts on e.DeptID equals d.ID
            </div>
            <a href="Pages/InnerJoinDemo.aspx" class="btn-notion btn-notion-primary">Explore Inner Join &raquo;</a>
        </div>

        <!-- Card 5 -->
        <div class="notion-card">
            <div class="card-title">5. LINQ to SQL CRUD</div>
            <p style="font-size: 0.875rem; color: #787774; margin-bottom: 14px;">
                Interact with SQL Server via <code>DataContext</code>: Insert using <code>InsertOnSubmit</code>, update entity fields, and delete with <code>DeleteOnSubmit</code>.
            </p>
            <div style="font-size: 0.8rem; font-family: monospace; background: #f7f6f3; padding: 6px 10px; border-radius: 4px; margin-bottom: 14px;">
                dbContext.SubmitChanges()
            </div>
            <a href="Pages/LinqToSqlCrud.aspx" class="btn-notion btn-notion-primary">Explore CRUD WebForm &raquo;</a>
        </div>

        <!-- Card 6 -->
        <div class="notion-card">
            <div class="card-title">6. Stored Procedures</div>
            <p style="font-size: 0.875rem; color: #787774; margin-bottom: 14px;">
                Invoke stored procedures returning <code>ISingleResult&lt;T&gt;</code>, execute CRUD procedures, and capture <code>OUTPUT</code> parameters.
            </p>
            <div style="font-size: 0.8rem; font-family: monospace; background: #f7f6f3; padding: 6px 10px; border-radius: 4px; margin-bottom: 14px;">
                GetEmployeesByDepartment(id, ref name)
            </div>
            <a href="Pages/LinqToSqlStoredProc.aspx" class="btn-notion btn-notion-primary">Explore Stored Procedures &raquo;</a>
        </div>
    </div>

    <!-- Live Console Execution Section -->
    <div class="notion-card">
        <div class="card-title">Interactive Console Output Runner</div>
        <p style="font-size: 0.9rem; color: #787774;">
            Run all in-memory LINQ demo routines from <code>Demos/ConsoleDemos.cs</code> directly and inspect the formatted console output.
        </p>

        <div class="button-row">
            <asp:Button ID="btnRunConsoleDemos" runat="server" Text="Execute All In-Memory Demos" CssClass="btn-notion btn-notion-primary" OnClick="btnRunConsoleDemos_Click" />
        </div>

        <asp:Panel ID="pnlConsoleOutput" runat="server" Visible="false">
            <div class="terminal-output"><asp:Literal ID="litConsoleOutput" runat="server" /></div>
        </asp:Panel>
    </div>
</asp:Content>
