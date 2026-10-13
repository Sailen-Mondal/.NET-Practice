<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="WebForm2.aspx.cs" Inherits="WebApplication1.WebForm2" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Employee Registration - All 6 Validation Controls</title>
    <style type="text/css">
        body {
            font-family: Arial, sans-serif;
            margin: 30px;
            background-color: #f7f9fc;
        }
        .container {
            width: 820px;
            margin: 0 auto;
            background: #ffffff;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0px 2px 10px rgba(0,0,0,0.1);
        }
        h2, h3 {
            color: #333333;
            text-align: center;
        }
        .info-box {
            background-color: #e8f4fd;
            border-left: 4px solid #007bff;
            padding: 12px 16px;
            margin-bottom: 20px;
            font-size: 13px;
            line-height: 1.6;
        }
        .form-table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 15px;
        }
        .form-table td {
            padding: 8px 10px;
            vertical-align: middle;
        }
        .col-label {
            width: 170px;
            font-weight: bold;
            color: #444;
        }
        .col-input {
            width: 250px;
        }
        .col-validator {
            font-size: 13px;
        }
        .input-control {
            width: 230px;
            padding: 6px 10px;
            border: 1px solid #ccc;
            border-radius: 4px;
        }
        .btn-submit {
            background-color: #007bff;
            color: white;
            border: none;
            padding: 10px 24px;
            font-size: 14px;
            border-radius: 4px;
            cursor: pointer;
        }
        .btn-submit:hover {
            background-color: #0056b3;
        }
        .message-label {
            display: block;
            margin-top: 10px;
            font-weight: bold;
            font-size: 14px;
        }
        .validation-summary {
            background-color: #ffe6e6;
            border: 1px solid #ff4d4d;
            border-radius: 4px;
            padding: 10px 15px;
            margin-bottom: 20px;
        }
        .gridview {
            width: 100%;
            border-collapse: collapse;
            margin-top: 15px;
        }
        .gridview th {
            background-color: #007bff;
            color: white;
            padding: 8px;
            text-align: left;
        }
        .gridview td {
            padding: 8px;
            border-bottom: 1px solid #ddd;
        }
        .gridview tr:nth-child(even) {
            background-color: #f2f2f2;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="container">
            <h2>Employee Registration Form</h2>
            <p style="text-align: center; color: #666;">(Demonstrating All 6 ASP.NET Validation Controls & 3-Layer Architecture)</p>

            <div class="info-box">
                <strong>6 ASP.NET Validation Controls implemented on this page:</strong><br />
                1. <strong>RequiredFieldValidator:</strong> Ensures First Name, Last Name, Age, etc., are not left blank.<br />
                2. <strong>RangeValidator:</strong> Restricts Age between 18 and 65.<br />
                3. <strong>CompareValidator:</strong> Validates Confirm Salary matches Salary.<br />
                4. <strong>RegularExpressionValidator:</strong> Validates Email format (e.g. user@domain.com).<br />
                5. <strong>CustomValidator:</strong> Server-side check that City belongs to approved headquarter cities.<br />
                6. <strong>ValidationSummary:</strong> Displays all validation error messages together in one box below.
            </div>

            <!-- 6. VALIDATION SUMMARY -->
            <asp:ValidationSummary ID="ValidationSummary1" runat="server" 
                HeaderText="Please correct the following errors before submitting:" 
                ForeColor="Red" 
                CssClass="validation-summary" 
                DisplayMode="BulletList" />

            <table class="form-table">
                <!-- FIRST NAME -->
                <tr>
                    <td class="col-label">
                        <asp:Label ID="lblFirstName" runat="server" Text="First Name:"></asp:Label>
                    </td>
                    <td class="col-input">
                        <asp:TextBox ID="txtFirstName" runat="server" CssClass="input-control"></asp:TextBox>
                    </td>
                    <td class="col-validator">
                        <!-- 1. RequiredFieldValidator -->
                        <asp:RequiredFieldValidator ID="rfvFirstName" runat="server" 
                            ControlToValidate="txtFirstName" 
                            ErrorMessage="First Name is required" 
                            ForeColor="Red" Display="Dynamic">
                            * First Name is required
                        </asp:RequiredFieldValidator>
                    </td>
                </tr>

                <!-- LAST NAME -->
                <tr>
                    <td class="col-label">
                        <asp:Label ID="lblLastName" runat="server" Text="Last Name:"></asp:Label>
                    </td>
                    <td class="col-input">
                        <asp:TextBox ID="txtLastName" runat="server" CssClass="input-control"></asp:TextBox>
                    </td>
                    <td class="col-validator">
                        <!-- 1. RequiredFieldValidator -->
                        <asp:RequiredFieldValidator ID="rfvLastName" runat="server" 
                            ControlToValidate="txtLastName" 
                            ErrorMessage="Last Name is required" 
                            ForeColor="Red" Display="Dynamic">
                            * Last Name is required
                        </asp:RequiredFieldValidator>
                    </td>
                </tr>

                <!-- EMAIL (RegularExpressionValidator) -->
                <tr>
                    <td class="col-label">
                        <asp:Label ID="lblEmail" runat="server" Text="Email:"></asp:Label>
                    </td>
                    <td class="col-input">
                        <asp:TextBox ID="txtEmail" runat="server" CssClass="input-control"></asp:TextBox>
                    </td>
                    <td class="col-validator">
                        <asp:RequiredFieldValidator ID="rfvEmail" runat="server" 
                            ControlToValidate="txtEmail" 
                            ErrorMessage="Email is required" 
                            ForeColor="Red" Display="Dynamic">
                            * Email is required
                        </asp:RequiredFieldValidator>
                        <!-- 4. RegularExpressionValidator -->
                        <asp:RegularExpressionValidator ID="revEmail" runat="server" 
                            ControlToValidate="txtEmail" 
                            ValidationExpression="^\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*$" 
                            ErrorMessage="Invalid Email format (e.g. employee@company.com)" 
                            ForeColor="Red" Display="Dynamic">
                            * Invalid email format
                        </asp:RegularExpressionValidator>
                    </td>
                </tr>

                <!-- AGE (RangeValidator) -->
                <tr>
                    <td class="col-label">
                        <asp:Label ID="lblAge" runat="server" Text="Age:"></asp:Label>
                    </td>
                    <td class="col-input">
                        <asp:TextBox ID="txtAge" runat="server" CssClass="input-control"></asp:TextBox>
                    </td>
                    <td class="col-validator">
                        <asp:RequiredFieldValidator ID="rfvAge" runat="server" 
                            ControlToValidate="txtAge" 
                            ErrorMessage="Age is required" 
                            ForeColor="Red" Display="Dynamic">
                            * Age is required
                        </asp:RequiredFieldValidator>
                        <!-- 2. RangeValidator -->
                        <asp:RangeValidator ID="rvAge" runat="server" 
                            ControlToValidate="txtAge" 
                            Type="Integer" 
                            MinimumValue="18" 
                            MaximumValue="65" 
                            ErrorMessage="Age must be between 18 and 65" 
                            ForeColor="Red" Display="Dynamic">
                            * Age must be 18 to 65
                        </asp:RangeValidator>
                    </td>
                </tr>

                <!-- CITY (CustomValidator) -->
                <tr>
                    <td class="col-label">
                        <asp:Label ID="lblCity" runat="server" Text="City:"></asp:Label>
                    </td>
                    <td class="col-input">
                        <asp:TextBox ID="txtCity" runat="server" CssClass="input-control"></asp:TextBox>
                    </td>
                    <td class="col-validator">
                        <asp:RequiredFieldValidator ID="rfvCity" runat="server" 
                            ControlToValidate="txtCity" 
                            ErrorMessage="City is required" 
                            ForeColor="Red" Display="Dynamic">
                            * City is required
                        </asp:RequiredFieldValidator>
                        <!-- 5. CustomValidator -->
                        <asp:CustomValidator ID="cvCity" runat="server" 
                            ControlToValidate="txtCity" 
                            OnServerValidate="cvCity_ServerValidate" 
                            ErrorMessage="City must be an approved branch: Kolkata, Delhi, Mumbai, Bengaluru, Hyderabad, Chennai, Kochi, Ahmedabad, Lucknow" 
                            ForeColor="Red" Display="Dynamic">
                            * Not an approved company branch city
                        </asp:CustomValidator>
                    </td>
                </tr>

                <!-- DATE OF JOINING -->
                <tr>
                    <td class="col-label">
                        <asp:Label ID="lblDateOfJoining" runat="server" Text="Date Of Joining:"></asp:Label>
                    </td>
                    <td class="col-input">
                        <asp:TextBox ID="txtDateOfJoining" runat="server" TextMode="Date" CssClass="input-control"></asp:TextBox>
                    </td>
                    <td class="col-validator">
                        <asp:RequiredFieldValidator ID="rfvDate" runat="server" 
                            ControlToValidate="txtDateOfJoining" 
                            ErrorMessage="Date of Joining is required" 
                            ForeColor="Red" Display="Dynamic">
                            * Date of Joining is required
                        </asp:RequiredFieldValidator>
                    </td>
                </tr>

                <!-- SALARY -->
                <tr>
                    <td class="col-label">
                        <asp:Label ID="lblSalary" runat="server" Text="Salary:"></asp:Label>
                    </td>
                    <td class="col-input">
                        <asp:TextBox ID="txtSalary" runat="server" CssClass="input-control"></asp:TextBox>
                    </td>
                    <td class="col-validator">
                        <asp:RequiredFieldValidator ID="rfvSalary" runat="server" 
                            ControlToValidate="txtSalary" 
                            ErrorMessage="Salary is required" 
                            ForeColor="Red" Display="Dynamic">
                            * Salary is required
                        </asp:RequiredFieldValidator>
                    </td>
                </tr>

                <!-- CONFIRM SALARY (CompareValidator) -->
                <tr>
                    <td class="col-label">
                        <asp:Label ID="lblConfirmSalary" runat="server" Text="Confirm Salary:"></asp:Label>
                    </td>
                    <td class="col-input">
                        <asp:TextBox ID="txtConfirmSalary" runat="server" CssClass="input-control"></asp:TextBox>
                    </td>
                    <td class="col-validator">
                        <asp:RequiredFieldValidator ID="rfvConfirmSalary" runat="server" 
                            ControlToValidate="txtConfirmSalary" 
                            ErrorMessage="Confirm Salary is required" 
                            ForeColor="Red" Display="Dynamic">
                            * Confirm Salary is required
                        </asp:RequiredFieldValidator>
                        <!-- 3. CompareValidator -->
                        <asp:CompareValidator ID="cvSalaryMatch" runat="server" 
                            ControlToValidate="txtConfirmSalary" 
                            ControlToCompare="txtSalary" 
                            Type="Double" 
                            Operator="Equal" 
                            ErrorMessage="Confirm Salary must match the entered Salary" 
                            ForeColor="Red" Display="Dynamic">
                            * Salaries do not match
                        </asp:CompareValidator>
                    </td>
                </tr>

                <!-- SUBMIT BUTTON -->
                <tr>
                    <td>&nbsp;</td>
                    <td colspan="2">
                        <asp:Button ID="btnSubmit" runat="server" Text="Submit" CssClass="btn-submit" OnClick="btnSubmit_Click" />
                    </td>
                </tr>

                <!-- RESULT MESSAGE -->
                <tr>
                    <td colspan="3">
                        <asp:Label ID="lblMessage" runat="server" CssClass="message-label"></asp:Label>
                    </td>
                </tr>
            </table>

            <hr />
            <h3>Database Records (Employees)</h3>
            <asp:GridView ID="gvEmployees" runat="server" CssClass="gridview" AutoGenerateColumns="true">
            </asp:GridView>
        </div>
    </form>
</body>
</html>
