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

# Skills (shown as goals on the dashboard, Pro only): id, name, pose, linked exercise (animation and,
# for time goals, best time), ordered workouts from easy to hard, free,
# stages (skill with stages) or targetSeconds (time goal)
G = []
def goal(id, name, pose, exercise, plans, free, stages=None, seconds=None, animation=None):
    # animation: shown for the skill instead of the linked exercise's animation (optional)
    G.append(dict(id=id, name=name, pose=pose, exercise=exercise, plans=plans, isFree=free, stages=stages, targetSeconds=seconds, animation=animation))
goal("frontLever", ("Front lever", "Front Lever"), "frontLever", "tuckFrontLever", ["pullDay", "pullStrength", "frontLeverBuildUp"], False,
     stages=[("Tuck", "Tuck"), ("Advanced tuck", "Advanced Tuck"), ("One leg", "Ein Bein"), ("Straddle", "Straddle"), ("Full front lever", "Voller Front Lever")],
     animation="frontLever")
goal("plank5Min", ("Plank 5 min", "Plank 5 min"), "plank", "plank", ["corePlank", "coreStrength"], False, seconds=300)
goal("handstandPushUp", ("Handstand push-up", "Handstand-Liegestütz"), "handstand", "pikePushUp", ["pushBasics", "pushPower", "handstandSchool"], False,
     stages=[("Pike push-up", "Pike-Liegestütz"), ("Elevated pike push-up", "Erhöhter Pike-Liegestütz"), ("Wall handstand hold", "Handstand an der Wand halten"), ("Half wall handstand push-up", "Halber Handstand-Liegestütz an der Wand"), ("Full wall handstand push-up", "Voller Handstand-Liegestütz an der Wand")])
goal("lSit30", ("L-sit 30 s", "L-Sit 30 s"), "lSit", "lSit", ["corePlank", "coreStrength"], False, seconds=30)
goal("pistolSquat", ("Pistol squat", "Pistol Squat"), "pistolSquat", "pistolSquat", ["legsNoEquipment", "legDayPlus"], False,
     stages=[("Deep squat", "Tiefe Kniebeuge"), ("Lunge", "Ausfallschritt"), ("Box pistol", "Pistol auf Kasten"), ("Assisted pistol", "Pistol mit Hilfe"), ("Full pistol squat", "Voller Pistol Squat")])
goal("muscleUp", ("Muscle-up", "Muscle-up"), "muscleUp", "muscleUp", ["pullDay", "pullStrength", "pushPower", "muscleUpPath"], False,
     stages=[("10 pull-ups", "10 Klimmzüge"), ("Chest-to-bar pull-up", "Klimmzug bis zur Brust"), ("10 dips", "10 Dips"), ("Negative muscle-up", "Negativer Muscle-up"), ("Muscle-up", "Muscle-up")])

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
