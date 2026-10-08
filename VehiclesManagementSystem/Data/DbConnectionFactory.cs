using Microsoft.Data.SqlClient;

namespace VehiclesManagementSystem.Data;

/// <summary>
/// Factory that produces configured SqlConnection instances.
/// Centralizes connection string management and isolates
/// connection creation for testability.
/// </summary>
public class DbConnectionFactory
{
    private readonly string _connectionString;

    public DbConnectionFactory(string connectionString)
    {
        ArgumentException.ThrowIfNullOrWhiteSpace(connectionString);
        _connectionString = connectionString;
    }

    /// <summary>
    /// Creates a new <see cref="SqlConnection"/> with the configured connection string.
    /// The caller is responsible for opening and disposing the connection.
    /// </summary>
    public SqlConnection CreateConnection() => new(_connectionString);
}
