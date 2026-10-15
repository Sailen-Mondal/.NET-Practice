<%@ Page Title="Concepts & Architecture" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Concepts.aspx.cs" Inherits="WebServices.Concepts" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <h1 class="page-title">Web Service Concepts & Architecture</h1>
    <p class="page-subtitle">Curriculum notes covering the fundamental architecture of Web Services, SOAP, WSDL, UDDI, and ASP.NET AJAX.</p>

    <!-- Concept 1 -->
    <div class="notion-callout">
        <svg class="callout-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/>
        </svg>
        <div>
            <h3 class="notion-h3" style="margin-top:0; margin-bottom:6px;">1. What is a Web Service?</h3>
            <p class="notion-p">
                A <strong>Web Service</strong> is an application designed to interact directly with other applications over the Internet. 
                Web service consumers invoke method calls on remote objects using standard protocols: 
                <strong>HTTP</strong>, <strong>XML</strong>, and <strong>SOAP</strong>.
            </p>
            <p class="notion-p">
                <strong>Key Advantage:</strong> Web Service messages are formatted in XML&mdash;a universal standard between incompatible systems&mdash;and transmitted via HTTP so they pass through corporate firewalls without special configuration.
            </p>
        </div>
    </div>

    <!-- Concept 2 -->
    <div class="notion-callout">
        <svg class="callout-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <polyline points="22 12 18 12 15 21 9 3 6 12 2 12"/>
        </svg>
        <div>
            <h3 class="notion-h3" style="margin-top:0; margin-bottom:6px;">2. What is SOAP?</h3>
            <p class="notion-p">
                <strong>SOAP (Simple Object Access Protocol)</strong> is a protocol specification for exchanging structured information. 
                It packages remote function calls into an XML envelope, transmits the payload across HTTP, and executes the target method on the remote machine.
            </p>
        </div>
    </div>

    <!-- Concept 3 -->
    <div class="notion-callout">
        <svg class="callout-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/><polyline points="10 9 9 9 8 9"/>
        </svg>
        <div>
            <h3 class="notion-h3" style="margin-top:0; margin-bottom:6px;">3. What is WSDL?</h3>
            <p class="notion-p">
                <strong>WSDL (Web Services Description Language)</strong> is an XML-based language used to describe the capabilities offered by a web service. 
                It specifies:
            </p>
            <ul style="padding-left:20px; font-size:14px; color:var(--text-light); line-height:1.8;">
                <li>The available methods and operations (e.g. <code>GetUserDetails</code>, <code>GetStudentByID</code>)</li>
                <li>The data types and schemas of arguments and return values</li>
                <li>The URL endpoints and port bindings (SOAP 1.1 / 1.2 / HTTP GET / POST)</li>
            </ul>
        </div>
    </div>

    <!-- Concept 4 -->
    <div class="notion-callout">
        <svg class="callout-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/>
        </svg>
        <div>
            <h3 class="notion-h3" style="margin-top:0; margin-bottom:6px;">4. What is UDDI &amp; .DISCO?</h3>
            <p class="notion-p">
                <strong>UDDI (Universal Description, Discovery, and Integration)</strong> is an XML-based registry standard that allows businesses to list themselves on the Internet and discover available Web Services.
            </p>
            <p class="notion-p">
                <strong>Discovery (.DISCO) Files:</strong> XML files located on web servers that group services together and link directly to their WSDL and SOAP endpoints for discovery tools.
            </p>
        </div>
    </div>

    <!-- Concept 5 -->
    <div class="notion-callout">
        <svg class="callout-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2"/>
        </svg>
        <div>
            <h3 class="notion-h3" style="margin-top:0; margin-bottom:6px;">5. Calling Web Services via ASP.NET AJAX ([ScriptService])</h3>
            <p class="notion-p">
                Adding the <code>[System.Web.Script.Services.ScriptService]</code> attribute to an ASMX service allows the ASP.NET AJAX framework to automatically generate client-side JavaScript proxies. 
                The client invokes methods via standard JSON calls, eliminating the overhead of full-page postbacks and manual XML parsing.
            </p>
        </div>
    </div>

</asp:Content>
