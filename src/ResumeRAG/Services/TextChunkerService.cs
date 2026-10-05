using ResumeRAG.Models;

namespace ResumeRAG.Services;

/// <summary>
/// Implements sliding window text chunking with configurable overlap.
/// 
/// HOW IT WORKS:
/// ═══════════════════════════════════════════════════════════════
/// Given ChunkSize=500, Overlap=100:
///   Stride = ChunkSize - Overlap = 400
///
///   Text:    [==============================================]
///   Chunk 1: [======500======]
///   Chunk 2:         [======500======]        ← starts 400 chars later
///   Chunk 3:                 [======500======] ← starts 400 chars later
///                    ↕100↕                     ← overlap zone
///
/// The overlap ensures that sentences/concepts at chunk boundaries
/// appear in full in at least one chunk, preserving semantic coherence.
/// ═══════════════════════════════════════════════════════════════
/// </summary>
public static class TextChunkerService
{
    /// <summary>
    /// Splits text into overlapping chunks using a sliding window approach.
    /// </summary>
    /// <param name="text">The full text to chunk.</param>
    /// <param name="sourceFile">Source file name for metadata tagging.</param>
    /// <param name="chunkSize">Maximum number of characters per chunk (default: 500).</param>
    /// <param name="overlap">Number of overlapping characters between consecutive chunks (default: 100).</param>
    /// <returns>A list of TextChunk objects with position metadata.</returns>
    public static List<TextChunk> Chunk(string text, string sourceFile,
        int chunkSize = 500, int overlap = 100)
    {
        var chunks = new List<TextChunk>();

        if (string.IsNullOrWhiteSpace(text))
            return chunks;

        if (overlap >= chunkSize)
            throw new ArgumentException("Overlap must be less than chunk size.");

        int stride = chunkSize - overlap;
        int position = 0;
        int index = 0;

        while (position < text.Length)
        {
            // Calculate how many characters to take (may be less at end of text)
            int length = Math.Min(chunkSize, text.Length - position);
            string chunkText = text.Substring(position, length);

            chunks.Add(new TextChunk
            {
                Id = $"{Path.GetFileNameWithoutExtension(sourceFile)}_chunk_{index}",
                Text = chunkText,
                SourceFile = Path.GetFileName(sourceFile),
                ChunkIndex = index,
                StartPosition = position,
                EndPosition = position + length
            });

            // If we've reached the end of the text, stop
            if (position + length >= text.Length)
                break;

            position += stride;
            index++;
        }

        return chunks;
    }
}
