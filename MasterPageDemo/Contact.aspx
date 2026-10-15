<%@ Page Title="Contact" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Contact.aspx.cs" Inherits="MasterPageDemo.Contact" ContentType="text/html; charset=utf-8" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">

    <h1 class="page-title">Contact</h1>
    <p class="page-subtitle">Get in touch with the right team. Use the search bar to filter by name, email, department, or phone.</p>

    <%-- Search badge --%>
    <asp:Panel ID="SearchBadge" runat="server" Visible="false" CssClass="search-badge">
        Results for: <strong><asp:Literal ID="LitQuery" runat="server" /></strong>
        &nbsp;&middot;&nbsp;
        <a runat="server" href="~/Contact.aspx">Clear search</a>
    </asp:Panel>

    <span class="gv-count">
        <asp:Literal ID="LitCount" runat="server" />
    </span>

    <div class="gv-wrap">
        <asp:GridView
            ID="ContactGrid"
            runat="server"
            AutoGenerateColumns="False"
            GridLines="None"
            CssClass="gv">

            <EmptyDataRowStyle CssClass="gv-empty" />
            <EmptyDataTemplate>
                No contacts match your search. <a runat="server" href="~/Contact.aspx">Clear search</a>
            </EmptyDataTemplate>

            <Columns>
                <asp:BoundField DataField="Name"       HeaderText="Name" />
                <asp:BoundField DataField="Email"      HeaderText="Email" />
                <asp:BoundField DataField="Department" HeaderText="Department" />
                <asp:BoundField DataField="Phone"      HeaderText="Phone" />
            </Columns>
        </asp:GridView>
    </div>

    <hr class="notion-divider" />

    <div class="notion-callout">
        <svg class="callout-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/>
        </svg>
        <span>
            This page shares the same sidebar, top bar, and search bar as <strong>Home</strong> and <strong>About</strong>.
            Only the GridView data is different — it is bound to <code>SampleData.GetContacts()</code> in <code>Contact.aspx.cs</code>.
        </span>
    </div>

</asp:Content>
