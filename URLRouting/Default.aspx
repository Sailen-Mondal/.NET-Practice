<%@ Page Title="Home Page" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="URLRouting._Default" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">

    <main>
        <section class="row py-4" aria-labelledby="aspnetTitle">
            <h1 id="aspnetTitle" class="text-primary">Page Redirection & URL Routing in ASP.NET</h1>
            <p class="lead">Interactive practice demos for Page Redirection (<code>Response.Redirect</code>) and URL Routing (<code>System.Web.Routing</code>).</p>
        </section>

        <div class="row g-4">
            <!-- Card 1: Page Redirection -->
            <section class="col-md-6">
                <div class="card h-100 p-3 shadow-sm border-primary">
                    <div class="card-body">
                        <h3 class="card-title text-primary">1. Page Redirection</h3>
                        <p class="card-text">
                            Learn how <code>Response.Redirect</code> works compared to <code>HyperLink</code> controls:
                        </p>
                        <ul>
                            <li>Hyperlinks are client-side only (no server events to intercept).</li>
                            <li>Buttons and LinkButtons allow intercepting the click on the server before redirecting.</li>
                            <li>Causes <b>2 Request/Response cycles</b> (HTTP 302 Found &rarr; HTTP GET).</li>
                            <li>Works on the <b>same web server</b> or <b>different web servers</b>.</li>
                        </ul>
                        <a href="PageRedirectionDemo.aspx" class="btn btn-primary mt-2">Open Page Redirection Demo &raquo;</a>
                    </div>
                </div>
            </section>

            <!-- Card 2: URL Routing -->
            <section class="col-md-6">
                <div class="card h-100 p-3 shadow-sm border-success">
                    <div class="card-body">
                        <h3 class="card-title text-success">2. URL Routing</h3>
                        <p class="card-text">
                            Learn how to create search-engine-friendly, dynamic URLs without exposing database query strings:
                        </p>
                        <ul>
                            <li>Configured in <code>RouteConfig.cs</code> using <code>routes.MapPageRoute(...)</code>.</li>
                            <li>Pattern: <code>Articles/{id}/{Title}</code> &rarr; maps to <code>~/DetailPage.aspx</code>.</li>
                            <li>Read parameters in target page using <code>Page.RouteData.Values["id"]</code>.</li>
                            <li>Database table <code>Articletable</code> in <code>TestDB</code>.</li>
                        </ul>
                        <a href="URLRouting.aspx" class="btn btn-success mt-2">Open URL Routing GridView Demo &raquo;</a>
                        <a href="Articles/1/How-to-validate-dropdownlist-in-asp.net" class="btn btn-outline-success mt-2">Test Direct Route &raquo;</a>
                    </div>
                </div>
            </section>
        </div>
    </main>

</asp:Content>
