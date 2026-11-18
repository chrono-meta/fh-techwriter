#!/usr/bin/env bash
# packs/ja/run.sh <file> — textlint(preset-ja-technical-writing + @textlint-ja/preset-ai-writing) wrapper. Level: wrapper-only.
# exit: 0 clean · 1 findings (candidates, not confirmed defects) · 2 UNMEASURED (textlint missing/errored, bad input)
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/../.." && pwd)"
TL="$ROOT/node_modules/.bin/textlint"
f="${1:-}"
[ -n "$f" ] && [ -f "$f" ] || { echo "UNMEASURED: input file missing: '$f'" >&2; exit 2; }
[ -x "$TL" ] || { echo "UNMEASURED: textlint not installed — run: (cd $ROOT && npm ci) — this is not a pass" >&2; exit 2; }
f_abs="$(cd "$(dirname "$f")" && pwd)/$(basename "$f")"
out="$(cd "$ROOT" && "$TL" --config "$HERE/.textlintrc.json" --format unix "$f_abs" 2>&1)"; rc=$?
# textlint: 0 = no lint errors, 1 = lint errors found, >=2 = fatal
if [ $rc -ne 0 ] && [ $rc -ne 1 ]; then echo "$out" >&2; echo "UNMEASURED: textlint exited $rc — this is not a pass" >&2; exit 2; fi
n="$(printf '%s\n' "$out" | grep -cE ':[0-9]+:[0-9]+: ' || true)"
if [ $rc -eq 1 ] && [ "$n" -eq 0 ]; then echo "$out" >&2; echo "UNMEASURED: textlint rc=1 but no parsable findings" >&2; exit 2; fi
[ -n "$out" ] && printf '%s\n' "$out"
echo "pack=ja level=wrapper-only findings=$n file=$f"
[ "$n" -gt 0 ] && exit 1 || exit 0
