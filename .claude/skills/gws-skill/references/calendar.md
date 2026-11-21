# Google Calendar

`G=.claude/skills/gws-skill/scripts/gws.sh`. Scope: `calendar`. Default time zone: Asia/Seoul (`+09:00`).

## Helpers

| Command | Purpose | Key flags |
|---|---|---|
| `+agenda` | Upcoming events across all calendars (read-only) | `--today`, `--tomorrow`, `--week`, `--days N`, `--calendar '<name or ID>'`, `--timezone <IANA>` |
| `+insert` | Create an event | `--summary --start --end` (RFC 3339, required), `--calendar` (default `primary`), `--location`, `--description`, `--attendee <email>` (repeatable; **sends invites**), `--meet` (adds a Google Meet link) |

## Common tasks

```bash
# Agenda
bash $G calendar +agenda --today
bash $G calendar +agenda --week
bash $G calendar +agenda --days 3 --calendar '수업(주)'

# Calendars and their IDs
bash $G calendar calendarList list --params '{"fields":"items(id,summary,primary)"}' --format table

# Create — write tier: preview + approval first (outward-facing if --attendee is used)
bash $G calendar +insert --summary '커리큘럼 회의' --start '2026-11-24T14:00:00+09:00' --end '2026-11-24T15:00:00+09:00' --location '온라인' --meet

# All-day event or reminders → raw insert
bash $G calendar events insert --params '{"calendarId":"primary"}' --json '{"summary":"강의안 제출 마감","start":{"date":"2026-11-20"},"end":{"date":"2026-11-21"}}'
bash $G calendar events insert --params '{"calendarId":"primary"}' --json '{"summary":"회의","start":{"dateTime":"2026-11-24T14:00:00+09:00"},"end":{"dateTime":"2026-11-24T15:00:00+09:00"},"reminders":{"useDefault":false,"overrides":[{"method":"popup","minutes":30}]}}'

# Search events in a range (singleEvents expands recurring events)
bash $G calendar events list --params '{"calendarId":"primary","timeMin":"2026-11-24T00:00:00+09:00","timeMax":"2026-12-01T00:00:00+09:00","singleEvents":true,"orderBy":"startTime","q":"회의"}'

# Natural-language quick add
bash $G calendar events quickAdd --params '{"calendarId":"primary","text":"Lunch with Kim tomorrow 12pm"}'

# Update part of an event / delete it (approval)
bash $G calendar events patch --params '{"calendarId":"primary","eventId":"<ID>"}' --json '{"location":"본사 3층"}'
bash $G calendar events delete --params '{"calendarId":"primary","eventId":"<ID>","sendUpdates":"all"}'

# Free/busy
bash $G calendar freebusy query --json '{"timeMin":"2026-11-24T09:00:00+09:00","timeMax":"2026-11-24T18:00:00+09:00","items":[{"id":"primary"}]}'
```

## Raw API resources

| Resource | Methods |
|---|---|
| `events` | `list get insert patch update delete move quickAdd instances import watch` |
| `calendarList` | the user's calendar list: `list get insert patch update delete` |
| `calendars` | create or delete secondary calendars |
| `freebusy` | `query` |
| `acl` | calendar sharing |
| `settings`, `colors` | user settings, color IDs |

## Notes

- **Date-based requests** ("오늘", "내일", "오늘이랑 내일") → use `--today` / `--tomorrow` (midnight to midnight, KST). `--days N` and `--week` start **now**, so they skip events that already ended today. For "today and tomorrow", run `--today` and `--tomorrow`, or a raw `events list` with explicit `timeMin`/`timeMax`.
- `+agenda` covers **all** calendars. A raw `events list` covers one `calendarId` only.
- Raw `events list` with `--format table` shows `defaultReminders` when there are no events, and that table looks like an event. Use `+agenda` for "what's on my calendar", or add `"fields":"items(summary,start,end,htmlLink)"`.
- `--format table` works with helpers too (it is a global flag).
- An all-day event's `end.date` is **exclusive** (the next day).
- `--attendee` and `sendUpdates:"all"` email other people, so treat them as outward-facing actions.
- `+insert` and `events insert` return `htmlLink`; include it in the report.
