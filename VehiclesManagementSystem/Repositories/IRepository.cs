namespace VehiclesManagementSystem.Repositories;

/// <summary>
/// Generic CRUD contract for any entity type.
/// Provides a standard interface for data access operations.
/// </summary>
/// <typeparam name="T">The entity type this repository manages.</typeparam>
public interface IRepository<T> where T : class
{
    /// <summary>Retrieves a single entity by its primary key.</summary>
    Task<T?> GetByIdAsync(int id);

    /// <summary>Retrieves all entities from the data store.</summary>
    Task<List<T>> GetAllAsync();

    /// <summary>Inserts a new entity. Returns the number of rows affected.</summary>
    Task<int> AddAsync(T entity);

    /// <summary>Updates an existing entity. Returns the number of rows affected.</summary>
    Task<int> UpdateAsync(T entity);

    /// <summary>Deletes an entity by its primary key. Returns the number of rows affected.</summary>
    Task<int> DeleteAsync(int id);
}
