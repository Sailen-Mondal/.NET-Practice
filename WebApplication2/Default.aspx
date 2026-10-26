<%@ Page Title="CRUD using LINQ" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="CRUDUsingLINQ._Default" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="notion-header-group">
        <h1 class="notion-page-title">CRUD Operations Using LINQ</h1>
        <p class="notion-page-desc">
            Complete Create, Read, Update, and Delete implementation using LINQ to SQL (<code class="notion-badge">DataContext</code>) and an interactive ASP.NET GridView control.
        </p>
    </div>

    <div class="notion-callout">
        <div class="notion-callout-header">[Architecture Note] LINQ to SQL Architecture</div>
        <div class="notion-callout-body">
            LINQ provides compile-time type safety and IntelliSense. The <code class="notion-badge">SampleDataContext</code> translates C# LINQ operations (<code class="notion-badge">InsertOnSubmit</code>, <code class="notion-badge">SubmitChanges</code>, <code class="notion-badge">DeleteOnSubmit</code>) directly into parameterized T-SQL commands sent to SQL Server.
        </div>
    </div>

    <asp:Label ID="lblresult" runat="server" CssClass="notion-status" Visible="false" />

    <div class="notion-table-wrapper">
        <asp:GridView ID="gvDetails" runat="server"
            ShowFooter="true"
            AllowPaging="true"
            PageSize="10"
            AutoGenerateColumns="false"
            DataKeyNames="ID,Name"
            CssClass="notion-gridview"
            GridLines="None"
            OnPageIndexChanging="gvDetails_PageIndexChanging"
            OnRowCancelingEdit="gvDetails_RowCancelingEdit"
            OnRowEditing="gvDetails_RowEditing"
            OnRowUpdating="gvDetails_RowUpdating"
            OnRowDeleting="gvDetails_RowDeleting"
            OnRowCommand="gvDetails_RowCommand"
            OnRowDataBound="gvDetails_RowDataBound">
            <Columns>
                <asp:BoundField DataField="ID" HeaderText="ID" ReadOnly="true" ItemStyle-Width="60px" />
                
                <asp:TemplateField HeaderText="Name">
                    <ItemTemplate>
                        <asp:Label ID="lblName" runat="server" Text='<%# Eval("Name") %>' />
                    </ItemTemplate>
                    <EditItemTemplate>
                        <asp:TextBox ID="txtName" runat="server" Text='<%# Eval("Name") %>' CssClass="notion-input" />
                    </EditItemTemplate>
                    <FooterTemplate>
                        <asp:TextBox ID="txtfName" runat="server" placeholder="Enter Full Name" CssClass="notion-input" />
                    </FooterTemplate>
                </asp:TemplateField>

                <asp:TemplateField HeaderText="Location">
                    <ItemTemplate>
                        <asp:Label ID="lblLocation" runat="server" Text='<%# Eval("Location") %>' />
                    </ItemTemplate>
                    <EditItemTemplate>
                        <asp:TextBox ID="txtLocation" runat="server" Text='<%# Eval("Location") %>' CssClass="notion-input" />
                    </EditItemTemplate>
                    <FooterTemplate>
                        <asp:TextBox ID="txtfLocation" runat="server" placeholder="Enter Location" CssClass="notion-input" />
                    </FooterTemplate>
                </asp:TemplateField>

                <asp:TemplateField HeaderText="Gender">
                    <ItemTemplate>
                        <asp:Label ID="lblGender" runat="server" Text='<%# Eval("Gender") %>' />
                    </ItemTemplate>
                    <EditItemTemplate>
                        <asp:TextBox ID="txtGender" runat="server" Text='<%# Eval("Gender") %>' CssClass="notion-input" />
                    </EditItemTemplate>
                    <FooterTemplate>
                        <asp:TextBox ID="txtfGender" runat="server" placeholder="Male / Female" CssClass="notion-input" />
                    </FooterTemplate>
                </asp:TemplateField>

                <asp:TemplateField HeaderText="Actions" ItemStyle-Width="180px">
                    <ItemTemplate>
                        <asp:LinkButton ID="btnEdit" runat="server" CommandName="Edit" Text="Edit" CssClass="notion-action-link" />
                        <asp:LinkButton ID="btnDelete" runat="server" CommandName="Delete" Text="Delete" CssClass="notion-action-link notion-action-delete" />
                    </ItemTemplate>
                    <EditItemTemplate>
                        <asp:LinkButton ID="btnUpdate" runat="server" CommandName="Update" Text="Update" CssClass="notion-action-link" />
                        <asp:LinkButton ID="btnCancel" runat="server" CommandName="Cancel" Text="Cancel" CssClass="notion-action-link" />
                    </EditItemTemplate>
                    <FooterTemplate>
                        <asp:Button ID="btnAdd" CommandName="AddNew" runat="server" Text="Add New" CssClass="notion-btn notion-btn-primary notion-btn-sm" />
                    </FooterTemplate>
                </asp:TemplateField>
            </Columns>
        </asp:GridView>
    </div>

    <h2 class="notion-section-title">Query Syntax vs Method Syntax (Slide Reference)</h2>
    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px;">
        <div>
            <h3 class="notion-sub-title">1. Query Syntax (SQL-Like)</h3>
            <pre class="notion-code-block">// Read
var result = (from emp in db.Employee1
              select new {
                  emp.ID, emp.Name, emp.Location, emp.Gender
              }).ToList();

// Fetch For Update
Employee1 emp = (from em in db.Employee1 
                 where em.ID == empid 
                 select em).FirstOrDefault();</pre>
        </div>
        <div>
            <h3 class="notion-sub-title">2. Method Syntax (Lambda Expression)</h3>
            <pre class="notion-code-block">// Read
var result = db.Employee1
               .Select(emp => new {
                   emp.ID, emp.Name, emp.Location, emp.Gender
               }).ToList();

// Fetch For Update
Employee1 emp = db.Employee1.Single(x => x.ID == empid);</pre>
        </div>
    </div>
</asp:Content>
