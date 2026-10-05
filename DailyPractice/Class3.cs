using System;

namespace ThirdADO
{
    /// <summary>
    /// Represents the Bikeshop entity model mapping directly to the 'bikeshop' table in SQL Server.
    /// </summary>
    public class Bikeshop
    {
        /// <summary>
        /// Gets or sets the unique primary key identifier of the bike.
        /// Corresponds to column 'Id' (int, identity) in the database.
        /// </summary>
        public int Id { get; set; }

        /// <summary>
        /// Gets or sets the name/model of the bike.
        /// Corresponds to column 'bike_name' (varchar) in the database.
        /// </summary>
        public string bike_name { get; set; }

        /// <summary>
        /// Gets or sets the bike name using standard C# PascalCase naming convention.
        /// Serves as a synchronized alias to <see cref="bike_name"/> for flexibility across different callers.
        /// </summary>
        public string Name
        {
            get => bike_name;
            set => bike_name = value;
        }

        /// <summary>
        /// Gets or sets the price of the bike.
        /// Corresponds to column 'price' (decimal / float) in the database.
        /// </summary>
        public decimal price { get; set; }

        /// <summary>
        /// Formats the bike information as a readable single-line summary string.
        /// </summary>
        public override string ToString()
        {
            return $"ID: {Id,-5} | Name: {Name,-20} | Price: {price,12:C}";
        }
    }
}
