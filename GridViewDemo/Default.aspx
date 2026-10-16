<%@ Page Title="GridView Hub" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="GridViewDemo._Default" ResponseEncoding="utf-8" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="notion-breadcrumb">
        <span>Workspace</span> / <span>ASP.NET GridView Architecture &amp; Implementation</span>
    </div>

    <!-- Header Section -->
    <div class="notion-page-header">
        <span class="notion-page-badge">Comprehensive Curriculum</span>
        <h1 class="notion-page-title">ASP.NET GridView Developer Reference</h1>
        <p class="notion-page-desc">
            An interactive implementation of core GridView operations in ASP.NET Web Forms, structured with a clean, professional interface for rapid reference and study.
        </p>
    </div>

    <!-- DB Status & Reset Callout -->
    <div class="notion-callout" style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 14px;">
        <div>
            <div class="notion-callout-title">Database Status: Live &amp; Connected</div>
            <div style="font-size: 13px; color: #475569;">
                Target: SQL Server 2019 (GridViewDB) &bull; Customers, tblEmployee, Products, and Stored Procedures active.
            </div>
        </div>
        <div>
            <asp:Button ID="btnResetDB" runat="server" Text="Reset Sample Database" 
                OnClick="btnResetDB_Click" CssClass="btn-notion btn-notion-sm" 
                OnClientClick="return confirm('Restore all database tables to pristine initial seed records?');" />
        </div>
    </div>

    <asp:Panel ID="pnlAlert" runat="server" Visible="false" CssClass="notion-callout" Style="border-left-color: #16a34a; background-color: #f0fdf4;">
        <asp:Label ID="lblAlertMessage" runat="server" ForeColor="#166534" Font-Bold="true"></asp:Label>
    </asp:Panel>

    <!-- Topics Grid -->
    <div style="display: grid; grid-template-columns: repeat(auto-fill, minmax(360px, 1fr)); gap: 20px; margin-top: 24px;">

        <!-- Card 1 -->
        <div class="notion-card" style="margin-bottom: 0;">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px;">
                <span class="notion-tag notion-tag-neutral">Topic 01</span>
                <span style="font-size: 11px; font-weight: 600; color: #64748b; text-transform: uppercase;">Data Binding</span>
            </div>
            <h4 style="margin: 0 0 6px 0; font-size: 16px; font-weight: 600;">Basic Binding &amp; Built-in Paging</h4>
            <p style="font-size: 13px; color: #64748b; margin: 0 0 16px 0; min-height: 40px;">
                Populate GridView from Customers table using ADO.NET (SqlDataAdapter &amp; DataTable) with OnPageIndexChanging pagination.
            </p>
            <a href="BasicPaging.aspx" class="btn-notion btn-notion-primary btn-notion-sm">Open Module &rarr;</a>
        </div>

        <!-- Card 2 -->
        <div class="notion-card" style="margin-bottom: 0;">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px;">
                <span class="notion-tag notion-tag-neutral">Topic 02</span>
                <span style="font-size: 11px; font-weight: 600; color: #64748b; text-transform: uppercase;">Formatting</span>
            </div>
            <h4 style="margin: 0 0 6px 0; font-size: 16px; font-weight: 600;">Column Visibility &amp; Data Formats</h4>
            <p style="font-size: 13px; color: #64748b; margin: 0 0 16px 0; min-height: 40px;">
                Three techniques to hide columns (like EmployeeId), spaces in HeaderText, and DataFormatString for Date ({0:d}) and Currency ({0:c}).
            </p>
            <a href="FormattingBasics.aspx" class="btn-notion btn-notion-primary btn-notion-sm">Open Module &rarr;</a>
        </div>

        <!-- Card 3 -->
        <div class="notion-card" style="margin-bottom: 0;">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px;">
                <span class="notion-tag notion-tag-neutral">Topic 03</span>
                <span style="font-size: 11px; font-weight: 600; color: #64748b; text-transform: uppercase;">Globalization</span>
            </div>
            <h4 style="margin: 0 0 6px 0; font-size: 16px; font-weight: 600;">Multi-Culture Currency Formatting</h4>
            <p style="font-size: 13px; color: #64748b; margin: 0 0 16px 0; min-height: 40px;">
                Format country currencies dynamically in RowDataBound (US, UK, India, SA, Malaysia) plus searchable .NET culture explorer.
            </p>
            <a href="CurrencyCulture.aspx" class="btn-notion btn-notion-primary btn-notion-sm">Open Module &rarr;</a>
        </div>

        <!-- Card 4 -->
        <div class="notion-card" style="margin-bottom: 0;">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px;">
                <span class="notion-tag notion-tag-neutral">Topic 04 &amp; 05</span>
                <span style="font-size: 11px; font-weight: 600; color: #64748b; text-transform: uppercase;">Runtime Styles</span>
            </div>
            <h4 style="margin: 0 0 6px 0; font-size: 16px; font-weight: 600;">Dynamic Rows &amp; Conditional Highlight</h4>
            <p style="font-size: 13px; color: #64748b; margin: 0 0 16px 0; min-height: 40px;">
                Hide technical columns (CountryCulture) across Header and DataRow, and dynamically highlight records where Salary &gt; 70,000.
            </p>
            <a href="DynamicRowFormatting.aspx" class="btn-notion btn-notion-primary btn-notion-sm">Open Module &rarr;</a>
        </div>

        <!-- Card 5 -->
        <div class="notion-card" style="margin-bottom: 0;">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px;">
                <span class="notion-tag notion-tag-neutral">Topic 06</span>
                <span style="font-size: 11px; font-weight: 600; color: #64748b; text-transform: uppercase;">Validation</span>
            </div>
            <h4 style="margin: 0 0 6px 0; font-size: 16px; font-weight: 600;">TemplateFields &amp; Field Validation</h4>
            <p style="font-size: 13px; color: #64748b; margin: 0 0 16px 0; min-height: 40px;">
                Convert BoundField to TemplateField with DropDownList editing for Gender, RequiredFieldValidator with InitialValue, and ValidationSummary.
            </p>
            <a href="TemplateFieldsValidation.aspx" class="btn-notion btn-notion-primary btn-notion-sm">Open Module &rarr;</a>
        </div>

        <!-- Card 6 -->
        <div class="notion-card" style="margin-bottom: 0;">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px;">
                <span class="notion-tag notion-tag-neutral">Topic 07</span>
                <span style="font-size: 11px; font-weight: 600; color: #64748b; text-transform: uppercase;">Declarative CRUD</span>
            </div>
            <h4 style="margin: 0 0 6px 0; font-size: 16px; font-weight: 600;">Full CRUD with SqlDataSource</h4>
            <p style="font-size: 13px; color: #64748b; margin: 0 0 16px 0; min-height: 40px;">
                Declarative Insert, Update, Delete with typed parameters, footer row insertion, and distinct ValidationGroups.
            </p>
            <a href="CrudSqlDataSource.aspx" class="btn-notion btn-notion-primary btn-notion-sm">Open Module &rarr;</a>
        </div>

        <!-- Card 7 -->
        <div class="notion-card" style="margin-bottom: 0;">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px;">
                <span class="notion-tag notion-tag-neutral">Topic 08</span>
                <span style="font-size: 11px; font-weight: 600; color: #64748b; text-transform: uppercase;">3-Tier Arch</span>
            </div>
            <h4 style="margin: 0 0 6px 0; font-size: 16px; font-weight: 600;">Full CRUD with ObjectDataSource</h4>
            <p style="font-size: 13px; color: #64748b; margin: 0 0 16px 0; min-height: 40px;">
                Tiered architecture binding GridView to an Employee entity model and EmployeeDataAccessLayer business methods.
            </p>
            <a href="CrudObjectDataSource.aspx" class="btn-notion btn-notion-primary btn-notion-sm">Open Module &rarr;</a>
        </div>

        <!-- Card 8 -->
        <div class="notion-card" style="margin-bottom: 0;">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px;">
                <span class="notion-tag notion-tag-neutral">Topic 09</span>
                <span style="font-size: 11px; font-weight: 600; color: #64748b; text-transform: uppercase;">Code-Behind</span>
            </div>
            <h4 style="margin: 0 0 6px 0; font-size: 16px; font-weight: 600;">Pure Code-Behind CRUD &amp; RowCommand</h4>
            <p style="font-size: 13px; color: #64748b; margin: 0 0 16px 0; min-height: 40px;">
                100% C# programmatic CRUD without DataSource controls, custom action commands, and client-side JavaScript delete confirmation.
            </p>
            <a href="CrudCodeBehind.aspx" class="btn-notion btn-notion-primary btn-notion-sm">Open Module &rarr;</a>
        </div>

        <!-- Card 9 -->
        <div class="notion-card" style="margin-bottom: 0;">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px;">
                <span class="notion-tag notion-tag-neutral">Topic 10</span>
                <span style="font-size: 11px; font-weight: 600; color: #64748b; text-transform: uppercase;">Optimization</span>
            </div>
            <h4 style="margin: 0 0 6px 0; font-size: 16px; font-weight: 600;">Custom Server-Side Paging</h4>
            <p style="font-size: 13px; color: #64748b; margin: 0 0 16px 0; min-height: 40px;">
                Server-side stored procedure paging using ROW_NUMBER() with total rows OUTPUT parameter and an ASP.NET Repeater pager.
            </p>
            <a href="CustomPaging.aspx" class="btn-notion btn-notion-primary btn-notion-sm">Open Module &rarr;</a>
        </div>

        <!-- Card 10 -->
        <div class="notion-card" style="margin-bottom: 0;">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px;">
                <span class="notion-tag notion-tag-neutral">Topic 11</span>
                <span style="font-size: 11px; font-weight: 600; color: #64748b; text-transform: uppercase;">Master-Detail</span>
            </div>
            <h4 style="margin: 0 0 6px 0; font-size: 16px; font-weight: 600;">ItemTemplate Controls &amp; Routing</h4>
            <p style="font-size: 13px; color: #64748b; margin: 0 0 16px 0; min-height: 40px;">
                Retrieve values from controls inside ItemTemplate, redirect with QueryString, and load full product specifications.
            </p>
            <a href="Products.aspx" class="btn-notion btn-notion-primary btn-notion-sm">Open Module &rarr;</a>
        </div>
    </div>

    <!-- Quick Reference Cheat Sheet -->
    <div class="notion-card" style="margin-top: 32px;">
        <div class="notion-card-header">
            <h3 class="notion-card-title">GridView Lifecycle &amp; Events Reference</h3>
        </div>
        <table class="notion-grid" style="border: none;">
            <thead>
                <tr>
                    <th style="width: 220px;">Event Name</th>
                    <th style="width: 240px;">Execution Timing</th>
                    <th>Implementation Scope</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td><strong>RowDataBound</strong></td>
                    <td>After a row is bound to its record</td>
                    <td>Row-level culture formatting, conditional color highlighting (Salary &gt; 70k), hiding technical cells.</td>
                </tr>
                <tr>
                    <td><strong>RowCommand</strong></td>
                    <td>When any Button/LinkButton is clicked</td>
                    <td>Handling custom commands (EditRow, DeleteRow, UpdateRow, InsertRow) via CommandArgument.</td>
                </tr>
                <tr>
                    <td><strong>PageIndexChanging</strong></td>
                    <td>When a pager link is clicked</td>
                    <td>Updating <code>GridView.PageIndex = e.NewPageIndex</code> and re-binding the datasource.</td>
                </tr>
                <tr>
                    <td><strong>RowEditing / RowCancelingEdit</strong></td>
                    <td>When toggling row edit state</td>
                    <td>Setting <code>GridView.EditIndex</code> to rowIndex or -1 to activate editable inputs.</td>
                </tr>
            </tbody>
        </table>
    </div>
</asp:Content>
