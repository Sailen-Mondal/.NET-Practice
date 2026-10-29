namespace ViewModelDemo.Models
{
    public class UserSession
    {
        public int UserId { get; set; }
        public string Username { get; set; }
        public string Email { get; set; }
        public string FullName { get; set; }
        public string Role { get; set; }

        public bool IsAdmin => string.Equals(Role, "Admin", System.StringComparison.OrdinalIgnoreCase);
    }
}
