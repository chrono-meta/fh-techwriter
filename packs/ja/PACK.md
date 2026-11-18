# ja 팩 — 日本語

- **수준: wrapper-only.** textlint 15.8.0 + `textlint-rule-preset-ja-technical-writing` 12.0.2 + `@textlint-ja/textlint-rule-preset-ai-writing` 1.7.0 을 감싼다. 이 레포가 실측한 일본어 클래스는 없다.
- 실행: `bash packs/ja/run.sh <file>` (레포 루트에서 `npm ci` 가 먼저 돼 있어야 한다 — 로컬 `node_modules` 만 쓴다)
- exit: 0 지적 없음 · 1 지적 있음(후보다) · 2 UNMEASURED(textlint 없음 · textlint 오류 · rc=1 인데 읽을 수 있는 지적 0)

## 무엇을 보나
- 기술 문서 프리셋: 문장 길이(100자) · 경어체/평어체 섞임 · 조사 중복 · 숫자 표기 · 오용 · 느낌표.
- AI 글쓰기 프리셋: 과장 · 단정 표현 · 장황한 조동사.

## 무엇을 보지 않나 (UNMEASURED)
- **번역투 제거.** 한국어 · 영어에서 옮긴 일본어의 어색함을 재는 레인이 없다.
- 저자 교정 실측 · 매체 보정.
- 바꾼 설정: `no-mix-dearu-desumasu` 는 본래 목록 항목에 である調를 요구한다. 두 문서에서 です/ます 목록을 36건 오탐해서, 목록은 «다수 문체 기준 섞임만», 본문은 ですます 기준으로 바꿨다(BIRTH_REPORT §6-3). 진짜 섞임은 계속 잡는다. «する。» 같은 평서형은 바꾸기 전에도 후에도 잡지 못한다.
- 남은 한계: `ja-no-abusage` 는 «1 回目が止まった» 의 «目が止まっ» 을 오용으로 잘못 읽었다. 긴 단락에서 열 번호가 줄 길이를 넘게 나오는 경우가 있다(README.ja.md 75 · 126행).

## 출처
- textlint: https://textlint.org · preset-ja-technical-writing: https://github.com/textlint-ja/textlint-rule-preset-ja-technical-writing · preset-ai-writing: https://github.com/textlint-ja/textlint-rule-preset-ai-writing
