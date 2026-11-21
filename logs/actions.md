# Action Log

## 2026-11-15 (Sun)

- **Action:** Updated `CLAUDE.md` — added Section 3.1 "Memo Classification Rules" (prefixes `개인:`, `업무:`/`강의:`, `배움:`/`공부:` mapped to Personal Tasks / Work / Study DB; one-line `저장됨: [DB name]` output after saving).
- **Translation:** Updated `translate/_CLAUDE.md` with the same section.
- **Result:** Success (approved by user).

- **Action:** Defined `강의:` memos as lecture work → always Work DB. Updated `.claude/rules/nt-work.md` (keyword, purpose, mismatch-check exception), `.claude/rules/nt-study.md` (narrowed "courses", no redirect of `강의:`), and `CLAUDE.md` Section 3.1.
- **Translation:** Updated `translate/_claude/_rules/_nt-work.md`, `translate/_claude/_rules/_nt-study.md`, `translate/_CLAUDE.md`.
- **Result:** Success (approved by user).

- **Action:** Applied prompt-audit fixes (excluding creation of `docs/notion-schema.md`): quoted the `notion-db-register` description (YAML parse error); added `notion-fetch` fallback where `docs/notion-schema.md` is referenced; added plain-list fallback for missing preview/report templates; removed missing `docs/workflow.md` and `docs/approval-policy.md` references; made `templates/email/` optional; added the `저장됨: [DB name]` output exception to `notion-db-register`; routed target DB resolution as CLAUDE.md Section 3 → `.claude/rules/` → `notion-db-register` → `notion-writer` (trigger DB only for defaults/follow-ups or uncovered keywords); renamed project to `notion_auto`.
- **Files:** `CLAUDE.md`, `.claude/rules/nt-*.md` (3), `.claude/skills/notion-db-register|notion-db-analyze|gws-execute/SKILL.md`, `.claude/agents/notion-analyst|notion-writer|gws-executor.md`, and their `translate/` counterparts.
- **Result:** Success (approved by user).

- **Action:** Created Notion API connection `notion_auto` via Playwright MCP (`notion.so/my-integrations` → Developer connections → New connection). Auth: API token (internal). Workspace: user's personal workspace. Capabilities: Read / Update / Insert content; comments off; user info "No user information"; agent capabilities off.
- **Token:** Copied via the page's Copy button and written to `.env` as `NOTION_API_KEY` (never printed; `.env` is git-ignored).
- **Verification:** `GET /v1/users/me` → bot `notion_auto` OK. `POST /v1/search` → 0 results (no pages shared with the connection yet).
- **Result:** Success (approved by user). Pending: share target DBs with the connection.

- **Action:** Checked pages shared with connection `notion_auto` (read-only). API `POST /v1/search` and the Developer connections "Content permissions" tab agree: 1 page — untitled top-level private page ("새 페이지", created 2026-11-15 07:18 UTC, empty). No target DBs (Personal / Work / Study / Trigger) shared yet.
- **Result:** Success (approved by user).

- **Action:** Renamed the page shared with connection `notion_auto` (ID `4199b096-dd3e-8019-9881-ceb1663a18da`, top-level private page) from untitled ("새 페이지") to `개인 일정 관리` via `PATCH /v1/pages/{id}` (title only; content and location unchanged).
- **Note:** The first two attempts via Git Bash `curl` stored a garbled title (U+FFFD) because of a shell encoding issue. The third attempt, using Python `urllib` with UTF-8, overwrote it with the correct title.
- **Verification:** `GET /v1/pages/{id}` → title `개인 일정 관리` matches (last_edited 2026-11-15 07:26 UTC).
- **Result:** Success (approved by user).

