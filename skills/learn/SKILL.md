---
name: learn
description: Create reusable skills from any source — URLs, docs, code, conversations, notes. Generates standards-compliant SKILL.md files automatically.
version: 1.0.0
author: Luna (OpenClaw Agency)
license: MIT
metadata:
  tags: [skills, learning, automation, meta]
  category: meta
---

# Learn — Auto-Generate Skills from Any Source 🧠

Turn any source material into a reusable OpenClaw skill. No hand-writing SKILL.md needed.

**Inspired by:** [Hermes Agent `/learn`](https://hermes-agent.nousresearch.com/docs/user-guide/features/skills#learning-a-skill-from-sources-learn)

## When to Use

- User says "learn this" or "save this as a skill"
- After completing a complex workflow that should be repeatable
- When given documentation, SDK docs, or API references
- When a URL contains procedures worth capturing
- When the agent discovers a better way to do something

## Quick Reference

| Source | How | Example |
|--------|-----|---------|
| **URL** | Fetch + distill | `learn https://docs.stripe.com/api` |
| **Local files** | Read + synthesize | `learn ~/projects/my-sdk/README.md` |
| **Conversation** | Capture workflow | `learn how we just deployed X` |
| **Notes** | Structure + formalize | `learn deploy: ssh to server, git pull, restart` |
| **Multiple URLs** | Merge sources | `learn from these 3 docs about X` |

## Procedure

### Step 1: Gather Source Material

Based on the input type:

```
URL → web_fetch → extract key procedures, commands, patterns
Files → read → extract relevant sections
Conversation → replay history → extract workflow steps
Notes → parse → structure into procedures
```

### Step 2: Analyze & Structure

From the raw material, extract:

1. **What this skill does** (≤60 char description)
2. **When to use it** (trigger conditions)
3. **Quick reference** (common commands/APIs in a table)
4. **Procedure** (step-by-step instructions)
5. **Pitfalls** (known failure modes + fixes)
6. **Verification** (how to confirm it worked)

### Step 3: Generate SKILL.md

Use this exact template:

```markdown
---
name: {kebab-case-name}
description: {Brief description, ≤60 chars}
version: 1.0.0
author: Luna (OpenClaw Agency)
license: MIT
metadata:
  tags: [{relevant, tags}]
  category: {category}
---

# {Skill Title}

{One-paragraph intro.}

## When to Use

{Trigger conditions — when should the agent load this skill?}

## Quick Reference

{Table of common commands, APIs, or patterns}

## Procedure

{Step-by-step instructions}

## Pitfalls

{Known failure modes and how to handle them}

## Verification

{How to confirm it worked}

## License

MIT — Built for OpenClaw Agency by Luna 🦉
```

### Step 4: Save the Skill

Save to `workspace/skills/{name}/SKILL.md`

Create `workspace/skills/{name}/README.md` with a brief summary.

### Step 5: Update Index

Add the new skill to `workspace/skills/INDEX.md` (progressive disclosure level 0).

## Skill Naming Rules

- **kebab-case** for directory name: `my-cool-skill`
- **lowercase** for skill name in frontmatter: `my-cool-skill`
- **Descriptive** but concise: `gws-email-sender` not `email`
- **Avoid collisions** with existing skills

## Description Rules

- **≤60 characters** (Hermes standard)
- **Action-oriented**: "Send emails via gws CLI" not "Email skill"
- **No filler**: "Gmail search, read, send via gws" not "A comprehensive email management solution"

## Progressive Disclosure

When listing skills, use a light index:

```markdown
| Skill | Description | Category |
|-------|-------------|----------|
| google-workspace | Gmail, Calendar, Drive via gws CLI | productivity |
| ultra-browser-skill | Multi-agent browser control | automation |
```

Only load full SKILL.md content when the agent actually needs it. This keeps token usage low.

## Skill Bundles

Group related skills into bundles for single-command activation:

```yaml
# workspace/skills/bundles/research.yaml
name: research
description: Research workflow — search, analyze, report
skills:
  - query-perplexity
  - research-agent
  - humanizer
instruction: |
  Always cite sources. Use perplexity for deep research,
  research-agent for multi-source, humanizer for final polish.
```

## Agent-Created Skills

The agent should create skills when:

1. **Complex task completed** (5+ tool calls) → capture as reusable procedure
2. **Dead end found and resolved** → document the working path
3. **User says "remember this"** → formalize into a skill
4. **Repeated pattern detected** → extract into a template

### Write Approval

By default, skills are saved directly. For critical workflows:
- Stage in `workspace/skills/pending/` first
- User reviews before moving to `workspace/skills/`

## Example: Learning from a URL

```
User: learn https://docs.stripe.com/api/charges

Agent:
1. web_fetch the URL
2. Extract: endpoints, auth, request/response formats
3. Generate SKILL.md with:
   - Quick reference table of endpoints
   - Procedure for creating charges
   - Common pitfalls (auth errors, idempotency)
   - Verification steps
4. Save to skills/stripe-charges/SKILL.md
5. Add to INDEX.md
```

## Example: Learning from Conversation

```
User: learn how we just deployed the staging server

Agent:
1. Review conversation history for deployment steps
2. Extract: commands, URLs, configurations, gotchas
3. Generate SKILL.md with:
   - Procedure: SSH → pull → build → deploy → verify
   - Pitfalls: common deploy failures
   - Verification: health check endpoints
4. Save to skills/deploy-staging/SKILL.md
```

## Pitfalls

- **Don't invent commands** that don't exist in the source material
- **Don't over-generalize** — keep it specific to what was actually learned
- **Don't skip pitfalls** — the failure modes are often more valuable than the happy path
- **Don't forget verification** — always include how to confirm it worked

## Verification

After creating a skill:
1. Check SKILL.md has all required sections
2. Verify description is ≤60 chars
3. Confirm no invented commands or tools
4. Test that the procedure actually works
5. Ensure INDEX.md is updated

## License

MIT — Built for OpenClaw Agency by Luna 🦉
