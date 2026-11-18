# Single source for Catalog.json and Catalog.xcstrings (sample content, see docs/SPEC.md "Inhalte").
# Exercise: id, category, level, animation, pose, easier, harder, (en, de) name, 3 steps, mistakes
E = []
def ex(id, cat, lvl, anim, pose, easier, harder, name, steps, mistakes):
    E.append(dict(id=id, category=cat, level=lvl, animation=anim, pose=pose, easier=easier, harder=harder,
                  name=name, steps=steps, mistakes=mistakes))

ex("kneePushUp", "push", "beginner", "kneePushUp", "pushUp", None, "pushUp",
   ("Knee push-up", "Knie-Liegestütz"),
   [("Kneel and place your hands slightly wider than shoulder width.", "Knie dich hin und setz die Hände etwas breiter als schulterbreit auf."),
    ("Keep a straight line from knees to head and tighten your core.", "Halte Knie, Hüfte und Kopf in einer Linie und spann den Bauch an."),
    ("Lower your chest towards the floor and push back up.", "Senk die Brust zum Boden und drück dich wieder hoch.")],
   [("Hips sagging or sticking up.", "Die Hüfte hängt durch oder ragt nach oben."),
    ("Elbows flaring straight out to the sides.", "Die Ellbogen stehen weit zur Seite ab.")])
ex("pushUp", "push", "beginner", "pushUp", "pushUp", "kneePushUp", "pikePushUp",
   ("Push-up", "Liegestütz"),
   [("Start in a high plank with your hands under your shoulders.", "Beginne im hohen Stütz, die Hände unter den Schultern."),
    ("Lower your body as one unit until your chest almost touches the floor.", "Senk den Körper als Einheit, bis die Brust fast den Boden berührt."),
    ("Press back up until your arms are straight.", "Drück dich hoch, bis die Arme gestreckt sind.")],
   [("Hips sagging towards the floor.", "Die Hüfte sackt zum Boden durch."),
    ("Only going halfway down.", "Nur halb nach unten gehen.")])
ex("pikePushUp", "push", "intermediate", "pikePushUp", "pushUp", "pushUp", "wallHandstand",
   ("Pike push-up", "Pike-Liegestütz"),
   [("Walk your feet in until your hips are high and your body forms an upside-down V.", "Lauf mit den Füßen heran, bis die Hüfte hoch ist und der Körper ein umgekehrtes V bildet."),
    ("Bend your elbows and lower the top of your head towards the floor in front of your hands.", "Beug die Ellbogen und senk den Kopf vor den Händen Richtung Boden."),
    ("Push back up to straight arms, keeping your hips high.", "Drück dich zurück zu gestreckten Armen, die Hüfte bleibt oben.")],
   [("Letting the hips drop into a normal push-up.", "Die Hüfte sinkt ab und es wird ein normaler Liegestütz."),
    ("Lowering the face instead of the top of the head.", "Das Gesicht statt des Scheitels absenken.")])
ex("dip", "push", "intermediate", "dip", "muscleUp", "pushUp", "muscleUp",
   ("Dip", "Dip"),
   [("Support yourself on parallel bars with straight arms and shoulders down.", "Stütz dich mit gestreckten Armen auf den Barren, die Schultern unten."),
    ("Bend your elbows backwards and lower until your upper arms are about parallel to the floor.", "Beug die Ellbogen nach hinten und senk dich ab, bis die Oberarme etwa waagrecht sind."),
    ("Press back up to straight arms.", "Drück dich zurück in den gestreckten Stütz.")],
   [("Shrugging the shoulders up to the ears.", "Die Schultern zu den Ohren ziehen."),
    ("Going deeper than your shoulders allow without pain.", "Tiefer gehen, als die Schultern schmerzfrei mitmachen.")])
ex("row", "pull", "beginner", "row", "pullUp", None, "negativePullUp",
   ("Australian row", "Australian Row"),
   [("Hang under a low bar with straight arms, heels on the floor and body straight.", "Häng unter einer niedrigen Stange, Arme gestreckt, Fersen am Boden, Körper gerade."),
    ("Pull your chest to the bar while squeezing your shoulder blades together.", "Zieh die Brust zur Stange und zieh dabei die Schulterblätter zusammen."),
    ("Lower yourself under control until your arms are straight again.", "Lass dich kontrolliert ab, bis die Arme wieder gestreckt sind.")],
   [("Hips dropping during the pull.", "Die Hüfte sinkt beim Ziehen ab."),
    ("Pulling with the neck instead of the back.", "Mit dem Kopf nach vorn ziehen statt mit dem Rücken.")])
ex("negativePullUp", "pull", "beginner", "negativePullUp", "pullUp", "row", "pullUp",
   ("Negative pull-up", "Negativer Klimmzug"),
   [("Jump or step up so your chin is above the bar.", "Spring oder steig hoch, bis das Kinn über der Stange ist."),
    ("Lower yourself as slowly as you can, about three to five seconds.", "Lass dich so langsam wie möglich ab, etwa drei bis fünf Sekunden."),
    ("Reach a full hang, then step back up for the next repetition.", "Lass dich bis in den vollen Hang ab und steig für die nächste Wiederholung wieder hoch.")],
   [("Dropping quickly through the bottom half.", "In der unteren Hälfte schnell durchfallen."),
    ("Letting the shoulders go loose at the bottom.", "Unten die Schultern locker hängen lassen.")])
