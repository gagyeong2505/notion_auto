# Google Calendar

`G=.claude/skills/gws-skill/scripts/gws.sh`. 권한 범위: `calendar`. 기본 시간대: Asia/Seoul(`+09:00`).

## 헬퍼

| 명령 | 용도 | 주요 옵션 |
|---|---|---|
| `+agenda` | 모든 캘린더의 다가오는 일정(읽기 전용) | `--today`, `--tomorrow`, `--week`, `--days N`, `--calendar '<이름 또는 ID>'`, `--timezone <IANA>` |
| `+insert` | 일정 생성 | `--summary --start --end`(RFC 3339, 필수), `--calendar`(기본 `primary`), `--location`, `--description`, `--attendee <이메일>`(여러 번 가능, **초대 메일 발송**), `--meet`(Google Meet 링크 추가) |

## 자주 쓰는 작업

```bash
# 일정 조회
bash $G calendar +agenda --today
bash $G calendar +agenda --week
bash $G calendar +agenda --days 3 --calendar '수업(주)'

# 캘린더 목록과 ID
bash $G calendar calendarList list --params '{"fields":"items(id,summary,primary)"}' --format table

# 생성 — 쓰기 단계: 먼저 미리보기 + 승인 (--attendee를 쓰면 외부 노출 작업)
bash $G calendar +insert --summary '커리큘럼 회의' --start '2026-11-24T14:00:00+09:00' --end '2026-11-24T15:00:00+09:00' --location '온라인' --meet

# 종일 일정이나 알림 설정 → 원본 insert 사용
bash $G calendar events insert --params '{"calendarId":"primary"}' --json '{"summary":"강의안 제출 마감","start":{"date":"2026-11-20"},"end":{"date":"2026-11-21"}}'
bash $G calendar events insert --params '{"calendarId":"primary"}' --json '{"summary":"회의","start":{"dateTime":"2026-11-24T14:00:00+09:00"},"end":{"dateTime":"2026-11-24T15:00:00+09:00"},"reminders":{"useDefault":false,"overrides":[{"method":"popup","minutes":30}]}}'

# 기간 내 일정 검색 (singleEvents는 반복 일정을 개별 일정으로 펼침)
bash $G calendar events list --params '{"calendarId":"primary","timeMin":"2026-11-24T00:00:00+09:00","timeMax":"2026-12-01T00:00:00+09:00","singleEvents":true,"orderBy":"startTime","q":"회의"}'

# 자연어로 빠르게 추가
bash $G calendar events quickAdd --params '{"calendarId":"primary","text":"Lunch with Kim tomorrow 12pm"}'

# 일정 일부 수정 / 삭제 (승인)
bash $G calendar events patch --params '{"calendarId":"primary","eventId":"<ID>"}' --json '{"location":"본사 3층"}'
bash $G calendar events delete --params '{"calendarId":"primary","eventId":"<ID>","sendUpdates":"all"}'

# 빈 시간 조회
bash $G calendar freebusy query --json '{"timeMin":"2026-11-24T09:00:00+09:00","timeMax":"2026-11-24T18:00:00+09:00","items":[{"id":"primary"}]}'
```

## 원본 API 리소스

| 리소스 | 메서드 |
|---|---|
| `events` | `list get insert patch update delete move quickAdd instances import watch` |
| `calendarList` | 사용자의 캘린더 목록: `list get insert patch update delete` |
| `calendars` | 보조 캘린더 생성·삭제 |
| `freebusy` | `query` |
| `acl` | 캘린더 공유 |
| `settings`, `colors` | 사용자 설정, 색상 ID |

## 참고

- **날짜 단위 요청**("오늘", "내일", "오늘이랑 내일")에는 `--today` / `--tomorrow`를 씁니다(KST 자정부터 자정까지). `--days N`과 `--week`는 **지금 시각**부터 조회하므로 오늘 이미 끝난 일정이 빠집니다. "오늘과 내일"은 `--today`와 `--tomorrow`를 각각 실행하거나, `timeMin`/`timeMax`를 지정해 원본 `events list`를 씁니다.
- `+agenda`는 **모든** 캘린더를 조회합니다. 원본 `events list`는 `calendarId` 하나만 조회합니다.
- 원본 `events list`에 `--format table`을 쓰면, 일정이 없을 때 `defaultReminders` 표가 나와 일정처럼 보입니다. "내 일정"을 볼 때는 `+agenda`를 쓰거나 `"fields":"items(summary,start,end,htmlLink)"`를 지정합니다.
- `--format table`은 전역 옵션이라 헬퍼에도 쓸 수 있습니다.
- 종일 일정의 `end.date`는 그 날짜를 **포함하지 않습니다**(다음 날로 지정).
- `--attendee`와 `sendUpdates:"all"`은 다른 사람에게 메일을 보내므로 외부 노출 작업으로 다룹니다.
- `+insert`와 `events insert`는 `htmlLink`를 반환합니다. 보고에 포함합니다.
