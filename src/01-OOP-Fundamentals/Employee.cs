namespace Assignment;

// Question 3: Single and hierarchical inheritance.
public class Employee
{
    public Employee(int employeeId, string name, decimal baseSalary)
    {
        EmployeeID = employeeId;
        Name = name;
        BaseSalary = baseSalary;
    }

    public int EmployeeID { get; }
    public string Name { get; }
    public decimal BaseSalary { get; }

    public virtual decimal CalculateNetSalary()
    {
        return BaseSalary;
    }
}

public class FullTimeEmployee : Employee
{
    public FullTimeEmployee(int employeeId, string name, decimal baseSalary)
        : base(employeeId, name, baseSalary)
    {
    }

    public override decimal CalculateNetSalary()
    {
        return BaseSalary - (BaseSalary * 0.10m);
    }
}

public class ContractEmployee : Employee
{
    public ContractEmployee(int employeeId, string name, decimal baseSalary)
        : base(employeeId, name, baseSalary)
    {
    }

    public override decimal CalculateNetSalary()
    {
        return BaseSalary - (BaseSalary * 0.05m);
    }
}

public class Freelancer : Employee
{
    public Freelancer(int employeeId, string name, decimal baseSalary)
        : base(employeeId, name, baseSalary)
    {
    }

    public override decimal CalculateNetSalary()
    {
        return BaseSalary;
    }
}
