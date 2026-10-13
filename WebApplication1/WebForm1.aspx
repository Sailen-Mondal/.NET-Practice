<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="WebForm1.aspx.cs" Inherits="WebApplication1.WebForm1" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>WebForm1</title>
</head>
<body>
    <form id="form1" runat="server">
        <div style="font-family: Arial; padding: 20px;">
            <h3>State Management - ViewState Demo</h3>

            <!-- 1. Without ViewState -->
            <b>Without ViewState (Stuck at 1):</b><br />
            <asp:TextBox ID="TextBox1" runat="server"></asp:TextBox>
            <asp:Button ID="Button1" runat="server" Text="Click Me" OnClick="Button1_Click" />

            <br /><br /><br />

            <!-- 2. With ViewState -->
            <b>With ViewState (Increments):</b><br />
            <asp:TextBox ID="TextBox2" runat="server"></asp:TextBox>
            <asp:Button ID="Button2" runat="server" Text="Click Me" OnClick="Button2_Click" />
        </div>
    </form>
</body>
</html>
