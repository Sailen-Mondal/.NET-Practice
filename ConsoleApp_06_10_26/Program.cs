using System;
using System.Configuration;
using System.Data;
using System.Data.Common;
using System.Data.SqlClient;

namespace ConsoleApp_06_10_26
{
    internal class Program
    {
        static void Main(string[] args)
        {
            string connectionString = ConfigurationManager.ConnectionStrings["DBConn"].ConnectionString;

            // DATA TABLE
            SqlDataAdapter dataAdapter = new SqlDataAdapter("SELECT * FROM Students", connectionString);
            DataTable studentTable = new DataTable();
            dataAdapter.Fill(studentTable);

            Console.WriteLine("===== USING DATATABLE =====");

            foreach (DataRow row in studentTable.Rows)
            {
                Console.WriteLine(
                    row["Id"] + " | " +
                    row["Name"] + " | " +
                    row["Email"] + " | " +
                    row["Age"]
                );
            }

            Console.WriteLine();
            Console.WriteLine("===== USING DATASET =====");

            // DATA SET
            foreach (DataRow row in studentTable.Rows)
            {
                Console.WriteLine(
                    row["Id"] + " | " +
                    row["Name"] + " | " +
                    row["Email"] + " | " +
                    row["Age"]
                );
            }

        }
    }
}
