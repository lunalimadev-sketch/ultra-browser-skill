---
name: ultra-browser-skill
description: Advanced browser control for OpenClaw — full page control, safety boundaries, site memory, session persistence, sandboxed JS execution, computer-use tools, background parallel ops, and smart tool routing. Merges innovations from browser-control-skill, agent-browser-skill, dev-browser, and browser-use.
version: 2.0.0
author: Luna (OpenClaw Agency)
---

# Ultra Browser Skill v2 🦉

Full browser control for OpenClaw. Not read-only — click, fill, upload, type, keyboard shortcuts, dropdowns, console interception, screenshots with element annotations, sandboxed scripts, computer-use tools, and session persistence.

## What's New in v2

- **Session Persistence** — login once, stay logged in forever (profiles per site)
- **Batch Commands** — execute multiple actions in one call
- **Ref-based Element Selection** — @e1, @e2 refs (93% less context than CSS selectors)
- **Sandboxed JS Execution** — run scripts without host risk
- **Computer-use Tools** — pixel/vision tier + DOM-id tier for two interaction modes
- **Persistent Pages** — navigate once, reuse across multiple scripts
- **Custom Tools** — agent can create tools on demand
- **Element Annotations** — screenshots with numbered interactive elements
- **Network Interception** — monitor requests/responses in real-time

## Core Principle

**Shared browser, safe boundaries.** AI operates the user's real Chrome with real login sessions. Safety is non-negotiable.

## Quick Start

```
/ultra-browse here fill out this form on the current page
/ultra-browse bg research these 5 competitors
/ultra-browse auto check my Jira dashboard
```

## Operating Modes

### Foreground (`here`)
- Uses OpenClaw `browser` tool with `profile="user"`
- Operates on the user's visible tab
- User watches every step
- Best for: form filling, single-page tasks, when user wants to supervise

### Background (`bg`)
- Uses `browser open` with dedicated labels
- Each task gets its own tab — user's tabs unaffected
- Parallel sub-agents for multi-site research
- Best for: research, data extraction, multi-tab workflows

### Auto (`auto`)
- Detects foreground vs background based on context
- If user is on the target page → foreground
- If task needs a new page → background
- Default mode when not specified

## Session Persistence

**Login once, stay logged in forever.** Browser profiles save cookies, localStorage, and session state.

### How It Works
- Each site gets its own profile directory
- Cookies and session data persist across sessions
- No need to re-login on repeated visits

### Profile Management

```
# Create/use a profile for a site
/ultra-browse profile create linkedin
/ultra-browse profile create github-work
/ultra-browse profile create github-personal

# Use profile for a task
/ultra-browse --profile linkedin check my feed

# List saved profiles
/ultra-browse profile list

# Delete a profile
/ultra-browse profile delete old-site
```

### Profile Directory Structure
```
~/.openclaw/workspace/skills/ultra-browser-skill/profiles/
├── linkedin/
│   ├── cookies.json
│   ├── localStorage/
│   └── session-state.json
├── github/
├── instagram/
└── gmail/
```

### Best Practices
- **One profile per account** — work LinkedIn ≠ personal LinkedIn
- **Never commit profiles** — they contain auth tokens
- **Backup important profiles** — just copy the directory
- **Separate sensitive sites** — banking gets its own profile (read-only)

## Batch Commands

Execute multiple browser actions in a single call — faster execution, less overhead.

### Syntax
```
/ultra-browse batch \
  "open https://linkedin.com/feed" \
  "snapshot -i" \
  "screenshot /tmp/feed.png" \
  "close"
```

### Use Cases
- **Multi-step flows:** login → navigate → extract → close
- **Data collection:** open 5 URLs → snapshot each → extract data
- **Automation scripts:** repetitive tasks with known steps

### Implementation
```json
{
  "action": "batch",
  "commands": [
    {"action": "open", "url": "https://linkedin.com/feed", "label": "linkedin"},
    {"action": "snapshot", "targetId": "linkedin", "refs": "aria"},
    {"action": "screenshot", "targetId": "linkedin", "paths": ["/tmp/feed.png"]},
    {"action": "close", "targetId": "linkedin"}
  ]
}
```

