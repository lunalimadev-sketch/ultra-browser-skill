# Learn Skill 🧠

**Auto-generate reusable skills from any source.**

## What It Does

| Source | How It Works |
|--------|-------------|
| **URL** | Fetches page, extracts procedures, generates SKILL.md |
| **Local files** | Reads docs/code, synthesizes into skill |
| **Conversation** | Captures workflow from chat history |
| **Notes** | Structures informal notes into formal skill |

## Quick Start

```
# Learn from a URL
learn https://docs.stripe.com/api/charges

# Learn from files
learn ~/projects/my-sdk/README.md

# Learn from conversation
learn how we just deployed the staging server

# Learn from notes
learn deploy: ssh to server, git pull, npm build, restart pm2
```

## Features

- **Standards-compliant SKILL.md** — follows OpenClaw/Hermes format
- **Progressive Disclosure** — light index → full content on demand
- **Skill Bundles** — group related skills
- **Naming enforcement** — kebab-case, ≤60 char descriptions
- **No invented commands** — only uses what's in the source material

## What Gets Generated

```
skills/{name}/
├── SKILL.md          # Full skill instructions
└── README.md         # Brief summary
```

Plus entry in `skills/INDEX.md` for progressive disclosure.

## License

MIT — Built for OpenClaw Agency by Luna 🦉
