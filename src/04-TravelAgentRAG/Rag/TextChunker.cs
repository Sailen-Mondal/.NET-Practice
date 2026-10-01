using TravelAgentRAG.Models;

namespace TravelAgentRAG.Rag;

/// <summary>
/// Represents a single piece of text extracted from a destination with metadata.
/// </summary>
public record TextChunk(string Destination, string Category, string Text);


/// <summary>
/// Splits structured TravelDestination objects into flat text chunks with metadata.
/// </summary>
public static class TextChunker
{
    public static List<TextChunk> ChunkDestinations(List<TravelDestination> destinations)
    {
        var chunks = new List<TextChunk>();

        foreach (var dest in destinations)
        {
            chunks.Add(new TextChunk(dest.Name, "Overview", $"{dest.Name}, {dest.Country} - Overview: {dest.Description}"));
            chunks.Add(new TextChunk(dest.Name, "BestTimeToVisit", $"{dest.Name}, {dest.Country} - Best Time to Visit: {dest.BestTimeToVisit}"));
            chunks.Add(new TextChunk(dest.Name, "TopAttractions", $"{dest.Name}, {dest.Country} - Top Attractions: {dest.TopAttractions}"));
            chunks.Add(new TextChunk(dest.Name, "Budget", $"{dest.Name}, {dest.Country} - Budget: {dest.AverageBudgetPerDay}"));
            chunks.Add(new TextChunk(dest.Name, "LocalCuisine", $"{dest.Name}, {dest.Country} - Local Cuisine: {dest.LocalCuisine}"));
            chunks.Add(new TextChunk(dest.Name, "TravelTips", $"{dest.Name}, {dest.Country} - Travel Tips: {dest.TravelTips}"));
        }

        return chunks;
    }
}
