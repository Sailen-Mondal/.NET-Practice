using System.Collections.Generic;

namespace ConsoleApp_06_10_26
{
    // ================================================================
    // Interface - Contract for all Employee data operations
    // ================================================================
    public interface IEmployeeRepository
    {
        int AddEmployee(Employee emp);
        List<Employee> GetAllEmployees();
        Employee GetEmployeeById(int id);
        bool UpdateEmployee(Employee emp);
        bool DeleteEmployee(int id);
    }
}
