<%@ Page Title="TemplateField & Validation" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="TemplateFieldsValidation.aspx.cs" Inherits="GridViewDemo.TemplateFieldsValidation" ResponseEncoding="utf-8" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="notion-breadcrumb">
        <a href="Default.aspx">Overview</a> / <span>Topic 06: TemplateFields &amp; Validation</span>
    </div>

    <div class="notion-page-header">
        <span class="notion-page-badge">Topic 06</span>
        <h1 class="notion-page-title">TemplateFields &amp; Input Validation</h1>
        <p class="notion-page-desc">
            Convert standard BoundFields to TemplateFields to customize the editing interface with a DropDownList for Gender, wire two-way data binding (Bind), and enforce RequiredFieldValidator with ValidationSummary.
        </p>
    </div>

    <!-- Concept Callout -->
    <div class="notion-callout">
        <div class="notion-callout-title">Validation Architecture</div>
        <ul style="margin: 4px 0 0 16px; padding: 0;">
            <li><strong>Custom Edit UI:</strong> Replace default TextBox in <code>&lt;EditItemTemplate&gt;</code> with a <code>DropDownList</code> and bind <code>SelectedValue='&lt;%# Bind("Gender") %&gt;'</code>.</li>
            <li><strong>Enforcing Selection:</strong> <code>RequiredFieldValidator</code> with <code>InitialValue="Select Gender"</code> prevents saving the placeholder option.</li>
            <li><strong>Schema Consideration:</strong> Database column set to <code>nvarchar(20)</code> prevents string truncation crashes before validation executes.</li>
        </ul>
    </div>

    <!-- Live GridView Card -->
    <div class="notion-card">
        <div class="notion-card-header">
            <h3 class="notion-card-title">Editable Employee Grid</h3>
            <span class="notion-tag notion-tag-neutral">Click Edit to Test Validation</span>
        </div>

        <asp:SqlDataSource ID="SqlDataSource1" runat="server" 
            ConnectionString="<%$ ConnectionStrings:DBConnectionString %>" 
            SelectCommand="SELECT EmployeeId, FirstName, LastName, Gender, City FROM [tblEmployee] ORDER BY EmployeeId"
            UpdateCommand="UPDATE [tblEmployee] SET FirstName = @FirstName, LastName = @LastName, Gender = @Gender, City = @City WHERE EmployeeId = @EmployeeId">
            <UpdateParameters>
                <asp:Parameter Name="FirstName" Type="String" />
                <asp:Parameter Name="LastName" Type="String" />
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
                CssClass="notion-grid"
                GridLines="None">
                <Columns>
                    <asp:CommandField ShowEditButton="True" ButtonType="Link" 
                        ControlStyle-CssClass="notion-action-link" />

                    <asp:BoundField DataField="EmployeeId" HeaderText="ID" ReadOnly="True" InsertVisible="False" />
                    
                    <asp:BoundField DataField="FirstName" HeaderText="First Name" />
                    <asp:BoundField DataField="LastName" HeaderText="Last Name" />

                    <asp:TemplateField HeaderText="Gender" SortExpression="Gender">
                        <ItemTemplate>
                            <span class='notion-tag <%# Eval("Gender").ToString() == "Male" ? "notion-tag-male" : "notion-tag-female" %>'>
                                <asp:Label ID="Label1" runat="server" Text='<%# Bind("Gender") %>'></asp:Label>
                            </span>
                        </ItemTemplate>
                        <EditItemTemplate>
                            <div style="display: flex; align-items: center; gap: 6px;">
                                <asp:DropDownList ID="DropDownList1" runat="server" 
                                    SelectedValue='<%# Bind("Gender") %>'
                                    CssClass="notion-select">
                                    <asp:ListItem>Select Gender</asp:ListItem>
                                    <asp:ListItem>Male</asp:ListItem>
                                    <asp:ListItem>Female</asp:ListItem>
                                </asp:DropDownList>
                                <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" 
                                    ErrorMessage="Gender is a required field" 
                                    ControlToValidate="DropDownList1" 
                                    InitialValue="Select Gender" 
                                    Text="*" ForeColor="#dc2626">
                                </asp:RequiredFieldValidator>
                            </div>
                        </EditItemTemplate>
                    </asp:TemplateField>

                    <asp:BoundField DataField="City" HeaderText="City" />
                </Columns>
                <EditRowStyle CssClass="notion-edit-row" />
            </asp:GridView>
        </div>

        <!-- Validation Summary -->
        <asp:ValidationSummary ID="ValidationSummary1" runat="server" 
            CssClass="notion-validation-summary" 
            HeaderText="Please resolve the following validation errors:" />
    </div>

    <!-- Code Explanation Drawer -->
    <details class="notion-toggle">
        <summary>View TemplateField &amp; Validator Markup</summary>
        <div class="notion-toggle-content">
            <pre class="notion-code-block"><code>&lt;asp:TemplateField HeaderText="Gender" SortExpression="Gender"&gt;
    &lt;EditItemTemplate&gt;
        &lt;asp:DropDownList ID="DropDownList1" runat="server" SelectedValue='&lt;%# Bind("Gender") %&gt;'&gt;
            &lt;asp:ListItem&gt;Select Gender&lt;/asp:ListItem&gt;
            &lt;asp:ListItem&gt;Male&lt;/asp:ListItem&gt;
            &lt;asp:ListItem&gt;Female&lt;/asp:ListItem&gt;
        &lt;/asp:DropDownList&gt;
        &lt;asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" 
            ErrorMessage="Gender is a required field" 
            ControlToValidate="DropDownList1" 
            InitialValue="Select Gender" 
            Text="*" ForeColor="Red"&gt;
        &lt;/asp:RequiredFieldValidator&gt;
    &lt;/EditItemTemplate&gt;
    &lt;ItemTemplate&gt;
        &lt;asp:Label ID="Label1" runat="server" Text='&lt;%# Bind("Gender") %&gt;'&gt;&lt;/asp:Label&gt;
    &lt;/ItemTemplate&gt;
&lt;/asp:TemplateField&gt;

&lt;asp:ValidationSummary ID="ValidationSummary1" runat="server" ForeColor="Red" /&gt;</code></pre>
        </div>
    </details>
</asp:Content>
