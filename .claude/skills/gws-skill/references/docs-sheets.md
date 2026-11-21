# Google Docs and Sheets

`G=.claude/skills/gws-skill/scripts/gws.sh`. Scopes: `documents`, `spreadsheets`. File IDs are in the URL: `docs.google.com/document/d/<ID>/` and `docs.google.com/spreadsheets/d/<ID>/`.

## Docs

| Command | Purpose |
|---|---|
| `+write --document <ID> --text '<text>'` | Append plain text to the end of the document |
| `documents create --json '{"title":"..."}'` | Create an empty document (returns `documentId`) |
| `documents get --params '{"documentId":"<ID>"}'` | Read the structure and content (JSON) |
| `documents batchUpdate` | Insert, delete, replace, and format text and tables |

```bash
# Create, then fill
bash $G docs documents create --json '{"title":"회의록 2026-11-24"}'
bash $G docs +write --document <DOC_ID> --text $'1. 안건\n2. 결정 사항\n'

# Read as plain text: export through Drive (easier than parsing documents get)
bash $G drive files export --params '{"fileId":"<DOC_ID>","mimeType":"text/plain"}' --output ./doc.txt

# Replace placeholders (template filling)
bash $G docs documents batchUpdate --params '{"documentId":"<DOC_ID>"}' --json '{"requests":[{"replaceAllText":{"containsText":{"text":"{{이름}}","matchCase":true},"replaceText":"홍길동"}}]}'

# Insert text at the start (index 1)
bash $G docs documents batchUpdate --params '{"documentId":"<DOC_ID>"}' --json '{"requests":[{"insertText":{"location":{"index":1},"text":"제목\n"}}]}'
```

To copy a template document, use `drive files copy`, then `replaceAllText`.

## Sheets

| Command | Purpose |
|---|---|
| `+read --spreadsheet <ID> --range 'Sheet1!A1:D10'` | Read values (read-only) |
| `+append --spreadsheet <ID> --values 'a,b,c'` | Append one row |
| `+append --spreadsheet <ID> --json-values '[["a","b"],["c","d"]]'` | Append several rows |
| `spreadsheets create` | Create a spreadsheet |
| `spreadsheets get` | Sheet names and properties |
| `spreadsheets values get/update/append/clear/batchGet/batchUpdate` | Cell values |
| `spreadsheets batchUpdate` | Structure: add sheets, formatting, merges, and so on |

```bash
# Create
bash $G sheets spreadsheets create --json '{"properties":{"title":"업무 트래커"},"sheets":[{"properties":{"title":"Tasks"}}]}'

# Sheet names
bash $G sheets spreadsheets get --params '{"spreadsheetId":"<ID>","fields":"sheets.properties.title"}'

# Read
bash $G sheets +read --spreadsheet <ID> --range 'Tasks!A1:E20'

# Append rows
bash $G sheets +append --spreadsheet <ID> --json-values '[["2026-11-24","강의안 제출","진행중"]]'

# Overwrite a range (USER_ENTERED parses formulas and dates like typing in the UI)
bash $G sheets spreadsheets values update --params '{"spreadsheetId":"<ID>","range":"Tasks!A1:C1","valueInputOption":"USER_ENTERED"}' --json '{"values":[["날짜","작업","상태"]]}'

# Clear a range (destructive → approval)
bash $G sheets spreadsheets values clear --params '{"spreadsheetId":"<ID>","range":"Tasks!A2:C100"}'

# Add a sheet tab
bash $G sheets spreadsheets batchUpdate --params '{"spreadsheetId":"<ID>"}' --json '{"requests":[{"addSheet":{"properties":{"title":"Archive"}}}]}'
```

## Notes

- `+append` writes after the last row of the table that it detects, starting from the first sheet.
- Use `valueInputOption: "RAW"` when values must be stored literally (for example a leading `=` that is not a formula).
