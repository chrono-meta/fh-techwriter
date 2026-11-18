# ko 팩 — 한국어

- **수준: measured.** 저자 교정 실측 부류(운영자 손편집 · 외부 리뷰어 지적 · 문서 댓글에서 거둔 클래스)와, known-pair 로 보정한 스캔 레인이다.
- 실행: `bash packs/ko/run.sh <file>` → `python3 scripts/ko_tech_writer_calibrate.py --scan <file>`
- exit: 0 지적 없음 · 1 지적 있음(후보다, 결함 확정이 아니다) · 2 UNMEASURED(python3 없음 · 스캐너 오류 · 안 닫힌 코드 블록)

## 무엇을 보나
- Step 2 번역투 · 문체 레인 C1~C5, C7~C21(줄표 이어붙임 · 용어-머리 · 콜론 나열투 · 조각문 · 소유 직역 · 기호 · 구어 어미 · 라틴 뒤 조사 띄어쓰기 · 내부 합성어 · 가운뎃점 밀도 · 대조형 문말 · 분열문 · 소제목 과밀 · 뻔한 추상어 · 풀이 없는 약어).
- Step 4-b 전칭 단정 후보 C6 · C6b. 이 레인은 숫자 · 주장 게이트로 넘길 자리를 표시한다. 결함 판정은 사람이 한다.
- 정본 본문: forge-harness 의 `plugins/fh-commons/skills/ko-tech-writer/SKILL.md`. 이 레포의 같은 경로는 `scripts/regen_from_fh.sh` 로 생성한 사본이다. 고칠 때는 FH 에서 고친다. 레인별 보정 스위트: `bash scripts/test_ko_tech_writer_lanes.sh`.

- 이 레포의 §2-b 레인 K1 예고형 도입 · K2 «~셈입니다» 마무리(`packs/ko/extra_lanes.py`, 후보). 운영자 교정 2026-11-07 에서 왔다. known-pair 는 `calibration/k_*.md` 에 있다. v3.9.1 → v4 퇴고 대조에서 5/5 가 실제로 고친 문장이었다(BIRTH_REPORT §6-2).

## 무엇을 보지 않나 (UNMEASURED)
- 운영자 교정 §2-b 의 나머지: 주어 · 목적어 · 서술어 결손, 도치. 패턴이 없다. 표 안의 예고형 도입도 보지 않는다.
- 국립국어원 범위 표기 규범(물결표 `~`). 현재 스킬은 en dash 를 권한다. 충돌이 해소되지 않았다.
- 문장 길이 · 매체 프로필 대조(매체 보정은 사람이 실제 게재 글을 읽는 단계다).
- 이름에 «후보» 나 «UNCALIBRATED» 가 붙은 레인(C9 · C15 · C16 · C17~C21)은 정상 용례도 걸린다. 스킬 자신의 known-negative 에서도 C9 · C15 가 1건씩 걸린다.

## 출처
- forge-harness `ko-tech-writer` 0.1.0 단독판(`.fh-export/MODULE.md`). 2026-11-07 에 처음 뽑았고, 2026-11-18 에 FH `origin/main`(`7097a4d8`)에서 다시 뽑았다. 다시 뽑은 판에는 낱말 뜻 늘어놓기(`--senses`, 레인 C22)가 들어 있다. `run.sh` 는 이 모드를 부르지 않는다.
- 국립국어원 규범 정리: 저자의 비공개 작업 노트(공개하지 않음).
- 운영자 교정 §2-b: 같은 노트의 문체 지침(공개하지 않음).
