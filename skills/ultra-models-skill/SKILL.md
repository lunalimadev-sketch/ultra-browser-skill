---
name: ultra-models-skill
description: >-
  Audit free AI model availability across providers (OpenRouter, OpenCode,
  KiloCode, NVIDIA, Antigravity Proxy, KIMI CODE), check config against live APIs,
  discover new free models, diagnose silent fallback failures.
  Trigger terms: free models, model audit, model check, fallback broken,
  list free models, which models are available, antigravity, kimi, dual-protocol provider.
---

# Ultra Models Skill

Detect dead models, new additions, broken fallbacks, and orphaned aliases
by cross-referencing live API responses against `openclaw.json`.

## 📁 Path-Agnostic (v2)

All scripts now auto-detect your OpenClaw home directory:

1. `$env:OPENCLAW_CONFIG_PATH` (if set)
2. `$env:USERPROFILE\.openclaw`
3. `$env:HOMEDRIVE$env:HOMEPATH\.openclaw`

Works on any machine — ClawLabs, Luna, Justus, or any other install.

## When to Use / When NOT to Use

**Use for:** auditing free model availability, diagnosing silent fallbacks,
discovering new free models, verifying config before gateway restart,
or when user says "check models", "list free models", "are fallbacks working".

**Don't use for:** changing model config (`gateway config.patch`), testing
model quality (use `session_status`), paid pricing, or one-off queries.

## Commands

### 1. List all free models from live APIs

```powershell
powershell -ExecutionPolicy Bypass -File "<skill-dir>/scripts/list-free-models.ps1"
```

### 2. Compare config vs live APIs (main diagnostic)

```powershell
powershell -ExecutionPolicy Bypass -File "<skill-dir>/scripts/compare-config.ps1"
```

Reports: dead models, new models, orphaned aliases, broken fallbacks across
all 5 providers.

### 3. List antigravity proxy models

```powershell
powershell -ExecutionPolicy Bypass -File "<skill-dir>/scripts/list-antigravity-models.ps1"
```

Queries `127.0.0.1:8080`. No API key needed.

### 4. KiloCode detail view

```powershell
powershell -ExecutionPolicy Bypass -File "<skill-dir>/scripts/kilo-free-detail.ps1"
```

## Allowed Tools

- `exec` — Run PowerShell scripts
- `gateway` — Read/patch openclaw.json config
- `session_status` — Verify current model and fallback state

## Provider API Endpoints

| Provider | Endpoint | Auth |
|----------|----------|------|
| OpenRouter | `https://openrouter.ai/api/v1/models` | Bearer token |
| OpenCode | `https://opencode.ai/zen/v1/models` | Bearer token |
| KiloCode | `https://api.kilo.ai/api/gateway/models` | Bearer token |
| NVIDIA | `https://integrate.api.nvidia.com/v1/models` | Bearer token |
| Antigravity | `http://127.0.0.1:8080/v1/models` | None (local proxy) |
| Kimi Code | `https://api.kimi.com/coding/v1/models` (OpenAI) / `https://api.kimi.com/coding/v1/messages` (Anthropic) | Bearer API Key |

## Kimi Code (6th provider — dual-protocol)

Kimi Code is a membership coding-agent provider. It speaks BOTH the OpenAI and Anthropic
API shapes, so OpenClaw/OpenCode can use it by just setting Base URL + API Key + Model ID.

**Key facts for the audit:**
- **Base URL:** `https://api.kimi.com/coding/v1` (OpenAI-compatible) or `https://api.kimi.com/coding` (Anthropic-compatible, append `/v1/messages`)
- **Auth:** `Authorization: Bearer <kimi-api-key>` (same key for both protocols)
- **Model IDs:**
  - `kimi-for-coding` — Standard tier (full coding ability)
  - `kimi-for-coding-highspeed` — HighSpeed tier (~5–6× output speed, ~3× quota cost)
- **Stable IDs:** the backend swaps the real model underneath without changing your config.
- **SILENT FALLBACK (audit trap):** if you set the HighSpeed ID wrong (or any invalid ID), requests silently fall back to Standard — no error, no acceleration. Always verify the exact ID string.
- **Two independent limits:**
  1. Weekly quota that does NOT roll over (resets every 7 days from subscription date)
  2. Rolling 5-hour frequency window — too many requests in a short span triggers rate-limiting that auto-recovers when the window rolls forward
- **No public free tier:** Kimi Code requires a paid membership. Treat as a PAID provider in the audit — do not mark as free.
- **Client identity rule:** tools must keep their real User-Agent; spoofing the client identifier is a violation that can get the key suspended. Flag this in security review.

**Config mapping:** OpenClaw/OpenCode entries would use `kimi/kimi-for-coding` style IDs; verify against `openclaw.json` → `agents.defaults.models` and `fallbacks`.

## Free Model Detection & Config Mapping

| Provider | Detection Rule | Config Note |
|----------|---------------|-------------|
| OpenRouter | `pricing.prompt == "0"` | — |
| OpenCode | ID matches `-free` or equals `big-pickle` | Models silently removed (401 errors) |
| KiloCode | `isFree == true` | — |
| NVIDIA | `owned_by == "nvidia"` + no pricing or pricing == 0 | NIM Preview rotates frequently |
| Antigravity | All returned models available (local proxy) | Config uses `antigravity-proxy/<id>` prefix |

## Config vs API Comparison (compare-config.ps1)

The `compare-config.ps1` script now reads:
- **Aliases** from `openclaw.json` → `agents.defaults.models`
- **Primary model** from `openclaw.json` → `agents.defaults.model.primary`
- **Fallbacks** from `openclaw.json` → `agents.defaults.model.fallbacks`

It cross-references these against live API responses to find:
- Dead aliases (configured but removed by provider)
- New free models (available but not in config)
- Broken fallbacks (fallback model no longer exists)
- Primary model health

## Known Issues

- OpenCode silently removes models (returns 401 "Model not supported")
- NVIDIA NIM Preview catalog requires HTML scraping (no stable JSON API)
- Some models exist in provider definitions but aren't routable
- OpenCode renames models (`super` → `ultra` pattern common)

## Best Practices

1. Run `compare-config.ps1` before any config change — catch dead models first
2. Never hardcode API keys — auto-detection reads `.env` at runtime
3. Monitor periodically — providers remove/rename models without notice
4. Check fallback chain health — one dead fallback cascades failures
5. Check if antigravity proxy is running before querying it
