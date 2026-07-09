---
name: deep-research
description: Pesquisa profunda multi-fonte com relatórios citados. 6 passos, verificação obrigatória de fontes, parallelização com subagentes.
---

# Deep Research

Relatórios de pesquisa citados de múltiplas fontes web. Síntese com atribuição, não googlage.

## When to Activate

- "Pesquisar", "deep dive", "investigar", "estado atual de"
- Análise competitiva, due diligence, sizing de mercado
- Qualquer questão que exige síntese de múltiplas fontes

## Workflow — 6 Steps

### 1. Define the Question
Ask 1-2 clarifying questions:
- "Seu objetivo é aprendizado, tomada de decisão, ou escrita?"
- "Algum ângulo ou profundidade específica?"
If "só pesquisa" → proceed with reasonable defaults.

### 2. Plan the Research
Split into 3-5 sub-questions. For each:
- What type of source answers it?
- Which domains/sources are authoritative?

Use `web_search` for discovery, `web_fetch` for extraction.

### 3. Gather Sources (Parallelize)
- Run 3-5 parallel searches via `web_search`
- Fetch top results with `web_fetch`
- For heavy research: spawn subagents with `sessions_spawn` per sub-question

### 4. Verify and Cross-Reference
**live-state-truth rules:**
- Every URL must be fetched — never cite unchecked
- Dead links → flag, don't silently omit
- Conflicting claims → surface the contradiction with both sides
- Date of information matters — prefer recent

### 5. Synthesize
Structure:
```
## Executive Summary (3-5 sentences)

## Key Findings
### Finding 1
[What + evidence + citation]

### Finding 2
...

## Contradictions / Open Questions
[If any]

## Sources
1. [Title](URL) — [date]
2. ...
```

Rules:
- Every claim MUST have a citation
- Prefer primary sources over aggregators
- Note when info is outdated

### 6. Deliver
- Send report to requester
- Log in daily notes: topic, sources count, key findings
- If actionable insights exist, highlight them

## Quality Gates

| Gate | Check |
|------|-------|
| Source count | ≥5 independent sources |
| Citation coverage | Every claim has ≥1 citation |
| Freshness | Most sources <1 year old |
| Contradictions | Surfaced, not hidden |
| Dead links | Flagged explicitly |

## Anti-patterns

- ❌ Citing URLs you didn't fetch
- ❌ Single-source claims presented as fact
- ❌ "Research" = one Google search
- ❌ Synthesis that's just concatenation
- ❌ Hiding contradictions to sound authoritative
