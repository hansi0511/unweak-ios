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

# ===== Skill stages =====

# --- elevated pike push-up: feet on a box, hips higher, more weight on the hands
ebox = 132; efoot = (72, ebox); ehand = (142, FLOOR)
def epike(sh, bend, neck):
    hip = circ(efoot, THIGH + SHIN, sh, TORSO, -1)
    return P(hip, ang(hip, sh), ang(hip, sh)+neck, [('p', ehand, bend), ('p', (ehand[0]+2, ehand[1]), bend)], [('p', efoot, 1), ('p', (efoot[0]+2, efoot[1]), 1)])
up, down = epike((133, 118), -1, -5), epike((137, 138), -1, -12)
ebox_lines = [((52, ebox), (88, ebox)), ((52, ebox), (52, FLOOR+1.5)), ((88, ebox), (88, FLOOR+1.5))]
ANIMS['elevatedPikePushUp'] = dict(canvas=(200,170), dur=3, end=0.0, app=ebox_lines + [floor()], keys=[(0,up),(0.1,up),(0.45,down),(0.55,down),(0.9,up),(1,up)])

# --- handstand against the wall (back to the wall, heels on it)
WALL = 122
wall = ((WALL, 12), (WALL, FLOOR+1.5))
whand = (110, FLOOR)
def wstand(sh, neck=90, bend=1):
    hip = (sh[0]+5, sh[1]-42+0.3)
    hip = along(sh, ang(sh, hip), TORSO)
    dx = WALL-4-hip[0]; feet = (WALL-4, hip[1]-math.sqrt((THIGH+SHIN-0.3)**2 - dx*dx))
    return P(hip, ang(hip, sh), neck, [('p', whand, bend), ('p', (whand[0]+2, whand[1]), bend)], [('p', feet, -1), ('p', (feet[0], feet[1]+2), -1)])
rest, breathe = wstand((106, 114.5)), wstand((106, 113.5))
ANIMS['wallHandstand'] = dict(canvas=(200,170), dur=4, end=0.0, app=[wall, floor()], keys=[(0,rest),(0.5,breathe),(1,rest)])

# --- handstand push-up against the wall: half and full range
top, half, full = wstand((106, 114.5)), wstand((103, 124), 95), wstand((99, 133), 100)
ANIMS['halfWallHandstandPushUp'] = dict(canvas=(200,170), dur=3, end=0.0, app=[wall, floor()], keys=[(0,top),(0.1,top),(0.45,half),(0.55,half),(0.9,top),(1,top)])
ANIMS['wallHandstandPushUp'] = dict(canvas=(200,170), dur=3.5, end=0.0, app=[wall, floor()], keys=[(0,top),(0.1,top),(0.45,full),(0.55,full),(0.9,top),(1,top)])

# --- negative muscle-up: start in support, lower slowly to the hang, climb back quickly
ANIMS['negativeMuscleUp'] = dict(canvas=(200,240), dur=5, end=0.0, app=[((60,100),(140,100))],
    keys=[(0,supp),(0.12,supp),(0.3,trans),(0.45,front),(0.65,pull),(0.82,hang),(0.86,hang),(0.91,pull),(0.94,front),(0.97,trans),(1,supp)])

# --- box pistol: sit back onto a box on one leg and stand up again
bbox = 126
bbox_lines = [((50, bbox), (84, bbox)), ((50, bbox), (50, FLOOR+1.5)), ((84, bbox), (84, FLOOR+1.5))]
up, down = pistol((99, 110), -88, (70, 92), 10), pistol((76, bbox-3), -68, (-8, -6), -2)
ANIMS['boxPistol'] = dict(canvas=(200,170), dur=3.5, end=0.0, app=bbox_lines + [floor()], keys=[(0,up),(0.1,up),(0.45,down),(0.55,down),(0.9,up),(1,up)])

# --- assisted pistol: hands on a pole in front for balance
pole = 140
def apistol(hip, torso, free, grip):
    return P(hip, torso, torso, [('p', (pole-1, grip), 1), ('p', (pole-1, grip+3), 1)], [('p', pf, -1), ('a', free[0], free[1])])
up, down = apistol((99, 110), -88, (70, 92), 84), apistol((82, 136), -62, (-6, -4), 84)
ANIMS['assistedPistol'] = dict(canvas=(200,170), dur=3.5, end=0.0, app=[((pole, 40), (pole, FLOOR+1.5)), floor()], keys=[(0,up),(0.1,up),(0.45,down),(0.55,down),(0.9,up),(1,up)])

# ===== Catalog additions =====

# --- incline push-up: hands on a box, feet on the floor
ibox = 136; ihand = (148, ibox); ifoot = (76, FLOOR)
def incline(sh, neck):
    hip, a = body_line(ifoot, sh)
    return P(hip, a, a+neck, [('p', ihand, 1), ('p', (ihand[0]+2, ihand[1]), 1)], [('p', ifoot, 1), ('p', (ifoot[0]+2, ifoot[1]), 1)])
