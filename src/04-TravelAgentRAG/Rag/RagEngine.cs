using OllamaSharp;

namespace TravelAgentRAG.Rag;

/// <summary>
/// Orchestrates the full RAG (Retrieval-Augmented Generation) pipeline.
/// 
/// The RAG flow:
///   1. RETRIEVE: Find relevant text chunks from the knowledge base
///   2. AUGMENT:  Build a prompt that includes the retrieved context
///   3. GENERATE: Send the augmented prompt to the LLM for a grounded answer
/// 
/// Manages conversation state and active destination across multi-turn chats.
/// </summary>
public class RagEngine
{
    private readonly OllamaApiClient _ollama;
    private readonly KeywordSearcher _searcher;
    private readonly Chat _chat;
    private string? _activeDestination;
    private const string ChatModel = "qwen2.5-coder:3b";
    private const string AgentFile = "Agent.md";

    private static readonly string[] KnownDestinations =
    [
        "Jaipur", "Goa", "Manali", "Varanasi", "Munnar", "Udaipur", "Rishikesh", "Darjeeling", "Kolkata"
    ];

    public RagEngine(OllamaApiClient ollama)
    {
        _ollama = ollama;
        _ollama.SelectedModel = ChatModel;
        _searcher = new KeywordSearcher();

        var systemPrompt = LoadAgentPrompt();
        _chat = new Chat(_ollama, systemPrompt);
    }

    private static string LoadAgentPrompt()
    {
        var paths = new[]
        {
            Path.Combine(AppContext.BaseDirectory, AgentFile),
            Path.Combine(Directory.GetCurrentDirectory(), AgentFile)
        };

        foreach (var path in paths)
        {
            if (File.Exists(path))
            {
                var content = File.ReadAllText(path);
                Console.WriteLine($"  Agent instructions loaded from: {Path.GetFileName(path)}");
                return content;
            }
        }

        Console.ForegroundColor = ConsoleColor.DarkYellow;
        Console.WriteLine("  Warning: Agent.md not found, using default prompt.");
        Console.ResetColor();

        return "You are a friendly Indian travel agent AI. Answer questions based on the provided context only.";
    }

    public void Index(List<TextChunk> chunks)
    {
        _searcher.AddChunks(chunks);
    }

    /// <summary>
    /// The main RAG pipeline: Retrieve → Augment → Generate.
    /// Returns an async stream of tokens for real-time console output.
    /// </summary>
    public async IAsyncEnumerable<string> AskAsync(string question)
    {
        // Detect if the user mentioned a new destination
        foreach (var dest in KnownDestinations)
        {
            if (question.Contains(dest, StringComparison.OrdinalIgnoreCase))
            {
                _activeDestination = dest;
                break;
            }
        }

        // ---- STEP 1: RETRIEVE ----
        var relevantChunks = _searcher.Search(question, _activeDestination, topK: 4);

        string context;
        if (relevantChunks.Count == 0)
        {
            context = "No relevant information found in the knowledge base.";
        }
        else
        {
            context = string.Join("\n\n", relevantChunks.Select((chunk, i) => $"[Source {i + 1}]: {chunk}"));
        }

        // ---- STEP 2: AUGMENT ----
        var augmentedMessage = $"""
            [RETRIEVED KNOWLEDGE BASE CONTEXT]:
            {context}

            [USER MESSAGE]: {question}
            """;

        // ---- STEP 3: GENERATE ----
        await foreach (var token in _chat.SendAsync(augmentedMessage))
        {
            if (token is not null)
                yield return token;
        }
    }
}
