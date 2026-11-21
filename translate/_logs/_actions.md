# 작업 기록 (한글 번역본)

## 2026-11-15 (일)

- **작업:** `CLAUDE.md` 수정 — 3.1 "메모 분류 규칙" 섹션 추가(접두어 `개인:`, `업무:`/`강의:`, `배움:`/`공부:`를 각각 Personal Tasks / Work / Study DB에 연결, 저장 후 `저장됨: [DB명]` 한 줄 출력).
- **번역:** `translate/_CLAUDE.md`에 같은 섹션 반영.
- **결과:** 성공(사용자 승인 완료).

- **작업:** `강의:` 메모를 강의 업무로 정의 → 항상 Work DB에 저장. `.claude/rules/nt-work.md`(키워드, 목적, 불일치 확인 예외), `.claude/rules/nt-study.md`("강의" 범위를 수강으로 한정, `강의:` 메모 전환 금지), `CLAUDE.md` 3.1 수정.
- **번역:** `translate/_claude/_rules/_nt-work.md`, `translate/_claude/_rules/_nt-study.md`, `translate/_CLAUDE.md` 갱신.
- **결과:** 성공(사용자 승인 완료).

- **작업:** prompt-audit 수정 적용(`docs/notion-schema.md` 작성 제외): `notion-db-register` description 따옴표 처리(YAML 오류); `docs/notion-schema.md`를 참조하는 곳에 `notion-fetch` 대체 경로 추가; 미리보기·보고 템플릿이 없을 때 일반 목록으로 출력; 없는 `docs/workflow.md`, `docs/approval-policy.md` 참조 삭제; `templates/email/`을 선택 사항으로 변경; `notion-db-register`에 `저장됨: [DB명]` 출력 예외 추가; 저장 DB 결정 흐름을 CLAUDE.md 3번 → `.claude/rules/` → `notion-db-register` → `notion-writer`로 정리(트리거 DB는 기본값·후속 작업 또는 규칙 파일이 없는 키워드에만 사용); 프로젝트 이름을 `notion_auto`로 변경.
- **파일:** `CLAUDE.md`, `.claude/rules/nt-*.md`(3개), `.claude/skills/notion-db-register|notion-db-analyze|gws-execute/SKILL.md`, `.claude/agents/notion-analyst|notion-writer|gws-executor.md` 및 각 `translate/` 번역본.
- **결과:** 성공(사용자 승인 완료).

- **작업:** Playwright MCP로 Notion API 연결 `notion_auto` 생성(`notion.so/my-integrations` → Developer connections → 신규 연결). 인증: API 토큰(내부용). 워크스페이스: 사용자 개인 워크스페이스. 권한: 콘텐츠 읽기/업데이트/삽입 켬, 댓글 끔, 사용자 정보 "사용자 정보 없음", 에이전트 기능 끔.
- **토큰:** 화면의 복사하기 버튼으로 복사해 `.env`에 `NOTION_API_KEY`로 저장(화면 출력 없음, `.env`는 git 제외 대상).
- **검증:** `GET /v1/users/me` → 봇 `notion_auto` 정상. `POST /v1/search` → 결과 0건(아직 연결에 공유된 페이지 없음).
- **결과:** 성공(사용자 승인 완료). 남은 작업: 대상 DB를 연결에 공유.

- **작업:** `notion_auto` 연결에 공유된 페이지 확인(조회만 함). API `POST /v1/search` 결과와 개발자 화면의 "콘텐츠 사용 권한" 탭 결과가 같음: 1개 페이지 — 제목 없는 최상위 개인 페이지("새 페이지", 2026-11-15 07:18 UTC 생성, 내용 없음). 대상 DB(개인/업무/배움/트리거)는 아직 공유되지 않음.
- **결과:** 성공(사용자 승인 완료).

- **작업:** `notion_auto` 연결에 공유된 페이지(ID `4199b096-dd3e-8019-9881-ceb1663a18da`, 최상위 개인 페이지)의 제목을 없음("새 페이지")에서 `개인 일정 관리`로 변경함. `PATCH /v1/pages/{id}` 사용(제목만 변경, 내용과 위치는 그대로).
- **참고:** Git Bash `curl`로 보낸 첫 두 번의 시도에서는 셸 인코딩 문제로 제목이 깨진 문자(U+FFFD)로 저장됨. 세 번째로 Python `urllib`(UTF-8)로 다시 보내 올바른 제목으로 덮어씀.
- **검증:** `GET /v1/pages/{id}` → 제목 `개인 일정 관리` 일치 확인(최종 수정 2026-11-15 07:26 UTC).
- **결과:** 성공(사용자 승인 완료).

