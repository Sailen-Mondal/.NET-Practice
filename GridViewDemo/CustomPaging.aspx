<%@ Page Title="Custom Server-Side Paging" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="CustomPaging.aspx.cs" Inherits="GridViewDemo.CustomPaging" ResponseEncoding="utf-8" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="notion-breadcrumb">
        <a href="Default.aspx">Overview</a> / <span>Topic 10: Custom Server-Side Paging</span>
    </div>

    <div class="notion-page-header">
        <span class="notion-page-badge">Topic 10</span>
        <h1 class="notion-page-title">Custom Server-Side Paging with Stored Procedure &amp; Repeater</h1>
        <p class="notion-page-desc">
            Scale large enterprise datasets by querying only the active page from SQL Server using ROW_NUMBER() and an OUTPUT parameter for total row count, rendered with an ASP.NET Repeater.
        </p>
    </div>

    <!-- Concept Callout -->
    <div class="notion-callout">
        <div class="notion-callout-title">Performance Benefits of Custom Paging</div>
        <p style="margin: 0;">
            Default GridView pagination loads the entire table into web server memory before slicing. Custom server-side paging executes <code>spGetEmployees_by_PageIndex_and_PageSize</code> to fetch only the requested records (e.g. 3 rows per page), dramatically reducing database I/O, server RAM, and network payload.
        </p>
    </div>

    <!-- Live GridView Card -->
    <div class="notion-card">
        <div class="notion-card-header">
            <h3 class="notion-card-title">Paged Employee Dataset</h3>
            <div style="display: flex; gap: 8px; align-items: center;">
                <span class="notion-tag notion-tag-neutral">Page Size: 3 rows</span>
                <span class="notion-tag notion-tag-it">
                    <asp:Label ID="lblPageStats" runat="server" Text="Loading..."></asp:Label>
                </span>
            </div>
        </div>

        <div class="notion-grid-wrapper">
            <asp:GridView ID="GridView1" runat="server" 
                AutoGenerateColumns="False" 
                AllowPaging="false"
                CssClass="notion-grid"
                GridLines="None">
                <Columns>
                    <asp:BoundField DataField="EmployeeId" HeaderText="ID" ItemStyle-Width="60px" />
                    <asp:BoundField DataField="Name" HeaderText="Employee Name" ItemStyle-Width="250px" />
                    <asp:TemplateField HeaderText="Gender" ItemStyle-Width="120px">
                        <ItemTemplate>
                            <span class='notion-tag <%# Eval("Gender").ToString() == "Male" ? "notion-tag-male" : "notion-tag-female" %>'>
                                <%# Eval("Gender") %>
                            </span>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:BoundField DataField="City" HeaderText="City" ItemStyle-Width="200px" />
                </Columns>
            </asp:GridView>
        </div>

        <!-- Custom Repeater Pager -->
        <div style="margin-top: 16px; display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 12px;">
            <div style="font-size: 13px; color: #64748b;">
                Page selection:
            </div>
            <div class="notion-pager">
                <asp:Repeater ID="repeaterPaging" runat="server">
                    <ItemTemplate>
                        <asp:LinkButton ID="pagingLinkButton" runat="server" 
                            Text='<%# Eval("Text") %>' 
                            CommandArgument='<%# Eval("Value") %>' 
                            Enabled='<%# Eval("Enabled") %>' 
                            OnClick="linkButton_Click"
                            Style='<%# (bool)Eval("Enabled") ? "" : "background-color: #0f172a; color: #ffffff; border-color: #0f172a; font-weight: 600;" %>'>
                        </asp:LinkButton>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>
    </div>

    <!-- Code Explanation Drawer -->
    <details class="notion-toggle">
        <summary>View Stored Procedure &amp; Repeater C# Logic</summary>
        <div class="notion-toggle-content">
            <p><strong>SQL Stored Procedure (spGetEmployees_by_PageIndex_and_PageSize):</strong></p>
            <pre class="notion-code-block"><code>CREATE PROC spGetEmployees_by_PageIndex_and_PageSize
    @PageIndex int, 
    @PageSize int,
    @TotalRows int output
AS 
BEGIN 
    SET NOCOUNT ON;
    DECLARE @StartRowIndex int = (@PageIndex * @PageSize) + 1;
    DECLARE @EndRowIndex int = (@PageIndex + 1) * @PageSize;

    SELECT EmployeeId, Name, Gender, City FROM 
    (
        SELECT ROW_NUMBER() OVER (ORDER BY EmployeeId) AS RowNumber, EmployeeId, Name, Gender, City 
        FROM tblEmployee
    ) Employees 
    WHERE RowNumber &gt;= @StartRowIndex AND RowNumber &lt;= @EndRowIndex;

    SELECT @TotalRows = COUNT(*) FROM tblEmployee;
END</code></pre>
        </div>
    </details>
</asp:Content>
