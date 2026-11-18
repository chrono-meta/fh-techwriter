#!/usr/bin/env bash
# test_regen_lanes.sh <FH_ROOT> [REF] — known-pair lanes for the single-source rule and for regen_from_fh.sh's
# failure handling. Every lane runs in its own scratch clone of this repo's HEAD (+ the current scripts/).
#   R0  fresh clone: check_fh_sync.sh → 0
#   R1  hand-edit one exported file (append a line to SKILL.md) → check_fh_sync.sh → 1 and names that file
#   R2  regen_from_fh.sh → rc 0, and check_fh_sync.sh → 0 again (the hand edit is gone)
#   R3  tar fails while copying the export (a failing `tar` first on PATH) → regen exits 2 and the exported
#       paths are untouched (working tree and index identical to HEAD). Red if the tar status is not checked.
#   R4  a stale tracked file under an exported path whose name has a space and Korean letters → regen
#       removes it AND stages the deletion, and sync is 0. Red if paths are newline-split (no -z / xargs -0).
#   R5  static: regen guards `cd "$ROOT"` and `mktemp -d` (cannot be made to fail from outside, so this
#       lane reads the source). Red if either guard is removed.
# Nothing in this checkout is touched. exit: 0 all OK · 1 a lane failed · 2 UNMEASURED (no FH checkout/ref)
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FH="${1:-${FH_HOME:-}}"; REF="${2:-origin/main}"
[ -n "$FH" ] && git -C "$FH" rev-parse --verify -q "$REF^{commit}" >/dev/null 2>&1 || {
  echo "UNMEASURED: need a forge-harness checkout with ref '$REF' (arg 1 or FH_HOME) — not a pass" >&2; exit 2; }
FH="$(cd "$FH" && pwd)"
tmp="$(mktemp -d)" && [ -d "$tmp" ] || { echo "UNMEASURED: mktemp -d failed" >&2; exit 2; }
trap 'rm -rf "$tmp"' EXIT
fail=0
ok(){ echo "OK   $1"; }; bad(){ echo "FAIL $1"; fail=1; }
T=plugins/fh-commons/skills/ko-tech-writer/SKILL.md
fresh(){  # $1 = lane name → a scratch clone of HEAD with the current scripts/ committed on top
  local d="$tmp/$1"
  git clone -q --local "$ROOT" "$d" || { echo "UNMEASURED: could not clone this repo" >&2; exit 2; }
  cp "$ROOT"/scripts/*.sh "$d/scripts/" && git -C "$d" add scripts && git -C "$d" -c user.name=lane -c user.email=lane@invalid \
    commit -q --allow-empty -m "lane: current scripts" || { echo "UNMEASURED: could not prepare scratch clone" >&2; exit 2; }
  cd "$d" || exit 2; }

# R0–R2
fresh r0
out="$(bash scripts/check_fh_sync.sh "$FH" "$REF" 2>&1)"; r=$?
[ $r -eq 0 ] && ok "R0 fresh copy is in sync (rc=0)" || bad "R0 fresh copy rc=$r (expected 0) — regenerate this repo first: $out"
printf '\nhand edit made by test_regen_lanes.sh\n' >> "$T"
out="$(bash scripts/check_fh_sync.sh "$FH" "$REF" 2>&1)"; r=$?
if [ $r -eq 1 ] && printf '%s\n' "$out" | grep -q "DRIFT  $T"; then ok "R1 hand edit is caught (rc=1, names $T)"
else bad "R1 hand edit rc=$r (expected 1 naming $T)"; fi
bash scripts/regen_from_fh.sh "$FH" "$REF" >"$tmp/regen.log" 2>&1; r=$?
[ $r -eq 0 ] && ok "R2a regen rc=0" || { bad "R2a regen rc=$r (expected 0)"; tail -15 "$tmp/regen.log"; }
out="$(bash scripts/check_fh_sync.sh "$FH" "$REF" 2>&1)"; r=$?
if [ $r -eq 0 ] && ! grep -q "hand edit made by test_regen_lanes.sh" "$T"; then ok "R2b after regen: in sync again (rc=0), hand edit gone"
else bad "R2b after regen rc=$r (expected 0, hand edit removed)"; fi

# R3 — a failing tar must leave the exported paths untouched
fresh r3
mkdir -p "$tmp/badbin" && printf '#!/bin/sh\necho "fake tar: failing on purpose" >&2\nexit 1\n' > "$tmp/badbin/tar" && chmod +x "$tmp/badbin/tar"
PATH="$tmp/badbin:$PATH" bash scripts/regen_from_fh.sh "$FH" "$REF" >"$tmp/r3.log" 2>&1; r=$?
st="$(git status --porcelain)"
if [ $r -eq 2 ] && [ -z "$st" ]; then ok "R3 tar failure → regen rc=2, exported paths untouched"
else bad "R3 tar failure → regen rc=$r (expected 2), status: $(printf '%s' "$st" | head -3 | tr '\n' ' ')"; fi

# R4 — a stale tracked file with a space and non-ASCII letters in its name
fresh r4
S="plugins/fh-commons/skills/ko-tech-writer/fixtures/낡은 픽스처.md"
printf 'stale\n' > "$S" && git add -- "$S" && git -c user.name=lane -c user.email=lane@invalid commit -q -m "lane: stale file" || exit 2
bash scripts/regen_from_fh.sh "$FH" "$REF" >"$tmp/r4.log" 2>&1; r=$?
staged_del="$(git -c core.quotePath=false diff --cached --name-status -- "$S")"
bash scripts/check_fh_sync.sh "$FH" "$REF" >/dev/null 2>&1; s=$?
if [ $r -eq 0 ] && [ ! -e "$S" ] && [ "$staged_del" = "D	$S" ] && [ $s -eq 0 ]; then
  ok "R4 stale '$S' removed, deletion staged, sync rc=0"
else bad "R4 stale file: regen rc=$r, exists=$([ -e "$S" ] && echo yes || echo no), staged='$staged_del', sync rc=$s"; tail -5 "$tmp/r4.log"; fi

# R5 — guards that cannot be triggered from outside
cd "$ROOT" || exit 2
g1="$(grep -cE '^cd "\$ROOT" \|\| \{.*exit 2' scripts/regen_from_fh.sh)"
g2="$(grep -cE '^tmp="\$\(mktemp -d\)" && \[ -d "\$tmp" \] \|\| \{.*exit 2' scripts/regen_from_fh.sh)"
[ "$g1" -ge 1 ] && [ "$g2" -ge 1 ] && ok "R5 static: regen guards cd \"\$ROOT\" and mktemp -d" || bad "R5 static: cd guard=$g1 mktemp guard=$g2 (expected ≥1 each)"
exit $fail
