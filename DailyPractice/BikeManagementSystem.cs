using System;
using System.Collections.Generic;
using ThirdADO;

namespace DailyPractice
{
    /// <summary>
    /// Interactive Console Management System for Bike Shop inventory.
    /// Provides a complete user interface for CRUD operations:
    /// - Create: Add new bikes
    /// - Read: View all bikes or find by ID
    /// - Update: Modify existing bike details
    /// - Delete: Remove bikes safely with confirmation
    /// </summary>
    internal class BikeManagementSystem
    {
        private readonly BikeshopRepo _repo;

        public BikeManagementSystem()
        {
            _repo = new BikeshopRepo();
        }

        /// <summary>
        /// Starts the interactive management loop until the user chooses to exit.
        /// </summary>
        public void Run()
        {
            bool running = true;

            while (running)
            {
                DisplayMenu();
                Console.Write("Enter your choice (0-5): ");
                string input = Console.ReadLine()?.Trim();

                Console.WriteLine();

                switch (input)
                {
                    case "1":
                        ViewAllBikes();
                        break;
                    case "2":
                        SearchBikeById();
                        break;
                    case "3":
                        InsertBike();
                        break;
                    case "4":
                        UpdateBike();
                        break;
                    case "5":
                        DeleteBike();
                        break;
                    case "0":
                        Console.WriteLine("Returning to previous menu...\n");
                        running = false;
                        break;
                    default:
                        Console.ForegroundColor = ConsoleColor.Yellow;
                        Console.WriteLine("Invalid option. Please enter a number between 0 and 5.");
                        Console.ResetColor();
                        break;
                }

                if (running)
                {
                    Console.WriteLine("\nPress Enter to continue...");
                    Console.ReadLine();
                }
            }
        }

        /// <summary>
        /// Displays the visual management menu.
        /// </summary>
        private void DisplayMenu()
        {
            Console.Clear();
            Console.ForegroundColor = ConsoleColor.Cyan;
            Console.WriteLine("==================================================");
            Console.WriteLine("           BIKE SHOP MANAGEMENT SYSTEM            ");
            Console.WriteLine("==================================================");
            Console.ResetColor();
            Console.WriteLine(" [1] View All Bikes              (SELECT ALL)");
            Console.WriteLine(" [2] Search Bike by ID           (SELECT BY ID)");
            Console.WriteLine(" [3] Add New Bike                (INSERT)");
            Console.WriteLine(" [4] Update Bike Details         (UPDATE)");
            Console.WriteLine(" [5] Delete a Bike               (DELETE)");
            Console.WriteLine(" [0] Exit Management System");
            Console.WriteLine("==================================================");
        }

        /// <summary>
        /// READ ALL: Queries database and prints all bikes in a formatted table.
        /// </summary>
        public void ViewAllBikes()
        {
            Console.ForegroundColor = ConsoleColor.Cyan;
            Console.WriteLine("--- [READ ALL] All Registered Bikes ---");
            Console.ResetColor();

            try
            {
                List<Bikeshop> bikes = _repo.GetAllBikeshops();

                if (bikes.Count == 0)
                {
                    Console.ForegroundColor = ConsoleColor.Yellow;
                    Console.WriteLine("No bikes found in the database.");
                    Console.ResetColor();
                    return;
                }

                Console.WriteLine($"Total Bikes: {bikes.Count}");
                Console.WriteLine(new string('-', 52));
                Console.WriteLine($"{"ID",-6} | {"Bike Name",-24} | {"Price",14}");
                Console.WriteLine(new string('-', 52));

                decimal totalPrice = 0;
                foreach (var bike in bikes)
                {
                    Console.WriteLine($"{bike.Id,-6} | {bike.Name,-24} | {bike.price,14:C}");
                    totalPrice += bike.price;
                }

                Console.WriteLine(new string('-', 52));
                decimal avgPrice = totalPrice / bikes.Count;
                Console.WriteLine($"Average Bike Price: {avgPrice:C}");
            }
            catch (Exception ex)
            {
                PrintError($"Failed to fetch bikes: {ex.Message}");
            }
        }

        /// <summary>
        /// READ ONE: Searches for a bike by its primary key ID.
        /// </summary>
        public void SearchBikeById()
        {
            Console.ForegroundColor = ConsoleColor.Cyan;
            Console.WriteLine("--- [READ BY ID] Search Bike ---");
            Console.ResetColor();

            int id = ReadPositiveInt("Enter Bike ID to search: ");

            try
            {
                Bikeshop bike = _repo.GetBikeshopById(id);

                if (bike == null)
                {
                    Console.ForegroundColor = ConsoleColor.Yellow;
                    Console.WriteLine($"Bike with ID {id} was not found.");
                    Console.ResetColor();
                }
                else
                {
                    PrintSuccess("Bike Found!");
                    Console.WriteLine($"  ID:    {bike.Id}");
                    Console.WriteLine($"  Name:  {bike.Name}");
                    Console.WriteLine($"  Price: {bike.price:C}");
                }
            }
            catch (Exception ex)
            {
                PrintError($"Database query error: {ex.Message}");
            }
        }

        /// <summary>
        /// CREATE / INSERT: Prompts for name and price, then inserts a new bike into the database.
        /// </summary>
        public void InsertBike()
        {
            Console.ForegroundColor = ConsoleColor.Cyan;
            Console.WriteLine("--- [INSERT] Add New Bike ---");
            Console.ResetColor();

            string name = ReadNonEmptyString("Enter Bike Name: ");
            decimal price = ReadPositiveDecimal("Enter Bike Price: ");

            Bikeshop newBike = new Bikeshop
            {
                Name = name,
                price = price
            };

            try
            {
                int generatedId = _repo.AddBikeshop(newBike);
                PrintSuccess($"Bike successfully added with generated ID: {generatedId}!");
                Console.WriteLine($"  Name:  {newBike.Name}");
                Console.WriteLine($"  Price: {newBike.price:C}");
            }
            catch (Exception ex)
            {
                PrintError($"Failed to add bike: {ex.Message}");
            }
        }

