using System;

namespace WebServices
{
    /// <summary>
    /// Student entity model matching tblStudents schema in TestDB.
    /// Serialized to JSON for ASP.NET AJAX client script and XML for SOAP responses.
    /// </summary>
    public class Student
    {
        public int ID { get; set; }
        public string Name { get; set; }
        public string Gender { get; set; }
        public int TotalMarks { get; set; }
    }
}