## Ref-based Element Selection

Efficient element targeting using @e1, @e2 refs instead of CSS selectors.

### How It Works
1. `snapshot` returns numbered refs for every interactive element
2. Use refs in subsequent `act` calls
3. Refs are stable within a snapshot but go stale after navigation

### Example
```json
// Step 1: Get refs
{"action": "snapshot", "targetId": "page1", "refs": "aria"}
// Returns: e42 (input field), e43 (button), e44 (link)

// Step 2: Use refs
{"action": "act", "kind": "fill", "ref": "e42", "text": "Hello"}
{"action": "act", "kind": "click", "ref": "e43"}
```

### Benefits
- **93% less context** than CSS selectors
- **Stable within snapshot** — no brittle selectors
- **Visual mapping** — screenshot annotations match refs

## Sandboxed JavaScript Execution

Run JavaScript in a sandboxed QuickJS environment — no host filesystem or network access.

### When to Use
- Complex DOM manipulation
- Data extraction from nested elements
- Custom calculations on page data
- Testing/prototyping interactions

### Implementation
```json
{
  "action": "act",
  "kind": "evaluate",
  "fn": "() => { const items = document.querySelectorAll('.result-item'); return Array.from(items).map(el => ({title: el.querySelector('h3')?.textContent, url: el.querySelector('a')?.href})); }",
  "targetId": "page1"
}
```

