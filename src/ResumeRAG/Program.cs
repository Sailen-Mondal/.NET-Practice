using System.Text;
using ResumeRAG.Models;
using ResumeRAG.Services;
using Spectre.Console;

Console.OutputEncoding = Encoding.UTF8;

const int ChunkSize = 500;
const int Overlap = 100;
const int TopK = 5;

string baseDir = AppContext.BaseDirectory;
string projectRoot = FindProjectRoot(baseDir);
string resumesDir = Path.Combine(projectRoot, "Data", "Resumes");
string vectorStorePath = Path.Combine(projectRoot, "Data", "vector_store.json");

// ── Application Banner ──
ConsoleUIService.ShowBanner();

// ═══════════════════════════════════════════════════════════════
// STAGE 0: Pre-flight checks
// ═══════════════════════════════════════════════════════════════
ConsoleUIService.ShowStageHeader("Pre-flight Checks", 0);

Directory.CreateDirectory(resumesDir);

ConsoleUIService.ShowInfo("Checking Ollama server connectivity...");

using var embeddingService = new EmbeddingService();
using var llmService = new LlmService();
var (isReachable, modelExists) = await embeddingService.CheckHealthAsync();

if (!isReachable)
{
    ConsoleUIService.ShowError("Cannot connect to Ollama at http://localhost:11434");
    ConsoleUIService.ShowError("Please start Ollama and try again.");
    ConsoleUIService.ShowInfo("Run: ollama serve");
    return;
}
ConsoleUIService.ShowSuccess("Ollama server is reachable.");

if (!modelExists)
{
    ConsoleUIService.ShowError("Embedding model 'nomic-embed-text' not found.");
    ConsoleUIService.ShowInfo("Run: ollama pull nomic-embed-text");
    return;
}
ConsoleUIService.ShowSuccess("Embedding model 'nomic-embed-text' is available.");

bool llmExists = await llmService.IsModelAvailableAsync();
if (!llmExists)
{
    ConsoleUIService.ShowWarning("LLM model 'qwen2.5-coder:3b' not found in Ollama.");
    ConsoleUIService.ShowInfo("Run: ollama pull qwen2.5-coder:3b for answer generation.");
}
else
{
    ConsoleUIService.ShowSuccess("LLM model 'qwen2.5-coder:3b' is ready for generation.");
}

// ═══════════════════════════════════════════════════════════════
// STAGE 1: Discover & Parse PDFs
// ═══════════════════════════════════════════════════════════════
ConsoleUIService.ShowStageHeader("PDF Discovery & Parsing", 1);

var pdfFiles = Directory.GetFiles(resumesDir, "*.pdf", SearchOption.TopDirectoryOnly);

if (pdfFiles.Length == 0)
{
    ConsoleUIService.ShowWarning($"No PDF files found in: {resumesDir}");
    ConsoleUIService.ShowInfo("Place your resume PDFs in the directory above and run again.");

    var existingStore = await VectorStoreService.LoadAsync(vectorStorePath);
    if (existingStore.Count > 0)
    {
        await RunQueryLoop(embeddingService, llmService, existingStore, vectorStorePath, showSummary: true);
    }
    return;
}

var fileInfos = new List<(string FileName, int Pages, long SizeKB)>();
foreach (var pdfFile in pdfFiles)
{
    var fileInfo = new FileInfo(pdfFile);
    int pages = PdfParserService.GetPageCount(pdfFile);
    fileInfos.Add((fileInfo.Name, pages, fileInfo.Length / 1024));
}
ConsoleUIService.ShowPdfTable(fileInfos);

var extractedTexts = new Dictionary<string, string>();

