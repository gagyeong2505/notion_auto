# Google Drive

`G=.claude/skills/gws-skill/scripts/gws.sh`. 권한 범위: `drive`(전체 접근).

## 헬퍼

| 명령 | 용도 | 주요 옵션 |
|---|---|---|
| `+upload <파일>` | 로컬 파일 업로드(MIME 유형 자동 감지) | `--parent <폴더ID>`, `--name '<저장할 이름>'` |

## 자주 쓰는 작업

```bash
# 목록 / 검색 (q는 Drive 검색 문법)
bash $G drive files list --params '{"pageSize":10,"fields":"files(id,name,mimeType,modifiedTime,webViewLink)"}' --format table
bash $G drive files list --params '{"q":"name contains '\''커리큘럼'\'' and trashed=false","fields":"files(id,name,webViewLink)"}'
bash $G drive files list --params '{"q":"'\''<FOLDER_ID>'\'' in parents and trashed=false"}'
bash $G drive files list --params '{"q":"mimeType='\''application/vnd.google-apps.folder'\''"}'

# 모든 페이지 가져오기
bash $G drive files list --params '{"pageSize":100}' --page-all --page-limit 5

# 메타데이터
bash $G drive files get --params '{"fileId":"<ID>","fields":"id,name,mimeType,size,webViewLink,parents"}'

# 업로드
bash $G drive +upload ./report.pdf --parent <FOLDER_ID> --name '11월 보고서.pdf'

# 일반 파일 다운로드 / Google 문서 내보내기
bash $G drive files get --params '{"fileId":"<ID>","alt":"media"}' --output ./file.pdf
bash $G drive files export --params '{"fileId":"<DOC_ID>","mimeType":"application/pdf"}' --output ./doc.pdf

# 폴더 생성, 복사, 이름 변경, 이동
bash $G drive files create --json '{"name":"새 폴더","mimeType":"application/vnd.google-apps.folder","parents":["<PARENT_ID>"]}'
bash $G drive files copy --params '{"fileId":"<ID>"}' --json '{"name":"사본"}'
bash $G drive files update --params '{"fileId":"<ID>"}' --json '{"name":"새 이름"}'
bash $G drive files update --params '{"fileId":"<ID>","addParents":"<NEW>","removeParents":"<OLD>"}'

# 휴지통(복구 가능) vs 삭제(영구) — 둘 다 승인 필요
bash $G drive files update --params '{"fileId":"<ID>"}' --json '{"trashed":true}'
bash $G drive files delete --params '{"fileId":"<ID>"}'

# 공유 — 외부 노출 작업, 명시적 승인 필요
bash $G drive permissions list --params '{"fileId":"<ID>"}'
bash $G drive permissions create --params '{"fileId":"<ID>","sendNotificationEmail":false}' --json '{"role":"reader","type":"user","emailAddress":"a@example.com"}'
bash $G drive permissions create --params '{"fileId":"<ID>"}' --json '{"role":"reader","type":"anyone"}'   # 링크가 있는 모든 사용자
```

내보내기 MIME 유형: PDF `application/pdf`, Word `application/vnd.openxmlformats-officedocument.wordprocessingml.document`, Excel `application/vnd.openxmlformats-officedocument.spreadsheetml.sheet`, CSV `text/csv`(첫 시트만), PowerPoint `application/vnd.openxmlformats-officedocument.presentationml.presentation`.

Google 파일 MIME 유형: 문서 `application/vnd.google-apps.document`, 시트 `...spreadsheet`, 슬라이드 `...presentation`, 폴더 `...folder`.

## 원본 API 리소스

| 리소스 | 메서드 |
|---|---|
| `files` | `list get create copy update delete download export emptyTrash generateIds listLabels modifyLabels watch` |
| `permissions` | `create list get update delete` |
| `drives` | 공유 드라이브: `list get create update delete hide unhide` |
| `comments`, `replies` | 파일 댓글과 답글 |
| `revisions` | 버전 기록 |
| `about` | 사용자, 저장 용량(`--params '{"fields":"user,storageQuota"}'`) |
| `changes`, `channels` | 변경 추적, 푸시 알림 |

## 참고

- 작은따옴표로 감싼 bash 문자열 안에서 `'`는 `'\''`로 씁니다(위 `q` 예시 참고).
- `fields`를 지정하면 출력이 짧아집니다. 링크를 보고할 때는 `webViewLink`를 포함합니다.
- `emptyTrash`와 `files delete`는 영구 삭제입니다.
