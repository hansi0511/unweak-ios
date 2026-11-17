# Design V2: übersichtlicher für Neulinge

Stand: 17. November 2026. Hansi hat V2 freigegeben. V2 ersetzt die Oberfläche aus `docs/SCREENS.md`; Daten, Logik, Freischalt-Regeln und Preise bleiben, wie sie sind.

Referenz: das Mockup „Unweak – App-Mockup“, Seite „V2 · übersichtlicher“ (bei Hansi). Die 16 Screens liegen als Quelltext in `docs/mockup-v2/` (HTML, nur zum Nachschlagen von Maßen, Texten und Reihenfolge; nicht bauen oder einbinden).

## Regeln

1. **Eine Hauptaufgabe pro Screen.** Genau ein Hauptknopf (Akzentfläche, 56 bis 64 pt hoch), unten oder in einer Karte.
2. **Sätze statt Labels.** Keine Mono-Großbuchstaben-Labels über Abschnitten. Abschnittstitel in Space Grotesk 18 pt, normale Schreibweise („Für dich“, „Dein Weg“). JetBrains Mono nur noch für die Marken „PRO“, „GRATIS“ und Hashtags.
3. **Details erst auf Antippen.** Bedingungen, Muskeln, Erklärungen und Varianten stehen nicht dauerhaft auf dem Screen.
4. **Weniger Zahlen.** Höchstens drei Kennzahlen pro Screen.
5. **Keine Umschalter für Bereiche.** Statt „Skills | Workouts“ und „Stats | Achievements“ eigene Einträge, die auf eigene Screens führen. Ausnahme: der Ich-Bereich (Körper, Farben, Extras).
6. **Fortschritt als Bild.** Ringe, Segmente, Tages-Kreise und Stufen-Kacheln statt Text wie „Stufe 2 / 5 · Advanced Tuck“.
7. Farben, Schriften, Bausteine und Sticky Man wie in `docs/DESIGN.md`. Eckmarkierungen nur noch auf der wichtigsten Karte eines Screens.

## Navigation

Drei Tabs wie bisher: Ich, Workouts, Journey.

| Von | Auslöser | Nach |
|---|---|---|
| Anmeldung | Mit Apple / Google anmelden | Ich |
| Ich | Avatar mit Ring | Ich-Bereich |
| Ich | „Starten“ in „Heute dran“ | Training |
| Ich | Zeile „Dein Ziel“ | Skill |
| Workouts | Karte in „Für dich“ | Training |
| Workouts | Kachel in „Nach Bereich“ | Workouts eines Bereichs |
| Workouts | Karte „Skills“ | Skills |
| Workouts | Plus oben rechts | Neues Workout |
| Workouts eines Bereichs | Karte | Training |
| Skills | Kachel | Skill |
| Skill | „Passendes Workout starten“ | Training |
| Training | „?“ oben rechts | Technik |
| Training | „Training abschließen“ nach dem letzten Satz der letzten Übung | Training geschafft |
| Training geschafft | „Speichern“ | Journey |
| Training geschafft | Teilen-Symbol | Teilen |
| Journey | Zeile „Erfolge“ | Erfolge |
| Journey | Training in der Liste | Training geschafft (als Eintrag) |
| Journey | Plus oben rechts | Training geschafft (nachtragen) |
| Erfolge | Erreichter Erfolg | Teilen |
| Ich-Bereich | Regler-Symbol oben rechts | Einstellungen |
| Einstellungen | Zeile „Abo“ | Abo |
| Einstellungen | „Abmelden“ | Anmeldung |

## Screens

