---
name: google-workspace
description: Gmail, Calendar, Drive, Sheets via gws CLI. OAuth setup, triage, confirmations, structured output. For OpenClaw.
version: 1.0.0
author: Luna (OpenClaw Agency)
---

# Google Workspace Skill 📧

Gmail, Calendar, Drive, and Sheets through the `gws` CLI (v0.18.1). Includes OAuth setup flow, triage questions, confirmation rules, and structured JSON output.

**Source of patterns:** [Hermes Agent](https://github.com/NousResearch/hermes-agent) Google Workspace skill.

## Quick Reference

| Service | Command | Example |
|---------|---------|---------|
| Gmail | `gws gmail users messages list` | List unread emails |
| Gmail | `gws gmail users messages get` | Read email content |
| Gmail | `gws gmail users messages send` | Send email |
| Calendar | `gws calendar events list` | List upcoming events |
| Calendar | `gws calendar events insert` | Create event |
| Drive | `gws drive files list` | Search files |
| Drive | `gws drive files create` | Upload/create file |
| Sheets | `gws sheets spreadsheets get` | Read spreadsheet |
| Sheets | `gws sheets spreadsheets values get` | Read cell range |

## Setup (First Time)

### Check Auth Status

```bash
gws auth status
```

If `AUTHENTICATED` → ready to use. If `NOT_AUTHENTICATED` → run setup.

### Setup Flow

```bash
# Step 1: Check status
gws auth status

# Step 2: If not authenticated, start OAuth flow
gws auth login

# Step 3: Follow browser prompts to authorize

# Step 4: Verify
gws auth status
```

**If auth fails:**
- `REFRESH_FAILED` → redo `gws auth login`
- `403: Insufficient Permission` → missing scope, re-authorize
- `403: Access Not Configured` → enable API in Google Cloud Console

## Triage Questions

Before using Google Workspace, ask:

1. **"What services do you need?"**
   - Email only → use `gws gmail`
   - Calendar only → use `gws calendar`
   - Full workspace → use all services

2. **"Is this a one-time action or recurring?"**
   - One-time → execute directly
   - Recurring → create a cron job or template

## Confirmation Rules

### Always Confirm First

| Action | What to Show |
|--------|-------------|
| **Send email** | Recipients, subject, body preview |
| **Create calendar event** | Summary, time, attendees |
| **Delete calendar event** | Event details |
| **Upload to Drive** | File name, destination folder |
| **Share Drive file** | Email, role (reader/writer) |
| **Delete Drive file** | File name, trash vs permanent |
| **Write to Sheets** | Range, values |
| **Modify Gmail labels** | Message subject, labels |

### Never Confirm

| Action | Why |
|--------|-----|
| Read emails | Non-destructive |
| List calendar | Non-destructive |
| Search Drive | Non-destructive |
| Read spreadsheet | Non-destructive |

## Gmail

### Search Emails

```bash
# Unread messages
gws gmail users messages list --params '{"userId": "me", "q": "is:unread", "maxResults": 10}'

# From specific sender
gws gmail users messages list --params '{"userId": "me", "q": "from:boss@company.com newer_than:1d"}'

# With attachments
gws gmail users messages list --params '{"userId": "me", "q": "has:attachment filename:pdf newer_than:7d"}'

# Search syntax: is:unread, from:, to:, subject:, newer_than:, has:attachment, label:
```

### Read Email

```bash
# Get message by ID (format=full for complete content)
gws gmail users messages get --params '{"userId": "me", "id": "MESSAGE_ID", "format": "full"}'
```

### Send Email

```bash
# Plain text
gws gmail users messages send --json '{
  "userId": "me",
  "raw": "From: sender@example.com\r\nTo: recipient@example.com\r\nSubject: Hello\r\n\r\nMessage body"
}'

# HTML
gws gmail users messages send --json '{
  "userId": "me",
  "raw": "From: sender@example.com\r\nTo: recipient@example.com\r\nSubject: Report\r\nContent-Type: text/html\r\n\r\n<h1>Q4 Report</h1><p>Details...</p>"
}'
```

### Reply to Email

```bash
# Reply (auto-threads via In-Reply-To)
gws gmail users messages send --json '{
  "userId": "me",
  "raw": "From: sender@example.com\r\nTo: original@example.com\r\nSubject: Re: Original Subject\r\nIn-Reply-To: <ORIGINAL_MESSAGE_ID>\r\n\r\nThanks, that works for me."
}'
```

### Modify Labels

```bash
# Add label
gws gmail users messages modify --params '{"userId": "me", "id": "MSG_ID"}' --json '{
  "addLabelIds": ["LABEL_ID"],
  "removeLabelIds": []
}'

# Mark as read (remove UNREAD)
gws gmail users messages modify --params '{"userId": "me", "id": "MSG_ID"}' --json '{
  "addLabelIds": [],
  "removeLabelIds": ["UNREAD"]
}'
```

## Calendar

### List Events

```bash
# Next 7 days (default)
gws calendar events list --params '{"calendarId": "primary", "timeMin": "2026-07-06T00:00:00Z", "timeMax": "2026-07-13T23:59:59Z", "singleEvents": true, "orderBy": "startTime"}'

# Specific range
gws calendar events list --params '{"calendarId": "primary", "timeMin": "2026-07-01T00:00:00Z", "timeMax": "2026-07-31T23:59:59Z", "singleEvents": true}'
```

### Create Event

```bash
gws calendar events insert --params '{"calendarId": "primary"}' --json '{
  "summary": "Team Standup",
  "start": {"dateTime": "2026-07-07T10:00:00-03:00", "timeZone": "America/Sao_Paulo"},
  "end": {"dateTime": "2026-07-07T10:30:00-03:00", "timeZone": "America/Sao_Paulo"},
  "attendees": [{"email": "alice@co.com"}, {"email": "bob@co.com"}],
  "location": "Meeting Room A"
}'
```

### Delete Event

```bash
gws calendar events delete --params '{"calendarId": "primary", "eventId": "EVENT_ID"}'
```

## Drive

### Search Files

```bash
# By name
gws drive files list --params '{"q": "name contains \'quarterly report\'", "pageSize": 10}'

# By MIME type
gws drive files list --params '{"q': "mimeType=\'application/pdf\'", "pageSize": 5}'

# In specific folder
gws drive files list --params '{"q': "\'FOLDER_ID\' in parents", "pageSize": 20}'
```

### Get File Metadata

```bash
gws drive files get --params '{"fileId": "FILE_ID"}'
```

### Upload File

```bash
# Upload with auto-detect MIME type
gws drive files create --upload /path/to/report.pdf --params '{"name": "Report.pdf", "parents": ["FOLDER_ID"]}'
```

### Download File

```bash
# Download as-is
gws drive files get --params '{"fileId": "FILE_ID", "alt": "media"}' --output /path/to/download.pdf
```

### Share File

```bash
# Share with specific person
gws drive permissions create --params '{"fileId": "FILE_ID"}' --json '{
  "role": "reader",
  "type": "user",
  "emailAddress": "alice@example.com"
}'

# Anyone with link
gws drive permissions create --params '{"fileId": "FILE_ID"}' --json '{
  "role": "reader",
  "type": "anyone"
}'
```

### Delete File (Trash by Default)

```bash
# Move to trash (reversible)
gws drive files delete --params '{"fileId": "FILE_ID"}'

# Permanent delete (use --params with supportsAllDrives=true if needed)
gws drive files delete --params '{"fileId": "FILE_ID"}'
```

## Sheets

### Read Spreadsheet

```bash
# Get spreadsheet metadata
gws sheets spreadsheets get --params '{"spreadsheetId": "SHEET_ID"}'

# Read cell range
gws sheets spreadsheets values get --params '{"spreadsheetId": "SHEET_ID", "range": "Sheet1!A1:D10"}'
```

### Write to Spreadsheet

```bash
# Update range
gws sheets spreadsheets values update --params '{"spreadsheetId": "SHEET_ID", "range": "Sheet1!A1:B2"}' --json '{
  "values": [["Name", "Score"], ["Alice", "95"], ["Bob", "87"]]
}'

# Append rows
gws sheets spreadsheets values append --params '{"spreadsheetId": "SHEET_ID", "range": "Sheet1!A:C", "valueInputOption": "USER_ENTERED"}' --json '{
  "values": [["new", "row", "data"]]
}'
```

### Create Spreadsheet

```bash
gws sheets spreadsheets create --json '{
  "properties": {"title": "Q4 Budget"},
  "sheets": [{"properties": {"title": "Expenses"}}]
}'
```

## Output Format

All commands return JSON. Key fields:

| Service | Key Fields |
|---------|-----------|
| **Gmail search** | `[{id, threadId, snippet, labels}]` |
| **Gmail get** | `{id, threadId, payload: {headers, body}}` |
| **Calendar list** | `[{id, summary, start, end, attendees}]` |
| **Drive search** | `[{id, name, mimeType, modifiedTime}]` |
| **Sheets get** | `{values: [[cell, cell, ...], ...]}` |

## Error Handling

| Error | Fix |
|-------|-----|
| `NOT_AUTHENTICATED` | Run `gws auth login` |
| `REFRESH_FAILED` | Token revoked — redo `gws auth login` |
| `403: Insufficient Permission` | Missing scope — re-authorize |
| `403: Access Not Configured` | Enable API in Google Cloud Console |
| `404: Not Found` | Check file/event/message ID |
| `429: Rate Limit` | Back off, batch reads when possible |

## Rate Limits

- Gmail: 250 quota units/second
- Calendar: 1,000,000 requests/day
- Drive: 12,000 requests/100 seconds
- Sheets: 300 requests/minute

**Best practices:**
- Batch reads when possible
- Avoid rapid-fire sequential calls
- Use `--page-all` for large result sets
- Cache frequently accessed data

## Troubleshooting

| Problem | Cause | Fix |
|---------|-------|-----|
| Auth loop | Expired token | `gws auth login` |
| Missing emails | Wrong label filter | Check `is:unread`, `label:` syntax |
| Event not created | Missing timezone | Always use ISO 8601 with offset |
| File not shared | Wrong permission type | Check `user` vs `anyone` vs `domain` |
| Sheet write fails | Range format wrong | Use `Sheet1!A1:B2` notation |

## Rules

1. **Always confirm** destructive actions (send, create, delete, share, modify)
2. **Never confirm** read-only actions (search, list, get)
3. **Check auth** before first use
4. **Include timezone** in all calendar operations
5. **Prefer trash** over permanent delete for Drive files
6. **Batch reads** to respect rate limits
7. **Cache results** for frequently accessed data

## License

MIT — Built for OpenClaw Agency by Luna 🦉
