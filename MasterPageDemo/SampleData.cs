using System.Collections.Generic;
using System.Linq;

namespace MasterPageDemo
{
    // ── Model: Article (used by Default.aspx / Home) ─────────────────────────
    public class Article
    {
        public int    Id          { get; set; }
        public string Title       { get; set; }
        public string Category    { get; set; }
        public string Author      { get; set; }
        public string Date        { get; set; }
        public string Description { get; set; }
    }

    // ── Model: TeamMember (used by About.aspx) ───────────────────────────────
    public class TeamMember
    {
        public string Name       { get; set; }
        public string Role       { get; set; }
        public string Department { get; set; }
        public string Location   { get; set; }
    }

    // ── Model: ContactEntry (used by Contact.aspx) ───────────────────────────
    public class ContactEntry
    {
        public string Name       { get; set; }
        public string Email      { get; set; }
        public string Department { get; set; }
        public string Phone      { get; set; }
    }

    // ── Static in-memory data store ──────────────────────────────────────────
    public static class SampleData
    {
        // ── Articles ─────────────────────────────────────────────────────────
        private static readonly List<Article> _articles = new List<Article>
        {
            new Article { Id = 1, Title = "Getting Started with ASP.NET",       Category = "Web Development", Author = "Rohan Das",    Date = "2026-01-10", Description = "An introduction to ASP.NET Web Forms and the page lifecycle." },
            new Article { Id = 2, Title = "Understanding Master Pages",          Category = "ASP.NET",         Author = "Priya Sharma", Date = "2026-02-14", Description = "Learn how Site.Master provides a shared layout for all content pages." },
            new Article { Id = 3, Title = "Working with GridView Control",       Category = "Controls",        Author = "Ankit Roy",    Date = "2026-03-05", Description = "Bind data to GridView, enable sorting, paging and custom columns." },
            new Article { Id = 4, Title = "Code-Behind Pattern in Web Forms",    Category = "Architecture",    Author = "Rohan Das",    Date = "2026-04-18", Description = "Separation of markup and logic using .aspx and .aspx.cs files." },
            new Article { Id = 5, Title = "QueryString and Page Navigation",     Category = "ASP.NET",         Author = "Priya Sharma", Date = "2026-05-22", Description = "Pass data between pages using Request.QueryString and Response.Redirect." },
            new Article { Id = 6, Title = "CSS Variables and Theming",           Category = "Design",          Author = "Sneha Bose",   Date = "2026-06-01", Description = "Use CSS custom properties to build consistent, maintainable themes." },
            new Article { Id = 7, Title = "LINQ for In-Memory Data Filtering",   Category = "C#",              Author = "Ankit Roy",    Date = "2026-07-09", Description = "Filter and sort collections with LINQ Where and OrderBy." },
            new Article { Id = 8, Title = "Web.config and App Configuration",    Category = "Configuration",   Author = "Sneha Bose",   Date = "2026-08-30", Description = "Manage encoding, routing, and environment settings in Web.config." },
        };

        public static List<Article> GetArticles(string query = "")
        {
            if (string.IsNullOrWhiteSpace(query))
                return _articles;

            string q = query.ToLowerInvariant();
            return _articles.Where(a =>
                a.Title.ToLower().Contains(q)       ||
                a.Category.ToLower().Contains(q)    ||
                a.Author.ToLower().Contains(q)      ||
                a.Date.Contains(q)                  ||
                a.Description.ToLower().Contains(q)
            ).ToList();
        }

        // ── Team Members ─────────────────────────────────────────────────────
        private static readonly List<TeamMember> _team = new List<TeamMember>
        {
            new TeamMember { Name = "Rohan Das",      Role = "Lead Developer",       Department = "Engineering",   Location = "Kolkata" },
            new TeamMember { Name = "Priya Sharma",   Role = "UI/UX Designer",       Department = "Design",        Location = "Mumbai"  },
            new TeamMember { Name = "Ankit Roy",      Role = "Backend Engineer",     Department = "Engineering",   Location = "Kolkata" },
            new TeamMember { Name = "Sneha Bose",     Role = "Frontend Developer",   Department = "Engineering",   Location = "Pune"    },
            new TeamMember { Name = "Arjun Mehta",    Role = "QA Engineer",          Department = "Quality",       Location = "Delhi"   },
            new TeamMember { Name = "Kavya Nair",     Role = "Product Manager",      Department = "Management",    Location = "Bangalore" },
        };

        public static List<TeamMember> GetTeamMembers(string query = "")
        {
            if (string.IsNullOrWhiteSpace(query))
                return _team;

            string q = query.ToLowerInvariant();
            return _team.Where(m =>
                m.Name.ToLower().Contains(q)       ||
                m.Role.ToLower().Contains(q)       ||
                m.Department.ToLower().Contains(q) ||
                m.Location.ToLower().Contains(q)
            ).ToList();
        }

        // ── Contacts ─────────────────────────────────────────────────────────
        private static readonly List<ContactEntry> _contacts = new List<ContactEntry>
        {
            new ContactEntry { Name = "Support Team",     Email = "support@example.com",    Department = "Customer Support", Phone = "+91 98001 11001" },
            new ContactEntry { Name = "Sales Desk",       Email = "sales@example.com",      Department = "Sales",            Phone = "+91 98001 11002" },
            new ContactEntry { Name = "HR Department",    Email = "hr@example.com",          Department = "Human Resources",  Phone = "+91 98001 11003" },
            new ContactEntry { Name = "Finance Team",     Email = "finance@example.com",    Department = "Finance",          Phone = "+91 98001 11004" },
            new ContactEntry { Name = "Tech Helpdesk",   Email = "helpdesk@example.com",   Department = "IT",               Phone = "+91 98001 11005" },
            new ContactEntry { Name = "Media Enquiries", Email = "media@example.com",       Department = "Marketing",        Phone = "+91 98001 11006" },
        };

        public static List<ContactEntry> GetContacts(string query = "")
        {
            if (string.IsNullOrWhiteSpace(query))
                return _contacts;

            string q = query.ToLowerInvariant();
            return _contacts.Where(c =>
                c.Name.ToLower().Contains(q)       ||
                c.Email.ToLower().Contains(q)      ||
                c.Department.ToLower().Contains(q) ||
                c.Phone.Contains(q)
            ).ToList();
        }
    }
}
