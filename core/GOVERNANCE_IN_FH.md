# 언어 무관 거버넌스는 FH 에 있다

이 레포는 아래 다섯을 다시 짓지 않는다(SOUL 성공 정의 ③). 쓸 때는 forge-harness(FH)의 정본을 부른다.

| 거버넌스 | FH 정본 위치 |
|---|---|
| 숫자 · 주장 게이트(전 숫자 추출 · 라벨 · 창) | `plugins/fh-commons/skills/ko-tech-writer/SKILL.md` Step 4 (기존 검증 자산으로 라우팅) |
| 전칭 단정 후보 · 미측정 ≠ 0 | 같은 파일 Step 4-b |
| 개고 사후 점검 `--check-rewrite`(남길 곳 · 숫자 NEW/LOST · 발화 클래스) | 같은 파일 Step 4-c · `scripts/ko_tech_writer_calibrate.py --check-rewrite` |
| 정직 수위 분리(독자 정보 vs 자기감사) | 같은 파일 Step 3 |
| 정지 조건 루프(새 지적 0 ∧ 변경 0) + 라운드 상한 | `plugins/fh-commons/skills/convergence-loop/` |
| 모듈 계약 · 합성 계약(가장 엄격한 제약이 이긴다) | `knowledge/shared/harness-core/fh_module_contract.md` · `capability_composition_contract.md` |

## 지금 상태 — 두 벌이 있다
- 이 레포의 `plugins/fh-commons/skills/ko-tech-writer/` 와 `scripts/ko_tech_writer_*` 는 FH 의 `scripts/fh_module_check.py export` 로 뽑은 단독판이다(2026-11-07, `.fh-export/`).
- 그래서 Step 3 · 4 의 본문이 이 레포에도 사본으로 들어 있다. 이 사본은 ko 팩이 돌기 위한 것이고, 거버넌스의 정본은 FH 쪽이다.
- 단일 원본(2026-11-18 운영자 결정): ko-tech-writer 의 원본은 FH 에 남는다. 이 레포의 사본은 `bash scripts/regen_from_fh.sh <FH_ROOT>` 로 생성하고, 여기서 고치지 않는다. `bash scripts/check_fh_sync.sh [FH_ROOT] [REF]` 로 두 사본을 대조한다(0 같음 · 1 갈라짐 · 2 UNMEASURED · 3 FH 사본 사라짐). 그전 계획(FH 다음 메이저에서 FH 쪽 본체 제거)은 이 결정으로 바뀌었다. 2026-11-07 첫 실행은 1이었다. 다른 세션이 이 레포 작업 트리의 SKILL.md 에 «정본 위치» 줄을 넣었고 아직 커밋하지 않았다. 커밋된 사본은 FH 와 같다.
- 이 레포에서만 쓰는 ko 레인(`packs/ko/extra_lanes.py`)은 export 사본 밖에 둔다. export 사본을 고치면 대조가 깨진다.
- FH 쪽 연결부 PR 은 이 레포가 아니라 FH 에서 따로 만든다.
