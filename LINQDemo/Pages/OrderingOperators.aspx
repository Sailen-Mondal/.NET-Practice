<%@ Page Title="Ordering Operators" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="OrderingOperators.aspx.cs" Inherits="LINQDemo.Pages.OrderingOperators" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="page-title">Ordering Operators in LINQ</div>
    <div class="page-subtitle">Sorting and reversing sequences using OrderBy, OrderByDescending, ThenBy, ThenByDescending, and Reverse</div>

    <div class="notion-card">
        <div class="card-title">Base Student Dataset</div>
        <p style="font-size: 0.9rem; color: #787774;">
            The operations below operate on the following student collection:
        </p>
        <asp:GridView ID="gvOriginalStudents" runat="server" CssClass="notion-grid" AutoGenerateColumns="true" />
    </div>

    <!-- Ascending Ordering -->
    <div class="notion-card">
        <div class="card-title">1. Sort Students by Name (Ascending)</div>
        <p style="font-size: 0.9rem; color: #787774;">
            Examples 1 & 2: Compare Method Syntax with SQL-like Query Syntax.
        </p>

        <div class="code-box">
// Example 1: Method Syntax
IEnumerable&lt;Student&gt; result = Student.GetAllStudents().OrderBy(s => s.Name);

// Example 2: SQL-like Query Syntax
IEnumerable&lt;Student&gt; result = from student in Student.GetAllStudents()
                               orderby student.Name
                               select student;
        </div>

        <div class="button-row">
            <asp:Button ID="btnOrderAscMethod" runat="server" Text="Sort Name Ascending (Method)" CssClass="btn-notion btn-notion-primary" OnClick="btnOrderAscMethod_Click" />
            <asp:Button ID="btnOrderAscQuery" runat="server" Text="Sort Name Ascending (Query)" CssClass="btn-notion" OnClick="btnOrderAscQuery_Click" />
        </div>

        <asp:Panel ID="pnlAscResult" runat="server" Visible="false">
            <asp:GridView ID="gvAscStudents" runat="server" CssClass="notion-grid" AutoGenerateColumns="true" />
        </asp:Panel>
    </div>

    <!-- Descending Ordering -->
    <div class="notion-card">
        <div class="card-title">2. Sort Students by Name (Descending)</div>
        <p style="font-size: 0.9rem; color: #787774;">
            Examples 3 & 4: Descending order using <code>OrderByDescending</code> and the <code>descending</code> keyword.
        </p>

        <div class="code-box">
// Example 3: Method Syntax
IEnumerable&lt;Student&gt; result = Student.GetAllStudents().OrderByDescending(s => s.Name);

// Example 4: SQL-like Query Syntax
IEnumerable&lt;Student&gt; result = from student in Student.GetAllStudents()
                               orderby student.Name descending
                               select student;
        </div>

        <div class="button-row">
            <asp:Button ID="btnOrderDescMethod" runat="server" Text="Sort Name Descending (Method)" CssClass="btn-notion btn-notion-primary" OnClick="btnOrderDescMethod_Click" />
            <asp:Button ID="btnOrderDescQuery" runat="server" Text="Sort Name Descending (Query)" CssClass="btn-notion" OnClick="btnOrderDescQuery_Click" />
        </div>

        <asp:Panel ID="pnlDescResult" runat="server" Visible="false">
            <asp:GridView ID="gvDescStudents" runat="server" CssClass="notion-grid" AutoGenerateColumns="true" />
        </asp:Panel>
    </div>

    <!-- Secondary Ordering & Reverse -->
    <div class="notion-card">
        <div class="card-title">3. Multi-Level Sorting (ThenBy) & Reverse</div>
        <p style="font-size: 0.9rem; color: #787774;">
            <code>ThenBy</code> sorts ties from the initial <code>OrderBy</code>. <code>Reverse</code> inverts the item order in the collection.
        </p>

        <div class="code-box">
// Multi-Level Sort: OrderBy TotalMarks ascending, ThenBy Name ascending
var result = Student.GetAllStudents()
    .OrderBy(s => s.TotalMarks)
    .ThenBy(s => s.Name);

// Reverse Operator: Inverts current sequence
List&lt;Student&gt; list = Student.GetAllStudents();
list.Reverse();
        </div>

        <div class="button-row">
            <asp:Button ID="btnThenBy" runat="server" Text="OrderBy Marks ThenBy Name" CssClass="btn-notion btn-notion-primary" OnClick="btnThenBy_Click" />
            <asp:Button ID="btnReverse" runat="server" Text="Execute Reverse Operator" CssClass="btn-notion" OnClick="btnReverse_Click" />
        </div>

        <asp:Panel ID="pnlSpecialResult" runat="server" Visible="false">
            <div style="font-weight: 600; font-size: 0.85rem; margin-top: 12px; color: #37352f;">
                <asp:Label ID="lblSpecialTitle" runat="server" />
            </div>
            <asp:GridView ID="gvSpecialStudents" runat="server" CssClass="notion-grid" AutoGenerateColumns="true" />
        </asp:Panel>
    </div>
</asp:Content>
