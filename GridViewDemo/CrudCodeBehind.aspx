<%@ Page Title="CRUD via Code-Behind" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="CrudCodeBehind.aspx.cs" Inherits="GridViewDemo.CrudCodeBehind" ResponseEncoding="utf-8" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="notion-breadcrumb">
        <a href="Default.aspx">Overview</a> / <span>Topic 09: Full CRUD Without DataSource Controls</span>
    </div>

    <div class="notion-page-header">
        <span class="notion-page-badge">Topic 09</span>
        <h1 class="notion-page-title">Full CRUD via Pure Code-Behind &amp; RowCommand</h1>
        <p class="notion-page-desc">
            Complete programmatic control over GridView state, commands, and validation without any declarative DataSource controls, featuring client-side JavaScript delete confirmation.
        </p>
    </div>

    <!-- Concept Callout -->
    <div class="notion-callout">
        <div class="notion-callout-title">Programmatic CRUD Flow</div>
        <ul style="margin: 4px 0 0 16px; padding: 0;">
            <li><strong>No DataSource Controls:</strong> The GridView does not have a <code>DataSourceID</code>. Data binding is executed explicitly via <code>BindGridViewData()</code>.</li>
            <li><strong>RowCommand Event:</strong> Edit, Cancel, Update, Delete, and Insert commands dispatch through <code>GridView1_RowCommand</code> with custom <code>CommandName</code> and <code>CommandArgument</code>.</li>
            <li><strong>Client-Side Delete Confirmation:</strong> The Delete button uses <code>OnClientClick="return confirm('...');"</code> to intercept the postback before it reaches the server.</li>
        </ul>
    </div>

    <!-- Live GridView Card -->
    <div class="notion-card">
        <div class="notion-card-header">
            <h3 class="notion-card-title">Programmatic Employee Grid</h3>
            <span class="notion-tag notion-tag-neutral">Event: RowCommand</span>
        </div>

        <div class="notion-grid-wrapper">
            <asp:GridView ID="GridView1" runat="server" 
                AutoGenerateColumns="False" 
                DataKeyNames="EmployeeId" 
                ShowFooter="True"
                OnRowCommand="GridView1_RowCommand"
                CssClass="notion-grid"
                GridLines="None">
                <Columns>
                    <asp:TemplateField HeaderText="Actions" ItemStyle-Width="160px">
                        <ItemTemplate>
                            <asp:LinkButton ID="lbEdit" runat="server" CommandName="EditRow" 
                                CommandArgument='<%# Eval("EmployeeId") %>' CssClass="notion-action-link">
                                Edit
                            </asp:LinkButton>
                            <asp:LinkButton ID="lbDelete" runat="server" CommandName="DeleteRow" 
                                CommandArgument='<%# Eval("EmployeeId") %>' CausesValidation="false" 
                                OnClientClick="return confirm('Are you sure you want to delete this row?');" 
                                CssClass="notion-action-link delete">
                                Delete
                            </asp:LinkButton>
                        </ItemTemplate>
                        <EditItemTemplate>
                            <asp:LinkButton ID="lbUpdate" runat="server" CommandName="UpdateRow" 
                                CommandArgument='<%# Eval("EmployeeId") %>' CssClass="notion-action-link update">
                                Update
                            </asp:LinkButton>
                            <asp:LinkButton ID="lbCancel" runat="server" CommandName="CancelUpdate" 
                                CausesValidation="false" CssClass="notion-action-link cancel">
                                Cancel
                            </asp:LinkButton>
                        </EditItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Employee ID" InsertVisible="False">
                        <ItemTemplate>
                            <asp:Label ID="Label1" runat="server" Text='<%# Bind("EmployeeId") %>'></asp:Label>
                        </ItemTemplate>
                        <EditItemTemplate>
                            <asp:Label ID="Label1" runat="server" Text='<%# Eval("EmployeeId") %>'></asp:Label>
                        </EditItemTemplate>
                        <FooterTemplate>
                            <asp:LinkButton ID="lbInsert" runat="server" CommandName="InsertRow" 
                                ValidationGroup="Insert" CssClass="notion-action-link insert">
                                Insert
                            </asp:LinkButton>
                        </FooterTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Name">
                        <ItemTemplate>
                            <asp:Label ID="Label2" runat="server" Text='<%# Bind("Name") %>'></asp:Label>
                        </ItemTemplate>
                        <EditItemTemplate>
                            <asp:TextBox ID="TextBox1" runat="server" Text='<%# Bind("Name") %>' CssClass="notion-input"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="rfvEditName" runat="server" ErrorMessage="Name is required" 
                                ControlToValidate="TextBox1" Text="*" ForeColor="#dc2626">
                            </asp:RequiredFieldValidator>
                        </EditItemTemplate>
                        <FooterTemplate>
                            <asp:TextBox ID="txtName" runat="server" Placeholder="New employee..." CssClass="notion-input"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="rfvInsertName" runat="server" ErrorMessage="Name is required" 
                                ControlToValidate="txtName" Text="*" ForeColor="#dc2626" ValidationGroup="Insert">
                            </asp:RequiredFieldValidator>
                        </FooterTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Gender">
                        <ItemTemplate>
                            <span class='notion-tag <%# Eval("Gender").ToString() == "Male" ? "notion-tag-male" : "notion-tag-female" %>'>
                                <asp:Label ID="Label3" runat="server" Text='<%# Bind("Gender") %>'></asp:Label>
                            </span>
                        </ItemTemplate>
                        <EditItemTemplate>
                            <asp:DropDownList ID="DropDownList1" runat="server" SelectedValue='<%# Bind("Gender") %>' CssClass="notion-select">
                                <asp:ListItem>Select Gender</asp:ListItem>
                                <asp:ListItem>Male</asp:ListItem>
                                <asp:ListItem>Female</asp:ListItem>
                            </asp:DropDownList>
                            <asp:RequiredFieldValidator ID="rfvEditGender" runat="server" ErrorMessage="Gender is required" 
                                ControlToValidate="DropDownList1" InitialValue="Select Gender" Text="*" ForeColor="#dc2626">
                            </asp:RequiredFieldValidator>
                        </EditItemTemplate>
                        <FooterTemplate>
                            <asp:DropDownList ID="ddlGender" runat="server" CssClass="notion-select">
                                <asp:ListItem>Select Gender</asp:ListItem>
                                <asp:ListItem>Male</asp:ListItem>
                                <asp:ListItem>Female</asp:ListItem>
                            </asp:DropDownList>
                            <asp:RequiredFieldValidator ID="rfvInsertGender" runat="server" ErrorMessage="Gender is required" 
                                ControlToValidate="ddlGender" InitialValue="Select Gender" Text="*" ForeColor="#dc2626" ValidationGroup="Insert">
                            </asp:RequiredFieldValidator>
                        </FooterTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="City">
                        <ItemTemplate>
                            <asp:Label ID="Label4" runat="server" Text='<%# Bind("City") %>'></asp:Label>
                        </ItemTemplate>
                        <EditItemTemplate>
                            <asp:TextBox ID="TextBox3" runat="server" Text='<%# Bind("City") %>' CssClass="notion-input"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="rfvEditCity" runat="server" ErrorMessage="City is required" 
                                ControlToValidate="TextBox3" Text="*" ForeColor="#dc2626">
                            </asp:RequiredFieldValidator>
                        </EditItemTemplate>
                        <FooterTemplate>
                            <asp:TextBox ID="txtCity" runat="server" Placeholder="City..." CssClass="notion-input"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="rfvInsertCity" runat="server" ErrorMessage="City is required" 
                                ControlToValidate="txtCity" Text="*" ForeColor="#dc2626" ValidationGroup="Insert">
                            </asp:RequiredFieldValidator>
                        </FooterTemplate>
                    </asp:TemplateField>
                </Columns>
                <EditRowStyle CssClass="notion-edit-row" />
                <FooterStyle CssClass="notion-footer-row" />
            </asp:GridView>
        </div>

        <asp:ValidationSummary ID="ValidationSummary1" runat="server" ValidationGroup="Insert" 
            CssClass="notion-validation-summary" HeaderText="Insert validation failed:" />
        <asp:ValidationSummary ID="ValidationSummary2" runat="server" 
            CssClass="notion-validation-summary" HeaderText="Edit validation failed:" />
    </div>

    <!-- Code Explanation Drawer -->
    <details class="notion-toggle">
        <summary>View GridView1_RowCommand Event Handler C#</summary>
        <div class="notion-toggle-content">
            <pre class="notion-code-block"><code>protected void GridView1_RowCommand(object sender, GridViewCommandEventArgs e)
{
    if (e.CommandName == "EditRow")
    {
        int rowIndex = ((GridViewRow)((LinkButton)e.CommandSource).NamingContainer).RowIndex;
        GridView1.EditIndex = rowIndex;
        BindGridViewData();
    }
    else if (e.CommandName == "DeleteRow")
    {
        EmployeeDataAccessLayer.DeleteEmployee(Convert.ToInt32(e.CommandArgument));
        BindGridViewData();
    }
    else if (e.CommandName == "CancelUpdate")
    {
        GridView1.EditIndex = -1;
        BindGridViewData();
    }
    else if (e.CommandName == "UpdateRow")
    {
        int rowIndex = ((GridViewRow)((LinkButton)e.CommandSource).NamingContainer).RowIndex;
        int employeeId = Convert.ToInt32(e.CommandArgument);
        string name = ((TextBox)GridView1.Rows[rowIndex].FindControl("TextBox1")).Text;
        string gender = ((DropDownList)GridView1.Rows[rowIndex].FindControl("DropDownList1")).SelectedValue;
        string city = ((TextBox)GridView1.Rows[rowIndex].FindControl("TextBox3")).Text;
        
        EmployeeDataAccessLayer.UpdateEmployee(employeeId, name, gender, city);
        GridView1.EditIndex = -1;
        BindGridViewData();
    }
    else if (e.CommandName == "InsertRow")
    {
        string name = ((TextBox)GridView1.FooterRow.FindControl("txtName")).Text;
        string gender = ((DropDownList)GridView1.FooterRow.FindControl("ddlGender")).SelectedValue;
        string city = ((TextBox)GridView1.FooterRow.FindControl("txtCity")).Text;
        
        EmployeeDataAccessLayer.InsertEmployee(name, gender, city);
        BindGridViewData();
    }
}</code></pre>
        </div>
    </details>
</asp:Content>
