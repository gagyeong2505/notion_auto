# Rule: nt-study

## Keyword

- `nt-study`
- Memo prefixes `배움:`, `공부:`, and `학습:` (see `CLAUDE.md` Section 3.1)

## Target

- **Notion DB:** Study DB

## Purpose

- Save **study-related to-dos** (courses the user takes as a learner, reading, assignments, exam preparation, self-learning) to the Study DB.

## Handling

1. When the input has the form `nt-study: content`, treat the content as a study-related to-do.
2. Follow the `notion-db-register` skill flow:
   - Split the content into the Study DB properties (`docs/notion-schema.md`; if it does not exist, fetch the target DB with `notion-fetch` and use the property names it returns).
   - Show a preview in `templates/register-preview.md` format (if the template does not exist, list the target DB, each property value, applied defaults, and planned follow-up tasks) and get user approval.
   - After approval, register via the `notion-writer` subagent.
3. Record the result in `logs/actions.md`.

## Priority

- This rule takes precedence over the Notion trigger DB. If the trigger DB maps `nt-study` to a different DB, follow this rule.
- Use the trigger DB's default values and follow-up tasks only if `nt-study` exists in the trigger DB.

## Mismatch Check

- If the content looks like a personal or work task rather than a study one, do not register it. Ask the user to confirm the keyword (`nt-personal` or `nt-work` may be more appropriate).
- A memo starting with `강의:` is lecture work, not study. Never redirect it to the Study DB; it follows `nt-work.md`.
