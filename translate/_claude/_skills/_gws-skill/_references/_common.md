# 공통: 옵션, 인증, 종료 코드, 워크플로, 문제 해결

`G=.claude/skills/gws-skill/scripts/gws.sh` (gws 0.22.5).

## 공통 옵션

| 옵션 | 용도 |
|---|---|
| `--params '<JSON>'` | URL·쿼리 파라미터(ID, 필터, pageSize, fields) |
| `--json '<JSON>'` | POST/PATCH/PUT 요청 본문 |
| `--upload <PATH>` / `--upload-content-type <MIME>` | 미디어 업로드(multipart) |
| `--output <PATH>` | 바이너리 응답 저장(다운로드, 내보내기) |
| `--format json\|table\|yaml\|csv` | 출력 형식(기본 `json`) |
| `--page-all`, `--page-limit N`(기본 10), `--page-delay MS` | 자동 페이지 넘김, 페이지당 NDJSON 한 줄 |
| `--dry-run` | 보내지 않고 로컬에서 검증한 뒤 요청 내용 출력 |
| `--api-version <v>` | API 버전 지정 |
| `--sanitize <template>` | Model Armor로 응답 필터링(cloud-platform 권한 필요) |

`bash $G schema <서비스.리소스.메서드> [--resolve-refs]`로 어떤 메서드든 파라미터와 요청 본문 구조를 볼 수 있습니다.

## 인증 명령

| 명령 | 용도 |
|---|---|
| `auth status` | JSON: `user`, `token_valid`, `scopes`, `project_id`, 자격 증명 경로 |
| `auth login -s gmail,drive,docs,sheets,calendar` | 지정한 서비스로 브라우저 로그인(로그인은 사용자가 직접) |
| `auth login --readonly` / `--full` / `--scopes <목록>` | 읽기 전용 / 전체 / 직접 지정한 권한 범위 |
| `auth logout` | 저장된 자격 증명과 토큰 캐시 삭제 |
| `auth export --unmasked` | 복호화한 자격 증명 출력(**refresh token 포함**). 분명한 이유와 승인 없이 실행하지 않음 |
| `auth setup [--project ID]` | GCP 프로젝트 생성, API 활성화(gcloud 필요. OAuth 클라이언트 생성은 여전히 Cloud Console에서 해야 함) |

자격 증명 사용 순서: `GOOGLE_WORKSPACE_CLI_TOKEN` → `GOOGLE_WORKSPACE_CLI_CREDENTIALS_FILE` → 암호화된 로그인 자격 증명(`~/.config/gws/credentials.enc`) → 평문 `credentials.json`. OAuth 클라이언트 정보는 `.env`(`CLIENT_ID`/`CLIENT_SECRET`)나 `~/.config/gws/client_secret.json`에서 가져옵니다.

서비스를 추가하려면 전체 목록으로 다시 로그인합니다. 예:
`bash $G auth login -s gmail,drive,docs,sheets,calendar,tasks,slides`
검증되지 않은(테스트 중) 앱은 권한 범위를 약 25개까지만 허용하므로 `--full`이나 recommended 프리셋은 쓰지 않습니다.

## 종료 코드

| 코드 | 의미 | 조치 |
|---|---|---|
| 0 | 성공 | — |
| 1 | API 오류(Google이 오류 응답) | `error.message` / `reason` 확인(404 잘못된 ID, 403 권한 부족 또는 API 비활성) |
| 2 | 인증 오류(자격 증명 없음, 만료, 무효) | `scripts/check.sh` 실행 후 다시 로그인 |
| 3 | 검증 오류(잘못된 인자나 JSON) | 명령 수정, `schema`로 확인 |
| 4 | 스키마 조회 오류(API 스키마를 가져오지 못함) | 네트워크 확인 후 재시도 |
| 5 | 내부 오류 | 사용자에게 보고 |

## 워크플로 헬퍼 (`gws workflow …`, 별칭 `wf`)

| 명령 | 용도 | 필요 권한 |
|---|---|---|
| `+weekly-digest` | 이번 주 회의와 안 읽은 메일 수(읽기 전용) | calendar, gmail ✅ |
| `+meeting-prep` | 다음 일정의 참석자와 설명(읽기 전용) | calendar ✅ |
| `+standup-report` | 오늘 회의와 남은 할 일 | tasks 권한 ❌ |
| `+email-to-task` | Gmail 메일을 Google Tasks 할 일로 변환 | tasks 권한 ❌ |
| `+file-announce` | Drive 파일을 Chat 스페이스에 공지 | chat 권한 ❌ |

## 기타 서비스(로그인 권한 추가 필요)

`slides`, `tasks`, `people`(연락처), `chat`, `forms`, `keep`, `meet`, `classroom`, `script`(Apps Script), `events`(Workspace 이벤트), `admin-reports`(Workspace 관리자 전용), `modelarmor`. `bash $G <서비스> --help`로 확인합니다.

## 문제 해결

| 증상 | 해결 |
|---|---|
| `gws: command not found` | `scripts/check.sh` 실행(npm으로 설치) |
| 종료 코드 2 / `invalid_grant` | 토큰이 만료되거나 취소됨. 테스트 중인 앱은 refresh token이 약 7일 뒤 만료될 수 있으므로 다시 로그인 |
| `accessNotConfigured`(403) | 오류의 `enable_url`을 열거나 `gcloud services enable <api>` 실행, 약 10초 뒤 재시도 |
| 로그인 시 "Access blocked" | Cloud Console → Google 인증 플랫폼 → 대상 → 테스트 사용자에 계정 추가 |
| `redirect_uri_mismatch` | OAuth 클라이언트 유형이 **데스크톱 앱**이어야 함 |
| Windows에서 JSON 파싱 오류 | PowerShell 대신 Git Bash에서 실행 |
| `insufficientPermissions` | 해당 서비스가 로그인 권한 범위에 없음. `-s`에 포함해 다시 로그인 |
| 모든 호출에 `Using keyring backend: keyring` 출력 | 정상(stderr). JSON을 파싱할 때는 `2>/dev/null` 사용 |
| `gmail +read`의 `warning: unknown output format 'text'` | 무해함. 출력은 정상 |
