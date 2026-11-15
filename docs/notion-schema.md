# Notion Schema

Reference for the Notion databases used by `notion_auto`. Use the property names below exactly. If this file and Notion disagree, re-check with `notion-fetch` and update this file.

## Parent Page

- **Title:** 개인 일정 관리
- **Page ID:** `4199b096-dd3e-8019-9881-ceb1663a18da`
- All databases below are inline databases on this page.

## Database Map

| DB | Rule file | Database ID | Data source |
|---|---|---|---|
| Personal Tasks | `.claude/rules/nt-personal.md` | `4199b096-dd3e-818a-8138-ff08a61d2e73` | `collection://4199b096-dd3e-8194-ad94-000b4567cbd6` |
| Work | `.claude/rules/nt-work.md` | `4199b096-dd3e-8142-869a-e303d56a736c` | `collection://4199b096-dd3e-81ff-8f09-000b636e368e` |
| Study | `.claude/rules/nt-study.md` | `4199b096-dd3e-81ab-8298-f398ac972402` | `collection://4199b096-dd3e-814f-874e-000b8b3cada6` |

## Properties

### Personal Tasks

| Property | Type | Options / Notes |
|---|---|---|
| `Name` | title | Schedule name |
| `Date` | date | Scheduled date |
| `Person` | rich_text | People involved (plain text) |
| `Priority` | select | `High`, `Medium`, `Low` |
| `Location` | rich_text | Place |

### Work

| Property | Type | Options / Notes |
|---|---|---|
| `Name` | title | Task name (`강의:` memos are lecture work) |
| `Registered` | created_time | Set automatically on creation; read-only |
| `Due` | date | Deadline |
| `Collaborators` | rich_text | Plain text, because the API connection has no user-information access |
| `Email` | email | Single address; recipient for GWS follow-up emails |
| `Priority` | select | `High`, `Medium`, `Low` |

### Study

| Property | Type | Options / Notes |
|---|---|---|
| `Topic` | title | Study topic |
| `Due` | date | Deadline |
| `Summary` | rich_text | Summary |

- No DB has a `Status` property, so completion state is not tracked.

## Filter Mapping (for notion-db-analyze)

| Expression | Filter |
|---|---|
| due today | Personal Tasks: `Date` = today; Work / Study: `Due` = today |
| this week | same date property within this week's range |
| past due | date property < today (completion cannot be checked without `Status`) |
| high priority | `Priority` = `High` (Personal Tasks / Work) |
| collaborator = X (Work only) | `Collaborators` contains X |

## Trigger DB

- Not created yet. Rule files take precedence; until a trigger DB exists, apply no default values and run no follow-up tasks.
