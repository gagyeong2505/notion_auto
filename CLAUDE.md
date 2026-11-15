# CLAUDE.md

Project-wide rules for `notion_auto`. Claude Code reads this document at the start of every session and treats it as the baseline for all work.

## 1. Project Purpose

- Query and analyze Notion databases, and register items using trigger keywords.
- Carry approved tasks forward through the GWS CLI (mail, files, calendar).

## 2. Workflow Rule (Report First, Then Execute)

- For every task the user requests, first output a **todo list** describing the planned steps.
- Do not start execution until the user approves the todo list.
- If the user requests changes, revise the todo list and ask for approval again.

## 3. Request Routing Rules

- Request in the form `keyword: content` → resolve the target DB first, then run the registration flow via the **notion-db-register** skill:
  1. Match the keyword against Section 3.1 (memo prefixes) or an `nt-*` keyword.
  2. Read the matching rule file in `.claude/rules/`. The rule file fixes the target DB and takes precedence over the Notion trigger DB.
  3. Pass the target DB to `notion-db-register`. Use the trigger DB only for default values and follow-up tasks, or to resolve keywords that no rule file covers.
- General request without a keyword (e.g., "Check today's tasks due") → run the analysis flow via the **notion-db-analyze** skill.

### 3.1 Memo Classification Rules

When the user enters a memo, classify it by its prefix and save it to Notion:

| Prefix | Rule to read | Target DB |
|---|---|---|
| `개인:` | `.claude/rules/nt-personal.md` | Personal Tasks DB |
| `업무:` or `강의:` | `.claude/rules/nt-work.md` | Work DB |
| `배움:`, `공부:`, or `학습:` | `.claude/rules/nt-study.md` | Study DB |

- `강의:` memos are always judged as lecture work and saved to the Work DB (no mismatch check).
- The preview and approval steps in Section 4 still apply before saving.
- After saving, output only one line: `저장됨: [DB name]`.

## 4. Absolute Rules

- Notion writes, email sending, and file creation must be executed **only after user approval**.
- Before approval, always show a preview (use `templates/register-preview.md` or `templates/report.md` when present; otherwise list the fields the skill names).
- Record every execution result in `logs/actions.md`.

## 5. Role Division (Subagents)

| Subagent | Responsibility |
|---|---|
| `notion-analyst` | Query and analysis (read-only); filter by date, status, assignee, etc. and report results |
| `notion-writer` | Create DB tables; classify schedules by trigger and register them; update approved items |
| `gws-executor` | Execute all approved GWS follow-up tasks; draft emails first and send only after send approval |

## 6. Reference Documents

- `docs/notion-schema.md` (if missing, read DB properties directly with `notion-fetch`)

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
