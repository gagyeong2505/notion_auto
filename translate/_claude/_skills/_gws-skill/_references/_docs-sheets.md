# Google Docs와 Sheets

`G=.claude/skills/gws-skill/scripts/gws.sh`. 권한 범위: `documents`, `spreadsheets`. 파일 ID는 URL에 있습니다: `docs.google.com/document/d/<ID>/`, `docs.google.com/spreadsheets/d/<ID>/`.

## Docs

| 명령 | 용도 |
|---|---|
| `+write --document <ID> --text '<내용>'` | 문서 끝에 일반 텍스트 추가 |
| `documents create --json '{"title":"..."}'` | 빈 문서 생성(`documentId` 반환) |
| `documents get --params '{"documentId":"<ID>"}'` | 구조와 내용 읽기(JSON) |
| `documents batchUpdate` | 텍스트·표 삽입, 삭제, 바꾸기, 서식 지정 |

```bash
# 문서 생성 후 내용 채우기
bash $G docs documents create --json '{"title":"회의록 2026-11-24"}'
bash $G docs +write --document <DOC_ID> --text $'1. 안건\n2. 결정 사항\n'

# 일반 텍스트로 읽기: Drive로 내보내기(documents get을 해석하는 것보다 쉬움)
bash $G drive files export --params '{"fileId":"<DOC_ID>","mimeType":"text/plain"}' --output ./doc.txt

# 자리표시자 바꾸기(템플릿 채우기)
bash $G docs documents batchUpdate --params '{"documentId":"<DOC_ID>"}' --json '{"requests":[{"replaceAllText":{"containsText":{"text":"{{이름}}","matchCase":true},"replaceText":"홍길동"}}]}'

# 문서 맨 앞(index 1)에 텍스트 삽입
bash $G docs documents batchUpdate --params '{"documentId":"<DOC_ID>"}' --json '{"requests":[{"insertText":{"location":{"index":1},"text":"제목\n"}}]}'
```

템플릿 문서를 복사하려면 `drive files copy`로 복사한 뒤 `replaceAllText`를 씁니다.

## Sheets

| 명령 | 용도 |
|---|---|
| `+read --spreadsheet <ID> --range 'Sheet1!A1:D10'` | 값 읽기(읽기 전용) |
| `+append --spreadsheet <ID> --values 'a,b,c'` | 행 1개 추가 |
| `+append --spreadsheet <ID> --json-values '[["a","b"],["c","d"]]'` | 여러 행 추가 |
| `spreadsheets create` | 스프레드시트 생성 |
| `spreadsheets get` | 시트 이름과 속성 |
| `spreadsheets values get/update/append/clear/batchGet/batchUpdate` | 셀 값 |
| `spreadsheets batchUpdate` | 구조 변경: 시트 추가, 서식, 셀 병합 등 |

```bash
# 생성
bash $G sheets spreadsheets create --json '{"properties":{"title":"업무 트래커"},"sheets":[{"properties":{"title":"Tasks"}}]}'

# 시트 이름
bash $G sheets spreadsheets get --params '{"spreadsheetId":"<ID>","fields":"sheets.properties.title"}'

# 읽기
bash $G sheets +read --spreadsheet <ID> --range 'Tasks!A1:E20'

# 행 추가
bash $G sheets +append --spreadsheet <ID> --json-values '[["2026-11-24","강의안 제출","진행중"]]'

# 범위 덮어쓰기 (USER_ENTERED는 화면에서 입력할 때처럼 수식과 날짜를 해석)
bash $G sheets spreadsheets values update --params '{"spreadsheetId":"<ID>","range":"Tasks!A1:C1","valueInputOption":"USER_ENTERED"}' --json '{"values":[["날짜","작업","상태"]]}'

# 범위 지우기 (파괴적 작업 → 승인)
bash $G sheets spreadsheets values clear --params '{"spreadsheetId":"<ID>","range":"Tasks!A2:C100"}'

# 시트 탭 추가
bash $G sheets spreadsheets batchUpdate --params '{"spreadsheetId":"<ID>"}' --json '{"requests":[{"addSheet":{"properties":{"title":"Archive"}}}]}'
```

## 참고

- `+append`는 첫 번째 시트에서 찾은 표의 마지막 행 다음에 씁니다.
- 값을 입력한 그대로 저장해야 할 때(예: 수식이 아닌 `=`로 시작하는 값)는 `valueInputOption: "RAW"`를 씁니다.
