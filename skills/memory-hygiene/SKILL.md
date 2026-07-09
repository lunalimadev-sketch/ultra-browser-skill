---
name: memory-hygiene
description: When writing to or reading from MEMORY.md, daily notes, TOOLS.md, or any persistent memory. Governs WHAT deserves persisting, HOW to write it so it survives time, and the recall rule: verify remembered facts against live state before acting.
---

# memory-hygiene: memory is a claim about the past, not a fact about the present

An agent's persistent memory is its highest-leverage asset and its most dangerous one. Good memory compounds: every session starts smarter. Bad memory compounds too: one stale "fact" confidently recalled can outvote the live system in front of you.

## Writing: what deserves persistence

Persist the things a future session cannot rederive:

- **Decisions and their WHY.** "We chose X over Y because Z" — the why is the part that evaporates.
- **Corrections received.** When a human corrects you, persist it with the reason, so the future session applies the principle, not just the rule.
- **Non-obvious constraints.** The gotcha that cost an hour. The API that lies. The step that must come first.
- **Preferences of the humans you work with.** How they like to be asked, what they care about.

Do NOT persist what the codebase, git history, or docs already record. Memory that duplicates a derivable fact ages into contradiction. **Never persist secrets.**

## Writing: how

- **One fact per entry, dated.** "As of 2026-07-09, the deploy hook is armed" ages honestly. Undated facts rot.
- **Write the trigger with the fact.** "When touching the publish pipeline, remember X" — the future session needs to know WHEN this matters.
- **Small and curated beats large and complete.** Memory loads into finite context. Every stale line taxes every future session. Prune when you add.

### File mapping

| File | Purpose | Staleness risk |
|------|---------|----------------|
| `MEMORY.md` | Long-term curated memory | Slow (decisions, preferences) |
| `memory/YYYY-MM-DD.md` | Daily raw logs | Medium (facts, events) |
| `TOOLS.md` | Tool configs, paths, env vars | Medium (versions change) |
| `USER.md` | Human preferences | Slow |
| `AGENTS.md` | Agent conventions | Slow |

## Recall: the verification rule

Remembered facts are point-in-time observations. Before ACTING on one:

1. **Grade the staleness risk.** Preferences age slowly. System state (versions, configs, file locations) ages fast.
2. **Fast-aging fact + consequential action = verify first.** Use `exec` or `read` to confirm before building on memory.
3. **When memory and live state disagree, live state wins** — and update the memory in the same breath.
4. **Say which you are using.** "Per memory from June" vs "verified just now" — the reader deserves the vintage.

## The maintenance habit

- Memory proves wrong → fix it immediately, do not route around it.
- Memory proves right and important → promote it (clearer trigger, better placement).
- A memory store nobody prunes becomes a liability with a good reputation.

## The honest limit

This skill gives memory DISCIPLINE. What it cannot give is persistence itself — a skill file cannot remember your decisions for you, and everything a session learns evaporates unless something durable catches it. **Discipline plus durable storage is the complete system.** This skill is the discipline half.

## Origin

Adapted from Iwo's Rigor Pack (Fable 5 skill distillation, July 2026). OpenClaw-native version referencing MEMORY.md, daily notes, TOOLS.md, AGENTS.md.
