# CHANGES.md — AgenteRedesSociais Distillation

## Summary
Rewrote SKILL.md applying rigor discipline. 107 lines → 76 lines (−29%).

## What Changed

### Added (Rigor Gates)
- **Pre-Flight section**: Mandatory `xurl whoami` + `xurl auth status` before every post (live-state-truth). Prevents posting to wrong account or with expired auth.
- **Content gate checklist**: 480-char count, typo check, link verification, scope confirmation (adversarial-verify + scope-fence).
- **Post-Flight logging**: Every post logged to `memory/YYYY-MM-DD.md` with method, type, content, status, URL (memory-hygiene).

### Removed (Ruthless Editor)
- **"Status Atual" section**: Dynamic state hardcoded in a skill file is a lie. Removed entirely.
- **"Método 3: Script PowerShell" section**: One-liner with no real documentation. Dead weight.
- **"Prompt Padrão (Via Chat)" section**: Describes agent behavior, not skill procedure. Cut.
- **Verbose setup prose**: Collapsed 7 numbered steps + commentary into 4 terse commands.
- **Redundant browser login details**: Condensed to essential flow.

### Changed
- **Character limit**: Corrected to 480 (non-Premium) — was incorrectly listed as 280.
- **Thread syntax**: Added concrete chained-reply pattern instead of vague mention.
- **Error table**: Kept same errors, tightened descriptions, added "do NOT retry immediately" for 429.
- **Security section**: Preserved all rules, removed redundant "NUNCA faça" formatting.
- **Browser fallback**: Added explicit "verify session first" step — was missing (anti-pattern: posting without verifying login).

### Rigor Principles Applied
| Principle | Implementation |
|-----------|---------------|
| plan-gate | Pre-Flight section with identity + auth check |
| adversarial-verify | Content gate checklist (typos, links, account, chars) |
| live-state-truth | `xurl whoami` / browser snapshot before assuming login |
| scope-fence | Explicit rule: no hashtags/threads/bait unless requested |
| ruthless-editor | 107 → 76 lines, 3 sections deleted, prose halved |
| memory-hygiene | Post-Flight logging template with structured format |

### Anti-Patterns Addressed
- ❌ Posting without verifying login → ✅ Mandatory `whoami` / snapshot
- ❌ Ignoring rate limits → ✅ Pre-flight + "do NOT retry" in error table
- ❌ Posting to wrong account → ✅ Identity verification in pre-flight
- ❌ No post history → ✅ Structured logging after every post
