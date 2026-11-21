# Gmail

`G=.claude/skills/gws-skill/scripts/gws.sh`. 권한 범위: `gmail.modify`(읽기, 작성, 발송, 라벨 지정 가능. 영구 삭제는 불가).

## 헬퍼

| 명령 | 용도 | 주요 옵션 |
|---|---|---|
| `+triage` | 안 읽은 메일 요약(읽기 전용, 표 출력) | `--max N`(기본 20), `--query '<Gmail 검색어>'`(기본 `is:unread`), `--labels` |
| `+read` | 메일 1건 본문 읽기 | `--id <ID>`, `--headers`, `--html` |
| `+send` | 새 메일 발송 또는 초안 저장 | `--to --subject --body`(필수), `--cc --bcc`, `-a <파일>`(여러 번 가능, 합계 25MB), `--html`, `--from <별칭>`, **`--draft`** |
| `+reply` / `+reply-all` | 스레드 안에서 답장(In-Reply-To, References, threadId 자동 설정, 원문 인용) | `--message-id <ID> --body`, `--to`(받는 사람 추가), `--cc --bcc -a --html --draft` |
| `+forward` | 원본 첨부와 함께 전달 | `--message-id --to`, `--body`(메모), `--no-original-attachments`, `-a --html --draft` |
| `+watch` | 새 메일을 NDJSON으로 실시간 수신(Pub/Sub와 cloud-platform 권한 필요, 현재 미인증) | `--project --label-ids --once --cleanup` |

## 자주 쓰는 작업

```bash
# 안 읽은 메일 요약, 또는 검색
bash $G gmail +triage --max 10
bash $G gmail +triage --query 'from:boss@example.com newer_than:7d' --max 5

# 메일 ID 찾기 (q는 Gmail 검색 문법)
bash $G gmail users messages list --params '{"userId":"me","q":"subject:견적 is:unread","maxResults":5}'

# 메일 읽기
bash $G gmail +read --id 18f1a2b3c4d --headers

# 초안 먼저(안전), 발송은 나중에
bash $G gmail +send --to a@example.com --subject '주간 보고' --body '안녕하세요...' --draft
bash $G gmail users drafts list --params '{"userId":"me","maxResults":5}'
bash $G gmail users drafts send --params '{"userId":"me"}' --json '{"id":"<DRAFT_ID>"}'   # 실제 발송 → 승인 필요

# HTML 본문 + 첨부
bash $G gmail +send --to a@example.com --subject '자료' --body '<p>첨부 확인 부탁드립니다.</p>' --html -a ./report.pdf --draft

# 답장 / 전달을 초안으로
bash $G gmail +reply --message-id 18f1a2b3c4d --body '확인했습니다.' --draft
bash $G gmail +forward --message-id 18f1a2b3c4d --to b@example.com --body '참고 바랍니다' --draft

# 계정 정보
bash $G gmail users getProfile --params '{"userId":"me"}'
```

## 원본 API (`gws gmail users ...`)

| 리소스 | 메서드 |
|---|---|
| `users` | `getProfile`, `watch`, `stop` |
| `users messages` | `list get send modify batchModify trash untrash import insert`(`delete`/`batchDelete`는 더 넓은 권한 필요) |
| `users messages attachments` | `get` |
| `users drafts` | `create list get update send delete` |
| `users labels` | `create list get patch update delete` |
| `users threads` | `list get modify trash untrash` |
| `users history`, `users settings` | 변경 이력; 필터, 전달, 보낸 사람 별칭, 부재중 설정 |

라벨 조회와 읽음 처리:

```bash
bash $G gmail users labels list --params '{"userId":"me"}' --format table
bash $G gmail users messages modify --params '{"userId":"me","id":"<MSG_ID>"}' --json '{"removeLabelIds":["UNREAD"]}'
```

## 참고

- `+triage`와 `+read`는 메일함을 변경하지 않습니다.
- `+triage`는 기본으로 표를 출력하고, `id` 열이 메일 ID입니다. 결과를 파싱해야 하면 `--format json`을 붙입니다.
- `+triage` 결과는 **날짜순이라는 보장이 없고**, `date` 헤더의 시간대도 제각각입니다. "가장 최근" 메일을 찾을 때는 날짜를 KST로 바꿔 비교합니다. `users messages list`는 최신 메일부터 반환하므로 그것을 써도 됩니다.
- `+read`가 stderr에 `warning: unknown output format 'text'; falling back to json`을 출력할 수 있습니다. 무해하며 본문은 정상으로 출력됩니다.
- 여러 줄 본문: bash ANSI-C 따옴표 `--body $'안녕하세요.\n\n본문입니다.\n\n감사합니다.'`를 쓰거나, 작은따옴표 안에서 실제로 줄을 바꿉니다.
- `+send`/`+reply`/`+forward`에 `--dry-run`을 쓰면 `"message":{}`만 보여서 받는 사람이나 본문을 확인할 수 없습니다. 미리보기에 직접 적어 보여줍니다.
- 초안 승인은 발송 승인이 아닙니다. `drafts send`나 `--draft` 없는 `+send` 전에 다시 승인을 받습니다.
