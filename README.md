# Unweak (iOS)

Calisthenics-App mit vordefinierten Trainingsplänen, Trainingstagebuch und einem Ziel, auf das man hinarbeitet. Untertitel: „Progress from week to week“. Die Figur „Sticky Man“ zeigt jede Übung als Animation und ist das Erkennungszeichen der App.

Dieses Repository enthält die native iOS-App (Swift, SwiftUI). Die Android-App folgt später in einem eigenen Repository als Nachbau.

## Stand

Schritt 5 von 7 (siehe `CLAUDE.md`): alles, was ohne Server läuft. Trainingsdaten, Workouts mit eigenen Workouts, Training, Übungsdetail, Tagebuch mit lokaler Speicherung, Dashboard mit Woche, Ziel und Erfolgen, Ziel wählen und Einstellungen mit Trainingserinnerung (lokale Mitteilungen), Akzentfarbe und Sprache. Konto (Schritt 6) und Abo (Schritt 7) sind noch Platzhalter. Trainingsinhalte und Erfolge sind Beispielinhalte, bis der echte Katalog steht. Offene Punkte zu den Animationen sammelt Issue #4.

Öffnen: `Unweak.xcodeproj` in Xcode 16 oder neuer. Mindestversion iOS 17. Die Bundle-ID `com.example.unweak` ist ein Platzhalter.

| Ordner | Inhalt |
|---|---|
| `Unweak/App` | Einstieg und Tab-Navigation |
| `Unweak/Design` | Farben, Schriften, Akzentfarben und Bausteine (`Components/`) |
| `Unweak/StickyMan` | Sticky Man: Gelenkpunkte, Animationen (Front Lever, Klimmzug), Listenposen, Darstellung |
| `Unweak/Training` | Trainingsdaten (Übungen, Pläne, Ziele, Erfolge) und Ablauf eines Trainings |
| `Unweak/Settings` | Sprache der App und Trainingserinnerungen |
| `Unweak/Journal` | Tagebuch: Einträge, lokale Speicherung (`userdata.json`), Auswertungen für Woche, Serie, Rekorde und Erfolge |
| `Unweak/Features` | Screens, je Bereich ein Ordner |
| `Unweak/Resources` | Schriften mit Lizenzen, Assets, Texte der Oberfläche (`Localizable.xcstrings`), Trainingsinhalte (`Catalog.json`, Texte in `Catalog.xcstrings`) |
| `UnweakTests` | Unit-Tests |
| `tools` | Skripte, die Trainingsinhalte und Animationsdaten erzeugen (siehe `tools/README.md`) |

Neue Dateien in diesen Ordnern nimmt Xcode automatisch ins Projekt auf.

Die Vorgaben stehen in `docs/`:

| Datei | Inhalt |
|---|---|
| `docs/SPEC.md` | Umfang von Version 1, Entscheidungen, offene Punkte |
| `docs/SCREENS.md` | Alle Screens mit Inhalt und Navigation |
| `docs/DESIGN.md` | Farben, Schriften, Bausteine, Sticky Man und Animationswerte |
| `CLAUDE.md` | Arbeitsanweisung für Claude Code |

Das klickbare Mockup liegt als privater Claude-Artefakt bei Hansi („Unweak – App-Mockup“). Es ist die optische Referenz; verbindlich sind die Dateien in `docs/`.
