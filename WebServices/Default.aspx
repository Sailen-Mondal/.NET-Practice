<%@ Page Title="Overview" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="WebServices._Default" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <h1 class="page-title">Web Services Practice</h1>
    <p class="page-subtitle">Interactive practice workspace exploring ASP.NET ASMX Web Services, SOAP, XML, WSDL, and ASP.NET AJAX ScriptService.</p>

    <div class="notion-callout">
        <svg class="callout-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/>
        </svg>
        <div>
            <strong>Web Service Core Concept:</strong> A Web Service is a language-independent software system designed to support interoperable machine-to-machine interaction over a network. It uses standard web protocols (HTTP) and open data formats (XML, SOAP, JSON) to ensure incompatible systems can communicate across firewalls.
        </div>
    </div>

    <hr class="notion-divider" />

    <h3 class="notion-h3">Learning Modules</h3>

    <div class="notion-card-grid">
        <a class="notion-card" href="UserDirectory.aspx">
            <div class="notion-card-title">
                <span>User Directory</span>
                <span class="notion-badge">SOAP &middot; XML</span>
            </div>
            <div class="notion-card-desc">
                Query the <code>UserInformation</code> database table through <code>UserService.asmx</code> returning an <code>XmlElement</code>. The ASP.NET consumer parses the XML into a <code>DataSet</code> and binds to a GridView.
            </div>
            <span class="notion-card-badge">Module 1 &middot; Server Consumer</span>
        </a>

        <a class="notion-card" href="StudentPortal.aspx">
            <div class="notion-card-title">
                <span>Student Portal</span>
                <span class="notion-badge badge-info">AJAX &middot; JSON</span>
            </div>
            <div class="notion-card-desc">
                Call <code>StudentService.asmx</code> directly from client-side JavaScript using ASP.NET AJAX <code>ScriptManager</code>. Executes <code>spGetStudentByID</code> with zero page reload.
            </div>
            <span class="notion-card-badge">Module 2 &middot; ScriptService</span>
        </a>

        <a class="notion-card" href="Endpoints.aspx">
            <div class="notion-card-title">
                <span>Service Endpoints</span>
                <span class="notion-badge">WSDL &middot; Raw ASMX</span>
            </div>
            <div class="notion-card-desc">
                Browse the auto-generated Web Service test harnesses, inspect XML method signatures, and view machine-readable <code>?WSDL</code> contracts.
            </div>
            <span class="notion-card-badge">Module 3 &middot; Interface Contract</span>
        </a>

        <a class="notion-card" href="Concepts.aspx">
            <div class="notion-card-title">
                <span>Concepts & Architecture</span>
                <span class="notion-badge">MCC IT Study Guide</span>
            </div>
            <div class="notion-card-desc">
                Study notes detailing SOAP, WSDL, UDDI, DISCO files, HTTP transmission, XML serialization, and advantages of web services.
            </div>
            <span class="notion-card-badge">Module 4 &middot; Reference</span>
        </a>
    </div>

    <hr class="notion-divider" />

    <h3 class="notion-h3">Environment & Database Status</h3>
    
    <div class="gv-wrap">
        <table class="notion-table">
            <thead>
                <tr>
                    <th>Component</th>
                    <th>Configuration / Target</th>
                    <th>Status</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td><strong>Database Instance</strong></td>
                    <td>Microsoft SQL Server (<code>TestDB</code> on localhost)</td>
                    <td><span class="notion-badge badge-success">Connected</span></td>
                </tr>
                <tr>
                    <td><strong>User Table</strong></td>
                    <td><code>UserInformation</code> (<asp:Literal ID="litUserCount" runat="server">8</asp:Literal> records)</td>
                    <td><span class="notion-badge badge-success">Ready</span></td>
                </tr>
                <tr>
                    <td><strong>Student Table</strong></td>
                    <td><code>tblStudents</code> (<asp:Literal ID="litStudentCount" runat="server">8</asp:Literal> records)</td>
                    <td><span class="notion-badge badge-success">Ready</span></td>
                </tr>
                <tr>
                    <td><strong>Stored Procedure</strong></td>
                    <td><code>spGetStudentByID</code></td>
                    <td><span class="notion-badge badge-success">Compiled</span></td>
                </tr>
                <tr>
                    <td><strong>Runtime Framework</strong></td>
                    <td>.NET Framework 4.7.2 &middot; ASP.NET Web Forms</td>
                    <td><span class="notion-badge badge-info">Active</span></td>
                </tr>
            </tbody>
        </table>
    </div>

</asp:Content>
