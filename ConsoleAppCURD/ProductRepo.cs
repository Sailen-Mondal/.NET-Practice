using Microsoft.Data.SqlClient;
using System.Data;

namespace ConsoleAppCURD
{
    public class ProductRepo
    {
        private readonly string _connectionString;

        public ProductRepo(string connectionString)
        {
            _connectionString = connectionString;
        }

        // CREATE: Insert an employee
        public int Insert(Employee employee)
        {
            using SqlConnection connection =
                new SqlConnection(_connectionString);

            using SqlCommand command =
                new SqlCommand("dbo.usp_Employee_Insert", connection);

            command.CommandType = CommandType.StoredProcedure;

            AddEmployeeParameters(command, employee);

            connection.Open();

            return Convert.ToInt32(command.ExecuteScalar());
        }

        // READ: Fetch all employees
        public List<Employee> GetAll()
        {
            List<Employee> employees = new List<Employee>();

            using SqlConnection connection =
                new SqlConnection(_connectionString);

            using SqlCommand command =
                new SqlCommand("dbo.usp_Employee_GetAll", connection);

            command.CommandType = CommandType.StoredProcedure;

            connection.Open();

            using SqlDataReader reader = command.ExecuteReader();

            while (reader.Read())
            {
                employees.Add(MapEmployee(reader));
            }

            return employees;
        }

        // READ: Fetch one employee by ID
        public Employee? GetById(int id)
        {
            using SqlConnection connection =
                new SqlConnection(_connectionString);

            using SqlCommand command =
                new SqlCommand("dbo.usp_Employee_GetById", connection);

            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.Add("@ID", SqlDbType.Int).Value = id;

            connection.Open();

            using SqlDataReader reader = command.ExecuteReader();

            if (reader.Read())
            {
                return MapEmployee(reader);
            }

            return null;
        }

        // UPDATE: Modify an employee
        public int Update(Employee employee)
        {
            using SqlConnection connection =
                new SqlConnection(_connectionString);

            using SqlCommand command =
                new SqlCommand("dbo.usp_Employee_Update", connection);

            command.CommandType = CommandType.StoredProcedure;

            command.Parameters.Add("@ID", SqlDbType.Int)
                .Value = employee.ID;

            AddEmployeeParameters(command, employee);

            connection.Open();

            return Convert.ToInt32(command.ExecuteScalar());
        }

        // DELETE: Remove an employee
        public int Delete(int id)
        {
            using SqlConnection connection =
                new SqlConnection(_connectionString);

            using SqlCommand command =
                new SqlCommand("dbo.usp_Employee_Delete", connection);

            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.Add("@ID", SqlDbType.Int).Value = id;

            connection.Open();

            return Convert.ToInt32(command.ExecuteScalar());
        }

        // Add the common employee parameters
        private static void AddEmployeeParameters(
            SqlCommand command, Employee employee)
        {
            command.Parameters.Add("@LastName", SqlDbType.NVarChar, 100)
                .Value = employee.LastName;

            command.Parameters.Add("@FirstName", SqlDbType.NVarChar, 100)
                .Value = employee.FirstName;

            command.Parameters.Add("@Age", SqlDbType.Int)
                .Value = employee.Age;

            command.Parameters.Add("@City", SqlDbType.NVarChar, 100)
                .Value = employee.City;

            command.Parameters.Add("@DateOfJoining", SqlDbType.Date)
                .Value = employee.DateOfJoining;

            SqlParameter salaryParameter =
                command.Parameters.Add("@Salary", SqlDbType.Decimal);

            salaryParameter.Precision = 10;
            salaryParameter.Scale = 2;
            salaryParameter.Value = employee.Salary;
        }

        // Convert a database row into an Employee object
        private static Employee MapEmployee(SqlDataReader reader)
        {
            int idOrdinal = reader.GetOrdinal("ID");
            int lastNameOrdinal = reader.GetOrdinal("LastName");
            int firstNameOrdinal = reader.GetOrdinal("FirstName");
            int ageOrdinal = reader.GetOrdinal("Age");
            int cityOrdinal = reader.GetOrdinal("City");
            int dateOfJoiningOrdinal = reader.GetOrdinal("DateOfJoining");
            int salaryOrdinal = reader.GetOrdinal("Salary");

            return new Employee
            {
                ID = reader.GetInt32(idOrdinal),
                LastName = reader.IsDBNull(lastNameOrdinal)
                    ? string.Empty
                    : reader.GetString(lastNameOrdinal),
                FirstName = reader.IsDBNull(firstNameOrdinal)
                    ? string.Empty
                    : reader.GetString(firstNameOrdinal),
                Age = reader.IsDBNull(ageOrdinal)
                    ? 0
                    : reader.GetInt32(ageOrdinal),
                City = reader.IsDBNull(cityOrdinal)
                    ? string.Empty
                    : reader.GetString(cityOrdinal),
                DateOfJoining = reader.IsDBNull(dateOfJoiningOrdinal)
                    ? DateTime.MinValue
                    : reader.GetDateTime(dateOfJoiningOrdinal),
                Salary = reader.IsDBNull(salaryOrdinal)
                    ? 0m
                    : reader.GetDecimal(salaryOrdinal)
            };
        }
    }
}
