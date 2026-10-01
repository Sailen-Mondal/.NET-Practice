# Desi Yatra — AI Travel Agent (RAG Demo)

A C# .NET 10 console application demonstrating **Retrieval-Augmented Generation (RAG)** using a local Ollama LLM. The app acts as an Indian travel agent that answers travel questions by retrieving relevant information from a hardcoded knowledge base, then augmenting the LLM prompt with that context.

## What is RAG?

**Retrieval-Augmented Generation** is a technique that improves LLM responses by:

1. **Retrieving** relevant documents/chunks from a knowledge base
2. **Augmenting** the LLM prompt with that retrieved context
3. **Generating** a grounded answer based on real data (not hallucinations)

```
User Question
     │
     ▼
┌─────────────┐     ┌──────────────────┐     ┌─────────────┐
│  Retrieve    │────▶│  Augment Prompt   │────▶│  Generate   │
│  (Keyword    │     │  (System Prompt + │     │  (Ollama    │
│   Search)    │     │   Context + Query)│     │   LLM)      │
└─────────────┘     └──────────────────┘     └─────────────┘
     ▲                                              │
     │                                              ▼
┌─────────────┐                              Streamed Answer
│ Knowledge   │
│ Base (Static│
│ Travel Data)│
└─────────────┘
```

## Destinations Covered

| City | State | Known For |
|------|-------|-----------|
| Jaipur | Rajasthan | Pink City, forts, palaces, bazaars |
| Goa | Goa | Beaches, Portuguese heritage, nightlife |
| Manali | Himachal Pradesh | Mountains, snow, adventure sports |
| Varanasi | Uttar Pradesh | Spiritual capital, Ganges ghats, ancient culture |
| Munnar | Kerala | Tea plantations, misty hills, wildlife |
| Udaipur | Rajasthan | City of Lakes, romantic palaces |
| Rishikesh | Uttarakhand | Yoga capital, rafting, Beatles ashram |
| Darjeeling | West Bengal | Tea, toy train, Kanchenjunga views |
| Kolkata | West Bengal | City of Joy, colonial heritage, Durga Puja, culinary hub |

## Prerequisites

- [.NET 10 SDK](https://dotnet.microsoft.com/download)
- [Ollama](https://ollama.com/) installed with the `qwen2.5-coder:3b` model

## How to Run

1. **Start Ollama server** (in a separate terminal):
   ```bash
   ollama serve
   ```

2. **Run the app**:
   ```bash
   cd D:\.NET\src\04-TravelAgentRAG
   dotnet run
   ```

3. **Chat with the agent** — it will ask follow-up questions about your budget, travel days, interests, etc. before giving personalized recommendations.

## Sample Conversation

```
You: I want to visit Goa

Desi Yatra: Arey wah, Goa is a fantastic choice! Before I plan your
perfect Goa trip, I need a few details:

- What's your budget preference — budget, mid-range, or luxury?
- How many days are you planning to spend?
- Who are you traveling with — solo, couple, family, or friends?

You: Budget trip, 4 days, with friends

Desi Yatra: Chalo, here's your 4-day budget Goa plan with friends! ...
```

## Project Structure

```
04-TravelAgentRAG/
├── TravelAgentRAG.csproj       # Project file
├── Program.cs                  # Entry point & chat loop
├── README.md                   # This file
├── Data/
│   └── TravelDataStore.cs      # Hardcoded Indian travel data
├── Models/
│   └── TravelDestination.cs    # Destination data model
└── Rag/
    ├── TextChunker.cs          # Splits data into searchable chunks
    ├── KeywordSearcher.cs      # Keyword-based retrieval engine
    └── RagEngine.cs            # RAG pipeline orchestrator
```

## Key Concepts Demonstrated

- **Text Chunking**: Breaking structured data into focused text passages
- **Keyword Search**: Simple retrieval using tokenization and stop-word filtering
- **Prompt Engineering**: System prompts that define agent personality and behavior
- **Context Injection**: Augmenting LLM prompts with retrieved data
- **Streaming**: Real-time token-by-token output for responsive UX
- **Conversation Memory**: Persistent chat history for multi-turn interactions
