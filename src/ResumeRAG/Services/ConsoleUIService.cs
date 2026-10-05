using ResumeRAG.Models;
using Spectre.Console;

namespace ResumeRAG.Services;

/// <summary>
/// Apple-inspired, mature, and comprehensive console UI service using Spectre.Console.
/// Features full pipeline visibility (tables, chunk previews, progress tracking, summary panels)
/// rendered in an understated, executive color scheme without neon colors or emojis.
/// </summary>
public static class ConsoleUIService
{
    // ── Curated Apple-Inspired Palette (No Neon) ──
    private const string Primary = "#F5F5F7";     // Crisp off-white
    private const string Accent = "#5B8DEF";      // Subdued Apple system slate blue
    private const string Secondary = "#8E8E93";   // Apple neutral grey
    private const string Muted = "#636366";       // Apple dark grey
    private const string Border = "#3A3A3C";      // Subtle dark separator grey
    private const string Success = "#4E9A68";     // Muted sage green
    private const string Warning = "#D4A373";     // Warm sand/amber
    private const string Error = "#D9534F";       // Subdued rose

    private static readonly Color BorderColor = Color.FromHex(Border);
    private static readonly Color AccentColor = Color.FromHex(Accent);

    /// <summary>
    /// Displays the application title banner in refined slate typography.
    /// </summary>
    public static void ShowBanner()
    {
        AnsiConsole.WriteLine();
        AnsiConsole.Write(
            new FigletText("ResumeRAG")
                .Centered()
                .Color(AccentColor));

        AnsiConsole.Write(
            new Text("--- Local Retrieval-Augmented Generation Engine ---",
                new Style(Color.FromHex(Secondary)))
                .Centered());
        AnsiConsole.WriteLine();
        AnsiConsole.WriteLine();
    }

    /// <summary>
    /// Displays a clean stage header with stage number and rule divider (no emoji).
    /// </summary>
    public static void ShowStageHeader(string title, int stageNumber)
    {
        AnsiConsole.WriteLine();
        AnsiConsole.Write(
            new Rule($"[bold {Primary}]Stage {stageNumber}: {Markup.Escape(title)}[/]")
                .RuleStyle(Border)
                .LeftJustified());
        AnsiConsole.WriteLine();
    }

    /// <summary>
    /// Standardized status output lines with clean text tags.
    /// </summary>
    public static void ShowSuccess(string message) =>
        AnsiConsole.MarkupLine($"  [bold {Success}][[OK]][/] [{Primary}]{Markup.Escape(message)}[/]");

    public static void ShowWarning(string message) =>
        AnsiConsole.MarkupLine($"  [bold {Warning}][[WARN]][/] [{Warning}]{Markup.Escape(message)}[/]");

    public static void ShowError(string message) =>
        AnsiConsole.MarkupLine($"  [bold {Error}][[ERR]][/] [{Error}]{Markup.Escape(message)}[/]");

    public static void ShowInfo(string message) =>
        AnsiConsole.MarkupLine($"  [bold {Accent}][[INFO]][/] [{Secondary}]{Markup.Escape(message)}[/]");

    /// <summary>
    /// Displays a framed configuration panel.
    /// </summary>
    public static void ShowPanel(string title, string content)
    {
        var panel = new Panel(content)
            .Header($" [bold {Primary}]{Markup.Escape(title)}[/] ")
            .HeaderAlignment(Justify.Left)
            .Border(BoxBorder.Rounded)
            .BorderColor(BorderColor)
            .Padding(1, 0);

        AnsiConsole.Write(panel);
    }

    /// <summary>
    /// Displays the table of discovered PDF files.
    /// </summary>
    public static void ShowPdfTable(List<(string FileName, int Pages, long SizeKB)> files)
    {
        var table = new Table()
            .Border(TableBorder.Rounded)
            .BorderColor(BorderColor)
            .Title($"[{Secondary}]Discovered PDF Documents[/]");

        table.AddColumn(new TableColumn($"[{Secondary}]#[/]").Centered().Width(4));
        table.AddColumn(new TableColumn($"[{Secondary}]File Name[/]").LeftAligned());
        table.AddColumn(new TableColumn($"[{Secondary}]Pages[/]").Centered().Width(8));
        table.AddColumn(new TableColumn($"[{Secondary}]Size[/]").RightAligned().Width(12));

        for (int i = 0; i < files.Count; i++)
        {
            var (fileName, pages, sizeKB) = files[i];
            table.AddRow(
                $"[{Muted}]{i + 1}[/]",
                $"[bold {Primary}]{Markup.Escape(fileName)}[/]",
                $"[{Secondary}]{pages}[/]",
                $"[{Secondary}]{sizeKB} KB[/]"
            );
        }

        AnsiConsole.Write(table);
        AnsiConsole.WriteLine();
    }

