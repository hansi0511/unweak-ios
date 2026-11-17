import math, sys
from body import *

def ang(a, b): return math.degrees(math.atan2(b[1]-a[1], b[0]-a[0]))
def along(a, deg, l): return pt(a, deg, l)
def circ(c1, r1, c2, r2, bend):  # point at r1 from c1 and r2 from c2
    return joint(c1, c2, r1, r2, bend)
FLOOR = 157
floor = lambda x0=10, x1=190: ((x0, FLOOR+1.5), (x1, FLOOR+1.5))
ANIMS = {}

def body_line(foot, shoulder):
    a = ang(foot, shoulder); hip = along(foot, a, THIGH+SHIN); return hip, a

# --- push-up
foot = (50, FLOOR); hand = (131, FLOOR)
def pushup_pose(shoulder_y, neck_up):
    dy = FLOOR - shoulder_y; dx = math.sqrt(89**2 - dy**2)
    sh = (foot[0]+dx, shoulder_y); hip, a = body_line(foot, sh)
    return P(hip, a, a+neck_up, [('p', hand, 1), ('p', (hand[0]+2, hand[1]), 1)], [('p', foot, 1), ('p', (foot[0]+2, foot[1]), 1)])
up, down = pushup_pose(116, -8), pushup_pose(141, -4)
ANIMS['pushUp'] = dict(canvas=(200,170), dur=3, end=0.0, app=[floor()], keys=[(0,up),(0.1,up),(0.45,down),(0.55,down),(0.9,up),(1,up)])

# --- knee push-up
knee = (80, FLOOR-1); kfoot = (60.5, 141)
def kpush(shoulder_y):
    dy = knee[1]-shoulder_y; dx = math.sqrt(66**2-dy**2); sh = (knee[0]+dx, shoulder_y)
    a = ang(knee, sh); hip = along(knee, a, THIGH)
    return P(hip, a, a-8, [('p', (132, FLOOR), 1), ('p', (134, FLOOR), 1)], [('p', kfoot, -1), ('p', (kfoot[0]+2, kfoot[1]), -1)])
up, down = kpush(116), kpush(141)
ANIMS['kneePushUp'] = dict(canvas=(200,170), dur=3, end=0.0, app=[floor()], keys=[(0,up),(0.1,up),(0.45,down),(0.55,down),(0.9,up),(1,up)])

# --- pike push-up
phand = (175, FLOOR); pfoot = (82, FLOOR)
def pike(hip, sh, bend, neck=-5):
    return P(hip, ang(hip, sh), ang(hip, sh)+neck, [('p', phand, bend), ('p', (phand[0]+2, phand[1]), bend)], [('p', pfoot, 1), ('p', (pfoot[0]+2, pfoot[1]), 1)])
uhip = (102, 114.5); ush = along(uhip, 35, TORSO)
dsh = (150, 138); dhip = circ(pfoot, THIGH + SHIN, dsh, TORSO, -1)  # straight legs: hip stays 47 from the feet
up, down = pike(uhip, ush, -1), pike(dhip, dsh, -1, -10)
ANIMS['pikePushUp'] = dict(canvas=(200,170), dur=3, end=0.0, app=[floor()], keys=[(0,up),(0.1,up),(0.45,down),(0.55,down),(0.9,up),(1,up)])

# --- dips
dh = (100, 95)
def dip(sh, hip):
    return P(hip, ang(hip, sh), -80, [('p', dh, 1), ('p', (dh[0]+2, dh[1]), 1)], [('a', 100, 155), ('a', 98, 150)])
up, down = dip((100, 52.5), (101, 94.5)), dip((107, 74), (95, 114))
ANIMS['dip'] = dict(canvas=(200,170), dur=3, end=0.0, app=[((78,95),(124,95)), floor()], keys=[(0,up),(0.1,up),(0.45,down),(0.55,down),(0.9,up),(1,up)])

# --- australian row
rh = (150, 95); rfoot = (63, FLOOR)
def row(sh):
    hip, a = body_line(rfoot, sh)
    return P(hip, a, a-6, [('p', rh, -1), ('p', (rh[0]+2, rh[1]), -1)], [('p', rfoot, 1), ('p', (rfoot[0]+2, rfoot[1]), 1)])
down_sh = circ(rfoot, 89, rh, 42.5, 1)
up_sh = (rfoot[0] + math.sqrt(89**2-47**2), 110)
up, down = row(up_sh), row(down_sh)
ANIMS['row'] = dict(canvas=(200,170), dur=3, end=0.45, app=[((135,95),(165,95)), floor()], keys=[(0,down),(0.1,down),(0.45,up),(0.55,up),(0.9,down),(1,down)])

# --- squat
sf1, sf2 = (102, FLOOR), (98, FLOOR)
def squat(hip, torso, arm):
    return P(hip, torso, torso, [('a', arm, arm+2), ('a', arm+4, arm+6)], [('p', sf1, -1), ('p', sf2, -1)])
