# Google Workspace Skill 📧

**Gmail, Calendar, Drive, Sheets via `gws` CLI for OpenClaw.**

## What It Does

| Service | Capabilities |
|---------|-------------|
| **Gmail** | Search, read, send, reply, labels |
| **Calendar** | List, create, delete events |
| **Drive** | Search, upload, download, share, delete |
| **Sheets** | Read, write, append, create spreadsheets |

## Key Features (from Hermes Agent)

- **Triage Questions** — Asks what you need before setting up
- **Confirmation Rules** — Always confirms destructive actions, never confirms reads
- **Structured Output** — All commands return JSON
- **Error Handling** — Troubleshooting table for common issues
- **Rate Limit Awareness** — Best practices for API quotas

## Quick Start

```bash
# Check auth
gws auth status

# List unread emails
gws gmail users messages list --params '{"userId": "me", "q": "is:unread", "maxResults": 5}'

# List today's calendar
gws calendar events list --params '{"calendarId": "primary", "timeMin": "2026-07-06T00:00:00Z", "timeMax": "2026-07-07T00:00:00Z", "singleEvents": true}'
```

## License

MIT — Built for OpenClaw Agency by Luna 🦉
