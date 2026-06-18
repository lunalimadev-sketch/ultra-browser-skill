---
name: ultra-browser-skill
description: Advanced browser control for OpenClaw — full page control, safety boundaries, site memory, background parallel ops, and smart tool routing. Merges OpenClaw native browser capabilities with browser-control-skill innovations.
version: 1.0.0
author: Luna (OpenClaw Agency)
---

# Ultra Browser Skill

Full browser control for OpenClaw. Not read-only — click, fill, upload, type, keyboard shortcuts, dropdowns, console interception, screenshots with element annotations.

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

## Safety System (3 Layers)

### Layer 1: Domain Blocklist
Sensitive domains are **read-only** by default. Agent will NOT click, fill, or submit on these:

**Banking:** Chase, Wells Fargo, Bank of America, Itaú, Bradesco, Nubank, Banco do Brasil
**Payments:** PayPal, Stripe, Square, Mercado Pago, Pix (banking portals)
**Auth:** accounts.google.com, okta.com, auth0.com, login.microsoftonline.com
**Cloud:** console.aws.amazon.com, console.cloud.google.com, portal.azure.com
**Government:** gov.br, receita.fazenda.gov.br

→ Agent can READ data from these sites but NEVER click buttons or fill forms.
→ To override: user must explicitly say "I confirm this action on [domain]"

### Layer 2: Element-Level Protection
- **Password fields:** NEVER auto-filled. Always ask user.
- **Payment buttons:** "Pay", "Checkout", "Purchase", "Comprar", "Pagar", "Finalizar compra" → blocked
- **Delete actions:** "Delete", "Remove", "Excluir", "Remover" → require confirmation
- **File downloads:** Ask before downloading executables or sensitive files

### Layer 3: Action Confirmation
Before any irreversible action, agent asks:
- Submitting forms (unless user said "submit after filling")
- Sending messages/emails
- Deleting data
- Making purchases
- Changing account settings

**User can pre-authorize:** "Fill and submit this form" skips confirmation for that specific form.

## Smart Tool Routing

Not every task needs the browser. Agent routes to lightest tool:

```
Level 1: web_search    → Simple searches, public info
Level 2: web_fetch     → Public page content extraction
Level 3: browser read  → Snapshot/read authenticated pages
Level 4: browser act   → Click, fill, upload on pages
Level 5: browser full  → Multi-step flows, parallel ops
```

**Rule:** Start light. Escalate only when needed. Don't open a browser for a public API query.

## Background Parallel Research

For multi-site research, agent spawns sub-agents:

```
Main Agent: "Research these 5 competitors"
 ├─ Sub-Agent 1 → competitor-a.com (own tab via browser open label="research-1")
 ├─ Sub-Agent 2 → competitor-b.com (own tab via browser open label="research-2")
 ├─ Sub-Agent 3 → competitor-c.com (own tab via browser open label="research-3")
 ├─ Sub-Agent 4 → competitor-d.com (own tab via browser open label="research-4")
 └─ Sub-Agent 5 → competitor-e.com (own tab via browser open label="research-5")
 → Each researches independently, closes its tab, reports back
 → Main agent consolidates results
```

**Implementation in OpenClaw:**
1. Use `sessions_spawn` for each sub-agent
2. Each sub-agent uses `browser open` with unique label
3. Sub-agents use `browser snapshot` + `web_fetch` as needed
4. Results collected via `sessions_yield`

## Site Memory

Agent remembers patterns for sites it has operated on:

```json
{
  "linkedin.com": {
    "login_flow": "email → password → 2FA code from email",
    "onboarding_steps": ["ageConfirmation", "jobStatus", "photoSkip", "connectionsSkip"],
    " selectors": {
      "postButton": "button[aria-label='Start a post']",
      "codeInput": "input[name='pin']"
    },
    "tips": ["Onboarding can be skipped", "Code expires in 5 min"]
  },
  "instagram.com": {
    "signup_flow": "email → password → birthday → name → username → code",
    "code_source": "email (lunalimadev@gmail.com)",
    "tips": ["Codes arrive via email, not SMS", "Birthday must be 18+"]
  }
}
```

