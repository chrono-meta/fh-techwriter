#!/usr/bin/env bash
# calibrate_packs.sh — known-pair check for every pack wrapper before trusting it.
# PASS per pack = must_flag exits 1 AND must_not_flag exits 0 AND tool-absent run exits 2 (UNMEASURED, never 0).
# exit: 0 all packs PASS · 1 any FAIL
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fail=0
for l in ko en ja; do
  w="$ROOT/packs/$l/run.sh"; c="$ROOT/packs/$l/calibration"
  bash "$w" "$c/must_flag.md" >/dev/null 2>&1; a=$?
  bash "$w" "$c/must_not_flag.md" >/dev/null 2>&1; b=$?
  bash "$w" "$c/does_not_exist.md" >/dev/null 2>&1; d=$?
  # tool-absent: hide the tool behind a PATH without it (ko: python3, en: vale); ja: point at a missing node_modules via a copy
  case $l in
    ko|en) env PATH=/nonexistent /bin/bash "$w" "$c/must_flag.md" >/dev/null 2>&1; t=$? ;;
    ja) tmp="$(mktemp -d)"; mkdir -p "$tmp/packs/ja"; cp "$w" "$ROOT/packs/ja/.textlintrc.json" "$tmp/packs/ja/"
        bash "$tmp/packs/ja/run.sh" "$c/must_flag.md" >/dev/null 2>&1; t=$?; rm -rf "$tmp" ;;
  esac
  if [ $a -eq 1 ] && [ $b -eq 0 ] && [ $d -eq 2 ] && [ $t -eq 2 ]; then s=PASS; else s=FAIL; fail=1; fi
  echo "$l $s must_flag=$a must_not_flag=$b missing_input=$d tool_absent=$t"
done
# ko §2-b lanes (packs/ko/extra_lanes.py): exact counts on their own pair
kp="$(python3 "$ROOT/packs/ko/extra_lanes.py" "$ROOT/packs/ko/calibration/k_must_flag.md" 2>/dev/null)"
kn="$(python3 "$ROOT/packs/ko/extra_lanes.py" "$ROOT/packs/ko/calibration/k_must_not_flag.md" 2>/dev/null)"
k1="$(printf '%s\n' "$kp" | grep -c $'\tK1 ' || true)"; k2="$(printf '%s\n' "$kp" | grep -c $'\tK2 ' || true)"
kneg="$(printf '%s' "$kn" | grep -c . || true)"
if [ "$k1" -eq 3 ] && [ "$k2" -eq 1 ] && [ "$kneg" -eq 0 ]; then s=PASS; else s=FAIL; fail=1; fi
echo "ko-K $s K1=$k1/3 K2=$k2/1 must_not_flag=$kneg"
exit $fail
