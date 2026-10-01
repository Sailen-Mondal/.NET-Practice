using OllamaSharp;
using TravelAgentRAG.Data;
using TravelAgentRAG.Rag;

// ============================================
//  AI Travel Agent — RAG Demo (Indian Cities)
//  Uses: Ollama (qwen2.5-coder:3b) + Keyword-based Retrieval
// ============================================

Console.ForegroundColor = ConsoleColor.Cyan;
Console.WriteLine("============================================");
Console.WriteLine("   Desi Yatra — AI Travel Agent (RAG Demo)  ");
Console.WriteLine("============================================");
Console.ResetColor();
Console.WriteLine();

// ---- STEP 1: Load the knowledge base ----
var destinations = TravelDataStore.GetDestinations();
var chunks = TextChunker.ChunkDestinations(destinations);
Console.WriteLine($"  Loaded {destinations.Count} destinations -> {chunks.Count} text chunks");

// ---- STEP 2: Build the search index ----
var ollama = new OllamaApiClient(new Uri("http://localhost:11434"));
var engine = new RagEngine(ollama);

engine.Index(chunks);
Console.WriteLine("  Search index built!");
Console.WriteLine();

// Show available destinations
Console.ForegroundColor = ConsoleColor.DarkGray;
Console.WriteLine("  Destinations: " + string.Join(", ", destinations.Select(d => d.Name)));
Console.WriteLine("  Ask me anything about traveling in India!");
Console.WriteLine("  Type 'exit' to quit.");
Console.ResetColor();
Console.WriteLine();

// Check for automated test mode
if (args.Contains("--test", StringComparer.OrdinalIgnoreCase))
{
    Console.WriteLine("Running automated 3-turn integration test...\n");
    
    var testQuestions = new[]
    {
        "I want to travel to Kolkata",
        "Budget is 2000 INR per day, 3 days, with 2 friends",
        "What sweets are famous there?"
    };

    foreach (var q in testQuestions)
    {
        Console.ForegroundColor = ConsoleColor.Yellow;
        Console.WriteLine($"You: {q}");
        Console.ResetColor();
        Console.WriteLine();
        
        Console.ForegroundColor = ConsoleColor.Green;
        Console.Write("Desi Yatra: ");
        await foreach (var token in engine.AskAsync(q))
        {
            Console.Write(token);
        }
        Console.ResetColor();
        Console.WriteLine("\n\n");
    }

    Console.WriteLine("Automated test completed successfully!");
    return;
}

// ---- STEP 3: Interactive Q&A loop ----
while (true)
{
    Console.ForegroundColor = ConsoleColor.Yellow;
    Console.Write("You: ");
    Console.ResetColor();

    var question = Console.ReadLine();

    if (string.IsNullOrWhiteSpace(question) || question.Equals("exit", StringComparison.OrdinalIgnoreCase))
        break;

    Console.WriteLine();
    Console.ForegroundColor = ConsoleColor.Green;
    Console.Write("Desi Yatra: ");

    try
    {
        await foreach (var token in engine.AskAsync(question))
        {
            Console.Write(token);
        }
    }
    catch (HttpRequestException)
    {
        Console.ForegroundColor = ConsoleColor.Red;
        Console.Write("Error: Could not connect to Ollama. Make sure it's running on http://localhost:11434");
    }

    Console.ResetColor();
    Console.WriteLine();
    Console.WriteLine();
}

Console.WriteLine("Alvida! Happy travels!");
