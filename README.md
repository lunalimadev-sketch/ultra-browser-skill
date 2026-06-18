# Ultra Browser Skill v2 🦉

**Full browser control for OpenClaw — not read-only.**

Merges OpenClaw's native browser capabilities with innovations from:
- [browser-control-skill](https://github.com/d-wwei/browser-control-skill) — safety, site memory, tool routing
- [agent-browser-skill](https://github.com/00OO666/agent-browser-skill) — session persistence, batch, refs
- [dev-browser](https://github.com/SawyerHood/dev-browser) — sandboxed JS, computer-use tools
- [browser-use](https://github.com/browser-use/browser-use) — agent loop, custom tools

## What It Does

- **Click** buttons, links, menu items — including React/Vue dynamic elements
- **Fill forms** — native inputs, React controlled components, contenteditable
- **Upload files** — bypasses OS file dialog
- **Type in rich text editors** — Notion, Slack, Gmail via CDP Input.insertText
- **Keyboard shortcuts** — Enter, Tab, Ctrl+A, custom combos
- **Operate dropdowns** — standard and custom div-based
- **Screenshots with element annotations** — numbered interactive elements
- **Session persistence** — login once, stay logged in forever
- **Batch commands** — execute multiple actions in one call
- **Ref-based selection** — @e1, @e2 refs (93% less context than CSS)
- **Sandboxed JS execution** — run scripts without host risk
- **Computer-use tools** — pixel/vision + DOM-id tiers
- **Network interception** — monitor API calls in real-time
- **Background parallel research** — multiple tabs, zero interference
- **Custom tools** — agent creates reusable tools on demand

## Safety First 🔒

**3-Layer Protection:**

| Layer | What It Does | Example |
|-------|-------------|---------|
| **Domain Blocklist** | Sensitive domains → read-only | Banks, PayPal, AWS Console |
| **Element Protection** | Dangerous elements → blocked | Password fields, payment buttons |
| **Action Confirmation** | Irreversible actions → ask first | Submit, send, delete |

**Override:** "I confirm this action on [domain]" or "trust [site] for this session"

## Modes

| Mode | How It Works | Your Experience |
|------|-------------|-----------------|
| **Foreground** (`here`) | Operates on your visible tab | Watch AI work, every step visible |
| **Background** (`bg`) | Opens dedicated tabs | Your tabs stay untouched |
| **Auto** (`auto`) | Detects best mode | Default when not specified |

## Smart Routing

```
web_search → web_fetch → browser read → browser act → browser batch → background
 (lightest)                                                          (most powerful)
```

## Session Persistence

```bash
# Login once, stay logged in forever
/ultra-browse profile create linkedin
/ultra-browse --profile linkedin check my feed
```

Each profile saves cookies, localStorage, and session state. Separate profiles per account.

## Batch Commands

```bash
# Execute multiple actions in one call
/ultra-browse batch \
  "open https://linkedin.com/feed" \
  "snapshot -i" \
  "screenshot /tmp/feed.png" \
  "close"
```

## Quick Start

```bash
# Copy to your OpenClaw skills directory
cp -r ultra-browser-skill ~/.openclaw/workspace/skills/

# Or clone
git clone https://github.com/lunalimadev-sketch/ultra-browser-skill.git \
  ~/.openclaw/workspace/skills/ultra-browser-skill
```

## Usage

Just describe what you want — the skill handles mode selection, safety checks, and tool routing:

- "Fill out this form on the current page"
- "Research these 5 competitors in the background"
- "Check my Jira dashboard"
- "Post this article on LinkedIn"
- "Extract all ticket statuses from this sprint"
- "Take a screenshot of example.com and analyze it"

## Modules

| Module | Purpose |
|--------|---------|
| `modules/site-memory.json` | Accumulated site patterns & selectors |
| `modules/safety-rules.json` | Domain blocklist + element protection |
| `modules/tool-router.md` | Smart routing decision tree |
| `modules/custom-tools.json` | Agent-created reusable tools |

## Requirements

- OpenClaw with `browser` tool enabled
- Chrome or Chromium-based browser
- For background mode: Node.js (for CDP proxy)

## What's Borrowed

| Feature | Source | Status |
|---------|--------|--------|
| 3-layer safety system | browser-control-skill | ✅ Implemented |
| Site memory | browser-control-skill | ✅ Implemented |
| Smart tool routing | browser-control-skill | ✅ Implemented |
| Session persistence | agent-browser-skill | ✅ Implemented |
| Batch commands | agent-browser-skill | ✅ Implemented |
| Ref-based selection | agent-browser-skill | ✅ Implemented |
| Sandboxed JS | dev-browser | ✅ Implemented |
| Computer-use tools | dev-browser | ✅ Implemented |
| Persistent pages | dev-browser | ✅ Implemented |
| Custom tools | browser-use | ✅ Implemented |
| Background parallel | browser-control-skill | ✅ Implemented |

## License

MIT — Built for OpenClaw Agency by Luna 🦉