ex("pullUp", "pull", "intermediate", "pullUp", "pullUp", "negativePullUp", "muscleUp",
   ("Pull-up", "Klimmzug"),
   [("Hang from the bar with hands slightly wider than shoulder width.", "Häng an der Stange, die Hände etwas breiter als schulterbreit."),
    ("Pull your shoulders down and pull up until your chin is above the bar.", "Zieh die Schultern nach unten und zieh dich hoch, bis das Kinn über der Stange ist."),
    ("Lower yourself under control to a full hang.", "Lass dich kontrolliert bis in den vollen Hang ab.")],
   [("Swinging the legs for momentum.", "Mit den Beinen Schwung holen."),
    ("Stopping short of a full hang.", "Nicht bis in den vollen Hang ablassen.")])
ex("squat", "legs", "beginner", "squat", "squat", None, "lunge",
   ("Squat", "Kniebeuge"),
   [("Stand with feet shoulder-width apart, toes slightly turned out.", "Stell dich schulterbreit hin, die Fußspitzen leicht nach außen."),
    ("Push your hips back and bend your knees until your thighs are at least parallel to the floor.", "Schieb die Hüfte nach hinten und beug die Knie, bis die Oberschenkel mindestens waagrecht sind."),
    ("Drive through your whole foot to stand back up.", "Drück dich über den ganzen Fuß wieder nach oben.")],
   [("Heels lifting off the floor.", "Die Fersen heben vom Boden ab."),
    ("Knees caving inwards.", "Die Knie knicken nach innen.")])
ex("lunge", "legs", "beginner", "lunge", "squat", "squat", "pistolSquat",
   ("Lunge", "Ausfallschritt"),
   [("Take a long step forward and keep your upper body upright.", "Mach einen großen Schritt nach vorn und halte den Oberkörper aufrecht."),
    ("Lower your back knee until it almost touches the floor.", "Senk das hintere Knie, bis es fast den Boden berührt."),
    ("Push through your front heel to come back up.", "Drück dich über die vordere Ferse wieder hoch.")],
   [("Front knee collapsing inwards.", "Das vordere Knie knickt nach innen."),
    ("Leaning far forward with the upper body.", "Mit dem Oberkörper weit nach vorn kippen.")])
ex("pistolSquat", "legs", "advanced", "pistolSquat", "pistolSquat", "lunge", None,
   ("Pistol squat", "Pistol Squat"),
   [("Stand on one leg and hold the other leg straight out in front of you.", "Stell dich auf ein Bein und streck das andere gerade nach vorn."),
    ("Sit down slowly on the standing leg, arms reaching forward for balance.", "Setz dich langsam auf dem Standbein ab, die Arme nach vorn als Gegengewicht."),
    ("Stand back up without letting the free foot touch the floor.", "Steh wieder auf, ohne dass der freie Fuß den Boden berührt.")],
   [("Heel of the standing foot lifting.", "Die Ferse des Standbeins hebt ab."),
    ("Dropping into the bottom without control.", "Unkontrolliert nach unten fallen.")])
ex("plank", "core", "beginner", "plank", "plank", None, "lSit",
   ("Plank", "Plank"),
   [("Rest on your forearms with elbows under your shoulders.", "Stütz dich auf die Unterarme, die Ellbogen unter den Schultern."),
    ("Lift your hips so your body forms a straight line from head to heels.", "Heb die Hüfte, bis der Körper von Kopf bis Ferse eine Linie bildet."),
    ("Tighten your core and glutes and breathe calmly.", "Spann Bauch und Gesäß an und atme ruhig weiter.")],
   [("Hips sagging or piking up.", "Die Hüfte hängt durch oder ragt nach oben."),
    ("Holding your breath.", "Die Luft anhalten.")])
ex("kneeRaise", "core", "beginner", "kneeRaise", "lSit", "plank", "lSit",
   ("Hanging knee raise", "Hängendes Knieheben"),
   [("Hang from the bar with straight arms and active shoulders.", "Häng mit gestreckten Armen und aktiven Schultern an der Stange."),
    ("Raise your knees until your thighs are at least horizontal.", "Zieh die Knie hoch, bis die Oberschenkel mindestens waagrecht sind."),
    ("Lower your legs slowly without swinging.", "Senk die Beine langsam ab, ohne zu schwingen.")],
   [("Swinging back and forth.", "Vor und zurück schwingen."),
    ("Only lifting the feet, not the knees.", "Nur die Füße statt der Knie anheben.")])
ex("lSit", "core", "intermediate", "lSit", "lSit", "kneeRaise", None,
   ("L-sit", "L-Sit"),
   [("Place your hands on parallettes or the floor next to your hips.", "Setz die Hände neben der Hüfte auf Parallettes oder den Boden."),
    ("Press down, lock your elbows and lift your hips off the ground.", "Drück dich nach unten weg, streck die Ellbogen durch und heb die Hüfte an."),
    ("Raise your straight legs until they are parallel to the floor and hold.", "Heb die gestreckten Beine bis zur Waagrechten und halte die Position.")],
   [("Bent knees.", "Gebeugte Knie."),
    ("Shoulders shrugged up.", "Hochgezogene Schultern.")])
