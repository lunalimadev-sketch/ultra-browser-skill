"""
News Intelligence - Multi-Source Collector
Fetches news from RSS, HN, Reddit, Twitter, GitHub, Telegram.
Adapted from Horizon methodology.
"""

import json
import hashlib
import re
from datetime import datetime, timedelta
from pathlib import Path
from typing import Optional
from dataclasses import dataclass, asdict

try:
    import requests
except ImportError:
    import urllib.request
    import urllib.parse
    import json as _json

    class _FakeResponse:
        def __init__(self, data, status=200):
            self._data = data
            self.status_code = status
        def json(self):
            return self._data
        def raise_for_status(self):
            if self.status_code >= 400:
                raise Exception(f"HTTP {self.status_code}")

    class requests:
        @staticmethod
        def get(url, **kwargs):
            try:
                req = urllib.request.Request(url, headers=kwargs.get("headers", {}))
                with urllib.request.urlopen(req, timeout=30) as resp:
                    data = _json.loads(resp.read().decode())
                    return _FakeResponse(data)
            except Exception as e:
                return _FakeResponse({}, 500)


@dataclass
class NewsItem:
    title: str
    url: str
    source: str
    category: str
    score: float = 0.0
    summary: str = ""
    context: str = ""
    comments: str = ""
    published: str = ""
    fetched_at: str = ""
    content_hash: str = ""

    def __post_init__(self):
        if not self.fetched_at:
            self.fetched_at = datetime.now().isoformat()
        if not self.content_hash:
            self.content_hash = hashlib.md5(
                (self.title.lower().strip() + self.url).encode()
            ).hexdigest()


