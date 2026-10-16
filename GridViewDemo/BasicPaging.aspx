<%@ Page Title="Basic Binding & Paging" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="BasicPaging.aspx.cs" Inherits="GridViewDemo.BasicPaging" ResponseEncoding="utf-8" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="notion-breadcrumb">
        <a href="Default.aspx">Overview</a> / <span>Topic 01: Basic Data Binding &amp; Paging</span>
    </div>

    <div class="notion-page-header">
        <span class="notion-page-badge">Topic 01</span>
        <h1 class="notion-page-title">Basic Data Binding &amp; Built-in Paging</h1>
        <p class="notion-page-desc">
            Populate an ASP.NET GridView from SQL Server using ADO.NET (SqlDataAdapter &amp; DataTable) and implement built-in pagination.
        </p>
    </div>

    <!-- Concept Callout -->
    <div class="notion-callout">
        <div class="notion-callout-title">Architecture Summary</div>
        <p style="margin: 0;">
            Setting <code>AutoGenerateColumns="false"</code> gives explicit control over each column via <code>&lt;asp:BoundField&gt;</code>. Built-in pagination requires setting <code>AllowPaging="true"</code>, configuring <code>PageSize</code>, and handling the <code>OnPageIndexChanging</code> event to assign <code>GridView.PageIndex = e.NewPageIndex</code> and re-invoke <code>BindGrid()</code>.
        </p>
    </div>

    <!-- Live GridView Card -->
    <div class="notion-card">
        <div class="notion-card-header">
            <h3 class="notion-card-title">Customers Dataset</h3>
            <span class="notion-tag notion-tag-neutral">PageSize: 5</span>
        </div>

        <div class="notion-grid-wrapper">
            <asp:GridView ID="GridView1" runat="server" 
                AutoGenerateColumns="false" 
                AllowPaging="true" 
                PageSize="5"
                OnPageIndexChanging="OnPageIndexChanging"
                CssClass="notion-grid"
                GridLines="None">
                <Columns>
                    <asp:BoundField ItemStyle-Width="120px" DataField="CustomerID" HeaderText="Customer ID" />
                    <asp:BoundField ItemStyle-Width="250px" DataField="ContactName" HeaderText="Contact Name" />
                    <asp:BoundField ItemStyle-Width="180px" DataField="City" HeaderText="City" />
                    <asp:BoundField ItemStyle-Width="180px" DataField="Country" HeaderText="Country" />
                </Columns>
                <PagerStyle CssClass="notion-pager" HorizontalAlign="Center" />
            </asp:GridView>
        </div>
    </div>

    <!-- Code Explanation Drawer -->
    <details class="notion-toggle">
        <summary>View Implementation Code (C# &amp; ASPX)</summary>
        <div class="notion-toggle-content">
            <p><strong>C# Code-Behind (BasicPaging.aspx.cs):</strong></p>
            <pre class="notion-code-block"><code>protected void Page_Load(object sender, EventArgs e)
{
    if (!this.IsPostBack)
    {
        this.BindGrid();
    }
}

private void BindGrid()
{
    string constr = ConfigurationManager.ConnectionStrings["constr"].ConnectionString;
    using (SqlConnection con = new SqlConnection(constr))
    {
        using (SqlCommand cmd = new SqlCommand("SELECT CustomerId, ContactName, City, Country FROM Customers", con))
        {
            using (SqlDataAdapter sda = new SqlDataAdapter(cmd))
            {
                using (DataTable dt = new DataTable())
                {
                    sda.Fill(dt);
                    GridView1.DataSource = dt;
                    GridView1.DataBind();
                }
            }
        }
    }
}

protected void OnPageIndexChanging(object sender, GridViewPageEventArgs e)
{
    GridView1.PageIndex = e.NewPageIndex;
    this.BindGrid();
}</code></pre>
        </div>
    </details>
</asp:Content>
