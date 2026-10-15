<%@ Page Title="About" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="About.aspx.cs" Inherits="MasterPageDemo.About" ContentType="text/html; charset=utf-8" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">

    <h1 class="page-title">About</h1>
    <p class="page-subtitle">Understanding the role of the Master Page and meet the team.</p>

    <h3 class="notion-h3">What is a Master Page?</h3>
    <p class="notion-p">
        A Master Page in ASP.NET Web Forms acts as a <strong>template</strong> for your application.
        It defines the overall structure — the header, navigation, sidebar, and footer — so you only
        write that layout code once.
    </p>
    <p class="notion-p">
        Every content page that references <code>Site.Master</code> automatically inherits the full
        layout. You only author the body-specific content in each <code>.aspx</code> file.
    </p>

    <div class="notion-quote">
        Write the layout once, inherit it everywhere — that is the Master Page philosophy.
    </div>

    <hr class="notion-divider" />

    <h3 class="notion-h3">Team Members</h3>
    <p class="notion-p">Use the search bar above to filter by name, role, department, or location.</p>

    <%-- Search badge --%>
    <asp:Panel ID="SearchBadge" runat="server" Visible="false" CssClass="search-badge">
        Results for: <strong><asp:Literal ID="LitQuery" runat="server" /></strong>
        &nbsp;&middot;&nbsp;
        <a runat="server" href="~/About.aspx">Clear search</a>
    </asp:Panel>

    <span class="gv-count">
        <asp:Literal ID="LitCount" runat="server" />
    </span>

    <div class="gv-wrap">
        <asp:GridView
            ID="TeamGrid"
            runat="server"
            AutoGenerateColumns="False"
            GridLines="None"
            CssClass="gv">

            <EmptyDataRowStyle CssClass="gv-empty" />
            <EmptyDataTemplate>
                No team members match your search. <a runat="server" href="~/About.aspx">Clear search</a>
            </EmptyDataTemplate>

            <Columns>
                <asp:BoundField DataField="Name"       HeaderText="Name" />
                <asp:BoundField DataField="Role"       HeaderText="Role" />
                <asp:BoundField DataField="Department" HeaderText="Department" />
                <asp:BoundField DataField="Location"   HeaderText="Location" />
            </Columns>
        </asp:GridView>
    </div>

    <hr class="notion-divider" />

    <h3 class="notion-h3">Tags</h3>
    <span class="notion-tag">ASP.NET</span>&nbsp;
    <span class="notion-tag">Web Forms</span>&nbsp;
    <span class="notion-tag">Master Page</span>&nbsp;
    <span class="notion-tag">.NET Framework</span>

</asp:Content>
