<%@ Page Title="User Directory" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="UserDirectory.aspx.cs" Inherits="WebServices.UserDirectory" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <h1 class="page-title">User Directory</h1>
    <p class="page-subtitle">Consuming an ASP.NET SOAP Web Service returning XML (<code>XmlElement</code>) over HTTP.</p>

    <div class="notion-callout">
        <svg class="callout-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/>
        </svg>
        <div>
            <strong>How this works:</strong> The consumer calls <code>UserService.asmx.GetUserDetails(userName)</code>. 
            The web service queries <code>UserInformation</code> using a SQL LIKE statement, loads the data into a <code>DataSet</code>, 
            and converts it into an <code>XmlElement</code>. 
            The consumer then reads this XML using <code>XmlNodeReader</code> and binds it directly to the <code>GridView</code> below.
        </div>
    </div>

    <!-- Search Controls -->
    <div class="notion-form-row">
        <span class="notion-form-label">Search Username:</span>
        <asp:TextBox ID="txtUserName" runat="server" CssClass="notion-input" placeholder="e.g. john, jane, or leave blank"></asp:TextBox>
        <asp:Button ID="btnSubmit" runat="server" Text="Search" CssClass="notion-btn" OnClick="btnSubmit_Click" />
        <asp:Button ID="btnReset" runat="server" Text="Show All" CssClass="notion-btn notion-btn-secondary" OnClick="btnReset_Click" />
    </div>

    <!-- Row Count Badge -->
    <span class="gv-count">
        <asp:Literal ID="litCount" runat="server" />
    </span>

    <!-- GridView Display -->
    <div class="gv-wrap">
        <asp:GridView
            ID="gvUserDetails"
            runat="server"
            AutoGenerateColumns="False"
            GridLines="None"
            CssClass="notion-table"
            EmptyDataText="No records found matching your search.">

            <EmptyDataRowStyle CssClass="gv-empty" />

            <Columns>
                <asp:BoundField DataField="userID"    HeaderText="User ID"    ItemStyle-Width="80px" />
                <asp:BoundField DataField="UserName"  HeaderText="Username"   ItemStyle-Width="180px" />
                <asp:BoundField DataField="FirstName" HeaderText="First Name" ItemStyle-Width="180px" />
                <asp:BoundField DataField="LastName"  HeaderText="Last Name"  ItemStyle-Width="180px" />
                <asp:BoundField DataField="Location"  HeaderText="Location"   ItemStyle-Width="200px" />
            </Columns>
        </asp:GridView>
    </div>

    <hr class="notion-divider" />

    <h3 class="notion-h3">Under the Hood: Key C# Patterns</h3>
    <div class="notion-callout" style="background:#fff;">
        <svg class="callout-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <polyline points="16 18 22 12 16 6"/><polyline points="8 6 2 12 8 18"/>
        </svg>
        <div>
            <p class="notion-p" style="margin-bottom:6px;"><strong>WebMethod XML Serialization:</strong></p>
            <code>
                DataSet ds = new DataSet("UserData");<br />
                da.Fill(ds);<br />
                XmlDocument doc = new XmlDocument();<br />
                doc.LoadXml(ds.GetXml());<br />
                return doc.DocumentElement; // Returns XmlElement over SOAP
            </code>
            <p class="notion-p" style="margin-top:12px; margin-bottom:6px;"><strong>Consumer Deserialization into GridView:</strong></p>
            <code>
                XmlElement exelement = service.GetUserDetails(userName);<br />
                XmlNodeReader nodereader = new XmlNodeReader(exelement);<br />
                dsresult.ReadXml(nodereader, XmlReadMode.Auto);<br />
                gvUserDetails.DataSource = dsresult;<br />
                gvUserDetails.DataBind();
            </code>
        </div>
    </div>
</asp:Content>
