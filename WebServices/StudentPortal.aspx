<%@ Page Title="Student Portal" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="StudentPortal.aspx.cs" Inherits="WebServices.StudentPortal" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <script type="text/javascript">
        function GetStudentById() {
            var txtId = document.getElementById('<%= txtStudentId.ClientID %>');
            var id = txtId.value.trim();

            if (!id || isNaN(id) || parseInt(id, 10) <= 0) {
                setStatus("Please enter a valid positive numeric Student ID.", "error");
                return;
            }

            setStatus("Contacting StudentService.asmx via AJAX...", "info");

            // WebServices namespace is defined by StudentService.asmx
            if (typeof WebServices !== "undefined" && WebServices.StudentService) {
                WebServices.StudentService.GetStudentByID(parseInt(id, 10), GetStudentByIdSuccessCallback, GetStudentByIdFailedCallback);
            } else if (typeof StudentService !== "undefined") {
                StudentService.GetStudentByID(parseInt(id, 10), GetStudentByIdSuccessCallback, GetStudentByIdFailedCallback);
            } else {
                setStatus("StudentService proxy is not loaded. Please verify script reference.", "error");
            }
        }

        function GetStudentByIdSuccessCallback(result) {
            if (result) {
                document.getElementById('<%= txtName.ClientID %>').value = result.Name || "";
                document.getElementById('<%= txtGender.ClientID %>').value = result.Gender || "";
                document.getElementById('<%= txtTotalMarks.ClientID %>').value = result.TotalMarks;
                setStatus("Record retrieved for Student ID #" + result.ID + " (" + result.Name + ").", "success");
            } else {
                document.getElementById('<%= txtName.ClientID %>').value = "";
                document.getElementById('<%= txtGender.ClientID %>').value = "";
                document.getElementById('<%= txtTotalMarks.ClientID %>').value = "";
                setStatus("No student found with ID #" + document.getElementById('<%= txtStudentId.ClientID %>').value + ".", "error");
            }
        }

        function GetStudentByIdFailedCallback(errors) {
            var msg = errors && errors.get_message ? errors.get_message() : "Unknown error invoking web service.";
            setStatus("Service error: " + msg, "error");
        }

        function setStatus(message, type) {
            var statusDiv = document.getElementById("statusBox");
            if (!statusDiv) return;
            statusDiv.style.display = "block";
            statusDiv.innerText = message;

            if (type === "success") {
                statusDiv.style.background = "#edf7ed";
                statusDiv.style.color = "#1e4620";
                statusDiv.style.borderColor = "#c8e6c9";
            } else if (type === "error") {
                statusDiv.style.background = "#fdeded";
                statusDiv.style.color = "#5f2120";
                statusDiv.style.borderColor = "#f5c6cb";
            } else {
                statusDiv.style.background = "#e8f4fd";
                statusDiv.style.color = "#014361";
                statusDiv.style.borderColor = "#b8e2fb";
            }
        }

        function fillAndSearch(id) {
            document.getElementById('<%= txtStudentId.ClientID %>').value = id;
            GetStudentById();
        }
    </script>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <!-- Register StudentService.asmx proxy with ASP.NET AJAX -->
    <asp:ScriptManagerProxy ID="ScriptManagerProxy1" runat="server">
        <Services>
            <asp:ServiceReference Path="~/StudentService.asmx" />
        </Services>
    </asp:ScriptManagerProxy>

    <h1 class="page-title">Student Portal</h1>
    <p class="page-subtitle">Calling an ASP.NET Web Service directly from JavaScript using ASP.NET AJAX (<code>[ScriptService]</code>).</p>

    <div class="notion-callout">
        <svg class="callout-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/>
        </svg>
        <div>
            <strong>Partial Page Communication Proof:</strong> Notice the <em>Page Initial Render Time</em> displayed below. 
            When you type a Student ID and click <strong>Get Student</strong>, the student data fills instantly from the SQL Server stored procedure 
            (<code>spGetStudentByID</code>) via client-side AJAX, while the render time remains completely unchanged.
        </div>
    </div>

    <!-- Live Render Time Proof Banner -->
    <div style="background:var(--bg-secondary); border:1px solid var(--border); border-radius:var(--radius); padding:10px 16px; margin-bottom:20px; font-size:13px; display:flex; align-items:center; justify-content:space-between;">
        <span>Page Initial Server Render Time: <strong style="font-family:'SFMono-Regular',Consolas,monospace;"><asp:Label ID="lblPageTime" runat="server"></asp:Label></strong></span>
        <span class="notion-badge badge-info">Zero Full-Page Postbacks</span>
    </div>

    <!-- Status Message Box -->
    <div id="statusBox" style="display:none; padding:10px 14px; border-radius:var(--radius); border:1px solid var(--border); font-size:13px; margin-bottom:18px;"></div>

    <!-- Student Lookup Form -->
    <div style="max-width:540px; background:var(--bg); border:1px solid var(--border); border-radius:var(--radius); padding:20px 24px; margin-bottom:30px;">
        <h3 class="notion-h3" style="margin-top:0; margin-bottom:16px;">Student Information Lookup</h3>

        <div class="notion-form-row">
            <span class="notion-form-label">Student ID:</span>
            <asp:TextBox ID="txtStudentId" runat="server" CssClass="notion-input" style="min-width:140px; width:140px;" placeholder="e.g. 1"></asp:TextBox>
            <input id="btnGetStudent" type="button" value="Get Student" class="notion-btn" onclick="GetStudentById()" />
        </div>

        <div class="notion-form-row">
            <span class="notion-form-label">Full Name:</span>
            <asp:TextBox ID="txtName" runat="server" ReadOnly="true" CssClass="notion-input" style="width:100%;"></asp:TextBox>
        </div>

        <div class="notion-form-row">
            <span class="notion-form-label">Gender:</span>
            <asp:TextBox ID="txtGender" runat="server" ReadOnly="true" CssClass="notion-input" style="width:100%;"></asp:TextBox>
        </div>

        <div class="notion-form-row" style="margin-bottom:0;">
            <span class="notion-form-label">Total Marks:</span>
            <asp:TextBox ID="txtTotalMarks" runat="server" ReadOnly="true" CssClass="notion-input" style="width:100%;"></asp:TextBox>
        </div>
    </div>

    <hr class="notion-divider" />

    <!-- Available Students Helper Table -->
    <h3 class="notion-h3">Available Students in Database (Click to Query via AJAX)</h3>
    <span class="gv-count">Quickly test existing IDs generated in <code>tblStudents</code></span>

    <div class="gv-wrap" style="max-width:720px;">
        <asp:GridView
            ID="gvStudentList"
            runat="server"
            AutoGenerateColumns="False"
            GridLines="None"
            CssClass="notion-table">

            <Columns>
                <asp:BoundField DataField="ID"         HeaderText="ID"          ItemStyle-Width="60px" />
                <asp:BoundField DataField="Name"       HeaderText="Student Name" ItemStyle-Width="220px" />
                <asp:BoundField DataField="Gender"     HeaderText="Gender"      ItemStyle-Width="120px" />
                <asp:BoundField DataField="TotalMarks" HeaderText="Total Marks" ItemStyle-Width="120px" />
                <asp:TemplateField HeaderText="Action" ItemStyle-Width="100px">
                    <ItemTemplate>
                        <a href="javascript:void(0);" onclick='fillAndSearch(<%# Eval("ID") %>);' style="font-size:12px; color:var(--accent); text-decoration:none;">Load Record &rarr;</a>
                    </ItemTemplate>
                </asp:TemplateField>
            </Columns>
        </asp:GridView>
    </div>

</asp:Content>
