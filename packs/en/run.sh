#!/usr/bin/env bash
# packs/en/run.sh <file> — Vale(Google + write-good) wrapper. Level: wrapper-only.
# exit: 0 clean · 1 findings (candidates, not confirmed defects) · 2 UNMEASURED (vale missing/errored, styles not synced, bad input)
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
f="${1:-}"
[ -n "$f" ] && [ -f "$f" ] || { echo "UNMEASURED: input file missing: '$f'" >&2; exit 2; }
command -v vale >/dev/null 2>&1 || { echo "UNMEASURED: vale not installed — this is not a pass" >&2; exit 2; }
[ -d "$HERE/styles/Google" ] && [ -d "$HERE/styles/write-good" ] || {
  echo "UNMEASURED: styles not synced — run: (cd $HERE && vale sync)" >&2; exit 2; }
out="$(vale --config="$HERE/.vale.ini" --no-exit --output=line "$f" 2>&1)"; rc=$?
[ $rc -eq 0 ] || { echo "$out" >&2; echo "UNMEASURED: vale exited $rc — this is not a pass" >&2; exit 2; }
n="$(printf '%s\n' "$out" | grep -c ':[0-9]*:[0-9]*:' || true)"
[ -n "$out" ] && printf '%s\n' "$out"
echo "pack=en level=wrapper-only findings=$n file=$f"
[ "$n" -gt 0 ] && exit 1 || exit 0
