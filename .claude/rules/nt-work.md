# Rule: nt-work

## Keyword

- `nt-work`
- Memo prefixes `업무:` and `강의:` (see `CLAUDE.md` Section 3.1)

## Target

- **Notion DB:** Work DB

## Purpose

- Save **work-related to-dos** (projects, meetings, reports, deadlines, business tasks, lecture work such as preparing or delivering a lecture) to the Work DB.

## Handling

1. When the input has the form `nt-work: content`, treat the content as a work-related to-do.
2. Follow the `notion-db-register` skill flow:
   - Split the content into the Work DB properties (`docs/notion-schema.md`; if it does not exist, fetch the target DB with `notion-fetch` and use the property names it returns).
   - Show a preview in `templates/register-preview.md` format (if the template does not exist, list the target DB, each property value, applied defaults, and planned follow-up tasks) and get user approval.
   - After approval, register via the `notion-writer` subagent.
3. Record the result in `logs/actions.md`.

## Priority

- This rule takes precedence over the Notion trigger DB. If the trigger DB maps `nt-work` to a different DB, follow this rule.
- Use the trigger DB's default values and follow-up tasks only if `nt-work` exists in the trigger DB.

## Mismatch Check

- If the content looks like a personal or study task rather than a work one, do not register it. Ask the user to confirm the keyword (`nt-personal` or `nt-study` may be more appropriate).
- Exception: A memo starting with `강의:` is always treated as lecture work (preparing or delivering a lecture). Register it in the Work DB without the mismatch check, even if the content mentions classes or course materials.
