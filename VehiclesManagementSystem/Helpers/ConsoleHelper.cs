using VehiclesManagementSystem.Models;

namespace VehiclesManagementSystem.Helpers;

/// <summary>
/// Console UI utilities for input parsing and display formatting.
/// Keeps Program.cs clean by centralizing all user interaction helpers.
/// </summary>
public static class ConsoleHelper
{
    /// <summary>Prints a styled section header.</summary>
    public static void PrintHeader(string title)
    {
        Console.ForegroundColor = ConsoleColor.Cyan;
        Console.WriteLine($"\n{"".PadLeft(50, '=')}");
        Console.WriteLine($"  {title}");
        Console.WriteLine($"{"".PadLeft(50, '=')}");
        Console.ResetColor();
    }

    /// <summary>Prints a success message in green.</summary>
    public static void PrintSuccess(string message)
    {
        Console.ForegroundColor = ConsoleColor.Green;
        Console.WriteLine($"  \u2713 {message}");
        Console.ResetColor();
    }

    /// <summary>Prints an error message in red.</summary>
    public static void PrintError(string message)
    {
        Console.ForegroundColor = ConsoleColor.Red;
        Console.WriteLine($"  \u2717 {message}");
        Console.ResetColor();
    }

    /// <summary>Prints a warning message in yellow.</summary>
    public static void PrintWarning(string message)
    {
        Console.ForegroundColor = ConsoleColor.Yellow;
        Console.WriteLine($"  \u26A0 {message}");
        Console.ResetColor();
    }

    /// <summary>Displays a formatted table of vehicles.</summary>
    public static void PrintVehicleTable(List<Vehicle> vehicles)
    {
        if (vehicles.Count == 0)
        {
            PrintWarning("No vehicles found.");
            return;
        }

        Console.ForegroundColor = ConsoleColor.DarkGray;
        Console.WriteLine($"  {"Id",-5} {"VIN",-20} {"Make",-12} {"Model",-18} {"Year",-6} {"Odometer",12} {"Status",-10}");
        Console.WriteLine($"  {"".PadLeft(83, '-')}");
        Console.ResetColor();

        foreach (var v in vehicles)
        {
            Console.ForegroundColor = v.IsActive ? ConsoleColor.White : ConsoleColor.DarkGray;
            string status = v.IsActive ? "Active" : "Inactive";
            Console.WriteLine($"  {v.Id,-5} {v.VIN,-20} {v.Make,-12} {v.Model,-18} {v.Year,-6} {v.OdometerReading,12:N2} {status,-10}");
        }

        Console.ResetColor();
        Console.WriteLine();
    }

    /// <summary>Reads and validates an integer from the console.</summary>
    public static int ReadInt(string prompt)
    {
        while (true)
        {
            Console.Write($"  {prompt}: ");
            if (int.TryParse(Console.ReadLine()?.Trim(), out int value))
                return value;
            PrintError("Invalid number. Please try again.");
        }
    }

    /// <summary>Reads and validates a decimal from the console.</summary>
    public static decimal ReadDecimal(string prompt)
    {
        while (true)
        {
            Console.Write($"  {prompt}: ");
            if (decimal.TryParse(Console.ReadLine()?.Trim(), out decimal value))
                return value;
            PrintError("Invalid decimal number. Please try again.");
        }
    }

    /// <summary>Reads a non-empty string from the console.</summary>
    public static string ReadString(string prompt)
    {
        while (true)
        {
            Console.Write($"  {prompt}: ");
            string? input = Console.ReadLine()?.Trim();
            if (!string.IsNullOrWhiteSpace(input))
                return input;
            PrintError("Input cannot be empty. Please try again.");
        }
    }

    /// <summary>Reads a yes/no confirmation from the console.</summary>
    public static bool ReadYesNo(string prompt)
    {
        while (true)
        {
            Console.Write($"  {prompt} (y/n): ");
            string? input = Console.ReadLine()?.Trim().ToLower();
            if (input == "y" || input == "yes") return true;
            if (input == "n" || input == "no") return false;
            PrintError("Please enter 'y' or 'n'.");
        }
    }
}
