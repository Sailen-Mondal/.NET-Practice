using System.Net.Http.Json;
using System.Text;
using System.Text.Json;
using System.Text.Json.Serialization;
using ResumeRAG.Models;

namespace ResumeRAG.Services;

/// <summary>
/// Generates natural language responses using a local Ollama LLM.
/// Takes retrieved chunks as context and the user's query to produce a grounded answer.
/// This is the "G" (Generation) in RAG.
/// </summary>
public class LlmService : IDisposable
{
    private readonly HttpClient _httpClient;
    private readonly string _model;

    public LlmService(string ollamaUrl = "http://localhost:11434",
        string model = "qwen2.5-coder:3b")
    {
        _httpClient = new HttpClient
        {
            BaseAddress = new Uri(ollamaUrl),
            Timeout = TimeSpan.FromMinutes(3)
        };
        _model = model;
    }

    /// <summary>
    /// Generates a response by sending the user's query along with retrieved context chunks
    /// to the LLM. Streams the response token-by-token for a real-time typing effect.
    /// </summary>
    /// <param name="query">The user's original question.</param>
    /// <param name="results">Top-K search results containing relevant resume chunks.</param>
    /// <param name="onToken">Callback invoked for each streamed token (for live display).</param>
    /// <returns>The complete generated response.</returns>
    public async Task<string> GenerateResponseAsync(string query, List<SearchResult> results,
        Action<string>? onToken = null)
    {
        // Build the context from retrieved chunks
        var contextBuilder = new StringBuilder();
        for (int i = 0; i < results.Count; i++)
        {
            var r = results[i];
            contextBuilder.AppendLine($"[Document: {r.Chunk.SourceFile} | Chunk #{r.Chunk.ChunkIndex} | Score: {r.SimilarityScore:F4}]");
            contextBuilder.AppendLine(r.Chunk.Text);
            contextBuilder.AppendLine();
        }

        string systemPrompt = """
            You are a helpful assistant that answers questions about candidates based on their resume data.
            You will be given relevant excerpts from one or more resumes as context.
            
            Rules:
            - Answer ONLY based on the provided context. Do not make up information.
            - If the context doesn't contain enough information to answer, say so clearly.
            - Be concise but thorough. Use bullet points when listing multiple items.
            - When citing sources, use the document name and actual chunk number (e.g., "Chunk #7 in Sailen_Mondal_Resume.pdf").
            - If asked about skills, experience, or projects, organize your answer clearly.
            """;

        string userPrompt = $"""
            CONTEXT (Retrieved Resume Chunks):
            {contextBuilder}
            
            QUESTION: {query}
            
            Please provide a clear, well-structured answer based on the context above.
            """;

        var request = new OllamaChatRequest
        {
            Model = _model,
            Messages =
            [
                new OllamaChatMessage { Role = "system", Content = systemPrompt },
                new OllamaChatMessage { Role = "user", Content = userPrompt }
            ],
            Stream = true
        };

        var jsonContent = JsonSerializer.Serialize(request);
        var httpContent = new StringContent(jsonContent, Encoding.UTF8, "application/json");

        using var response = await _httpClient.SendAsync(
            new HttpRequestMessage(HttpMethod.Post, "/api/chat") { Content = httpContent },
            HttpCompletionOption.ResponseHeadersRead);

        response.EnsureSuccessStatusCode();

        var fullResponse = new StringBuilder();

        using var stream = await response.Content.ReadAsStreamAsync();
        using var reader = new StreamReader(stream);

        while (await reader.ReadLineAsync() is { } line)
        {
            if (string.IsNullOrWhiteSpace(line)) continue;

            try
            {
                var chunk = JsonSerializer.Deserialize<OllamaChatStreamResponse>(line);
                if (chunk?.Message?.Content is { } token)
                {
                    fullResponse.Append(token);
                    onToken?.Invoke(token);
                }

                if (chunk?.Done == true) break;
            }
            catch (JsonException)
            {
                // Skip malformed chunks
            }
        }

        return fullResponse.ToString();
    }

    /// <summary>
    /// Checks if the generation model is available on the Ollama server.
    /// </summary>
    public async Task<bool> IsModelAvailableAsync()
    {
        try
        {
            var response = await _httpClient.GetAsync("/api/tags");
            if (!response.IsSuccessStatusCode) return false;

            var tagsResult = await response.Content.ReadFromJsonAsync<OllamaTagsResponse>();
            return tagsResult?.Models?.Any(m =>
                m.Name?.StartsWith(_model, StringComparison.OrdinalIgnoreCase) == true) ?? false;
        }
        catch
        {
            return false;
        }
    }

    public void Dispose() => _httpClient.Dispose();
}

// ── Ollama Chat API models ──

internal class OllamaChatRequest
{
    [JsonPropertyName("model")]
    public string Model { get; set; } = "";

    [JsonPropertyName("messages")]
    public List<OllamaChatMessage> Messages { get; set; } = [];

    [JsonPropertyName("stream")]
    public bool Stream { get; set; } = true;
}

internal class OllamaChatMessage
{
    [JsonPropertyName("role")]
    public string Role { get; set; } = "";

    [JsonPropertyName("content")]
    public string Content { get; set; } = "";
}

internal class OllamaChatStreamResponse
{
    [JsonPropertyName("message")]
    public OllamaChatMessage? Message { get; set; }

    [JsonPropertyName("done")]
    public bool Done { get; set; }
}
