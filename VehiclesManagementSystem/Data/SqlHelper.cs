using Microsoft.Data.SqlClient;
using System.Data;

namespace VehiclesManagementSystem.Data;

/// <summary>
/// Centralized asynchronous ADO.NET command executor.
/// Manages connection lifetime, parameter binding, and resource disposal.
/// All connections and commands are wrapped in 'await using' for automatic cleanup.
/// </summary>
public class SqlHelper
{
    private readonly DbConnectionFactory _factory;

    public SqlHelper(DbConnectionFactory factory)
    {
        _factory = factory ?? throw new ArgumentNullException(nameof(factory));
    }

    /// <summary>
    /// Executes a query and maps each row to <typeparamref name="T"/>
    /// using the provided mapping function.
    /// </summary>
    /// <typeparam name="T">The type to map each row to.</typeparam>
    /// <param name="sql">The parameterized SQL query to execute.</param>
    /// <param name="map">A function that maps a <see cref="SqlDataReader"/> row to <typeparamref name="T"/>.</param>
    /// <param name="parameters">Optional SQL parameters for the query.</param>
    /// <returns>A list of mapped entities.</returns>
    public async Task<List<T>> ExecuteReaderAsync<T>(
        string sql,
        Func<SqlDataReader, T> map,
        SqlParameter[]? parameters = null)
    {
        var results = new List<T>();

        await using var connection = _factory.CreateConnection();
        await connection.OpenAsync();

        await using var command = new SqlCommand(sql, connection);
        command.CommandType = CommandType.Text;

        if (parameters is not null)
            command.Parameters.AddRange(parameters);

        await using var reader = await command.ExecuteReaderAsync();

        while (await reader.ReadAsync())
        {
            results.Add(map(reader));
        }

        return results;
    }

    /// <summary>
    /// Executes an INSERT, UPDATE, or DELETE statement.
    /// Returns the number of rows affected.
    /// </summary>
    /// <param name="sql">The parameterized SQL command to execute.</param>
    /// <param name="parameters">Optional SQL parameters for the command.</param>
    /// <returns>The number of rows affected.</returns>
    public async Task<int> ExecuteNonQueryAsync(
        string sql,
        SqlParameter[]? parameters = null)
    {
        await using var connection = _factory.CreateConnection();
        await connection.OpenAsync();

        await using var command = new SqlCommand(sql, connection);
        command.CommandType = CommandType.Text;

        if (parameters is not null)
            command.Parameters.AddRange(parameters);

        return await command.ExecuteNonQueryAsync();
    }

    /// <summary>
    /// Executes a query and returns the first column of the first row,
    /// cast to <typeparamref name="T"/>.
    /// Useful for COUNT, MAX, or INSERT ... OUTPUT INSERTED.Id queries.
    /// </summary>
    /// <typeparam name="T">The expected return type.</typeparam>
    /// <param name="sql">The parameterized SQL query to execute.</param>
    /// <param name="parameters">Optional SQL parameters for the query.</param>
    /// <returns>The scalar result, or default if null/DBNull.</returns>
    public async Task<T?> ExecuteScalarAsync<T>(
        string sql,
        SqlParameter[]? parameters = null)
    {
        await using var connection = _factory.CreateConnection();
        await connection.OpenAsync();

        await using var command = new SqlCommand(sql, connection);
        command.CommandType = CommandType.Text;

        if (parameters is not null)
            command.Parameters.AddRange(parameters);

        var result = await command.ExecuteScalarAsync();

        if (result is null || result == DBNull.Value)
            return default;

        return (T)Convert.ChangeType(result, typeof(T));
    }
}