- **작업:** `notion-writer` 서브에이전트로 `개인 일정 관리` 페이지(`4199b096-dd3e-8019-9881-ceb1663a18da`) 아래에 인라인 데이터베이스 3개를 만듦: `Personal Tasks`(collection://4199b096-dd3e-8194-ad94-000b4567cbd6), `Work`(collection://4199b096-dd3e-81ff-8f09-000b636e368e), `Study`(collection://4199b096-dd3e-814f-874e-000b8b3cada6). 속성: Name, Date, Status, Category, Memo(Work에는 Assignee, Priority 추가). 선택 옵션 색상은 에이전트가 정함.
- **검증:** 각 DB를 `notion-fetch`로 조회 → 속성 이름, 유형, 옵션이 승인된 미리보기와 일치하고, 3개 모두 상위 페이지에 인라인으로 들어 있음.
- **문서:** `docs/notion-schema.md`와 `translate/_docs/_notion-schema.md`를 만듦.
- **결과:** 성공(사용자 승인 완료).

- **작업:** `notion-writer` 서브에이전트로 DB 3개의 스키마를 수정함(먼저 모든 DB가 비어 있는지 확인). Personal Tasks: Person, Priority, Location 추가, Status, Category, Memo 삭제. Work: Date→Due, Assignee→Collaborators 이름 변경, Registered(생성 일시), Email(이메일) 추가, Status, Category, Memo 삭제. Study: Name→Topic, Date→Due, Memo→Summary 이름 변경, Status, Category 삭제.
- **검증:** `notion-fetch`로 다시 조회 → 최종 속성이 승인된 미리보기와 일치.
- **문서:** `docs/notion-schema.md`와 `translate/_docs/_notion-schema.md` 수정(속성 표, 필터 대응표, `Status = Scheduled` 기본값 삭제).
- **결과:** 성공(사용자 승인 완료).

- **작업:** `notion-writer` 서브에이전트로 승인된 메모 4건 등록(4건 성공, 0건 실패):
  - Personal Tasks: 남양주 방문 (Date 2026-11-21 (토), Location 남양주)
  - Work: 정규 수업 개강 (Due 2026-11-17 (화))
  - Work: 수정된 커리큘럼 표 전달 (Email 기록, Due 없음)
  - Study: 에이전트 업데이트 사항 업데이트 (Due 2026-11-18 (수)), 접두어 `학습:`(사용자 확인)
- **검증:** 등록 후 각 페이지를 다시 조회 → 값 일치, 한글 정상. 기본값과 후속 작업은 적용하지 않음.
- **문서:** `CLAUDE.md` 3.1절과 `.claude/rules/nt-study.md`에 Study DB 메모 접두어 `학습:`을 추가하고, 번역본 `translate/_CLAUDE.md`, `translate/_claude/_rules/_nt-study.md`도 수정.
- **결과:** 성공(사용자 승인 완료).

- **작업:** `Downloads/가상_커리큘럼_조율_회의록.docx`(가상 커리큘럼 조율 회의록)를 분석해 모든 실행 항목을 Work(강의 업무)로 분류. `notion-writer` 서브에이전트로 승인된 8건을 Work DB에 등록(중복 확인 통과, 8건 성공, 0건 실패). Email은 문서의 공통 수신처, Priority는 비움.
  1. 커리큘럼 조율 회의 (온라인) — 마감 2026-11-16 (월) 14:00–15:00 KST
  2. 회의 결정사항·담당 일정표 메일 공유 — 마감 2026-11-17 (화)
  3. 교육목표·주차별 강의안 초안 v1 제출 (DOCX) — 마감 2026-11-20 (금)
  4. 실습 과제 목록·평가 루브릭 제출 (XLSX) — 마감 2026-11-24 (화)
  5. 강의자료 템플릿·대표 시안 제출 (PPTX/PNG) — 마감 2026-11-27 (금)
  6. 통합 운영안·수강생 공지문 제출 (DOCX/PDF) — 마감 2026-12-02 (수)
  7. 마감 산출물 취합·누락/형식 오류 사전 점검 — 마감 2026-12-03 (목)
  8. 교차검수표·최종 승인본 제출 및 최종안 승인 (XLSX/PDF) — 마감 2026-12-04 (금)
- **검증:** 등록 후 다시 조회 → 값 일치, 한글 정상. 기본값과 후속 작업 없음.
- **결과:** 성공(사용자 승인 완료).

- **작업:** 지금까지의 작업 전체를 GitHub `gagyeong2505/notion_auto`(`main`)에 업로드. `.gitignore`에 `.playwright-mcp/` 추가, 신규 파일 민감 정보 점검(이상 없음). 커밋 `5fc9b26`, 푸시 `94aaf1b..5fc9b26`.
- **결과:** 성공(사용자 승인 완료).

## 2026-11-21 (토)

- **작업:** GWS CLI 설치 및 인증.
  - `npm install -g @googleworkspace/cli` → `gws 0.22.5`.
  - `winget`을 실행할 수 없어서 Google Cloud CLI 594.0.0을 공식 zip으로 `%LOCALAPPDATA%\Google\google-cloud-sdk`에 설치하고, `bin` 폴더를 사용자 PATH에 추가함.
  - `gcloud auth login --no-launch-browser`: 로그인은 사용자가 Playwright 창에서 직접 하고, 계속/허용 버튼은 Playwright가 누름.
  - `gws auth setup --project gws-workspace-8694`(기존 프로젝트)는 OAuth 클라이언트 생성 단계에서 멈춤(Console에서만 만들 수 있음). `gcloud services enable`로 Gmail, Drive, Docs, Sheets, Calendar API를 켬.
  - Playwright로 Cloud Console에서 데스크톱 OAuth 클라이언트 `gws CLI notion_auto`(`479429529840-4iggh57t...`)를 만들고 `~/.config/gws/client_secret.json`을 작성함. 동의 화면은 이미 External/테스트 상태였고, 계정이 Test user로 등록되어 있었음.
  - `gws auth login -s gmail,drive,docs,sheets,calendar`: 계정 선택, 확인되지 않은 앱 경고 통과, 전체 권한 동의를 Playwright가 처리함.
- **검증:** `gws auth status` → `token_valid: true`, refresh token 있음, 자격 증명 암호화 저장, 사용자 `a01087548364@gmail.com`. 읽기 전용 테스트 통과: Drive 파일 목록, Gmail `getProfile`, Calendar `calendarList`(종료 코드 0).
- **정리:** 클라이언트 보안 비밀이 들어 있던 Playwright 스냅샷 2개를 삭제함(`.playwright-mcp/`는 git 제외 대상).
- **결과:** 성공(사용자 승인 완료).

- **작업:** gmail, drive, docs, sheets, calendar, workflow, auth의 `gws` 명령어와 기능을 정리함(읽기 전용: `--help`만 실행, API 호출 없음). 결과는 대화창에 표로 출력했고 파일은 저장하지 않음.
- **결과:** 성공(사용자 승인 완료).

- **작업:** `gws-skill` 스킬 제작(`.claude/skills/gws-skill/`): `SKILL.md`, `references/`(gmail, drive, docs-sheets, calendar, common), `scripts/`(`_env.sh`; `.env`에서 `GOOGLE_WORKSPACE_*`/`GWS_*` 키만 불러오는 래퍼 `gws.sh`; 자동 설치를 포함한 점검 스크립트 `check.sh`), `.env.example`. 프로젝트 루트 `.env`(git 제외)를 만들어 OAuth 클라이언트 ID/보안 비밀과 프로젝트 ID를 저장함(A 방식: 토큰 내보내기 파일 없음). `gws-execute/SKILL.md`에 `gws-skill`을 가리키는 안내를 추가함.
- **검증:** 레퍼런스의 명령 예시를 모두 `--dry-run`으로 검증함(종료 코드 0). `check.sh` → READY. 스킬만 사용한 새 테스트 에이전트 3개(오늘·내일 일정, 안 읽은 메일 요약, 메일 초안과 일정 미리보기를 dry-run으로)가 모두 종료 코드 0으로 성공했고, 쓰기 작업은 없었음. 테스트 의견을 반영함: Gmail dry-run의 한계, `+triage` 정렬과 출력 형식, `--today`/`--days`의 차이, 빈 결과 보고 방식, 메일 내용 개인정보 처리, 무해한 stderr 출력, 프로젝트 CLAUDE.md 규칙 우선.
- **번역:** `translate/_claude/_skills/_gws-skill/`(SKILL과 레퍼런스 5개), `translate/_claude/_skills/_gws-execute/_SKILL.md`.
- **결과:** 성공(사용자 승인 완료).

- **작업:** Playwright로 Notion 통합 페이지 열기(읽기 전용). `notion.so/profile/integrations`가 로그인 화면으로 넘어가서 사용자가 직접 로그인함. 로그인 후 `app.notion.com/developers/connections`(개발자 도구 → 개발자 연결)로 이동함.
- **확인 결과:** 내부용 연결 5개(API 토큰, 워크스페이스 "가경 김의 Notion", 소유자: 사용자 본인): `notion_auto`(2026-11-15), `agent_09`(2026-11-08), `GG_AI_AG_2607`(2026-08-27), `GG_API`(2026-06-21), `GG_DB`(2026-06-21). 토큰은 열거나 표시하지 않았고, 설정도 변경하지 않음.
- **결과:** 성공(사용자 승인 완료).

- **작업:** Playwright로 `notion_auto` 연결에 공유된 Notion 페이지 열기(읽기 전용). 경로: 개발자 연결 → `notion_auto` → 콘텐츠 사용 권한 탭 → 개인 페이지(1개 페이지): 최상위 페이지 "개인 일정 관리". 목록 항목은 링크가 아니어서 사이드바에서 열었음(`app.notion.com/p/4199b096dd3e80199881ceb1663a18da`).
- **확인 결과:** 페이지에 인라인 DB 3개가 있고 `docs/notion-schema.md`와 일치함: Personal Tasks(Name/Date/Location/Person/Priority, 1건), Work(Name/Collaborators/Due/Email/Priority/Registered, 10건), Study(Topic/Due/Summary, 1건). API 토큰은 표시하지 않았고, 설정과 내용도 변경하지 않음.
- **결과:** 성공(사용자 승인 완료).

- **작업:** Notion 페이지 "개인 일정 관리"의 일정을 `gws calendar events insert`(gws-skill)로 Google Calendar(`primary`)에 등록함. 색상: 개인 = `4` Flamingo(분홍), Work = `11` Tomato(빨강), 학습 = `10` Basil(초록). 참석자는 넣지 않았고(초대 메일 발송 없음), 협업자는 설명란에 적음.
  - 개인(1건): 남양주 방문 — 2026-11-21 (토), 종일, 장소 남양주.
  - Work(9건): 커리큘럼 조율 회의 (온라인) 2026-11-16 (월) 14:00–15:00, 회의 결정사항·담당 일정표 메일 공유와 정규 수업 개강 2026-11-17 (화), 교육목표·주차별 강의안 초안 v1 제출 2026-11-20 (금), 실습 과제 목록·평가 루브릭 제출 2026-11-24 (화), 강의자료 템플릿·대표 시안 제출 2026-11-27 (금), 통합 운영안·수강생 공지문 제출 2026-12-02 (수), 마감 산출물 취합·누락/형식 오류 사전 점검 2026-12-03 (목), 교차검수표·최종 승인본 제출 및 최종안 승인 2026-12-04 (금). 회의를 제외하고 모두 종일 일정.
  - 학습(1건): 에이전트 업데이트 사항 업데이트 — 2026-11-18 (수), 종일.
  - 건너뜀: 수정된 커리큘럼 표 전달(Work, Due 없음).
- **비고:** 첫 시도(Python 스크립트에서 `bash` 호출)는 WSL bash로 연결되어 API 호출 전에 실패했고, 생성된 일정은 없음. Git Bash에서 JSON 파일로 다시 실행해 11건 모두 종료 코드 0.
- **검증:** 등록 전 2026-11-16 ~ 2026-12-05 기존 일정 없음. 등록 후 `events list`로 11건의 색상과 한글 제목이 정상임을 확인함. Playwright로 Google Calendar(2026년 11월 월간 보기)를 열었음.
- **결과:** 성공(사용자 승인 완료).

- **작업:** 지금까지의 작업 전체를 GitHub `gagyeong2505/notion_auto`(`main`)에 업로드: 신규 `gws-skill`(SKILL, references 5개, scripts 3개)과 번역본, `gws-execute` 수정, 작업 로그. 신규 파일 민감 정보 점검(이상 없음), `.env`는 계속 제외됨.
- **결과:** 성공(사용자 승인 완료).
