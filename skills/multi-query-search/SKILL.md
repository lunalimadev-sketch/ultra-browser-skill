---
name: multi-query-search
description: Decompose complex queries into multiple targeted searches using precision, recall, temporal, semantic, and multilingual strategies. Adapted from msearch methodology for OpenClaw.
metadata:
  openclaw:
    os: ["darwin", "linux", "win32"]
---

# Multi-Query Search Skill

Decompose complex user queries into multiple targeted searches to maximize coverage and precision. Adapted from `file_search.msearch` methodology for the OpenClaw ecosystem.

## When to Use

- User asks a complex, multi-faceted question
- Research tasks requiring comprehensive coverage
- Queries involving multiple entities, time periods, or domains
- When a single search would miss important context

## Strategy: 5-Query Decomposition

For each complex query, generate up to **5 parallel searches**:

### 1. Precision Query
A precise restatement of the user's question using exact terminology.
- Use the user's exact terms
- Include key entities and constraints
- Aim for the most direct answer

### 2. Recall Query
Short, concise keywords (1-3 words) likely to appear in relevant results.
- Strip articles, prepositions, filler
- Focus on nouns and technical terms
- Example: user asks "what is the impact of transformer architecture on modern NLP" → recall: `"transformer NLP impact"`

### 3. Temporal Query (QDF)
Apply date freshness based on information recency needs:

| QDF | Freshness | OpenClaw Parameter |
|-----|-----------|-------------------|
| 0 | 10+ years (stable/historical) | *(omit freshness)* |
| 1 | Up to 18 months | `freshness: "year"` |
| 2 | Up to 6 months | `freshness: "month"` |
| 3 | Up to 3 months | `freshness: "month"` + manual date filter |
| 4 | Up to 60 days | `freshness: "week"` |
| 5 | Up to 30 days | `freshness: "day"` |

**Infer temporal intent:** If the user says "recent", use QDF=4/5. If "latest" or "new", use QDF=5. If "history" or "background", use QDF=0/1.

### 4. Semantic Query
Conceptual and related terms that capture the meaning without exact keywords.
- Synonyms, broader/narrower concepts
- Related domains and cross-disciplinary terms
- Example: "neural network optimization" → `"deep learning gradient methods training efficiency"`

### 5. Multilingual Query (if applicable)
If the user writes in a non-English language, also search in English AND the original language.
- Query 5a: English version
- Query 5b: Original language version
- Only apply when the user's language differs from English

## Query Construction Rules

Each query must:
- **Be self-contained** — understandable without context
- **Use boost operators** when the provider supports it:
  - Brave: `+(entity)` for strong emphasis
  - Exa: neural mode inherently handles semantic weight
- **Use hybrid phrasing** — combine keywords with semantic context
- **Include distinct terms** — avoid repeating the same keywords across queries
- **Set temporal filters** — apply QDF=3+ for queries about current events

## Intent Classification (Optional)

If the user is searching for a specific file/document/topic/object, tag with intent:
- `nav` — navigational intent ("find the slides for project Aurora")
- *(omit if not applicable)*

## Execution Flow

```
1. RECEIVE complex query from user
2. DECOMPOSE into up to 5 queries (precision, recall, temporal, semantic, multilingual)
3. EXECUTE searches in parallel using:
   - web_search (Brave/Perplexity/Exa/Gemini) for external queries
   - memory_search for workspace/memory context
   - exec with find/grep for local file searches
4. MERGE results, deduplicate by URL/title
5. EVALUATE relevance using:
   - Document timestamps and freshness
   - Title and snippet quality
   - Source authority
6. SYNTHESIZE final answer with citations
```

## Provider-Specific Adaptations

### Brave Search
- Use `+(term)` boost for important entities
- `freshness: "day"|"week"|"month"|"year"` for temporal
- `country`, `language` for locale-specific queries
- `llm-context` mode for pre-extracted text chunks

### Perplexity Search
- `domain_filter` for targeted sources (max 20 domains)
- `max_tokens` and `max_tokens_per_page` for content depth
- Best for structured results with content extraction

### Exa Search
- `type: "neural"` for semantic-heavy queries
- `type: "deep"` for thorough research
- `contents: { text, highlights, summary }` for extraction
- Best for academic and technical content

### Gemini Search
- AI-synthesized answers with Google grounding
- Automatic citation resolution
- Best for quick synthesized answers

### Memory Search
- Searches `MEMORY.md` + `memory/*.md` files
- Use for workspace context, past decisions, project history
- No temporal parameters — always searches all content

## Output Format

When presenting results, include:
1. **Source citations** — URL or file path for each claim
2. **Freshness indicator** — how recent the information is
3. **Confidence level** — based on source quality and recency
4. **Query coverage** — which of the 5 queries contributed

## Example

**User query:** "Quais são as melhores práticas de segurança para agentes de IA em produção?"

**Decomposition:**
1. **Precision:** `"best practices security AI agents production deployment"`
2. **Recall:** `"AI agent security practices"`
3. **Temporal (QDF=4):** `"AI agent security 2026"` → `freshness: "week"`
4. **Semantic:** `"LLM safety guardrails production deployment防护 injection prompt"`
5. **Multilingual:** `"segurança agentes IA produção práticas"` (Portuguese)

## Tests

See `tests/test-multi-query-search.md` for validation cases.