### 1 Ich (Tab) — `V2-Ich`
- Titel „Ich“, sonst nichts im Kopf (Teilen der Woche wandert zu „Training geschafft“ und „Erfolge“).
- Avatar 190 pt mit Wochenring (Bögen = Wochenziel). Darunter „**2 von 3** Trainings diese Woche“ (Zahl in Akzentfarbe) und klein „3 Wochen in Folge geschafft“. Antippen öffnet den Ich-Bereich.
- Karte „Heute dran“: Pose, Workout-Name groß, „21 min · 4 Übungen“, Hauptknopf „Starten“. Es ist das erste der bisherigen „nächsten Workouts“; das Karussell entfällt.
- Eine Zeile „Dein Ziel: Front Lever“ mit „2 / 5“ und Segmenten, nur mit Pro und gewähltem Skill. Mehrere gelernte Skills: nur der erste; die übrigen auf der Skills-Seite. Gratis: dieselbe Zeile als „Skills · Pro“ zur Abo-Seite.

### 2 Workouts (Tab) — `V2-Workouts`
- Titel, rechts Plus (Neues Workout).
- „Für dich“: zwei große Karten (erste mit Akzentrahmen und gefülltem Play-Knopf), aus denselben Vorschlägen wie „Heute dran“.
- „Nach Bereich“: 2 × 2 Kacheln Push, Pull, Beine, Core mit Pose und Anzahl Workouts.
- Karte „Skills · PRO“ mit einem Satz („Front Lever, Muscle-up & Co. in 5 Stufen“).
- Eigene Workouts erscheinen in „Nach Bereich“ bei ihrem Bereich, zuerst und mit Marke „Eigenes“.

### 3 Workouts eines Bereichs — `V2-Bereich`
- Zurück, Titel („Pull“), ein Satz („Für Rücken und Arme“). Karten mit Pose, Name, „Dauer · Niveau“ und Play-Symbol.

### 4 Skills — `V2-Skills`
- Zurück, Marke „PRO“, Titel, Satz „Wähle ein Ziel. Du lernst es in 5 Stufen.“
- 2 Spalten, je Skill eine Kachel: Pose, Name, fünf Segmente. Gewählter Skill mit Akzentrahmen und „Dein Ziel“. Ohne Pro führt jede Kachel zur Abo-Seite.

### 5 Skill — `V2-Skill`
- Zurück, rechts Knopf „✓ Mein Ziel“ bzw. „Als Ziel wählen“. Titel.
- Panel mit Animation.
- „Dein Weg“ mit „Stufe 3 von 5“: fünf Stufen-Kacheln in einer Reihe (erreicht gefüllt, aktuelle mit 2 pt Rahmen, spätere gedimmt). Antippen einer Kachel öffnet das bestehende Info-Fenster der Stufe.
- Karte „Jetzt dran“: Name der aktuellen Stufe, ein Satz, was zu tun ist, gestrichelter Knopf „Geschafft“ (markiert die Stufe). Zurücknehmen nur noch im Info-Fenster der Stufe. Nach der letzten Stufe „Gemeistert!“.
- Hauptknopf „Passendes Workout starten“ (erstes Workout des Skills, das zur aktuellen Stufe passt). Die Liste „Workouts für diesen Skill“ entfällt.
- Die Sätze für „Jetzt dran“ brauchen neue Texte je Stufe (DE und EN). Die Haltezeiten im Mockup sind Platzhalter und müssen fachlich geprüft werden.

### 6 Training — `V2-Training`
- Kopf: Schließen, Fortschritt der Übungen als Segmente, „?“ (Technik).
- Übungsname, große Animation, darunter **eine** große Zahl (Wiederholungen oder Sekunden) mit Einheit.
- Satz-Punkte und „Satz 3 von 4“.
- Hauptknopf „Satz geschafft“. Danach startet die Pause automatisch: die große Zahl zeigt die Restzeit, Knopf „Pause überspringen“. Nach dem letzten Satz der letzten Übung „Training abschließen“.
- Die Zeile „Als Nächstes“ entfällt.

### 7 Technik — `V2-Uebung`
- Schließen, Titel, Animation, drei kurze Schritte (eine Zeile je Schritt), ein Hinweis mit Warn-Symbol, zwei Kacheln „Zu schwer?“ / „Zu leicht?“.

