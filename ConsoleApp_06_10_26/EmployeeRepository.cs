using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

namespace ConsoleApp_06_10_26
{
    // ================================================================
    // Repository - Implements CRUD via stored procedures
    // ================================================================
    public class EmployeeRepository : IEmployeeRepository
    {
        private readonly string _connectionString;

        public EmployeeRepository(string connectionString)
        {
            _connectionString = connectionString;
        }

        // Inserts a new employee and returns the generated ID
        public int AddEmployee(Employee emp)
        {
            using (SqlConnection conn = new SqlConnection(_connectionString))
            {
                SqlCommand cmd = new SqlCommand("sp_InsertEmployee", conn);
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@LastName", emp.LastName);
                cmd.Parameters.AddWithValue("@FirstName", (object)emp.FirstName ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@Age", (object)emp.Age ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@City", (object)emp.City ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@DateOfJoining", (object)emp.DateOfJoining ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@Salary", (object)emp.Salary ?? DBNull.Value);

                conn.Open();

                // Capture PRINT messages from stored procedure
                conn.InfoMessage += (sender, e) => Console.WriteLine("[SQL] " + e.Message);

                // sp_InsertEmployee returns SCOPE_IDENTITY() as NewID
                object result = cmd.ExecuteScalar();
                return Convert.ToInt32(result);
            }
        }

        // Retrieves all employees from the table
        public List<Employee> GetAllEmployees()
        {
            List<Employee> employees = new List<Employee>();

            using (SqlConnection conn = new SqlConnection(_connectionString))
            {
                SqlCommand cmd = new SqlCommand("sp_GetAllEmployees", conn);
                cmd.CommandType = CommandType.StoredProcedure;

                conn.Open();

                // Capture PRINT messages from stored procedure
                conn.InfoMessage += (sender, e) => Console.WriteLine("[SQL] " + e.Message);

                SqlDataReader reader = cmd.ExecuteReader();

                while (reader.Read())
                {
                    employees.Add(MapEmployee(reader));
                }
            }

            return employees;
        }

        // Retrieves a single employee by ID
        public Employee GetEmployeeById(int id)
        {
            using (SqlConnection conn = new SqlConnection(_connectionString))
            {
                SqlCommand cmd = new SqlCommand("sp_GetEmployeeById", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@ID", id);

                conn.Open();

                // Capture PRINT messages from stored procedure
                conn.InfoMessage += (sender, e) => Console.WriteLine("[SQL] " + e.Message);

                SqlDataReader reader = cmd.ExecuteReader();

                if (reader.Read())
                {
                    return MapEmployee(reader);
                }
            }

            return null;
        }

        // Updates an existing employee, returns true if a row was affected
        public bool UpdateEmployee(Employee emp)
        {
            using (SqlConnection conn = new SqlConnection(_connectionString))
            {
                SqlCommand cmd = new SqlCommand("sp_UpdateEmployee", conn);
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@ID", emp.ID);
                cmd.Parameters.AddWithValue("@LastName", emp.LastName);
                cmd.Parameters.AddWithValue("@FirstName", (object)emp.FirstName ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@Age", (object)emp.Age ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@City", (object)emp.City ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@DateOfJoining", (object)emp.DateOfJoining ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@Salary", (object)emp.Salary ?? DBNull.Value);

                conn.Open();

                // Capture PRINT messages from stored procedure
                conn.InfoMessage += (sender, e) => Console.WriteLine("[SQL] " + e.Message);

                // sp_UpdateEmployee returns @@ROWCOUNT as RowsAffected
                object result = cmd.ExecuteScalar();
                return Convert.ToInt32(result) > 0;
            }
        }

        // Deletes an employee by ID, returns true if a row was affected
        public bool DeleteEmployee(int id)
        {
            using (SqlConnection conn = new SqlConnection(_connectionString))
            {
                SqlCommand cmd = new SqlCommand("sp_DeleteEmployee", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@ID", id);

                conn.Open();

                // Capture PRINT messages from stored procedure
                conn.InfoMessage += (sender, e) => Console.WriteLine("[SQL] " + e.Message);

                // sp_DeleteEmployee returns @@ROWCOUNT as RowsAffected
                object result = cmd.ExecuteScalar();
                return Convert.ToInt32(result) > 0;
            }
        }

        // Helper - Maps a SqlDataReader row to an Employee object
        private Employee MapEmployee(SqlDataReader reader)
        {
            return new Employee
            {
                ID            = (int)reader["ID"],
                LastName      = reader["LastName"].ToString(),
                FirstName     = reader["FirstName"] == DBNull.Value ? null : reader["FirstName"].ToString(),
                Age           = reader["Age"] == DBNull.Value ? (int?)null : (int)reader["Age"],
                City          = reader["City"] == DBNull.Value ? null : reader["City"].ToString(),
                DateOfJoining = reader["DateOfJoining"] == DBNull.Value ? (DateTime?)null : (DateTime)reader["DateOfJoining"],
                Salary        = reader["Salary"] == DBNull.Value ? (decimal?)null : (decimal)reader["Salary"]
            };
        }
    }
}
