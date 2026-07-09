# CHANGES.md — Deep Research Skill Distillation

## Summary
Rewrote the Deep Research skill from 87 lines to 68 lines, applying rigor discipline principles from Iwo's Rigor Pack.

## Principles Applied

### 1. plan-gate
- **Before:** Step 2 listed example sub-questions but had no gate — searching could start without a written plan.
- **After:** Step 2 explicitly requires writing sub-questions + planned source types before any `web_search` call. Bold instruction: "Do not search until the plan is written."

### 2. adversarial-verify
- **Before:** Quality rules listed as 10 separate items, easy to skip. No explicit verification pass.
- **After:** Step 5 includes a mandatory checklist (7 items) run between synthesis and delivery. Verification is part of the workflow, not a sidebar.

### 3. live-state-truth
- **Before:** Step 4 said "read 3-5 sources in depth" and "don't trust snippets" — but no rule against citing unfetched URLs.
- **After:** Hard rule: "Never cite a URL you didn't fetch." Step 4 requires maintaining a source log with status. Dead links explicitly logged, never silently dropped.

### 4. scope-fence
- **Before:** No scope control. Anti-pattern "usar uma única fonte pra claim amplo" was the closest, but nothing prevented scope creep.
- **After:** Step 1 requires writing the exact question being answered. Tangential findings go to a `## Tangents` section in the report — flagged but never chased mid-research.

### 5. ruthless-editor
- **Before:** Report template had "Principais Conclusões" and "Metodologia" sections encouraging narration. 10 quality rules were verbose.
- **After:** Report header says "findings and citations, not narration." Conclusions/Methodology sections cut. Quality rules compressed to 6 hard rules (one line each). Template is leaner.

### 6. memory-hygiene
- **Before:** No logging guidance. Research results lived only in the report.
- **After:** Step 6 requires logging to `memory/YYYY-MM-DD.md`: topic, source count, dead links, confidence. Step 4 requires maintaining a source log during research with URL, status, finding, and credibility.

## Structural Changes

| Aspect | Before (87 lines) | After (68 lines) |
|--------|-------------------|-------------------|
| Language | Portuguese | English (consistent with rigor pack) |
| Quality rules | 10 items, separate section | 6 hard rules, one line each |
| Anti-patterns | 5-item separate section | Eliminated — covered by hard rules |
| Verification | Implicit in rules | Explicit checklist in Step 5 |
| Source logging | Not mentioned | Required in Step 4 |
| Scope control | None | Step 1 gate + Tangents section |
| Dead link handling | Not addressed | Logged in source table + report section |
| Contradictions | Rule 7 mentioned it | Report template has explicit contradiction format with ⚠️ |
| Report template | Verbose with methodology | Lean: Summary → Findings → Tangents → Dead Sources → Sources |
| Memory logging | None | Required in Step 6 |

## What Was Kept
- 6-step workflow structure (renumbered/renamed)
- Subagent parallelization (tightened — main session must verify all subagent output)
- Report formatting with inline citations
- Tool references: `web_search`, `web_fetch`, `write`
- Source count target (15-30)
- Deep-read requirement (3-5 sources)
- Recency preference (<12 months)
