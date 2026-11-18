# Social: Wochen-Liga und Duell

Stand: 18. November 2026. Hansi hat entschieden: Liga und Duell kommen in Version 1. Mockup: „Unweak – App-Mockup“, Seite „V2 · übersichtlicher“, dritte Reihe „Social: Wochen-Liga und Duell“ (Screens 17 bis 21). Quelltext in `docs/mockup-v2/` (`V2-Liga`, `V2-Punkte`, `V2-Wochenende`, `V2-Duell`, `V2-Herausfordern`, geänderter `V2-Ich`).

Ziel: Die App wird durch Wettbewerb einzigartig, ohne dass Nutzer Inhalte posten. Sichtbar sind von anderen nur Anzeigename, Avatar und Punkte.

## Wochen-Liga

- **Woche:** Montag 00:00 bis Sonntag 24:00. Gewertet wird für alle gleichzeitig nach UTC; angezeigt wird die Restzeit in lokaler Zeit („Noch 2 Tage“).
- **Ligen:** Bronze, Silber, Gold, Diamant. Neue Nutzer starten in Bronze.
- **Gruppe:** Jeden Montag wird jeder in eine Gruppe seiner Liga gelost, Ziel 20 Personen. Gibt es zu wenige Nutzer in einer Liga, werden die Gruppen kleiner (mindestens 5); Auf- und Abstiegsplätze skalieren mit (je ein Viertel der Gruppe, abgerundet, mindestens 1).
- **Teilnahme:** Wer in der Vorwoche kein Training abgeschlossen hat, wird nicht eingelost, bis er wieder trainiert. Dann steigt er in seiner bisherigen Liga ein.
- **Wertung am Sonntag:** Top 5 steigen auf (Diamant bleibt Diamant), die letzten 5 steigen ab (Bronze bleibt Bronze), der Rest bleibt. Bei Punktgleichstand gewinnt, wer die Punktzahl früher erreicht hat.
- **Preis:** Platz 1 bekommt ein Avatar-Extra, das es nur so gibt (z. B. „Silberkrone“, je Liga eine Farbe). Einmal gewonnen, bleibt es freigeschaltet.

### Punkte

| Anlass | Punkte | Regel |
|---|---|---|
| Training abgeschlossen | +10 | höchstens 1 pro Kalendertag, Mindestdauer 10 min |
| Wochenziel geschafft | +20 | einmal pro Woche |
| Skill-Stufe erreicht | +30 | höchstens 1 pro Woche und Skill |
| Serie | +5 je Woche in Folge | wird am Montag gutgeschrieben |

Gegen Schummeln zählen nur Dinge, die sich schwer fälschen lassen: Wiederholungen, Rekorde und nachgetragene Trainings bringen keine Punkte. Nachgetragene Trainings zählen weiter für Tagebuch, Serie und Level.

### Screens

- **Ich-Tab:** neue Zeile unter „Heute dran“: Liga-Abzeichen, „Silber-Liga“, „Noch 2 Tage“, rechts „Platz 4“ und darunter „Aufstiegszone“, „Mittelfeld“ oder „Abstiegszone“. Öffnet die Liga.
- **Liga (`V2-Liga`):** Zurück, Info-Knopf (Punkte). Abzeichen, Liganame, „Noch 2 Tage · Top 5 steigen auf“. Zwei Kacheln: Preis für Platz 1 und laufende Duelle. Rangliste: Platz, Mini-Avatar, Anzeigename, Punkte; eigene Zeile hervorgehoben; Trennlinien „Aufstieg bis hier“ (Akzent) und „Abstieg ab hier“ (`#FF7566`). Langes Drücken auf eine fremde Zeile: „Melden“ und „Blockieren“.
- **Punkte (`V2-Punkte`):** die Tabelle oben in vier Zeilen, zwei Sätze zu Gruppe und Wertung, die vier Ligen.
- **Wochenabschluss (`V2-Wochenende`):** erscheint beim ersten Öffnen ab Montag. Platz, Überschrift („Aufgestiegen!“, „Liga gehalten“ oder „Abgestiegen“), Podest der Top 3, Karte mit der Liga ab Montag, „Weiter“ und „Teilen“.

## Duell

- Zwei Freunde treten 7 Tage gegeneinander an. Arten: **Öfter trainieren** (abgeschlossene Trainings, 1 pro Tag), **Längster Plank** (beste Plank-Zeit im Training), **Mehr Skill-Stufen** (nur wenn beide Pro haben).
- Einladen per Link (iOS-Teilen-Menü). Wer den Link öffnet und angemeldet ist, nimmt an. Annehmen innerhalb von 48 Stunden, sonst verfällt die Einladung.
- Höchstens 3 laufende Duelle gleichzeitig.
- Gewinn: Abzeichen „Duellsieger“ im Tagebuch (Zähler, wie oft gewonnen). Kein Einfluss auf die Liga.
- Freunde sind Leute, mit denen man schon ein Duell hatte. Eine eigene Freundesliste, Suche oder Folgen gibt es nicht.

