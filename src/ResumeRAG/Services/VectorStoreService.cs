using System.Numerics.Tensors;
using System.Text.Json;
using ResumeRAG.Models;

namespace ResumeRAG.Services;

/// <summary>
/// Manages the JSON-based vector store: serialization, deserialization, and cosine similarity search.
/// 
/// The vector store is a simple JSON file containing an array of ChunkEmbedding objects.
/// Each object holds the chunk text, metadata, and its float[] embedding vector.
/// 
/// Search uses TensorPrimitives.CosineSimilarity() which is hardware-accelerated (SIMD/AVX)
/// for high-performance similarity computation even on large stores.
/// </summary>
public static class VectorStoreService
{
    private static readonly JsonSerializerOptions JsonOptions = new()
    {
        WriteIndented = true
    };

    /// <summary>
    /// Saves the embedding collection to a JSON file.
    /// </summary>
    public static async Task SaveAsync(string path, List<ChunkEmbedding> embeddings)
    {
        // Ensure directory exists
        var directory = Path.GetDirectoryName(path);
        if (!string.IsNullOrEmpty(directory))
            Directory.CreateDirectory(directory);

        var json = JsonSerializer.Serialize(embeddings, JsonOptions);
        await File.WriteAllTextAsync(path, json);
    }

    /// <summary>
    /// Loads the embedding collection from a JSON file.
    /// Returns an empty list if the file doesn't exist.
    /// </summary>
    public static async Task<List<ChunkEmbedding>> LoadAsync(string path)
    {
        if (!File.Exists(path))
            return [];

        var json = await File.ReadAllTextAsync(path);
        return JsonSerializer.Deserialize<List<ChunkEmbedding>>(json) ?? [];
    }

    /// <summary>
    /// Performs cosine similarity search: compares the query embedding against all stored embeddings
    /// and returns the top-K most similar chunks, ranked by score.
    /// 
    /// Cosine Similarity formula:
    ///   similarity(A, B) = (A · B) / (|A| × |B|)
    /// 
    /// Score interpretation:
    ///   1.0  = identical vectors (perfect match)
    ///   0.0  = orthogonal vectors (unrelated)
    ///  -1.0  = opposite vectors
    /// </summary>
    /// <param name="store">All stored chunk embeddings to search through.</param>
    /// <param name="queryEmbedding">The vector representation of the user's query.</param>
    /// <param name="topK">Number of top results to return (default: 5).</param>
    /// <returns>Ranked list of SearchResult objects with similarity scores.</returns>
    public static List<SearchResult> Search(
        List<ChunkEmbedding> store, float[] queryEmbedding, int topK = 5)
    {
        if (store.Count == 0)
            return [];

        return store
            .Select(chunk => new SearchResult
            {
                Chunk = chunk,
                SimilarityScore = TensorPrimitives.CosineSimilarity(
                    chunk.Embedding.AsSpan(), queryEmbedding.AsSpan())
            })
            .OrderByDescending(r => r.SimilarityScore)
            .Take(topK)
            .ToList();
    }

    /// <summary>
    /// Gets summary statistics about the vector store.
    /// </summary>
    public static (int TotalChunks, int UniqueFiles, int EmbeddingDimension) GetStats(
        List<ChunkEmbedding> store)
    {
        if (store.Count == 0)
            return (0, 0, 0);

        return (
            store.Count,
            store.Select(e => e.SourceFile).Distinct().Count(),
            store[0].Embedding.Length
        );
    }
}
