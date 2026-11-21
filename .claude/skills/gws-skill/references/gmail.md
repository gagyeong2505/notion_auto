# Gmail

`G=.claude/skills/gws-skill/scripts/gws.sh`. Scope: `gmail.modify` (read, compose, send, and label; permanent delete is not allowed).

## Helpers

| Command | Purpose | Key flags |
|---|---|---|
| `+triage` | Unread inbox summary (read-only, table output) | `--max N` (default 20), `--query '<gmail search>'` (default `is:unread`), `--labels` |
| `+read` | Read one message body | `--id <ID>`, `--headers`, `--html` |
| `+send` | Send or draft a new email | `--to --subject --body` (required), `--cc --bcc`, `-a <file>` (repeatable, 25 MB total), `--html`, `--from <alias>`, **`--draft`** |
| `+reply` / `+reply-all` | Reply in the thread (sets In-Reply-To, References, threadId; quotes the original) | `--message-id <ID> --body`, `--to` (adds recipients), `--cc --bcc -a --html --draft` |
| `+forward` | Forward with the original attachments | `--message-id --to`, `--body` (note), `--no-original-attachments`, `-a --html --draft` |
| `+watch` | Stream new mail as NDJSON (needs Pub/Sub and the cloud-platform scope; not authorized now) | `--project --label-ids --once --cleanup` |

## Common tasks

```bash
# Unread summary, or search
bash $G gmail +triage --max 10
bash $G gmail +triage --query 'from:boss@example.com newer_than:7d' --max 5

# Find message IDs (q uses Gmail search syntax)
bash $G gmail users messages list --params '{"userId":"me","q":"subject:견적 is:unread","maxResults":5}'

# Read a message
bash $G gmail +read --id 18f1a2b3c4d --headers

# Draft first (safe), send later
bash $G gmail +send --to a@example.com --subject '주간 보고' --body '안녕하세요...' --draft
bash $G gmail users drafts list --params '{"userId":"me","maxResults":5}'
bash $G gmail users drafts send --params '{"userId":"me"}' --json '{"id":"<DRAFT_ID>"}'   # sends → needs approval

# HTML body with an attachment
bash $G gmail +send --to a@example.com --subject '자료' --body '<p>첨부 확인 부탁드립니다.</p>' --html -a ./report.pdf --draft

# Reply / forward as a draft
bash $G gmail +reply --message-id 18f1a2b3c4d --body '확인했습니다.' --draft
bash $G gmail +forward --message-id 18f1a2b3c4d --to b@example.com --body '참고 바랍니다' --draft

# Account info
bash $G gmail users getProfile --params '{"userId":"me"}'
```

## Raw API (`gws gmail users ...`)

| Resource | Methods |
|---|---|
| `users` | `getProfile`, `watch`, `stop` |
| `users messages` | `list get send modify batchModify trash untrash import insert` (`delete`/`batchDelete` need a wider scope) |
| `users messages attachments` | `get` |
| `users drafts` | `create list get update send delete` |
| `users labels` | `create list get patch update delete` |
| `users threads` | `list get modify trash untrash` |
| `users history`, `users settings` | change history; filters, forwarding, send-as, vacation |

Labels and marking as read:

```bash
bash $G gmail users labels list --params '{"userId":"me"}' --format table
bash $G gmail users messages modify --params '{"userId":"me","id":"<MSG_ID>"}' --json '{"removeLabelIds":["UNREAD"]}'
```

## Notes

- `+triage` and `+read` never modify the mailbox.
- `+triage` prints a table by default, and its `id` column is the message ID. Add `--format json` when you need to parse it.
- `+triage` rows are **not guaranteed to be in date order**, and the `date` header mixes time zones. To find "the latest" message, convert the dates to KST before comparing. `users messages list` returns the newest first, so you can also use it.
- `+read` may print `warning: unknown output format 'text'; falling back to json` to stderr. It is harmless, and the body is still printed.
- Multi-line body: use bash ANSI-C quoting, `--body $'안녕하세요.\n\n본문입니다.\n\n감사합니다.'`, or real line breaks inside single quotes.
- `--dry-run` on `+send`/`+reply`/`+forward` shows only `"message":{}`, so it cannot check the recipients or body. Show them in the preview yourself.
- Approving a draft is not approval to send it. Ask again before `drafts send` or `+send` without `--draft`.
