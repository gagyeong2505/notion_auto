---
name: gws-skill
description: "Use the Google Workspace CLI (gws) to read and act on the user's Gmail, Google Drive, Docs, Sheets, and Calendar — with credentials loaded automatically from .env. Use this skill whenever the user wants to check, search, send, draft, reply to, or forward email; list, upload, download, export, share, or organize Drive files; create or edit Google Docs or Sheets; or view, add, change, or delete calendar events — even if they never say 'gws' (e.g. '오늘 일정 보여줘', '안 읽은 메일 요약', '이 파일 드라이브에 올려줘', '회의 일정 잡아줘'). Also use it for gws installation, login, auth errors, or questions about which gws commands exist."
---

# gws-skill

Run Google Workspace tasks through the `gws` CLI. The bundled scripts load the OAuth client from `.env`, so no manual environment setup is needed.

## 1. Before the first command: readiness check

```bash
bash .claude/skills/gws-skill/scripts/check.sh
```

| Exit | Meaning | What to do |
|---|---|---|
| 0 `READY` | Installed, `.env` loaded, logged in | Continue |
| 1 | gws/npm missing (gws is auto-installed via npm when npm exists) | Ask the user to install Node.js 18+ |
| 2 | `.env` missing or empty client values | Copy `.env.example` to the project root as `.env`; ask the user for the values from Cloud Console |
| 3 | Not logged in / token expired | Run the login command it prints. It opens a browser and the **user** must sign in |

Run the check once per session, or again after an exit code `2` (auth error) from any command.

## 2. Running commands

Always run gws through the wrapper so `.env` is loaded:

```bash
G=.claude/skills/gws-skill/scripts/gws.sh
bash $G calendar +agenda --today
bash $G gmail +triage --max 5
```

- Use **Git Bash** (the Bash tool). PowerShell breaks the JSON quoting in `--params` / `--json`.
- Paths are relative to the project root. If the shell may start elsewhere (for example in a subagent), `cd` to the project root first or use the absolute path.
- Every call prints `Using keyring backend: keyring` to stderr. This is normal. Add `2>/dev/null` when you pipe JSON into a parser.
- The wrapper exports only `GOOGLE_WORKSPACE_*` / `GWS_*` keys from `.env`, so other secrets in the same file are not passed to gws.
- Command shape: `gws <service> <resource> [sub-resource] <method> --params '<JSON>' --json '<JSON>'`, or a `+helper` shortcut. Prefer helpers when one fits; they handle encoding, threading, and time formatting.
- Unsure of the parameters? Run `bash $G schema <service.resource.method>` (e.g. `calendar.events.insert`).
- Use `--format table` for readable output in chat, and keep the default `json` when you need IDs from the result.

## 3. Pick the reference for the task

Read only the reference that matches the task:

| Task | Reference |
|---|---|
| Email: triage, search, read, send, draft, reply, forward, labels | `references/gmail.md` |
| Drive: list/search, upload, download, export, folders, sharing | `references/drive.md` |
| Docs and Sheets: create, read, append, update | `references/docs-sheets.md` |
| Calendar: agenda, create/update/delete events, free/busy | `references/calendar.md` |
| Global flags, auth, exit codes, workflows, other services, troubleshooting | `references/common.md` |

## 4. Safety: preview before anything that changes data

Other people can see sent mail, shared files, and calendar invites, and those actions are hard to undo. So treat commands in three tiers:

| Tier | Examples | Handling |
|---|---|---|
| Read-only | `+triage`, `+read`, `+agenda`, `files list`, `+read` (sheets), `get`, `list`, `schema`, `auth status` | Run directly |
| Write | `+send --draft`, `+upload`, `files create/copy/update`, `+append`, `+write`, `+insert`, `events patch` | Show a preview (exact command plus a plain summary: recipients, file name, time) and wait for approval |
| Outward-facing or irreversible | Sending email (`+send` without `--draft`, `+reply`, `+forward`, `drafts send`), `permissions create`, `delete`, `trash`, `emptyTrash`, `+insert --attendee` (sends invites) | Preview and get **explicit** approval. For email, create a draft first and send only after a separate send approval |

- `--dry-run` validates a write command locally without calling the API. For Calendar, Drive, Docs, and Sheets it prints the full request body. For the Gmail helpers (`+send`, `+reply`, `+forward`) it shows only the endpoint (`"message":{}`), so it does not prove that the recipients, subject, or body are right. Always write those out in the preview yourself.
- Several write actions for one request (for example a draft plus an event) can share one preview and one approval. Number them so the user can approve or change each one.

**Project rules win over this table.** When the project's `CLAUDE.md` is stricter, follow it. In this project (`notion_auto`):
- Show a todo list or plan first and wait for approval, even for read-only requests. For write tasks, the plan includes the full preview above.
- Record each executed result, read-only queries included, in `logs/actions.md` (and its Korean translation `translate/_logs/_actions.md`). Do not log dry-runs or previews that were never executed.
- Follow-up tasks handed off from Notion go through the `gws-execute` skill and the `gws-executor` subagent. Direct user requests can use this skill directly.

## 5. Defaults for this user

- Time zone: **Asia/Seoul (+09:00)**. Write times in RFC 3339 (`2026-11-24T10:00:00+09:00`).
- When reporting dates to the user, use `YYYY-MM-DD (Day)`.
- Authorized scopes: gmail.modify, drive, documents, spreadsheets, calendar. Other services (tasks, slides, chat, …) need a new login with more scopes (see `references/common.md`).

## 6. Reporting results

- Summarize results in a short table and include links: `https://mail.google.com/mail/u/0/#drafts`, the `webViewLink` of Drive files, and the `htmlLink` of calendar events.
- For an empty result, say so plainly and state the scope you checked (for example "일정 없음 — 3 calendars checked, 2026-11-21 (Sat) ~ 2026-11-22 (Sun)"), so the user knows it is not an error.
- Email content is private. Summarize it (sender, subject, a one-line gist) instead of pasting bodies, and leave out tracking or unsubscribe URLs and tokens that `+read` prints.
- On a non-zero exit, show the error `message` and use the exit code table in `references/common.md` to explain it. Do not retry write commands automatically, because a retry could duplicate the email or event.
