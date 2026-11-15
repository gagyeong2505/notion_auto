---
name: gws-execute
description: Execute approved follow-up tasks (Gmail, Drive/Docs/Sheets, Calendar) through the GWS CLI. Use when notion-db-register or notion-db-analyze hands off follow-up tasks, or when the user asks to run a GWS task. Builds the commands, shows a command preview, and runs them via the gws-executor subagent only after approval.
---

# gws-execute

Executes approved follow-up tasks with GWS CLI (`gws`) commands.

## Prerequisites

- The `gws` CLI must be installed and authenticated with the user's Google account.
- If `gws` is not available, stop and tell the user that installation and authentication are required.

## Reference Documents

Located in `.claude/skills/gws-execute/references/`:

| Task type | Reference |
|---|---|
| Mail | `references/gmail.md` — draft creation, sending, filling template variables |
| File | `references/drive-docs.md` — creating docs/sheets, choosing folders |
| Calendar | `references/calendar.md` — event registration, time zone (Asia/Seoul), reminders |

## Procedure

1. **Identify the task type**
   - Classify each follow-up task as mail, file, or calendar.

2. **Read the reference and build the commands**
   - If the matching reference document exists in `references/`, read it and build the commands according to it.
   - If it does not exist, check the syntax with `gws --help` (and subcommand help), and tell the user that no reference document was found.
   - For mail, fill template variables from `templates/email/` when a matching template exists; otherwise draft the body directly.

3. **Show a command preview and request approval**
   - Show the exact `gws` commands to be run and a summary of what each does (recipients, subject, file name, event time, etc.).
   - Wait for the user's response:
     - **Approved** → go to step 4.
     - **Changes requested** → revise and show the preview again.
     - **Rejected / no response** → stop. Do not execute.

4. **Execute via the `gws-executor` subagent**
   - Pass the approved commands and the fact that the user approved.
   - **Mail is a two-step process:**
     1. Create a draft only, and show the user the draft content and link.
     2. Send only after the user separately approves sending. Otherwise, leave it as a draft.

5. **Report result links**
   - Report the email draft link (and send status), file links, and event links.
   - On failure or partial success, report succeeded and failed tasks separately with causes.

6. **Log**
   - Record the executed commands and results in `logs/actions.md`.

## Rules

- Never execute commands that have not been approved.
- Approval to create an email draft is not approval to send it.
- Do not run `gws` commands directly from this skill. Always use the `gws-executor` subagent.
