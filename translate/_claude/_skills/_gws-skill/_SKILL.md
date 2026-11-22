---
name: gws-skill
description: "Google Workspace CLI(gws)로 사용자의 Gmail, Google Drive, Docs, Sheets, Calendar를 조회하고 작업합니다. 인증 정보는 .env에서 자동으로 불러옵니다. 사용자가 메일 확인·검색·발송·초안·답장·전달, Drive 파일 목록·업로드·다운로드·내보내기·공유·정리, Google 문서·시트 생성·편집, 캘린더 일정 조회·추가·변경·삭제를 원할 때 반드시 이 스킬을 사용합니다. 'gws'라는 말이 없어도 마찬가지입니다(예: '오늘 일정 보여줘', '안 읽은 메일 요약', '이 파일 드라이브에 올려줘', '회의 일정 잡아줘'). gws 설치, 로그인, 인증 오류, 사용 가능한 gws 명령에 관한 질문에도 사용합니다."
---

# gws-skill

Google Workspace 작업을 `gws` CLI로 실행합니다. 포함된 스크립트가 `.env`에서 OAuth 클라이언트 정보를 불러오므로 환경 변수를 따로 설정할 필요가 없습니다.

## 1. 첫 명령 전에: 준비 상태 점검

```bash
bash .claude/skills/gws-skill/scripts/check.sh
```

| 종료 코드 | 의미 | 조치 |
|---|---|---|
| 0 `READY` | 설치됨, `.env` 로드됨, 로그인됨 | 계속 진행 |
| 1 | gws/npm 없음(npm이 있으면 gws는 자동 설치) | 사용자에게 Node.js 18 이상 설치 요청 |
| 2 | `.env`가 없거나 클라이언트 값이 비어 있음 | `.env.example`을 프로젝트 루트에 `.env`로 복사하고, Cloud Console의 값을 사용자에게 요청 |
| 3 | 로그인 안 됨 / 토큰 만료 | 안내된 로그인 명령 실행. 브라우저가 열리면 **사용자**가 직접 로그인 |

점검은 세션마다 한 번 실행하고, 어떤 명령이든 종료 코드 `2`(인증 오류)가 나오면 다시 실행합니다.

## 2. 명령 실행

`.env`가 적용되도록 항상 래퍼 스크립트로 gws를 실행합니다.

```bash
G=.claude/skills/gws-skill/scripts/gws.sh
bash $G calendar +agenda --today
bash $G gmail +triage --max 5
```

- **Git Bash**(Bash 도구)를 사용합니다. PowerShell에서는 `--params` / `--json`의 JSON 따옴표가 깨집니다.
- 경로는 프로젝트 루트 기준입니다. 셸이 다른 위치에서 시작할 수 있으면(예: 서브에이전트) 먼저 프로젝트 루트로 `cd`하거나 절대 경로를 씁니다.
- 모든 호출에서 stderr로 `Using keyring backend: keyring`이 출력됩니다. 정상입니다. JSON을 파서로 넘길 때는 `2>/dev/null`을 붙입니다.
- 래퍼는 `.env`에서 `GOOGLE_WORKSPACE_*` / `GWS_*` 키만 내보냅니다. 같은 파일의 다른 비밀 값은 gws로 넘어가지 않습니다.
- 명령 형식: `gws <서비스> <리소스> [하위 리소스] <메서드> --params '<JSON>' --json '<JSON>'` 또는 `+헬퍼` 단축 명령. 맞는 헬퍼가 있으면 헬퍼를 우선 씁니다. 인코딩, 스레드 연결, 시간 형식을 알아서 처리합니다.
- 파라미터를 모르겠으면 `bash $G schema <서비스.리소스.메서드>`(예: `calendar.events.insert`)를 실행합니다.
- 대화창에 보여줄 때는 `--format table`, 결과에서 ID가 필요할 때는 기본값 `json`을 씁니다.

## 3. 작업별 참조 문서

작업에 맞는 참조 문서만 읽습니다.

| 작업 | 참조 문서 |
|---|---|
| 메일: 요약, 검색, 읽기, 발송, 초안, 답장, 전달, 라벨 | `references/gmail.md` |
| Drive: 목록·검색, 업로드, 다운로드, 내보내기, 폴더, 공유 | `references/drive.md` |
| Docs·Sheets: 생성, 읽기, 추가, 수정 | `references/docs-sheets.md` |
| Calendar: 일정 조회, 일정 생성·수정·삭제, 빈 시간 | `references/calendar.md` |
| 공통 옵션, 인증, 종료 코드, 워크플로, 기타 서비스, 문제 해결 | `references/common.md` |

