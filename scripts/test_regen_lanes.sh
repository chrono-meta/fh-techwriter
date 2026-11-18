#!/usr/bin/env bash
# test_regen_lanes.sh <FH_ROOT> [REF] — known-pair lane for the single-source rule, run in a scratch clone.
#   R0  fresh clone of this repo's HEAD (+ current scripts/): check_fh_sync.sh → 0
#   R1  hand-edit one exported file (append a line to SKILL.md) → check_fh_sync.sh → 1 and names that file
#   R2  regen_from_fh.sh → rc 0, and check_fh_sync.sh → 0 again (the hand edit is gone)
# Nothing in this checkout is touched. exit: 0 all OK · 1 a lane failed · 2 UNMEASURED (no FH checkout/ref)
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FH="${1:-${FH_HOME:-}}"; REF="${2:-origin/main}"
[ -n "$FH" ] && git -C "$FH" rev-parse --verify -q "$REF^{commit}" >/dev/null 2>&1 || {
  echo "UNMEASURED: need a forge-harness checkout with ref '$REF' (arg 1 or FH_HOME) — not a pass" >&2; exit 2; }
FH="$(cd "$FH" && pwd)"
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
git clone -q --local "$ROOT" "$tmp/r" || { echo "UNMEASURED: could not clone this repo" >&2; exit 2; }
cp "$ROOT"/scripts/*.sh "$tmp/r/scripts/"
cd "$tmp/r"; fail=0
ok(){ echo "OK   $1"; }; bad(){ echo "FAIL $1"; fail=1; }
T=plugins/fh-commons/skills/ko-tech-writer/SKILL.md

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
exit $fail
