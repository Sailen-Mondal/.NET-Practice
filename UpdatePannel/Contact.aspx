<%@ Page Title="UpdatePanel Triggers" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Contact.aspx.cs" Inherits="UpdatePannel.Contact" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <main>
        <h2>UpdatePanel with Triggers Demo</h2>
        <p>
            Two panels, both with <code>UpdateMode="Conditional"</code>.<br />
            <strong>Update Both Panels</strong> — refreshes Panel 1 directly AND triggers Panel 2 via <code>AsyncPostBackTrigger</code>.<br />
            <strong>Update This Panel</strong> — refreshes only Panel 1 (Panel 2 stays unchanged).
        </p>

        <%-- Panel 1: updates on both button clicks --%>
        <asp:UpdatePanel ID="UpdatePanel1" runat="server" UpdateMode="Conditional">
            <ContentTemplate>
                <fieldset style="width:320px; border:2px solid green; padding:10px;">
                    <legend style="color:green;">Update Panel - 1</legend>
                    <asp:Label ID="lbl1" runat="server" ForeColor="Green"></asp:Label>
                    <br /><br />
                    <%-- Both buttons live in Panel 1 --%>
                    <asp:Button ID="btnBoth" runat="server" Text="Update Both Panels"
                        OnClick="btnBoth_Click" />
                    &nbsp;
                    <asp:Button ID="btnThis" runat="server" Text="Update This Panel"
                        OnClick="btnThis_Click" />
                </fieldset>
            </ContentTemplate>
        </asp:UpdatePanel>

        <br />

        <%--
            Panel 2: only updates when btnBoth fires — controlled by AsyncPostBackTrigger.
            btnThis does NOT trigger this panel, so lbl2 stays unchanged when that button is clicked.
        --%>
        <asp:UpdatePanel ID="UpdatePanel2" runat="server" UpdateMode="Conditional">
            <ContentTemplate>
                <fieldset style="width:320px; border:2px solid red; padding:10px;">
                    <legend style="color:red;">Update Panel - 2</legend>
                    <asp:Label ID="lbl2" runat="server" ForeColor="Red"></asp:Label>
                </fieldset>
            </ContentTemplate>
            <Triggers>
                <%-- Only btnBoth's Click event triggers this panel --%>
                <asp:AsyncPostBackTrigger ControlID="btnBoth" EventName="Click" />
            </Triggers>
        </asp:UpdatePanel>

    </main>
</asp:Content>