ex("wallHandstand", "skill", "beginner", "handstand", "handstand", "pikePushUp", None,
   ("Wall handstand", "Handstand an der Wand"),
   [("Place your hands shoulder-width apart about a hand's length from the wall.", "Setz die Hände schulterbreit etwa eine Handlänge vor der Wand auf."),
    ("Kick up one leg after the other until your heels rest against the wall.", "Schwing ein Bein nach dem anderen hoch, bis die Fersen an der Wand liegen."),
    ("Push the floor away, squeeze your legs together and look at your hands.", "Drück den Boden weg, schließ die Beine und schau zu deinen Händen.")],
   [("Strong arch in the lower back.", "Starkes Hohlkreuz."),
    ("Bent arms.", "Gebeugte Arme.")])
ex("tuckFrontLever", "skill", "advanced", "tuckFrontLever", "frontLever", "kneeRaise", None,
   ("Tuck front lever", "Tuck Front Lever"),
   [("Hang from the bar and pull your knees tightly to your chest.", "Häng an der Stange und zieh die Knie eng an die Brust."),
    ("Press the bar down with straight arms until your back is horizontal.", "Drück die Stange mit gestreckten Armen nach unten, bis der Rücken waagrecht ist."),
    ("Hold the position with your hips level with your shoulders.", "Halte die Position, die Hüfte auf Höhe der Schultern.")],
   [("Bending the arms.", "Die Arme beugen."),
    ("Hips dropping below shoulder height.", "Die Hüfte sinkt unter Schulterhöhe.")])
ex("muscleUp", "skill", "advanced", "muscleUp", "muscleUp", "pullUp", None,
   ("Muscle-up", "Muscle-up"),
   [("Hang with a slightly narrower grip and start with a strong, explosive pull.", "Häng mit etwas engerem Griff und beginne mit einem kräftigen, explosiven Zug."),
    ("As your chest reaches the bar, lean forward and turn your wrists over the bar.", "Sobald die Brust an der Stange ist, lehn dich nach vorn und dreh die Handgelenke über die Stange."),
    ("Press up into a straight-arm support above the bar.", "Drück dich in den gestreckten Stütz über der Stange.")],
   [("Pulling too slowly to get over the bar.", "Zu langsam ziehen, um über die Stange zu kommen."),
    ("Getting one arm over before the other.", "Einen Arm vor dem anderen über die Stange bringen.")])

# Plans: id, name, category, level, pose, free, [(exercise, sets, reps|None, seconds|None, rest)]
PL = []
def plan(id, name, cat, lvl, pose, free, items):
    PL.append(dict(id=id, name=name, category=cat, level=lvl, pose=pose, isFree=free,
                   exercises=[dict(exercise=e, sets=s, reps=r, seconds=sec, rest=rest) for e, s, r, sec, rest in items]))
plan("pushBasics", ("Push Basics", "Push Basics"), "push", "beginner", "pushUp", True,
     [("kneePushUp", 3, 10, None, 60), ("pushUp", 4, 6, None, 90), ("pikePushUp", 3, 6, None, 90), ("plank", 3, None, 30, 45)])
plan("pullDay", ("Pull Day", "Pull Day"), "pull", "beginner", "pullUp", True,
     [("row", 3, 10, None, 60), ("negativePullUp", 3, 5, None, 90), ("pullUp", 3, 4, None, 120), ("kneeRaise", 3, 10, None, 60)])
plan("corePlank", ("Core & Plank", "Core & Plank"), "core", "beginner", "plank", True,
     [("plank", 3, None, 40, 45), ("kneeRaise", 3, 10, None, 60), ("lSit", 4, None, 10, 60)])
plan("legsNoEquipment", ("Legs without equipment", "Beine ohne Geräte"), "legs", "beginner", "squat", True,
     [("squat", 4, 15, None, 60), ("lunge", 3, 10, None, 60), ("pistolSquat", 3, 3, None, 90)])
plan("handstandSchool", ("Handstand school", "Handstand-Schule"), "skill", "beginner", "handstand", False,
     [("pikePushUp", 3, 8, None, 90), ("plank", 3, None, 30, 45), ("wallHandstand", 4, None, 20, 60)])
plan("pushEndurance", ("Push Endurance", "Push-Ausdauer"), "push", "beginner", "pushUp", True,
     [("kneePushUp", 3, 15, None, 60), ("pushUp", 3, 10, None, 75), ("plank", 3, None, 40, 45)])
plan("pushPower", ("Push Power", "Push-Kraft"), "push", "intermediate", "pushUp", True,
     [("pushUp", 4, 10, None, 90), ("dip", 4, 8, None, 90), ("pikePushUp", 3, 8, None, 90), ("plank", 3, None, 45, 45)])
