namespace ResumeRAG.Models;

/// <summary>
/// Represents a single chunk of text extracted from a PDF resume.
/// Each chunk carries metadata about its source and position within the original document.
/// </summary>
public class TextChunk
{
    /// <summary>Unique identifier: "{filename}_chunk_{index}"</summary>
    public string Id { get; set; } = "";

    /// <summary>The actual text content of this chunk.</summary>
    public string Text { get; set; } = "";

    /// <summary>Original PDF file path this chunk was extracted from.</summary>
    public string SourceFile { get; set; } = "";

    /// <summary>Sequential index of this chunk within the source document.</summary>
    public int ChunkIndex { get; set; }

    /// <summary>Character offset where this chunk starts in the full document text.</summary>
    public int StartPosition { get; set; }

    /// <summary>Character offset where this chunk ends in the full document text.</summary>
    public int EndPosition { get; set; }
}
