# Smart Tool Routing

## Decision Tree

```
User request
  │
  ├─ Simple search / public info?
  │   └─ YES → web_search (Level 1)
  │
  ├─ Need content from specific URL (public)?
  │   └─ YES → web_fetch (Level 2)
  │
  ├─ Need to read authenticated page?
  │   └─ YES → browser snapshot (Level 3)
  │
  ├─ Need to click/fill/upload on a page?
  │   └─ YES → browser act (Level 4)
  │
  ├─ Multi-step flow (login, onboarding, checkout)?
  │   └─ YES → browser full (Level 5)
  │
  └─ Need to research multiple sites in parallel?
      └─ YES → background sub-agents (Level 5+)
```

## Level Details

### Level 1: web_search
**When:** Simple queries, public info, fact-checking
**Cost:** Lowest
**Example:** "What's the market cap of Tesla?"

### Level 2: web_fetch
**When:** Need content from a specific public URL
**Cost:** Low
**Example:** "Extract the text from this article: https://..."

### Level 3: browser read (snapshot)
**When:** Page requires login or is dynamic (SPA)
**Cost:** Medium
**Example:** "What does my LinkedIn feed show?"

### Level 4: browser act (click/fill)
**When:** Need to interact with page elements
**Cost:** Medium-High
**Example:** "Click the 'New Post' button on LinkedIn"

### Level 5: browser full (multi-step)
**When:** Complex flows requiring multiple actions
**Cost:** High
**Example:** "Log into Instagram and post a photo"

### Level 5+: background sub-agents
**When:** Researching multiple sites simultaneously
**Cost:** Highest (but parallel = faster)
**Example:** "Research these 5 competitors' pricing pages"

## Routing Rules

1. **Always start at Level 1** — don't open a browser for a Google query
2. **Escalate only when needed** — if web_fetch fails, try browser read
3. **Prefer background** for multi-site tasks — user's browser stays clean
4. **Use labels** for all tabs — easy reuse and cleanup
5. **Close tabs when done** — don't leak browser resources

## Anti-Patterns

❌ Opening browser for a simple search
❌ Using browser act when snapshot would suffice
❌ Running 5 serial background tasks when parallel is possible
❌ Leaving tabs open after task completion
❌ Not checking domain blocklist before acting
