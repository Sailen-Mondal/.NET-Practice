using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using WebApplication1.Models;

namespace WebApplication1.DAL
{
    // =========================================================================
    // DATA ACCESS LAYER (DAL)
    // Directly communicates with the database using ADO.NET (SqlConnection, SqlCommand)
    // Decoupled from UI and Business Logic
    // =========================================================================
    public class EmployeeDAL
    {
        // Read connection string from Web.config (with fallback if tested outside IIS)
        private readonly string cs = ConfigurationManager.ConnectionStrings["myCon"] != null
            ? ConfigurationManager.ConnectionStrings["myCon"].ConnectionString
            : "Data Source=.;Initial Catalog=ADOPractice;User ID=sa;Password=mcc#1234;TrustServerCertificate=True";

        // Method to insert a new Employee into database
        public int InsertEmployee(Employee emp)
        {
            using (SqlConnection con = new SqlConnection(cs))
            {
                using (SqlCommand cmd = new SqlCommand("dbo.usp_Employee_Insert", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    // Add parameters to prevent SQL Injection
                    cmd.Parameters.AddWithValue("@FirstName", emp.FirstName);
                    cmd.Parameters.AddWithValue("@LastName", emp.LastName);
                    cmd.Parameters.AddWithValue("@Age", emp.Age);
                    cmd.Parameters.AddWithValue("@City", emp.City);
                    cmd.Parameters.AddWithValue("@DateOfJoining", emp.DateOfJoining);
                    cmd.Parameters.AddWithValue("@Salary", emp.Salary);

                    con.Open();
                    // Returns the new employee ID
                    object result = cmd.ExecuteScalar();
                    return result != null ? Convert.ToInt32(result) : 0;
                }
            }
        }

        // Method to fetch all employees to display in GridView
        public DataTable GetAllEmployees()
        {
            DataTable dt = new DataTable();

            using (SqlConnection con = new SqlConnection(cs))
            {
                using (SqlCommand cmd = new SqlCommand("dbo.usp_Employee_GetAll", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    using (SqlDataAdapter sda = new SqlDataAdapter(cmd))
                    {
                        sda.Fill(dt);
                    }
                }
            }

            return dt;
        }
    }
}
