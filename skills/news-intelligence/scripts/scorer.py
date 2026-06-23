"""
News Intelligence - AI Scoring Engine
Scores news items 0-10 using configured AI model.
"""

import json
import os
from pathlib import Path
from datetime import datetime


def score_item(item: dict, config: dict) -> float:
    """Score a single news item using AI or fallback heuristics."""
    ai_cfg = config.get("ai", {})

    # Try AI scoring first
    try:
        return _ai_score(item, ai_cfg)
    except Exception:
        pass

    # Fallback: heuristic scoring
    return _heuristic_score(item)


def _ai_score(item: dict, ai_cfg: dict) -> float:
    """Score using OpenRouter or local API."""
    try:
        import requests
    except ImportError:
        return _heuristic_score(item)

    api_key = os.environ.get("OPENROUTER_API_KEY", "")
    if not api_key:
        return _heuristic_score(item)

    prompt = ai_cfg.get("scoring_prompt", "Score 0-10 for relevance.")
    title = item.get("title", "")
    source = item.get("source", "")
    url = item.get("url", "")

    resp = requests.post(
        "https://openrouter.ai/api/v1/chat/completions",
        headers={
            "Authorization": f"Bearer {api_key}",
            "Content-Type": "application/json",
        },
        json={
            "model": ai_cfg.get("model", "google/gemini-2.0-flash"),
            "messages": [
                {"role": "system", "content": prompt},
                {"role": "user", "content": f"Title: {title}\nSource: {source}\nURL: {url}"}
            ],
            "max_tokens": 10,
            "temperature": 0.0,
        },
        timeout=15,
    )

    if resp.status_code != 200:
        return _heuristic_score(item)

    result = resp.json()
    text = result.get("choices", [{}])[0].get("message", {}).get("content", "5")
    # Extract number from response
    import re
    nums = re.findall(r'\d+\.?\d*', text)
    if nums:
        score = float(nums[0])
        return min(max(score, 0), 10)
    return 5.0


def _heuristic_score(item: dict) -> float:
    """Simple heuristic scoring when AI is unavailable."""
    score = 5.0
    title = item.get("title", "").lower()

    # Boost for AI/tech keywords
    high_value = ["gpt", "claude", "gemini", "llm", "ai", "agent", "rag",
                   "openai", "anthropic", "google", "meta", "breakthrough",
                   "launch", "release", "open source", "billion", "billion"]
    for kw in high_value:
        if kw in title:
            score += 0.5

    # Source-based boost
    source = item.get("source", "")
    if "hackernews" in source:
        score += 1.0
    elif "github" in source:
        score += 0.5

    return min(max(score, 0), 10)


def score_batch(items: list[dict], config: dict) -> list[dict]:
    """Score a batch of items and filter by threshold."""
    threshold = config.get("general", {}).get("score_threshold", 5)
    scored = []

    for item in items:
        item["score"] = score_item(item, config)
        if item["score"] >= threshold:
            scored.append(item)

    scored.sort(key=lambda x: x["score"], reverse=True)
    max_items = config.get("general", {}).get("max_items", 50)
    return scored[:max_items]


if __name__ == "__main__":
    import sys
    config_path = sys.argv[1] if len(sys.argv) > 1 else "config/sources.json"
    input_path = sys.argv[2] if len(sys.argv) > 2 else "data/raw"

    with open(config_path, encoding="utf-8") as f:
        config = json.load(f)

    # Load raw items
    raw_files = sorted(Path(input_path).glob("raw_*.json"))
    if not raw_files:
        print("No raw data found")
        sys.exit(1)

    with open(raw_files[-1], encoding="utf-8") as f:
        items = json.load(f)

    scored = score_batch(items, config)

    output_dir = Path("data/scored")
    output_dir.mkdir(parents=True, exist_ok=True)
    ts = datetime.now().strftime("%Y%m%d_%H%M%S")
    with open(output_dir / f"scored_{ts}.json", "w", encoding="utf-8") as f:
        json.dump(scored, f, ensure_ascii=False, indent=2)

    print(f"Scored {len(scored)}/{len(items)} items (threshold: {threshold})")
