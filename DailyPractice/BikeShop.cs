using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;

namespace ThirdADO
{
    /// <summary>
    /// Repository class implementing the Data Access Layer (DAL) for Bikeshop operations.
    /// Handles full CRUD (Create, Read, Update, Delete) database operations using ADO.NET.
    /// </summary>
    internal class BikeshopRepo
    {
        /// <summary>
        /// Database connection string read dynamically from App.config ('DBConn').
        /// </summary>
        public string _conStr = ConfigurationManager.ConnectionStrings["DBConn"].ConnectionString;

        /// <summary>
        /// Backward-compatible alias for the connection string field.
        /// </summary>
        public string _constr => _conStr;

        /// <summary>
        /// CREATE: Inserts a new Bikeshop record into the 'bikeshop' table and returns its newly generated Identity ID.
        /// Demonstrates parameterized SQL commands to guard against SQL Injection vulnerabilities.
        /// </summary>
        /// <param name="bikeshop">The Bikeshop model containing the bike details to insert.</param>
        /// <returns>The generated primary key ID of the newly inserted bike.</returns>
        public int AddBikeshop(Bikeshop bikeshop)
        {
            // 'using' statement guarantees deterministic disposal of the connection,
            // returning it to the ADO.NET connection pool even if an error occurs.
            using (SqlConnection con = new SqlConnection(_conStr))
            {
                con.Open();

                // Parameterized INSERT query using @name and @price as placeholders.
                // SCOPE_IDENTITY() retrieves the latest IDENTITY value generated within the current execution scope.
                string query = "INSERT INTO bikeshop (bike_name, price) VALUES (@name, @price); SELECT SCOPE_IDENTITY();";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    // Map parameters to protect against SQL Injection and ensure correct data typing
                    cmd.Parameters.AddWithValue("@name", bikeshop.bike_name ?? bikeshop.Name);
                    cmd.Parameters.AddWithValue("@price", bikeshop.price);

                    // ExecuteScalar executes the query and returns the first column of the first row (the new ID)
                    object result = cmd.ExecuteScalar();
                    int newId = Convert.ToInt32(result);

                    bikeshop.Id = newId;
                    return newId;
                }
            }
        }

        /// <summary>
        /// READ ALL: Retrieves all Bikeshop records from the database table.
        /// Uses SqlDataReader for high-performance, forward-only streaming of records.
        /// </summary>
        /// <returns>A List of <see cref="Bikeshop"/> objects mapped from database rows.</returns>
        public List<Bikeshop> GetAllBikeshops()
        {
            List<Bikeshop> bikeshops = new List<Bikeshop>();

            using (SqlConnection con = new SqlConnection(_conStr))
            {
                con.Open();

                string query = "SELECT Id, bike_name, price FROM bikeshop ORDER BY Id ASC";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            Bikeshop bikeshop = new Bikeshop
                            {
                                Id = Convert.ToInt32(reader["Id"]),
                                Name = reader["bike_name"].ToString(),
                                price = Convert.ToDecimal(reader["price"])
                            };

                            bikeshops.Add(bikeshop);
                        }
                    }
                }
            }

            return bikeshops;
        }

        /// <summary>
        /// READ ONE: Retrieves a single Bikeshop record by its unique Primary Key (Id).
        /// </summary>
        /// <param name="id">The primary key ID of the bike to find.</param>
        /// <returns>The matching <see cref="Bikeshop"/> instance, or null if no record exists with that ID.</returns>
        public Bikeshop GetBikeshopById(int id)
        {
            using (SqlConnection con = new SqlConnection(_conStr))
            {
                con.Open();

                string query = "SELECT Id, bike_name, price FROM bikeshop WHERE Id = @id";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@id", id);

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            return new Bikeshop
                            {
                                Id = Convert.ToInt32(reader["Id"]),
                                Name = reader["bike_name"].ToString(),
                                price = Convert.ToDecimal(reader["price"])
                            };
                        }
                    }
                }
            }

            return null; // Return null if record was not found
        }

        /// <summary>
        /// UPDATE: Modifies the details (name and price) of an existing bike record identified by its ID.
        /// </summary>
        /// <param name="bikeshop">The Bikeshop model containing updated values and the target ID.</param>
        /// <returns>True if the record was found and updated; false if no matching record was found.</returns>
        public bool UpdateBikeshop(Bikeshop bikeshop)
        {
            using (SqlConnection con = new SqlConnection(_conStr))
            {
                con.Open();

                string query = "UPDATE bikeshop SET bike_name = @name, price = @price WHERE Id = @id";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@id", bikeshop.Id);
                    cmd.Parameters.AddWithValue("@name", bikeshop.bike_name ?? bikeshop.Name);
                    cmd.Parameters.AddWithValue("@price", bikeshop.price);

                    // ExecuteNonQuery returns the number of rows affected by the UPDATE statement
                    int rowsAffected = cmd.ExecuteNonQuery();
                    return rowsAffected > 0;
                }
            }
        }

        /// <summary>
        /// DELETE: Deletes an existing Bikeshop record identified by its primary key (Id).
        /// </summary>
        /// <param name="id">The primary key ID of the bike to delete.</param>
        /// <returns>True if the record was successfully deleted; false if no record matched the ID.</returns>
        public bool DeleteBikeshop(int id)
        {
            using (SqlConnection con = new SqlConnection(_conStr))
            {
                con.Open();

                string query = "DELETE FROM bikeshop WHERE Id = @id";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@id", id);

                    // ExecuteNonQuery returns the number of rows affected by the DELETE statement
                    int rowsAffected = cmd.ExecuteNonQuery();
                    return rowsAffected > 0;
                }
            }
        }
    }
}
