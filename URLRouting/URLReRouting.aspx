<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="URLReRouting.aspx.cs" Inherits="URLRouting.URL_ReRouting" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>URL Routing Demo</title>
    <style type="text/css">
        body {
            font-family: Arial, sans-serif;
            margin: 20px;
        }
        .info-box {
            background-color: #f4f8fa;
            border-left: 4px solid #007acc;
            padding: 12px;
            margin-bottom: 20px;
        }
        .ArticleTitle {
            font-weight: bold;
            color: #8C4510;
            text-decoration: underline;
        }
        .ArticleTitle:hover {
            color: #009900;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div>
            <h1><span style="color: #009900">URL Routing</span></h1>
            
            <div class="info-box">
                <b>Beginner Concept:</b> Notice how clicking an article title navigates to a friendly routed URL like
                <code>/Articles/1/How-to-validate-dropdownlist-in-asp.net</code> instead of 
                <code>/DetailPage.aspx?id=1</code>.
            </div>

            <asp:GridView ID="GridView1" runat="server" AutoGenerateColumns="False" BackColor="#DEBA84" 
                BorderColor="#DEBA84" BorderStyle="None" BorderWidth="1px" CellPadding="3" CellSpacing="2" 
                Width="850px" Height="80px">
                <FooterStyle BackColor="#F7DFB5" ForeColor="#8C4510" />
                <Columns>
                    <asp:TemplateField HeaderText="Title">
                        <ItemTemplate>
                            <asp:HyperLink ID="HyperLink1" runat="server" CssClass="ArticleTitle" 
                                NavigateUrl='<%# GetRouteUrl("RouteForArticle", new { id = Eval("id"), Title = GetTitle(Eval("Title")) }) %>' 
                                Text='<%# Eval("Title") %>'>
                            </asp:HyperLink>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Description">
                        <ItemTemplate>
                            <asp:Label ID="lblDesc" runat="server" Text='<%# DataBinder.Eval(Container.DataItem, "Description") %>'></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Author">
                        <ItemTemplate>
                            <asp:Label ID="lblauthor" runat="server" Text='<%# DataBinder.Eval(Container.DataItem, "Author") %>'></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
                <RowStyle BackColor="#FFF7E7" ForeColor="#8C4510" />
                <SelectedRowStyle BackColor="#738A9C" Font-Bold="True" ForeColor="White" />
                <PagerStyle ForeColor="#8C4510" HorizontalAlign="Center" />
                <HeaderStyle BackColor="#A55129" Font-Bold="True" ForeColor="White" />
            </asp:GridView>

            <br />
            <a href="PageRedirectionDemo.aspx">&larr; Back to Page Redirection Demo</a> | 
            <a href="Default.aspx">Home</a>
        </div>
    </form>
</body>
</html>