await AnsiConsole.Progress()
    .AutoClear(false)
    .HideCompleted(false)
    .Columns(
        new SpinnerColumn(),
        new TaskDescriptionColumn { Alignment = Justify.Left },
        new ProgressBarColumn(),
        new PercentageColumn(),
        new ElapsedTimeColumn())
    .StartAsync(async ctx =>
    {
        var task = ctx.AddTask("Extracting text from PDFs...", maxValue: pdfFiles.Length);

        foreach (var pdfFile in pdfFiles)
        {
            string fileName = Path.GetFileName(pdfFile);
            task.Description = $"Parsing: {Markup.Escape(fileName)}";

            string text = PdfParserService.ExtractText(pdfFile);
            extractedTexts[pdfFile] = text;

            task.Increment(1);
            await Task.Delay(50);
        }

        task.Description = $"Parsed {pdfFiles.Length} PDF document(s)";
    });

AnsiConsole.WriteLine();
foreach (var (filePath, text) in extractedTexts)
{
    string fileName = Path.GetFileName(filePath);
    ConsoleUIService.ShowSuccess($"{fileName} -> {text.Length:N0} characters extracted");
}

// ═══════════════════════════════════════════════════════════════
// STAGE 2: Text Chunking
// ═══════════════════════════════════════════════════════════════
ConsoleUIService.ShowStageHeader("Text Chunking (Sliding Window)", 2);

ConsoleUIService.ShowPanel("Chunking Configuration",
    $"[#8E8E93]Strategy:[/]     [#F5F5F7]Fixed-size Sliding Window[/]\n" +
    $"[#8E8E93]Chunk Size:[/]   [#F5F5F7]{ChunkSize}[/] characters\n" +
    $"[#8E8E93]Overlap:[/]      [#F5F5F7]{Overlap}[/] characters (20%)\n" +
    $"[#8E8E93]Stride:[/]       [#F5F5F7]{ChunkSize - Overlap}[/] characters");

AnsiConsole.WriteLine();

var allChunks = new List<TextChunk>();

foreach (var (filePath, text) in extractedTexts)
{
    string fileName = Path.GetFileName(filePath);
    var chunks = TextChunkerService.Chunk(text, filePath, ChunkSize, Overlap);
    allChunks.AddRange(chunks);

    ConsoleUIService.ShowChunkingSummary(fileName, chunks.Count, ChunkSize, Overlap);
    ConsoleUIService.ShowChunkPreview(chunks);
}

ConsoleUIService.ShowSuccess($"Total chunks across all documents: {allChunks.Count}");

// ═══════════════════════════════════════════════════════════════
// STAGE 3: Generate Embeddings
// ═══════════════════════════════════════════════════════════════
ConsoleUIService.ShowStageHeader("Embedding Generation (Ollama)", 3);

ConsoleUIService.ShowInfo("Model: nomic-embed-text (768 dimensions)");
ConsoleUIService.ShowInfo($"Generating embeddings for {allChunks.Count} chunks...");
AnsiConsole.WriteLine();

var embeddings = new List<ChunkEmbedding>();

await AnsiConsole.Progress()
    .AutoClear(false)
    .HideCompleted(false)
    .Columns(
        new SpinnerColumn(),
        new TaskDescriptionColumn { Alignment = Justify.Left },
        new ProgressBarColumn(),
        new PercentageColumn(),
        new RemainingTimeColumn(),
        new ElapsedTimeColumn())
    .StartAsync(async ctx =>
    {
        var task = ctx.AddTask("Embedding chunks...", maxValue: allChunks.Count);

        for (int i = 0; i < allChunks.Count; i++)
        {
            var chunk = allChunks[i];
            task.Description = $"Embedding chunk {i + 1}/{allChunks.Count}: {Markup.Escape(chunk.Id)}";

            try
            {
                var embedding = await embeddingService.GenerateEmbeddingAsync(chunk.Text);

                embeddings.Add(new ChunkEmbedding
                {
                    ChunkId = chunk.Id,
                    Text = chunk.Text,
                    SourceFile = chunk.SourceFile,
                    ChunkIndex = chunk.ChunkIndex,
                    Embedding = embedding
                });
            }
            catch (Exception ex)
            {
                ConsoleUIService.ShowError($"Failed to embed chunk {chunk.Id}: {ex.Message}");
            }

            task.Increment(1);
        }

        task.Description = $"Generated {embeddings.Count} embeddings";
    });

