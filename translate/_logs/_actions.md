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
