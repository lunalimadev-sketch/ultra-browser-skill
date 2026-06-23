"""
News Intelligence - Enrichment Engine
Adds web-researched context and comment summaries to high-scored items.
"""

import json
import os
import re
from pathlib import Path
from datetime import datetime


def enrich_item(item: dict, config: dict) -> dict:
    """Enrich a single item with context and summary."""
    ai_cfg = config.get("ai", {})

    # Only enrich items with score >= 7
    if item.get("score", 0) < 7:
        return item

    try:
        import requests
    except ImportError:
        return item

    api_key = os.environ.get("OPENROUTER_API_KEY", "")
    if not api_key:
        return item

    model = ai_cfg.get("model", "google/gemini-2.0-flash")
    headers = {
        "Authorization": f"Bearer {api_key}",
        "Content-Type": "application/json",
    }

    # Generate summary
    try:
        summary_prompt = ai_cfg.get("summary_prompt", "Summarize in 2-3 sentences.")
        resp = requests.post(
            "https://openrouter.ai/api/v1/chat/completions",
            headers=headers,
            json={
                "model": model,
                "messages": [
                    {"role": "system", "content": summary_prompt},
                    {"role": "user", "content": f"Title: {item.get('title', '')}\nURL: {item.get('url', '')}"}
                ],
                "max_tokens": 200,
                "temperature": 0.3,
            },
            timeout=15,
        )
        if resp.status_code == 200:
            result = resp.json()
            item["summary"] = result.get("choices", [{}])[0].get("message", {}).get("content", "")
    except Exception:
        pass

    # Generate context (only for top 3)
    if item.get("score", 0) >= 8:
        try:
            ctx_prompt = ai_cfg.get("enrichment_prompt", "Provide brief context.")
            resp = requests.post(
                "https://openrouter.ai/api/v1/chat/completions",
                headers=headers,
                json={
                    "model": model,
                    "messages": [
                        {"role": "system", "content": ctx_prompt},
                        {"role": "user", "content": f"Title: {item.get('title', '')}"}
                    ],
                    "max_tokens": 150,
                    "temperature": 0.3,
                },
                timeout=15,
            )
            if resp.status_code == 200:
                result = resp.json()
                item["context"] = result.get("choices", [{}])[0].get("message", {}).get("content", "")
        except Exception:
            pass

    return item


def enrich_batch(items: list[dict], config: dict) -> list[dict]:
    """Enrich all items (top-scored get full enrichment)."""
    enriched = []
    for i, item in enumerate(items):
        print(f"[Enricher] {i+1}/{len(items)}: {item.get('title', '')[:50]}...")
        enriched.append(enrich_item(item, config))
    return enriched


if __name__ == "__main__":
    import sys
    config_path = sys.argv[1] if len(sys.argv) > 1 else "config/sources.json"
    input_path = sys.argv[2] if len(sys.argv) > 2 else "data/deduped"

    with open(config_path, encoding="utf-8") as f:
        config = json.load(f)

    raw_files = sorted(Path(input_path).glob("deduped_*.json"))
    if not raw_files:
        print("No deduped data found")
        sys.exit(1)

    with open(raw_files[-1], encoding="utf-8") as f:
        items = json.load(f)

    enriched = enrich_batch(items, config)

    output_dir = Path("data/enriched")
    output_dir.mkdir(parents=True, exist_ok=True)
    ts = datetime.now().strftime("%Y%m%d_%H%M%S")
    with open(output_dir / f"enriched_{ts}.json", "w", encoding="utf-8") as f:
        json.dump(enriched, f, ensure_ascii=False, indent=2)

    print(f"Enriched {len(enriched)} items")
