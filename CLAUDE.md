# Arbeitsanweisung

Du baust die iOS-App „Unweak“. Lies zuerst `docs/SPEC.md`, `docs/DESIGN.md` und `docs/DESIGN-V2.md`. Für die Oberfläche gilt `docs/DESIGN-V2.md`; `docs/SCREENS.md` beschreibt den Stand davor und gilt nur noch, wo V2 nichts sagt. Sie sind verbindlich; wo sie schweigen, entscheide einfach und notiere die Annahme in der Pull-Request-Beschreibung.

## Rahmen

- Swift und SwiftUI, keine plattformübergreifenden Frameworks.
- Hansi (Inhaber) testet am Gerät, signiert und veröffentlicht. Er ist kein Vollzeit-Entwickler: Erkläre in jeder Übergabe kurz, was er in Xcode tun muss.
- Sprache der Oberfläche: Deutsch und Englisch von Anfang an. Kein Text fest im Code, alles über einen String Catalog.
- Codebezeichner und Kommentare auf Englisch, Dokumentation in `docs/` auf Deutsch.
- So einfach wie möglich. Keine Funktion, die nicht in `docs/SPEC.md` steht.

## Reihenfolge

1. Xcode-Projekt, Design-Grundlagen (`Theme`, Schriften, Bausteine aus `docs/DESIGN.md`), Navigation mit drei Tabs.
2. Sticky Man als wiederverwendbare Komponente: Posen und Animationen aus Gelenkpunkten, nicht aus Bilddateien.
3. Trainingsdaten als lokale Datei (Pläne, Übungen, Ziele mit Stufen) und die Screens Workouts, Training läuft, Übungsdetail.
4. Tagebuch und Tagebucheintrag mit lokaler Speicherung, Dashboard mit Woche, Ziel und Erfolgen.
5. Eigenes Workout erstellen, Ziel wählen, Einstellungen (Erinnerungen als lokale Mitteilungen, Farbe, Sprache).
6. Konto: Anmeldung mit Apple und Google, Sicherung und Abgleich der Daten, Konto löschen.
7. Abo mit StoreKit 2: fünf Pläne gratis, der Rest hinter dem Abo, Käufe wiederherstellen.

Schritte 1 bis 5 müssen ohne Server lauffähig sein. Für 6 und 7 zuerst die offenen Punkte in `docs/SPEC.md` mit Hansi klären.

## Als fertig gilt

- Das Projekt baut ohne Warnungen und läuft im Simulator.
- Jeder Screen entspricht `docs/SCREENS.md` und sieht in beiden Sprachen und mit allen sechs Akzentfarben richtig aus.
- Logik (Fortschritt, Stufen, Serien, Erinnerungen) hat Unit-Tests.
- Bedienelemente sind mindestens 44 pt groß und für VoiceOver beschriftet; Animationen beachten „Bewegung reduzieren“.

## Nicht tun

- Keine Influencer- oder Community-Funktionen. Die kommen erst in Version 2.
- Keine Schlüssel, Passwörter oder Zugangsdaten ins Repository.
- Nicht direkt auf `main` arbeiten: pro Schritt ein Branch und ein Pull Request.
