<%@ Page Title="CRUD via SqlDataSource" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="CrudSqlDataSource.aspx.cs" Inherits="GridViewDemo.CrudSqlDataSource" ResponseEncoding="utf-8" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="notion-breadcrumb">
        <a href="Default.aspx">Overview</a> / <span>Topic 07: Full CRUD with SqlDataSource</span>
    </div>

    <div class="notion-page-header">
        <span class="notion-page-badge">Topic 07</span>
        <h1 class="notion-page-title">Full CRUD with SqlDataSource &amp; Footer Insert</h1>
        <p class="notion-page-desc">
            Perform Insert, Update, and Delete operations declaratively using SqlDataSource, leveraging the GridView Footer row for new record entry, and segregated ValidationGroups.
        </p>
    </div>

    <!-- Concept Callout -->
    <div class="notion-callout">
        <div class="notion-callout-title">Architecture Highlights</div>
        <ul style="margin: 4px 0 0 16px; padding: 0;">
            <li><strong>Declarative CRUD:</strong> SqlDataSource manages SELECT, INSERT, UPDATE, and DELETE SQL queries with typed parameters.</li>
            <li><strong>Footer Row Insert:</strong> Setting <code>ShowFooter="True"</code> displays input controls in the footer template alongside the Insert link.</li>
            <li><strong>Validation Isolation:</strong> Using <code>ValidationGroup="Insert"</code> ensures that inserting a new row in the footer does not interfere with row editing.</li>
        </ul>
    </div>

    <!-- Live GridView Card -->
    <div class="notion-card">
        <div class="notion-card-header">
            <h3 class="notion-card-title">Employee Management</h3>
            <span class="notion-tag notion-tag-neutral">ShowFooter: True</span>
        </div>

        <asp:SqlDataSource ID="SqlDataSource1" runat="server" 
            ConnectionString="<%$ ConnectionStrings:SampleConnectionString %>"
            DeleteCommand="DELETE FROM [tblEmployee] WHERE [EmployeeId] = @EmployeeId" 
            InsertCommand="INSERT INTO [tblEmployee] ([Name], [Gender], [City], [Salary], [AnnualSalary]) VALUES (@Name, @Gender, @City, 55000, 55000)"
            SelectCommand="SELECT [EmployeeId], ISNULL([Name], [FirstName] + ' ' + [LastName]) AS [Name], [Gender], [City] FROM [tblEmployee] ORDER BY [EmployeeId]" 
            UpdateCommand="UPDATE [tblEmployee] SET [Name] = @Name, [Gender] = @Gender, [City] = @City WHERE [EmployeeId] = @EmployeeId">
            <DeleteParameters>
                <asp:Parameter Name="EmployeeId" Type="Int32" />
            </DeleteParameters>
            <InsertParameters>
                <asp:Parameter Name="Name" Type="String" />
                <asp:Parameter Name="Gender" Type="String" />
                <asp:Parameter Name="City" Type="String" />
            </InsertParameters>
            <UpdateParameters>
                <asp:Parameter Name="Name" Type="String" />
                <asp:Parameter Name="Gender" Type="String" />
                <asp:Parameter Name="City" Type="String" />
                <asp:Parameter Name="EmployeeId" Type="Int32" />
            </UpdateParameters>
        </asp:SqlDataSource>

        <div class="notion-grid-wrapper">
            <asp:GridView ID="GridView1" runat="server" 
                AutoGenerateColumns="False" 
                DataKeyNames="EmployeeId" 
                DataSourceID="SqlDataSource1" 
                ShowFooter="True"
                CssClass="notion-grid"
                GridLines="None">
                <Columns>
                    <asp:CommandField ShowDeleteButton="True" ShowEditButton="True" 
                        ControlStyle-CssClass="notion-action-link" />

                    <asp:TemplateField HeaderText="Employee ID" InsertVisible="False" SortExpression="EmployeeId">
                        <EditItemTemplate>
                            <asp:Label ID="Label1" runat="server" Text='<%# Eval("EmployeeId") %>'></asp:Label>
                        </EditItemTemplate>
                        <ItemTemplate>
                            <asp:Label ID="Label1" runat="server" Text='<%# Bind("EmployeeId") %>'></asp:Label>
                        </ItemTemplate>
                        <FooterTemplate>
                            <asp:LinkButton ID="lbInsert" ValidationGroup="Insert" runat="server" 
                                OnClick="lbInsert_Click" CssClass="notion-action-link insert">
                                Insert
                            </asp:LinkButton>
                        </FooterTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Name" SortExpression="Name">
                        <EditItemTemplate>
                            <asp:TextBox ID="TextBox1" runat="server" Text='<%# Bind("Name") %>' CssClass="notion-input"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="rfvEditName" runat="server" ErrorMessage="Name is required"
                                ControlToValidate="TextBox1" Text="*" ForeColor="#dc2626">
                            </asp:RequiredFieldValidator>
                        </EditItemTemplate>
                        <ItemTemplate>
                            <asp:Label ID="Label2" runat="server" Text='<%# Bind("Name") %>'></asp:Label>
                        </ItemTemplate>
                        <FooterTemplate>
                            <asp:TextBox ID="txtName" runat="server" Placeholder="Enter name..." CssClass="notion-input"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="rfvInsertName" runat="server" ErrorMessage="Name is required for insert" 
                                ControlToValidate="txtName" Text="*" ForeColor="#dc2626" ValidationGroup="Insert">
                            </asp:RequiredFieldValidator>
                        </FooterTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Gender" SortExpression="Gender">
                        <EditItemTemplate>
                            <asp:DropDownList ID="DropDownList1" runat="server" SelectedValue='<%# Bind("Gender") %>' CssClass="notion-select">
                                <asp:ListItem>Select Gender</asp:ListItem>
                                <asp:ListItem>Male</asp:ListItem>
                                <asp:ListItem>Female</asp:ListItem>
                            </asp:DropDownList>
                            <asp:RequiredFieldValidator ID="rfvEditGender" runat="server" ErrorMessage="Gender is required" 
                                Text="*" ControlToValidate="DropDownList1" ForeColor="#dc2626" InitialValue="Select Gender">
                            </asp:RequiredFieldValidator>
                        </EditItemTemplate>
                        <ItemTemplate>
                            <span class='notion-tag <%# Eval("Gender").ToString() == "Male" ? "notion-tag-male" : "notion-tag-female" %>'>
                                <asp:Label ID="Label3" runat="server" Text='<%# Bind("Gender") %>'></asp:Label>
                            </span>
                        </ItemTemplate>
                        <FooterTemplate>
                            <asp:DropDownList ID="ddlInsertGender" runat="server" CssClass="notion-select">
                                <asp:ListItem>Select Gender</asp:ListItem>
                                <asp:ListItem>Male</asp:ListItem>
                                <asp:ListItem>Female</asp:ListItem>
                            </asp:DropDownList>
                            <asp:RequiredFieldValidator ID="rfvInsertGender" runat="server" ErrorMessage="Gender is required for insert" 
                                Text="*" ControlToValidate="ddlInsertGender" ForeColor="#dc2626" InitialValue="Select Gender" ValidationGroup="Insert">
                            </asp:RequiredFieldValidator>
                        </FooterTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="City" SortExpression="City">
                        <EditItemTemplate>
                            <asp:TextBox ID="TextBox3" runat="server" Text='<%# Bind("City") %>' CssClass="notion-input"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="rfvEditCity" runat="server" ErrorMessage="City is required" 
                                Text="*" ControlToValidate="TextBox3" ForeColor="#dc2626">
                            </asp:RequiredFieldValidator>
                        </EditItemTemplate>
                        <ItemTemplate>
                            <asp:Label ID="Label4" runat="server" Text='<%# Bind("City") %>'></asp:Label>
                        </ItemTemplate>
                        <FooterTemplate>
                            <asp:TextBox ID="txtCity" runat="server" Placeholder="Enter city..." CssClass="notion-input"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="rfvInsertCity" runat="server" ErrorMessage="City is required for insert" 
                                Text="*" ControlToValidate="txtCity" ForeColor="#dc2626" ValidationGroup="Insert">
                            </asp:RequiredFieldValidator>
                        </FooterTemplate>
                    </asp:TemplateField>
                </Columns>
                <EditRowStyle CssClass="notion-edit-row" />
                <FooterStyle CssClass="notion-footer-row" />
            </asp:GridView>
        </div>

        <!-- Segregated Validation Summaries -->
        <asp:ValidationSummary ID="ValidationSummary1" runat="server" ValidationGroup="Insert" 
            CssClass="notion-validation-summary" HeaderText="Insert validation failed:" />
        <asp:ValidationSummary ID="ValidationSummary2" runat="server" 
            CssClass="notion-validation-summary" HeaderText="Edit validation failed:" />
    </div>

    <!-- Code Explanation Drawer -->
    <details class="notion-toggle">
        <summary>View lbInsert_Click Code-Behind</summary>
        <div class="notion-toggle-content">
            <pre class="notion-code-block"><code>protected void lbInsert_Click(object sender, EventArgs e)
{
    SqlDataSource1.InsertParameters["Name"].DefaultValue = 
        ((TextBox)GridView1.FooterRow.FindControl("txtName")).Text;
    SqlDataSource1.InsertParameters["Gender"].DefaultValue = 
        ((DropDownList)GridView1.FooterRow.FindControl("ddlInsertGender")).SelectedValue;
    SqlDataSource1.InsertParameters["City"].DefaultValue = 
        ((TextBox)GridView1.FooterRow.FindControl("txtCity")).Text;
        
    SqlDataSource1.Insert();
}</code></pre>
        </div>
    </details>
</asp:Content>