up, down = incline(circ(ifoot, 89, ihand, 41.5, -1), -10), incline(circ(ifoot, 89, ihand, 24, -1), -6)
ibox_lines = [((134, ibox), (170, ibox)), ((134, ibox), (134, FLOOR+1.5)), ((170, ibox), (170, FLOOR+1.5))]
ANIMS['inclinePushUp'] = dict(canvas=(200,170), dur=3, end=0.0, app=ibox_lines + [floor()], keys=[(0,up),(0.1,up),(0.45,down),(0.55,down),(0.9,up),(1,up)])

# --- decline push-up: feet on a box, hands on the floor
dbox = 132; dfoot = (52, dbox); dhand = (140, FLOOR)
def decline(sh, neck):
    hip, a = body_line(dfoot, sh)
    return P(hip, a, a+neck, [('p', dhand, 1), ('p', (dhand[0]+2, dhand[1]), 1)], [('p', dfoot, 1), ('p', (dfoot[0]+2, dfoot[1]), 1)])
up, down = decline(circ(dfoot, 89, dhand, 41.5, -1), -6), decline(circ(dfoot, 89, dhand, 24, -1), -2)
dbox_lines = [((34, dbox), (70, dbox)), ((34, dbox), (34, FLOOR+1.5)), ((70, dbox), (70, FLOOR+1.5))]
ANIMS['declinePushUp'] = dict(canvas=(200,170), dur=3, end=0.0, app=dbox_lines + [floor()], keys=[(0,up),(0.1,up),(0.45,down),(0.55,down),(0.9,up),(1,up)])

# --- diamond push-up: hands close together under the chest, elbows along the body
dmfoot = (50, FLOOR); dmhand = (128, FLOOR)
def diamond(sh, neck):
    hip, a = body_line(dmfoot, sh)
    return P(hip, a, a+neck, [('p', dmhand, 1), ('p', (dmhand[0]+1, dmhand[1]), 1)], [('p', dmfoot, 1), ('p', (dmfoot[0]+2, dmfoot[1]), 1)])
up, down = diamond(circ(dmfoot, 89, dmhand, 41.5, -1), -8), diamond(circ(dmfoot, 89, dmhand, 22, -1), -4)
ANIMS['diamondPushUp'] = dict(canvas=(200,170), dur=3, end=0.0, app=[floor()], keys=[(0,up),(0.1,up),(0.45,down),(0.55,down),(0.9,up),(1,up)])

# --- bench dip: hands on a box behind, heels on the floor
bdbox = 120; bdhand = (84, bdbox); bdfoot = (119, FLOOR)
def bdip(hip, sh):
    return P(hip, ang(hip, sh), -84, [('p', bdhand, -1), ('p', (bdhand[0]-2, bdhand[1]), -1)], [('p', bdfoot, -1), ('p', (bdfoot[0]+2, bdfoot[1]), -1)])
up, down = bdip((93, 120), (91, 78)), bdip((96, 140), (93, 98))
bd_lines = [((50, bdbox), (86, bdbox)), ((50, bdbox), (50, FLOOR+1.5)), ((86, bdbox), (86, FLOOR+1.5))]
ANIMS['benchDip'] = dict(canvas=(200,170), dur=3, end=0.0, app=bd_lines + [floor()], keys=[(0,up),(0.1,up),(0.45,down),(0.55,down),(0.9,up),(1,up)])

# --- dead hang: straight arms on the bar, breathing calmly
def hangp(hip_y, legs=((88, 92), (92, 90))):
    return P((100, hip_y), -90, -90, [('p', kh, 1), ('p', (kh[0]+2, kh[1]), 1)], [('a', *legs[0]), ('a', *legs[1])])
rest, breathe = hangp(105.5), hangp(104.5)
ANIMS['deadHang'] = dict(canvas=(200,170), dur=4, end=0.0, app=[((60,20),(140,20))], keys=[(0,rest),(0.5,breathe),(1,rest)])

# --- scapula pull-up: arms stay straight, the shoulders pull the body up a little
low, high = hangp(105.5), hangp(99)
ANIMS['scapulaPullUp'] = dict(canvas=(200,170), dur=3, end=0.5, app=[((60,20),(140,20))], keys=[(0,low),(0.15,low),(0.45,high),(0.6,high),(0.9,low),(1,low)])

# --- hanging leg raise: straight legs up to horizontal
down, up = hangp(105.5), hangp(105.5, ((2, 2), (0, 0)))
ANIMS['hangingLegRaise'] = dict(canvas=(200,170), dur=3.5, end=0.5, app=[((60,20),(140,20))], keys=[(0,down),(0.1,down),(0.45,up),(0.6,up),(0.95,down),(1,down)])

# --- tuck L-sit: like the L-sit, knees bent towards the chest
def tsit(th, sh_, hip_y):
    return P((101, hip_y), -90, -90, [('p', lh, 1), ('p', (lh[0]+2, lh[1]), 1)], [('a', th, sh_), ('a', th+2, sh_+2)])
