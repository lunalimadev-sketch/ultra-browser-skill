# CHANGES.md — Content Engine Distillation

## What changed

### Structure: 6 workflow phases → 6 numbered rigor gates
The old skill listed rules and formats loosely. The distilled version enforces a strict sequence: **plan-gate → produce → voice-apply → verify → scope-check → log**. Each gate is mandatory, not suggested.

### Added: Plan-Gate (§1)
- Before writing anything, confirm platforms, voice, objective, audience
- If any is missing, **stop and ask** — don't assume
- Prevents the #1 failure: producing content without clarity on who it's for

### Added: Adversarial-Verify (§4)
- Checklist with concrete thresholds (>40% text overlap = rewrite)
- Explicit AI pattern blacklist with examples
- Readability constraint (no sentences >25 words)
- Read-aloud test for voice consistency

### Added: Scope-Fence (§5)
- Only produce platforms explicitly requested
- No "bonus" suggestions or unsolicited extras
- Variations only when asked

### Added: Memory Logging (§6)
- Every production logged to daily memory file
- Tracks: platforms, voice profile, objective, requester

### Improved: Voice Profile System (§3)
**Before:** "Se existe, reusar. Se não, definir tom antes de escrever."
**After:** 4-step concrete process:
1. `read` the file (verify it exists — fail if not)
2. Extract register, vocabulary, rhythm, persona
3. Flex register by platform but keep persona constant
4. Read-aloud test

### Improved: Platform Definitions (§2)
**Before:** Listed formats but no enforcement mechanism
**After:**
- Consolidated into scannable table with hard limits
- Added "rule of iron": if LinkedIn version works pasted into X, it's wrong
- Tone column per platform (not just format)
- Explicit bans per platform (e.g., no "concordam?" on LinkedIn)

### Removed
- "Quando Ativar" section (obvious from context — scope-fence handles misuse)
- Redundant "Regras Core" (absorbed into gates)
- Loose workflow (replaced by numbered mandatory gates)

## Line count
- **Before:** 51 lines (thin, advisory)
- **After:** 44 lines of content (dense, mandatory, with verification)

## Rigor principles applied
| Principle | Implementation |
|---|---|
| plan-gate | §1 — confirm before writing |
| adversarial-verify | §4 — diff test, AI patterns, readability |
| live-state-truth | §3.1 — `read` voice profile, fail if missing |
| scope-fence | §5 — only requested platforms |
| ruthless-editor | Table format, no examples bloat, numbered gates |
| memory-hygiene | §6 — log every production |
