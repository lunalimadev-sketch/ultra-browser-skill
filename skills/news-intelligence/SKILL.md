---
name: news-intelligence
description: Multi-source news monitoring with AI scoring, deduplication, and daily briefings. Adapted from Horizon methodology for OpenClaw agency workflows.
metadata:
  openclaw:
    os: ["darwin", "linux", "win32"]
---

# News Intelligence Skill

Collect, score, deduplicate, enrich, and deliver news briefings from multiple sources. Adapted from Horizon's pipeline for the OpenClaw agency ecosystem.

## Pipeline

```
Sources → Fetch → Dedup → AI Score → Enrich → Summary → Deliver
```

## When to Use

- Monitor competitors, clients, or industry topics daily
- Generate research briefings for article writing
- Feed content to AgenteRedesSociais for posting
- Track mentions across platforms (HN, Reddit, Twitter, RSS, Telegram)
- Deliver structured briefings to Telegram/webhook

## Sources Supported

| Source | What it fetches | Config key |
|--------|----------------|------------|
| RSS/Atom | Any feed | `rss` |
| Hacker News | Top stories by score | `hackernews` |
| Reddit | Subreddits + user posts | `reddit` |
| Twitter/X | Tweets from specific users | `twitter` |
| Telegram | Public channel messages | `telegram` |
| GitHub | User events & repo releases | `github` |
| Web Search | Brave/Perplexity for ad-hoc topics | `web_search` |

## AI Scoring

Each item is scored 0-10 using the configured model:
- **8-10:** Critical — must include
- **6-7:** Relevant — include by default
- **4-5:** Marginal — include if under quota
- **0-3:** Noise — filter out

Threshold configurable per source category.

## Deduplication

Items are deduplicated by:
1. URL exact match
2. Title similarity (Jaccard > 0.6)
3. AI semantic dedup for same-story-different-angle

## Usage

### Run full pipeline
```bash
python scripts/run.py --hours 24 --config config/sources.json
```

### Run specific stage
```bash
python scripts/run.py --stage fetch --hours 24
python scripts/run.py --stage score --input data/raw/
python scripts/run.py --stage dedup --input data/scored/
python scripts/run.py --stage briefing --input data/deduped/
```

### Quick briefing (via agent)
Agent can call the pipeline and deliver results to Telegram:
```
"Rode o pipeline de news intelligence e me mande o briefing"
```

## Configuration

Edit `config/sources.json` to customize:
- Which sources to monitor
- AI model and threshold per category
- Delivery channels (Telegram, webhook, file)
- Language preferences (PT, EN, ZH)

## Output Format

```markdown
# 📰 Daily Briefing — 2026-06-23

## 🔴 Critical (8-10)
- **[Title]** (score: 9) — Source
  Summary + context + link

## 🟡 Relevant (6-7)
- **[Title]** (score: 7) — Source
  Summary + link

## Stats
- Sources checked: 7
- Items fetched: 234
- After dedup: 187
- After scoring: 42
- Delivered: 28
```

## Integration with Agency

- **Article research:** Feed scored items to Dwight for bibliography
- **Social media:** Top-scored items → AgenteRedesSociais for posting
- **Client reports:** Daily briefings per client topic
- **Memory:** Save briefings to `memory/briefings/YYYY-MM-DD.md`

## Files

```
news-intelligence/
├── SKILL.md
├── config/
│   └── sources.json
├── scripts/
│   ├── collector.py      # Multi-source fetcher
│   ├── scorer.py         # AI scoring engine
│   ├── dedup.py          # Deduplication
│   ├── enricher.py       # Web context enrichment
│   ├── briefing.py       # Markdown generator
│   └── run.py            # Main orchestrator
└── data/                 # Runtime data (gitignored)
```

## Tests

See `tests/test-news-intelligence.md` for validation cases.
