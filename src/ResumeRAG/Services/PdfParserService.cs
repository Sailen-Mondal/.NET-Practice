using System.Text;
using System.Text.RegularExpressions;
using UglyToad.PdfPig;

namespace ResumeRAG.Services;

/// <summary>
/// Extracts and cleans text from PDF files using PdfPig.
/// Handles multi-page documents and normalizes whitespace for downstream chunking.
/// </summary>
public static partial class PdfParserService
{
    /// <summary>
    /// Opens a PDF file and extracts all text content page-by-page.
    /// </summary>
    /// <param name="filePath">Absolute path to the PDF file.</param>
    /// <returns>Cleaned, concatenated text from all pages.</returns>
    public static string ExtractText(string filePath)
    {
        using var document = PdfDocument.Open(filePath);
        var textBuilder = new StringBuilder();

        foreach (var page in document.GetPages())
        {
            textBuilder.AppendLine(page.Text);
        }

        return CleanText(textBuilder.ToString());
    }

    /// <summary>
    /// Gets the number of pages in a PDF without extracting text.
    /// </summary>
    public static int GetPageCount(string filePath)
    {
        using var document = PdfDocument.Open(filePath);
        return document.NumberOfPages;
    }

    /// <summary>
    /// Collapses multiple whitespace characters (spaces, tabs, newlines) into single spaces
    /// and trims leading/trailing whitespace. This produces a clean, continuous text block
    /// that's ideal for fixed-size chunking.
    /// </summary>
    private static string CleanText(string text)
    {
        // Collapse all whitespace sequences into a single space
        text = MultipleWhitespaceRegex().Replace(text, " ");
        return text.Trim();
    }

    [GeneratedRegex(@"\s+")]
    private static partial Regex MultipleWhitespaceRegex();
}
