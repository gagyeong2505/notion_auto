# Rule: nt-personal

## Keyword

- `nt-personal`

## Target

- **Notion DB:** Personal Tasks DB

## Purpose

- Save **personal to-dos** (private errands, appointments, household tasks, personal reminders) to the Personal Tasks DB.

## Handling

1. When the input has the form `nt-personal: content`, treat the content as a personal to-do.
2. Follow the `notion-db-register` skill flow:
   - Split the content into the Personal Tasks DB properties (`docs/notion-schema.md`).
   - Show a preview in `templates/register-preview.md` format and get user approval.
   - After approval, register via the `notion-writer` subagent.
3. Record the result in `logs/actions.md`.

## Priority

- This rule takes precedence over the Notion trigger DB. If the trigger DB maps `nt-personal` to a different DB, follow this rule.
- Use the trigger DB's default values and follow-up tasks only if `nt-personal` exists in the trigger DB.

## Mismatch Check

- If the content looks like a work or study task rather than a personal one, do not register it. Ask the user to confirm the keyword (`nt-work` or `nt-study` may be more appropriate).
