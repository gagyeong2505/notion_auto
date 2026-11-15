# Notion 스키마

`notion_auto`에서 사용하는 Notion 데이터베이스 참조 문서. 아래 속성 이름을 정확히 그대로 사용한다. 이 파일과 Notion의 내용이 다르면 `notion-fetch`로 다시 확인하고 이 파일을 수정한다.

## 상위 페이지

- **제목:** 개인 일정 관리
- **페이지 ID:** `4199b096-dd3e-8019-9881-ceb1663a18da`
- 아래 데이터베이스는 모두 이 페이지 안의 인라인 데이터베이스다.

## 데이터베이스 목록

| DB | 규칙 파일 | 데이터베이스 ID | 데이터 소스 |
|---|---|---|---|
| Personal Tasks (개인 할 일) | `.claude/rules/nt-personal.md` | `4199b096-dd3e-818a-8138-ff08a61d2e73` | `collection://4199b096-dd3e-8194-ad94-000b4567cbd6` |
| Work (업무) | `.claude/rules/nt-work.md` | `4199b096-dd3e-8142-869a-e303d56a736c` | `collection://4199b096-dd3e-81ff-8f09-000b636e368e` |
| Study (배움) | `.claude/rules/nt-study.md` | `4199b096-dd3e-81ab-8298-f398ac972402` | `collection://4199b096-dd3e-814f-874e-000b8b3cada6` |

## 속성

### Personal Tasks (개인 할 일)

| 속성 | 유형 | 옵션 / 참고 |
|---|---|---|
| `Name` | 제목 | 일정 이름 |
| `Date` | 날짜 | 일정 날짜 |
| `Person` | 텍스트 | 관련된 사람(일반 텍스트) |
| `Priority` | 선택 | `High`, `Medium`, `Low` |
| `Location` | 텍스트 | 위치 |

### Work (업무)

| 속성 | 유형 | 옵션 / 참고 |
|---|---|---|
| `Name` | 제목 | 업무 이름(`강의:` 메모는 강의 업무) |
| `Registered` | 생성 일시 | 항목을 만들 때 자동 입력, 수정 불가 |
| `Due` | 날짜 | 마감일 |
| `Collaborators` | 텍스트 | API 연결에 사용자 정보 권한이 없어 일반 텍스트로 입력 |
| `Email` | 이메일 | 주소 1개, GWS 후속 메일의 받는 사람 |
| `Priority` | 선택 | `High`, `Medium`, `Low` |

### Study (배움)

| 속성 | 유형 | 옵션 / 참고 |
|---|---|---|
| `Topic` | 제목 | 학습 주제 |
| `Due` | 날짜 | 마감일 |
| `Summary` | 텍스트 | 요약 |

- 어느 DB에도 `Status` 속성이 없으므로 완료 여부는 추적하지 않는다.

## 필터 대응표 (notion-db-analyze용)

| 표현 | 필터 |
|---|---|
| 오늘 마감 | Personal Tasks: `Date` = 오늘, Work / Study: `Due` = 오늘 |
| 이번 주 | 같은 날짜 속성이 이번 주 범위 안 |
| 날짜 지남 | 날짜 속성 < 오늘(`Status`가 없어 완료 여부는 확인 불가) |
| 중요도 높음 | `Priority` = `High` (Personal Tasks / Work) |
| 공동작업자 = X (Work만 해당) | `Collaborators`에 X 포함 |

## 트리거 DB

- 아직 만들지 않음. 규칙 파일이 우선한다. 트리거 DB가 생기기 전까지는 기본값을 적용하지 않고 후속 작업도 실행하지 않는다.
