using System;
using System.ComponentModel.DataAnnotations;

namespace StudentManagementSystem.Models
{
    public class Project
    {
        [Display(Name = "Project ID")]
        public int ProjectID { get; set; }

        [Required(ErrorMessage = "Project title is required.")]
        [StringLength(150, ErrorMessage = "Title cannot exceed 150 characters.")]
        [Display(Name = "Project Title")]
        public string Title { get; set; }

        [StringLength(500, ErrorMessage = "Description cannot exceed 500 characters.")]
        [DataType(DataType.MultilineText)]
        [Display(Name = "Description")]
        public string Description { get; set; }

        [Required(ErrorMessage = "Category is required.")]
        [StringLength(50)]
        [Display(Name = "Category")]
        public string Category { get; set; }

        [Required(ErrorMessage = "Lead student name is required.")]
        [StringLength(100)]
        [Display(Name = "Lead Student")]
        public string LeadStudent { get; set; }

        [Required(ErrorMessage = "Status is required.")]
        [StringLength(50)]
        [Display(Name = "Status")]
        public string Status { get; set; }

        [Required(ErrorMessage = "Priority is required.")]
        [StringLength(20)]
        [Display(Name = "Priority")]
        public string Priority { get; set; }

        [Required(ErrorMessage = "Budget is required.")]
        [Range(0, 10000000, ErrorMessage = "Budget must be a non-negative amount.")]
        [Display(Name = "Budget (INR)")]
        [DisplayFormat(DataFormatString = "{0:N2}", ApplyFormatInEditMode = false)]
        public decimal Budget { get; set; }

        [Required(ErrorMessage = "Start date is required.")]
        [DataType(DataType.Date)]
        [DisplayFormat(DataFormatString = "{0:yyyy-MM-dd}", ApplyFormatInEditMode = true)]
        [Display(Name = "Start Date")]
        public DateTime StartDate { get; set; } = DateTime.Today;

        [DataType(DataType.Date)]
        [DisplayFormat(DataFormatString = "{0:yyyy-MM-dd}", ApplyFormatInEditMode = true)]                      
        [Display(Name = "End Date")]
        public DateTime? EndDate { get; set; }
    }

    public class ProjectMetrics
    {
        public int TotalProjects { get; set; }
        public int InProgressCount { get; set; }
        public int CompletedCount { get; set; }
        public int PlanningCount { get; set; }
        public decimal TotalBudget { get; set; }
        public decimal AverageBudget { get; set; }
    }

    public class ProjectIndexViewModel
    {
        public System.Collections.Generic.List<Project> Projects { get; set; }
        public ProjectMetrics Metrics { get; set; }
        public string SearchTerm { get; set; }
        public string SelectedStatus { get; set; }
    }
}
