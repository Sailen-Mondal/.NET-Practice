<%@ Page Title="Products Master" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Products.aspx.cs" Inherits="GridViewDemo.Products" ResponseEncoding="utf-8" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="notion-breadcrumb">
        <a href="Default.aspx">Overview</a> / <span>Topic 11: Master-Detail &amp; ItemTemplate Controls</span>
    </div>

    <div class="notion-page-header">
        <span class="notion-page-badge">Topic 11</span>
        <h1 class="notion-page-title">Master-Detail Navigation &amp; ItemTemplate Access</h1>
        <p class="notion-page-desc">
            Retrieve a value from a control inside a GridView TemplateField (LinkButton ID) and navigate to a detailed view using QueryString parameters.
        </p>
    </div>

    <!-- Concept Callout -->
    <div class="notion-callout">
        <div class="notion-callout-title">ItemTemplate Event Access Pattern</div>
        <p style="margin: 0;">
            Inside the <code>TemplateField</code>, the <code>&lt;asp:LinkButton&gt;</code> has its text bound to <code>&lt;%# Eval("ID") %&gt;</code>. In code-behind, the event sender is cast to <code>(LinkButton)sender</code>, providing access to its text property to redirect with <code>Response.Redirect("~/ProductDetails.aspx?ID=" + ((LinkButton)sender).Text)</code>.
        </p>
    </div>

    <!-- Live GridView Card -->
    <div class="notion-card">
        <div class="notion-card-header">
            <h3 class="notion-card-title">Products Catalog</h3>
            <span class="notion-tag notion-tag-neutral">Stored Procedure: spGetBasicProductDetails</span>
        </div>

        <div class="notion-grid-wrapper">
            <asp:GridView ID="GridView1" runat="server" 
                AutoGenerateColumns="False"
                CssClass="notion-grid"
                GridLines="None">
                <Columns>
                    <asp:TemplateField HeaderText="Product ID" ItemStyle-Width="120px">
                        <ItemTemplate>
                            <asp:LinkButton ID="LinkButton1" runat="server" 
                                OnClick="LinkButton1_Click"
                                Text='<%# Eval("ID") %>' 
                                CssClass="notion-action-link"
                                Style="color: #2563eb; font-weight: 600;">
                            </asp:LinkButton>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:BoundField DataField="Name" HeaderText="Product Name" ItemStyle-Width="300px" />
                    
                    <asp:TemplateField HeaderText="Price" ItemStyle-Width="150px">
                        <ItemTemplate>
                            <span style="font-weight: 600; color: #16a34a;">
                                <%# "$" + Eval("Price") %>
                            </span>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Actions">
                        <ItemTemplate>
                            <a href='ProductDetails.aspx?ID=<%# Eval("ID") %>' class="btn-notion btn-notion-sm">
                                View Specs &rarr;
                            </a>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
        </div>
    </div>

    <!-- Code Explanation Drawer -->
    <details class="notion-toggle">
        <summary>View LinkButton &amp; Redirection Code</summary>
        <div class="notion-toggle-content">
            <pre class="notion-code-block"><code>// ASPX Markup:
&lt;asp:TemplateField HeaderText="ID"&gt;
    &lt;ItemTemplate&gt;
        &lt;asp:LinkButton ID="LinkButton1" OnClick="LinkButton1_Click"
            Text='&lt;%#Eval("ID") %&gt;' runat="server"&gt;&lt;/asp:LinkButton&gt;
    &lt;/ItemTemplate&gt;
&lt;/asp:TemplateField&gt;

// C# Code-Behind:
protected void LinkButton1_Click(object sender, EventArgs e)
{
    Response.Redirect("~/ProductDetails.aspx?ID=" + ((LinkButton)sender).Text);
}</code></pre>
        </div>
    </details>
</asp:Content>
