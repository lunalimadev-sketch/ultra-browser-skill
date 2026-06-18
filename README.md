# Ultra Browser Skill 🦉

**Full browser control for OpenClaw — not read-only.**

Merges OpenClaw's native browser capabilities with the best innovations from [browser-control-skill](https://github.com/d-wwei/browser-control-skill).

## What It Does

- **Click** buttons, links, menu items — including React/Vue dynamic elements
- **Fill forms** — native inputs, React controlled components, contenteditable
- **Upload files** — bypasses OS file dialog
- **Type in rich text editors** — Notion, Slack, Gmail via CDP Input.insertText
- **Keyboard shortcuts** — Enter, Tab, Ctrl+A, custom combos
- **Operate dropdowns** — standard and custom div-based
- **Screenshots with element annotations** — numbered interactive elements
- **Console & network interception** — debug web apps in real-time
- **Background parallel research** — multiple tabs, multiple sub-agents, zero interference

## Safety First 🔒

**3-Layer Protection:**

| Layer | What It Does | Example |
|-------|-------------|---------|
| **Domain Blocklist** | Sensitive domains → read-only | Banks, PayPal, AWS Console |
| **Element Protection** | Dangerous elements → blocked | Password fields, payment buttons |
| **Action Confirmation** | Irreversible actions → ask first | Submit, send, delete |

## Modes

| Mode | How It Works | Your Experience |
|------|-------------|-----------------|
| **Foreground** (`here`) | Operates on your visible tab | Watch AI work, every step visible |
| **Background** (`bg`) | Opens dedicated tabs | Your tabs stay untouched |
| **Auto** (`auto`) | Detects best mode | Default when not specified |

## Smart Routing

```
web_search → web_fetch → browser read → browser act → browser full
 (lightest)                                          (most powerful)
```

Don't open a browser for a Google query. Start light, escalate only when needed.

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

## What's Borrowed from browser-control-skill

✅ 3-layer safety system (domain blocklist, element protection, action confirmation)
✅ Site memory concept (auto-accumulating platform patterns)
✅ Smart tool routing (lightest tool first)
✅ Background parallel sub-agents
✅ Foreground/background/auto mode switching

## What's Native from OpenClaw

✅ `browser` tool with full act/snapshot/upload/console support
✅ `profile="user"` for existing Chrome sessions
✅ Tab management with labels
✅ `sessions_spawn` for sub-agents
✅ Stale ref recovery (snapshot → re-ref → retry)
✅ `web_search` and `web_fetch` for light queries
✅ Cross-platform (Windows, macOS, Linux)

## Modules

| Module | Purpose |
|--------|---------|
| `modules/site-memory.json` | Accumulated site patterns & selectors |
| `modules/safety-rules.json` | Domain blocklist + element protection |
| `modules/tool-router.md` | Smart routing decision tree |

## Requirements

- OpenClaw with `browser` tool enabled
- Chrome or Chromium-based browser
- For background mode: Node.js (for CDP proxy)

## License

MIT — Built for OpenClaw Agency by Luna 🦉

## Credits

Inspired by [browser-control-skill](https://github.com/d-wwei/browser-control-skill) by d-wwei.
Adapted and extended for the OpenClaw ecosystem.
