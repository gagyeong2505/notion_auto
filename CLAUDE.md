# CLAUDE.md

Project-wide rules for `agent1114`. Claude Code reads this document at the start of every session and treats it as the baseline for all work.

## 1. Project Purpose

- Query and analyze Notion databases, and register items using trigger keywords.
- Carry approved tasks forward through the GWS CLI (mail, files, calendar).

## 2. Workflow Rule (Report First, Then Execute)

- For every task the user requests, first output a **todo list** describing the planned steps.
- Do not start execution until the user approves the todo list.
- If the user requests changes, revise the todo list and ask for approval again.

## 3. Request Routing Rules

- Request in the form `keyword: content` → run the registration flow via the **notion-db-register** skill.
- General request without a keyword (e.g., "Check today's tasks due") → run the analysis flow via the **notion-db-analyze** skill.

## 4. Absolute Rules

- Notion writes, email sending, and file creation must be executed **only after user approval**.
- Before approval, always show a preview (`templates/register-preview.md` or `templates/report.md`).
- Record every execution result in `logs/actions.md`.

## 5. Role Division (Subagents)

| Subagent | Responsibility |
|---|---|
| `notion-analyst` | Query and analysis (read-only); filter by date, status, assignee, etc. and report results |
| `notion-writer` | Create DB tables; classify schedules by trigger and register them; update approved items |
| `gws-executor` | Execute all approved GWS follow-up tasks; draft emails first and send only after send approval |

## 6. Reference Documents

- `docs/notion-schema.md`
- `docs/workflow.md`
- `docs/approval-policy.md`

## 7. Documentation & Translation Rules

- All `.md` files in this project must be written in **English**.
- A Korean translation of each `.md` file must be saved separately in the `translate/` folder at the project root.
- Every file and folder name inside `translate/` must be prefixed with `_`.
  - Example: translation of `CLAUDE.md` → `translate/_CLAUDE.md`
  - Example: translation of the `.claude/` folder → `translate/_claude/`
- Mirror the original directory structure under `translate/` (e.g., `docs/workflow.md` → `translate/_docs/_workflow.md`).
- When an English `.md` file is created or modified, create or update its Korean translation in the same task.

## 8. Response Language & Format

- Respond to the user in **Korean** (documentation files remain in English per Section 7).
- Format dates as `YYYY-MM-DD (Day)`.
