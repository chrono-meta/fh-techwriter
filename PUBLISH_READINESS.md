# 공개 준비 점검 (Pre-Publish dry run, 2026-11-18)

이 문서는 공개 전에 돌린 점검의 기록이다. **공개는 하지 않았다.** visibility 변경, 새 레포 생성, 이력 재작성은 운영자가 정한다.

## 결과 요약

| 점검 | 결과 | 비고 |
|---|---|---|
| FH 사본 동기화 `scripts/check_fh_sync.sh` | rc=0 (files=15, drift=0) | FH `origin/main` 기준 |
| 단일 원본 레인 `scripts/test_regen_lanes.sh` | rc=0 (R0 · R1 · R2a · R2b 모두 OK) | 생성 파일을 손으로 고치면 1, 다시 생성하면 0 |
| 팩 보정 `scripts/calibrate_packs.sh` | rc=0, UNMEASURED 0 | ko · en · ja · ko-K 모두 PASS |
| ko 레인 `scripts/test_ko_tech_writer_lanes.sh` | rc=0 | 레인 C1~C22 |
| public-surface-audit (추적 파일 전체) | 0건 | 아래 참고 |
| 대조군(심은 토큰) | 잡힘 (rc=1, 5건) | 같은 스캐너, 임시 사본 |
| marketplace-gate Check 5 (공개 안전) | SAFE | public-surface-audit CLEAN + LICENSE 있음 |
| security-review (첫 커밋 변경분) | 보고할 취약점 0건 | 뒤에 더한 스크립트 2개는 작성자 자가 확인만. 아래 참고 |
| LICENSE | MIT, Copyright (c) 2026 chrono-meta | 본문은 forge-harness 와 같다 |

## public-surface-audit

- 범위: `git ls-files` 전체(60개 파일). 바이너리는 없다.
- 패턴: forge-harness 의 `scripts/psa_scan_lib.sh` 를 그대로 썼다. 공개 기본 패턴과 운영자 비공개 패턴(사용자 이름 · 회사명 · 홈 경로 · 보조 저장소 이름)을 합쳐 27행이다. 운영자 패턴 파일이 있었으므로 NOT CONFIGURED 상태가 아니다.
- 추가 목록: 대소문자 무시로 macOS 홈 경로 접두어, 보조 저장소 이름, 내부 호스트 모양(내부망 · VPN 도메인 접미어, 사설 IP), 국내 주요 회사명 몇 개를 패턴에 더해 검사했다. 이 목록에서도 0건이다.
- 대조군: 임시 사본에 사용자 이름 · 홈 경로 · 보조 저장소 이름을 한 줄 심었다. 같은 스캐너가 이 줄을 5건으로 잡았다(rc=1). 그래서 위의 0건은 스캐너가 실제로 잡을 수 있는 상태에서 나온 결과다.
- 남긴 것: `SKILL.md` 의 매체 프로필(tech.kakaopay.com 공개 글 11편)은 공개된 forge-harness 에도 그대로 있다. FH 원본과 바이트 단위로 같게 두었다.

## 고친 것

- 세 파일(`BIRTH_REPORT.md`, `core/PANEL_AND_ROUNDS.md`, `packs/ko/PACK.md`)에 적혀 있던 저자의 비공개 작업 노트 경로를 중립 문구로 바꿨다.
- `birth/after_tuning/fh_sync.out.txt` 는 절대 경로가 찍힌 첫 실행 출력이었다. 상대 경로로 다시 돌린 출력으로 바꿨다. 첫 실행 결과(exit 1)는 `BIRTH_REPORT.md` 6-1 에 글로 남아 있다.
- README 를 외부 독자용으로 다시 썼다. ko 는 문서 한 편으로 쟀고, en · ja 는 린터 래퍼라 번역투 제거 효과가 UNMEASURED 라고 적었다.
- 서드파티 파일은 이 레포에 들어 있지 않다. Vale 스타일(Google, write-good)은 `vale sync` 가, textlint 규칙(MIT)은 `npm ci` 가 받아 온다. 그래서 별도 고지 파일을 두지 않았다.

## security-review

- 첫 커밋의 변경분은 별도 서브 에이전트가 검토했다. 대상은 코드 파일 두 개(`scripts/check_fh_sync.sh`, `scripts/ko_tech_writer_calibrate.py`)다. 높은 확신으로 보고할 취약점은 0건이었다. `eval` · `subprocess` · `pickle` · `yaml` 을 쓰지 않고 네트워크 호출도 없다. 이 결과는 코드를 읽고 내린 판단이고, 공격을 실제로 재현해 본 것은 아니다.
- 단일 원본 작업으로 더한 두 스크립트(`scripts/regen_from_fh.sh`, `scripts/test_regen_lanes.sh`)는 그 검토가 끝난 뒤에 썼다. 그래서 그 검토에 들어 있지 않고, 작성자가 직접 읽어 확인한 것뿐이다. 두 스크립트는 사용자가 넘긴 FH 경로를 따옴표로 감싸 `git` 에만 넘긴다. 파일을 쓰는 곳은 `mktemp` 임시 폴더와 이 레포의 생성 경로뿐이다.
- 참고(결함으로 보지 않음): 래퍼는 사용자가 넘긴 파일 이름을 검증 없이 린터에 넘긴다. 로컬 사용자가 직접 넣는 값이라 취약점으로 분류하지 않았다.

## 공개 전에 남은 일 (운영자 결정)

- **이력.** 기존 커밋 4개의 diff 에 비공개 토큰이 남아 있다(사용자 이름 · 홈 경로 2줄, 보조 저장소 이름 6줄). 이 브랜치는 이력을 고치지 않는다. 선택지는 세 가지다. ① 새 공개 레포를 단일 커밋으로 시작한다. ② 이력을 재작성한다. ③ 이력에 남은 토큰을 감수하고 그대로 공개한다. 단일 커밋 트리는 레포 밖 임시 폴더에 준비해 두었다(경로와 트리 해시는 PR 본문에 있다).
- **FH 쪽 자동 재생성.** FH 에서 ko-tech-writer 가 바뀔 때 이 레포를 다시 생성하는 장치는 만들지 않았다. 지금은 `scripts/regen_from_fh.sh` 를 손으로 돌린다.
