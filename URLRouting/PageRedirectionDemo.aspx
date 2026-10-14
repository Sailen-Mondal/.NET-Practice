<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PageRedirectionDemo.aspx.cs" Inherits="URLRouting.PageRedirectionDemo" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Page Redirection Demo - Response.Redirect</title>
    <style type="text/css">
        body {
            font-family: Arial, sans-serif;
            margin: 20px;
            background-color: #fcfcfc;
        }
        .container {
            max-width: 800px;
            background: #fff;
            padding: 25px;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        .demo-section {
            border: 1px solid #e0e0e0;
            border-radius: 6px;
            padding: 15px;
            margin-bottom: 20px;
            background-color: #fafafa;
        }
        .demo-title {
            font-weight: bold;
            color: #333;
            margin-bottom: 8px;
        }
        .note {
            background-color: #fff8e1;
            border-left: 4px solid #ffb300;
            padding: 10px;
            font-size: 13px;
            margin-top: 10px;
        }
        .btn-custom {
            padding: 8px 16px;
            background-color: #0078d4;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
        }
        .btn-custom:hover {
            background-color: #005a9e;
        }
        .btn-external {
            padding: 8px 16px;
            background-color: #107c41;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="container">
            <h1 style="color: #0078d4;">Page Redirection in ASP.NET</h1>
            <p>This page demonstrates the concepts of <b>HyperLink</b> vs <b>Response.Redirect</b>.</p>

            <!-- Section 1: HyperLink Control (Client-side Navigation) -->
            <div class="demo-section">
                <div class="demo-title">1. HyperLink Control (Client-Side Navigation)</div>
                <p>A Hyperlink navigates directly on the client side without triggering any server-side events.</p>
                <asp:HyperLink ID="hypArticles" runat="server" NavigateUrl="~/URLRouting.aspx" ForeColor="#0066cc" Font-Bold="true">
                    &rarr; Click here to visit Articles (via HyperLink)
                </asp:HyperLink>
                <div class="note">
                    <b>Note:</b> The HyperLink control does not expose any server-side events. You cannot intercept the click event in C# code before redirecting.
                </div>
            </div>

            <!-- Section 2: Button Server Control (Intercept Click with Response.Redirect) -->
            <div class="demo-section">
                <div class="demo-title">2. Button Server Control (Intercepting Click with Response.Redirect)</div>
                <p>When you need to execute code on the server (like logging, validation, or saving state) before redirecting:</p>
                Name: <asp:TextBox ID="txtUserName" runat="server" placeholder="Enter your name"></asp:TextBox>
                <br /><br />
                <asp:Button ID="btnRedirectInternal" runat="server" Text="Save to Session & Redirect to Articles" CssClass="btn-custom" OnClick="btnRedirectInternal_Click" />
                <div class="note">
                    <b>Under the Hood (2 Request/Response Cycles):</b><br />
                    1. Browser sends a POST request to the server when the button is clicked.<br />
                    2. Server executes <code>btnRedirectInternal_Click</code> and returns an <b>HTTP 302 (Found)</b> redirect header with the target URL.<br />
                    3. Browser automatically issues a new <b>HTTP GET</b> request to the target URL.<br />
                    4. The URL in the address bar updates and the browser history is maintained.
                </div>
            </div>

            <!-- Section 3: LinkButton Server Control -->
            <div class="demo-section">
                <div class="demo-title">3. LinkButton Server Control</div>
                <p>A LinkButton looks like a hyperlink, but posts back to the server so you can intercept the click:</p>
                <asp:LinkButton ID="lnkBtnArticles" runat="server" OnClick="lnkBtnArticles_Click" ForeColor="#d83b01" Font-Bold="true">
                    &rarr; Intercept click on server & Redirect via LinkButton
                </asp:LinkButton>
            </div>

            <!-- Section 4: Redirecting to an External Web Server -->
            <div class="demo-section">
                <div class="demo-title">4. Redirecting to an External Website (Different Web Server)</div>
                <p><code>Response.Redirect()</code> can navigate to pages on the same server OR to a different web server entirely:</p>
                <asp:Button ID="btnRedirectExternal" runat="server" Text="Redirect to Microsoft.com (External Server)" CssClass="btn-external" OnClick="btnRedirectExternal_Click" />
            </div>

            <hr />
            <a href="URLRouting.aspx">Go to URL Routing Demo &rarr;</a> | 
            <a href="Default.aspx">Home</a>
        </div>
    </form>
</body>
</html>
