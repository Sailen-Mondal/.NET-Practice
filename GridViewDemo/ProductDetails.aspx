<%@ Page Title="Product Details" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ProductDetails.aspx.cs" Inherits="GridViewDemo.ProductDetails" ResponseEncoding="utf-8" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="notion-breadcrumb">
        <a href="Default.aspx">Overview</a> / <a href="Products.aspx">Products</a> / <span>Product Details</span>
    </div>

    <div class="notion-page-header">
        <span class="notion-page-badge">Product Specifications</span>
        <h1 class="notion-page-title">
            <asp:Label ID="lblNameHeader" runat="server" Text="Product"></asp:Label>
        </h1>
        <p class="notion-page-desc">
            Detailed technical specifications retrieved using Stored Procedure spGetProductDetailsByID and QueryString ID.
        </p>
    </div>

    <div class="notion-card" style="max-width: 680px;">
        <div class="notion-card-header">
            <h3 class="notion-card-title">Specification Sheet</h3>
            <a href="Products.aspx" class="btn-notion btn-notion-sm">&larr; Back to Products</a>
        </div>

        <table style="width: 100%; border-collapse: collapse; font-size: 13.5px;">
            <tr style="border-bottom: 1px solid #f1f5f9;">
                <td style="padding: 12px 0; font-weight: 600; color: #64748b; width: 180px;">Product ID</td>
                <td style="padding: 12px 0;"><asp:Label ID="lblID" runat="server" Font-Bold="true"></asp:Label></td>
            </tr>
            <tr style="border-bottom: 1px solid #f1f5f9;">
                <td style="padding: 12px 0; font-weight: 600; color: #64748b;">Product Name</td>
                <td style="padding: 12px 0;"><asp:Label ID="lblName" runat="server"></asp:Label></td>
            </tr>
            <tr style="border-bottom: 1px solid #f1f5f9;">
                <td style="padding: 12px 0; font-weight: 600; color: #64748b;">Unit Price</td>
                <td style="padding: 12px 0; color: #16a34a; font-weight: 600;">
                    $<asp:Label ID="lblPrice" runat="server"></asp:Label>
                </td>
            </tr>
            <tr style="border-bottom: 1px solid #f1f5f9;">
                <td style="padding: 12px 0; font-weight: 600; color: #64748b;">Color</td>
                <td style="padding: 12px 0;"><asp:Label ID="lblColor" runat="server"></asp:Label></td>
            </tr>
            <tr style="border-bottom: 1px solid #f1f5f9;">
                <td style="padding: 12px 0; font-weight: 600; color: #64748b;">Dimensions / Size</td>
                <td style="padding: 12px 0;"><asp:Label ID="lblSize" runat="server"></asp:Label></td>
            </tr>
            <tr style="border-bottom: 1px solid #f1f5f9;">
                <td style="padding: 12px 0; font-weight: 600; color: #64748b;">Weight</td>
                <td style="padding: 12px 0;"><asp:Label ID="lblWeight" runat="server"></asp:Label> kg</td>
            </tr>
            <tr style="border-bottom: 1px solid #f1f5f9;">
                <td style="padding: 12px 0; font-weight: 600; color: #64748b;">Inventory in Stock</td>
                <td style="padding: 12px 0;"><asp:Label ID="lblQuantityInStock" runat="server"></asp:Label> units</td>
            </tr>
            <tr style="border-bottom: 1px solid #f1f5f9;">
                <td style="padding: 12px 0; font-weight: 600; color: #64748b;">Product Status</td>
                <td style="padding: 12px 0;">
                    <asp:Label ID="lblDiscontinued" runat="server"></asp:Label>
                </td>
            </tr>
            <tr>
                <td style="padding: 12px 0; font-weight: 600; color: #64748b;">Manufacturer / Supplier</td>
                <td style="padding: 12px 0;"><asp:Label ID="lblSupplier" runat="server"></asp:Label></td>
            </tr>
        </table>
    </div>

    <!-- Code Explanation Drawer -->
    <details class="notion-toggle" style="max-width: 680px;">
        <summary>View QueryString &amp; Stored Procedure Execution</summary>
        <div class="notion-toggle-content">
            <pre class="notion-code-block"><code>string productId = Request.QueryString["ID"];
if (productId == null)
{
    Response.Redirect("Products.aspx");
}

string cs = ConfigurationManager.ConnectionStrings["CS"].ConnectionString;
using (SqlConnection con = new SqlConnection(cs))
{
    SqlCommand cmd = new SqlCommand("spGetProductDetailsByID", con);
    cmd.CommandType = CommandType.StoredProcedure;
    cmd.Parameters.Add(new SqlParameter("@ID", productId));
    con.Open();

    using (SqlDataReader rdr = cmd.ExecuteReader())
    {
        while (rdr.Read())
        {
            lblID.Text = rdr["ID"].ToString();
            lblName.Text = rdr["Name"].ToString();
            lblPrice.Text = rdr["Price"].ToString();
            lblColor.Text = rdr["Color"].ToString();
            lblSize.Text = rdr["Size"].ToString();
            lblWeight.Text = rdr["Weight"].ToString();
            lblQuantityInStock.Text = rdr["QuantityInStock"].ToString();
            lblDiscontinued.Text = (bool)rdr["Discontinued"] ? "Discontinued" : "Active";
            lblSupplier.Text = rdr["Supplier"].ToString();
        }
    }
}</code></pre>
        </div>
    </details>
</asp:Content>
