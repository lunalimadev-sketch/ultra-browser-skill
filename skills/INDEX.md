# Skill Index 📚

Progressive disclosure index — load only what you need.

## Level 0: This Index (~500 tokens)

| Skill | Description | Category |
|-------|-------------|----------|
| learn | Create skills from URLs, docs, conversations, notes | meta |
| google-workspace | Gmail, Calendar, Drive, Sheets via gws CLI | productivity |
| ultra-browser-skill | Multi-agent browser control (Planner→Navigator→Validator) | automation |
| academic-task-manager | Academic research task management | research |
| agente-redes-sociais | Social media automation (X/Twitter) | social |
| antigravity | Antigravity Claude Proxy integration | infrastructure |
| humanizer | Remove AI slop from generated text | writing |
| query-perplexity | Deep research via Perplexity AI | research |
| paperclip | Paperclip project management | productivity |
| deslop | Clean AI-generated content | writing |
| context7 | Context7 documentation integration | development |

## Level 1: Full Content

Load full SKILL.md only when the task requires it:
```
read workspace/skills/{name}/SKILL.md
```

## Level 2: Reference Files

Load specific reference files for deep dives:
```
read workspace/skills/{name}/references/{file}
```

## Bundles

| Bundle | Skills | Use Case |
|--------|--------|----------|
| research | query-perplexity, research-agent, humanizer | Deep research workflow |
| content | deslop, humanizer, agente-redes-sociais | Content creation |
| automation | ultra-browser-skill, google-workspace | Browser + workspace automation |

---

*Last updated: 2026-07-06*
