# Rule: nt-study

## Keyword

- `nt-study`

## Target

- **Notion DB:** Study DB

## Purpose

- Save **study-related to-dos** (courses, reading, assignments, exam preparation, self-learning) to the Study DB.

## Handling

1. When the input has the form `nt-study: content`, treat the content as a study-related to-do.
2. Follow the `notion-db-register` skill flow:
   - Split the content into the Study DB properties (`docs/notion-schema.md`).
   - Show a preview in `templates/register-preview.md` format and get user approval.
   - After approval, register via the `notion-writer` subagent.
3. Record the result in `logs/actions.md`.

## Priority

- This rule takes precedence over the Notion trigger DB. If the trigger DB maps `nt-study` to a different DB, follow this rule.
- Use the trigger DB's default values and follow-up tasks only if `nt-study` exists in the trigger DB.

## Mismatch Check

- If the content looks like a personal or work task rather than a study one, do not register it. Ask the user to confirm the keyword (`nt-personal` or `nt-work` may be more appropriate).
