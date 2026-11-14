---
name: notion-db-analyze
description: Handle Notion query and analysis requests that contain no trigger keyword (e.g., "Check today's tasks due", "Show overdue tasks this week", "List incomplete tasks for Kim"). Converts the request into filter conditions, queries via the notion-analyst subagent, and reports results. Read-only — never writes to Notion.
---

# notion-db-analyze

Handles query and analysis requests that do not use a trigger keyword.

> **This skill never writes to Notion** (no page or database creation, update, or deletion).

## Input

- A general request without a `keyword:` prefix.

## Procedure

1. **Convert the request into query conditions**
   - Map the request's expressions to filter conditions using the mapping in `docs/notion-schema.md`.
     - e.g., "due today" → Date = today; "overdue" → Date < today AND Status ≠ Done; "incomplete" → Status ≠ Done.
   - Convert relative dates to absolute dates (Asia/Seoul, `YYYY-MM-DD (Day)`).
   - If the target DB or a condition is ambiguous, ask the user before querying.

2. **Query via the `notion-analyst` subagent**
   - Pass the original request text and the converted conditions (date, status, assignee, etc.).

3. **Report**
   - Present the result in `templates/report.md` format: applied conditions, number of matching items, item list (title, date, status, assignee, link).

4. **Suggest follow-up tasks**
   - Based on the follow-up candidates returned by `notion-analyst`, suggest follow-up tasks (e.g., drafting deadline-reminder emails, creating a summary document, registering calendar events).
   - Only if the user approves, hand them off to the `gws-execute` skill.
   - If not approved, finish without further action.

## Rules

- No Notion writes in this skill. If the user asks to modify data during analysis, explain that it requires a separate registration/update flow with approval.
- Use only property names confirmed in `docs/notion-schema.md`.
- Do not execute follow-up tasks without approval.
