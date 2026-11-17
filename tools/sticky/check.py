"""Checks the key-pose animations the same way UnweakTests/StickyBodyTests does.

Usage: python3 tools/sticky/check.py tools/sticky
"""
import math, sys
sys.path.insert(0, sys.argv[1])
from anims import ANIMS
from body import solve, pose_at, TORSO, NECK, UPPER, FORE, THIGH, SHIN

ok = True
for name, A in ANIMS.items():
    W, H = A['canvas']; bone = 0.0; pin = 0.0; closest = 1e9; outside = 0
    for i in range(1001):
        p = pose_at(A['keys'], i / 1000); f = solve(p)
        bone = max(bone, abs(math.dist(f['hip'], f['shoulder']) - TORSO), abs(math.dist(f['shoulder'], f['head']) - NECK))
        for root, (m, e), (l1, l2) in [(f['shoulder'], a, (UPPER, FORE)) for a in f['arms']] + [(f['hip'], l, (THIGH, SHIN)) for l in f['legs']]:
            bone = max(bone, abs(math.dist(root, m) - l1), abs(math.dist(m, e) - l2))
            closest = min(closest, math.dist(root, e))
        for spec, (m, e) in zip(p['arms'] + p['legs'], f['arms'] + f['legs']):
            if spec[0] == 'p': pin = max(pin, math.dist(e, spec[1]))
        pts = [f['hip'], f['shoulder'], f['head']] + [q for l in f['arms'] + f['legs'] for q in l]
        outside += sum(1 for x, y in pts if not (0 <= x <= W and 0 <= y <= H))
    good = bone < 0.01 and pin < 2 and outside == 0 and closest >= 5
    ok &= good
    print(f"{'ok ' if good else 'BAD'} {name:12s} boneError={bone:.3f} pinError={pin:.2f} closestRootToEnd={closest:.1f} outside={outside}")
sys.exit(0 if ok else 1)