plan("rowsAndHangs", ("Rows & Hangs", "Rudern & Hängen"), "pull", "beginner", "pullUp", True,
     [("row", 4, 10, None, 60), ("kneeRaise", 3, 8, None, 60), ("negativePullUp", 3, 4, None, 90)])
plan("pullStrength", ("Pull Strength", "Zugkraft"), "pull", "intermediate", "pullUp", True,
     [("pullUp", 5, 5, None, 120), ("row", 3, 12, None, 60), ("negativePullUp", 3, 3, None, 90), ("kneeRaise", 3, 12, None, 60)])
plan("legDayPlus", ("Leg Day Plus", "Beine Plus"), "legs", "intermediate", "squat", True,
     [("squat", 4, 20, None, 60), ("lunge", 4, 12, None, 60), ("pistolSquat", 3, 4, None, 90)])
plan("coreStrength", ("Core Strength", "Core-Kraft"), "core", "intermediate", "lSit", True,
     [("kneeRaise", 4, 12, None, 60), ("lSit", 4, None, 15, 60), ("plank", 3, None, 60, 60)])
plan("frontLeverBuildUp", ("Front lever build-up", "Front-Lever-Aufbau"), "skill", "advanced", "frontLever", False,
     [("pullUp", 4, 6, None, 120), ("kneeRaise", 3, 12, None, 60), ("tuckFrontLever", 5, None, 10, 90), ("row", 3, 12, None, 60)])
plan("muscleUpPath", ("Muscle-up path", "Muscle-up-Weg"), "skill", "advanced", "muscleUp", False,
     [("pullUp", 4, 6, None, 120), ("dip", 4, 8, None, 90), ("negativePullUp", 3, 5, None, 90), ("muscleUp", 5, 2, None, 150)])

# Skills (shown as goals in the Me tab, Pro only): id, name, pose, linked exercise (animation and,
# for time goals, best time), ordered workouts from easy to hard, free,
# stages (skill with stages) or targetSeconds (time goal)
G = []
def goal(id, name, pose, exercise, plans, free, muscles, benefit, stages=None, seconds=None, animation=None):
    # animation: shown for the skill instead of the linked exercise's animation (optional)
    # muscles, benefit: (English, German) texts for the skill's info sheet
    # stages: (name, animation, muscles, benefit, tip); texts as (English, German); tip: what to do
    # now ("Jetzt dran"), with suggested holds or reps (draft, to be checked)
    G.append(dict(id=id, name=name, pose=pose, exercise=exercise, plans=plans, isFree=free, muscles=muscles, benefit=benefit,
                  stages=stages, targetSeconds=seconds, animation=animation))

