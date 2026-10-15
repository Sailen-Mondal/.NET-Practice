<%@ Page Title="Home" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="MasterPageDemo._Default" ContentType="text/html; charset=utf-8" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">

    <h1 class="page-title">Home</h1>
    <p class="page-subtitle">Welcome to the ASP.NET Web Forms Master Page demonstration.</p>

    <div class="notion-callout">
        <svg class="callout-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/>
        </svg>
        <span>
            The <strong>header</strong>, <strong>sidebar navigation</strong>, and <strong>footer</strong> you see on every page are defined
            once inside <code>Site.Master</code>. Use the <strong>search bar</strong> in the top bar to filter the articles below.
        </span>
    </div>

    <hr class="notion-divider" />

    <h3 class="notion-h3">Articles</h3>

    <%-- Search badge: visible only when a filter is active --%>
    <asp:Panel ID="SearchBadge" runat="server" Visible="false" CssClass="search-badge">
        Results for: <strong><asp:Literal ID="LitQuery" runat="server" /></strong>
        &nbsp;&middot;&nbsp;
        <a runat="server" href="~/">Clear search</a>
    </asp:Panel>

    <%-- Row count label --%>
    <span class="gv-count">
        <asp:Literal ID="LitCount" runat="server" />
    </span>

    <div class="gv-wrap">
        <asp:GridView
            ID="ArticleGrid"
            runat="server"
            AutoGenerateColumns="False"
            GridLines="None"
            CssClass="gv">

            <EmptyDataRowStyle CssClass="gv-empty" />
            <EmptyDataTemplate>
                No articles match your search. <a runat="server" href="~/">Clear search</a>
            </EmptyDataTemplate>

            <Columns>
                <asp:BoundField DataField="Id"          HeaderText="#"            ItemStyle-Width="40px" />
                <asp:BoundField DataField="Title"       HeaderText="Title" />
                <asp:BoundField DataField="Category"    HeaderText="Category" />
                <asp:BoundField DataField="Author"      HeaderText="Author" />
                <asp:BoundField DataField="Date"        HeaderText="Date"         ItemStyle-Width="100px" />
                <asp:BoundField DataField="Description" HeaderText="Description"  ItemStyle-Width="320px" />
            </Columns>
        </asp:GridView>
    </div>

</asp:Content>
