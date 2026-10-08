using VehiclesManagementSystem.Data;

namespace VehiclesManagementSystem.Repositories;

/// <summary>
/// Abstract base repository providing shared <see cref="SqlHelper"/> access
/// to all concrete repository implementations.
/// Enforces the generic CRUD contract from <see cref="IRepository{T}"/>.
/// </summary>
/// <typeparam name="T">The entity type this repository manages.</typeparam>
public abstract class Repository<T> : IRepository<T> where T : class
{
    /// <summary>
    /// The centralized data access helper shared by all derived repositories.
    /// </summary>
    protected readonly SqlHelper Db;

    protected Repository(SqlHelper sqlHelper)
    {
        Db = sqlHelper ?? throw new ArgumentNullException(nameof(sqlHelper));
    }

    public abstract Task<T?> GetByIdAsync(int id);
    public abstract Task<List<T>> GetAllAsync();
    public abstract Task<int> AddAsync(T entity);
    public abstract Task<int> UpdateAsync(T entity);
    public abstract Task<int> DeleteAsync(int id);
}
