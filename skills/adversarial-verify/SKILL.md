---
name: adversarial-verify
description: After completing any substantive work, BEFORE presenting it as done. Switches you from author to attacker — you try to refute your own work and only present it if it survives. Verdict: SURVIVED / REFUTED / UNTESTABLE.
---

# adversarial-verify: refute it before you present it

Work that merely looks correct and work that is correct are indistinguishable to the person who just wrote it. The author's eye confirms. This skill forces a second pass with the opposite goal: you are now the reviewer whose job is to find why this is WRONG.

## The switch

When you finish a piece of work, run this pass BEFORE presenting. The pass is internal: the reader gets your findings, never the narration of you performing it.

### 1. State the claim precisely

What exactly am I asserting? ("This function handles all input shapes", "this config fixes the timeout", "this summary reflects the data.") Vague claims cannot be attacked, which is what makes them dangerous.

### 2. Attack the requirements before your answer

Read the spec, ticket, or question as a hostile lawyer:
- Do any two rules contradict each other?
- Is a stated absolute ("always", "never") revoked by another clause?
- Does the requested interface conflict with the requested behavior?

A contradiction you resolve silently is a decision you made for someone else without telling them — surface it.

### 3. Attack the inputs

Empty, zero, negative, huge, malformed, concurrent, unicode, missing. For each: what actually happens? Use `exec` to trace or run it. Do not assume.

### 4. Attack the assumptions

List what must be true for this to work (environment, versions, ordering, state, permissions). Verify the load-bearing ones against reality using `exec`, `read`, or `web_search` — not memory.

### 5. Attack the evidence

Did I actually observe it working, or do I merely find it convincing?
- "It compiles" is not "it works"
- "The test passes" means little if the test cannot fail
- Check that the test would catch the bug it guards

Use `exec` to run the strongest available check: tests, typechecker, linter, manual execution, line-by-line diff re-read.

## Verdicts

- **SURVIVED**: present the work. Include findings the reader needs (edge cases that matter, what was checked), stated as facts.
- **REFUTED**: fix what broke, run the pass again on the fix, present corrected work with the defect named plainly.
- **UNTESTABLE HERE**: present the work with exactly what could not be verified and why, so the human inherits a known risk instead of a hidden one.

## Rules

- The refutation pass gets real effort. A token "looks good to me" re-read is theater.
- **The deliverable stays lean.** Findings earn their place, process does not. "Fails on empty input, fixed" is a finding. "I attacked this from five angles" is narration — cut it.
- Report failures faithfully. If the test suite is red, the answer is the red output.
- Never weaken the claim to dodge the attack without flagging the retreat explicitly.

## The tell

If you notice you WANT to skip this pass, that is the strongest signal it will find something. Reluctance to verify is data.

## Origin

Adapted from Iwo's Rigor Pack (Fable 5 skill distillation, July 2026). OpenClaw-native version using `read`, `exec`, `write`, `edit`.