### Safety
- Scripts run in isolated context
- No access to host filesystem
- No access to other tabs
- No network access (except page's own requests)
- Timeout: 10 seconds max

## Computer-use Tools

Two tiers of interaction for maximum flexibility.

### Pixel/Vision Tier (`screenshot` + coordinates)
- Take screenshot → identify elements by pixel position
- Click at coordinates: `{"action": "act", "kind": "clickCoords", "x": 450, "y": 300}`
- Best for: visual elements, canvas, custom UIs
- Works when: DOM refs are unavailable

### DOM-id Tier (`snapshot` + refs)
- DOM snapshot → identify elements by @e refs
- Click by ref: `{"action": "act", "kind": "click", "ref": "e42"}`
- Best for: forms, buttons, links, standard UI
- Works when: elements are in DOM

### Element Annotations (Screenshots with Numbers)
```json
{"action": "screenshot", "targetId": "page1", "labels": true}
```
Returns screenshot with every interactive element numbered → matches snapshot refs.

## Persistent Pages

Navigate once, reuse across multiple actions — don't reload between operations.

### How It Works
1. Open a page with a label
2. Perform multiple actions on that labeled tab
3. Page state persists (scroll position, form data, JS state)
4. Close when done

### Example
```json
// Open once
{"action": "open", "url": "https://notion.so/workspace", "label": "notion"}

// Multiple interactions (page stays loaded)
{"action": "act", "kind": "click", "ref": "e42", "targetId": "notion"}
{"action": "act", "kind": "type", "ref": "e42", "text": "Meeting notes", "targetId": "notion"}
{"action": "act", "kind": "press", "key": "Tab", "targetId": "notion"}
{"action": "act", "kind": "type", "ref": "e43", "text": "Content here", "targetId": "notion"}

// Close when done
{"action": "close", "targetId": "notion"}
```

## Network Interception

Monitor and log network requests in real-time — debug API calls, track loading, capture responses.

### Implementation
```json
// Enable network logging
{"action": "act", "kind": "evaluate", "fn": "() => { window.__netLog = []; const origFetch = window.fetch; window.fetch = async (...args) => { const res = await origFetch(...args); window.__netLog.push({url: args[0], status: res.status, time: Date.now()}); return res; }; return 'network logging enabled'; }", "targetId": "page1"}

// Get logged requests
{"action": "act", "kind": "evaluate", "fn": "() => window.__netLog", "targetId": "page1"}
```

## Safety System (3 Layers)

### Layer 1: Domain Blocklist
Sensitive domains are **read-only** by default:

**Banking:** Itaú, Bradesco, Nubank, Caixa, BB, Chase, Wells Fargo
**Payments:** PayPal, Stripe, Mercado Pago, PagSeguro
**Auth:** accounts.google.com, okta.com, auth0.com
**Cloud:** console.aws.amazon.com, console.cloud.google.com, portal.azure.com
**Government:** gov.br, receita.fazenda.gov.br
**Crypto:** metamask.io, phantom.app

→ Agent can READ but NEVER click/fill/submit
→ Override: "I confirm this action on [domain]"

### Layer 2: Element-Level Protection
- **Password fields:** NEVER auto-filled → ask user
- **Payment buttons:** "Pay", "Checkout", "Comprar", "Pagar" → blocked
- **Delete actions:** "Delete", "Excluir", "Remover" → require confirmation
- **Send actions:** "Send", "Submit", "Publicar" → confirm unless pre-authorized

### Layer 3: Action Confirmation
Before irreversible actions:
- Submitting forms (unless user said "fill and submit")
- Sending messages/emails
- Deleting data
- Making purchases
- Changing account settings

**User can pre-authorize:** "Fill and submit this form" skips confirmation for that specific form.

## Smart Tool Routing

Start light, escalate only when needed:

```
Level 1: web_search    → Simple searches, public info
Level 2: web_fetch     → Public page content extraction
Level 3: browser read  → Snapshot/read authenticated pages
Level 4: browser act   → Click, fill, upload on pages
Level 5: browser full  → Multi-step flows, batch commands
Level 5+: background   → Parallel sub-agents, multiple tabs
```

**Rule:** Don't open a browser for a Google query. Start light. Escalate only when needed.

## Background Parallel Research

For multi-site research, spawn sub-agents:

```
Main Agent: "Research these 5 competitors"
 ├─ Sub-Agent 1 → competitor-a.com (browser open label="research-1")
 ├─ Sub-Agent 2 → competitor-b.com (browser open label="research-2")
 ├─ Sub-Agent 3 → competitor-c.com (browser open label="research-3")
 ├─ Sub-Agent 4 → competitor-d.com (browser open label="research-4")
 └─ Sub-Agent 5 → competitor-e.com (browser open label="research-5")
 → Each researches independently, closes its tab, reports back
 → Main agent consolidates results
```

**Implementation:**
1. Use `sessions_spawn` for each sub-agent
2. Each sub-agent uses `browser open` with unique label
3. Sub-agents use `browser snapshot` + `web_fetch` as needed
4. Results collected via `sessions_yield`

## Site Memory

Agent remembers patterns for sites it has operated on:

### What's Stored
- Login flows and 2FA patterns
- Onboarding steps (what can be skipped)
- Effective selectors and ref patterns
- Known pitfalls and workarounds
- Successful strategies

### Auto-Accumulation
Every successful interaction adds to site memory. Over time, the agent gets faster on repeated sites.

### Storage
`modules/site-memory.json` — JSON file with per-site patterns

### Example Entry
```json
{
  "linkedin.com": {
    "login_flow": "email → password → 2FA (email code)",
    "onboarding": {
      "steps": ["emailConfirmation", "ageCheck", "jobSeekerStatus", "photoUpload", "contactImport", "connectionSuggestions", "followSuggestions", "appDownload"],
      "all_skippable": true,
      "skip_strategy": "click 'Skip' or 'Pular' on each step"
    },
    "selectors": {
      "codeInput": "input[aria-label*='code']",
      "continueButton": "button:has-text('Continue')",
      "skipLink": "a:has-text('Skip')"
    },
    "tips": [
      "Progress bar shows % completion",
      "Photo upload can be skipped",
      "Connection suggestions can be skipped"
    ],
    "interactions": 5
  }
}
```

## Custom Tools

Agent can create and register tools on demand for repetitive tasks.

### How It Works
1. Agent identifies a repetitive pattern
2. Creates a tool definition with parameters
3. Saves tool to `modules/custom-tools.json`
4. Reuses tool in future sessions

### Example
```json
{
  "name": "linkedin_post",
  "description": "Create a LinkedIn post with given content",
  "parameters": {
    "content": {"type": "string", "description": "Post content"},
    "image": {"type": "string", "description": "Optional image path"}
  },
  "steps": [
    "Navigate to linkedin.com/feed",
    "Click 'Start a post' button",
    "Type content",
    "If image provided, click photo icon and upload",
    "Click 'Post' button"
  ]
}
```

## Operating Loop

1. **Check state** — `browser status` or `browser profiles` before acting
2. **Choose mode** — foreground (here), background (bg), or auto
3. **Safety check** — domain blocklist + element protection
4. **Tool routing** — start with lightest tool, escalate as needed
5. **Read before act** — snapshot before every click/fill
6. **Act narrowly** — one action at a time, snapshot between actions
7. **Recover from staleness** — re-snapshot if refs go stale
8. **Update site memory** — save what worked
9. **Report blockers** — if manual step needed, tell user exactly what

## Key Commands Reference

### Status & Setup
```json
{"action": "status"}                    // Browser available?
{"action": "profiles"}                  // Which profiles?
{"action": "tabs"}                      // List open tabs
```

### Tab Management
```json
{"action": "open", "url": "...", "label": "task1"}   // Open labeled tab
{"action": "focus", "targetId": "task1"}              // Switch to tab
{"action": "close", "targetId": "t3"}                 // Close tab
```

### Reading
```json
{"action": "snapshot", "targetId": "task1", "refs": "aria"}  // DOM snapshot
{"action": "screenshot", "targetId": "task1", "labels": true} // Annotated screenshot
```

### Acting
```json
{"action": "act", "kind": "click", "ref": "e42", "targetId": "task1"}
{"action": "act", "kind": "type", "ref": "e42", "text": "hello", "targetId": "task1"}
{"action": "act", "kind": "fill", "ref": "e42", "text": "hello", "targetId": "task1"}
{"action": "act", "kind": "select", "ref": "e42", "values": ["opt1"], "targetId": "task1"}
{"action": "act", "kind": "press", "key": "Enter", "targetId": "task1"}
{"action": "act", "kind": "hover", "ref": "e42", "targetId": "task1"}
{"action": "act", "kind": "clickCoords", "x": 450, "y": 300, "targetId": "task1"}
```

### File Upload
```json
{"action": "upload", "paths": ["C:\\file.pdf"], "targetId": "task1"}
```

### Batch
```json
{
  "action": "batch",
  "commands": [
    {"action": "open", "url": "...", "label": "t1"},
    {"action": "snapshot", "targetId": "t1"},
    {"action": "screenshot", "targetId": "t1"},
    {"action": "close", "targetId": "t1"}
  ]
}
```

### Console & Network
```json
{"action": "console", "targetId": "task1"}
```

### JavaScript Evaluation
```json
{"action": "act", "kind": "evaluate", "fn": "document.title", "targetId": "task1"}
```

## Stale Ref Recovery

If action fails with missing/stale ref:
1. Re-snapshot same `targetId`
2. Find current visible control
3. Retry once with new ref
4. If UI changed to blocker state → report blocker, don't loop

## Modules

| Module | Purpose |
|--------|---------|
| `modules/site-memory.json` | Accumulated site patterns & selectors |
| `modules/safety-rules.json` | Domain blocklist + element protection |
| `modules/tool-router.md` | Smart routing decision tree |
| `modules/custom-tools.json` | Agent-created reusable tools |
| `modules/session-store/` | Persistent browser profiles |

## Credits

Built for OpenClaw Agency by Luna 🦉

Inspired by:
- [browser-control-skill](https://github.com/d-wwei/browser-control-skill) — safety system, site memory, tool routing
- [agent-browser-skill](https://github.com/00OO666/agent-browser-skill) — session persistence, batch commands, ref selection
- [dev-browser](https://github.com/SawyerHood/dev-browser) — sandboxed JS, computer-use tools, persistent pages
- [browser-use](https://github.com/browser-use/browser-use) — agent loop, custom tools, LLM routing

## License

MIT
