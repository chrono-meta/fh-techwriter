#!/usr/bin/env bash
# regen_from_fh.sh <FH_ROOT> [REF] — rebuild this repo's copy of ko-tech-writer from forge-harness.
#
# Single-source rule: the canon of ko-tech-writer lives in forge-harness
# (plugins/fh-commons/skills/ko-tech-writer + scripts/ko_tech_writer_*). The copy here is generated —
# edit it there, not here. Repo-owned parts are packs/, core/, birth/, README, LICENSE and the other
# scripts in scripts/.
#
# What it does: clones FH at REF (default origin/main) into a temp folder, runs FH's own
# `fh_module_check.py export` there, replaces ONLY the exported paths here with the result (stale files
# under those paths are removed), stages them, writes GENERATED_FROM_FH.txt, then runs
# check_fh_sync.sh (must be 0) and the ko lane suite (must be 0).
# exit: 0 regenerated and verified · 1 regenerated but a check failed · 2 UNMEASURED (FH/REF missing, export failed)
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FH="${1:-${FH_HOME:-}}"; REF="${2:-origin/main}"
[ -n "$FH" ] || { echo "usage: regen_from_fh.sh <FH_ROOT> [REF]  (or set FH_HOME)" >&2; exit 2; }
FH="$(cd "$FH" 2>/dev/null && pwd)" || { echo "UNMEASURED: FH checkout not found" >&2; exit 2; }
sha="$(git -C "$FH" rev-parse --verify -q "$REF^{commit}")" || {
  echo "UNMEASURED: no ref '$REF' in $FH — nothing regenerated" >&2; exit 2; }
MANIFEST=plugins/fh-commons/skills/ko-tech-writer/fh-module.yaml
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
git clone -q --local --no-checkout "$FH" "$tmp/fh" && git -C "$tmp/fh" checkout -q "$sha" || {
  echo "UNMEASURED: could not check out $sha in a scratch clone" >&2; exit 2; }
( cd "$tmp/fh" && python3 scripts/fh_module_check.py export "$MANIFEST" --out "$tmp/out" ) >"$tmp/export.log" 2>&1 || {
  cat "$tmp/export.log" >&2; echo "UNMEASURED: FH export failed at $sha — nothing here was changed" >&2; exit 2; }

# The exported paths: the skill folder, .fh-export/, and every file the export produced.
cd "$ROOT"
old="$(git ls-files plugins/fh-commons/skills/ko-tech-writer .fh-export scripts/ko_tech_writer_calibrate.py scripts/test_ko_tech_writer_lanes.sh)"
new="$(cd "$tmp/out" && find . -type f | sed 's|^\./||' | sort)"
[ -n "$new" ] || { echo "UNMEASURED: export produced no files" >&2; exit 2; }
[ -n "$old" ] && printf '%s\n' "$old" | while IFS= read -r p; do rm -f -- "$p"; done
rm -rf plugins/fh-commons/skills/ko-tech-writer .fh-export
( cd "$tmp/out" && tar cf - . ) | tar xf -
printf 'ko-tech-writer here is generated from forge-harness %s (%s) by scripts/regen_from_fh.sh.\nEdit it in forge-harness, not here. Paths:\n%s\n' \
  "$sha" "$REF" "$new" > GENERATED_FROM_FH.txt
{ [ -n "$old" ] && printf '%s\n' "$old"; printf '%s\n' "$new" GENERATED_FROM_FH.txt; } | sort -u | xargs git add -A --
echo "regenerated from FH $sha ($REF): $(printf '%s\n' "$new" | wc -l | xargs) files (staged)"
git status --short -- plugins/fh-commons/skills/ko-tech-writer .fh-export scripts/ko_tech_writer_calibrate.py scripts/test_ko_tech_writer_lanes.sh GENERATED_FROM_FH.txt

rc=0
bash scripts/check_fh_sync.sh "$FH" "$sha"; s=$?; echo "check_fh_sync rc=$s"; [ $s -eq 0 ] || rc=1
bash scripts/test_ko_tech_writer_lanes.sh >"$tmp/lanes.log" 2>&1; l=$?; echo "ko lanes rc=$l"
[ $l -eq 0 ] || { tail -20 "$tmp/lanes.log" >&2; rc=1; }
exit $rc
