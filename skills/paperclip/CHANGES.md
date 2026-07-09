# CHANGES.md — Paperclip Skill Distillation

**Date:** 2026-07-09
**Original:** 542 lines (~22KB)
**Distilled:** 261 lines (~14KB)
**Reduction:** 52% line count, 37% bytes

## Methodology

Applied Iwo's Rigor Pack discipline principles to compress the skill without losing any functionality or endpoint coverage.

---

## Structural Changes

### Added: Discipline Gates (NEW section)
Injected a top-level `## Discipline Gates` section encoding four rigor principles directly into the workflow:
- **Plan-gate:** Micro-plan before any mutation (what, why, verify)
- **Live-state-truth:** GET before mutating — never trust prior heartbeat memory
- **Scope-fence:** Do exactly what was asked, flag adjacent issues
- **Adversarial-verify:** Re-read resource after mutation to confirm success

**Why:** These were implicit best practices scattered across the doc. Making them explicit and mandatory prevents the most common agent mistakes (stale state, scope creep, silent failures).

### Added: Critical Rules as Anti-Pattern Table
Replaced the bullet-list Critical Rules with a two-column `Rule | Anti-Pattern` table.

**Why:** Anti-patterns are more actionable than rules alone. "Always checkout before work" is clearer when paired with "Don't PATCH status to in_progress manually."

---

## Compression Changes

### Authentication section
- Collapsed env var descriptions from prose paragraphs into a compact list
- Extracted wake payload shortcut into its own labeled paragraph
- Moved `PAPERCLIP_WAKE_PAYLOAD_JSON` handling from being buried in Step 6 to a visible callout in Authentication

**Why:** Agents scan for env var names, not prose. List format is faster to parse.

### Heartbeat Procedure (Steps 1-9)
- **Steps 1-3:** Compressed to essential API call + purpose (cut ~40% per step)
- **Step 4:** Collapsed mention-handling into a structured sub-list instead of 5 paragraphs
- **Step 5:** Kept code block, cut surrounding prose
- **Step 6:** Reorganized as numbered priority list (payload → heartbeat-context → comments) instead of interleaved paragraphs. Merged execution-policy review/approval handling inline with bullet format
- **Step 8:** Merged Status Quick Guide inline as single-line definitions instead of a separate subsection with 7 multi-line entries. Cut redundant "practical rules" that duplicated Critical Rules
- **Step 9:** Cut to 2 lines

**Why:** Each step had 2-3x more words than needed. The information density was low — many sentences restated the same rule with different phrasing.

### Issue Dependencies
- Cut verbose JSON examples (the pattern is obvious from endpoint + field name)
- Kept auto-wake semantics (the non-obvious part)
- Added explicit note that `cancelled` doesn't count as resolved (a common gotcha)

### Board Approval
- Kept the JSON example (it's the only place showing the payload shape)
- Cut surrounding prose

### Project Setup
- Collapsed from 8 lines to 2 numbered steps

### OpenClaw Invite Workflow
- Collapsed from 15+ lines to 3 numbered steps
- Cut the detailed access control explanation (it's enforced server-side anyway)

### Company Skills
- Collapsed to 2 lines + reference pointer

### Routines
- Collapsed to 2 lines + reference pointer

### Company Import/Export
- Collapsed from 15+ lines to 3 bullets covering the essential semantics
- Cut duplicate endpoint listings (already in endpoint table)

### Comment Style
- Kept all linking rules (these are non-obvious and frequently violated)
- Collapsed URL pattern list from prose+example to compact list
- Added explicit anti-pattern line

### Planning
- Collapsed from 15+ lines to 3 sentences + 1 rule
- Cut the JSON example (PUT with key `plan` is self-explanatory)

### Endpoint Table
- Consolidated related endpoints onto single rows using `|` notation (e.g., documents, comments, attachments, routines, triggers)
- Combined GET/PUT/PATCH variants where the pattern is regular
- Reduced from 50+ rows to ~32 rows without losing any endpoint

---

## Removed / Relocated

### Self-Test Playbook (REMOVED)
The entire self-test section (create throwaway issue, trigger heartbeat, verify transitions) was app-level validation, not agent operation guidance. Agents don't self-test Paperclip — they use it.

**Where it went:** The full reference at `api-reference.md` covers this. If needed, it should be a separate ops runbook, not embedded in the agent skill.

### Searching Issues (MERGED)
Was a standalone 5-line section for one query parameter. Merged into the endpoint table as `GET /api/companies/:companyId/issues?q=term`.

### Manual local CLI mode (CUT)
One-off setup instruction irrelevant to heartbeat operation. Operators handle this, not agents.

### Redundant examples throughout
- Removed duplicate `PATCH` examples that showed the same pattern with different statuses
- Removed the `scripts/paperclip-issue-update.sh` example from Comment Style (kept the one in Step 8)
- Removed the markdown comment example block (the format rules are sufficient)

---

## What Was NOT Cut

- **Every endpoint** from the original table is present in the distilled version
- **All workflow paths:** approval, mention, blocked-dedup, execution-policy review, planning, delegation
- **All env vars** and their semantics
- **All linking rules** for comments and ticket references
- **All status values** and their correct usage
- **Reference file pointers** for routines, company-skills, and full API reference
- **Git co-author rule**
- **Wake payload handling**
- **Agent instructions path** endpoint and rules
