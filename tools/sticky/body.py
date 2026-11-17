import math
NECK, TORSO, UPPER, FORE, THIGH, SHIN = 14, 42, 22, 21, 24, 23

def pt(p, ang, l):
    a = math.radians(ang); return (p[0] + l*math.cos(a), p[1] + l*math.sin(a))

def joint(start, end, l1, l2, bend):
    dx, dy = end[0]-start[0], end[1]-start[1]; d0 = math.hypot(dx, dy)
    if d0 == 0: return (start[0], start[1]+l1)
    ux, uy = dx/d0, dy/d0; d = max(min(d0, l1+l2), abs(l1-l2), 1e-6)
    a = (l1*l1 - l2*l2 + d*d)/(2*d); h = math.sqrt(max(l1*l1 - a*a, 0))
    bx, by = start[0]+ux*a, start[1]+uy*a
    c1 = (bx - uy*h, by + ux*h); c2 = (bx + uy*h, by - ux*h)
    def cross(c): return dx*(c[1]-start[1]) - dy*(c[0]-start[0])
    return c1 if (cross(c1) >= 0) == (bend > 0) else c2

def limb(root, spec, l1, l2):
    if spec[0] == 'a':
        m = pt(root, spec[1], l1); return m, pt(m, spec[2], l2)
    _, end, bend = spec
    m = joint(root, end, l1, l2, bend)
    # end reached? if out of reach, stretch toward end
    d = math.hypot(end[0]-root[0], end[1]-root[1])
    if d > l1 + l2:
        ang = math.degrees(math.atan2(end[1]-root[1], end[0]-root[0]))
        return pt(root, ang, l1), pt(root, ang, l1+l2)
    return m, end

def solve(p):
    hip = p['hip']; sh = pt(hip, p['torso'], TORSO); head = pt(sh, p['neck'], NECK)
    arms = [limb(sh, s, UPPER, FORE) for s in p['arms']]
    legs = [limb(hip, s, THIGH, SHIN) for s in p['legs']]
    return dict(hip=hip, shoulder=sh, head=head, arms=arms, legs=legs)

def smooth(f): return f*f*(3-2*f)
def lerp(a, b, f): return a + (b-a)*f
def lerp_spec(a, b, f):
    assert a[0] == b[0], (a, b)
    if a[0] == 'a': return ('a', lerp(a[1], b[1], f), lerp(a[2], b[2], f))
    return ('p', (lerp(a[1][0], b[1][0], f), lerp(a[1][1], b[1][1], f)), a[2])
def lerp_pose(a, b, f):
    return dict(hip=(lerp(a['hip'][0], b['hip'][0], f), lerp(a['hip'][1], b['hip'][1], f)),
                torso=lerp(a['torso'], b['torso'], f), neck=lerp(a['neck'], b['neck'], f),
                arms=[lerp_spec(x, y, f) for x, y in zip(a['arms'], b['arms'])],
                legs=[lerp_spec(x, y, f) for x, y in zip(a['legs'], b['legs'])])
def pose_at(keys, t):
    t = min(max(t, 0), 1)
    if t <= keys[0][0]: return keys[0][1]
    for (t0, p0), (t1, p1) in zip(keys, keys[1:]):
        if t <= t1: return lerp_pose(p0, p1, smooth((t-t0)/(t1-t0)) if t1 > t0 else 1)
    return keys[-1][1]

def P(hip, torso, neck, arms, legs): return dict(hip=hip, torso=torso, neck=neck, arms=arms, legs=legs)
