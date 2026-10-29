using System.Collections.Generic;
using ViewModelDemo.Models;

namespace ViewModelDemo.ViewModels
{
    public class AdminDashboardViewModel
    {
        public int TotalEmployees { get; set; }
        public int TotalUsers { get; set; }
        public decimal TotalPayroll { get; set; }
        public decimal AverageSalary { get; set; }
        public Dictionary<string, int> DepartmentCounts { get; set; } = new Dictionary<string, int>();
        public List<EmployeeListItemViewModel> RecentEmployees { get; set; } = new List<EmployeeListItemViewModel>();
        public List<User> RecentUsers { get; set; } = new List<User>();

        public string FormattedTotalPayroll => "Rs. " + TotalPayroll.ToString("N2");
        public string FormattedAverageSalary => "Rs. " + AverageSalary.ToString("N2");
    }
}
