#!/usr/bin/env bash
# check_fh_sync.sh [FH_ROOT] [REF]  (FH_ROOT defaults to $FH_HOME, then $HOME/projects/forge-harness) — are the two copies of ko-tech-writer still the same?
# Compares every exported file here with the same path in forge-harness at REF (default origin/main),
# read through `git show` so FH's working tree / current branch does not matter.
# Ends when FH removes its copy (next FH major): then FH lacks the path → exit 3, and this check retires.
# exit: 0 in sync · 1 drift (names each file) · 2 UNMEASURED (FH checkout or REF missing) · 3 FH copy gone
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FH="${1:-${FH_HOME:-$HOME/projects/forge-harness}}"; REF="${2:-origin/main}"
git -C "$FH" rev-parse --verify -q "$REF^{commit}" >/dev/null 2>&1 || {
  echo "UNMEASURED: no forge-harness checkout with ref '$REF' at $FH — this is not in-sync" >&2; exit 2; }
files="$(cd "$ROOT" && git ls-files plugins/fh-commons/skills/ko-tech-writer scripts/ko_tech_writer_calibrate.py scripts/test_ko_tech_writer_lanes.sh)"
[ -n "$files" ] || { echo "UNMEASURED: no tracked ko-tech-writer files here" >&2; exit 2; }
drift=0; gone=0; n=0
while IFS= read -r p; do
  n=$((n+1))
  if ! git -C "$FH" cat-file -e "$REF:$p" 2>/dev/null; then echo "GONE-IN-FH  $p"; gone=$((gone+1)); continue; fi
  if ! git -C "$FH" show "$REF:$p" | cmp -s - "$ROOT/$p"; then echo "DRIFT  $p"; drift=$((drift+1)); fi
done <<< "$files"
echo "fh=$FH ref=$REF ($(git -C "$FH" rev-parse --short "$REF")) files=$n drift=$drift gone_in_fh=$gone"
[ $gone -eq $n ] && { echo "FH copy is gone — the two-copy period has ended; retire this check." ; exit 3; }
[ $drift -eq 0 ] && [ $gone -eq 0 ] && exit 0 || exit 1
