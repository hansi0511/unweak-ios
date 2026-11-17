# Spezifikation Version 1

Stand: 16. November 2026. Alle Punkte unter „Entschieden“ stammen von Hansi.

## Entschieden

| Thema | Entscheidung |
|---|---|
| Name | Unweak, Untertitel „Progress from week to week“. Marken- und Domainprüfung steht noch aus. |
| Plattformen | Zwei native Apps. Zuerst iOS (dieses Repository), danach Android als Nachbau. |
| Umfang | Ohne Influencer-Tab. Der kommt nur bei Erfolg als Version 2. |
| Konto | Von Anfang an, Anmeldung mit Apple oder Google. Fortschritt wird im Konto gesichert. |
| Preis | Gratis: 10 Workouts und bis zu 3 eigene Workouts, keine Skills. Pro-Abo (4,90 pro Monat oder 29,90 pro Jahr, Euro und Dollar): alle Skills mit ihren Workouts, Skills als Ziel, unbegrenzt eigene Workouts. |
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

1. **Ich** (erster Tab), auf einer Seite ohne Scrollen (bis drei Skills): atmender Avatar mit Wochenring (ein Bogen pro Training des Wochenziels), dezent Woche, Serie und Körpername; die fünf nächsten Workouts als Karussell (eine Kachel mittig, Wischen zur nächsten) für alle (mit Pro zuerst aus den gelernten Skills, gratis aus den Gratis-Workouts); mit Pro je gelerntem Skill eine schmale Zeile mit Pose der aktuellen Stufe und Stand, ein Tipp öffnet die Skill-Seite. Gratis statt der Skills ein Hinweis darauf.
11. **Ich-Bereich** (über die Überschrift „Ich“): Level des Avatars mit dem Weg zum nächsten Körper, Avatar anpassen und Einstellungen. **Avatar anpassen:** Körper (automatisch oder ein erreichter), Farbe, zweite Farbe für das Extra, Grund (dunkel, Nacht, invertiert) und ein Extra (Stirnband, Kappe, Visier, Kopfhörer, Medaille, Krone). Gesperrtes zeigt, was es freischaltet.
2. **Workouts:** zwei Bereiche mit Umschalter. **Skills** (zuerst, hervorgehoben, nur mit Pro; in der Gratis-Version führen die Karten zur Abo-Seite): je Skill eine Karte; die Skill-Seite zeigt Animation, Stufen bzw. Bestzeit, „Diesen Skill lernen“ bzw. „Lerne ich“ (ganz oben) und die passenden Workouts von leicht nach schwer. **Workouts**: die 10 allgemeinen Workouts (gratis) und eigene Workouts, filterbar nach Push, Pull, Beine, Core. Workouts, die Pro brauchen, führen ohne Abo zur Abo-Seite.
3. **Training:** eine Übung pro Bildschirm, Sätze abhaken, Pausenzeit, nächste Übung, am Ende Speichern in die Journey.
4. **Übungsdetail:** Animation, Technikschritte, häufige Fehler, leichtere und schwerere Variante.
5. **Eigenes Workout:** Name, Kategorie, Übungen aus dem Katalog hinzufügen und entfernen. Gratis bis zu 3, mit Pro unbegrenzt.
6. **Journey** (früher Tagebuch, Name in beiden Sprachen): Bereich „Stats“ mit den Rekorden jeder Übung als Kacheln ganz oben, den Monatszahlen und darunter den letzten Trainings (Rekorde hervorgehoben); Bereich „Achievements“ mit allen zwölf Erfolgen; Eintrag mit Übungen, Bewertung (leicht, passt, hart) und Notiz.
7. **Ziele = Skills:** beliebig viele Skills gleichzeitig, aufzunehmen mit „Diesen Skill lernen“ auf der Skill-Karte im Workouts-Tab oder ganz oben auf der Skill-Seite; „Bearbeiten“ im Tab „Ich“ führt zu den Skills im Workouts-Tab. Skills mit Stufen haben fünf Stufen, die der Nutzer selbst als erreicht markiert und wieder zurücknehmen kann; Zeit-Skills (Plank 5 min, L-Sit 30 s) übernehmen die Bestzeit aus dem Tagebuch. Jede Stufe hat eine eigene Sticky-Man-Animation. Skill und Stufen haben je ein Info-Fenster mit den beanspruchten Muskeln und dem Nutzen. Das nächste Workout im Tab „Ich“ kommt mit Pro aus den gelernten Skills.
8. **Einstellungen** (aus dem Ich-Bereich): Konto, Abo, Trainingserinnerung, Farbe, Sprache, Rechtliches, Abmelden, Konto löschen.
9. **Teilen:** aus dem Tagebucheintrag (Workout, Rekord), dem Tab „Ich“ (Woche/Serie), der Journey (erreichte Erfolge) und der Skill-Seite (Fortschritt). Vorschau mit Wahl des Formats, dann das iOS-Teilen-Menü.
10. **Anmeldung und Abo-Seite.** Abo mit StoreKit 2: Jahr oder Monat, Käufe wiederherstellen, Abo verwalten.

## Beispielinhalte aus dem Mockup

Diese Inhalte sind Platzhalter, bis der echte Katalog steht.

- **Gratis-Pläne:** Push Basics, Pull Day, Core & Plank, Beine ohne Geräte, Handstand-Schule.
- **Abo-Pläne:** Front-Lever-Aufbau, Muscle-up-Weg.
- **Ziele:** Front Lever, Plank 5 min, Handstand Push-up, L-Sit 30 s, Pistol Squat, Muscle-up (Abo).
- **Erfolge:** 10 Klimmzüge, Plank 3 min, L-Sit 20 s, 25 Trainings (4 von 12).

## Offene Punkte

Vor dem jeweiligen Schritt mit Hansi klären.

- **Server:** Firebase ist gewählt; Projekt anlegen und einrichten (Schritt 6).
- **Inhalte:** vollständiger Übungskatalog, Pläne mit Sätzen und Wiederholungen, Stufen je Ziel und die Liste der zwölf Erfolge fehlen.
- **Technik:** Bundle-ID und Produkt-IDs der Abos sind noch Platzhalter (`com.example.unweak`, `com.example.unweak.pro.monthly` / `.yearly`). Niedrigste iOS-Version: 17.
- **Recht:** Datenschutzerklärung, Nutzungsbedingungen, Impressum, Gesundheitshinweis.
- **Name:** Prüfung von Marke, Domain und Store-Verfügbarkeit.
- **Avatar-Skins:** welche Skins es zu kaufen gibt, Preise und Produkt-IDs (eigener Schritt nach dem Avatar).

## Nicht in Version 1

Influencer-Tab, Folgen, Feed, eigene Workouts teilen, Moderation, Anbindung an Apple Health.
