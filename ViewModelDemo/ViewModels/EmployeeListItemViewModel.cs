namespace ViewModelDemo.ViewModels
{
    public class EmployeeListItemViewModel
    {
        public int EmployeeId { get; set; }
        public string Name { get; set; }
        public string Gender { get; set; }
        public string Department { get; set; }
        public decimal Salary { get; set; }
        public int AddressId { get; set; }
        public string City { get; set; }
        public string State { get; set; }
        public string Country { get; set; }

        public string FormattedSalary => "Rs. " + Salary.ToString("N2");
        public string Location => City + ", " + State;
    }
}
