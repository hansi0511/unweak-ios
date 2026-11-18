# Spezifikation Version 1

Stand: 16. November 2026. Alle Punkte unter „Entschieden“ stammen von Hansi.

## Entschieden

| Thema | Entscheidung |
|---|---|
| Name | Unweak, Untertitel „Progress from week to week“. Marken- und Domainprüfung steht noch aus. |
| Plattformen | Zwei native Apps. Zuerst iOS (dieses Repository), danach Android als Nachbau. |
| Umfang | Mit Wochen-Liga und Duell (`docs/SOCIAL.md`). Ohne Influencer-Tab; der kommt nur bei Erfolg als Version 2. |
| Konto | Von Anfang an, Anmeldung mit Apple oder Google. Fortschritt wird im Konto gesichert. |
| Preis | Gratis: 10 Workouts und bis zu 3 eigene Workouts, keine Skills. Pro-Abo (4,90 pro Monat oder 29,90 pro Jahr, Euro und Dollar): alle Workouts, alle Skills mit ihren Workouts, Skills als Ziel, unbegrenzt eigene Workouts. |
| Server | Firebase (Anmeldung mit Apple und Google, Sicherung der Daten). |
| Sprachen | Deutsch und Englisch. |
| Stil | Futuristischer HUD-Look, Sticky Man als zentrales Element für alle Übungen. |
| Erinnerungen | Der Nutzer wählt Trainingstage und Uhrzeit selbst. Die Mitteilung kommt nur an diesen Tagen. |
| Farbe | Sechs wählbare Akzentfarben. |
| Avatar | Der Sticky Man ist der Avatar des Nutzers. Er wächst mit dem Training (Start, Athlet ab 10 Trainings, Trainiert ab 50, Legende nach dem ersten gemeisterten Skill). Farbe, zweite Farbe, Grund und Extras sind frei kombinierbar und unabhängig von der Akzentfarbe. Extras werden über Erfolge und Skills freigeschaltet. Alles gratis. Kaufbare Skins (Extras, Farb-Kombinationen, Körper-Looks) kommen in einem späteren Schritt. |
| Skills | Skills (z. B. Front Lever, Muscle-up) sind im Workouts-Tab hervorgehoben und von den Workouts getrennt. Ein Skill ist zugleich das Ziel: Wer einen Skill lernt, bekommt die passenden Workouts. Mehrere Skills lassen sich gleichzeitig lernen. Vorerst die sechs bestehenden Skills. |
| Wochenziel | Anzahl der Trainingstage aus der Erinnerung (Standard 3). Eine Woche zählt zur Serie, wenn das Ziel erreicht ist. |
| Eigene Workouts | Lassen sich auch bearbeiten und löschen (mit Rückfrage); Tagebucheinträge bleiben erhalten. |
| Sprache in der App | Standard ist die Sprache des iPhones; in den Einstellungen lässt sie sich auf DE oder EN umstellen. |
| Teilen | Fertiges Workout, Rekord, Erfolg, Serie/Woche und Skill-Fortschritt im HUD-Look, als Video (MP4-Schleife mit animiertem Sticky Man, Standard) oder Bild, jeweils als Story 9:16 oder Post 4:5, über das iOS-Teilen-Menü, z. B. zu X, Facebook und Instagram. Keine eigenen Konten bei Meta oder X nötig. |
| Veröffentlichung | Über Hansis eigenes Entwicklerkonto. |

## Funktionen

