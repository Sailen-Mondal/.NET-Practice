using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using ViewModelDemo.Models;
using ViewModelDemo.ViewModels;

namespace ViewModelDemo.Data
{
    public static class DatabaseHelper
    {
        private static string GetConnectionString()
        {
            var setting = ConfigurationManager.ConnectionStrings["ViewModelDB"];
            return setting != null ? setting.ConnectionString : string.Empty;
        }

        // =====================================================================
        // User Authentication (Role-based: Admin vs User)
        // =====================================================================

        public static UserSession ValidateUser(string usernameOrEmail, string password)
        {
            string connStr = GetConnectionString();
            if (string.IsNullOrEmpty(connStr)) return null;

            try
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    conn.Open();
                    string sql = @"
                        SELECT UserId, Username, Email, FullName, Role
                        FROM dbo.Users
                        WHERE (Username = @Input OR Email = @Input)
                          AND PasswordHash = @Password";

                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@Input", usernameOrEmail.Trim());
                        cmd.Parameters.AddWithValue("@Password", password);

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                return new UserSession
                                {
                                    UserId = Convert.ToInt32(reader["UserId"]),
                                    Username = reader["Username"].ToString(),
                                    Email = reader["Email"].ToString(),
                                    FullName = reader["FullName"].ToString(),
                                    Role = reader["Role"].ToString()
                                };
                            }
                        }
                    }
                }
            }
            catch
            {
                // Fallback check for offline testing
                if (usernameOrEmail.Equals("admin", StringComparison.OrdinalIgnoreCase) && password == "Admin@123")
                {
                    return new UserSession { UserId = 1, Username = "admin", FullName = "System Administrator", Email = "admin@viewmodeldemo.com", Role = "Admin" };
                }
                if (usernameOrEmail.Equals("rahul", StringComparison.OrdinalIgnoreCase) && password == "User@123")
                {
                    return new UserSession { UserId = 2, Username = "rahul", FullName = "Rahul Sharma", Email = "rahul@example.com", Role = "User" };
                }
            }

            return null;
        }

        public static (bool Success, string ErrorMessage, UserSession Session) RegisterUser(RegisterViewModel model)
        {
            string connStr = GetConnectionString();
            if (string.IsNullOrEmpty(connStr))
            {
                return (false, "Database connection is not configured.", null);
            }

            try
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    conn.Open();

                    // Check if username or email already exists
                    string checkSql = "SELECT COUNT(1) FROM dbo.Users WHERE Username = @Username OR Email = @Email";
                    using (SqlCommand checkCmd = new SqlCommand(checkSql, conn))
                    {
                        checkCmd.Parameters.AddWithValue("@Username", model.Username.Trim());
                        checkCmd.Parameters.AddWithValue("@Email", model.Email.Trim());
                        int count = Convert.ToInt32(checkCmd.ExecuteScalar());
                        if (count > 0)
                        {
                            return (false, "A user with this username or email already exists.", null);
                        }
                    }

                    // Insert new user with 'User' role
                    string insertSql = @"
                        INSERT INTO dbo.Users (Username, Email, PasswordHash, FullName, Role, CreatedAt)
                        VALUES (@Username, @Email, @Password, @FullName, 'User', GETDATE());
                        SELECT SCOPE_IDENTITY();";

                    using (SqlCommand insertCmd = new SqlCommand(insertSql, conn))
                    {
                        insertCmd.Parameters.AddWithValue("@Username", model.Username.Trim());
                        insertCmd.Parameters.AddWithValue("@Email", model.Email.Trim().ToLowerInvariant());
                        insertCmd.Parameters.AddWithValue("@Password", model.Password);
                        insertCmd.Parameters.AddWithValue("@FullName", model.FullName.Trim());

                        int newId = Convert.ToInt32(insertCmd.ExecuteScalar());

                        UserSession session = new UserSession
                        {
                            UserId = newId,
                            Username = model.Username.Trim(),
                            Email = model.Email.Trim().ToLowerInvariant(),
                            FullName = model.FullName.Trim(),
                            Role = "User"
                        };

                        return (true, null, session);
                    }
                }
            }
            catch (Exception ex)
            {
                return (false, "Registration error: " + ex.Message, null);
            }
        }

        public static List<User> GetAllUsers()
        {
            List<User> list = new List<User>();
            string connStr = GetConnectionString();
            if (string.IsNullOrEmpty(connStr)) return list;

            try
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    conn.Open();
                    string sql = "SELECT UserId, Username, Email, FullName, Role, CreatedAt FROM dbo.Users ORDER BY UserId DESC";
                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            list.Add(new User
                            {
                                UserId = Convert.ToInt32(reader["UserId"]),
                                Username = reader["Username"].ToString(),
                                Email = reader["Email"].ToString(),
                                FullName = reader["FullName"].ToString(),
                                Role = reader["Role"].ToString(),
                                CreatedAt = Convert.ToDateTime(reader["CreatedAt"])
                            });
                        }
                    }
                }
            }
            catch
            {
                // Return fallback users
                list.Add(new User { UserId = 1, Username = "admin", FullName = "System Administrator", Email = "admin@viewmodeldemo.com", Role = "Admin", CreatedAt = DateTime.Now });
                list.Add(new User { UserId = 2, Username = "rahul", FullName = "Rahul Sharma", Email = "rahul@example.com", Role = "User", CreatedAt = DateTime.Now });
            }

            return list;
        }

        // =====================================================================
        // Admin Dashboard Metrics
        // =====================================================================

        public static AdminDashboardViewModel GetAdminDashboardData()
        {
            AdminDashboardViewModel vm = new AdminDashboardViewModel();
            string connStr = GetConnectionString();
            if (string.IsNullOrEmpty(connStr)) return vm;

            try
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    conn.Open();

                    // Aggregates for Employees
                    string empStatsSql = @"
                        SELECT COUNT(1) AS TotalCount,
                               ISNULL(SUM(Salary), 0) AS TotalSalary,
                               ISNULL(AVG(Salary), 0) AS AvgSalary
                        FROM dbo.Employees";

                    using (SqlCommand cmd = new SqlCommand(empStatsSql, conn))
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            vm.TotalEmployees = Convert.ToInt32(reader["TotalCount"]);
                            vm.TotalPayroll = Convert.ToDecimal(reader["TotalSalary"]);
                            vm.AverageSalary = Convert.ToDecimal(reader["AvgSalary"]);
                        }
                    }

                    // Total Users
                    string userCountSql = "SELECT COUNT(1) FROM dbo.Users";
                    using (SqlCommand cmd = new SqlCommand(userCountSql, conn))
                    {
                        vm.TotalUsers = Convert.ToInt32(cmd.ExecuteScalar());
                    }

                    // Department Breakdown
                    string deptSql = "SELECT Department, COUNT(1) AS Cnt FROM dbo.Employees GROUP BY Department";
                    using (SqlCommand cmd = new SqlCommand(deptSql, conn))
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            vm.DepartmentCounts[reader["Department"].ToString()] = Convert.ToInt32(reader["Cnt"]);
                        }
                    }

                    // Recent Employees (Top 5)
                    string recentEmpSql = @"
                        SELECT TOP 5 e.EmployeeId, e.Name, e.Gender, e.Department, e.Salary, e.AddressId,
                                     a.City, a.State, a.Country
                        FROM dbo.Employees e
                        INNER JOIN dbo.Addresses a ON e.AddressId = a.AddressId
                        ORDER BY e.EmployeeId DESC";

                    using (SqlCommand cmd = new SqlCommand(recentEmpSql, conn))
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            vm.RecentEmployees.Add(new EmployeeListItemViewModel
                            {
                                EmployeeId = Convert.ToInt32(reader["EmployeeId"]),
                                Name = reader["Name"].ToString(),
                                Gender = reader["Gender"].ToString(),
                                Department = reader["Department"].ToString(),
                                Salary = Convert.ToDecimal(reader["Salary"]),
                                AddressId = Convert.ToInt32(reader["AddressId"]),
                                City = reader["City"].ToString(),
                                State = reader["State"].ToString(),
                                Country = reader["Country"].ToString()
                            });
                        }
                    }

                    // Recent Users (Top 5)
                    string recentUserSql = "SELECT TOP 5 UserId, Username, Email, FullName, Role, CreatedAt FROM dbo.Users ORDER BY UserId DESC";
                    using (SqlCommand cmd = new SqlCommand(recentUserSql, conn))
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            vm.RecentUsers.Add(new User
                            {
                                UserId = Convert.ToInt32(reader["UserId"]),
                                Username = reader["Username"].ToString(),
                                Email = reader["Email"].ToString(),
                                FullName = reader["FullName"].ToString(),
                                Role = reader["Role"].ToString(),
                                CreatedAt = Convert.ToDateTime(reader["CreatedAt"])
                            });
                        }
                    }
                }
            }
            catch
            {
                // Fallback demo metrics if SQL is offline
                vm.TotalEmployees = 4;
                vm.TotalUsers = 3;
                vm.TotalPayroll = 276000m;
                vm.AverageSalary = 69000m;
                vm.DepartmentCounts["IT"] = 1;
                vm.DepartmentCounts["HR"] = 1;
                vm.DepartmentCounts["Engineering"] = 1;
                vm.DepartmentCounts["Finance"] = 1;
            }

            return vm;
        }

        // =====================================================================
        // Employee CRUD Operations (Multi-table ViewModels & Transactions)
        // =====================================================================

        public static List<EmployeeListItemViewModel> GetAllEmployees(string searchTerm = null)
        {
            List<EmployeeListItemViewModel> list = new List<EmployeeListItemViewModel>();
            string connStr = GetConnectionString();
            if (string.IsNullOrEmpty(connStr)) return list;

            try
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    conn.Open();
                    string sql = @"
                        SELECT e.EmployeeId, e.Name, e.Gender, e.Department, e.Salary, e.AddressId,
                               a.City, a.State, a.Country
                        FROM dbo.Employees e
                        INNER JOIN dbo.Addresses a ON e.AddressId = a.AddressId";

                    if (!string.IsNullOrWhiteSpace(searchTerm))
                    {
                        sql += " WHERE e.Name LIKE @Search OR e.Department LIKE @Search OR a.City LIKE @Search";
                    }

                    sql += " ORDER BY e.EmployeeId ASC";

                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        if (!string.IsNullOrWhiteSpace(searchTerm))
                        {
                            cmd.Parameters.AddWithValue("@Search", "%" + searchTerm.Trim() + "%");
                        }

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                list.Add(new EmployeeListItemViewModel
                                {
                                    EmployeeId = Convert.ToInt32(reader["EmployeeId"]),
                                    Name = reader["Name"].ToString(),
                                    Gender = reader["Gender"].ToString(),
                                    Department = reader["Department"].ToString(),
                                    Salary = Convert.ToDecimal(reader["Salary"]),
                                    AddressId = Convert.ToInt32(reader["AddressId"]),
                                    City = reader["City"].ToString(),
                                    State = reader["State"].ToString(),
                                    Country = reader["Country"].ToString()
                                });
                            }
                        }
                    }
                }
            }
            catch
            {
                // Fallback data
                list.Add(new EmployeeListItemViewModel { EmployeeId = 101, Name = "Dillip Mohapatra", Gender = "Male", Department = "IT", Salary = 65000, AddressId = 1001, City = "Bhubaneswar", State = "Odisha", Country = "India" });
                list.Add(new EmployeeListItemViewModel { EmployeeId = 102, Name = "Priya Patel", Gender = "Female", Department = "HR", Salary = 58000, AddressId = 1002, City = "Kolkata", State = "West Bengal", Country = "India" });
                list.Add(new EmployeeListItemViewModel { EmployeeId = 103, Name = "Rahul Sharma", Gender = "Male", Department = "Engineering", Salary = 82000, AddressId = 1003, City = "Bengaluru", State = "Karnataka", Country = "India" });
                list.Add(new EmployeeListItemViewModel { EmployeeId = 104, Name = "Sneha Roy", Gender = "Female", Department = "Finance", Salary = 71000, AddressId = 1004, City = "New Delhi", State = "Delhi", Country = "India" });
            }

            return list;
        }

        public static EmployeeFormViewModel GetEmployeeForEdit(int employeeId)
        {
            string connStr = GetConnectionString();
            if (string.IsNullOrEmpty(connStr)) return null;

            try
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    conn.Open();
                    string sql = @"
                        SELECT e.EmployeeId, e.Name, e.Gender, e.Department, e.Salary, e.AddressId,
                               a.Country, a.State, a.City, a.Pin
                        FROM dbo.Employees e
                        INNER JOIN dbo.Addresses a ON e.AddressId = a.AddressId
                        WHERE e.EmployeeId = @EmployeeId";

                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@EmployeeId", employeeId);
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                return new EmployeeFormViewModel
                                {
                                    EmployeeId = Convert.ToInt32(reader["EmployeeId"]),
                                    Name = reader["Name"].ToString(),
                                    Gender = reader["Gender"].ToString(),
                                    Department = reader["Department"].ToString(),
                                    Salary = Convert.ToDecimal(reader["Salary"]),
                                    AddressId = Convert.ToInt32(reader["AddressId"]),
                                    Country = reader["Country"].ToString(),
                                    State = reader["State"].ToString(),
                                    City = reader["City"].ToString(),
                                    Pin = reader["Pin"].ToString()
                                };
                            }
                        }
                    }
                }
            }
            catch
            {
                // Fallback for ID 101
                if (employeeId == 101)
                {
                    return new EmployeeFormViewModel
                    {
                        EmployeeId = 101,
                        Name = "Dillip Mohapatra",
                        Gender = "Male",
                        Department = "IT",
                        Salary = 65000,
                        AddressId = 1001,
                        Country = "India",
                        State = "Odisha",
                        City = "Bhubaneswar",
                        Pin = "751024"
                    };
                }
            }

            return null;
        }

        public static bool SaveEmployee(EmployeeFormViewModel model)
        {
            string connStr = GetConnectionString();
            if (string.IsNullOrEmpty(connStr)) return false;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                using (SqlTransaction trans = conn.BeginTransaction())
                {
                    try
                    {
                        if (model.EmployeeId == 0)
                        {
                            // CREATE: Insert Address first
                            string insertAddrSql = @"
                                INSERT INTO dbo.Addresses (Country, State, City, Pin)
                                VALUES (@Country, @State, @City, @Pin);
                                SELECT SCOPE_IDENTITY();";

                            int newAddressId;
                            using (SqlCommand cmd = new SqlCommand(insertAddrSql, conn, trans))
                            {
                                cmd.Parameters.AddWithValue("@Country", model.Country);
                                cmd.Parameters.AddWithValue("@State", model.State);
                                cmd.Parameters.AddWithValue("@City", model.City);
                                cmd.Parameters.AddWithValue("@Pin", model.Pin);
                                newAddressId = Convert.ToInt32(cmd.ExecuteScalar());
                            }

                            // Insert Employee referencing new AddressId
                            string insertEmpSql = @"
                                INSERT INTO dbo.Employees (Name, Gender, Department, Salary, AddressId)
                                VALUES (@Name, @Gender, @Department, @Salary, @AddressId);
                                SELECT SCOPE_IDENTITY();";

                            using (SqlCommand cmd = new SqlCommand(insertEmpSql, conn, trans))
                            {
                                cmd.Parameters.AddWithValue("@Name", model.Name);
                                cmd.Parameters.AddWithValue("@Gender", model.Gender);
                                cmd.Parameters.AddWithValue("@Department", model.Department);
                                cmd.Parameters.AddWithValue("@Salary", model.Salary);
                                cmd.Parameters.AddWithValue("@AddressId", newAddressId);
                                model.EmployeeId = Convert.ToInt32(cmd.ExecuteScalar());
                            }
                        }
                        else
                        {
                            // UPDATE: Update Address
                            string updateAddrSql = @"
                                UPDATE dbo.Addresses
                                SET Country = @Country, State = @State, City = @City, Pin = @Pin
                                WHERE AddressId = @AddressId";

                            using (SqlCommand cmd = new SqlCommand(updateAddrSql, conn, trans))
                            {
                                cmd.Parameters.AddWithValue("@Country", model.Country);
                                cmd.Parameters.AddWithValue("@State", model.State);
                                cmd.Parameters.AddWithValue("@City", model.City);
                                cmd.Parameters.AddWithValue("@Pin", model.Pin);
                                cmd.Parameters.AddWithValue("@AddressId", model.AddressId);
                                cmd.ExecuteNonQuery();
                            }

                            // Update Employee
                            string updateEmpSql = @"
                                UPDATE dbo.Employees
                                SET Name = @Name, Gender = @Gender, Department = @Department, Salary = @Salary
                                WHERE EmployeeId = @EmployeeId";

                            using (SqlCommand cmd = new SqlCommand(updateEmpSql, conn, trans))
                            {
                                cmd.Parameters.AddWithValue("@Name", model.Name);
                                cmd.Parameters.AddWithValue("@Gender", model.Gender);
                                cmd.Parameters.AddWithValue("@Department", model.Department);
                                cmd.Parameters.AddWithValue("@Salary", model.Salary);
                                cmd.Parameters.AddWithValue("@EmployeeId", model.EmployeeId);
                                cmd.ExecuteNonQuery();
                            }
                        }

                        trans.Commit();
                        return true;
                    }
                    catch
                    {
                        trans.Rollback();
                        throw;
                    }
                }
            }
        }

        public static bool DeleteEmployee(int employeeId)
        {
            string connStr = GetConnectionString();
            if (string.IsNullOrEmpty(connStr)) return false;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                using (SqlTransaction trans = conn.BeginTransaction())
                {
                    try
                    {
                        // 1. Find AddressId
                        int addressId = 0;
                        string findSql = "SELECT AddressId FROM dbo.Employees WHERE EmployeeId = @EmployeeId";
                        using (SqlCommand cmd = new SqlCommand(findSql, conn, trans))
                        {
                            cmd.Parameters.AddWithValue("@EmployeeId", employeeId);
                            object result = cmd.ExecuteScalar();
                            if (result != null && result != DBNull.Value)
                            {
                                addressId = Convert.ToInt32(result);
                            }
                        }

                        // 2. Delete Employee
                        string delEmpSql = "DELETE FROM dbo.Employees WHERE EmployeeId = @EmployeeId";
                        using (SqlCommand cmd = new SqlCommand(delEmpSql, conn, trans))
                        {
                            cmd.Parameters.AddWithValue("@EmployeeId", employeeId);
                            cmd.ExecuteNonQuery();
                        }

                        // 3. Delete Address
                        if (addressId > 0)
                        {
                            string delAddrSql = "DELETE FROM dbo.Addresses WHERE AddressId = @AddressId";
                            using (SqlCommand cmd = new SqlCommand(delAddrSql, conn, trans))
                            {
                                cmd.Parameters.AddWithValue("@AddressId", addressId);
                                cmd.ExecuteNonQuery();
                            }
                        }

                        trans.Commit();
                        return true;
                    }
                    catch
                    {
                        trans.Rollback();
                        throw;
                    }
                }
            }
        }

        // =====================================================================
        // Legacy Reference Methods (Maintained for Slide Compatibility)
        // =====================================================================

        public static (Employee employee, Address address) GetEmployeeWithAddress(int employeeId = 101)
        {
            string connStr = GetConnectionString();
            if (!string.IsNullOrEmpty(connStr))
            {
                try
                {
                    using (SqlConnection conn = new SqlConnection(connStr))
                    {
                        conn.Open();
                        string sql = @"
                            SELECT e.EmployeeId, e.Name, e.Gender, e.Department, e.Salary, e.AddressId,
                                   a.Country, a.State, a.City, a.Pin
                            FROM dbo.Employees e
                            INNER JOIN dbo.Addresses a ON e.AddressId = a.AddressId
                            WHERE e.EmployeeId = @EmployeeId";

                        using (SqlCommand cmd = new SqlCommand(sql, conn))
                        {
                            cmd.Parameters.AddWithValue("@EmployeeId", employeeId);
                            using (SqlDataReader reader = cmd.ExecuteReader())
                            {
                                if (reader.Read())
                                {
                                    Employee emp = new Employee
                                    {
                                        EmployeeId = Convert.ToInt32(reader["EmployeeId"]),
                                        Name = reader["Name"].ToString(),
                                        Gender = reader["Gender"].ToString(),
                                        Department = reader["Department"].ToString(),
                                        Salary = Convert.ToDecimal(reader["Salary"]),
                                        AddressId = Convert.ToInt32(reader["AddressId"])
                                    };

                                    Address addr = new Address
                                    {
                                        AddressId = Convert.ToInt32(reader["AddressId"]),
                                        Country = reader["Country"].ToString(),
                                        State = reader["State"].ToString(),
                                        City = reader["City"].ToString(),
                                        Pin = reader["Pin"].ToString()
                                    };

                                    return (emp, addr);
                                }
                            }
                        }
                    }
                }
                catch
                {
                    // Fall back
                }
            }

            return (
                new Employee { EmployeeId = 101, Name = "Dillip Mohapatra", Gender = "Male", Department = "IT", Salary = 65000, AddressId = 1001 },
                new Address { AddressId = 1001, City = "Bhubaneswar", State = "Odisha", Country = "India", Pin = "751024" }
            );
        }

        public static List<Student> GetStudents()
        {
            string connStr = GetConnectionString();
            if (!string.IsNullOrEmpty(connStr))
            {
                try
                {
                    using (SqlConnection conn = new SqlConnection(connStr))
                    {
                        conn.Open();
                        string sql = "SELECT RollNo, Name, Marks FROM dbo.Students ORDER BY RollNo ASC";

                        using (SqlCommand cmd = new SqlCommand(sql, conn))
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            List<Student> list = new List<Student>();
                            while (reader.Read())
                            {
                                list.Add(new Student
                                {
                                    RollNo = Convert.ToInt32(reader["RollNo"]),
                                    Name = reader["Name"].ToString(),
                                    Marks = Convert.ToDouble(reader["Marks"])
                                });
                            }

                            if (list.Count > 0)
                            {
                                return list;
                            }
                        }
                    }
                }
                catch
                {
                    // Fall back
                }
            }

            return new List<Student>
            {
                new Student { RollNo = 1, Name = "Ankur", Marks = 34 },
                new Student { RollNo = 2, Name = "Dhrumit", Marks = 79 },
                new Student { RollNo = 3, Name = "Mannan", Marks = 67 },
                new Student { RollNo = 4, Name = "Priya Sharma", Marks = 88.5 },
                new Student { RollNo = 5, Name = "Amit", Marks = 31 }
            };
        }
    }
}
