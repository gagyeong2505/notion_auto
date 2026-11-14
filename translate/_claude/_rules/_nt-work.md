# 규칙: nt-work

## 키워드

- `nt-work`

## 저장 대상

- **Notion DB:** Work DB

## 목적

- **업무 관련 할 일**(프로젝트, 회의, 보고서, 마감, 업무 처리)을 Work DB에 저장합니다.

## 처리 방법

1. 입력이 `nt-work: 내용` 형식이면 내용을 업무 관련 할 일로 봅니다.
2. `notion-db-register` 스킬 흐름을 따릅니다.
   - 내용을 Work DB의 속성에 맞게 나눕니다(`docs/notion-schema.md`).
   - `templates/register-preview.md` 형식으로 미리보기를 보여주고 사용자 승인을 받습니다.
   - 승인되면 `notion-writer` 서브에이전트로 등록합니다.
3. 결과를 `logs/actions.md`에 기록합니다.

## 우선순위

- 이 규칙은 Notion 트리거 DB보다 우선합니다. 트리거 DB가 `nt-work`를 다른 DB에 연결하고 있으면 이 규칙을 따릅니다.
- 트리거 DB의 기본값과 후속 작업은 `nt-work`가 트리거 DB에 있을 때만 사용합니다.

## 불일치 확인

- 내용이 업무가 아니라 개인 또는 학습 관련으로 보이면 등록하지 않습니다. 사용자에게 키워드를 확인합니다(`nt-personal`이나 `nt-study`가 더 맞을 수 있습니다).
