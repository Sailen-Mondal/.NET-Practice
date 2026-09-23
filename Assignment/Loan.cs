namespace Assignment;

// Question 8: Abstract class with shared and custom behaviour.
public abstract class Loan
{
    public void VerifyDocuments()
    {
        Console.WriteLine("Documents verified.");
    }

    public void SanctionAmount(decimal amount)
    {
        Console.WriteLine("Loan sanctioned: " + amount);
    }

    public abstract double CalculateInterestRate();
    public abstract bool CheckEligibility(int creditScore);
}

public class HomeLoan : Loan
{
    public override double CalculateInterestRate()
    {
        return 7.5;
    }

    public override bool CheckEligibility(int creditScore)
    {
        return creditScore >= 700;
    }
}

public class CarLoan : Loan
{
    public override double CalculateInterestRate()
    {
        return 8.5;
    }

    public override bool CheckEligibility(int creditScore)
    {
        return creditScore >= 650;
    }
}

public class EducationLoan : Loan
{
    public override double CalculateInterestRate()
    {
        return 6.5;
    }

    public override bool CheckEligibility(int creditScore)
    {
        return creditScore >= 600;
    }
}
