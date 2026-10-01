namespace TravelAgentRAG.Rag;

/// <summary>
/// Keyword-based search engine for retrieving relevant text chunks.
/// Supports destination filtering and topic-aware relevance scoring.
/// </summary>
public class KeywordSearcher
{
    private readonly List<TextChunk> _chunks = [];

    // Stop words that are ignored during general keyword matching
    private static readonly HashSet<string> StopWords =
    [
        "a", "an", "the", "is", "are", "was", "were", "be", "been",
        "in", "on", "at", "to", "for", "of", "with", "by", "from",
        "it", "its", "this", "that", "these", "those",
        "i", "me", "my", "we", "our", "you", "your",
        "what", "which", "who", "when", "where", "how",
        "do", "does", "did", "will", "would", "could", "should",
        "can", "may", "might", "shall", "must",
        "and", "or", "but", "not", "no", "so",
        "if", "then", "than", "very", "just", "about",
        "travel", "trip", "visit", "tour", "want", "like", "tell", "give",
        "suggest", "help", "need", "planning", "plan", "going", "go", "please"
    ];

    // Topic keywords mapped to relevant chunk categories
    private static readonly Dictionary<string, string[]> CategoryKeywords = new(StringComparer.OrdinalIgnoreCase)
    {
        ["LocalCuisine"] = ["food", "eat", "eating", "dish", "dishes", "cuisine", "restaurant", "sweets", "breakfast", "dinner", "lunch", "taste"],
        ["Budget"] = ["budget", "cost", "price", "rate", "inr", "usd", "rupees", "expensive", "cheap", "affordable", "money", "spend", "spending", "day", "days"],
        ["TopAttractions"] = ["attraction", "attractions", "see", "sightseeing", "places", "place", "monument", "fort", "temple", "church", "beach", "lake", "view", "views"],
        ["BestTimeToVisit"] = ["time", "season", "month", "weather", "summer", "winter", "monsoon", "spring", "october", "november", "december", "january", "february", "march", "april", "may", "june", "july", "august", "september"],
        ["TravelTips"] = ["tip", "tips", "advice", "guideline", "transport", "metro", "cab", "rickshaw", "guide", "scam", "stay", "hotel"]
    };

    public void AddChunks(List<TextChunk> chunks)
    {
        _chunks.AddRange(chunks);
    }

    /// <summary>
    /// Searches for the most relevant chunks matching the query and active destination.
    /// </summary>
    public List<string> Search(string query, string? activeDestination = null, int topK = 4)
    {
        var queryTokens = Tokenize(query);

        // Check if query mentions any specific destination in our database
        var mentionedDestination = _chunks
            .Select(c => c.Destination)
            .Distinct(StringComparer.OrdinalIgnoreCase)
            .FirstOrDefault(d => query.Contains(d, StringComparison.OrdinalIgnoreCase));

        var targetDestination = mentionedDestination ?? activeDestination;

        // If we have a target destination, score chunks for that destination first
        var candidateChunks = !string.IsNullOrEmpty(targetDestination)
            ? _chunks.Where(c => c.Destination.Equals(targetDestination, StringComparison.OrdinalIgnoreCase)).ToList()
            : _chunks;

        if (candidateChunks.Count == 0)
            candidateChunks = _chunks;

        var scored = candidateChunks
            .Select(chunk => new
            {
                chunk.Text,
                Score = CalculateScore(queryTokens, query, chunk)
            })
            .OrderByDescending(x => x.Score)
            .Take(topK)
            .ToList();

        // If all scores are 0 (e.g. general conversational reply), return key chunks for the target destination
        if (scored.All(x => x.Score <= 0) && !string.IsNullOrEmpty(targetDestination))
        {
            return candidateChunks
                .Where(c => c.Category is "Overview" or "Budget" or "TopAttractions" or "LocalCuisine")
                .Take(topK)
                .Select(c => c.Text)
                .ToList();
        }

        return scored.Where(x => x.Score > 0).Select(x => x.Text).ToList();
    }

    private static double CalculateScore(List<string> queryTokens, string fullQuery, TextChunk chunk)
    {
        double score = 0.0;
        var chunkLower = chunk.Text.ToLowerInvariant();
        var queryLower = fullQuery.ToLowerInvariant();

        // 1. Keyword match in chunk text
        foreach (var token in queryTokens)
        {
            if (chunkLower.Contains(token))
                score += 1.0;
        }

        // 2. Category intent boost
        if (CategoryKeywords.TryGetValue(chunk.Category, out var keywords))
        {
            foreach (var kw in keywords)
            {
                if (queryLower.Contains(kw))
                    score += 2.0;
            }
        }

        // 3. Exact destination match boost
        if (queryLower.Contains(chunk.Destination.ToLowerInvariant()))
        {
            score += 3.0;
        }

        return score;
    }

    private static List<string> Tokenize(string text)
    {
        return text
            .ToLowerInvariant()
            .Split([' ', ',', '.', '?', '!', ':', ';', '-', '(', ')', '"', '\''], StringSplitOptions.RemoveEmptyEntries)
            .Where(word => word.Length > 2 && !StopWords.Contains(word))
            .Distinct()
            .ToList();
    }
}