    /// <summary>
    /// Displays a summary grid of chunking parameters for a file.
    /// </summary>
    public static void ShowChunkingSummary(string fileName, int totalChunks, int chunkSize, int overlap)
    {
        var grid = new Grid();
        grid.AddColumn(new GridColumn().NoWrap().PadRight(3));
        grid.AddColumn(new GridColumn());

        grid.AddRow($"[{Secondary}]Target Document:[/]", $"[bold {Primary}]{Markup.Escape(fileName)}[/]");
        grid.AddRow($"[{Secondary}]Chunks Generated:[/]", $"[bold {Success}]{totalChunks}[/]");
        grid.AddRow($"[{Secondary}]Chunk Size:[/]", $"[{Secondary}]{chunkSize} characters[/]");
        grid.AddRow($"[{Secondary}]Window Overlap:[/]", $"[{Secondary}]{overlap} characters ({Math.Round((double)overlap / chunkSize * 100)}%)[/]");
        grid.AddRow($"[{Secondary}]Window Stride:[/]", $"[{Secondary}]{chunkSize - overlap} characters[/]");

        AnsiConsole.Write(grid);
        AnsiConsole.WriteLine();
    }

    /// <summary>
    /// Displays a detailed preview table of generated text chunks.
    /// </summary>
    public static void ShowChunkPreview(List<TextChunk> chunks, int maxPreviewLength = 100)
    {
        var table = new Table()
            .Border(TableBorder.Rounded)
            .BorderColor(BorderColor)
            .Title($"[{Secondary}]Chunk Preview (first 5 of {chunks.Count})[/]")
            .Expand();

        table.AddColumn(new TableColumn($"[{Secondary}]#[/]").Centered().Width(5));
        table.AddColumn(new TableColumn($"[{Secondary}]Char Range[/]").Centered().Width(14));
        table.AddColumn(new TableColumn($"[{Secondary}]Length[/]").Centered().Width(8));
        table.AddColumn(new TableColumn($"[{Secondary}]Content Preview[/]").LeftAligned());

        int previewCount = Math.Min(chunks.Count, 5);
        for (int i = 0; i < previewCount; i++)
        {
            var chunk = chunks[i];
            string preview = chunk.Text.Length > maxPreviewLength
                ? chunk.Text[..maxPreviewLength] + "..."
                : chunk.Text;

            table.AddRow(
                $"[{Accent}]{chunk.ChunkIndex}[/]",
                $"[{Muted}]{chunk.StartPosition}-{chunk.EndPosition}[/]",
                $"[{Secondary}]{chunk.Text.Length}[/]",
                $"[{Primary}]{Markup.Escape(preview)}[/]"
            );
        }

        if (chunks.Count > previewCount)
        {
            table.AddRow(
                $"[{Muted}]...[/]",
                $"[{Muted}]...[/]",
                $"[{Muted}]...[/]",
                $"[{Muted}]({chunks.Count - previewCount} more chunks not shown)[/]"
            );
        }

        AnsiConsole.Write(table);
        AnsiConsole.WriteLine();
    }

    /// <summary>
    /// Displays the vector store summary panel.
    /// </summary>
    public static void ShowVectorStoreStats(int totalChunks, int uniqueFiles, int dimensions, string storePath)
    {
        var grid = new Grid();
        grid.AddColumn(new GridColumn().NoWrap().PadRight(3));
        grid.AddColumn(new GridColumn());

        grid.AddRow($"[{Secondary}]Total Chunks:[/]", $"[bold {Success}]{totalChunks}[/]");
        grid.AddRow($"[{Secondary}]Source Documents:[/]", $"[bold {Primary}]{uniqueFiles}[/]");
        grid.AddRow($"[{Secondary}]Vector Dimension:[/]", $"[{Secondary}]{dimensions} (float32)[/]");
        grid.AddRow($"[{Secondary}]Store File:[/]", $"[{Muted}]{Markup.Escape(storePath)}[/]");

        var panel = new Panel(grid)
            .Header($" [bold {Primary}]Vector Store Summary[/] ")
            .HeaderAlignment(Justify.Left)
            .Border(BoxBorder.Rounded)
            .BorderColor(BorderColor)
            .Padding(1, 0);

        AnsiConsole.Write(panel);
        AnsiConsole.WriteLine();
    }