goal("frontLever", ("Front lever", "Front Lever"), "frontLever", "tuckFrontLever", ["pullDay", "pullStrength", "frontLeverBuildUp"], False,
     ("Your wide back muscles (the lats) do most of the work and keep you up like a shelf. Your belly and glutes hold everything in one straight line, the backs of your shoulders keep you steady, and your hands hang on tight.",
      "Dein breiter Rückenmuskel, der Latissimus, macht die Hauptarbeit und hält dich oben wie ein Regalbrett. Bauch und Po halten alles in einer geraden Linie, die hinteren Schultern sorgen für Ruhe und deine Hände halten fest."),
     ("You float horizontally under the bar, arms straight, as if gravity had taken a day off. Few moves build pulling strength and full-body tension like this one, and it looks spectacular too.",
      "Du schwebst waagrecht unter der Stange, die Arme gestreckt, als hätte die Schwerkraft gerade Pause. Kaum eine Übung baut so viel Zugkraft und Ganzkörperspannung auf, und spektakulär aussehen tut sie auch noch."),
     stages=[
         (("Tuck", "Tuck"), "tuckFrontLever",
          ("Your lats and belly start working together here, and the backs of your shoulders get their first real job.",
           "Hier lernen Latissimus und Bauch, zusammenzuarbeiten, und die hinteren Schultern bekommen ihren ersten richtigen Job."),
          ("Knees snuggled up to your chest, you roll into a small ball and hold it level. That keeps the lever short and lets you feel the position safely: the starting point for everything that follows.",
           "Die Knie kuscheln sich an die Brust, du wirst zum kleinen Päckchen und hältst es waagrecht. So bleibt der Hebel kurz und du lernst die Position ganz in Ruhe kennen: der Startpunkt für alles, was noch kommt."),
          ('Knees to your chest, back straight. Hold 10 seconds.', 'Knie zur Brust, Rücken gerade. Halte 10 Sekunden.')),
         (("Advanced tuck", "Advanced Tuck"), "advancedTuckFrontLever",
          ("Your lats and belly get a good deal more to do, and your lower back joins in to keep it nice and flat.",
           "Latissimus und Bauch bekommen ordentlich mehr zu tun, und dein unterer Rücken hilft mit, damit er schön flach bleibt."),
          ("Same little package, but your back is now flat as a table and your thighs point to the sky. The lever gets longer, so it feels much heavier. Patience pays off here.",
           "Das gleiche kleine Päckchen, nur ist dein Rücken jetzt flach wie ein Tisch und die Oberschenkel zeigen in den Himmel. Der Hebel wird länger und fühlt sich deutlich schwerer an. Hier zahlt sich Geduld aus."),
          ('Hips open, knees bent, back flat. Hold 10 seconds.', 'Hüfte gestreckt, Knie gebeugt, Rücken flach. Halte 10 Sekunden.')),
         (("One leg", "Ein Bein"), "oneLegFrontLever",
          ("Besides your lats and belly, your glutes and hip flexors now help keep the straight leg up.",
           "Neben Latissimus und Bauch helfen jetzt auch Po und Hüftbeuger, das gestreckte Bein oben zu halten."),
          ("One leg stretches out, the other stays tucked. This is the friendly bridge between the curled-up positions and the long ones, and you can switch legs to keep things fair.",
           "Ein Bein streckt sich aus, das andere bleibt angewinkelt. Das ist die freundliche Brücke zwischen den kleinen und den langen Positionen, und mit Beinwechsel kommt keine Seite zu kurz."),
          ('One leg straight, one bent. Hold 8 seconds per side.', 'Ein Bein gestreckt, eins gebeugt. Halte 8 Sekunden pro Seite.')),
         (("Straddle", "Straddle"), "straddleFrontLever",
          ("Your lats, belly and lower back are working at full power now, and your glutes and inner thighs keep the legs wide and straight.",
           "Latissimus, Bauch und unterer Rücken arbeiten jetzt richtig, und Po und Innenseiten der Oberschenkel halten die Beine weit und gestreckt."),
          ("Both legs straight and wide apart, like a big V. The spread makes the lever just a bit shorter than the full version: you are almost there!",
           "Beide Beine gestreckt und weit gegrätscht, wie ein großes V. Die Grätsche macht den Hebel nur ein kleines bisschen kürzer als die volle Version: Du bist fast da!"),
          ('Both legs straight and spread wide. Hold 6 seconds.', 'Beide Beine gestreckt und gegrätscht. Halte 6 Sekunden.')),
         (("Full front lever", "Voller Front Lever"), "frontLever",
          ("Everything at once: lats, belly, glutes and the backs of your shoulders hold you from head to toe like a plank of wood.",
           "Alles auf einmal: Latissimus, Bauch, Po und hintere Schultern halten dich von Kopf bis Fuß wie ein Brett."),
          ("Legs together, body straight, floating under the bar. This is the moment you have been training for. Enjoy it, take a photo, and be proud!",
           "Beine zusammen, Körper gestreckt, schwebend unter der Stange. Genau dafür hast du trainiert. Genieß den Moment, mach ein Foto und sei stolz!"),
          ('Body fully straight and level. Hold 5 seconds.', 'Körper ganz gestreckt und waagrecht. Halte 5 Sekunden.')),
     ],
     animation="frontLever")
goal("plank5Min", ("Plank 5 min", "Plank 5 min"), "plank", "plank", ["corePlank", "coreStrength"], False,
     ("Your deep belly muscles wrap around you like a corset, your six-pack muscles keep the line, and your shoulders and glutes quietly help out.",
      "Deine tiefen Bauchmuskeln legen sich wie ein Korsett um dich, die geraden Bauchmuskeln halten die Linie, und Schultern und Po helfen leise mit."),
     ("Five whole minutes, straight as a board on your forearms. It sounds simple, but it builds a trunk with staying power, better posture, and a happier lower back in everyday life.",
      "Fünf ganze Minuten, gerade wie ein Brett auf den Unterarmen. Klingt einfach, schenkt dir aber einen Rumpf mit Ausdauer, eine bessere Haltung und einen zufriedeneren unteren Rücken im Alltag."),
     seconds=300)