### 8 Training geschafft — `V2-Fertig`
- Ersetzt den Tagebucheintrag. Schließen, Teilen-Symbol.
- Haken im Akzentkreis, „Pull Day geschafft“, Datum.
- Drei Zahlen: Minuten, Übungen, Rekorde. Darunter, falls vorhanden, „Neuer Rekord: 6 Klimmzüge“.
- „Wie war's?“ mit Leicht / Passt / Hart. „+ Notiz hinzufügen“ öffnet erst dann das Feld.
- Hauptknopf „Speichern“.

### 9 Journey (Tab) — `V2-Journey`
- Titel, rechts Plus (Training nachtragen).
- Karte „Diese Woche“: sieben Tages-Kreise Mo bis So (trainiert gefüllt, heute hell umrandet), rechts „2 von 3“.
- Eine Zeile mit drei Zahlen: Trainings gesamt, Stunden, Rekorde.
- Zeile „Erfolge · 4 von 12“ mit Balken.
- „Letzte Trainings“: Pose, Name, „Mi, 11. Nov · 36 min“, Marke „Rekord“ falls vorhanden.
- Die Rekord-Reihe entfällt hier; Rekorde zeigt „Training geschafft“.

### 10 Erfolge — `V2-Erfolge`
- Zurück, Titel, „4 von 12 geschafft“. 3 Spalten, Wert groß und Bezeichnung; offene gedimmt. Erreichte öffnen Teilen.

### 11 Teilen — `V2-Teilen`
- Schließen, Titel, nur noch Umschalter Video / Bild. Das Format ist standardmäßig Story; Post bleibt als Option im Code, wird aber im Screen nicht mehr angeboten (später entscheiden).
- Vorschau: „UNWEAK“, Animation, Art, Titel, eine Zeile Kennzahlen, Hashtags. Hauptknopf „Teilen“.

### 12 Ich-Bereich — `V2-Profil`
- Zurück, rechts Regler-Symbol (Einstellungen).
- Avatar 132 pt neben „Level · Athlet“, Balken und „Noch 32 Trainings bis Trainiert“. Die Liste der vier Level entfällt.
- Drei Reiter **Körper**, **Farben**, **Extras**; immer nur einer offen.
  - Körper und Extras: 3-spaltige Kacheln mit großer Vorschau und Name; gesperrte gedimmt mit Schloss, ohne Text. Antippen einer gesperrten Kachel zeigt die Bedingung in einer Zeile unter dem Raster („Gesperrt: Ab 50 Trainings“).
  - Farben: „Figur“ und „Extra“ je sieben Farbkreise, „Hintergrund“ Dunkel / Nacht / Invertiert.

### 13 Einstellungen — `V2-Einstellungen`
- Gruppierte Zeilen ohne Erklärtexte: Konto (Apple), Abo (Gratis ›), Erinnerung mit Schalter und darunter, wenn an, sieben runde Tages-Knöpfe und die Uhrzeit mit − / +, Farbe (sechs Kreise), Sprache (DE / EN), Rechtliches ›.
- Unten als Textknöpfe „Abmelden“ und „Konto löschen“ (rot, mit Rückfrage).

### 14 Abo — `V2-Abo`
- Schließen, Marke „PRO“, Sticky Man über der Stange, Titel „Alle Skills freischalten“, „10 Workouts bleiben immer gratis.“
- Drei Vorteile in je drei Wörtern. Auswahl Jahr / Monat, Hauptknopf „Pro starten“, darunter „Käufe wiederherstellen“ und „Jederzeit kündbar“.

### 15 Neues Workout — `V2-Erstellen`
- Abbrechen, Titel, Name, Bereich (Push / Pull / Beine / Core), Übungen mit Minus-Knopf, gestrichelt „+ Übung hinzufügen“, Hauptknopf „Speichern“.

### 16 Anmeldung — `V2-Login`
- Sprachwahl, große Front-Lever-Animation, „Unweak“, „Progress from week to week.“, die zwei Anmelde-Knöpfe, Links zu Nutzungsbedingungen und Datenschutz.

## Offen

- Erster Start für Neulinge (drei Fragen: Ziel, Niveau, Trainingstage) ist noch nicht entworfen.
- Texte „Jetzt dran“ je Skill-Stufe fehlen.
