namespace TravelAgentRAG.Models;

/// <summary>
/// Represents a travel destination with all relevant information.
/// This is the raw data structure before it gets chunked for RAG.
/// </summary>
public class TravelDestination
{
    public required string Name { get; init; }
    public required string Country { get; init; }
    public required string Description { get; init; }
    public required string BestTimeToVisit { get; init; }
    public required string TopAttractions { get; init; }
    public required string AverageBudgetPerDay { get; init; }
    public required string LocalCuisine { get; init; }
    public required string TravelTips { get; init; }
}
