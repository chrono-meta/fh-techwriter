# en 팩 — English

- **수준: wrapper-only.** Vale 3.26.0 을 감싼다. 이 레포가 실측한 영어 클래스는 없다.
- 실행: `bash packs/en/run.sh <file>` (처음 한 번 `cd packs/en && vale sync` — 스타일 패키지를 `packs/en/styles/` 에 받는다)
- exit: 0 지적 없음 · 1 지적 있음(후보다) · 2 UNMEASURED(vale 없음 · 스타일 미동기화 · vale 오류)

## 무엇을 보나
- Vale 기본 스타일(철자) + Google 개발자 문서 스타일 + write-good(수동태 · 군더더기 · 약한 말).

## 무엇을 보지 않나 (UNMEASURED)
- **번역투 제거.** 한국어 · 일본어에서 옮긴 영어의 어색함을 재는 레인이 없다. 이 팩으로 번역투 제거를 주장하지 않는다.
- 저자 교정 실측. 영어 저자 교정 표본이 없다.
- 매체 보정(실제 게재 글 대조).
- 출생 실행 기준 정밀도는 낮다. FH README 한 편에서 226건이 나왔고, 표본 10건 중 사람이 고칠 만한 것은 1건이었다(BIRTH_REPORT).
- 꺼 둔 규칙: `write-good.E-Prime` · `Google.Parens`. 두 문서(FH README · openhuman README)에서 표본 32건을 봤는데 고칠 만한 것이 0이었다(BIRTH_REPORT §6-3). 끈 뒤의 정밀도는 다시 재지 않았다.

## 출처
- Vale: https://vale.sh · Google 스타일 패키지: https://github.com/errata-ai/Google · write-good: https://github.com/errata-ai/write-good
