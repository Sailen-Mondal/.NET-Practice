<%@ Page Title="Service Endpoints" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Endpoints.aspx.cs" Inherits="WebServices.Endpoints" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <h1 class="page-title">Service Endpoints & WSDL</h1>
    <p class="page-subtitle">Inspect raw ASMX test harnesses, machine-readable WSDL descriptions, and client-side proxies.</p>

    <div class="notion-callout">
        <svg class="callout-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/>
        </svg>
        <div>
            <strong>WSDL (Web Services Description Language):</strong> 
            WSDL is an XML-based contract that tells consuming clients which operations the service provides, 
            which parameters and data types it expects, and the exact SOAP endpoints to send messages to.
        </div>
    </div>

    <div class="notion-card-grid">
        <!-- UserService Endpoint Card -->
        <div class="notion-card" style="cursor:default;">
            <div class="notion-card-title">
                <span>UserService.asmx</span>
                <span class="notion-badge">SOAP 1.1 / 1.2</span>
            </div>
            <div class="notion-card-desc">
                Classical ASP.NET Web Service returning <code>XmlElement</code>. Designed for cross-platform integration over SOAP and HTTP.
            </div>
            <div style="display:flex; flex-direction:column; gap:8px; margin-top:10px;">
                <a href="UserService.asmx" target="_blank" class="notion-btn notion-btn-secondary" style="text-align:center; text-decoration:none;">
                    Open ASMX Test Harness &rarr;
                </a>
                <a href="UserService.asmx?WSDL" target="_blank" class="notion-btn notion-btn-secondary" style="text-align:center; text-decoration:none;">
                    View WSDL XML Contract &rarr;
                </a>
            </div>
        </div>

        <!-- StudentService Endpoint Card -->
        <div class="notion-card" style="cursor:default;">
            <div class="notion-card-title">
                <span>StudentService.asmx</span>
                <span class="notion-badge badge-info">[ScriptService]</span>
            </div>
            <div class="notion-card-desc">
                ASP.NET AJAX-enabled Web Service returning strongly-typed <code>Student</code> objects, equipped with a dynamic client-side JS proxy.
            </div>
            <div style="display:flex; flex-direction:column; gap:8px; margin-top:10px;">
                <a href="StudentService.asmx" target="_blank" class="notion-btn notion-btn-secondary" style="text-align:center; text-decoration:none;">
                    Open ASMX Test Harness &rarr;
                </a>
                <a href="StudentService.asmx?WSDL" target="_blank" class="notion-btn notion-btn-secondary" style="text-align:center; text-decoration:none;">
                    View WSDL XML Contract &rarr;
                </a>
                <a href="StudentService.asmx/js" target="_blank" class="notion-btn notion-btn-secondary" style="text-align:center; text-decoration:none;">
                    View Generated JS Proxy Script &rarr;
                </a>
            </div>
        </div>
    </div>

    <hr class="notion-divider" />

    <h3 class="notion-h3">Exposed Operations Reference</h3>
    <div class="gv-wrap">
        <table class="notion-table">
            <thead>
                <tr>
                    <th>Service</th>
                    <th>Method Name</th>
                    <th>Parameters</th>
                    <th>Return Type</th>
                    <th>Protocol</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td><code>UserService.asmx</code></td>
                    <td><code>GetUserDetails</code></td>
                    <td><code>string userName</code></td>
                    <td><code>XmlElement</code></td>
                    <td>SOAP, HTTP GET, HTTP POST</td>
                </tr>
                <tr>
                    <td><code>UserService.asmx</code></td>
                    <td><code>GetAllUsers</code></td>
                    <td><em>None</em></td>
                    <td><code>XmlElement</code></td>
                    <td>SOAP, HTTP GET, HTTP POST</td>
                </tr>
                <tr>
                    <td><code>StudentService.asmx</code></td>
                    <td><code>GetStudentByID</code></td>
                    <td><code>int ID</code></td>
                    <td><code>Student</code></td>
                    <td>SOAP, JSON/AJAX, HTTP POST</td>
                </tr>
                <tr>
                    <td><code>StudentService.asmx</code></td>
                    <td><code>GetAllStudents</code></td>
                    <td><em>None</em></td>
                    <td><code>List&lt;Student&gt;</code></td>
                    <td>SOAP, JSON/AJAX, HTTP POST</td>
                </tr>
            </tbody>
        </table>
    </div>
</asp:Content>
