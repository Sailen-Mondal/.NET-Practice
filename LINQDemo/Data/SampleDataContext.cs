using System;
using System.Configuration;
using System.Data;
using System.Data.Linq;
using System.Data.Linq.Mapping;
using System.Reflection;
using System.Web.Configuration;
using LINQDemo.Models;

namespace LINQDemo.Data
{
    /// <summary>
    /// LINQ to SQL DataContext managing entity mapping and stored procedure execution.
    /// Derives directly from System.Data.Linq.DataContext.
    /// </summary>
    public class SampleDataContext : DataContext
    {
        // Default connection string fallback
        private const string DefaultConnectionString =
            "Data Source=.;Initial Catalog=SampleDB;Integrated Security=True;TrustServerCertificate=True";

        /// <summary>
        /// Reads connection string from Web.config or falls back to default.
        /// </summary>
        public static string ConnectionString
        {
            get
            {
                ConnectionStringSettings setting = WebConfigurationManager.ConnectionStrings["SampleDB"];
                if (setting != null && !string.IsNullOrEmpty(setting.ConnectionString))
                {
                    return setting.ConnectionString;
                }
                return DefaultConnectionString;
            }
        }

        public SampleDataContext() : base(ConnectionString)
        {
        }

        public SampleDataContext(string connection) : base(connection)
        {
        }

        public SampleDataContext(IDbConnection connection) : base(connection)
        {
        }

        // Strongly-typed table accessors
        public Table<Employee> Employees => GetTable<Employee>();

        public Table<Department> Departments => GetTable<Department>();

        #region Stored Procedures Mapping

        /// <summary>
        /// Maps to the GetEmployees stored procedure.
        /// Returns an ISingleResult of Employee entities.
        /// </summary>
        [Function(Name = "GetEmployees")]
        public ISingleResult<Employee> GetEmployees()
        {
            IExecuteResult result = ExecuteMethodCall(this, (MethodInfo)MethodInfo.GetCurrentMethod());
            return (ISingleResult<Employee>)result.ReturnValue;
        }

        /// <summary>
        /// Maps to the InsertEmployee stored procedure.
        /// </summary>
        [Function(Name = "InsertEmployee")]
        public int InsertEmployee(
            [Parameter(Name = "FirstName", DbType = "NVarChar(50)")] string firstName,
            [Parameter(Name = "LastName", DbType = "NVarChar(50)")] string lastName,
            [Parameter(Name = "Gender", DbType = "NVarChar(50)")] string gender,
            [Parameter(Name = "Salary", DbType = "Int")] int? salary,
            [Parameter(Name = "DepartmentId", DbType = "Int")] int? departmentId)
        {
            IExecuteResult result = ExecuteMethodCall(
                this,
                (MethodInfo)MethodInfo.GetCurrentMethod(),
                firstName,
                lastName,
                gender,
                salary,
                departmentId);
            return (int)result.ReturnValue;
        }

        /// <summary>
        /// Maps to the UpdateEmployee stored procedure.
        /// </summary>
        [Function(Name = "UpdateEmployee")]
        public int UpdateEmployee(
            [Parameter(Name = "ID", DbType = "Int")] int id,
            [Parameter(Name = "FirstName", DbType = "NVarChar(50)")] string firstName,
            [Parameter(Name = "LastName", DbType = "NVarChar(50)")] string lastName,
            [Parameter(Name = "Gender", DbType = "NVarChar(50)")] string gender,
            [Parameter(Name = "Salary", DbType = "Int")] int? salary,
            [Parameter(Name = "DepartmentId", DbType = "Int")] int? departmentId)
        {
            IExecuteResult result = ExecuteMethodCall(
                this,
                (MethodInfo)MethodInfo.GetCurrentMethod(),
                id,
                firstName,
                lastName,
                gender,
                salary,
                departmentId);
            return (int)result.ReturnValue;
        }

        /// <summary>
        /// Maps to the DeleteEmployee stored procedure.
        /// </summary>
        [Function(Name = "DeleteEmployee")]
        public int DeleteEmployee([Parameter(Name = "ID", DbType = "Int")] int id)
        {
            IExecuteResult result = ExecuteMethodCall(
                this,
                (MethodInfo)MethodInfo.GetCurrentMethod(),
                id);
            return (int)result.ReturnValue;
        }

        /// <summary>
        /// Maps to the GetEmployeesByDepartment stored procedure with an OUTPUT parameter.
        /// </summary>
        /// <param name="departmentId">Input department ID.</param>
        /// <param name="departmentName">Output department name populated by the stored procedure.</param>
        [Function(Name = "GetEmployeesByDepartment")]
        public ISingleResult<Employee> GetEmployeesByDepartment(
            [Parameter(Name = "DepartmentId", DbType = "Int")] int? departmentId,
            [Parameter(Name = "DepartmentName", DbType = "NVarChar(50)")] ref string departmentName)
        {
            IExecuteResult result = ExecuteMethodCall(
                this,
                (MethodInfo)MethodInfo.GetCurrentMethod(),
                departmentId,
                departmentName);

            // Extract the output parameter value returned from SQL Server
            departmentName = (string)result.GetParameterValue(1);
            return (ISingleResult<Employee>)result.ReturnValue;
        }

        #endregion
    }
}