goal("handstandPushUp", ("Handstand push-up", "Handstand-Liegestütz"), "handstand", "pikePushUp", ["pushBasics", "pushPower", "handstandSchool"], False,
     ("Your shoulders are the stars here, with your triceps pushing alongside. Upper chest, upper back and belly make sure everything stays stacked.",
      "Deine Schultern sind hier die Stars, der Trizeps drückt fleißig mit. Obere Brust, oberer Rücken und Bauch sorgen dafür, dass alles schön übereinander bleibt."),
     ("Upside down, you press your whole body up and down. That builds strong, stable shoulders, and the world looks wonderfully different from down there.",
      "Kopfüber drückst du deinen ganzen Körper hinauf und hinunter. Das baut starke, stabile Schultern auf, und die Welt sieht von da unten herrlich anders aus."),
     stages=[
         (("Pike push-up", "Pike-Liegestütz"), "pikePushUp",
          ("Mostly your shoulders and triceps, with a little help from your upper chest.",
           "Vor allem Schultern und Trizeps, mit ein bisschen Unterstützung von der oberen Brust."),
          ("Hips up high, your body makes an upside-down V like a little tent. You learn to press straight up with part of your weight, gently and without any fear of heights.",
           "Die Hüfte geht hoch, dein Körper wird zum umgedrehten V, wie ein kleines Zelt. Du lernst, mit einem Teil deines Gewichts nach oben zu drücken, ganz sanft und ohne Höhenangst."),
          ('Hips high, head between your hands. Do 3 sets of 8.', 'Hüfte hoch, Kopf zwischen die Hände. Schaffe 3 × 8.')),
         (("Elevated pike push-up", "Erhöhter Pike-Liegestütz"), "elevatedPikePushUp",
          ("Shoulders and triceps get more weight to carry, and your belly keeps the tent nice and steady.",
           "Schultern und Trizeps bekommen mehr Gewicht zu tragen, und dein Bauch hält das Zelt schön stabil."),
          ("Your feet climb onto a box, so more of you rests on your hands. The angle gets steeper and you creep closer to the real handstand push-up.",
           "Deine Füße klettern auf einen Kasten, so liegt mehr von dir auf den Händen. Der Winkel wird steiler und du schleichst dich näher an den echten Handstand-Liegestütz heran."),
          ('Feet on a box, hips above your shoulders. Do 3 sets of 6.', 'Füße auf dem Kasten, Hüfte über den Schultern. Schaffe 3 × 6.')),
         (("Wall handstand hold", "Handstand an der Wand halten"), "wallHandstand",
          ("Shoulders and triceps hold you up, your belly keeps you straight, and your wrists get stronger day by day.",
           "Schultern und Trizeps tragen dich, der Bauch hält dich gerade, und deine Handgelenke werden Tag für Tag kräftiger."),
          ("Kick up and lean against the wall, the wall has your back! You get used to being upside down and carry your full weight on straight arms. Breathe calmly and smile.",
           "Hochschwingen und an die Wand lehnen, die Wand hält dir den Rücken frei! Du gewöhnst dich ans Kopfüber-Sein und trägst dein volles Gewicht auf gestreckten Armen. Ruhig atmen und lächeln."),
          ('Back to the wall, arms straight. Hold 30 seconds.', 'Rücken zur Wand, Arme gestreckt. Halte 30 Sekunden.')),
         (("Half wall handstand push-up", "Halber Handstand-Liegestütz an der Wand"), "halfWallHandstandPushUp",
          ("Shoulders and triceps press your full weight now, and your upper back keeps your shoulders safe.",
           "Schultern und Trizeps drücken jetzt dein volles Gewicht, und dein oberer Rücken passt auf deine Schultern auf."),
          ("Your first real presses upside down, only halfway down for now. Small range, big step: this is where the strength for the full movement grows.",
           "Deine ersten echten Drückbewegungen kopfüber, vorerst nur bis zur Hälfte. Kleiner Weg, großer Schritt: Hier wächst die Kraft für die ganze Bewegung."),
          ('Lower halfway down the wall and press up. Do 3 sets of 5.', 'An der Wand halb ablassen und hochdrücken. Schaffe 3 × 5.')),
         (("Full wall handstand push-up", "Voller Handstand-Liegestütz an der Wand"), "wallHandstandPushUp",
          ("Shoulders, triceps, upper chest and belly, all working together as one strong team.",
           "Schultern, Trizeps, obere Brust und Bauch, alle zusammen als ein starkes Team."),
          ("Head gently down to the floor and all the way back up to straight arms, with your whole weight. That is the goal of this skill: you did it!",
           "Den Kopf sanft bis zum Boden und wieder ganz hoch zu gestreckten Armen, mit deinem ganzen Gewicht. Das ist das Ziel dieses Skills: Geschafft!"),
          ('Head to the floor and all the way up. Do 3 sets of 3.', 'Kopf bis zum Boden und ganz hoch. Schaffe 3 × 3.')),
     ],
     animation="wallHandstandPushUp")
goal("lSit30", ("L-sit 30 s", "L-Sit 30 s"), "lSit", "lSit", ["corePlank", "coreStrength"], False,
     ("Your hip flexors and belly lift your legs, while your triceps and shoulders push you up and away from the floor.",
      "Hüftbeuger und Bauch heben deine Beine, während Trizeps und Schultern dich nach oben und weg vom Boden drücken."),
     ("Thirty seconds sitting in the air, legs straight out in front of you like a capital L. It builds wonderful compression strength and steady shoulders, a great base for many gymnastics moves.",
      "Dreißig Sekunden in der Luft sitzen, die Beine gestreckt vor dir wie ein großes L. Das schenkt dir tolle Kompressionskraft und ruhige Schultern, eine prima Basis für viele Turnelemente."),
     seconds=30)
