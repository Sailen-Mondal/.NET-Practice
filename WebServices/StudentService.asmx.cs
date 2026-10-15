using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.Services;

namespace WebServices
{
    /// <summary>
    /// ASP.NET AJAX-enabled Web Service.
    /// The [ScriptService] attribute enables client-side JavaScript invocation
    /// via ASP.NET AJAX ScriptManager and ServiceReference proxies.
    /// </summary>
    [WebService(Namespace = "http://tempuri.org/")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    [System.ComponentModel.ToolboxItem(false)]
    [System.Web.Script.Services.ScriptService] // Crucial: Enables JavaScript AJAX calling
    public class StudentService : System.Web.Services.WebService
    {
        private readonly string cs = ConfigurationManager.ConnectionStrings["StudentDBCon"].ConnectionString;

        /// <summary>
        /// Retrieves a single student by ID using the spGetStudentByID stored procedure.
        /// Returns a Student object which is automatically serialized to JSON by ASP.NET AJAX.
        /// </summary>
        /// <param name="ID">Student ID to look up</param>
        /// <returns>Student instance or null if not found</returns>
        [WebMethod(Description = "Retrieves student record by ID via spGetStudentByID stored procedure.")]
        public Student GetStudentByID(int ID)
        {
            Student student = null;

            using (SqlConnection con = new SqlConnection(cs))
            {
                using (SqlCommand cmd = new SqlCommand("spGetStudentByID", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add(new SqlParameter("@ID", ID));

                    con.Open();
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            student = new Student
                            {
                                ID = Convert.ToInt32(reader["ID"]),
                                Name = reader["Name"] == DBNull.Value ? string.Empty : reader["Name"].ToString(),
                                Gender = reader["Gender"] == DBNull.Value ? string.Empty : reader["Gender"].ToString(),
                                TotalMarks = reader["TotalMarks"] == DBNull.Value ? 0 : Convert.ToInt32(reader["TotalMarks"])
                            };
                        }
                    }
                }
            }

            return student;
        }

        /// <summary>
        /// Helper method to fetch all students for the UI lookup helper table.
        /// </summary>
        /// <returns>List of Student objects</returns>
        [WebMethod(Description = "Returns all students from tblStudents.")]
        public List<Student> GetAllStudents()
        {
            List<Student> students = new List<Student>();

            using (SqlConnection con = new SqlConnection(cs))
            {
                using (SqlCommand cmd = new SqlCommand("spGetAllStudents", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    con.Open();
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            students.Add(new Student
                            {
                                ID = Convert.ToInt32(reader["ID"]),
                                Name = reader["Name"] == DBNull.Value ? string.Empty : reader["Name"].ToString(),
                                Gender = reader["Gender"] == DBNull.Value ? string.Empty : reader["Gender"].ToString(),
                                TotalMarks = reader["TotalMarks"] == DBNull.Value ? 0 : Convert.ToInt32(reader["TotalMarks"])
                            });
                        }
                    }
                }
            }

            return students;
        }
    }
}