### Screens

- **Duell (`V2-Duell`):** Restzeit, Titel, Frage („Wer trainiert diese Woche öfter?“), beide Avatare gegenüber (der Gegner gespiegelt) mit Stand, zwei Tagesleisten Mo bis So, Gewinn, „Training starten“, „Neues Duell starten“.
- **Freund herausfordern (`V2-Herausfordern`):** Art wählen, Gegner aus früheren Duellen wählen oder „Per Link einladen“, „Herausfordern“.

## Anzeigename, Melden, Blockieren

- Beim ersten Öffnen der Liga: Anzeigename wählen (3 bis 20 Zeichen, Buchstaben, Ziffern, Punkt, Unterstrich, eindeutig). Wortfilter gegen Beleidigungen in DE und EN. Änderbar in den Einstellungen höchstens einmal pro 30 Tage.
- **Melden** eines Namens: Grund wählen (beleidigend, anstößig, sonstiges). Nach 3 Meldungen wird der Name automatisch durch „Sportler1234“ ersetzt, bis er geprüft ist. Prüfen in der Firebase-Konsole reicht für den Start.
- **Blockieren:** Der Blockierte erscheint für mich nicht mehr in Ranglisten und kann mich nicht herausfordern.
- **Einstellungen:** neuer Bereich „Liga“ mit Anzeigename, Schalter „An der Liga teilnehmen“ (aus: kein Einlosen, keine Duelle, Name wird nirgends angezeigt) und „Blockierte Nutzer“.
- **Konto löschen** entfernt auch Anzeigename, Ranglisteneinträge und Duelle.

## Gratis und Pro

Liga und Duell sind für alle gratis, weil sie neue Nutzer bringen. Gratis-Nutzer können keine Skill-Punkte sammeln; das wird in Kauf genommen (offener Punkt, siehe unten).

## Technik

- Firebase wie für das Konto: Firestore für Ligen, Gruppen, Punkte und Duelle; Cloud Functions für Einlosen am Montag, Wertung am Sonntag und das Gutschreiben von Punkten. Punkte schreibt nur der Server, die App meldet nur abgeschlossene Trainings und erreichte Stufen.
- Mitteilungen: „Du bist auf Platz 6 gerutscht“ (höchstens 1 pro Tag), Duell-Einladung, Wochenabschluss.
- Android baut später dieselbe Logik gegen denselben Server.

## Offen

- Fairness: Pro-Nutzer bekommen Skill-Punkte, Gratis-Nutzer nicht. Eigene Ligen für Pro, ausgleichende Punkte oder hinnehmen?
- Liga-Preise für Gold und Diamant (Extras gestalten).
- Datenschutzerklärung um Anzeigename, Rangliste und Duelle ergänzen.

## Stand der Umsetzung

Stand: 18. November 2026 (Pull Request „Wochen-Liga und Duell: Oberfläche und Logik“).

**In der App fertig, ohne Server:**

- **Regeln und Punkte** mit Unit-Tests (`Unweak/League/`):
  - Ligen, Auf- und Abstieg (ein Viertel der Gruppe, mindestens 1), Zonen, Gleichstand;
  - Woche nach UTC;
  - Punkte nach der Tabelle oben; nachgetragene Trainings sind markiert und bringen keine Punkte;
  - Anzeigename mit Wortfilter und 30-Tage-Sperre;
  - Duelle (Arten, 7 Tage, 48 Stunden, höchstens 3).
- **Alle Screens** dieses Dokuments: Liga-Zeile im Ich-Tab, Liga, Punkte, Wochenabschluss, Duell, Freund herausfordern, Anzeigename, Bereich „Liga“ in den Einstellungen mit „Blockierte Nutzer“, Abzeichen „Duellsieger“ auf der Erfolge-Seite, Liga-Kronen als Avatar-Extras und eine Share-Karte für den Wochenabschluss.
- **Beispieldaten** (`LeagueStore`, `SampleLeague`):
  - Die 19 anderen der Gruppe und die Freunde stammen aus dem Mockup; ihre Punkte wachsen über die Woche.
  - Die eigenen Punkte rechnet die App aus der Journey.
  - Name, Teilnahme, Blockierte, Meldungen und Duelle werden auf dem Gerät gespeichert.
  - Die Screens zeigen den Hinweis „Beispieldaten“.

**Kommt mit dem Server (nach Schritt 6):**

- echte Gruppen und Einlosen am Montag, Wertung am Sonntag, Punkte schreibt der Server;
- Prüfen, ob ein Anzeigename schon vergeben ist; Melden mit Ersatzname nach 3 Meldungen;
- Einladungslink:
  - braucht eine Domain für Universal Links; bis dahin steht in `LeagueLinks` ein Platzhalter `https://unweak.app/duel`;
  - Annehmen innerhalb von 48 Stunden;
- Mitteilungen (Platz verloren, Duell-Einladung, Wochenabschluss);
- Löschen von Name, Ranglisten und Duellen mit „Konto löschen“.