up, down = squat((99, 110), -90, 8), squat((74, 131), -58, -4)
ANIMS['squat'] = dict(canvas=(200,170), dur=3, end=0.0, app=[floor()], keys=[(0,up),(0.1,up),(0.45,down),(0.55,down),(0.9,up),(1,up)])

# --- lunge
ff, bf = (130, FLOOR), (64, FLOOR)
def lunge(hip):
    return P(hip, -90, -90, [('a', 95, 92), ('a', 85, 88)], [('p', ff, -1), ('p', bf, -1)])
up, down = lunge((97, 124)), lunge((89, 139))
ANIMS['lunge'] = dict(canvas=(200,170), dur=3, end=0.0, app=[floor()], keys=[(0,up),(0.1,up),(0.45,down),(0.55,down),(0.9,up),(1,up)])

# --- pistol squat
pf = (100, FLOOR)
def pistol(hip, torso, free, arm):
    return P(hip, torso, torso, [('a', arm, arm+2), ('a', arm+4, arm+6)], [('p', pf, -1), ('a', free[0], free[1])])
up, down = pistol((99, 110), -88, (70, 92), 10), pistol((82, 136), -62, (-6, -4), -6)
ANIMS['pistolSquat'] = dict(canvas=(200,170), dur=3.5, end=0.0, app=[floor()], keys=[(0,up),(0.1,up),(0.45,down),(0.55,down),(0.9,up),(1,up)])

# --- forearm plank (breathing)
plf = (54, FLOOR); plsh = (140, 135); phd = (161, FLOOR)
def plank(lift):
    sh = (plsh[0], plsh[1]-lift*0.3); hip, a = body_line(plf, sh)
    hip = (hip[0], hip[1]-lift); a = ang(hip, sh)
    return P(hip, a, a-6, [('p', phd, 1), ('p', (phd[0]+2, phd[1]), 1)], [('p', plf, 1), ('p', (plf[0]+2, plf[1]), 1)])
rest, breathe = plank(0), plank(2.5)
ANIMS['plank'] = dict(canvas=(200,170), dur=4, end=0.0, app=[floor()], keys=[(0,rest),(0.5,breathe),(1,rest)])

# --- hanging knee raise
kh = (100, 20)
def kraise(l1, l2):
    return P((100, 105), -90, -90, [('p', kh, 1), ('p', (kh[0]+2, kh[1]), 1)], [('a', l1[0], l1[1]), ('a', l2[0], l2[1])])
down, up = kraise((88, 92), (92, 90)), kraise((-6, 88), (-2, 92))
ANIMS['kneeRaise'] = dict(canvas=(200,170), dur=3, end=0.5, app=[((60,20),(140,20))], keys=[(0,down),(0.1,down),(0.45,up),(0.6,up),(0.95,down),(1,down)])

# --- L-sit on parallettes
lh = (100, 128)
def lsit(leg, hip_y):
    return P((101, hip_y), -90, -90, [('p', lh, 1), ('p', (lh[0]+2, lh[1]), 1)], [('a', leg, leg), ('a', leg+2, leg+2)])
# Legs stay at least horizontal: from horizontal, raised slightly above it, held, back.
level, raised = lsit(0, 127), lsit(-12, 127)
ANIMS['lSit'] = dict(canvas=(200,170), dur=4, end=0.5, app=[((84,128),(118,128)), floor()], keys=[(0,level),(0.3,raised),(0.7,raised),(1,level)])

# --- handstand (balancing)
hh = (100, FLOOR)
def hstand(dx, tilt):
    return P((100+dx, 71.5), 90+tilt, 90, [('p', hh, 1), ('p', (hh[0]+2, hh[1]), 1)], [('a', -90+tilt*1.2, -90+tilt*1.4), ('a', -90+tilt*1.2, -90+tilt*1.4)])
c, l, r = hstand(0, 0), hstand(-2.5, -3), hstand(2.5, 3)
ANIMS['handstand'] = dict(canvas=(200,170), dur=4, end=0.0, app=[floor()], keys=[(0,c),(0.25,l),(0.75,r),(1,c)])

# --- muscle-up
mh = (100, 100)
def mu(sh, hip, legs):
    return P(hip, ang(hip, sh), ang(hip, sh) + (0 if sh[1] > 100 else 0), [('p', mh, 1), ('p', (mh[0]+2, mh[1]), 1)], [('a', *legs), ('a', legs[0]+4, legs[1]+4)])
hang = mu((100, 142.5), (100, 184.5), (75, 120))
pull = mu((95, 113), (88, 153), (60, 85))
# The shoulder travels in front of the bar (x > 100) instead of through the hands.
front = mu((114, 106), (96, 144), (65, 95))
trans = mu((116, 86), (95, 122), (70, 100))
supp = mu((102, 57.5), (97, 99.2), (70, 95))
ANIMS['muscleUp'] = dict(canvas=(200,240), dur=4.5, end=0.75, app=[((60,100),(140,100))],
    keys=[(0,hang),(0.1,hang),(0.3,pull),(0.4,front),(0.5,trans),(0.66,supp),(0.82,supp),(0.9,trans),(0.95,front),(1,hang)])
