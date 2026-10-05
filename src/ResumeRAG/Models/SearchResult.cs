namespace ResumeRAG.Models;

/// <summary>
/// Represents a single search result: a chunk and its cosine similarity score to the query.
/// </summary>
public class SearchResult
{
    /// <summary>The matched chunk embedding with its text and metadata.</summary>
    public ChunkEmbedding Chunk { get; set; } = null!;

    /// <summary>
    /// Cosine similarity score between the query and this chunk.
    /// Range: -1.0 (opposite) to 1.0 (identical). Higher is more relevant.
    /// </summary>
    public float SimilarityScore { get; set; }
}
