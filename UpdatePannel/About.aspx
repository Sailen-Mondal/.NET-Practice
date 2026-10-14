<%@ Page Title="UpdatePanel + UpdateProgress" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="About.aspx.cs" Inherits="UpdatePannel.About" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <main>
        <h2>UpdatePanel + UpdateProgress Demo</h2>
        <p>
            <strong>UpdatePanel</strong> refreshes only its inner content (partial postback),
            so the rest of the page does NOT flicker.<br />
            <strong>UpdateProgress</strong> shows a "Please wait..." message during the async call.
        </p>

        <%--
            UpdatePanel wraps the controls that need async refresh.
            ScriptManager is already on Site.Master — no need to add it here.
        --%>
        <asp:UpdatePanel ID="UpdatePanel1" runat="server" UpdateMode="Conditional">
            <ContentTemplate>

                <%-- This label shows current time — only this area re-renders --%>
                <asp:Label ID="lblResult" runat="server" ForeColor="Blue"></asp:Label>
                <br /><br />

                <table border="1" cellpadding="6">
                    <tr>
                        <td>Name</td>
                        <td>
                            <asp:TextBox ID="txtName" runat="server"></asp:TextBox>
                            <asp:RequiredFieldValidator runat="server" ControlToValidate="txtName"
                                Text=" * Required" ForeColor="Red"></asp:RequiredFieldValidator>
                        </td>
                    </tr>
                    <tr>
                        <td>Address</td>
                        <td>
                            <asp:TextBox ID="txtAddress" runat="server"></asp:TextBox>
                            <asp:RequiredFieldValidator runat="server" ControlToValidate="txtAddress"
                                Text=" * Required" ForeColor="Red"></asp:RequiredFieldValidator>
                        </td>
                    </tr>
                    <tr>
                        <td colspan="2">
                            <%-- This button triggers async postback inside UpdatePanel --%>
                            <asp:Button ID="btnSave" runat="server" Text="Add Record"
                                OnClick="btnSave_Click" />
                        </td>
                    </tr>
                </table>

            </ContentTemplate>
        </asp:UpdatePanel>

        <%--
            UpdateProgress is shown ONLY while the UpdatePanel is processing.
            AssociatedUpdatePanelID links it to UpdatePanel1.
            DisplayAfter="500" waits 500ms before showing (avoids flicker on fast calls).
        --%>
        <asp:UpdateProgress ID="UpdateProgress1" runat="server"
            AssociatedUpdatePanelID="UpdatePanel1" DisplayAfter="500">
            <ProgressTemplate>
                <span style="color: darkorange; font-weight: bold;">
                    &#9203; Please wait...
                </span>
            </ProgressTemplate>
        </asp:UpdateProgress>

    </main>
</asp:Content>
