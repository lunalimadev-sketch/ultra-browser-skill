"""
News Intelligence - Main Orchestrator
Runs the full pipeline: fetch → score → dedup → enrich → briefing → deliver
"""

import json
import sys
import argparse
from pathlib import Path
from datetime import datetime

# Add scripts dir to path
sys.path.insert(0, str(Path(__file__).parent))

from collector import NewsCollector
from scorer import score_batch
from dedup import dedup_items, merge_cross_source
from enricher import enrich_batch
from briefing import generate_briefing, save_briefing


def run_pipeline(config_path: str = "config/sources.json", stage: str = "all", hours: int = None):
    """Run the full news intelligence pipeline."""
    config_file = Path(config_path)
    if not config_file.exists():
        print(f"[Error] Config not found: {config_path}")
        sys.exit(1)

    with open(config_file, encoding="utf-8") as f:
        config = json.load(f)

    if hours:
        config.setdefault("general", {})["hours"] = hours

    general = config.get("general", {})
    hours = general.get("hours", 24)

    print(f"{'='*60}")
    print(f"📡 News Intelligence Pipeline")
    print(f"{'='*60}")
    print(f"Time window: {hours}h | Stage: {stage}")
    print(f"Threshold: {general.get('score_threshold', 5)}")
    print()

    # Stage 1: FETCH
    if stage in ("all", "fetch"):
        print("📥 Stage 1: Fetching from sources...")
        collector = NewsCollector(config)
        items = collector.collect_all(hours=hours)
        collector.save_raw("data/raw")
        print(f"   → {len(items)} items fetched\n")

        if stage == "fetch":
            return items

    # Stage 2: SCORE
    if stage in ("all", "score"):
        print("🤖 Stage 2: AI Scoring...")
        raw_dir = Path("data/raw")
        raw_files = sorted(raw_dir.glob("raw_*.json"))
        if not raw_files:
            print("   → No raw data to score")
            return []
        with open(raw_files[-1], encoding="utf-8") as f:
            raw_items = json.load(f)
        scored = score_batch(raw_items, config)
        print(f"   → {len(scored)}/{len(raw_items)} items above threshold\n")

        if stage == "score":
            return scored

    # Stage 3: DEDUP
    if stage in ("all", "dedup"):
        print("🧹 Stage 3: Deduplication...")
        scored_dir = Path("data/scored")
        scored_files = sorted(scored_dir.glob("scored_*.json"))
        if not scored_files:
            print("   → No scored data to dedup")
            return []
        with open(scored_files[-1], encoding="utf-8") as f:
            scored_items = json.load(f)
        deduped = dedup_items(scored_items)
        merged = merge_cross_source(deduped)
        # Save
        output_dir = Path("data/deduped")
        output_dir.mkdir(parents=True, exist_ok=True)
        ts = datetime.now().strftime("%Y%m%d_%H%M%S")
        with open(output_dir / f"deduped_{ts}.json", "w", encoding="utf-8") as f:
            json.dump(merged, f, ensure_ascii=False, indent=2)
        print(f"   → {len(merged)} items after dedup\n")

        if stage == "dedup":
            return merged

    # Stage 4: ENRICH
    if stage in ("all", "enrich"):
        print("🔎 Stage 4: Enrichment...")
        dedup_dir = Path("data/deduped")
        dedup_files = sorted(dedup_dir.glob("deduped_*.json"))
        if not dedup_files:
            print("   → No deduped data to enrich")
            return []
        with open(dedup_files[-1], encoding="utf-8") as f:
            dedup_items_data = json.load(f)
        enriched = enrich_batch(dedup_items_data, config)
        # Save
        output_dir = Path("data/enriched")
        output_dir.mkdir(parents=True, exist_ok=True)
        ts = datetime.now().strftime("%Y%m%d_%H%M%S")
        with open(output_dir / f"enriched_{ts}.json", "w", encoding="utf-8") as f:
            json.dump(enriched, f, ensure_ascii=False, indent=2)
        print(f"   → {len(enriched)} items enriched\n")

        if stage == "enrich":
            return enriched

    # Stage 5: BRIEFING
    if stage in ("all", "briefing"):
        print("📝 Stage 5: Generating briefing...")
        enrich_dir = Path("data/enriched")
        enrich_files = sorted(enrich_dir.glob("enriched_*.json"))
        if not enrich_files:
            # Fallback to deduped
            dedup_dir = Path("data/deduped")
            dedup_files = sorted(dedup_dir.glob("deduped_*.json"))
            if dedup_files:
                with open(dedup_files[-1], encoding="utf-8") as f:
                    items = json.load(f)
            else:
                print("   → No data for briefing")
                return []
        else:
            with open(enrich_files[-1], encoding="utf-8") as f:
                items = json.load(f)

        briefing_text = generate_briefing(items, config)
        filepath = save_briefing(briefing_text, config)
        print(f"   → Briefing saved: {filepath}\n")

        # Print summary
        print(f"{'='*60}")
        print(f"✅ Pipeline complete!")
        print(f"{'='*60}")

        return items


def main():
    parser = argparse.ArgumentParser(description="News Intelligence Pipeline")
    parser.add_argument("--config", default="config/sources.json", help="Config file path")
    parser.add_argument("--stage", choices=["all", "fetch", "score", "dedup", "enrich", "briefing"],
                        default="all", help="Stage to run")
    parser.add_argument("--hours", type=int, help="Time window in hours")
    args = parser.parse_args()

    run_pipeline(config_path=args.config, stage=args.stage, hours=args.hours)


if __name__ == "__main__":
    main()
