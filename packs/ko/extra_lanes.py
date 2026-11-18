#!/usr/bin/env python3
"""packs/ko/extra_lanes.py <file> — ko lanes that live in this repo, not in the FH export.

Kept apart from scripts/ko_tech_writer_calibrate.py on purpose: that file is the exported copy and
must stay byte-identical to forge-harness (scripts/check_fh_sync.sh). Lanes here move into the
canonical scanner when FH's copy is retired.

Source: operator correction 2026-11-07 (STYLE_BRIEF §2-b, origin O):
  K1 forward-pointing lead-in «…는 이렇습니다.» / «다음과 같습니다.» that defers content to a list or
     the next sentence (candidate — a lead-in that itself carries content is fine).
  K2 «~한 셈입니다» flip-ending (candidate).
Not covered (UNMEASURED): missing subject/object, inverted word order — no pattern exists.
Output: <line>\t<class>\t<text>, same as --scan. Exit 0 always on a readable file, 10 on bad input.
"""
import re, sys

LANES = [
    ("K1 예고형 도입(§2-b·후보)",
     re.compile(r"(이렇(습니다|다|게\s?됩니다|게\s?줄어듭니다)|(다음|아래)과\s?같(습니다|다))\s*[.:：]?\s*$")),
    ("K2 «~셈입니다» 뒤집는 마무리(§2-b·후보)",
     re.compile(r"셈(입니다|이다)\s*[.]?")),
]

def main(argv):
    if len(argv) != 1:
        print("usage: extra_lanes.py FILE", file=sys.stderr); return 10
    try:
        lines = open(argv[0], encoding="utf-8").read().splitlines()
    except OSError as e:
        print(f"harness error: {e}", file=sys.stderr); return 10
    fence = False
    hits = []
    for i, raw in enumerate(lines, 1):
        s = raw.strip()
        if s.startswith("```") or s.startswith("~~~"):
            fence = not fence; continue
        if fence or s.startswith("<!--") or s.startswith("|"):
            continue
        body = re.sub(r"<!--.*?-->", "", raw).rstrip()
        # judge sentence by sentence so a mid-line lead-in («…이렇습니다. 다음 문장») is still caught
        for sent in re.split(r"(?<=[.!?])\s+", body):
            for name, rx in LANES:
                if rx.search(sent):
                    hits.append((i, name, raw)); break
    for i, name, raw in hits:
        print(f"{i}\t{name}\t{raw}")
    return 0

if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
