using System.Net.Http.Json;
using System.Text.Json.Serialization;

namespace ResumeRAG.Services;

/// <summary>
/// Generates vector embeddings by calling the local Ollama REST API.
/// Uses the /api/embed endpoint with the nomic-embed-text model (768 dimensions).
/// </summary>
public class EmbeddingService : IDisposable
{
    private readonly HttpClient _httpClient;
    private readonly string _model;

    public EmbeddingService(string ollamaUrl = "http://localhost:11434",
        string model = "nomic-embed-text")
    {
        _httpClient = new HttpClient
        {
            BaseAddress = new Uri(ollamaUrl),
            Timeout = TimeSpan.FromSeconds(120)
        };
        _model = model;
    }

    /// <summary>
    /// Generates a vector embedding for a single text input.
    /// </summary>
    /// <param name="text">The text to embed.</param>
    /// <returns>A float array representing the embedding vector (768 dimensions for nomic-embed-text).</returns>
    public async Task<float[]> GenerateEmbeddingAsync(string text)
    {
        var request = new OllamaEmbedRequest
        {
            Model = _model,
            Input = text
        };

        var response = await _httpClient.PostAsJsonAsync("/api/embed", request);
        response.EnsureSuccessStatusCode();

        var result = await response.Content.ReadFromJsonAsync<OllamaEmbedResponse>();

        if (result?.Embeddings is null || result.Embeddings.Length == 0)
            throw new InvalidOperationException("Ollama returned no embeddings. Is the model loaded?");

        return result.Embeddings[0];
    }

    /// <summary>
    /// Checks whether the Ollama server is reachable and the embedding model is available.
    /// </summary>
    public async Task<(bool IsReachable, bool ModelExists)> CheckHealthAsync()
    {
        try
        {
            var response = await _httpClient.GetAsync("/api/tags");
            if (!response.IsSuccessStatusCode)
                return (false, false);

            var tagsResult = await response.Content.ReadFromJsonAsync<OllamaTagsResponse>();
            bool modelExists = tagsResult?.Models?.Any(m =>
                m.Name?.StartsWith(_model, StringComparison.OrdinalIgnoreCase) == true) ?? false;

            return (true, modelExists);
        }
        catch
        {
            return (false, false);
        }
    }

    public void Dispose() => _httpClient.Dispose();
}

// ── Ollama API request/response models ──

internal class OllamaEmbedRequest
{
    [JsonPropertyName("model")]
    public string Model { get; set; } = "";

    [JsonPropertyName("input")]
    public string Input { get; set; } = "";
}

internal class OllamaEmbedResponse
{
    [JsonPropertyName("embeddings")]
    public float[][]? Embeddings { get; set; }
}

internal class OllamaTagsResponse
{
    [JsonPropertyName("models")]
    public OllamaModelInfo[]? Models { get; set; }
}

internal class OllamaModelInfo
{
    [JsonPropertyName("name")]
    public string? Name { get; set; }
}
