# Single source for Catalog.json and Catalog.xcstrings (see docs/SPEC.md "Inhalte").
# Exercise: id, category, level, animation, pose, easier, harder, (en, de) name, 3 steps, mistakes
E = []
def ex(id, cat, lvl, anim, pose, easier, harder, name, steps, mistakes):
    E.append(dict(id=id, category=cat, level=lvl, animation=anim, pose=pose, easier=easier, harder=harder,
                  name=name, steps=steps, mistakes=mistakes))

ex("kneePushUp", "push", "beginner", "kneePushUp", "pushUp", "inclinePushUp", "pushUp",
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
ex("pikePushUp", "push", "intermediate", "pikePushUp", "pushUp", "pushUp", "elevatedPikePushUp",
   ("Pike push-up", "Pike-Liegestütz"),
   [("Walk your feet in until your hips are high and your body forms an upside-down V.", "Lauf mit den Füßen heran, bis die Hüfte hoch ist und der Körper ein umgekehrtes V bildet."),
    ("Bend your elbows and lower the top of your head towards the floor in front of your hands.", "Beug die Ellbogen und senk den Kopf vor den Händen Richtung Boden."),
    ("Push back up to straight arms, keeping your hips high.", "Drück dich zurück zu gestreckten Armen, die Hüfte bleibt oben.")],
   [("Letting the hips drop into a normal push-up.", "Die Hüfte sinkt ab und es wird ein normaler Liegestütz."),
    ("Lowering the face instead of the top of the head.", "Das Gesicht statt des Scheitels absenken.")])
ex("dip", "push", "intermediate", "dip", "muscleUp", "benchDip", "muscleUp",
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
ex("pullUp", "pull", "intermediate", "pullUp", "pullUp", "chinUp", "chestToBarPullUp",
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
ex("lunge", "legs", "beginner", "lunge", "squat", "squat", "bulgarianSplitSquat",
   ("Lunge", "Ausfallschritt"),
   [("Take a long step forward and keep your upper body upright.", "Mach einen großen Schritt nach vorn und halte den Oberkörper aufrecht."),
    ("Lower your back knee until it almost touches the floor.", "Senk das hintere Knie, bis es fast den Boden berührt."),
    ("Push through your front heel to come back up.", "Drück dich über die vordere Ferse wieder hoch.")],
   [("Front knee collapsing inwards.", "Das vordere Knie knickt nach innen."),
    ("Leaning far forward with the upper body.", "Mit dem Oberkörper weit nach vorn kippen.")])
ex("pistolSquat", "legs", "advanced", "pistolSquat", "pistolSquat", "assistedPistol", None,
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
ex("kneeRaise", "core", "beginner", "kneeRaise", "lSit", "deadHang", "hangingLegRaise",
   ("Hanging knee raise", "Hängendes Knieheben"),
   [("Hang from the bar with straight arms and active shoulders.", "Häng mit gestreckten Armen und aktiven Schultern an der Stange."),
    ("Raise your knees until your thighs are at least horizontal.", "Zieh die Knie hoch, bis die Oberschenkel mindestens waagrecht sind."),
    ("Lower your legs slowly without swinging.", "Senk die Beine langsam ab, ohne zu schwingen.")],
   [("Swinging back and forth.", "Vor und zurück schwingen."),
    ("Only lifting the feet, not the knees.", "Nur die Füße statt der Knie anheben.")])
ex("lSit", "core", "intermediate", "lSit", "lSit", "tuckLSit", None,
   ("L-sit", "L-Sit"),
   [("Place your hands on parallettes or the floor next to your hips.", "Setz die Hände neben der Hüfte auf Parallettes oder den Boden."),
    ("Press down, lock your elbows and lift your hips off the ground.", "Drück dich nach unten weg, streck die Ellbogen durch und heb die Hüfte an."),
    ("Raise your straight legs until they are parallel to the floor and hold.", "Heb die gestreckten Beine bis zur Waagrechten und halte die Position.")],
   [("Bent knees.", "Gebeugte Knie."),
    ("Shoulders shrugged up.", "Hochgezogene Schultern.")])
ex("wallHandstand", "skill", "beginner", "handstand", "handstand", "pikePushUp", "halfWallHandstandPushUp",
   ("Wall handstand", "Handstand an der Wand"),
   [("Place your hands shoulder-width apart about a hand's length from the wall.", "Setz die Hände schulterbreit etwa eine Handlänge vor der Wand auf."),
    ("Kick up one leg after the other until your heels rest against the wall.", "Schwing ein Bein nach dem anderen hoch, bis die Fersen an der Wand liegen."),
    ("Push the floor away, squeeze your legs together and look at your hands.", "Drück den Boden weg, schließ die Beine und schau zu deinen Händen.")],
   [("Strong arch in the lower back.", "Starkes Hohlkreuz."),
    ("Bent arms.", "Gebeugte Arme.")])
ex("tuckFrontLever", "skill", "advanced", "tuckFrontLever", "frontLever", "kneeRaise", "advancedTuckFrontLever",
   ("Tuck front lever", "Tuck Front Lever"),
   [("Hang from the bar and pull your knees tightly to your chest.", "Häng an der Stange und zieh die Knie eng an die Brust."),
    ("Press the bar down with straight arms until your back is horizontal.", "Drück die Stange mit gestreckten Armen nach unten, bis der Rücken waagrecht ist."),
    ("Hold the position with your hips level with your shoulders.", "Halte die Position, die Hüfte auf Höhe der Schultern.")],
   [("Bending the arms.", "Die Arme beugen."),
    ("Hips dropping below shoulder height.", "Die Hüfte sinkt unter Schulterhöhe.")])
ex("muscleUp", "skill", "advanced", "muscleUp", "muscleUp", "negativeMuscleUp", None,
   ("Muscle-up", "Muscle-up"),
   [("Hang with a slightly narrower grip and start with a strong, explosive pull.", "Häng mit etwas engerem Griff und beginne mit einem kräftigen, explosiven Zug."),
    ("As your chest reaches the bar, lean forward and turn your wrists over the bar.", "Sobald die Brust an der Stange ist, lehn dich nach vorn und dreh die Handgelenke über die Stange."),
    ("Press up into a straight-arm support above the bar.", "Drück dich in den gestreckten Stütz über der Stange.")],
   [("Pulling too slowly to get over the bar.", "Zu langsam ziehen, um über die Stange zu kommen."),
    ("Getting one arm over before the other.", "Einen Arm vor dem anderen über die Stange bringen.")])

# --- Push
ex("inclinePushUp", "push", "beginner", "inclinePushUp", "pushUp", None, "kneePushUp",
   ("Incline push-up", "Liegestütz mit erhöhten Händen"),
   [("Place your hands on a box or bench, slightly wider than your shoulders.", "Setz die Hände etwas breiter als schulterbreit auf einen Kasten oder eine Bank."),
    ("Step back until your body forms a straight line from head to heels.", "Geh mit den Füßen zurück, bis dein Körper von Kopf bis Ferse eine Linie bildet."),
    ("Lower your chest to the edge and push back up.", "Senk die Brust zur Kante und drück dich wieder hoch.")],
   [("Hips sagging towards the floor.", "Die Hüfte sackt zum Boden durch."),
    ("Head reaching forward instead of the chest.", "Der Kopf geht nach vorn statt der Brust.")])
ex("diamondPushUp", "push", "intermediate", "diamondPushUp", "pushUp", "pushUp", "declinePushUp",
   ("Diamond push-up", "Diamant-Liegestütz"),
   [("Put your hands together under your chest so thumbs and index fingers form a diamond.", "Setz die Hände unter der Brust zusammen, sodass Daumen und Zeigefinger eine Raute bilden."),
    ("Keep your body straight and lower your chest towards your hands, elbows close to your body.", "Halte den Körper gerade und senk die Brust zu den Händen, die Ellbogen eng am Körper."),
    ("Press back up until your arms are straight.", "Drück dich hoch, bis die Arme gestreckt sind.")],
   [("Elbows flaring out to the sides.", "Die Ellbogen gehen weit zur Seite."),
    ("Hips sagging or piking up.", "Die Hüfte hängt durch oder ragt nach oben.")])
ex("declinePushUp", "push", "intermediate", "declinePushUp", "pushUp", "diamondPushUp", "pikePushUp",
   ("Decline push-up", "Liegestütz mit erhöhten Füßen"),
   [("Put your feet on a box or bench and your hands on the floor under your shoulders.", "Leg die Füße auf einen Kasten oder eine Bank, die Hände unter den Schultern auf den Boden."),
    ("Tighten your belly so your body stays straight from heels to head.", "Spann den Bauch an, damit dein Körper von den Fersen bis zum Kopf gerade bleibt."),
    ("Lower your chest towards the floor and press back up.", "Senk die Brust zum Boden und drück dich wieder hoch.")],
   [("Hips sagging towards the floor.", "Die Hüfte sackt zum Boden durch."),
    ("Only going halfway down.", "Nur halb nach unten gehen.")])
ex("benchDip", "push", "beginner", "benchDip", "muscleUp", None, "dip",
   ("Bench dip", "Bank-Dip"),
   [("Sit on the edge of a bench, hands next to your hips, and slide your hips forward off it.", "Setz dich auf die Kante einer Bank, die Hände neben der Hüfte, und schieb die Hüfte nach vorn von der Bank."),
    ("Bend your elbows straight back and lower your hips until your upper arms are about level.", "Beug die Ellbogen nach hinten und senk die Hüfte, bis die Oberarme etwa waagrecht sind."),
    ("Press back up until your arms are straight.", "Drück dich hoch, bis die Arme gestreckt sind.")],
   [("Elbows pointing out to the sides.", "Die Ellbogen zeigen zur Seite."),
    ("Hips drifting far away from the bench.", "Die Hüfte wandert weit von der Bank weg.")])
ex("elevatedPikePushUp", "push", "intermediate", "elevatedPikePushUp", "handstand", "pikePushUp", "halfWallHandstandPushUp",
   ("Elevated pike push-up", "Erhöhter Pike-Liegestütz"),
   [("Put your feet on a box and walk your hands back until your hips are above your shoulders.", "Stell die Füße auf einen Kasten und lauf mit den Händen zurück, bis die Hüfte über den Schultern ist."),
    ("Bend your elbows and lower the top of your head towards the floor in front of your hands.", "Beug die Ellbogen und senk den Scheitel vor den Händen Richtung Boden."),
    ("Press back up to straight arms.", "Drück dich zurück zu gestreckten Armen.")],
   [("Hips sinking down behind the shoulders.", "Die Hüfte sinkt hinter die Schultern ab."),
    ("Elbows flaring wide.", "Die Ellbogen gehen weit nach außen.")])
ex("halfWallHandstandPushUp", "skill", "advanced", "halfWallHandstandPushUp", "handstand", "elevatedPikePushUp", "wallHandstandPushUp",
   ("Half wall handstand push-up", "Halber Handstand-Liegestütz an der Wand"),
   [("Kick up into a handstand with your back to the wall.", "Schwing dich mit dem Rücken zur Wand in den Handstand."),
    ("Bend your elbows and lower yourself halfway towards the floor.", "Beug die Ellbogen und lass dich bis zur Hälfte Richtung Boden ab."),
    ("Press back up to straight arms.", "Drück dich zurück zu gestreckten Armen.")],
   [("Strong arch in the lower back.", "Starkes Hohlkreuz."),
    ("Dropping down without control.", "Unkontrolliert nach unten fallen.")])
ex("wallHandstandPushUp", "skill", "advanced", "wallHandstandPushUp", "handstand", "halfWallHandstandPushUp", None,
   ("Wall handstand push-up", "Handstand-Liegestütz an der Wand"),
   [("Kick up into a handstand with your back to the wall, hands a little wider than your shoulders.", "Schwing dich mit dem Rücken zur Wand in den Handstand, die Hände etwas breiter als die Schultern."),
    ("Lower yourself slowly until your head gently touches the floor.", "Lass dich langsam ab, bis der Kopf sanft den Boden berührt."),
    ("Press all the way back up to straight arms.", "Drück dich ganz zurück zu gestreckten Armen.")],
   [("Landing hard on your head.", "Hart auf dem Kopf landen."),
    ("Elbows flaring wide.", "Die Ellbogen gehen weit nach außen.")])

# --- Pull
ex("deadHang", "pull", "beginner", "deadHang", "pullUp", None, "scapulaPullUp",
   ("Dead hang", "Hängen an der Stange"),
   [("Grip the bar a little wider than your shoulders.", "Greif die Stange etwas breiter als schulterbreit."),
    ("Let your body hang with straight arms and legs together.", "Lass dich mit gestreckten Armen hängen, die Beine geschlossen."),
    ("Keep your belly lightly tensed and breathe calmly.", "Halte den Bauch leicht angespannt und atme ruhig weiter.")],
   [("Swinging back and forth.", "Vor und zurück schwingen."),
    ("Letting go before the time is up, instead of resting a moment and continuing.", "Loslassen, bevor die Zeit um ist, statt kurz abzusetzen und weiterzumachen.")])
ex("scapulaPullUp", "pull", "beginner", "scapulaPullUp", "pullUp", "deadHang", "negativePullUp",
   ("Scapula pull-up", "Schulterblatt-Klimmzug"),
   [("Hang from the bar with straight arms.", "Häng mit gestreckten Armen an der Stange."),
    ("Without bending your elbows, pull your shoulders down and away from your ears so your body rises a little.", "Zieh die Schultern nach unten, weg von den Ohren, ohne die Ellbogen zu beugen, sodass dein Körper etwas hochkommt."),
    ("Lower back into the hang under control.", "Lass dich kontrolliert zurück in den Hang.")],
   [("Bending the elbows.", "Die Ellbogen beugen."),
    ("Swinging the legs for momentum.", "Mit den Beinen Schwung holen.")])
ex("chinUp", "pull", "intermediate", "pullUp", "pullUp", "negativePullUp", "pullUp",
   ("Chin-up", "Chin-up"),
   [("Hang from the bar with your palms facing you, hands shoulder-width apart.", "Häng an der Stange, die Handflächen zeigen zu dir, die Hände schulterbreit."),
    ("Pull your chest towards the bar until your chin is above it.", "Zieh die Brust zur Stange, bis das Kinn darüber ist."),
    ("Lower yourself under control to a full hang.", "Lass dich kontrolliert bis in den vollen Hang ab.")],
   [("Swinging the legs for momentum.", "Mit den Beinen Schwung holen."),
    ("Only pulling halfway up.", "Nur halb hochziehen.")])
ex("chestToBarPullUp", "pull", "advanced", "pullUp", "pullUp", "pullUp", "negativeMuscleUp",
   ("Chest-to-bar pull-up", "Klimmzug bis zur Brust"),
   [("Hang from the bar with hands slightly wider than your shoulders.", "Häng an der Stange, die Hände etwas breiter als schulterbreit."),
    ("Pull hard and fast, leaning back slightly, until your chest touches the bar.", "Zieh kräftig und zügig, leicht nach hinten gelehnt, bis die Brust die Stange berührt."),
    ("Lower yourself under control to a full hang.", "Lass dich kontrolliert bis in den vollen Hang ab.")],
   [("Stopping with the chin at the bar.", "Mit dem Kinn an der Stange aufhören."),
    ("Kicking with the legs.", "Mit den Beinen strampeln.")])
ex("negativeMuscleUp", "skill", "advanced", "negativeMuscleUp", "muscleUp", "chestToBarPullUp", "muscleUp",
   ("Negative muscle-up", "Negativer Muscle-up"),
   [("Jump into a straight-arm support on top of the bar.", "Spring in den gestreckten Stütz oben auf der Stange."),
    ("Lower yourself slowly, lean forward and turn your wrists back under the bar.", "Lass dich langsam ab, lehn dich nach vorn und dreh die Handgelenke zurück unter die Stange."),
    ("Keep braking all the way down to a full hang.", "Brems weiter, bis du im vollen Hang ankommst.")],
   [("Dropping through the transition.", "Durch den Übergang fallen."),
    ("Letting the shoulders go loose at the bottom.", "Unten die Schultern locker lassen.")])
ex("advancedTuckFrontLever", "skill", "advanced", "advancedTuckFrontLever", "frontLever", "tuckFrontLever", "oneLegFrontLever",
   ("Advanced tuck front lever", "Advanced Tuck Front Lever"),
   [("Get into a tuck front lever under the bar.", "Geh unter der Stange in den Tuck Front Lever."),
    ("Open your hips until your back is flat, knees still bent.", "Streck die Hüfte, bis der Rücken flach ist, die Knie bleiben gebeugt."),
    ("Press the bar down with straight arms and hold.", "Drück die Stange mit gestreckten Armen nach unten und halte.")],
   [("Rounded back.", "Runder Rücken."),
    ("Bending the arms.", "Die Arme beugen.")])
ex("oneLegFrontLever", "skill", "advanced", "oneLegFrontLever", "frontLever", "advancedTuckFrontLever", "straddleFrontLever",
   ("One-leg front lever", "Front Lever mit einem Bein"),
   [("Start in an advanced tuck front lever.", "Beginne im Advanced Tuck Front Lever."),
    ("Stretch one leg out straight while the other stays bent.", "Streck ein Bein gerade aus, das andere bleibt gebeugt."),
    ("Hold with your body level, then switch legs in the next set.", "Halte den Körper waagrecht und wechsle im nächsten Satz das Bein.")],
   [("Hips dropping when the leg goes out.", "Die Hüfte sinkt, wenn das Bein rausgeht."),
    ("Bending the arms.", "Die Arme beugen.")])
ex("straddleFrontLever", "skill", "advanced", "straddleFrontLever", "frontLever", "oneLegFrontLever", "frontLever",
   ("Straddle front lever", "Straddle Front Lever"),
   [("Start in an advanced tuck front lever.", "Beginne im Advanced Tuck Front Lever."),
    ("Stretch both legs out wide to the sides.", "Streck beide Beine weit gegrätscht aus."),
    ("Keep your body level and press the bar down with straight arms.", "Halte den Körper waagrecht und drück die Stange mit gestreckten Armen nach unten.")],
   [("Hips sagging below the shoulders.", "Die Hüfte hängt unter Schulterhöhe."),
    ("Bent knees.", "Gebeugte Knie.")])
ex("frontLever", "skill", "advanced", "frontLever", "frontLever", "straddleFrontLever", None,
   ("Front lever", "Front Lever"),
   [("Hang from the bar and pull it down towards your hips with straight arms.", "Häng an der Stange und drück sie mit gestreckten Armen Richtung Hüfte."),
    ("Raise your whole body, legs together, until it is level.", "Heb den ganzen Körper mit geschlossenen Beinen bis zur Waagrechten."),
    ("Squeeze your belly and glutes and hold.", "Spann Bauch und Po an und halte.")],
   [("Hips dropping below the line.", "Die Hüfte sinkt unter die Linie."),
    ("Bending the arms.", "Die Arme beugen.")])

# --- Legs
ex("gluteBridge", "legs", "beginner", "gluteBridge", "squat", None, "bulgarianSplitSquat",
   ("Glute bridge", "Beckenheben"),
   [("Lie on your back, knees bent, feet flat on the floor hip-width apart.", "Leg dich auf den Rücken, die Knie gebeugt, die Füße hüftbreit flach am Boden."),
    ("Push through your heels and lift your hips until knees, hips and shoulders are in a line.", "Drück dich über die Fersen hoch und heb die Hüfte, bis Knie, Hüfte und Schultern eine Linie bilden."),
    ("Squeeze your glutes at the top, then lower slowly.", "Spann oben den Po an und senk die Hüfte langsam ab.")],
   [("Arching the lower back at the top.", "Oben ins Hohlkreuz gehen."),
    ("Pushing through the toes instead of the heels.", "Über die Zehen statt über die Fersen drücken.")])
ex("wallSit", "legs", "beginner", "wallSit", "squat", None, "squat",
   ("Wall sit", "Wandsitzen"),
   [("Lean your back against a wall and walk your feet forward.", "Lehn dich mit dem Rücken an eine Wand und geh mit den Füßen nach vorn."),
    ("Slide down until your thighs are level and your knees are above your ankles.", "Rutsch nach unten, bis die Oberschenkel waagrecht und die Knie über den Füßen sind."),
    ("Keep your back on the wall and hold.", "Lass den Rücken an der Wand und halte.")],
   [("Knees pushing forward past the toes.", "Die Knie schieben sich über die Zehen hinaus."),
    ("Resting the hands on the thighs.", "Die Hände auf den Oberschenkeln abstützen.")])
ex("jumpSquat", "legs", "intermediate", "jumpSquat", "squat", "squat", None,
   ("Jump squat", "Sprungkniebeuge"),
   [("Stand with feet shoulder-width apart and squat down.", "Stell dich schulterbreit hin und geh in die Kniebeuge."),
    ("Jump up explosively, swinging your arms up.", "Spring explosiv nach oben und schwing die Arme mit."),
    ("Land softly on your whole foot and sink straight into the next squat.", "Lande weich auf dem ganzen Fuß und geh direkt in die nächste Kniebeuge.")],
   [("Landing with stiff legs.", "Mit steifen Beinen landen."),
    ("Knees caving inwards on landing.", "Die Knie knicken bei der Landung nach innen.")])
ex("bulgarianSplitSquat", "legs", "intermediate", "bulgarianSplitSquat", "squat", "lunge", "boxPistol",
   ("Bulgarian split squat", "Bulgarische Kniebeuge"),
   [("Stand a big step in front of a bench and put the top of your back foot on it.", "Stell dich einen großen Schritt vor eine Bank und leg den Rist des hinteren Fußes darauf."),
    ("Lower your back knee towards the floor, upper body upright.", "Senk das hintere Knie Richtung Boden, der Oberkörper bleibt aufrecht."),
    ("Push through your front heel to stand back up.", "Drück dich über die vordere Ferse wieder hoch.")],
   [("Front knee collapsing inwards.", "Das vordere Knie knickt nach innen."),
    ("Standing too close to the bench.", "Zu nah an der Bank stehen.")])
ex("boxPistol", "legs", "intermediate", "boxPistol", "pistolSquat", "bulgarianSplitSquat", "assistedPistol",
   ("Box pistol", "Pistol auf Kasten"),
   [("Stand on one leg in front of a box, the other leg straight out in front.", "Stell dich auf einem Bein vor einen Kasten, das andere Bein gestreckt nach vorn."),
    ("Sit back slowly onto the box, arms reaching forward.", "Setz dich langsam nach hinten auf den Kasten, die Arme nach vorn."),
    ("Stand up on the same leg without rocking.", "Steh auf demselben Bein wieder auf, ohne Schwung.")],
   [("Dropping onto the box.", "Auf den Kasten plumpsen."),
    ("Knee caving inwards.", "Das Knie knickt nach innen.")])
ex("assistedPistol", "legs", "advanced", "assistedPistol", "pistolSquat", "boxPistol", "pistolSquat",
   ("Assisted pistol", "Pistol mit Hilfe"),
   [("Stand on one leg next to a pole or door frame and hold it lightly.", "Stell dich auf einem Bein neben eine Stange oder einen Türrahmen und halt dich leicht fest."),
    ("Sink all the way down on the standing leg, the other leg straight out in front.", "Geh auf dem Standbein ganz nach unten, das andere Bein gestreckt nach vorn."),
    ("Stand back up, using your hands only as much as you need.", "Steh wieder auf und nutz die Hände nur so viel wie nötig.")],
   [("Pulling yourself up with the arms.", "Dich mit den Armen hochziehen."),
    ("Heel of the standing foot lifting.", "Die Ferse des Standbeins hebt ab.")])

# --- Core
ex("hollowHold", "core", "beginner", "hollowHold", "plank", None, None,
   ("Hollow hold", "Hollow Hold"),
   [("Lie on your back and press your lower back into the floor.", "Leg dich auf den Rücken und drück den unteren Rücken in den Boden."),
    ("Lift your shoulders, arms and straight legs a little off the floor.", "Heb Schultern, Arme und gestreckte Beine ein Stück vom Boden ab."),
    ("Hold the banana shape and breathe calmly.", "Halte die Bananenform und atme ruhig weiter.")],
   [("Lower back lifting off the floor.", "Der untere Rücken hebt vom Boden ab."),
    ("Legs too high, which makes it too easy.", "Die Beine zu hoch, dann wird es zu leicht.")])
ex("mountainClimber", "core", "beginner", "mountainClimber", "plank", None, None,
   ("Mountain climber", "Bergsteiger"),
   [("Start in a high plank with your hands under your shoulders.", "Beginne im hohen Stütz, die Hände unter den Schultern."),
    ("Drive one knee towards your chest, then switch legs quickly.", "Zieh ein Knie zur Brust und wechsle dann zügig das Bein."),
    ("Keep your hips low and your shoulders above your hands.", "Halte die Hüfte unten und die Schultern über den Händen.")],
   [("Hips bouncing up and down.", "Die Hüfte hüpft auf und ab."),
    ("Shoulders drifting back behind the hands.", "Die Schultern wandern hinter die Hände.")])
ex("hangingLegRaise", "core", "intermediate", "hangingLegRaise", "lSit", "kneeRaise", None,
   ("Hanging leg raise", "Hängendes Beinheben"),
   [("Hang from the bar with straight arms and active shoulders.", "Häng mit gestreckten Armen und aktiven Schultern an der Stange."),
    ("Raise your straight legs until they are at least level.", "Heb die gestreckten Beine mindestens bis zur Waagrechten."),
    ("Lower them slowly without swinging.", "Senk sie langsam ab, ohne zu schwingen.")],
   [("Swinging back and forth.", "Vor und zurück schwingen."),
    ("Bending the knees to make it easier.", "Die Knie beugen, damit es leichter wird.")])
ex("tuckLSit", "core", "beginner", "tuckLSit", "lSit", None, "lSit",
   ("Tuck L-sit", "Tuck L-Sit"),
   [("Place your hands on parallettes or the floor next to your hips.", "Setz die Hände neben der Hüfte auf Parallettes oder den Boden."),
    ("Press down and lift your hips off the floor.", "Drück dich nach unten weg und heb die Hüfte an."),
    ("Pull your knees up towards your chest and hold, feet off the floor.", "Zieh die Knie Richtung Brust und halte, die Füße in der Luft.")],
   [("Shoulders shrugged up.", "Hochgezogene Schultern."),
    ("Bent elbows.", "Gebeugte Ellbogen.")])


# Plans: id, name, category, level, pose, free, [(exercise, sets, reps|None, seconds|None, rest)]
# Free: the first ten general workouts (docs/SPEC.md "Preis"). The other general workouts
# and all skill workouts are Pro.
PL = []
def plan(id, name, cat, lvl, pose, free, items):
    PL.append(dict(id=id, name=name, category=cat, level=lvl, pose=pose, isFree=free,
                   exercises=[dict(exercise=e, sets=s, reps=r, seconds=sec, rest=rest) for e, s, r, sec, rest in items]))

# --- Free general workouts
plan("pushBasics", ("Push Basics", "Push Basics"), "push", "beginner", "pushUp", True,
     [("kneePushUp", 3, 10, None, 60), ("pushUp", 4, 6, None, 90), ("pikePushUp", 3, 6, None, 90), ("plank", 3, None, 30, 45)])
plan("pullDay", ("Pull Day", "Pull Day"), "pull", "beginner", "pullUp", True,
     [("row", 3, 10, None, 60), ("negativePullUp", 3, 5, None, 90), ("pullUp", 3, 4, None, 120), ("kneeRaise", 3, 10, None, 60)])
plan("corePlank", ("Core & Plank", "Core & Plank"), "core", "beginner", "plank", True,
     [("plank", 3, None, 40, 45), ("kneeRaise", 3, 10, None, 60), ("lSit", 4, None, 10, 60)])
plan("legsNoEquipment", ("Legs without equipment", "Beine ohne Geräte"), "legs", "beginner", "squat", True,
     [("squat", 4, 15, None, 60), ("lunge", 3, 10, None, 60), ("pistolSquat", 3, 3, None, 90)])
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

# --- Pro general workouts: push
plan("pushUpVariety", ("Push-up Variety", "Liegestütz-Mix"), "push", "beginner", "pushUp", False,
     [("inclinePushUp", 3, 12, None, 60), ("pushUp", 3, 8, None, 75), ("diamondPushUp", 3, 5, None, 75), ("benchDip", 3, 10, None, 60)])
plan("chestAndTriceps", ("Chest & Triceps", "Brust & Trizeps"), "push", "intermediate", "pushUp", False,
     [("declinePushUp", 4, 8, None, 90), ("diamondPushUp", 3, 8, None, 75), ("dip", 4, 6, None, 90), ("benchDip", 3, 12, None, 60)])
plan("shoulderBuilder", ("Shoulder Builder", "Schulter-Aufbau"), "push", "intermediate", "handstand", False,
     [("pikePushUp", 4, 8, None, 90), ("elevatedPikePushUp", 3, 6, None, 90), ("declinePushUp", 3, 8, None, 75), ("plank", 3, None, 45, 45)])
plan("dipDay", ("Dip Day", "Dip-Tag"), "push", "advanced", "muscleUp", False,
     [("dip", 5, 8, None, 120), ("diamondPushUp", 4, 10, None, 75), ("declinePushUp", 3, 10, None, 75), ("benchDip", 2, 15, None, 60)])

# --- Pro general workouts: pull
plan("hangStrong", ("Hang Strong", "Stark am Hang"), "pull", "beginner", "pullUp", False,
     [("deadHang", 3, None, 30, 60), ("scapulaPullUp", 3, 8, None, 60), ("row", 3, 10, None, 60), ("kneeRaise", 3, 8, None, 60)])
plan("chinUpDay", ("Chin-up Day", "Chin-up-Tag"), "pull", "intermediate", "pullUp", False,
     [("chinUp", 4, 5, None, 120), ("row", 3, 12, None, 60), ("negativePullUp", 3, 4, None, 90), ("hangingLegRaise", 3, 6, None, 60)])
plan("pullUpVolume", ("Pull-up Volume", "Klimmzug-Volumen"), "pull", "intermediate", "pullUp", False,
     [("pullUp", 5, 6, None, 120), ("chinUp", 3, 6, None, 120), ("scapulaPullUp", 3, 10, None, 60), ("deadHang", 2, None, 45, 60)])
plan("pullPower", ("Pull Power", "Zug-Power"), "pull", "advanced", "pullUp", False,
     [("chestToBarPullUp", 5, 4, None, 150), ("pullUp", 3, 8, None, 120), ("hangingLegRaise", 3, 10, None, 60), ("scapulaPullUp", 2, 12, None, 60)])

# --- Pro general workouts: legs
plan("legBasics", ("Leg Basics", "Bein-Basics"), "legs", "beginner", "squat", False,
     [("squat", 3, 15, None, 60), ("gluteBridge", 3, 15, None, 45), ("lunge", 3, 10, None, 60), ("wallSit", 3, None, 30, 60)])
plan("wallSitBurner", ("Wall Sit Burner", "Wandsitz-Brenner"), "legs", "beginner", "squat", False,
     [("wallSit", 4, None, 40, 60), ("squat", 3, 20, None, 60), ("gluteBridge", 3, 20, None, 45)])
plan("jumpAndBurn", ("Jump & Burn", "Springen & Brennen"), "legs", "intermediate", "squat", False,
     [("jumpSquat", 4, 10, None, 75), ("squat", 3, 20, None, 60), ("lunge", 3, 12, None, 60), ("wallSit", 2, None, 45, 60)])
plan("singleLegStrength", ("Single-Leg Strength", "Einbeinige Kraft"), "legs", "intermediate", "pistolSquat", False,
     [("bulgarianSplitSquat", 4, 8, None, 90), ("boxPistol", 3, 5, None, 90), ("gluteBridge", 3, 15, None, 45)])
plan("legPower", ("Leg Power", "Bein-Power"), "legs", "advanced", "pistolSquat", False,
     [("jumpSquat", 4, 12, None, 75), ("bulgarianSplitSquat", 4, 10, None, 90), ("pistolSquat", 3, 5, None, 120), ("wallSit", 2, None, 60, 60)])

# --- Pro general workouts: core
plan("coreBasics", ("Core Basics", "Core-Basics"), "core", "beginner", "plank", False,
     [("plank", 3, None, 30, 45), ("hollowHold", 3, None, 20, 45), ("mountainClimber", 3, 20, None, 45)])
plan("hollowBody", ("Hollow Body", "Hollow Body"), "core", "beginner", "plank", False,
     [("hollowHold", 4, None, 25, 45), ("tuckLSit", 3, None, 10, 60), ("plank", 3, None, 40, 45), ("mountainClimber", 3, 20, None, 45)])
plan("hangingCore", ("Hanging Core", "Core am Hang"), "core", "intermediate", "lSit", False,
     [("deadHang", 2, None, 30, 60), ("kneeRaise", 3, 12, None, 60), ("hangingLegRaise", 4, 6, None, 75)])
plan("coreBurner", ("Core Burner", "Core-Brenner"), "core", "intermediate", "plank", False,
     [("mountainClimber", 4, 30, None, 45), ("hollowHold", 4, None, 30, 45), ("plank", 3, None, 60, 60), ("kneeRaise", 3, 12, None, 60)])
plan("coreAdvanced", ("Core Advanced", "Core für Fortgeschrittene"), "core", "advanced", "lSit", False,
     [("hangingLegRaise", 4, 10, None, 75), ("lSit", 4, None, 20, 60), ("hollowHold", 3, None, 45, 45), ("plank", 2, None, 90, 60)])

# --- Skill workouts (Pro), one per stage from easy to hard
plan("frontLeverBuildUp", ("Front lever build-up", "Front-Lever-Aufbau"), "skill", "advanced", "frontLever", False,
     [("pullUp", 4, 6, None, 120), ("kneeRaise", 3, 12, None, 60), ("tuckFrontLever", 5, None, 10, 90), ("row", 3, 12, None, 60)])
plan("frontLeverAdvancedTuck", ("Front lever: advanced tuck", "Front Lever: Advanced Tuck"), "skill", "advanced", "frontLever", False,
     [("tuckFrontLever", 2, None, 12, 90), ("advancedTuckFrontLever", 5, None, 8, 120), ("pullUp", 3, 6, None, 120), ("hangingLegRaise", 3, 6, None, 75)])
plan("frontLeverOneLeg", ("Front lever: one leg", "Front Lever: ein Bein"), "skill", "advanced", "frontLever", False,
     [("advancedTuckFrontLever", 3, None, 10, 90), ("oneLegFrontLever", 6, None, 6, 120), ("chestToBarPullUp", 3, 4, None, 150), ("hollowHold", 3, None, 30, 45)])
plan("frontLeverStraddle", ("Front lever: straddle", "Front Lever: Straddle"), "skill", "advanced", "frontLever", False,
     [("oneLegFrontLever", 3, None, 8, 120), ("straddleFrontLever", 5, None, 5, 150), ("pullUp", 3, 8, None, 120), ("hangingLegRaise", 3, 10, None, 75)])
plan("frontLeverFull", ("Front lever: full", "Front Lever: voll"), "skill", "advanced", "frontLever", False,
     [("straddleFrontLever", 3, None, 6, 150), ("frontLever", 5, None, 4, 150), ("chestToBarPullUp", 3, 5, None, 150), ("hollowHold", 3, None, 45, 45)])

plan("handstandSchool", ("Handstand school", "Handstand-Schule"), "skill", "beginner", "handstand", False,
     [("pikePushUp", 3, 8, None, 90), ("plank", 3, None, 30, 45), ("wallHandstand", 4, None, 20, 60)])
plan("handstandElevated", ("Handstand push-up: elevated pike", "Handstand-Liegestütz: erhöhter Pike"), "skill", "intermediate", "handstand", False,
     [("pikePushUp", 3, 8, None, 90), ("elevatedPikePushUp", 4, 6, None, 90), ("wallHandstand", 3, None, 20, 60), ("hollowHold", 3, None, 20, 45)])
plan("handstandWallHold", ("Handstand push-up: wall hold", "Handstand-Liegestütz: an der Wand halten"), "skill", "intermediate", "handstand", False,
     [("wallHandstand", 5, None, 30, 75), ("elevatedPikePushUp", 4, 8, None, 90), ("declinePushUp", 3, 8, None, 75)])
plan("handstandHalf", ("Handstand push-up: half range", "Handstand-Liegestütz: halber Weg"), "skill", "advanced", "handstand", False,
     [("wallHandstand", 3, None, 30, 75), ("halfWallHandstandPushUp", 5, 5, None, 120), ("elevatedPikePushUp", 3, 8, None, 90)])
plan("handstandFull", ("Handstand push-up: full range", "Handstand-Liegestütz: ganzer Weg"), "skill", "advanced", "handstand", False,
     [("halfWallHandstandPushUp", 3, 5, None, 120), ("wallHandstandPushUp", 5, 3, None, 150), ("wallHandstand", 3, None, 40, 75)])

plan("pistolDeepSquat", ("Pistol squat: deep squat", "Pistol Squat: tiefe Kniebeuge"), "skill", "beginner", "pistolSquat", False,
     [("squat", 4, 15, None, 60), ("wallSit", 3, None, 40, 60), ("gluteBridge", 3, 15, None, 45)])
plan("pistolLunge", ("Pistol squat: lunges", "Pistol Squat: Ausfallschritte"), "skill", "beginner", "pistolSquat", False,
     [("lunge", 4, 10, None, 60), ("bulgarianSplitSquat", 3, 8, None, 90), ("squat", 3, 20, None, 60)])
plan("pistolBox", ("Pistol squat: box", "Pistol Squat: Kasten"), "skill", "intermediate", "pistolSquat", False,
     [("bulgarianSplitSquat", 3, 8, None, 90), ("boxPistol", 5, 5, None, 90), ("wallSit", 2, None, 45, 60)])
plan("pistolAssisted", ("Pistol squat: assisted", "Pistol Squat: mit Hilfe"), "skill", "advanced", "pistolSquat", False,
     [("boxPistol", 3, 6, None, 90), ("assistedPistol", 5, 5, None, 120), ("jumpSquat", 3, 8, None, 75)])
plan("pistolFull", ("Pistol squat: full", "Pistol Squat: voll"), "skill", "advanced", "pistolSquat", False,
     [("assistedPistol", 3, 5, None, 120), ("pistolSquat", 5, 3, None, 150), ("bulgarianSplitSquat", 3, 10, None, 90)])

plan("muscleUpPullUps", ("Muscle-up: pull-ups", "Muscle-up: Klimmzüge"), "skill", "intermediate", "muscleUp", False,
     [("pullUp", 5, 6, None, 120), ("chinUp", 3, 6, None, 120), ("scapulaPullUp", 3, 10, None, 60), ("hangingLegRaise", 3, 8, None, 75)])
plan("muscleUpChestToBar", ("Muscle-up: chest to bar", "Muscle-up: bis zur Brust"), "skill", "advanced", "muscleUp", False,
     [("pullUp", 3, 8, None, 120), ("chestToBarPullUp", 5, 4, None, 150), ("dip", 3, 8, None, 90)])
plan("muscleUpDips", ("Muscle-up: dips", "Muscle-up: Dips"), "skill", "advanced", "muscleUp", False,
     [("dip", 5, 10, None, 120), ("chestToBarPullUp", 4, 5, None, 150), ("diamondPushUp", 3, 10, None, 75)])
plan("muscleUpNegatives", ("Muscle-up: negatives", "Muscle-up: Negative"), "skill", "advanced", "muscleUp", False,
     [("chestToBarPullUp", 3, 5, None, 150), ("negativeMuscleUp", 5, 3, None, 150), ("dip", 3, 10, None, 90)])
plan("muscleUpPath", ("Muscle-up path", "Muscle-up-Weg"), "skill", "advanced", "muscleUp", False,
     [("pullUp", 4, 6, None, 120), ("dip", 4, 8, None, 90), ("negativePullUp", 3, 5, None, 90), ("muscleUp", 5, 2, None, 150)])

plan("plankChallenge", ("Plank challenge", "Plank-Challenge"), "skill", "intermediate", "plank", False,
     [("plank", 4, None, 90, 90), ("hollowHold", 3, None, 30, 45), ("mountainClimber", 3, 20, None, 45)])
plan("lSitLab", ("L-sit lab", "L-Sit-Labor"), "skill", "intermediate", "lSit", False,
     [("tuckLSit", 4, None, 15, 60), ("lSit", 5, None, 10, 75), ("hangingLegRaise", 3, 8, None, 75), ("hollowHold", 3, None, 30, 45)])

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

goal("frontLever", ("Front lever", "Front Lever"), "frontLever", "tuckFrontLever", ["frontLeverBuildUp", "frontLeverAdvancedTuck", "frontLeverOneLeg", "frontLeverStraddle", "frontLeverFull"], False,
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
goal("plank5Min", ("Plank 5 min", "Plank 5 min"), "plank", "plank", ["corePlank", "coreStrength", "plankChallenge"], False,
     ("Your deep belly muscles wrap around you like a corset, your six-pack muscles keep the line, and your shoulders and glutes quietly help out.",
      "Deine tiefen Bauchmuskeln legen sich wie ein Korsett um dich, die geraden Bauchmuskeln halten die Linie, und Schultern und Po helfen leise mit."),
     ("Five whole minutes, straight as a board on your forearms. It sounds simple, but it builds a trunk with staying power, better posture, and a happier lower back in everyday life.",
      "Fünf ganze Minuten, gerade wie ein Brett auf den Unterarmen. Klingt einfach, schenkt dir aber einen Rumpf mit Ausdauer, eine bessere Haltung und einen zufriedeneren unteren Rücken im Alltag."),
     seconds=300)
goal("handstandPushUp", ("Handstand push-up", "Handstand-Liegestütz"), "handstand", "pikePushUp", ["handstandSchool", "handstandElevated", "handstandWallHold", "handstandHalf", "handstandFull"], False,
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
goal("lSit30", ("L-sit 30 s", "L-Sit 30 s"), "lSit", "lSit", ["corePlank", "coreStrength", "lSitLab"], False,
     ("Your hip flexors and belly lift your legs, while your triceps and shoulders push you up and away from the floor.",
      "Hüftbeuger und Bauch heben deine Beine, während Trizeps und Schultern dich nach oben und weg vom Boden drücken."),
     ("Thirty seconds sitting in the air, legs straight out in front of you like a capital L. It builds wonderful compression strength and steady shoulders, a great base for many gymnastics moves.",
      "Dreißig Sekunden in der Luft sitzen, die Beine gestreckt vor dir wie ein großes L. Das schenkt dir tolle Kompressionskraft und ruhige Schultern, eine prima Basis für viele Turnelemente."),
     seconds=30)
goal("pistolSquat", ("Pistol squat", "Pistol Squat"), "pistolSquat", "pistolSquat", ["pistolDeepSquat", "pistolLunge", "pistolBox", "pistolAssisted", "pistolFull"], False,
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
goal("muscleUp", ("Muscle-up", "Muscle-up"), "muscleUp", "muscleUp", ["muscleUpPullUps", "muscleUpChestToBar", "muscleUpDips", "muscleUpNegatives", "muscleUpPath"], False,
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
