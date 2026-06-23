"""
News Intelligence - Deduplication Engine
Removes duplicate items across sources using URL, title similarity, and content hash.
"""

import json
import re
from pathlib import Path
from datetime import datetime
from difflib import SequenceMatcher


def jaccard_similarity(a: str, b: str) -> float:
    """Jaccard similarity between two strings."""
    set_a = set(a.lower().split())
    set_b = set(b.lower().split())
    if not set_a or not set_b:
        return 0.0
    intersection = set_a & set_b
    union = set_a | set_b
    return len(intersection) / len(union)


def title_similarity(a: str, b: str) -> float:
    """Combined title similarity using SequenceMatcher + Jaccard."""
    seq_ratio = SequenceMatcher(None, a.lower(), b.lower()).ratio()
    jaccard = jaccard_similarity(a, b)
    return max(seq_ratio, jaccard)


def dedup_items(items: list[dict]) -> list[dict]:
    """Remove duplicates across sources."""
    seen_urls = {}
    seen_titles = {}
    unique = []

    # Sort by score descending (keep highest scored version)
    items_sorted = sorted(items, key=lambda x: x.get("score", 0), reverse=True)

    for item in items_sorted:
        url = item.get("url", "").rstrip("/").lower()
        title = item.get("title", "").strip()

        # URL exact match
        if url and url in seen_urls:
            continue

        # Title similarity check
        is_dup = False
        for seen_title in seen_titles:
            if title_similarity(title, seen_title) > 0.6:
                is_dup = True
                break

        if is_dup:
            continue

        # Keep this item
        if url:
            seen_urls[url] = True
        seen_titles[title] = True
        unique.append(item)

    return unique


def merge_cross_source(items: list[dict]) -> list[dict]:
    """Merge items that appear in multiple sources."""
    url_map = {}
    for item in items:
        url = item.get("url", "").rstrip("/").lower()
        if url in url_map:
            existing = url_map[url]
            # Merge sources
            existing_sources = existing.get("all_sources", [existing.get("source", "")])
            if item.get("source") not in existing_sources:
                existing_sources.append(item.get("source", ""))
            existing["all_sources"] = existing_sources
            # Keep highest score
            if item.get("score", 0) > existing.get("score", 0):
                existing["score"] = item["score"]
        else:
            item["all_sources"] = [item.get("source", "")]
            url_map[url] = item

    return list(url_map.values())


if __name__ == "__main__":
    import sys
    input_path = sys.argv[1] if len(sys.argv) > 1 else "data/scored"

    raw_files = sorted(Path(input_path).glob("scored_*.json"))
    if not raw_files:
        print("No scored data found")
        sys.exit(1)

    with open(raw_files[-1], encoding="utf-8") as f:
        items = json.load(f)

    deduped = dedup_items(items)
    merged = merge_cross_source(deduped)

    output_dir = Path("data/deduped")
    output_dir.mkdir(parents=True, exist_ok=True)
    ts = datetime.now().strftime("%Y%m%d_%H%M%S")
    with open(output_dir / f"deduped_{ts}.json", "w", encoding="utf-8") as f:
        json.dump(merged, f, ensure_ascii=False, indent=2)

    print(f"Deduped: {len(items)} → {len(merged)} items")