goal("pistolSquat", ("Pistol squat", "Pistol Squat"), "pistolSquat", "pistolSquat", ["legsNoEquipment", "legDayPlus"], False,
     ("The fronts of your thighs and your glutes do the heavy lifting, your inner thighs and calves keep you balanced, and your belly keeps you upright.",
      "Oberschenkel vorne und Po machen die schwere Arbeit, Innenseiten der Oberschenkel und Waden halten dich in Balance, und dein Bauch hält dich aufrecht."),
     ("A full squat on just one leg, the other one stretched out in front. It builds strength, balance and mobility in ankles and hips, and every leg gets its own little adventure.",
      "Eine volle Kniebeuge auf nur einem Bein, das andere streckt sich nach vorne. Das baut Kraft, Gleichgewicht und Beweglichkeit in Sprunggelenk und Hüfte auf, und jedes Bein bekommt sein eigenes kleines Abenteuer."),
     stages=[
         (("Deep squat", "Tiefe Kniebeuge"), "squat",
          ("Fronts of the thighs, glutes and inner thighs, all on both legs for now.",
           "Oberschenkel vorne, Po und Innenseiten der Oberschenkel, vorerst noch auf beiden Beinen."),
          ("Sink all the way down on both legs, as if sitting on a tiny stool. This opens up your ankles and hips for the deep position you will need later on one leg.",
           "Mit beiden Beinen ganz tief runter, als würdest du dich auf einen winzigen Hocker setzen. Das öffnet Sprunggelenke und Hüfte für die tiefe Position, die du später auf einem Bein brauchst."),
          ('Feet flat, all the way down. Hold the bottom 30 seconds.', 'Fersen am Boden, ganz nach unten. Halte unten 30 Sekunden.')),
         (("Lunge", "Ausfallschritt"), "lunge",
          ("Fronts and backs of the thighs and your glutes, with the front leg doing most of the work.",
           "Oberschenkel vorne und hinten und dein Po, wobei das vordere Bein den Großteil übernimmt."),
          ("A big step forward and down. Most of your weight rests on the front leg while the back one lends a hand: your first taste of single-leg strength and balance.",
           "Ein großer Schritt nach vorn und runter. Das meiste Gewicht liegt auf dem vorderen Bein, das hintere hilft ein wenig: dein erster Vorgeschmack auf Kraft und Balance auf einem Bein."),
          ('Front knee over the foot. Do 3 sets of 10 per leg.', 'Vorderes Knie über dem Fuß. Schaffe 3 × 10 pro Bein.')),
         (("Box pistol", "Pistol auf Kasten"), "boxPistol",
          ("Fronts of the thighs and glutes on one leg, with your belly keeping you upright.",
           "Oberschenkel vorne und Po auf einem Bein, und dein Bauch hält dich aufrecht."),
          ("Sit down onto a box on one leg and stand up again. The box catches you and decides how deep you go, so your strength can grow step by step.",
           "Auf einem Bein auf einen Kasten setzen und wieder aufstehen. Der Kasten fängt dich auf und bestimmt, wie tief es geht, so kann deine Kraft Schritt für Schritt wachsen."),
          ('Sit back onto the box on one leg. Do 3 sets of 5 per leg.', 'Auf einem Bein auf den Kasten setzen. Schaffe 3 × 5 pro Bein.')),
         (("Assisted pistol", "Pistol mit Hilfe"), "assistedPistol",
          ("Fronts of the thighs, glutes and calves, especially down at the very bottom.",
           "Oberschenkel vorne, Po und Waden, vor allem ganz unten in der Tiefe."),
          ("All the way down on one leg, while your hands hold on to a pole or doorframe for balance. Strength and mobility at the bottom, with a friendly helper by your side.",
           "Auf einem Bein ganz nach unten, während deine Hände sich an einer Stange oder am Türrahmen festhalten. Kraft und Beweglichkeit ganz unten, mit einem freundlichen Helfer an deiner Seite."),
          ('Hold the pole, go all the way down. Do 3 sets of 5 per leg.', 'An der Stange festhalten, ganz runter. Schaffe 3 × 5 pro Bein.')),
         (("Full pistol squat", "Voller Pistol Squat"), "pistolSquat",
          ("Fronts of the thighs, glutes, inner thighs and belly, all doing their part together.",
           "Oberschenkel vorne, Po, Innenseiten der Oberschenkel und Bauch, alle machen gemeinsam mit."),
          ("All the way down on one leg and back up, without any help. That is the goal of this skill: wobbling a little is allowed, celebrating is required!",
           "Auf einem Bein ganz runter und wieder hoch, ganz ohne Hilfe. Das ist das Ziel dieses Skills: Ein bisschen wackeln ist erlaubt, feiern ist Pflicht!"),
          ('All the way down and up, no help. Do 3 per leg.', 'Ganz runter und hoch, ohne Hilfe. Schaffe 3 pro Bein.')),
     ])
