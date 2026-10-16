using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace Demo
{
    public class EmployeeDataAccessLayer
    {
        // Select Method for ObjectDataSource & Code-Behind
        public static List<Employee> GetAllEmployees()
        {
            List<Employee> listEmployees = new List<Employee>();
            string cs = ConfigurationManager.ConnectionStrings["DBCS"].ConnectionString;
            using (SqlConnection con = new SqlConnection(cs))
            {
                string query = "SELECT EmployeeId, ISNULL(Name, ISNULL(FirstName + ' ' + LastName, '')) AS Name, " +
                               "FirstName, LastName, DateOfBirth, Salary, AnnualSalary, Gender, DepartmentName, Country, CountryCulture, City " +
                               "FROM tblEmployee ORDER BY EmployeeId ASC";
                SqlCommand cmd = new SqlCommand(query, con);
                con.Open();
                SqlDataReader rdr = cmd.ExecuteReader();
                while (rdr.Read())
                {
                    Employee employee = new Employee();
                    employee.EmployeeId = Convert.ToInt32(rdr["EmployeeId"]);
                    employee.Name = rdr["Name"] != DBNull.Value ? rdr["Name"].ToString() : "";
                    employee.FirstName = rdr["FirstName"] != DBNull.Value ? rdr["FirstName"].ToString() : "";
                    employee.LastName = rdr["LastName"] != DBNull.Value ? rdr["LastName"].ToString() : "";
                    employee.DateOfBirth = rdr["DateOfBirth"] != DBNull.Value ? (DateTime?)Convert.ToDateTime(rdr["DateOfBirth"]) : null;
                    employee.Salary = rdr["Salary"] != DBNull.Value ? Convert.ToInt32(rdr["Salary"]) : 0;
                    employee.AnnualSalary = rdr["AnnualSalary"] != DBNull.Value ? Convert.ToInt32(rdr["AnnualSalary"]) : employee.Salary;
                    employee.Gender = rdr["Gender"] != DBNull.Value ? rdr["Gender"].ToString() : "";
                    employee.DepartmentName = rdr["DepartmentName"] != DBNull.Value ? rdr["DepartmentName"].ToString() : "";
                    employee.Country = rdr["Country"] != DBNull.Value ? rdr["Country"].ToString() : "";
                    employee.CountryCulture = rdr["CountryCulture"] != DBNull.Value ? rdr["CountryCulture"].ToString() : "";
                    employee.City = rdr["City"] != DBNull.Value ? rdr["City"].ToString() : "";
                    listEmployees.Add(employee);
                }
            }
            return listEmployees;
        }

        // Delete Method for ObjectDataSource & Code-Behind
        public static void DeleteEmployee(int EmployeeId)
        {
            string cs = ConfigurationManager.ConnectionStrings["DBCS"].ConnectionString;
            using (SqlConnection con = new SqlConnection(cs))
            {
                SqlCommand cmd = new SqlCommand("DELETE FROM tblEmployee WHERE EmployeeId = @EmployeeId", con);
                cmd.Parameters.Add(new SqlParameter("@EmployeeId", EmployeeId));
                con.Open();
                cmd.ExecuteNonQuery();
            }
        }

        // Update Method for ObjectDataSource & Code-Behind
        public static int UpdateEmployee(int EmployeeId, string Name, string Gender, string City)
        {
            string cs = ConfigurationManager.ConnectionStrings["DBCS"].ConnectionString;
            using (SqlConnection con = new SqlConnection(cs))
            {
                string updateQuery = "UPDATE tblEmployee SET Name = @Name, Gender = @Gender, City = @City WHERE EmployeeId = @EmployeeId";
                SqlCommand cmd = new SqlCommand(updateQuery, con);
                cmd.Parameters.Add(new SqlParameter("@EmployeeId", EmployeeId));
                cmd.Parameters.Add(new SqlParameter("@Name", (object)Name ?? DBNull.Value));
                cmd.Parameters.Add(new SqlParameter("@Gender", (object)Gender ?? DBNull.Value));
                cmd.Parameters.Add(new SqlParameter("@City", (object)City ?? DBNull.Value));
                con.Open();
                return cmd.ExecuteNonQuery();
            }
        }

        // Insert Method for ObjectDataSource & Code-Behind
        public static int InsertEmployee(string Name, string Gender, string City)
        {
            string cs = ConfigurationManager.ConnectionStrings["DBCS"].ConnectionString;
            using (SqlConnection con = new SqlConnection(cs))
            {
                string insertQuery = "INSERT INTO tblEmployee (Name, Gender, City, Salary, AnnualSalary, DepartmentName) " +
                                     "VALUES (@Name, @Gender, @City, 55000, 55000, 'General')";
                SqlCommand cmd = new SqlCommand(insertQuery, con);
                cmd.Parameters.Add(new SqlParameter("@Name", (object)Name ?? DBNull.Value));
                cmd.Parameters.Add(new SqlParameter("@Gender", (object)Gender ?? DBNull.Value));
                cmd.Parameters.Add(new SqlParameter("@City", (object)City ?? DBNull.Value));
                con.Open();
                return cmd.ExecuteNonQuery();
            }
        }

        // Custom Server-Side Paging using Stored Procedure
        public static List<Employee> GetEmployees(int pageIndex, int pageSize, out int totalRows)
        {
            List<Employee> listEmployees = new List<Employee>();
            string conStr = ConfigurationManager.ConnectionStrings["DBCon"].ConnectionString;
            using (SqlConnection con = new SqlConnection(conStr))
            {
                SqlCommand cmd = new SqlCommand("spGetEmployees_by_PageIndex_and_PageSize", con);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@PageIndex", pageIndex);
                cmd.Parameters.AddWithValue("@PageSize", pageSize);
                SqlParameter paramOut = new SqlParameter
                {
                    ParameterName = "@TotalRows",
                    Direction = ParameterDirection.Output,
                    SqlDbType = SqlDbType.Int
                };
                cmd.Parameters.Add(paramOut);
                con.Open();
                SqlDataReader rdr = cmd.ExecuteReader();
                while (rdr.Read())
                {
                    Employee employee = new Employee();
                    employee.EmployeeId = Convert.ToInt32(rdr["EmployeeId"]);
                    employee.Name = rdr["Name"] != DBNull.Value ? rdr["Name"].ToString() : "";
                    employee.Gender = rdr["Gender"] != DBNull.Value ? rdr["Gender"].ToString() : "";
                    employee.City = rdr["City"] != DBNull.Value ? rdr["City"].ToString() : "";
                    listEmployees.Add(employee);
                }
                rdr.Close();
                totalRows = (int)cmd.Parameters["@TotalRows"].Value;
            }
            return listEmployees;
        }
    }
}
