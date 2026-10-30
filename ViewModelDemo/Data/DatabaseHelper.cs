using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
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
        // User Authentication (Role-based: Admin vs User via Stored Procedures)
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
                    using (SqlCommand cmd = new SqlCommand("dbo.sp_ValidateUser", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
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
                    using (SqlCommand cmd = new SqlCommand("dbo.sp_RegisterUser", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.AddWithValue("@Username", model.Username.Trim());
                        cmd.Parameters.AddWithValue("@Email", model.Email.Trim().ToLowerInvariant());
                        cmd.Parameters.AddWithValue("@Password", model.Password);
                        cmd.Parameters.AddWithValue("@FullName", model.FullName.Trim());

                        SqlParameter outId = new SqlParameter("@NewUserId", SqlDbType.Int) { Direction = ParameterDirection.Output };
                        SqlParameter outErr = new SqlParameter("@ErrorMessage", SqlDbType.NVarChar, 255) { Direction = ParameterDirection.Output };
                        cmd.Parameters.Add(outId);
                        cmd.Parameters.Add(outErr);

                        cmd.ExecuteNonQuery();

                        string errMsg = outErr.Value != DBNull.Value ? outErr.Value?.ToString() : null;
                        if (!string.IsNullOrEmpty(errMsg))
                        {
                            return (false, errMsg, null);
                        }

                        int newId = Convert.ToInt32(outId.Value);
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
                    using (SqlCommand cmd = new SqlCommand("dbo.sp_GetAllUsers", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
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
        // Admin Dashboard Metrics via Stored Procedure
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
                    using (SqlCommand cmd = new SqlCommand("dbo.sp_GetAdminDashboardStats", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            // Result 1: Aggregates
                            if (reader.Read())
                            {
                                vm.TotalEmployees = Convert.ToInt32(reader["TotalEmployees"]);
                                vm.TotalPayroll = Convert.ToDecimal(reader["TotalPayroll"]);
                                vm.AverageSalary = Convert.ToDecimal(reader["AvgSalary"]);
                                vm.TotalUsers = Convert.ToInt32(reader["TotalUsers"]);
                            }

                            // Result 2: Department breakdown
                            if (reader.NextResult())
                            {
                                while (reader.Read())
                                {
                                    vm.DepartmentCounts[reader["Department"].ToString()] = Convert.ToInt32(reader["Cnt"]);
                                }
                            }

                            // Result 3: Recent Employees (Top 5)
                            if (reader.NextResult())
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

                            // Result 4: Recent Users (Top 5)
                            if (reader.NextResult())
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
        // Employee CRUD Operations via Stored Procedures
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
                    using (SqlCommand cmd = new SqlCommand("dbo.sp_GetAllEmployees", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        if (!string.IsNullOrWhiteSpace(searchTerm))
                        {
                            cmd.Parameters.AddWithValue("@Search", searchTerm.Trim());
                        }
                        else
                        {
                            cmd.Parameters.AddWithValue("@Search", DBNull.Value);
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
                    using (SqlCommand cmd = new SqlCommand("dbo.sp_GetEmployeeWithAddress", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
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
                using (SqlCommand cmd = new SqlCommand("dbo.sp_SaveEmployee", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    SqlParameter empParam = new SqlParameter("@EmployeeId", SqlDbType.Int)
                    {
                        Direction = ParameterDirection.InputOutput,
                        Value = model.EmployeeId
                    };
                    SqlParameter addrParam = new SqlParameter("@AddressId", SqlDbType.Int)
                    {
                        Direction = ParameterDirection.InputOutput,
                        Value = model.AddressId
                    };

                    cmd.Parameters.Add(empParam);
                    cmd.Parameters.Add(addrParam);
                    cmd.Parameters.AddWithValue("@Name", model.Name);
                    cmd.Parameters.AddWithValue("@Gender", model.Gender);
                    cmd.Parameters.AddWithValue("@Department", model.Department);
                    cmd.Parameters.AddWithValue("@Salary", model.Salary);
                    cmd.Parameters.AddWithValue("@Country", model.Country ?? "India");
                    cmd.Parameters.AddWithValue("@State", model.State ?? "");
                    cmd.Parameters.AddWithValue("@City", model.City ?? "");
                    cmd.Parameters.AddWithValue("@Pin", model.Pin ?? "");

                    cmd.ExecuteNonQuery();

                    model.EmployeeId = Convert.ToInt32(empParam.Value);
                    model.AddressId = Convert.ToInt32(addrParam.Value);
                    return true;
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
                using (SqlCommand cmd = new SqlCommand("dbo.sp_DeleteEmployee", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@EmployeeId", employeeId);
                    cmd.ExecuteNonQuery();
                    return true;
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
                        using (SqlCommand cmd = new SqlCommand("dbo.sp_GetEmployeeWithAddress", conn))
                        {
                            cmd.CommandType = CommandType.StoredProcedure;
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
                        using (SqlCommand cmd = new SqlCommand("dbo.sp_GetStudents", conn))
                        {
                            cmd.CommandType = CommandType.StoredProcedure;
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
