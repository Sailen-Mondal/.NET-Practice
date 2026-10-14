<%@ Page Title="LinkButton Demo" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="UpdatePannel._Default" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <main>
        <h2>ASP.NET LinkButton</h2>
        <p>
            A <strong>LinkButton</strong> renders as a hyperlink in the browser,
            but clicking it causes a <em>full server postback</em> — just like a regular Button.
        </p>

        <p>It is a hyperlink-style button:</p>

        <%-- LinkButton: looks like a link, works like a button --%>
        <asp:LinkButton ID="LinkButton1" runat="server" OnClick="LinkButton1_Click">
            Click Here
        </asp:LinkButton>

        <p>
            <asp:Label ID="Label1" runat="server" ForeColor="Green"></asp:Label>
        </p>
    </main>
</asp:Content>