level, raised = tsit(-40, 95, 127), tsit(-52, 85, 126)
ANIMS['tuckLSit'] = dict(canvas=(200,170), dur=4, end=0.5, app=[((84,128),(118,128)), floor()], keys=[(0,level),(0.3,raised),(0.7,raised),(1,level)])

# --- hollow hold: on the back, shoulders and straight legs just off the floor, arms overhead
def hollow(rock):
    hip = (112, 149)
    return P(hip, 192 - rock, 196 - rock, [('a', 194 - rock, 194 - rock), ('a', 196 - rock, 196 - rock)], [('a', -12 + rock, -12 + rock), ('a', -10 + rock, -10 + rock)])
rest, breathe = hollow(0), hollow(2)
ANIMS['hollowHold'] = dict(canvas=(200,170), dur=4, end=0.0, app=[floor()], keys=[(0,rest),(0.5,breathe),(1,rest)])

# --- mountain climber: high plank, one knee drives towards the chest, then the other
mcfoot = (50, FLOOR); mchand = (131, FLOOR); mcsh = (128, 116)
mchip, mca = body_line(mcfoot, mcsh)
def climber(f1, f2):
    return P(mchip, mca, mca-8, [('p', mchand, 1), ('p', (mchand[0]+2, mchand[1]), 1)], [('p', f1, 1), ('p', f2, 1)])
back1, back2 = (50, FLOOR), (52, FLOOR)
fwd = (98, 150)
a1, a2 = climber(fwd, back2), climber(back1, (fwd[0]+2, fwd[1]))
ANIMS['mountainClimber'] = dict(canvas=(200,170), dur=2, end=0.0, app=[floor()], keys=[(0,climber(back1, back2)),(0.2,a1),(0.4,climber(back1, back2)),(0.6,a2),(0.8,climber(back1, back2)),(1,climber(back1, back2))])

# --- glute bridge: on the back, feet flat, hips lift into a straight line
gsh = (66, 149); gfoot = (128, FLOOR)
def bridge(deg):
    hip = along(gsh, deg, TORSO)
    return P(hip, ang(hip, gsh), 180, [('a', 4, 2), ('a', 6, 4)], [('p', gfoot, -1), ('p', (gfoot[0]+2, gfoot[1]), -1)])
down, up = bridge(-2), bridge(-28)
ANIMS['gluteBridge'] = dict(canvas=(200,170), dur=3, end=0.5, app=[floor()], keys=[(0,down),(0.1,down),(0.45,up),(0.6,up),(0.95,down),(1,down)])

# --- wall sit: back on the wall, thighs level, held while breathing
WS = 60; wsfoot = (92, FLOOR)
def wallsit(dy):
    hip = (WS+8, FLOOR-23-dy)
    return P(hip, -90, -90, [('a', 70, 85), ('a', 72, 88)], [('p', wsfoot, -1), ('p', (wsfoot[0]+2, wsfoot[1]), -1)])
rest, breathe = wallsit(0), wallsit(1)
ANIMS['wallSit'] = dict(canvas=(200,170), dur=4, end=0.0, app=[((WS, 30), (WS, FLOOR+1.5)), floor()], keys=[(0,rest),(0.5,breathe),(1,rest)])

# --- Bulgarian split squat: rear foot on a box, front foot on the floor
bsbox = 130; bsback = (60, bsbox); bsfront = (126, FLOOR)
def split(hip, torso):
    return P(hip, torso, torso, [('a', 95, 92), ('a', 85, 88)], [('p', bsfront, -1), ('p', bsback, -1)])
up, down = split((105, 116), -88), split((98, 136), -80)
bs_lines = [((40, bsbox), (72, bsbox)), ((40, bsbox), (40, FLOOR+1.5)), ((72, bsbox), (72, FLOOR+1.5))]
ANIMS['bulgarianSplitSquat'] = dict(canvas=(200,170), dur=3.5, end=0.0, app=bs_lines + [floor()], keys=[(0,up),(0.1,up),(0.45,down),(0.55,down),(0.9,up),(1,up)])

# --- jump squat: down into the squat, jump off the floor, land softly
def jsquat(hip, torso, arm, lift):
    return P(hip, torso, torso, [('a', arm, arm+2), ('a', arm+4, arm+6)], [('p', (102, FLOOR-lift), -1), ('p', (98, FLOOR-lift), -1)])
stand, low, air = jsquat((99, 110), -90, 8, 0), jsquat((74, 131), -58, -4, 0), jsquat((100, 92), -90, -100, 18)
ANIMS['jumpSquat'] = dict(canvas=(200,170), dur=2.5, end=0.0, app=[floor()], keys=[(0,stand),(0.1,stand),(0.4,low),(0.55,air),(0.65,air),(0.8,low),(0.95,stand),(1,stand)])
