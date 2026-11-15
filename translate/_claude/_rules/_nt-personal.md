# 규칙: nt-personal

## 키워드

- `nt-personal`

## 저장 대상

- **Notion DB:** Personal Tasks DB

## 목적

- **개인 할 일**(개인 용무, 약속, 집안일, 개인 알림)을 Personal Tasks DB에 저장합니다.

## 처리 방법

1. 입력이 `nt-personal: 내용` 형식이면 내용을 개인 할 일로 봅니다.
2. `notion-db-register` 스킬 흐름을 따릅니다.
   - 내용을 Personal Tasks DB의 속성에 맞게 나눕니다(`docs/notion-schema.md`). 이 파일이 없으면 `notion-fetch`로 대상 DB를 조회해 실제 속성 이름을 사용합니다.
   - `templates/register-preview.md` 형식으로 미리보기를 보여주고 사용자 승인을 받습니다(템플릿이 없으면 대상 DB, 각 속성 값, 적용한 기본값, 예정된 후속 작업을 나열합니다).
   - 승인되면 `notion-writer` 서브에이전트로 등록합니다.
3. 결과를 `logs/actions.md`에 기록합니다.

## 우선순위

- 이 규칙은 Notion 트리거 DB보다 우선합니다. 트리거 DB가 `nt-personal`을 다른 DB에 연결하고 있으면 이 규칙을 따릅니다.
- 트리거 DB의 기본값과 후속 작업은 `nt-personal`이 트리거 DB에 있을 때만 사용합니다.

## 불일치 확인

- 내용이 개인 할 일이 아니라 업무나 학습 관련으로 보이면 등록하지 않습니다. 사용자에게 키워드를 확인합니다(`nt-work`나 `nt-study`가 더 맞을 수 있습니다).
