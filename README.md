# Unweak (iOS)

Calisthenics-App mit vordefinierten Trainingsplänen, Trainingstagebuch und einem Ziel, auf das man hinarbeitet. Untertitel: „Progress from week to week“. Die Figur „Sticky Man“ zeigt jede Übung als Animation und ist das Erkennungszeichen der App.

Dieses Repository enthält die native iOS-App (Swift, SwiftUI). Die Android-App folgt später in einem eigenen Repository als Nachbau.

## Stand

Schritt 2 von 7 (siehe `CLAUDE.md`): Xcode-Projekt, Design-Grundlagen, Navigation mit drei Tabs und Sticky Man. Die Screens sind noch Platzhalter.

Öffnen: `Unweak.xcodeproj` in Xcode 16 oder neuer. Mindestversion iOS 17. Die Bundle-ID `com.example.unweak` ist ein Platzhalter.

| Ordner | Inhalt |
|---|---|
| `Unweak/App` | Einstieg und Tab-Navigation |
| `Unweak/Design` | Farben, Schriften, Akzentfarben und Bausteine (`Components/`) |
| `Unweak/StickyMan` | Sticky Man: Gelenkpunkte, Animationen (Front Lever, Klimmzug), Listenposen, Darstellung |
| `Unweak/Features` | Screens, je Bereich ein Ordner |
| `Unweak/Resources` | Schriften mit Lizenzen, Assets, Texte (`Localizable.xcstrings`) |
| `UnweakTests` | Unit-Tests |

Neue Dateien in diesen Ordnern nimmt Xcode automatisch ins Projekt auf.

Die Vorgaben stehen in `docs/`:

| Datei | Inhalt |
|---|---|
| `docs/SPEC.md` | Umfang von Version 1, Entscheidungen, offene Punkte |
| `docs/SCREENS.md` | Alle Screens mit Inhalt und Navigation |
| `docs/DESIGN.md` | Farben, Schriften, Bausteine, Sticky Man und Animationswerte |
| `CLAUDE.md` | Arbeitsanweisung für Claude Code |

Das klickbare Mockup liegt als privater Claude-Artefakt bei Hansi („Unweak – App-Mockup“). Es ist die optische Referenz; verbindlich sind die Dateien in `docs/`.
