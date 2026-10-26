<%@ Page Title="LINQ Basics & Ordering" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="LINQBasics.aspx.cs" Inherits="CRUDUsingLINQ.LINQBasics" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="notion-header-group">
        <h1 class="notion-page-title">LINQ Basics, Restriction & Ordering</h1>
        <p class="notion-page-desc">
            Explore the three fundamental syntaxes (Query, Method, Mixed), Restriction operators (Where/Predicate), and Ordering operators (OrderBy, OrderByDescending, Reverse).
        </p>
    </div>

    <h2 class="notion-section-title">1. Query Syntax vs Method Syntax vs Mixed Syntax</h2>
    <div class="notion-callout">
        <div class="notion-callout-header">[Slide Example] Numbers Greater Than 5 and Sum</div>
        <div class="notion-callout-body">
            Data Source: <code class="notion-badge">List&lt;int&gt; { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }</code>
        </div>
    </div>

    <div style="display: flex; gap: 8px; margin-bottom: 16px;">
        <asp:Button ID="btnRunQuerySyntax" runat="server" Text="Execute Query Syntax" CssClass="notion-btn" OnClick="btnRunQuerySyntax_Click" />
        <asp:Button ID="btnRunMethodSyntax" runat="server" Text="Execute Method Syntax" CssClass="notion-btn" OnClick="btnRunMethodSyntax_Click" />
        <asp:Button ID="btnRunMixedSyntax" runat="server" Text="Execute Mixed Syntax (Sum)" CssClass="notion-btn notion-btn-primary" OnClick="btnRunMixedSyntax_Click" />
    </div>

    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px;">
        <div>
            <h3 class="notion-sub-title">LINQ Code Snippet</h3>
            <pre class="notion-code-block"><asp:Label ID="lblSyntaxCode" runat="server" Text="// Select a button above to run LINQ syntax demo" /></pre>
        </div>
        <div>
            <h3 class="notion-sub-title">Execution Result</h3>
            <pre class="notion-code-block"><asp:Label ID="lblSyntaxOutput" runat="server" Text="(Output will appear here)" /></pre>
        </div>
    </div>

    <h2 class="notion-section-title">2. Restriction Operators (Where & Predicates)</h2>
    <p class="notion-page-desc">Filtering even numbers using lambda expressions, explicit delegates (<code class="notion-badge">Func&lt;int, bool&gt;</code>), and SQL-like syntax.</p>

    <div style="display: flex; gap: 8px; margin-bottom: 16px;">
        <asp:Button ID="btnFilterEven" runat="server" Text="Filter Even Numbers (Lambda)" CssClass="notion-btn" OnClick="btnFilterEven_Click" />
        <asp:Button ID="btnFilterPredicate" runat="server" Text="Filter Even (Func&lt;int, bool&gt;)" CssClass="notion-btn" OnClick="btnFilterPredicate_Click" />
        <asp:Button ID="btnFilterDeptEmp" runat="server" Text="Filter IT/HR Male Employees" CssClass="notion-btn notion-btn-primary" OnClick="btnFilterDeptEmp_Click" />
    </div>

    <pre class="notion-code-block"><asp:Label ID="lblRestrictionOutput" runat="server" Text="// Click a restriction button above to inspect results" /></pre>

    <h2 class="notion-section-title">3. Ordering Operators (OrderBy, OrderByDescending, Reverse)</h2>
    <p class="notion-page-desc">Sorting objects in memory using standard LINQ ordering methods.</p>

    <div style="display: flex; gap: 8px; margin-bottom: 16px;">
        <asp:Button ID="btnOrderAsc" runat="server" Text="OrderBy (Ascending)" CssClass="notion-btn" OnClick="btnOrderAsc_Click" />
        <asp:Button ID="btnOrderDesc" runat="server" Text="OrderByDescending" CssClass="notion-btn" OnClick="btnOrderDesc_Click" />
        <asp:Button ID="btnReverse" runat="server" Text="Reverse" CssClass="notion-btn" OnClick="btnReverse_Click" />
    </div>

    <div class="notion-table-wrapper">
        <asp:GridView ID="gvStudents" runat="server" AutoGenerateColumns="true" CssClass="notion-gridview" GridLines="None" />
    </div>
</asp:Content>
