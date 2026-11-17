import sys, math
sys.path.insert(0, sys.argv[1])
from anims import *
from PIL import Image, ImageDraw
S = 3; cols = 8
names = sys.argv[3:] or list(ANIMS)
for name in names:
    A = ANIMS[name]; W, H = A['canvas']
    img = Image.new('RGB', (W*S*cols, H*S), (7, 9, 12)); d = ImageDraw.Draw(img)
    for i in range(cols):
        t = i/cols; f = solve(pose_at(A['keys'], t)); ox = i*W*S
        L = lambda a, b, c, w: d.line([(ox+a[0]*S, a[1]*S), (ox+b[0]*S, b[1]*S)], fill=c, width=int(w*S))
        d.rectangle([ox, 0, ox+W*S-1, H*S-1], outline=(30, 42, 51))
        for a, b in A['app']: L(a, b, (234, 242, 245), 3)
        far = (110, 130, 60); near = (198, 242, 78)
        L(f['hip'], f['arms'][1][0], far, 0) if False else None
        for (m, e), c in ((f['arms'][1], far), (f['legs'][1], far)):
            L(f['shoulder'] if (m, e) == f['arms'][1] else f['hip'], m, c, 4.5); L(m, e, c, 4.5)
        L(f['hip'], f['shoulder'], near, 5)
        for (m, e), c, root in ((f['legs'][0], near, f['hip']), (f['arms'][0], near, f['shoulder'])):
            L(root, m, c, 4.5); L(m, e, c, 4.5)
        hx, hy = f['head']; r = 8.5*S
        d.ellipse([ox+hx*S-r, hy*S-r, ox+hx*S+r, hy*S+r], fill=(11, 16, 21), outline=near, width=int(4*S))
        d.text((ox+6, 6), f"{name} t={t:.2f}", fill=(159, 176, 188))
    img.save(f"{sys.argv[2]}/{name}.png")
print("rendered", names)
