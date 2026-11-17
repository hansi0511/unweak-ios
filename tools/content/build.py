import json, sys
sys.path.insert(0, sys.argv[1])
from content import E, PL, G, A
repo = sys.argv[2]
strings = {}
def put(key, pair): strings[key] = pair
catalog = {"exercises": [], "plans": [], "goals": [], "achievements": []}
for e in E:
    put(f"exercise.{e['id']}.name", e['name'])
    for i, s in enumerate(e['steps'], 1): put(f"exercise.{e['id']}.step{i}", s)
    for i, s in enumerate(e['mistakes'], 1): put(f"exercise.{e['id']}.mistake{i}", s)
    d = {k: e[k] for k in ("id", "category", "level", "animation", "pose")}
    d["mistakeCount"] = len(e['mistakes'])
    if e['easier']: d["easier"] = e['easier']
    if e['harder']: d["harder"] = e['harder']
    catalog["exercises"].append(d)
for p in PL:
    put(f"plan.{p['id']}.name", p['name'])
    items = []
    for x in p['exercises']:
        d = {"exercise": x['exercise'], "sets": x['sets']}
        if x['reps'] is not None: d["reps"] = x['reps']
        if x['seconds'] is not None: d["seconds"] = x['seconds']
        d["rest"] = x['rest']; items.append(d)
    catalog["plans"].append({"id": p['id'], "category": p['category'], "level": p['level'], "pose": p['pose'], "isFree": p['isFree'], "exercises": items})
for g in G:
    put(f"goal.{g['id']}.name", g['name'])
    put(f"goal.{g['id']}.muscles", g['muscles'])
    put(f"goal.{g['id']}.benefit", g['benefit'])
    d = {"id": g['id'], "pose": g['pose'], "exercise": g['exercise'], "plans": g['plans'], "isFree": g['isFree']}
    if g.get('animation'): d["animation"] = g['animation']
    if g['stages']:
        for i, (name, _, muscles, benefit) in enumerate(g['stages'], 1):
            put(f"goal.{g['id']}.stage{i}", name)
            put(f"goal.{g['id']}.stage{i}.muscles", muscles)
            put(f"goal.{g['id']}.stage{i}.benefit", benefit)
        d["stageCount"] = len(g['stages'])
        d["stageAnimations"] = [s[1] for s in g['stages']]
    else:
        d["targetSeconds"] = g['targetSeconds']
    catalog["goals"].append(d)
for a in A:
    put(f"achievement.{a['id']}.label", a['label'])
    d = {"id": a['id'], "kind": a['kind'], "threshold": a['threshold']}
    if a['exercise']: d["exercise"] = a['exercise']
    catalog["achievements"].append(d)
open(f"{repo}/Unweak/Resources/Catalog.json", "w").write(json.dumps(catalog, ensure_ascii=False, indent=2) + "\n")
xc = {"sourceLanguage": "en", "strings": {}, "version": "1.0"}
for k in sorted(strings):
    en, de = strings[k]
    xc["strings"][k] = {"extractionState": "manual", "localizations": {
        "de": {"stringUnit": {"state": "translated", "value": de}},
        "en": {"stringUnit": {"state": "translated", "value": en}}}}
open(f"{repo}/Unweak/Resources/Catalog.xcstrings", "w").write(json.dumps(xc, ensure_ascii=False, indent=2, separators=(",", " : ")) + "\n")
# validation
ids = {e['id'] for e in E}
for e in E:
    for r in (e['easier'], e['harder']): assert r is None or r in ids, r
for p in PL:
    for x in p['exercises']: assert x['exercise'] in ids, x
    assert len({x['exercise'] for x in p['exercises']}) == len(p['exercises']), p['id']
plan_ids = {p['id'] for p in PL}
for g in G:
    assert g['exercise'] in ids, g
    assert g['plans'] and all(p in plan_ids for p in g['plans']), g
# Every skill-category plan belongs to at least one skill.
for p in PL:
    if p['category'] == "skill": assert any(p['id'] in g['plans'] for g in G), p['id']
# Free version: the 10 general workouts. Skills and their own workouts are Pro.
assert sum(p['isFree'] for p in PL) == 10, "exactly 10 free workouts"
for p in PL: assert p['isFree'] == (p['category'] != "skill"), p['id']
for g in G: assert not g['isFree'], g['id']
for a in A:
    assert a['kind'] in ("workouts", "reps", "seconds", "streak"), a
    assert (a['exercise'] is not None) == (a['kind'] in ("reps", "seconds")), a
    assert a['exercise'] is None or a['exercise'] in ids, a
assert len(A) == 12 and len({a['id'] for a in A}) == 12
# durations
for p in PL:
    tot = sum(x['sets'] * ((x['reps'] * 3 if x['reps'] is not None else x['seconds']) + x['rest']) for x in p['exercises'])
    print(p['id'], tot, "s ->", max(1, round(tot/60)), "min")
print(len(strings), "strings,", len(E), "exercises,", len(PL), "plans,", len(G), "goals,", len(A), "achievements")
