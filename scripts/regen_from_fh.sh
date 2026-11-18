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
tmp="$(mktemp -d)" && [ -d "$tmp" ] || { echo "UNMEASURED: mktemp -d failed — nothing regenerated" >&2; exit 2; }
trap 'rm -rf "$tmp"' EXIT
git clone -q --local --no-checkout "$FH" "$tmp/fh" && git -C "$tmp/fh" checkout -q "$sha" || {
  echo "UNMEASURED: could not check out $sha in a scratch clone" >&2; exit 2; }
( cd "$tmp/fh" && python3 scripts/fh_module_check.py export "$MANIFEST" --out "$tmp/out" ) >"$tmp/export.log" 2>&1 || {
  cat "$tmp/export.log" >&2; echo "UNMEASURED: FH export failed at $sha — nothing here was changed" >&2; exit 2; }

# The exported paths: the skill folder, .fh-export/, and every file the export produced.
# Paths travel NUL-delimited end to end (git ls-files -z · find -print0 · xargs -0): a name with a space,
# a quote or non-ASCII (which plain `git ls-files` C-quotes) must not be split, skipped or mis-staged.
EXPORTED=(plugins/fh-commons/skills/ko-tech-writer .fh-export scripts/ko_tech_writer_calibrate.py scripts/test_ko_tech_writer_lanes.sh)
cd "$ROOT" || { echo "UNMEASURED: cannot cd to $ROOT — nothing here was changed" >&2; exit 2; }
git ls-files -z -- "${EXPORTED[@]}" > "$tmp/old.z" || { echo "UNMEASURED: git ls-files failed — nothing here was changed" >&2; exit 2; }
( cd "$tmp/out" && find . -type f -print0 ) | while IFS= read -r -d '' f; do printf '%s\0' "${f#./}"; done | sort -z > "$tmp/new.z"
[ -s "$tmp/new.z" ] || { echo "UNMEASURED: export produced no files" >&2; exit 2; }
# Copy the export to a staging folder FIRST and check every stage of the pipe. Only a complete copy may
# replace the old files — a failed tar used to leave the exported paths half-deleted.
mkdir "$tmp/stage" || { echo "UNMEASURED: cannot create staging folder — nothing here was changed" >&2; exit 2; }
( cd "$tmp/out" && tar cf - . ) | ( cd "$tmp/stage" && tar xf - ); st=("${PIPESTATUS[@]}")
[ "${st[0]}" -eq 0 ] && [ "${st[1]}" -eq 0 ] || {
  echo "UNMEASURED: copying the export failed (tar rc ${st[*]}) — nothing here was changed" >&2; exit 2; }
xargs -0 rm -f -- < "$tmp/old.z"
rm -rf plugins/fh-commons/skills/ko-tech-writer .fh-export
( cd "$tmp/stage" && tar cf - . ) | tar xf -; st=("${PIPESTATUS[@]}")
[ "${st[0]}" -eq 0 ] && [ "${st[1]}" -eq 0 ] || {
  echo "FAIL: placing the staged export failed (tar rc ${st[*]}) — exported paths are half-replaced." >&2
  echo "      Restore them with: git restore --source=HEAD --staged --worktree -- ${EXPORTED[*]}" >&2; exit 1; }
new="$(tr '\0' '\n' < "$tmp/new.z")"
printf 'ko-tech-writer here is generated from forge-harness %s (%s) by scripts/regen_from_fh.sh.\nEdit it in forge-harness, not here. Paths:\n%s\n' \
  "$sha" "$REF" "$new" > GENERATED_FROM_FH.txt
{ cat "$tmp/old.z" "$tmp/new.z"; printf '%s\0' GENERATED_FROM_FH.txt; } | sort -zu | xargs -0 git add -A -- || {
  echo "FAIL: git add of the regenerated paths failed" >&2; exit 1; }
echo "regenerated from FH $sha ($REF): $(printf '%s\n' "$new" | wc -l | xargs) files (staged)"
git status --short -- plugins/fh-commons/skills/ko-tech-writer .fh-export scripts/ko_tech_writer_calibrate.py scripts/test_ko_tech_writer_lanes.sh GENERATED_FROM_FH.txt

rc=0
bash scripts/check_fh_sync.sh "$FH" "$sha"; s=$?; echo "check_fh_sync rc=$s"; [ $s -eq 0 ] || rc=1
bash scripts/test_ko_tech_writer_lanes.sh >"$tmp/lanes.log" 2>&1; l=$?; echo "ko lanes rc=$l"
[ $l -eq 0 ] || { tail -20 "$tmp/lanes.log" >&2; rc=1; }
exit $rc
