# Google Drive

`G=.claude/skills/gws-skill/scripts/gws.sh`. Scope: `drive` (full access).

## Helper

| Command | Purpose | Key flags |
|---|---|---|
| `+upload <file>` | Upload a local file (MIME type detected automatically) | `--parent <FOLDER_ID>`, `--name '<target name>'` |

## Common tasks

```bash
# List / search (q uses Drive query syntax)
bash $G drive files list --params '{"pageSize":10,"fields":"files(id,name,mimeType,modifiedTime,webViewLink)"}' --format table
bash $G drive files list --params '{"q":"name contains '\''커리큘럼'\'' and trashed=false","fields":"files(id,name,webViewLink)"}'
bash $G drive files list --params '{"q":"'\''<FOLDER_ID>'\'' in parents and trashed=false"}'
bash $G drive files list --params '{"q":"mimeType='\''application/vnd.google-apps.folder'\''"}'

# All pages
bash $G drive files list --params '{"pageSize":100}' --page-all --page-limit 5

# Metadata
bash $G drive files get --params '{"fileId":"<ID>","fields":"id,name,mimeType,size,webViewLink,parents"}'

# Upload
bash $G drive +upload ./report.pdf --parent <FOLDER_ID> --name '11월 보고서.pdf'

# Download a binary file / export a Google Doc
bash $G drive files get --params '{"fileId":"<ID>","alt":"media"}' --output ./file.pdf
bash $G drive files export --params '{"fileId":"<DOC_ID>","mimeType":"application/pdf"}' --output ./doc.pdf

# Create a folder, copy, rename, or move
bash $G drive files create --json '{"name":"새 폴더","mimeType":"application/vnd.google-apps.folder","parents":["<PARENT_ID>"]}'
bash $G drive files copy --params '{"fileId":"<ID>"}' --json '{"name":"사본"}'
bash $G drive files update --params '{"fileId":"<ID>"}' --json '{"name":"새 이름"}'
bash $G drive files update --params '{"fileId":"<ID>","addParents":"<NEW>","removeParents":"<OLD>"}'

# Trash (recoverable) vs delete (permanent) — both need approval
bash $G drive files update --params '{"fileId":"<ID>"}' --json '{"trashed":true}'
bash $G drive files delete --params '{"fileId":"<ID>"}'

# Sharing — outward-facing, needs explicit approval
bash $G drive permissions list --params '{"fileId":"<ID>"}'
bash $G drive permissions create --params '{"fileId":"<ID>","sendNotificationEmail":false}' --json '{"role":"reader","type":"user","emailAddress":"a@example.com"}'
bash $G drive permissions create --params '{"fileId":"<ID>"}' --json '{"role":"reader","type":"anyone"}'   # anyone with the link
```

Export MIME types: PDF `application/pdf`, Word `application/vnd.openxmlformats-officedocument.wordprocessingml.document`, Excel `application/vnd.openxmlformats-officedocument.spreadsheetml.sheet`, CSV `text/csv` (first sheet), PowerPoint `application/vnd.openxmlformats-officedocument.presentationml.presentation`.

Google file MIME types: Doc `application/vnd.google-apps.document`, Sheet `...spreadsheet`, Slides `...presentation`, Folder `...folder`.

## Raw API resources

| Resource | Methods |
|---|---|
| `files` | `list get create copy update delete download export emptyTrash generateIds listLabels modifyLabels watch` |
| `permissions` | `create list get update delete` |
| `drives` | shared drives: `list get create update delete hide unhide` |
| `comments`, `replies` | file comments and replies |
| `revisions` | version history |
| `about` | user, storage quota (`--params '{"fields":"user,storageQuota"}'`) |
| `changes`, `channels` | change tracking and push notifications |

## Notes

- Inside a single-quoted bash string, write a literal `'` as `'\''` (see the `q` examples above).
- Add `fields` to keep the output small, and include `webViewLink` when you will report links.
- `emptyTrash` and `files delete` are permanent.
