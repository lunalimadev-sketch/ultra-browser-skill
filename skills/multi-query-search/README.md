# Multi-Query Search Skill

Decompose complex queries into multiple targeted searches for comprehensive coverage. Adapted from `file_search.msearch` methodology for the OpenClaw ecosystem.

## Overview

This skill teaches the agent to break down complex user queries into up to 5 parallel searches, each targeting a different aspect:

1. **Precision** — exact restatement with key terms
2. **Recall** — short keywords likely in results
3. **Temporal** — time-filtered using QDF (Query Date Freshness)
4. **Semantic** — related concepts and synonyms
5. **Multilingual** — bilingual queries when user writes in non-English

## Installation

Copy to your workspace skills directory:

```bash
cp -r multi-query-search ~/.openclaw/workspace/skills/
```

Or install from ClawHub (when published):

```bash
clawhub install multi-query-search
```

## Usage

The skill activates automatically for complex queries. Example:

```
User: "Quais são as melhores práticas de segurança para agentes de IA em produção?"
```

The agent will decompose this into 5-6 parallel searches covering precision, recall, temporal, semantic, and bilingual angles.

## QDF Reference

| QDF | Timeframe | OpenClaw `freshness` |
|-----|-----------|---------------------|
| 0 | 10+ years | *(none)* |
| 1 | ≤18 months | `"year"` |
| 2 | ≤6 months | `"month"` |
| 3 | ≤3 months | `"month"` + date filter |
| 4 | ≤60 days | `"week"` |
| 5 | ≤30 days | `"day"` |

## Supported Providers

Works with any `web_search` provider:
- **Brave** — boost `+(term)`, country/language filters
- **Perplexity** — domain filtering, content extraction
- **Exa** — neural/deep modes, highlights
- **Gemini** — AI-synthesized with citations

Also integrates with `memory_search` for workspace context.

## Tests

See `tests/test-multi-query-search.md` for 10 validation cases covering:
- English and Portuguese queries
- Temporal intent detection (breaking news → historical)
- Multi-entity queries
- Navigational intent
- Cross-domain topics
- Memory search fallback

## Files

```
multi-query-search/
├── SKILL.md              # Skill definition and instructions
├── README.md             # This file
└── tests/
    └── test-multi-query-search.md  # Test suite
```

## License

MIT