## 4. 안전: 데이터를 바꾸는 명령은 미리보기 먼저

보낸 메일, 공유한 파일, 캘린더 초대는 다른 사람에게 보이고 되돌리기 어렵습니다. 그래서 명령을 세 단계로 나눠 다룹니다.

| 단계 | 예시 | 처리 |
|---|---|---|
| 읽기 전용 | `+triage`, `+read`, `+agenda`, `files list`, `+read`(시트), `get`, `list`, `schema`, `auth status` | 바로 실행 |
| 쓰기 | `+send --draft`, `+upload`, `files create/copy/update`, `+append`, `+write`, `+insert`, `events patch` | 미리보기(정확한 명령과 받는 사람·파일 이름·시간 요약)를 보여주고 승인을 기다림 |
| 외부 노출·되돌릴 수 없음 | 메일 발송(`--draft` 없는 `+send`, `+reply`, `+forward`, `drafts send`), `permissions create`, `delete`, `trash`, `emptyTrash`, `+insert --attendee`(초대 발송) | 미리보기 후 **명시적** 승인. 메일은 초안을 먼저 만들고, 발송 승인을 따로 받은 뒤에만 발송 |

- `--dry-run`은 API를 호출하지 않고 쓰기 명령을 로컬에서 검증합니다. Calendar, Drive, Docs, Sheets에서는 요청 본문 전체가 출력됩니다. Gmail 헬퍼(`+send`, `+reply`, `+forward`)에서는 엔드포인트만 보이고(`"message":{}`), 받는 사람·제목·본문이 맞는지는 확인되지 않습니다. 이 내용은 항상 미리보기에 직접 적어 보여줍니다.
- 한 요청에 쓰기 작업이 여러 개면(예: 메일 초안 + 일정) 미리보기 하나로 묶어 한 번에 승인받을 수 있습니다. 사용자가 항목별로 승인하거나 수정할 수 있도록 번호를 붙입니다.

**프로젝트 규칙이 이 표보다 우선합니다.** 프로젝트의 `CLAUDE.md`가 더 엄격하면 그쪽을 따릅니다. 이 프로젝트(`notion_auto`)에서는:
- 읽기 전용 요청이라도 할 일 목록이나 계획을 먼저 보여주고 승인을 기다립니다. 쓰기 작업이면 계획에 위의 미리보기 전체를 넣습니다.
- 실행한 결과는 읽기 전용 조회까지 포함해 모두 `logs/actions.md`와 번역본 `translate/_logs/_actions.md`에 기록합니다. 실행하지 않은 dry-run이나 미리보기는 기록하지 않습니다.
- Notion에서 넘어온 후속 작업은 `gws-execute` 스킬과 `gws-executor` 서브에이전트로 처리합니다. `pm`이 할당한 작업은 해당 작성 에이전트(`docs-writer`, `slides-writer`, `sheets-writer`, `mail-writer`)가 처리합니다. 사용자가 직접 요청한 작업은 이 스킬로 바로 처리할 수 있습니다.

## 5. 이 사용자의 기본값

- 시간대: **Asia/Seoul (+09:00)**. 시간은 RFC 3339로 씁니다(`2026-11-24T10:00:00+09:00`).
- 사용자에게 날짜를 알릴 때는 `YYYY-MM-DD (요일)` 형식을 씁니다.
- 인증된 범위: gmail.modify, drive, documents, spreadsheets, calendar. 다른 서비스(tasks, slides, chat 등)는 범위를 넓혀 다시 로그인해야 합니다(`references/common.md` 참고).

## 6. 결과 보고

- 결과는 짧은 표로 요약하고 링크를 넣습니다: 초안함 `https://mail.google.com/mail/u/0/#drafts`, Drive 파일의 `webViewLink`, 캘린더 일정의 `htmlLink`.
- 결과가 비어 있으면 그렇다고 분명히 말하고, 확인한 범위를 밝힙니다(예: "일정 없음 — 캘린더 3개 확인, 2026-11-21 (토) ~ 2026-11-22 (일)"). 그래야 사용자가 오류가 아니라는 것을 알 수 있습니다.
- 메일 내용은 개인정보입니다. 본문을 붙여넣지 말고 보낸 사람, 제목, 한 줄 요지로 요약합니다. `+read`가 출력하는 추적 URL, 수신거부 URL, 토큰은 빼고 보여줍니다.
- 종료 코드가 0이 아니면 오류 `message`를 보여주고, `references/common.md`의 종료 코드 표로 원인을 설명합니다. 쓰기 명령은 자동으로 재시도하지 않습니다. 재시도하면 메일이나 일정이 중복될 수 있기 때문입니다.
