<%@ Page Title="LINQ Assessment" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="LINQAssessment._Default" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">

    <div class="page-title">LINQ Assessment Solutions</div>
    <div class="page-subtitle">Clean, minimal implementations of core LINQ operations: grouping, filtering by degree, and flattening collections.</div>

    <div class="button-row">
        <asp:Button ID="btnExecuteTasks" runat="server" Text="Execute All LINQ Tasks" CssClass="btn-notion btn-notion-primary" OnClick="btnExecuteTasks_Click" />
        <asp:Label ID="lblStatus" runat="server" CssClass="badge-tag" Text="Ready" />
    </div>

    <!-- Task 1 -->
    <div class="notion-card">
        <div class="card-title">Task 1: Enrolled Students Grouped by Department</div>
        <div class="card-desc">
            Groups active enrolled students by their department and counts the number of students belonging to each department.
        </div>

        <div class="code-box">
// LINQ Query: Filter enrolled students, group by Department, count per group
var departmentCounts = students
    .Where(s => s.IsEnrolled)
    .GroupBy(s => s.Department)
    .Select(g => new DepartmentGroupResult
    {
        Department = g.Key,
        StudentCount = g.Count()
    })
    .OrderByDescending(r => r.StudentCount)
    .ToList();
        </div>

        <asp:GridView ID="gvDepartmentCounts" runat="server" AutoGenerateColumns="False" CssClass="notion-grid" GridLines="None">
            <Columns>
                <asp:BoundField DataField="Department" HeaderText="Department" />
                <asp:BoundField DataField="StudentCount" HeaderText="Enrolled Student Count" ItemStyle-Width="200px" />
            </Columns>
        </asp:GridView>
    </div>

    <!-- Task 2 -->
    <div class="notion-card">
        <div class="card-title">Task 2: Graph Nodes with Degree Greater Than 3</div>
        <div class="card-desc">
            Finds all graph nodes (vertices) whose degree (number of direct connections) is strictly greater than 3.
        </div>

        <div class="code-box">
// LINQ Query: Filter nodes where connection count is greater than 3
var highDegreeNodes = nodes
    .Where(n => n.Connections.Count > 3)
    .Select(n => new GraphNodeResult
    {
        Vertex = n.Vertex,
        Degree = n.Connections.Count,
        ConnectedTo = string.Join(", ", n.Connections)
    })
    .OrderByDescending(n => n.Degree)
    .ToList();
        </div>

        <asp:GridView ID="gvHighDegreeNodes" runat="server" AutoGenerateColumns="False" CssClass="notion-grid" GridLines="None">
            <Columns>
                <asp:BoundField DataField="Vertex" HeaderText="Vertex / Node" ItemStyle-Width="150px" />
                <asp:BoundField DataField="Degree" HeaderText="Degree (Connections)" ItemStyle-Width="180px" />
                <asp:BoundField DataField="ConnectedTo" HeaderText="Connected Neighbors" />
            </Columns>
        </asp:GridView>
    </div>

    <!-- Task 3 -->
    <div class="notion-card">
        <div class="card-title">Task 3: Unique Flat Prerequisite Course Codes</div>
        <div class="card-desc">
            Given a student's enrolled courses for the year, extracts a flat, deduplicated list of every prerequisite course code they need to clear.
        </div>

        <div class="code-box">
// LINQ Query: Flatten nested prerequisite lists with SelectMany and deduplicate with Distinct
var uniquePrerequisites = enrolledCourses
    .SelectMany(course => course.Prerequisites)
    .Distinct()
    .OrderBy(code => code)
    .ToList();
        </div>

        <asp:GridView ID="gvPrerequisites" runat="server" AutoGenerateColumns="False" CssClass="notion-grid" GridLines="None">
            <Columns>
                <asp:TemplateField HeaderText="Prerequisite Course Code">
                    <ItemTemplate>
                        <span class="badge-tag"><%# Container.DataItem %></span>
                    </ItemTemplate>
                </asp:TemplateField>
            </Columns>
        </asp:GridView>
    </div>

    <!-- Formatted Terminal Output -->
    <div class="notion-card">
        <div class="card-title">Terminal / Console View</div>
        <div class="card-desc">Understated CLI formatted summary of execution results.</div>
        <pre class="terminal-output"><asp:Literal ID="litTerminalOutput" runat="server" /></pre>
    </div>

</asp:Content>
