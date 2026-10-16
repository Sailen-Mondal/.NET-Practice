<%@ Page Title="Formatting & Column Control" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="FormattingBasics.aspx.cs" Inherits="GridViewDemo.FormattingBasics" ResponseEncoding="utf-8" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="notion-breadcrumb">
        <a href="Default.aspx">Overview</a> / <span>Topic 02: Formatting &amp; Column Control</span>
    </div>

    <div class="notion-page-header">
        <span class="notion-page-badge">Topic 02</span>
        <h1 class="notion-page-title">Column Control &amp; Data Formatting</h1>
        <p class="notion-page-desc">
            Techniques to hide columns, customize column HeaderText with spaces, and apply DataFormatString for Date ({0:d} vs {0:D}) and Currency ({0:c}).
        </p>
    </div>

    <!-- 3 Ways Callout -->
    <div class="notion-callout">
        <div class="notion-callout-title">Three Methods to Hide Columns (e.g. EmployeeId)</div>
        <ol style="margin: 4px 0 0 16px; padding: 0;">
            <li><strong>SQL Query Projection:</strong> Exclude the column from the SELECT statement.</li>
            <li><strong>Omit BoundField:</strong> Do not include the <code>&lt;asp:BoundField DataField="EmployeeId"&gt;</code> in GridView columns.</li>
            <li><strong>Visible Property:</strong> Set <code>Visible="false"</code> directly on the BoundField.</li>
        </ol>
    </div>

    <!-- Live Controls & GridView Card -->
    <div class="notion-card">
        <div class="notion-card-header">
            <h3 class="notion-card-title">Employee Roster</h3>
            <div style="display: flex; gap: 12px; align-items: center; flex-wrap: wrap;">
                <label style="font-size: 13px; font-weight: 500; color: #475569;">Date Format:</label>
                <asp:DropDownList ID="ddlDateFormat" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlDateFormat_SelectedIndexChanged" CssClass="notion-select" Width="150px">
                    <asp:ListItem Value="{0:d}" Selected="True">Short Date ({0:d})</asp:ListItem>
                    <asp:ListItem Value="{0:D}">Long Date ({0:D})</asp:ListItem>
                </asp:DropDownList>

                <label style="font-size: 13px; font-weight: 500; color: #475569; margin-left: 8px;">Employee ID:</label>
                <asp:DropDownList ID="ddlIdVisibility" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlIdVisibility_SelectedIndexChanged" CssClass="notion-select" Width="140px">
                    <asp:ListItem Value="Hidden" Selected="True">Hidden (Visible=false)</asp:ListItem>
                    <asp:ListItem Value="Visible">Show ID Column</asp:ListItem>
                </asp:DropDownList>
            </div>
        </div>

        <asp:SqlDataSource ID="SqlDataSource1" runat="server" 
            ConnectionString="<%$ ConnectionStrings:DBConnectionString %>" 
            SelectCommand="SELECT EmployeeId, FirstName, LastName, DateOfBirth, Salary, Gender, DepartmentName FROM [tblEmployee]">
        </asp:SqlDataSource>

        <div class="notion-grid-wrapper">
            <asp:GridView ID="GridView1" runat="server" 
                AutoGenerateColumns="False" 
                DataKeyNames="EmployeeId" 
                DataSourceID="SqlDataSource1"
                CssClass="notion-grid"
                GridLines="None"
                OnRowDataBound="GridView1_RowDataBound">
                <Columns>
                    <asp:BoundField DataField="EmployeeId" HeaderText="Employee ID" Visible="false" />
                    <asp:BoundField DataField="FirstName" HeaderText="First Name" />
                    <asp:BoundField DataField="LastName" HeaderText="Last Name" />
                    <asp:BoundField DataField="DateOfBirth" HeaderText="Date Of Birth" DataFormatString="{0:d}" HtmlEncode="false" />
                    <asp:BoundField DataField="Salary" HeaderText="Annual Salary" DataFormatString="{0:c}" HtmlEncode="false" />
                    <asp:TemplateField HeaderText="Gender">
                        <ItemTemplate>
                            <span class='notion-tag <%# Eval("Gender").ToString() == "Male" ? "notion-tag-male" : "notion-tag-female" %>'>
                                <%# Eval("Gender") %>
                            </span>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Department">
                        <ItemTemplate>
                            <span class='notion-tag <%# Eval("DepartmentName").ToString() == "IT" ? "notion-tag-it" : (Eval("DepartmentName").ToString() == "HR" ? "notion-tag-hr" : "notion-tag-payroll") %>'>
                                <%# Eval("DepartmentName") %>
                            </span>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
        </div>
    </div>

    <!-- Code Explanation Drawer -->
    <details class="notion-toggle">
        <summary>View Markup &amp; Formatting Configuration</summary>
        <div class="notion-toggle-content">
            <pre class="notion-code-block"><code>&lt;asp:GridView ID="GridView1" runat="server" AutoGenerateColumns="False" 
    DataKeyNames="EmployeeId" DataSourceID="SqlDataSource1"&gt;
    &lt;Columns&gt;
        &lt;!-- 1. Hidden EmployeeId --&gt;
        &lt;asp:BoundField DataField="EmployeeId" HeaderText="Employee ID" Visible="false" /&gt;
        
        &lt;!-- 2. HeaderText with explicit spacing --&gt;
        &lt;asp:BoundField DataField="FirstName" HeaderText="First Name" /&gt;
        &lt;asp:BoundField DataField="LastName" HeaderText="Last Name" /&gt;
        
        &lt;!-- 3. Short Date Formatting --&gt;
        &lt;asp:BoundField DataField="DateOfBirth" HeaderText="Date Of Birth" 
            DataFormatString="{0:d}" HtmlEncode="false" /&gt;
        
        &lt;!-- 4. Currency Formatting --&gt;
        &lt;asp:BoundField DataField="Salary" HeaderText="Annual Salary" 
            DataFormatString="{0:c}" HtmlEncode="false" /&gt;
    &lt;/Columns&gt;
&lt;/asp:GridView&gt;</code></pre>
        </div>
    </details>
</asp:Content>
