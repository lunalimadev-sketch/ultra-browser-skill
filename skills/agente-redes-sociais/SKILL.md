---
name: agente-redes-sociais
description: Posta no X/Twitter via xurl CLI (API oficial) com browser automation como fallback. Quality gates obrigatórios antes de qualquer post público.
---

# AgenteRedesSociais

Posta no X/Twitter. API oficial (xurl) é o método principal. Browser automation é fallback.

## Account

- **Email:** lunalimadev@gmail.com
- **Método principal:** xurl CLI
- **Fallback:** browser tool (OpenClaw)

## Pre-Post Checklist (OBRIGATÓRIO)

Before ANY public action, verify:

1. **Login status:** `xurl auth status` — if not authenticated, STOP
2. **Rate limits:** `xurl rate-limits` — check remaining tweets/hour
3. **Content review:** spelling, links, mentions, tone
4. **Account confirmation:** correct account, not alt/throwaway
5. **Char count:** ≤280 (non-Premium) or ≤25,000 (Premium)

Anti-patterns:
- ❌ Posting without checking login → silent failure or wrong account
- ❌ Ignoring rate limits → shadowban
- ❌ Forgetting @mentions → unintended public callouts
- ❌ No char count check → truncated post

## Method 1: xurl CLI (Preferred)

```powershell
# Install
npm install -g @xdevplatform/xurl

# Auth (one-time)
xurl auth login

# Post tweet
xurl tweet post --text "Your tweet text here"

# Reply to tweet
xurl tweet reply --tweet-id <ID> --text "Reply text"

# Thread
xurl tweet post --text "1/3 First tweet" --thread \
  --thread-text "2/3 Second tweet" \
  --thread-text "3/3 Third tweet"

# Quote tweet
xurl tweet quote --tweet-id <ID> --text "Your take"

# Delete tweet
xurl tweet delete --tweet-id <ID>
```

## Method 2: Browser Fallback

When xurl is unavailable or rate-limited:

1. `browser action=start profile=openclaw`
2. Navigate to `https://x.com/compose/post`
3. Type content in compose box
4. Click Post button
5. Verify post appeared on timeline

## Workflow

```
1. VERIFY   → login + rate limits
2. COMPOSE  → write content, review, char count
3. CONFIRM  → correct account? correct content?
4. POST     → xurl or browser
5. VERIFY   → confirm post is live
6. LOG      → timestamp + content + status → memory/YYYY-MM-DD.md
```

## Error Handling

| Error | Fix |
|-------|-----|
| `auth required` | Run `xurl auth login` |
| `rate limit` | Wait or use browser fallback |
| `tweet too long` | Trim to 280 chars |
| `suspended` | STOP — notify user immediately |
| `network error` | Retry once, then browser fallback |

## Logging

After every post, append to daily notes:
```
### Tweet Posted
- Time: YYYY-MM-DD HH:MM
- Content: [first 100 chars]...
- Method: xurl/browser
- Status: success/failed
- Tweet ID: [if available]
```