        /// <summary>
        /// UPDATE: Modifies name and/or price of an existing bike in the database.
        /// </summary>
        public void UpdateBike()
        {
            Console.ForegroundColor = ConsoleColor.Cyan;
            Console.WriteLine("--- [UPDATE] Modify Bike Details ---");
            Console.ResetColor();

            int id = ReadPositiveInt("Enter Bike ID to update: ");

            try
            {
                Bikeshop existing = _repo.GetBikeshopById(id);
                if (existing == null)
                {
                    Console.ForegroundColor = ConsoleColor.Yellow;
                    Console.WriteLine($"Cannot update. Bike with ID {id} does not exist.");
                    Console.ResetColor();
                    return;
                }

                Console.WriteLine($"Current details: Name = '{existing.Name}', Price = {existing.price:C}");

                // Prompt for updated name (or press Enter to retain current)
                Console.Write($"Enter New Name (leave blank to keep '{existing.Name}'): ");
                string newName = Console.ReadLine()?.Trim();
                if (!string.IsNullOrEmpty(newName))
                {
                    existing.Name = newName;
                }

                // Prompt for updated price (or press Enter to retain current)
                Console.Write($"Enter New Price (leave blank to keep {existing.price:C}): ");
                string priceInput = Console.ReadLine()?.Trim();
                if (!string.IsNullOrEmpty(priceInput))
                {
                    if (decimal.TryParse(priceInput, out decimal newPrice) && newPrice >= 0)
                    {
                        existing.price = newPrice;
                    }
                    else
                    {
                        PrintError("Invalid price entered. Keeping existing price.");
                    }
                }

                bool isUpdated = _repo.UpdateBikeshop(existing);
                if (isUpdated)
                {
                    PrintSuccess($"Bike ID {existing.Id} successfully updated!");
                    Console.WriteLine($"  Updated Name:  {existing.Name}");
                    Console.WriteLine($"  Updated Price: {existing.price:C}");
                }
                else
                {
                    PrintError("Update operation failed. No records were modified.");
                }
            }
            catch (Exception ex)
            {
                PrintError($"Error while updating bike: {ex.Message}");
            }
        }

        /// <summary>
        /// DELETE: Removes a bike from the database with confirmation prompt.
        /// </summary>
        public void DeleteBike()
        {
            Console.ForegroundColor = ConsoleColor.Cyan;
            Console.WriteLine("--- [DELETE] Remove a Bike ---");
            Console.ResetColor();

            int id = ReadPositiveInt("Enter Bike ID to delete: ");

            try
            {
                Bikeshop existing = _repo.GetBikeshopById(id);
                if (existing == null)
                {
                    Console.ForegroundColor = ConsoleColor.Yellow;
                    Console.WriteLine($"Cannot delete. Bike with ID {id} does not exist.");
                    Console.ResetColor();
                    return;
                }

                Console.WriteLine($"Target Bike: [ID {existing.Id}] {existing.Name} - {existing.price:C}");
                Console.ForegroundColor = ConsoleColor.Red;
                Console.Write($"Are you sure you want to permanently delete '{existing.Name}'? (y/N): ");
                Console.ResetColor();

                string confirm = Console.ReadLine()?.Trim().ToLowerInvariant();
                if (confirm == "y" || confirm == "yes")
                {
                    bool isDeleted = _repo.DeleteBikeshop(id);
                    if (isDeleted)
                    {
                        PrintSuccess($"Bike with ID {id} was permanently deleted.");
                    }
                    else
                    {
                        PrintError("Delete operation failed. No records were deleted.");
                    }
                }
                else
                {
                    Console.WriteLine("Delete operation cancelled.");
                }
            }
            catch (Exception ex)
            {
                PrintError($"Error while deleting bike: {ex.Message}");
            }
        }

        #region Helper Input & Formatting Methods

        private string ReadNonEmptyString(string prompt)
        {
            while (true)
            {
                Console.Write(prompt);
                string input = Console.ReadLine()?.Trim();
                if (!string.IsNullOrEmpty(input))
                {
                    return input;
                }
                PrintError("Value cannot be blank. Please try again.");
            }
        }

        private int ReadPositiveInt(string prompt)
        {
            while (true)
            {
                Console.Write(prompt);
                string input = Console.ReadLine()?.Trim();
                if (int.TryParse(input, out int result) && result > 0)
                {
                    return result;
                }
                PrintError("Please enter a valid positive integer.");
            }
        }

        private decimal ReadPositiveDecimal(string prompt)
        {
            while (true)
            {
                Console.Write(prompt);
                string input = Console.ReadLine()?.Trim();
                if (decimal.TryParse(input, out decimal result) && result >= 0)
                {
                    return result;
                }
                PrintError("Please enter a valid non-negative number for price.");
            }
        }

        private void PrintSuccess(string message)
        {
            Console.ForegroundColor = ConsoleColor.Green;
            Console.WriteLine($"[SUCCESS] {message}");
            Console.ResetColor();
        }

        private void PrintError(string message)
        {
            Console.ForegroundColor = ConsoleColor.Red;
            Console.WriteLine($"[ERROR] {message}");
            Console.ResetColor();
        }

        #endregion
    }
}
