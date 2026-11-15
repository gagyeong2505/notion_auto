---
name: notion-db-register
description: 'Register an item in the target Notion DB resolved from a memo prefix, an nt-* keyword, or a trigger keyword. Use when a "keyword: content" input has been matched to a target DB (via CLAUDE.md Section 3.1 and .claude/rules/, or the trigger DB). Splits the input into DB properties, shows a preview, and registers via the notion-writer subagent only after user approval.'
---

# notion-db-register

Registers an item in the target DB that the trigger keyword has determined.

> **Never register without user approval.**

## Input

- The trigger keyword and the content after the first colon (`keyword: content`).
- The target DB resolved by the main session from the matching rule file (`CLAUDE.md` Section 3, `.claude/rules/`). It takes precedence over the trigger DB.
- Trigger DB information for the keyword, if the keyword exists there: default values and follow-up tasks (and the target DB only when no rule file covers the keyword).

## Procedure

1. **Check the target DB property structure**
   - Read `docs/notion-schema.md` for the target DB's property names and types; if it does not exist, fetch the target DB with `notion-fetch` and use the property names it returns.
   - Never use guessed property names.

2. **Split the input into properties**
   - Map the input content to the target DB properties (e.g., Title, Date, Location, Memo).
   - Convert date and time expressions (e.g., "tomorrow", "next Monday", "3 PM") to absolute values in `YYYY-MM-DD (Day)` / `HH:mm` format, Asia/Seoul time zone.
   - If a required property cannot be determined, ask the user instead of guessing.

3. **Apply trigger DB default values**
   - Fill in the default values defined in the trigger DB (e.g., Status = Scheduled).
   - Values explicitly given by the user take precedence over defaults.

4. **Show a preview and request approval**
   - Present the item in `templates/register-preview.md` format (or as a plain list if the template does not exist): target DB, each property value, applied defaults, and planned follow-up tasks.
   - Wait for the user's response:
     - **Approved** → go to step 5.
     - **Changes requested** → revise and show the preview again.
     - **Rejected / no response** → stop. Do not register.

5. **Register via the `notion-writer` subagent**
   - Pass the approved property values, target DB, and the fact that the user approved.
   - Receive the registration result (title, target DB, page link) and report it to the user.
   - For memos routed by `CLAUDE.md` Section 3.1, report only the single line `저장됨: [DB name]`.

6. **Delegate follow-up tasks**
   - If the trigger DB specifies follow-up tasks (mail, file, calendar), hand them off to the `gws-execute` skill along with the information returned by `notion-writer`.
   - If there are no follow-up tasks, finish here.

7. **Log**
   - Record the result in `logs/actions.md`.

## Rules

- Never register without approval.
- Do not write to Notion directly from this skill. Always use the `notion-writer` subagent.
- If registration fails or partially succeeds, report succeeded and failed items separately with causes.
