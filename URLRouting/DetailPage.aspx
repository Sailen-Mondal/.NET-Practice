<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="DetailPage.aspx.cs" Inherits="URLRouting.DetailPage" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Article Detail Page</title>
    <style type="text/css">
        body {
            font-family: Arial, sans-serif;
            margin: 20px;
        }
        .article-card {
            background-color: #fafafa;
            border: 1px solid #ddd;
            border-radius: 6px;
            padding: 20px;
            max-width: 750px;
        }
        .route-info {
            background-color: #e8f4fd;
            border: 1px solid #b6e0fe;
            padding: 10px;
            margin-bottom: 15px;
            border-radius: 4px;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="article-card">
            <h1>Article Details</h1>

            <div class="route-info">
                <b>Route Parameter Extracted:</b> 
                Article ID = <asp:Label ID="lblRouteId" runat="server" Font-Bold="true" ForeColor="#0066cc"></asp:Label> |
                Route Title = <asp:Label ID="lblRouteTitle" runat="server" Font-Bold="true" ForeColor="#0066cc"></asp:Label>
            </div>

            <p>
                <b>Title: </b>
                <asp:Label ID="lblTitle" runat="server" Text="Label" Font-Bold="true" ForeColor="blue"></asp:Label>
            </p>

            <p>
                <b>Author Name: </b>
                <asp:Label ID="lblauthor" runat="server" Text="Label" Font-Bold="true" ForeColor="blue"></asp:Label>
            </p>

            <p>
                <b>Description:</b><br />
                <asp:Label ID="lblDescription" runat="server" Text="Label"></asp:Label>
            </p>

            <hr />
            <a href="URLRouting.aspx">&larr; Back to Articles List (URLRouting.aspx)</a> | 
            <a href="PageRedirectionDemo.aspx">Page Redirection Demo</a> | 
            <a href="Default.aspx">Home</a>
        </div>
    </form>
</body>
</html>