goal("muscleUp", ("Muscle-up", "Muscle-up"), "muscleUp", "muscleUp", ["pullDay", "pullStrength", "pushPower", "muscleUpPath"], False,
     ("Lats and biceps pull you up, chest, triceps and shoulders push you over the top, and your belly ties it all together.",
      "Latissimus und Bizeps ziehen dich hoch, Brust, Trizeps und Schultern drücken dich oben drüber, und dein Bauch hält alles zusammen."),
     ("From hanging below the bar to sitting on top of it in one smooth swoop. It combines explosive pulling and pushing, and it feels like flying a little.",
      "Aus dem Hang unter der Stange in einem einzigen Schwung oben drauf in den Stütz. Das verbindet explosives Ziehen und Drücken und fühlt sich ein bisschen an wie Fliegen."),
     stages=[
         (("10 pull-ups", "10 Klimmzüge"), "pullUp",
          ("Your lats and biceps pull, the backs of your shoulders help, and your grip gets stronger with every rep.",
           "Latissimus und Bizeps ziehen, die hinteren Schultern helfen mit, und dein Griff wird mit jeder Wiederholung stärker."),
          ("Ten clean pull-ups in a row, chin over the bar each time. This is the pulling strength your muscle-up will be built on.",
           "Zehn saubere Klimmzüge am Stück, jedes Mal mit dem Kinn über die Stange. Das ist die Zugkraft, auf der dein Muscle-up später aufbaut."),
          ('Chin over the bar, no swinging. Do 10 in a row.', 'Kinn über die Stange, ohne Schwung. Schaffe 10 am Stück.')),
         (("Chest-to-bar pull-up", "Klimmzug bis zur Brust"), "pullUp",
          ("Lats and biceps pull extra hard, and your middle back squeezes your shoulder blades together.",
           "Latissimus und Bizeps ziehen extra kräftig, und dein mittlerer Rücken zieht die Schulterblätter zusammen."),
          ("Pull higher and a little faster, until your chest gives the bar a hug. You need exactly this height to get over the bar later on.",
           "Zieh höher und ein bisschen schneller, bis deine Brust die Stange umarmt. Genau diese Höhe brauchst du später, um über die Stange zu kommen."),
          ('Pull until your chest touches the bar. Do 3 sets of 5.', 'Zieh, bis die Brust die Stange berührt. Schaffe 3 × 5.')),
         (("10 dips", "10 Dips"), "dip",
          ("Chest, triceps and the fronts of your shoulders push you up from the bars.",
           "Brust, Trizeps und vordere Schultern drücken dich vom Barren nach oben."),
          ("Ten dips in a row on parallel bars. They give you the pushing strength for the part of the muscle-up that happens above the bar.",
           "Zehn Dips am Stück am Barren. Sie schenken dir die Drückkraft für den Teil des Muscle-ups, der über der Stange passiert."),
          ('Shoulders down, upper arms level at the bottom. Do 10 in a row.', 'Schultern unten, Oberarme unten waagrecht. Schaffe 10 am Stück.')),
         (("Negative muscle-up", "Negativer Muscle-up"), "negativeMuscleUp",
          ("Lats, chest, triceps and shoulders all work while slowly braking your way down.",
           "Latissimus, Brust, Trizeps und Schultern arbeiten alle, während du dich langsam nach unten abbremst."),
          ("Start on top of the bar and lower yourself slowly, slowly into the hang. That is how your body learns the tricky transition over the bar, calmly and under control.",
           "Oben auf der Stange beginnen und dich langsam, ganz langsam in den Hang ablassen. So lernt dein Körper den kniffligen Übergang über die Stange, in Ruhe und unter Kontrolle."),
          ('From support above the bar, lower in 5 seconds. Do 3 sets of 3.', 'Aus dem Stütz über der Stange in 5 Sekunden ablassen. Schaffe 3 × 3.')),
         (("Muscle-up", "Muscle-up"), "muscleUp",
          ("Lats, chest, triceps, shoulders and belly, your whole upper body in one big team move.",
           "Latissimus, Brust, Trizeps, Schultern und Bauch, dein ganzer Oberkörper in einem großen Teamwork."),
          ("Pull, swing through and push: from hanging to sitting on top of the bar in one go. That is the goal of this skill. Welcome up there!",
           "Ziehen, durchschwingen, drücken: vom Hang bis oben auf die Stange in einem Zug. Das ist das Ziel dieses Skills. Willkommen da oben!"),
          ('Pull, turn over the bar, press to support. Do 1 clean rep.', 'Ziehen, über die Stange drehen, in den Stütz drücken. Schaffe 1 saubere Wiederholung.')),
     ])

# Achievements (sample list of 12, see docs/SPEC.md "Inhalte"), computed from the journal.
# kind: workouts (number of journal entries), reps / seconds (best value of one exercise),
# streak (weeks in a row with the weekly target reached). label = text under the value.
A = []
def achievement(id, kind, threshold, label, exercise=None):
    A.append(dict(id=id, kind=kind, threshold=threshold, exercise=exercise, label=label))
achievement("firstWorkout", "workouts", 1, ("First workout", "Erstes Training"))
achievement("workouts10", "workouts", 10, ("Workouts", "Trainings"))
achievement("workouts25", "workouts", 25, ("Workouts", "Trainings"))
achievement("workouts50", "workouts", 50, ("Workouts", "Trainings"))
achievement("pullUps10", "reps", 10, ("Pull-ups", "Klimmzüge"), "pullUp")
achievement("pushUps20", "reps", 20, ("Push-ups", "Liegestütze"), "pushUp")
achievement("squats30", "reps", 30, ("Squats", "Kniebeugen"), "squat")
achievement("pistolSquats5", "reps", 5, ("Pistol squats", "Pistol Squats"), "pistolSquat")
achievement("plank3Min", "seconds", 180, ("Plank", "Plank"), "plank")
achievement("lSit20", "seconds", 20, ("L-sit", "L-Sit"), "lSit")
achievement("streak4", "streak", 4, ("Weeks in a row", "Wochen in Folge"))
achievement("firstMuscleUp", "reps", 1, ("Muscle-up", "Muscle-up"), "muscleUp")