1. **Ich** (erster Tab), Oberfläche nach `docs/DESIGN-V2.md` §1: atmender Avatar mit Wochenring (ein Bogen pro Training des Wochenziels), „2 von 3 Trainings diese Woche“ und die Serie; ein Tipp auf den Avatar öffnet den Ich-Bereich. Karte „Heute dran“ mit dem nächsten Workout (mit Pro aus den gelernten Skills, gratis aus den Gratis-Workouts) und „Starten“. Mit Pro bei einem gelernten Skill die Zeile „Dein Ziel: …“, bei mehreren „Deine Ziele“ mit einer Zeile pro Skill untereinander; gratis „Skills · PRO“.
11. **Ich-Bereich** (Tipp auf den Avatar), Oberfläche nach `docs/DESIGN-V2.md` §12: Level des Avatars mit Balken und dem Weg zum nächsten Körper; Reiter Körper, Farben, Extras zum Anpassen (Körper automatisch oder ein erreichter, Farbe der Figur und des Extras, Grund Dunkel/Nacht/Invertiert, ein Extra). Gesperrtes zeigt seine Bedingung erst beim Antippen. Rechts oben die Einstellungen.
2. **Workouts**, Oberfläche nach `docs/DESIGN-V2.md` §2–§4: „Für dich“ mit zwei vorgeschlagenen Workouts, „Nach Bereich“ mit Push, Pull, Beine, Core (je ein eigener Screen mit den eigenen Workouts zuerst und den Plänen dieses Bereichs; Pro-Pläne führen ohne Abo zur Abo-Seite), Karte „Skills“ zur Skills-Seite (ohne Pro führen die Kacheln zur Abo-Seite). Plus oben rechts: eigenes Workout (gratis bis zu 3). Zehn allgemeine Workouts sind gratis, die übrigen allgemeinen Workouts gehören zu Pro.
3. **Training**, Oberfläche nach `docs/DESIGN-V2.md` §6: eine Übung pro Bildschirm mit einer großen Zahl (Wiederholungen oder Sekunden), Satz-Punkte, Hauptknopf „Satz geschafft“; danach startet die Pause von selbst (Restzeit groß, „Pause überspringen“), nach dem letzten Satz „Nächste Übung“ bzw. „Training abschließen“. Danach „Training geschafft“ (§8) mit Minuten, Übungen, Rekorden, Bewertung, Notiz und „Speichern“; ✕ speichert direkt nach dem Training ebenfalls.
4. **Technik** (Übungsdetail), Oberfläche nach `docs/DESIGN-V2.md` §7: Animation, drei kurze Schritte, ein Hinweis auf den häufigsten Fehler, leichtere und schwerere Variante.
5. **Eigenes Workout**, Oberfläche nach `docs/DESIGN-V2.md` §15: Name, Bereich (Push, Pull, Beine, Core), Übungen aus dem Katalog mit Dosis („4 × 6“; Antippen zeigt Sätze und Ziel zum Anpassen), Minus zum Entfernen, „+ Übung hinzufügen“, „Speichern“. Gratis bis zu 3, mit Pro unbegrenzt.
6. **Journey** (früher Tagebuch, Name in beiden Sprachen), Oberfläche nach `docs/DESIGN-V2.md` §9–§10: „Diese Woche“ mit sieben Tages-Kreisen, drei Gesamtzahlen (Trainings, Stunden, Rekorde), Zeile „Erfolge“ zur Erfolge-Seite (alle zwölf, erreichte teilbar), „Letzte Trainings“ mit Marke „Rekord“. Plus oben rechts trägt ein Training nach. Eintrag als „Training geschafft“ (§8) mit Bewertung (leicht, passt, hart), Notiz und eingeklappt „Werte anpassen“ (daraus entstehen Rekorde).
7. **Ziele = Skills**, Skill-Seite nach `docs/DESIGN-V2.md` §5: beliebig viele Skills gleichzeitig, aufzunehmen mit „Als Ziel wählen“ oben auf der Skill-Seite. „Dein Weg“ zeigt die fünf Stufen als Kacheln; ein Tipp öffnet das Info-Fenster der Stufe (Muskeln, Ausführung, Schalter „Beherrscht“ zum Zurücknehmen). „Jetzt dran“ nennt die aktuelle Stufe mit einem Satz, was zu tun ist, und „Geschafft“. Zeit-Skills (Plank 5 min, L-Sit 30 s) übernehmen die Bestzeit aus der Journey. Jede Stufe hat eine eigene Sticky-Man-Animation. „Passendes Workout starten“ startet das Workout des Skills, das zur aktuellen Stufe passt (die Workouts des Skills von leicht nach schwer verteilt auf die fünf Stufen).
8. **Einstellungen** (Regler-Symbol im Ich-Bereich), Oberfläche nach `docs/DESIGN-V2.md` §13: Konto, Abo, Trainingserinnerung mit Tagen und Uhrzeit, Farbe, Sprache, Rechtliches, Abmelden, Konto löschen.
9. **Teilen**, Oberfläche nach `docs/DESIGN-V2.md` §11: aus „Training geschafft“ (Workout) und der Erfolge-Seite (erreichte Erfolge). Wahl Video oder Bild, Format Story (Post bleibt im Code für später), dann das iOS-Teilen-Menü.
10. **Anmeldung und Abo-Seite.** Abo-Seite nach `docs/DESIGN-V2.md` §14: drei Vorteile, Jahr oder Monat als Kacheln, „Pro starten“, „Käufe wiederherstellen“, „Jederzeit kündbar“ (dazu klein der Hinweis zur automatischen Verlängerung, den der App Store verlangt). Abo mit StoreKit 2, Abo verwalten. Der Anmelde-Screen (§16) kommt zusammen mit der Anmeldung (Schritt 6).

