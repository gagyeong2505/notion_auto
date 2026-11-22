# Rule: pm-workflow

## Scope

- Applies to the `pm` subagent and to the main session when it dispatches agents per a pm plan.
- Trigger: a work request based on Notion data that asks for a deliverable (report, slides, sheet, mail). Pure queries go to `notion-db-analyze`, not pm.

## 1. Request → Agent Mapping

| Request wording (KO/EN) | Agent | Deliverable |
|---|---|---|
| 보고서, 문서, 회의록, 정리 / report, doc, minutes | `docs-writer` | Google Docs |
| 발표, PPT, 제안서, 슬라이드 / slides, deck, proposal | `slides-writer` | Google Slides |
| 표, 시트, 엑셀, 집계 / sheet, table, tally | `sheets-writer` | Google Sheets |
| 메일, 공유, 안내, 리마인드 / mail, notify, remind | `mail-writer` | Gmail draft |

- If one request names several deliverables, create one task per deliverable.
- If the deliverable type is unclear, ask the user; do not guess.

## 2. Task Splitting Rules

- One task = one agent + one deliverable + one approval.
- Order of dependency: `sheets` → `docs` → `slides` → `mail` (later tasks may reference earlier results; mail usually links to the others).
- Tasks with no dependency are marked "parallel".
- Maximum 5 tasks per plan. If more are needed, split into phases and ask the user.

## 3. Input Data Handoff

Every task passed to a writer must include:

- Source DB (Personal Tasks / Work / Study) and the filter used (e.g., `Due` between 2026-11-23 (Mon) and 2026-11-29 (Sun)).
- The exact rows used (Name, date, priority, etc.). Writers must not re-query Notion.
- Deliverable title in the form `[YYYY-MM-DD] <topic> <type>` (e.g., `[2026-11-22] 주간 업무 보고서`).
- For mail: recipients from the Work DB `Email` property only. If empty, mark the recipient as `TBD` and ask the user. Never invent an address.

## 4. Approval Gates

| Gate | When | Who approves |
|---|---|---|
| Plan approval | After pm Mode 1 | User |
| Write approval | Each writer's preview, before creation | User |
| Send approval | Mail only, after the draft is inspected `PASS` | User (separately) |

- Never merge gates (e.g., "approve plan and send mail" in one step).
- Mail is never sent before its inspection is `PASS`.

## 5. Inspection Policy

- Every writer task goes to `inspection`; no task is "done" without a verdict.
- Rework handoff must include: task number, round `n/3`, and the full fix list.
- On `FAIL (final)`: stop, report remaining issues, and ask the user whether to fix manually, accept as-is, or delete the deliverable.

## 6. Stop & Escalate

Stop and ask the user when:

- The Notion analysis returns 0 rows.
- Data needed for a deliverable is missing (no due date, no recipient, etc.).
- A writer reports an auth or `gws` error.
- The request includes sharing, permission changes, or deletion (out of scope).

## 7. Logging

pm's final report must include `logs/actions.md` lines in this format:

| Date | Task | Agent | Deliverable (link) | Inspection | Status |
|---|---|---|---|---|---|

## 8. Prohibited

- pm never creates, edits, sends, or deletes anything.
- pm never assigns `notion-writer` (Notion writes are outside the pm workflow).
- pm never skips the user-approval step, even if the user says "알아서 해".
