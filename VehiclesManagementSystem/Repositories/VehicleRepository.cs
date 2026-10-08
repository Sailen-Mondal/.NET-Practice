using Microsoft.Data.SqlClient;
using VehiclesManagementSystem.Data;
using VehiclesManagementSystem.Models;

namespace VehiclesManagementSystem.Repositories;

/// <summary>
/// Concrete repository for Vehicle CRUD operations against dbo.Vehicles.
/// All SQL is parameterized — zero SQL injection risk.
/// Row mapping is handled via a private static delegate for reuse.
/// </summary>
public class VehicleRepository : Repository<Vehicle>
{
    public VehicleRepository(SqlHelper sqlHelper) : base(sqlHelper) { }

    /// <summary>
    /// Maps a single <see cref="SqlDataReader"/> row to a <see cref="Vehicle"/> instance.
    /// Uses ordinal-based access for performance and safety.
    /// </summary>
    private static Vehicle MapRow(SqlDataReader reader) => new()
    {
        Id              = reader.GetInt32(reader.GetOrdinal("Id")),
        VIN             = reader.GetString(reader.GetOrdinal("VIN")),
        Make            = reader.GetString(reader.GetOrdinal("Make")),
        Model           = reader.GetString(reader.GetOrdinal("Model")),
        Year            = reader.GetInt32(reader.GetOrdinal("Year")),
        OdometerReading = reader.GetDecimal(reader.GetOrdinal("OdometerReading")),
        IsActive        = reader.GetBoolean(reader.GetOrdinal("IsActive")),
        CreatedAt       = reader.GetDateTime(reader.GetOrdinal("CreatedAt")),
        UpdatedAt       = reader.IsDBNull(reader.GetOrdinal("UpdatedAt"))
                            ? null
                            : reader.GetDateTime(reader.GetOrdinal("UpdatedAt"))
    };

    /// <summary>Retrieves a single vehicle by its primary key.</summary>
    public override async Task<Vehicle?> GetByIdAsync(int id)
    {
        const string sql = "SELECT * FROM dbo.Vehicles WHERE Id = @Id;";

        var parameters = new[]
        {
            new SqlParameter("@Id", id)
        };

        var results = await Db.ExecuteReaderAsync(sql, MapRow, parameters);
        return results.FirstOrDefault();
    }

    /// <summary>Retrieves all vehicles ordered by Id.</summary>
    public override async Task<List<Vehicle>> GetAllAsync()
    {
        const string sql = "SELECT * FROM dbo.Vehicles ORDER BY Id;";
        return await Db.ExecuteReaderAsync(sql, MapRow);
    }

    /// <summary>Inserts a new vehicle into the fleet.</summary>
    public override async Task<int> AddAsync(Vehicle entity)
    {
        const string sql = @"
            INSERT INTO dbo.Vehicles (VIN, Make, Model, Year, OdometerReading, IsActive)
            VALUES (@VIN, @Make, @Model, @Year, @OdometerReading, @IsActive);";

        var parameters = new[]
        {
            new SqlParameter("@VIN",             entity.VIN),
            new SqlParameter("@Make",            entity.Make),
            new SqlParameter("@Model",           entity.Model),
            new SqlParameter("@Year",            entity.Year),
            new SqlParameter("@OdometerReading", entity.OdometerReading),
            new SqlParameter("@IsActive",        entity.IsActive)
        };

        return await Db.ExecuteNonQueryAsync(sql, parameters);
    }

    /// <summary>
    /// Updates an existing vehicle's telemetry and status.
    /// Automatically sets UpdatedAt to the current server time.
    /// </summary>
    public override async Task<int> UpdateAsync(Vehicle entity)
    {
        const string sql = @"
            UPDATE dbo.Vehicles
            SET VIN             = @VIN,
                Make            = @Make,
                Model           = @Model,
                Year            = @Year,
                OdometerReading = @OdometerReading,
                IsActive        = @IsActive,
                UpdatedAt       = SYSDATETIME()
            WHERE Id = @Id;";

        var parameters = new[]
        {
            new SqlParameter("@Id",              entity.Id),
            new SqlParameter("@VIN",             entity.VIN),
            new SqlParameter("@Make",            entity.Make),
            new SqlParameter("@Model",           entity.Model),
            new SqlParameter("@Year",            entity.Year),
            new SqlParameter("@OdometerReading", entity.OdometerReading),
            new SqlParameter("@IsActive",        entity.IsActive)
        };

        return await Db.ExecuteNonQueryAsync(sql, parameters);
    }

    /// <summary>Permanently removes a decommissioned vehicle from the fleet.</summary>
    public override async Task<int> DeleteAsync(int id)
    {
        const string sql = "DELETE FROM dbo.Vehicles WHERE Id = @Id;";

        var parameters = new[]
        {
            new SqlParameter("@Id", id)
        };

        return await Db.ExecuteNonQueryAsync(sql, parameters);
    }
}