## Inhalte

Quelle ist `tools/content/content.py`; daraus entstehen `Catalog.json` und `Catalog.xcstrings`. Geräte: Klimmzugstange, Barren (oder zwei Stühle), Wand, Kasten oder Bank. Ringe und Bänder kommen nicht vor.

- **Übungen:** 42, jede mit eigener Sticky-Man-Animation (einige Varianten teilen sich eine, z. B. Klimmzug und Chin-up), drei Schritten und typischen Fehlern.
- **Workouts:** 50. Allgemein je 7 für Push, Pull, Beine und Core (28), davon 10 gratis (Push Basics, Pull Day, Core & Plank, Beine ohne Geräte, Push-Ausdauer, Push-Kraft, Rudern & Hängen, Zugkraft, Beine Plus, Core-Kraft). Dazu 22 Skill-Workouts: je eins pro Stufe für Front Lever, Handstand-Liegestütz, Pistol Squat und Muscle-up, eins für Plank 5 min und L-Sit 30 s.
- **Skills:** Front Lever, Plank 5 min, Handstand-Liegestütz, L-Sit 30 s, Pistol Squat, Muscle-up (Abo).
- **Erfolge:** zwölf, z. B. 10 Klimmzüge, Plank 3 min, L-Sit 20 s, 25 Trainings.

## Offene Punkte

Vor dem jeweiligen Schritt mit Hansi klären.

- **Server:** Firebase ist gewählt; Projekt anlegen und einrichten (Schritt 6).
- **Inhalte:** Katalog steht als Entwurf (siehe „Inhalte“); Sätze, Wiederholungen, Haltezeiten und Texte fachlich prüfen.
- **Technik:** Bundle-ID und Produkt-IDs der Abos sind noch Platzhalter (`com.example.unweak`, `com.example.unweak.pro.monthly` / `.yearly`). Niedrigste iOS-Version: 17.
- **Recht:** Datenschutzerklärung, Nutzungsbedingungen, Impressum, Gesundheitshinweis.
- **Name:** Prüfung von Marke, Domain und Store-Verfügbarkeit.
- **Avatar-Skins:** welche Skins es zu kaufen gibt, Preise und Produkt-IDs (eigener Schritt nach dem Avatar).

## Nicht in Version 1

Influencer-Tab, Folgen, Feed, eigene Workouts teilen, Moderation von Inhalten (außer Anzeigenamen), Anbindung an Apple Health.
