using System.ComponentModel.DataAnnotations;

namespace ViewModelDemo.ViewModels
{
    public class EmployeeFormViewModel
    {
        public int EmployeeId { get; set; }

        [Required(ErrorMessage = "Employee Name is required")]
        [StringLength(150, ErrorMessage = "Name cannot exceed 150 characters")]
        [Display(Name = "Full Name")]
        public string Name { get; set; }

        [Required(ErrorMessage = "Gender is required")]
        public string Gender { get; set; }

        [Required(ErrorMessage = "Department is required")]
        [StringLength(100, ErrorMessage = "Department cannot exceed 100 characters")]
        public string Department { get; set; }

        [Required(ErrorMessage = "Salary is required")]
        [Range(1000, 10000000, ErrorMessage = "Salary must be between Rs. 1,000 and Rs. 10,000,000")]
        public decimal Salary { get; set; }

        public int AddressId { get; set; }

        [Required(ErrorMessage = "Country is required")]
        [StringLength(100)]
        public string Country { get; set; } = "India";

        [Required(ErrorMessage = "State is required")]
        [StringLength(100)]
        public string State { get; set; }

        [Required(ErrorMessage = "City is required")]
        [StringLength(100)]
        public string City { get; set; }

        [Required(ErrorMessage = "PIN Code is required")]
        [StringLength(20)]
        [Display(Name = "PIN Code")]
        public string Pin { get; set; }

        public bool IsEditMode => EmployeeId > 0;
        public string PageTitle => IsEditMode ? "Edit Employee" : "Add New Employee";
        public string PageHeader => IsEditMode ? "Update Employee Details" : "Create Employee Record";
        public string SubmitButtonText => IsEditMode ? "Save Changes" : "Create Employee";
    }
}