    /// <summary>
    /// Displays ranked search results in an elegant table.
    /// </summary>
    public static void ShowSearchResults(List<SearchResult> results, string query)
    {
        AnsiConsole.WriteLine();
        AnsiConsole.Write(
            new Rule($"[bold {Primary}]Search Results: \"{Markup.Escape(query)}\"[/]")
                .RuleStyle(Border)
                .LeftJustified());
        AnsiConsole.WriteLine();

        if (results.Count == 0)
        {
            ShowWarning("No relevant context found in index.");
            return;
        }

        var table = new Table()
            .Border(TableBorder.Rounded)
            .BorderColor(BorderColor)
            .Expand();

        table.AddColumn(new TableColumn($"[{Secondary}]Rank[/]").Centered().Width(6));
        table.AddColumn(new TableColumn($"[{Secondary}]Score[/]").Centered().Width(9));
        table.AddColumn(new TableColumn($"[{Secondary}]Source[/]").LeftAligned().Width(24));
        table.AddColumn(new TableColumn($"[{Secondary}]Chunk[/]").Centered().Width(7));
        table.AddColumn(new TableColumn($"[{Secondary}]Content[/]").LeftAligned());

        for (int i = 0; i < results.Count; i++)
        {
            var result = results[i];

            string rankBadge = i switch
            {
                0 => $"[bold {Primary}]#1[/]",
                1 => $"[{Primary}]#2[/]",
                2 => $"[{Secondary}]#3[/]",
                _ => $"[{Muted}]#{i + 1}[/]"
            };

            string scoreColor = result.SimilarityScore switch
            {
                >= 0.60f => Success,
                >= 0.45f => Warning,
                _ => Secondary
            };

            string content = result.Chunk.Text.Length > 200
                ? result.Chunk.Text[..200] + "..."
                : result.Chunk.Text;

            table.AddRow(
                rankBadge,
                $"[bold {scoreColor}]{result.SimilarityScore:F4}[/]",
                $"[bold {Primary}]{Markup.Escape(result.Chunk.SourceFile)}[/]",
                $"[{Muted}]{result.Chunk.ChunkIndex}[/]",
                $"[{Primary}]{Markup.Escape(content)}[/]"
            );
        }

        AnsiConsole.Write(table);
    }

    /// <summary>
    /// Header for the AI-generated answer section.
    /// </summary>
    public static void ShowLlmResponseHeader()
    {
        AnsiConsole.WriteLine();
        AnsiConsole.Write(
            new Rule($"[bold {Primary}]AI-Generated Answer[/]")
                .RuleStyle(Border)
                .LeftJustified());
        AnsiConsole.WriteLine();
    }

    /// <summary>
    /// Streams tokens directly to stdout with crisp readability.
    /// </summary>
    public static void WriteStreamToken(string token)
    {
        Console.Write(token);
    }

    /// <summary>
    /// Closes the AI response section.
    /// </summary>
    public static void ShowLlmResponseComplete()
    {
        AnsiConsole.WriteLine();
        AnsiConsole.WriteLine();
        AnsiConsole.Write(new Rule().RuleStyle(Border));
    }

    public static void ShowLlmError(string message)
    {
        AnsiConsole.WriteLine();
        ShowError($"Generation failed: {message}");
    }

    /// <summary>
    /// Clean query input prompt.
    /// </summary>
    public static string PromptQuery()
    {
        AnsiConsole.WriteLine();
        AnsiConsole.Write(new Rule($"[{Secondary}]Enter Your Query[/]").RuleStyle(Border).LeftJustified());

        try
        {
            var query = AnsiConsole.Prompt(
                new TextPrompt<string>($"  [{Accent}]>[/] ")
                    .PromptStyle("white"));
            return query;
        }
        catch (InvalidOperationException)
        {
            Console.Write("  > ");
            return Console.ReadLine() ?? "";
        }
    }

    /// <summary>
    /// Graceful session exit message.
    /// </summary>
    public static void ShowGoodbye()
    {
        AnsiConsole.WriteLine();
        AnsiConsole.Write(
            new Rule($"[bold {Primary}]Thank you for using ResumeRAG[/]")
                .RuleStyle(Border));
        AnsiConsole.MarkupLine($"  [{Secondary}]Your vector store is saved and ready for next time.[/]");
        AnsiConsole.WriteLine();
    }

    private static string PadCenter(this string text, int width)
    {
        if (text.Length >= width) return text;
        int padding = (width - text.Length) / 2;
        return text.PadLeft(text.Length + padding).PadRight(width);
    }
}
