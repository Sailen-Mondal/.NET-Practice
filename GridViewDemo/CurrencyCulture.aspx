<%@ Page Title="Multi-Culture & Currency" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="CurrencyCulture.aspx.cs" Inherits="GridViewDemo.CurrencyCulture" ResponseEncoding="utf-8" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="notion-breadcrumb">
        <a href="Default.aspx">Overview</a> / <span>Topic 03: Multi-Culture &amp; Row-Level Globalization</span>
    </div>

    <div class="notion-page-header">
        <span class="notion-page-badge">Topic 03</span>
        <h1 class="notion-page-title">Multi-Culture Currency Formatting</h1>
        <p class="notion-page-desc">
            Format currency symbols dynamically for distinct countries (US, UK, India, South Africa, Malaysia) in a single GridView using the RowDataBound event.
        </p>
    </div>

    <!-- Globalization Callout -->
    <div class="notion-callout">
        <div class="notion-callout-title">Globalization Mechanics in ASP.NET</div>
        <p style="margin: 0;">
            Standard <code>{0:c}</code> formats currency using the server culture, web.config (<code>&lt;globalization culture="en-US" /&gt;</code>), or page directive (<code>&lt;%@ Page Culture="en-GB" %&gt;</code>). For row-by-row international data, formatting is applied dynamically inside the <code>RowDataBound</code> event via <code>string.Format(new CultureInfo(culture), "{0:c}", salary)</code>.
        </p>
    </div>

    <!-- Live Multi-Culture GridView Card -->
    <div class="notion-card">
        <div class="notion-card-header">
            <h3 class="notion-card-title">International Compensation Dataset</h3>
            <span class="notion-tag notion-tag-neutral">Event: RowDataBound</span>
        </div>

        <asp:SqlDataSource ID="SqlDataSource1" runat="server" 
            ConnectionString="<%$ ConnectionStrings:DBConnectionString %>" 
            SelectCommand="SELECT EmployeeId, FirstName, Salary, Country FROM [tblEmployee] ORDER BY EmployeeId">
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
                    <asp:BoundField DataField="EmployeeId" HeaderText="ID" ItemStyle-Width="60px" />
                    <asp:BoundField DataField="FirstName" HeaderText="Employee Name" ItemStyle-Width="200px" />
                    <asp:BoundField DataField="Salary" HeaderText="Formatted Salary" ItemStyle-Width="220px" />
                    <asp:BoundField DataField="Country" HeaderText="Country" ItemStyle-Width="180px" />
                </Columns>
            </asp:GridView>
        </div>
    </div>

    <!-- Supported Cultures Explorer -->
    <div class="notion-card">
        <div class="notion-card-header">
            <h3 class="notion-card-title">Supported .NET Cultures Explorer</h3>
            <div style="display: flex; gap: 8px;">
                <asp:TextBox ID="txtCultureSearch" runat="server" CssClass="notion-input" Placeholder="Search by country or code (e.g. India, en, GB)..." Width="280px"></asp:TextBox>
                <asp:Button ID="btnSearchCulture" runat="server" Text="Filter" CssClass="btn-notion btn-notion-primary" OnClick="btnSearchCulture_Click" />
            </div>
        </div>

        <div style="max-height: 220px; overflow-y: auto; border: 1px solid #e2e8f0; border-radius: 4px; padding: 12px; background: #ffffff;">
            <asp:Literal ID="litCultures" runat="server"></asp:Literal>
        </div>
    </div>

    <!-- Code Explanation Drawer -->
    <details class="notion-toggle">
        <summary>View RowDataBound Multi-Culture Implementation</summary>
        <div class="notion-toggle-content">
            <pre class="notion-code-block"><code>protected void GridView1_RowDataBound(object sender, GridViewRowEventArgs e)
{
    if (e.Row.RowType == DataControlRowType.DataRow)
    {
        string country = e.Row.Cells[3].Text.Trim();
        int salary = Convert.ToInt32(e.Row.Cells[2].Text);
        string formattedString = "";

        if (country == "US")
            formattedString = string.Format(new CultureInfo("en-US"), "{0:c}", salary);
        else if (country == "UK")
            formattedString = string.Format(new CultureInfo("en-GB"), "{0:c}", salary);
        else if (country == "India")
            formattedString = string.Format(new CultureInfo("en-IN"), "{0:c}", salary);
        else if (country == "South Africa")
            formattedString = string.Format(new CultureInfo("en-ZA"), "{0:c}", salary);
        else if (country == "Malaysia")
            formattedString = string.Format(new CultureInfo("en-MY"), "{0:c}", salary);

        e.Row.Cells[2].Text = formattedString;
    }
}</code></pre>
        </div>
    </details>
</asp:Content>
