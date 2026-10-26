<%@ Page Title="About LINQ" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="About.aspx.cs" Inherits="CRUDUsingLINQ.About" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="notion-header-group">
        <h1 class="notion-page-title">About LINQ (Language Integrated Query)</h1>
        <p class="notion-page-desc">Comprehensive reference guide for LINQ fundamentals, architecture, and providers.</p>
    </div>

    <h2 class="notion-section-title">What is LINQ?</h2>
    <p>
        LINQ stands for <strong>Language Integrated Query</strong>. LINQ enables developers to query any type of data store (SQL Server databases, XML documents, in-memory objects, etc.) using a unified, strongly-typed C# syntax.
    </p>

    <h2 class="notion-section-title">Why Use LINQ?</h2>
    <div class="notion-callout">
        <div class="notion-callout-header">[Before LINQ] Fragmented Data Technologies</div>
        <div class="notion-callout-body">
            Prior to LINQ, querying different data sources required learning multiple unrelated syntaxes:
            <ul>
                <li>SQL Server: ADO.NET and T-SQL dialect</li>
                <li>XML documents: XSLT &amp; XPath</li>
                <li>In-memory collections: manual loops and conditions (<code class="notion-badge">List&lt;Customer&gt;</code>)</li>
            </ul>
        </div>
    </div>
    <div class="notion-callout">
        <div class="notion-callout-header">[With LINQ] Unified Syntax &amp; Safety</div>
        <div class="notion-callout-body">
            <ul>
                <li><strong>Unified Coding Style:</strong> The same LINQ syntax works across SQL Server, XML, and objects.</li>
                <li><strong>Compile-time Type Checking:</strong> Errors in column or table names are caught at compile-time instead of runtime.</li>
                <li><strong>IntelliSense:</strong> Rich autocompletion and documentation during development.</li>
            </ul>
        </div>
    </div>

    <h2 class="notion-section-title">LINQ Architecture &amp; Providers</h2>
    <p>
        A <strong>LINQ Provider</strong> is a component between the LINQ query and the actual data store that converts the LINQ expression tree into the native dialect understood by the data source. For example, the <strong>LINQ to SQL</strong> provider translates LINQ queries into T-SQL.
    </p>
</asp:Content>