// ═══════════════════════════════════════════════════════════════
// STAGE 4: Save to Vector Store
// ═══════════════════════════════════════════════════════════════
ConsoleUIService.ShowStageHeader("Vector Store Persistence", 4);

var existingEmbeddings = await VectorStoreService.LoadAsync(vectorStorePath);
if (existingEmbeddings.Count > 0)
{
    ConsoleUIService.ShowInfo($"Found existing store with {existingEmbeddings.Count} chunks.");

    var processedFiles = extractedTexts.Keys
        .Select(Path.GetFileName)
        .ToHashSet(StringComparer.OrdinalIgnoreCase);

    existingEmbeddings.RemoveAll(e =>
        processedFiles.Contains(e.SourceFile));

    ConsoleUIService.ShowInfo("Removed stale entries for re-processed files.");
}

existingEmbeddings.AddRange(embeddings);
await VectorStoreService.SaveAsync(vectorStorePath, existingEmbeddings);

var (totalChunks, uniqueFiles, embeddingDim) = VectorStoreService.GetStats(existingEmbeddings);
ConsoleUIService.ShowVectorStoreStats(totalChunks, uniqueFiles, embeddingDim, vectorStorePath);
ConsoleUIService.ShowSuccess($"Vector store saved to {vectorStorePath}");

// ═══════════════════════════════════════════════════════════════
// STAGE 5: Interactive Query Loop
// ═══════════════════════════════════════════════════════════════
await RunQueryLoop(embeddingService, llmService, existingEmbeddings, vectorStorePath, showSummary: false);

// ── Helper Methods ──

static async Task RunQueryLoop(EmbeddingService embeddingService, LlmService llmService,
    List<ChunkEmbedding> store, string storePath, bool showSummary = false)
{
    ConsoleUIService.ShowStageHeader("Interactive Search", 5);

    if (showSummary)
    {
        var (totalChunks, uniqueFiles, embeddingDim) = VectorStoreService.GetStats(store);
        ConsoleUIService.ShowVectorStoreStats(totalChunks, uniqueFiles, embeddingDim, storePath);
    }

    ConsoleUIService.ShowInfo("Type your query and press Enter. Type 'exit' to quit.");
    ConsoleUIService.ShowInfo($"Top {TopK} results will be shown for each query.");

    while (true)
    {
        string query = ConsoleUIService.PromptQuery();

        if (string.Equals(query.Trim(), "exit", StringComparison.OrdinalIgnoreCase))
        {
            ConsoleUIService.ShowGoodbye();
            break;
        }

        if (string.IsNullOrWhiteSpace(query))
        {
            ConsoleUIService.ShowWarning("Empty query. Please enter a search term.");
            continue;
        }

        float[] queryEmbedding;
        try
        {
            queryEmbedding = await AnsiConsole.Status()
                .Spinner(Spinner.Known.Dots)
                .SpinnerStyle(new Style(Color.FromHex("#5B8DEF")))
                .StartAsync("Embedding your query...", async _ =>
                {
                    return await embeddingService.GenerateEmbeddingAsync(query);
                });
        }
        catch (Exception ex)
        {
            ConsoleUIService.ShowError($"Failed to embed query: {ex.Message}");
            continue;
        }

        var results = VectorStoreService.Search(store, queryEmbedding, TopK);

        ConsoleUIService.ShowSearchResults(results, query);

        if (results.Count > 0)
        {
            ConsoleUIService.ShowLlmResponseHeader();
            try
            {
                await llmService.GenerateResponseAsync(query, results, onToken: ConsoleUIService.WriteStreamToken);
                ConsoleUIService.ShowLlmResponseComplete();
            }
            catch (Exception ex)
            {
                ConsoleUIService.ShowLlmError(ex.Message);
            }
        }
    }
}

static string FindProjectRoot(string startDir)
{
    var dir = new DirectoryInfo(startDir);
    while (dir != null)
    {
        if (dir.GetFiles("*.csproj").Length > 0)
            return dir.FullName;
        dir = dir.Parent;
    }
    return startDir;
}
