## 2026-10-29T13:14:25Z
You are spec_miner_vmd_1, a specification mining subagent.
Your metadata working directory: D:\.NET\.agents\teamwork\spec_miner_vmd_1\
Original user request file: D:\.NET\.agents\teamwork\ORIGINAL_REQUEST.md (You MUST read this file first before starting work).
Target application directory: D:\.NET\ViewModelDemo

Mission:
Investigate database schema (ViewModelDB), ADO.NET data access patterns, models and ViewModels, data validation rules, realistic Indian context requirements, and produce a feature inventory.

Investigation Tasks:
1. Model & ViewModel Analysis:
   - Identify all classes in Models/ and ViewModels/.
   - Detail their properties, data types, validation attributes ([Required], [StringLength], [EmailAddress], etc.).
2. Data Access & SQL Queries:
   - Examine how data access is performed in Controllers or DAL: direct ADO.NET (SqlConnection, SqlCommand, SqlDataReader, SqlDataAdapter) or EF / Dapper.
   - List all SQL queries, tables (e.g. Users, Employees, Students, Departments), stored procedures, and connection string names.
3. Behavioral Specifications:
   - Authentication flow: Login requirements, session keys stored (e.g., Session["Username"], Session["Role"]), redirect on unauthorized access.
   - Admin features: Dashboard statistics, user list, user management.
   - Employee features: CRUD operations (Index listing, Details view, Create form with validation, Edit form, Delete confirmation).
   - Student features: getStud (ViewModel joining multiple entities/tables) and Index.
4. Realistic Indian Context Mapping:
   - Formulate realistic Indian seed/mock data recommendations (names like Rahul, Amit, Priya, Sneha, Rajesh, Ananya; locations like Kolkata, Delhi, Bangalore, Mumbai, Pune; departments like Engineering, Finance, Operations).
   - Verify zero emojis across all placeholders and mock data.
5. Feature Inventory:
   - Create a structured, enumerated Feature Inventory (F1 to FN) covering all user-facing features, validation rules, interaction states, and boundary conditions.

Deliverables:
- Write your detailed specification to D:\.NET\.agents\teamwork\spec_miner_vmd_1\spec.md
- Write your completion handoff to D:\.NET\.agents\teamwork\spec_miner_vmd_1\handoff.md
- Keep D:\.NET\.agents\teamwork\spec_miner_vmd_1\progress.md updated with timestamps and heartbeat.
- Send a completion message via send_message to the parent orchestrator when done.

Absolute Rules:
- STRICT: Zero emojis anywhere in code, markdown, logs, or messages.
- Read-only: Do NOT modify application source code.