- **Action:** Created 3 inline databases under the page `개인 일정 관리` (`4199b096-dd3e-8019-9881-ceb1663a18da`) via the `notion-writer` subagent: `Personal Tasks` (collection://4199b096-dd3e-8194-ad94-000b4567cbd6), `Work` (collection://4199b096-dd3e-81ff-8f09-000b636e368e), `Study` (collection://4199b096-dd3e-814f-874e-000b8b3cada6). Properties: Name, Date, Status, Category, Memo (+ Assignee, Priority on Work). Select option colors were chosen by the agent.
- **Verification:** `notion-fetch` of each DB → property names, types, and options match the approved preview; all 3 are inline on the parent page.
- **Docs:** Created `docs/notion-schema.md` and `translate/_docs/_notion-schema.md`.
- **Result:** Success (approved by user).

- **Action:** Updated the 3 DB schemas via the `notion-writer` subagent (all DBs confirmed empty first). Personal Tasks: +Person, +Priority, +Location; -Status, -Category, -Memo. Work: Date→Due, Assignee→Collaborators, +Registered (created_time), +Email (email); -Status, -Category, -Memo. Study: Name→Topic, Date→Due, Memo→Summary; -Status, -Category.
- **Verification:** Fresh `notion-fetch` → final properties match the approved preview.
- **Docs:** Updated `docs/notion-schema.md` and `translate/_docs/_notion-schema.md` (property tables, filter mapping, removed the `Status = Scheduled` default).
- **Result:** Success (approved by user).

- **Action:** Registered 4 approved memos via the `notion-writer` subagent (4 succeeded, 0 failed):
  - Personal Tasks: 남양주 방문 (Date 2026-11-21 (Sat), Location 남양주)
  - Work: 정규 수업 개강 (Due 2026-11-17 (Tue))
  - Work: 수정된 커리큘럼 표 전달 (Email recorded; no Due)
  - Study: 에이전트 업데이트 사항 업데이트 (Due 2026-11-18 (Wed)), from prefix `학습:` (confirmed by user)
- **Verification:** Each page fetched after creation; values match, Korean text intact. No defaults or follow-up tasks applied.
- **Docs:** Added `학습:` as a Study DB memo prefix in `CLAUDE.md` Section 3.1 and `.claude/rules/nt-study.md`, plus translations `translate/_CLAUDE.md` and `translate/_claude/_rules/_nt-study.md`.
- **Result:** Success (approved by user).

- **Action:** Analyzed `Downloads/가상_커리큘럼_조율_회의록.docx` (fictional curriculum coordination minutes) and classified all action items as Work (lecture work). Registered 8 approved items in the Work DB via the `notion-writer` subagent (duplicate check passed; 8 succeeded, 0 failed). Email = common recipient from the document; Priority empty.
  1. 커리큘럼 조율 회의 (온라인) — Due 2026-11-16 (Mon) 14:00–15:00 KST
  2. 회의 결정사항·담당 일정표 메일 공유 — Due 2026-11-17 (Tue)
  3. 교육목표·주차별 강의안 초안 v1 제출 (DOCX) — Due 2026-11-20 (Fri)
  4. 실습 과제 목록·평가 루브릭 제출 (XLSX) — Due 2026-11-24 (Tue)
  5. 강의자료 템플릿·대표 시안 제출 (PPTX/PNG) — Due 2026-11-27 (Fri)
  6. 통합 운영안·수강생 공지문 제출 (DOCX/PDF) — Due 2026-12-02 (Wed)
  7. 마감 산출물 취합·누락/형식 오류 사전 점검 — Due 2026-12-03 (Thu)
  8. 교차검수표·최종 승인본 제출 및 최종안 승인 (XLSX/PDF) — Due 2026-12-04 (Fri)
- **Verification:** Re-queried after creation; values match, Korean text intact. No defaults or follow-up tasks.
- **Result:** Success (approved by user).

- **Action:** Uploaded all work to GitHub `gagyeong2505/notion_auto` (`main`). Added `.playwright-mcp/` to `.gitignore`; checked new files for secrets (none). Commit `5fc9b26`, pushed `94aaf1b..5fc9b26`.
- **Result:** Success (approved by user).

## 2026-11-21 (Sat)

- **Action:** Installed and authenticated the GWS CLI.
  - `npm install -g @googleworkspace/cli` → `gws 0.22.5`.
  - `winget` could not run, so the Google Cloud CLI 594.0.0 was installed from the official zip to `%LOCALAPPDATA%\Google\google-cloud-sdk`, and its `bin` folder was added to the user PATH.
  - `gcloud auth login --no-launch-browser`: the user signed in through Playwright; Playwright clicked Continue/Allow.
  - `gws auth setup --project gws-workspace-8694` (an existing project) stopped at OAuth client creation, which requires the Console. Enabled the Gmail, Drive, Docs, Sheets, and Calendar APIs with `gcloud services enable`.
  - In the Cloud Console (via Playwright), created the Desktop OAuth client `gws CLI notion_auto` (`479429529840-4iggh57t...`) and wrote `~/.config/gws/client_secret.json`. The consent screen was already External / Testing with the account as a test user.
  - `gws auth login -s gmail,drive,docs,sheets,calendar`: Playwright handled account selection, the unverified-app warning, and consent (all scopes).
- **Verification:** `gws auth status` → `token_valid: true`, refresh token present, credentials encrypted, user `a01087548364@gmail.com`. Read-only tests passed: Drive files list, Gmail `getProfile`, Calendar `calendarList` (exit 0).
- **Cleanup:** Deleted 2 Playwright snapshots that contained the client secret (`.playwright-mcp/` is git-ignored).
- **Result:** Success (approved by user).

- **Action:** Compiled the available `gws` commands and features (read-only: `--help` only, no API calls) for gmail, drive, docs, sheets, calendar, workflow, and auth. Output as tables in chat; no files saved.
- **Result:** Success (approved by user).

- **Action:** Created the `gws-skill` skill (`.claude/skills/gws-skill/`): `SKILL.md`, `references/` (gmail, drive, docs-sheets, calendar, common), `scripts/` (`_env.sh`, `gws.sh` wrapper that loads only `GOOGLE_WORKSPACE_*`/`GWS_*` keys from `.env`, `check.sh` readiness check with auto-install), and `.env.example`. Created the project-root `.env` (git-ignored) with the OAuth client ID/secret and project ID (option A: no exported token file). Added a pointer to `gws-skill` in `gws-execute/SKILL.md`.
- **Verification:** All reference command examples validated with `--dry-run` (exit 0). `check.sh` → READY. Three fresh test agents using only the skill (today/tomorrow agenda; unread mail summary; mail draft and event preview with dry-run) all succeeded with exit 0 and no writes. Their feedback was applied: Gmail dry-run limits, `+triage` ordering and format, `--today`/`--days` semantics, empty-result reporting, privacy of mail content, harmless stderr lines, and precedence of project CLAUDE.md rules.
- **Translation:** `translate/_claude/_skills/_gws-skill/` (SKILL and 5 references), `translate/_claude/_skills/_gws-execute/_SKILL.md`.
- **Result:** Success (approved by user).

- **Action:** Opened the Notion integrations page with Playwright (read-only). `notion.so/profile/integrations` redirected to login; the user signed in manually, and the page then redirected to `app.notion.com/developers/connections` (Developer tools → Developer connections).
- **Findings:** 5 internal connections (API token, workspace "가경 김의 Notion", owner: the user): `notion_auto` (2026-11-15), `agent_09` (2026-11-08), `GG_AI_AG_2607` (2026-08-27), `GG_API` (2026-06-21), `GG_DB` (2026-06-21). Tokens were not opened or displayed. No settings changed.
- **Result:** Success (approved by user).

- **Action:** Opened the Notion page shared with the `notion_auto` connection, using Playwright (read-only). Path: Developer connections → `notion_auto` → Content access tab → Personal pages (1 page): top-level page "개인 일정 관리". The list entry is not a link, so the page was opened from the sidebar (`app.notion.com/p/4199b096dd3e80199881ceb1663a18da`).
- **Findings:** The page holds 3 inline DBs, matching `docs/notion-schema.md`: Personal Tasks (Name/Date/Location/Person/Priority; 1 item), Work (Name/Collaborators/Due/Email/Priority/Registered; 10 items), and Study (Topic/Due/Summary; 1 item). The API token was not displayed. No settings or content changed.
- **Result:** Success (approved by user).

- **Action:** Registered the schedules from the Notion page "개인 일정 관리" in Google Calendar (`primary`) with `gws calendar events insert` (gws-skill). Colors: Personal = `4` Flamingo (pink), Work = `11` Tomato (red), Study = `10` Basil (green). No attendees (no invites sent); collaborators were written in the description.
  - Personal (1): 남양주 방문 — 2026-11-21 (Sat), all day, location 남양주.
  - Work (9): 커리큘럼 조율 회의 (온라인) 2026-11-16 (Mon) 14:00–15:00; 회의 결정사항·담당 일정표 메일 공유 and 정규 수업 개강 2026-11-17 (Tue); 교육목표·주차별 강의안 초안 v1 제출 2026-11-20 (Fri); 실습 과제 목록·평가 루브릭 제출 2026-11-24 (Tue); 강의자료 템플릿·대표 시안 제출 2026-11-27 (Fri); 통합 운영안·수강생 공지문 제출 2026-12-02 (Wed); 마감 산출물 취합·누락/형식 오류 사전 점검 2026-12-03 (Thu); 교차검수표·최종 승인본 제출 및 최종안 승인 2026-12-04 (Fri). All except the meeting are all-day.
  - Study (1): 에이전트 업데이트 사항 업데이트 — 2026-11-18 (Wed), all day.
  - Skipped: 수정된 커리큘럼 표 전달 (Work; no Due date).
- **Notes:** The first attempt (a Python script calling `bash`) resolved to WSL bash and failed before any API call, so nothing was created. Rerun from Git Bash with JSON files: all 11 returned exit 0.
- **Verification:** Before inserting, no events existed from 2026-11-16 to 2026-12-05. Afterwards, `events list` returned all 11 with the correct colors and Korean titles. Opened Google Calendar (Nov 2026 month view) in Playwright.
- **Result:** Success (approved by user).

- **Action:** Uploaded all work to GitHub `gagyeong2505/notion_auto` (`main`): new `gws-skill` (SKILL, 5 references, 3 scripts) with translations, `gws-execute` update, and action logs. Checked new files for secrets (none); `.env` stays ignored.
- **Result:** Success (approved by user).