class NewsCollector:
    def __init__(self, config: dict):
        self.config = config
        self.items: list[NewsItem] = []

    def collect_all(self, hours: int = 24) -> list[NewsItem]:
        sources = self.config.get("sources", {})
        cutoff = datetime.now() - timedelta(hours=hours)

        if sources.get("hackernews", {}).get("enabled"):
            self._fetch_hackernews(sources["hackernews"], cutoff)
        if sources.get("reddit", {}).get("enabled"):
            self._fetch_reddit(sources["reddit"], cutoff)
        if sources.get("rss", {}).get("enabled"):
            self._fetch_rss(sources["rss"], cutoff)
        if sources.get("twitter", {}).get("enabled"):
            self._fetch_twitter(sources["twitter"], cutoff)
        if sources.get("github", {}).get("enabled"):
            self._fetch_github(sources["github"], cutoff)

        return self.items

    def _fetch_hackernews(self, cfg: dict, cutoff: datetime):
        try:
            limit = cfg.get("limit", 30)
            min_score = cfg.get("min_score", 100)
            resp = requests.get(
                "https://hacker-news.firebaseio.com/v0/topstories.json"
            )
            if resp.status_code != 200:
                return
            story_ids = resp.json()[:limit]

            for sid in story_ids:
                try:
                    story_resp = requests.get(
                        f"https://hacker-news.firebaseio.com/v0/item/{sid}.json"
                    )
                    if story_resp.status_code != 200:
                        continue
                    story = story_resp.json()
                    if not story or story.get("score", 0) < min_score:
                        continue
                    pub_time = datetime.fromtimestamp(story.get("time", 0))
                    if pub_time < cutoff:
                        continue

                    self.items.append(NewsItem(
                        title=story.get("title", ""),
                        url=story.get("url", f"https://news.ycombinator.com/item?id={sid}"),
                        source="hackernews",
                        category=cfg.get("category", "tech"),
                        published=pub_time.isoformat(),
                    ))
                except Exception:
                    continue
        except Exception as e:
            print(f"[HN] Error: {e}")

    def _fetch_reddit(self, cfg: dict, cutoff: datetime):
        try:
            subreddits = cfg.get("subreddits", ["artificial"])
            limit = cfg.get("limit", 20)
            headers = {"User-Agent": "NewsIntelligence/1.0"}

            for sub in subreddits:
                try:
                    resp = requests.get(
                        f"https://www.reddit.com/r/{sub}/hot.json?limit={limit}",
                        headers=headers
                    )
                    if resp.status_code != 200:
                        continue
                    data = resp.json()
                    for post in data.get("data", {}).get("children", []):
                        p = post.get("data", {})
                        pub_time = datetime.fromtimestamp(p.get("created_utc", 0))
                        if pub_time < cutoff:
                            continue
                        self.items.append(NewsItem(
                            title=p.get("title", ""),
                            url=f"https://reddit.com{p.get('permalink', '')}",
                            source=f"reddit/{sub}",
                            category=cfg.get("category", "tech"),
                            published=pub_time.isoformat(),
                        ))
                except Exception:
                    continue
        except Exception as e:
            print(f"[Reddit] Error: {e}")

    def _fetch_rss(self, cfg: dict, cutoff: datetime):
        try:
            feeds = cfg.get("feeds", [])
            for feed in feeds:
                try:
                    resp = requests.get(feed["url"])
                    if resp.status_code != 200:
                        continue
                    content = resp.text if hasattr(resp, 'text') else json.dumps(resp.json())
                    items = re.findall(r'<item>(.*?)</item>', content, re.DOTALL)
                    for item_xml in items[:cfg.get("limit", 15)]:
                        title_match = re.search(r'<title[^>]*>(.*?)</title>', item_xml, re.DOTALL)
                        link_match = re.search(r'<link[^>]*>(.*?)</link>', item_xml, re.DOTALL)
                        if not title_match:
                            continue
                        title = re.sub(r'<!\[CDATA\[(.*?)\]\]>', r'\1', title_match.group(1)).strip()
                        link = re.sub(r'<!\[CDATA\[(.*?)\]\]>', r'\1', link_match.group(1)).strip() if link_match else ""
                        self.items.append(NewsItem(
                            title=title,
                            url=link,
                            source=f"rss/{feed.get('name', 'unknown')}",
                            category=feed.get("category", cfg.get("category", "tech")),
                        ))
                except Exception:
                    continue
        except Exception as e:
            print(f"[RSS] Error: {e}")

    def _fetch_twitter(self, cfg: dict, cutoff: datetime):
        # Twitter/X requires auth - mark as placeholder
        # In production, use browser automation or API
        pass

    def _fetch_github(self, cfg: dict, cutoff: datetime):
        try:
            repos = cfg.get("repos", [])
            headers = {"Accept": "application/vnd.github.v3+json"}
            for repo in repos:
                try:
                    resp = requests.get(
                        f"https://api.github.com/repos/{repo}/releases/latest",
                        headers=headers
                    )
                    if resp.status_code != 200:
                        continue
                    release = resp.json()
                    pub_time = datetime.fromisoformat(
                        release.get("published_at", "").replace("Z", "+00:00")
                    ).replace(tzinfo=None)
                    if pub_time < cutoff:
                        continue
                    self.items.append(NewsItem(
                        title=f"{repo}: {release.get('name', 'New Release')}",
                        url=release.get("html_url", ""),
                        source=f"github/{repo}",
                        category=cfg.get("category", "releases"),
                        published=pub_time.isoformat(),
                    ))
                except Exception:
                    continue
        except Exception as e:
            print(f"[GitHub] Error: {e}")

    def save_raw(self, output_dir: str):
        path = Path(output_dir)
        path.mkdir(parents=True, exist_ok=True)
        ts = datetime.now().strftime("%Y%m%d_%H%M%S")
        with open(path / f"raw_{ts}.json", "w", encoding="utf-8") as f:
            json.dump([asdict(item) for item in self.items], f, ensure_ascii=False, indent=2)
        print(f"[Collector] Saved {len(self.items)} items to {output_dir}")


if __name__ == "__main__":
    import sys
    config_path = sys.argv[1] if len(sys.argv) > 1 else "config/sources.json"
    with open(config_path, encoding="utf-8") as f:
        config = json.load(f)
    collector = NewsCollector(config)
    items = collector.collect_all(hours=config.get("general", {}).get("hours", 24))
    collector.save_raw("data/raw")
    print(f"Collected {len(items)} items")
