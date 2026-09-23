namespace Assignment;

// Question 1: Encapsulation
public class PaymentProcessor
{
    private string _cardNumber = string.Empty;
    private decimal _accountBalance;
    private string _securityToken = string.Empty;

    public string CardNumber
    {
        get
        {
            return "************" + _cardNumber.Substring(_cardNumber.Length - 4);
        }
        set
        {
            _cardNumber = value;
        }
    }

    public decimal AccountBalance
    {
        get
        {
            return _accountBalance;
        }
        set
        {
            if (value >= 0)
            {
                _accountBalance = value;
            }
        }
    }

    // Write-only property: outside code can set the token but cannot read it.
    public string SecurityToken
    {
        set
        {
            _securityToken = value;
        }
    }
}