**Auto积累:** Every successful interaction adds to site memory.
**Location:** `skills/ultra-browser-skill/modules/site-memory.json`

## Operating Loop

1. **Check state** — `browser status` or `browser profiles` before acting
2. **Choose mode** — foreground (here), background (bg), or auto
3. **Safety check** — domain blocklist + element protection
4. **Tool routing** — start with lightest tool, escalate as needed
5. **Read before act** — snapshot before every click/fill
6. **Act narrowly** — one action at a time, snapshot between actions
7. **Recover from staleness** — re-snapshot if refs go stale
8. **Report blockers** — if manual step needed, tell user exactly what

## Key Commands Reference

### Status & Setup
```json
{ "action": "status" }                    // Browser available?
{ "action": "profiles" }                  // Which profiles?
{ "action": "tabs" }                      // List open tabs
```

### Tab Management
```json
{ "action": "open", "url": "...", "label": "task1" }   // Open labeled tab
{ "action": "focus", "targetId": "task1" }              // Switch to tab
{ "action": "close", "targetId": "t3" }                 // Close tab
```

### Reading
```json
{ "action": "snapshot", "targetId": "task1", "refs": "aria" }  // DOM snapshot
{ "action": "screenshot", "targetId": "task1" }                 // Visual screenshot
```

### Acting (foreground & background)
```json
{ "action": "act", "kind": "click", "ref": "e42", "targetId": "task1" }
{ "action": "act", "kind": "type", "ref": "e42", "text": "hello", "targetId": "task1" }
{ "action": "act", "kind": "fill", "ref": "e42", "text": "hello", "targetId": "task1" }
{ "action": "act", "kind": "select", "ref": "e42", "values": ["option1"], "targetId": "task1" }
{ "action": "act", "kind": "press", "key": "Enter", "targetId": "task1" }
{ "action": "act", "kind": "hover", "ref": "e42", "targetId": "task1" }
```

### File Upload
```json
{ "action": "upload", "paths": ["C:\\file.pdf"], "targetId": "task1" }
```

### Console & Network
```json
{ "action": "console", "targetId": "task1" }   // View console logs
```

### JavaScript Evaluation
```json
{ "action": "act", "kind": "evaluate", "fn": "document.title", "targetId": "task1" }
```

## Stale Ref Recovery

If action fails with missing/stale ref:
1. Re-snapshot same `targetId`
2. Find current visible control
3. Retry once with new ref
4. If UI changed to blocker state → report blocker, don't loop

## Platform Adapters

This skill works natively in OpenClaw. No adapter needed — the `browser` tool is built-in.

For other platforms, see `adapters/` directory (future).

## Modules

- `modules/site-memory.json` — Accumulated site patterns
- `modules/safety-rules.json` — Domain blocklist + element protection rules
- `modules/tool-router.md` — Smart tool routing decision tree

## What's Borrowed from browser-control-skill

- ✅ 3-layer safety system (domain blocklist, element protection, action confirmation)
- ✅ Site memory concept (auto-accumulating platform patterns)
- ✅ Smart tool routing (lightest tool first)
- ✅ Background parallel sub-agents
- ✅ Foreground/background/auto mode switching

## What's Native from OpenClaw

- ✅ `browser` tool with full act/snapshot/upload/console support
- ✅ `profile="user"` for existing Chrome sessions
- ✅ Tab management with labels
- ✅ `sessions_spawn` for sub-agents
- ✅ Stale ref recovery (snapshot → re-ref → retry)
- ✅ `web_search` and `web_fetch` for light queries
- ✅ Cross-platform (Windows, macOS, Linux)

## License

MIT — Built for OpenClaw Agency by Luna 🦉
