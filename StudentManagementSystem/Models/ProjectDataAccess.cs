using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace StudentManagementSystem.Models
{
    // ADO.NET Data Access Layer for ProjectManagementDB.
    // Follows safe resource management using deterministic using blocks and parameterized queries.
    public class ProjectDataAccess
    {
        private readonly string connectionString;

        public ProjectDataAccess() : this(null)
        {
        }

        public ProjectDataAccess(string connString)
        {
            connectionString = connString ?? ConfigurationManager.ConnectionStrings["ProjectManagementDB"]?.ConnectionString;
        }

        // Retrieves all projects, with optional search and status filtering.
        public List<Project> GetAllProjects(string search = null, string status = null)
        {
            var list = new List<Project>();
            string sql = @"SELECT ProjectID, Title, Description, Category, LeadStudent, Status, Priority, Budget, StartDate, EndDate 
                           FROM dbo.Projects 
                           WHERE (1 = 1)";

            if (!string.IsNullOrWhiteSpace(search))
            {
                sql += @" AND (Title LIKE @Search OR LeadStudent LIKE @Search OR Category LIKE @Search OR Description LIKE @Search)";
            }

            if (!string.IsNullOrWhiteSpace(status) && status != "All")
            {
                sql += @" AND (Status = @Status)";
            }

            sql += " ORDER BY ProjectID DESC";

            using (var conn = new SqlConnection(connectionString))
            using (var cmd = new SqlCommand(sql, conn))
            {
                if (!string.IsNullOrWhiteSpace(search))
                {
                    cmd.Parameters.AddWithValue("@Search", "%" + search.Trim() + "%");
                }
                if (!string.IsNullOrWhiteSpace(status) && status != "All")
                {
                    cmd.Parameters.AddWithValue("@Status", status.Trim());
                }

                conn.Open();
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        list.Add(MapReaderToProject(reader));
                    }
                }
            }

            return list;
        }

        // Retrieves a single project by its primary key ID.
        public Project GetProjectById(int id)
        {
            string sql = @"SELECT ProjectID, Title, Description, Category, LeadStudent, Status, Priority, Budget, StartDate, EndDate 
                           FROM dbo.Projects 
                           WHERE ProjectID = @ProjectID";

            using (var conn = new SqlConnection(connectionString))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@ProjectID", id);
                conn.Open();

                using (var reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        return MapReaderToProject(reader);
                    }
                }
            }

            return null;
        }

        // Inserts a new project record and returns the generated ProjectID.
        public int InsertProject(Project project)
        {
            string sql = @"INSERT INTO dbo.Projects 
                           (Title, Description, Category, LeadStudent, Status, Priority, Budget, StartDate, EndDate)
                           VALUES
                           (@Title, @Description, @Category, @LeadStudent, @Status, @Priority, @Budget, @StartDate, @EndDate);
                           SELECT CAST(SCOPE_IDENTITY() AS INT);";

            using (var conn = new SqlConnection(connectionString))
            using (var cmd = new SqlCommand(sql, conn))
            {
                AddProjectParameters(cmd, project);
                conn.Open();
                int newId = (int)cmd.ExecuteScalar();
                project.ProjectID = newId;
                return newId;
            }
        }

        // Updates an existing project record.
        public bool UpdateProject(Project project)
        {
            string sql = @"UPDATE dbo.Projects 
                           SET Title = @Title,
                               Description = @Description,
                               Category = @Category,
                               LeadStudent = @LeadStudent,
                               Status = @Status,
                               Priority = @Priority,
                               Budget = @Budget,
                               StartDate = @StartDate,
                               EndDate = @EndDate
                           WHERE ProjectID = @ProjectID";

            using (var conn = new SqlConnection(connectionString))
            using (var cmd = new SqlCommand(sql, conn))
            {
                AddProjectParameters(cmd, project);
                cmd.Parameters.AddWithValue("@ProjectID", project.ProjectID);

                conn.Open();
                int rows = cmd.ExecuteNonQuery();
                return rows > 0;
            }
        }

        // Deletes a project record by ID.
        public bool DeleteProject(int id)
        {
            string sql = "DELETE FROM dbo.Projects WHERE ProjectID = @ProjectID";

            using (var conn = new SqlConnection(connectionString))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@ProjectID", id);
                conn.Open();
                int rows = cmd.ExecuteNonQuery();
                return rows > 0;
            }
        }

        // Computes aggregated KPI metrics for the Bento Grid overview.
        public ProjectMetrics GetProjectMetrics()
        {
            var metrics = new ProjectMetrics();
            string sql = @"SELECT 
                               COUNT(*) AS TotalProjects,
                               ISNULL(SUM(CASE WHEN Status = 'In Progress' THEN 1 ELSE 0 END), 0) AS InProgressCount,
                               ISNULL(SUM(CASE WHEN Status = 'Completed' THEN 1 ELSE 0 END), 0) AS CompletedCount,
                               ISNULL(SUM(CASE WHEN Status = 'Planning' THEN 1 ELSE 0 END), 0) AS PlanningCount,
                               ISNULL(SUM(Budget), 0.0) AS TotalBudget,
                               ISNULL(AVG(Budget), 0.0) AS AverageBudget
                           FROM dbo.Projects";

            using (var conn = new SqlConnection(connectionString))
            using (var cmd = new SqlCommand(sql, conn))
            {
                conn.Open();
                using (var reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        metrics.TotalProjects = Convert.ToInt32(reader["TotalProjects"]);
                        metrics.InProgressCount = Convert.ToInt32(reader["InProgressCount"]);
                        metrics.CompletedCount = Convert.ToInt32(reader["CompletedCount"]);
                        metrics.PlanningCount = Convert.ToInt32(reader["PlanningCount"]);
                        metrics.TotalBudget = Convert.ToDecimal(reader["TotalBudget"]);
                        metrics.AverageBudget = Convert.ToDecimal(reader["AverageBudget"]);
                    }
                }
            }

            return metrics;
        }

        private Project MapReaderToProject(SqlDataReader reader)
        {
            return new Project
            {
                ProjectID = Convert.ToInt32(reader["ProjectID"]),
                Title = reader["Title"]?.ToString(),
                Description = reader["Description"] == DBNull.Value ? null : reader["Description"].ToString(),
                Category = reader["Category"]?.ToString(),
                LeadStudent = reader["LeadStudent"]?.ToString(),
                Status = reader["Status"]?.ToString(),
                Priority = reader["Priority"]?.ToString(),
                Budget = Convert.ToDecimal(reader["Budget"]),
                StartDate = Convert.ToDateTime(reader["StartDate"]),
                EndDate = reader["EndDate"] == DBNull.Value ? (DateTime?)null : Convert.ToDateTime(reader["EndDate"])
            };
        }

        private void AddProjectParameters(SqlCommand cmd, Project project)
        {
            cmd.Parameters.AddWithValue("@Title", project.Title ?? string.Empty);
            cmd.Parameters.AddWithValue("@Description", (object)project.Description ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@Category", project.Category ?? string.Empty);
            cmd.Parameters.AddWithValue("@LeadStudent", project.LeadStudent ?? string.Empty);
            cmd.Parameters.AddWithValue("@Status", project.Status ?? "Planning");
            cmd.Parameters.AddWithValue("@Priority", project.Priority ?? "Medium");
            cmd.Parameters.AddWithValue("@Budget", project.Budget);
            cmd.Parameters.AddWithValue("@StartDate", project.StartDate);
            cmd.Parameters.AddWithValue("@EndDate", (object)project.EndDate ?? DBNull.Value);
        }
    }
}
