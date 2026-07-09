---
name: live-state-truth
description: Before asserting a fact about a system or acting on one, verify against the LIVE system. Docs, comments, READMEs, memory files, and your own memory are stale by default. The system is the source of truth, not its description.
---

# live-state-truth: the system is the source of truth

Every system carries two versions of itself: what it IS, and what its documentation say it is. They drift apart the moment they are written. Acting on the description when the system disagrees is how confident agents ship confident breakage.

## The rule

Before asserting a fact about a system, or taking an action whose safety depends on that fact, verify it against the live state:

| The claim comes from | Treat it as | Verify by |
|---|---|---|
| A README, doc, or wiki | Stale by default | `exec`: run the code path, `read`: actual source |
| A code comment | The code's opinion of itself | `read`: the code the comment describes |
| A config file in the repo | What was INTENDED | `exec`: query the running system for EFFECTIVE value |
| MEMORY.md or daily notes | A point-in-time observation | Re-check now — the system moved since |
| The user's description | Honest but possibly outdated | Confirm gently with a read-only probe |
| A schema or type definition | Better, but migrations lie | `exec`: inspect actual data or live schema |

## The procedure

1. **Name the load-bearing facts.** Which facts, if wrong, make my next action wrong or destructive? Those are the ones to verify.
2. **Pick the cheapest sufficient check.** If the authoritative artifact is already in front of you (the source file, the actual config), reading it IS the check. Reach for `exec` probes when truth is NOT in view.
3. **When description and reality disagree, reality wins — and say so.** Report the gap in one line: "the README says X, the code does Y".
4. **Timestamp what you learn.** "As of this check, X" ages honestly. "X is true" rots silently.
5. **Answer first, evidence second, tersely.** The deliverable is the verified answer plus the one-line evidence chain.

## Especially before destructive actions

Deletes, overwrites, restarts, migrations, force-pushes: the evidence bar rises with the blast radius. Look at the actual target first. If what you find contradicts how it was described, stop and surface the contradiction.

### OpenClaw verification probes

| System | Probe |
|--------|-------|
| Running service | `exec: Invoke-RestMethod http://localhost:PORT/health` |
| File on disk | `read` or `exec: Get-ChildItem` |
| Git state | `exec: git status`, `exec: git log --oneline -5` |
| API endpoint | `exec: Invoke-RestMethod -Method GET -Uri URL` |
| Process running | `exec: Get-Process` or `exec: pm2 list` |
| Port in use | `exec: netstat -ano \| findstr :PORT` |

## Anti-patterns this skill kills

- Recommending a flag that was removed two versions ago because a blog post said it exists.
- "The comment says this handles retries" — it did, before the refactor.
- Trusting your session memory of a file you edited an hour ago.
- Building on a "known" API response shape without one real sample.

## The cheap habit

One probe before one claim. It costs seconds and is the single highest-ratio rigor habit an agent can have.

## Origin

Adapted from Iwo's Rigor Pack (Fable 5 skill distillation, July 2026). OpenClaw-native version using `read`, `exec`, `web_search`.
