#!/usr/bin/env bash
# packs/ko/run.sh <file> — ko-tech-writer scan lanes (C1–C21, FH export) + this repo's §2-b lanes K1–K2 (packs/ko/extra_lanes.py). Level: measured (author-correction classes + calibrated lanes).
# exit: 0 clean · 1 findings (candidates, not confirmed defects; some lanes are labelled 후보/UNCALIBRATED) · 2 UNMEASURED (python3 missing, scanner error, unclosed block)
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/../.." && pwd)"
PY="$ROOT/scripts/ko_tech_writer_calibrate.py"
f="${1:-}"
[ -n "$f" ] && [ -f "$f" ] || { echo "UNMEASURED: input file missing: '$f'" >&2; exit 2; }
command -v python3 >/dev/null 2>&1 || { echo "UNMEASURED: python3 not installed — this is not a pass" >&2; exit 2; }
[ -f "$PY" ] || { echo "UNMEASURED: scanner missing: $PY" >&2; exit 2; }
out="$(python3 "$PY" --scan "$f" 2>&1)"; rc=$?
[ $rc -eq 0 ] || { echo "$out" >&2; echo "UNMEASURED: scanner exited $rc (3 = unclosed fence/fig block) — this is not a pass" >&2; exit 2; }
ext="$(python3 "$HERE/extra_lanes.py" "$f" 2>&1)"; rc=$?
[ $rc -eq 0 ] || { echo "$ext" >&2; echo "UNMEASURED: extra_lanes.py exited $rc — this is not a pass" >&2; exit 2; }
[ -n "$ext" ] && out="$out"$'\n'"$ext"
n="$(printf '%s\n' "$out" | grep -cE $'^[0-9]+\t' || true)"
printf '%s\n' "$out"
echo "pack=ko level=measured findings=$n file=$f"
[ "$n" -gt 0 ] && exit 1 || exit 0
