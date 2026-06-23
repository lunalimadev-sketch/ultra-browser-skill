# News Intelligence Skill

Multi-source news monitoring with AI scoring, deduplication, and daily briefings. Adapted from Horizon's pipeline for the OpenClaw agency ecosystem.

## Pipeline

```
Sources → Fetch → Dedup → AI Score → Enrich → Summary → Deliver
```

## Supported Sources

| Source | Status | Notes |
|--------|--------|-------|
| Hacker News | ✅ | Top stories by score |
| RSS/Atom | ✅ | Any feed |
| Reddit | ✅ | Subreddits + posts |
| GitHub | ✅ | Releases & events |
| Twitter/X | 🔲 | Requires auth (browser automation) |
| Telegram | 🔲 | Requires channel access |

## Quick Start

```bash
# Install
pip install requests  # or uv sync

# Run full pipeline
cd skills/news-intelligence
python scripts/run.py --hours 24

# Run specific stage
python scripts/run.py --stage fetch --hours 24
python scripts/run.py --stage score
python scripts/run.py --stage briefing
```

## Configuration

Edit `config/sources.json`:
- Toggle sources on/off
- Set AI model and scoring thresholds
- Configure delivery channels
- Add custom RSS feeds

## AI Scoring

Items scored 0-10 using configured model (OpenRouter/local):
- **8-10:** Critical
- **6-7:** Relevant
- **4-5:** Marginal
- **0-3:** Filtered out

## Deduplication

Three-layer dedup:
1. URL exact match
2. Title similarity (Jaccard > 0.6)
3. Cross-source merging (same URL = 1 item, highest score kept)

## Integration

- **Agent:** "Rode o pipeline de news intelligence"
- **Cron:** Schedule daily runs via OpenClaw cron
- **Telegram:** Auto-deliver briefing to chat
- **Memory:** Save briefings to `memory/briefings/`

## License

MIT
