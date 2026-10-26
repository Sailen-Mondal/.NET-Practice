# .NET Workspace Guidelines

## Scope & Context
- Practice and project codebase for .NET Framework, modern .NET, ASP.NET WebForms, MVC, ADO.NET, and C#.

## Code Style & Architectural Guidelines
- **Simple, Didactic Architecture**:
  - Implement features cleanly with direct separation of concerns (Presentation, Business Logic, Data Access / Database) without excess abstraction layers.
  - For ADO.NET: Always manage resources safely with `using` blocks (`SqlConnection`, `SqlCommand`, `SqlDataReader`) to prevent connection leaks.
  - For WebForms: Follow conventional ASP.NET control prefixes (`btnSubmit`, `lblMessage`, `txtUsername`, `gvCustomers`, etc.) and keep `.aspx` markup and code-behind cleanly synchronized.
  - For LINQ: Write clear query/method syntax with explicit variable naming.
- **Visuals**: Notion-like minimal aesthetic for all WebForms/HTML pages. No emojis.
