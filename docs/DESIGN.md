# Design

Futuristischer HUD-Look: fast schwarzer Grund, eine leuchtende Akzentfarbe, eckige Formen, technische Beschriftungen. Die App ist immer dunkel; die Farbwahl des Nutzers tauscht nur die Akzentfarbe.

## Farben

| Rolle | Wert |
|---|---|
| Hintergrund | `#07090C` |
| Fläche (Karten, Panels) | `#0B1015` |
| Fläche gewählt | `#111920` |
| Linie | `#1E2A33` |
| Linie stark (Rahmen von Knöpfen und Feldern) | `#3A4954` |
| Text | `#EAF2F5` |
| Text weich | `#C3CED6` |
| Text gedämpft (Labels, Metadaten) | `#9FB0BC` |
| Abo-Marke | `#FFB547` |
| Gefahr (Konto löschen) | `#FF8A8A` |

Akzentfarben, vom Nutzer wählbar. Text auf Akzentfläche ist immer `#07090C`.

| Name | Wert |
|---|---|
| Lime (Standard) | `#C6F24E` |
| Cyan | `#5CE1FF` |
| Orange | `#FFB547` |
| Rot | `#FF7566` |
| Pink | `#FF7AB8` |
| Violett | `#A995FF` |

Leuchten: Schatten in der Akzentfarbe mit 40 % Deckkraft, Radius 10 bis 28, nur auf Hauptknöpfen, aktiven Balken und Sticky Man.

## Schriften

| Einsatz | Schrift | Größe |
|---|---|---|
| Überschriften, große Zahlen | Space Grotesk Bold | 32 (Screen-Titel), 40 (Übungsname), 22 (Kennzahlen) |
| Fließtext, Listen | Inter Regular und Semibold | 13 bis 17 |
| Labels, Marken, Knopftexte in Großbuchstaben | JetBrains Mono Medium und Bold | 12, Laufweite 1 bis 1,5 |

Alle drei Schriften stehen unter der Open Font License und werden mit der App ausgeliefert.

## Bausteine

- **Ecken:** überall eckig, kein Radius.
- **Karte:** Fläche mit 1 pt Linie.
- **HUD-Panel:** Karte mit Raster-Hintergrund (Linien `#111920` alle 24 pt) und vier Eckmarkierungen (18 × 18 pt, 2 pt, Akzentfarbe).
- **Hauptknopf:** 60 pt hoch, Akzentfläche, Space Grotesk Bold 18, Leuchten.
- **Zweitknopf:** 1 pt gestrichelter Rahmen in Akzentfarbe, Mono-Text.
- **Auswahlfeld (Filter, Tage, Sprache):** 44 pt hoch, gewählt mit Akzentfläche, sonst Rahmen `#3A4954`.
- **Fortschritt:** Segmente statt durchgehender Balken, 4 bis 8 pt hoch.
- **Abstände:** Seitenrand 20 pt, zwischen Blöcken 18 bis 24 pt, Tab-Leiste 76 pt.
- **Bedienflächen:** mindestens 44 × 44 pt.

## Sticky Man

Strichfigur aus Linien mit runden Enden. Er wird aus Gelenkpunkten gezeichnet, damit Posen und Bewegungen als Daten vorliegen und keine Bilddateien nötig sind.

- **Große Figur** (Zeichenfläche etwa 160 bis 200 Einheiten): Strichstärke 5, Arme 4 bis 5, Kopf als Kreis mit Radius 8 bis 9, gefüllt in der Flächenfarbe. Geräte (Stange) in Textfarbe mit Strichstärke 3.
- **Kleine Pose** für Listen (Zeichenfläche 48 × 48): Strichstärke 3, Kopf Radius 4.
- **Farbe:** Akzentfarbe, mit Leuchten. In Listen darf die Pose für nicht hervorgehobene Zeilen in Textfarbe stehen.
- **Bewegung reduzieren:** Animation aus, Figur steht in der Endpose.

### Animation Front Lever (Dashboard, Anmeldung)

Zeichenfläche 160 × 160. Stange bei y = 24. Hände bei (55, 24) und (65, 24), Schulter bei (60, 62). Kopf (60, 47), Rumpf von der Schulter bis (60, 106), Beine bis (60, 150).

Kopf, Rumpf und Beine drehen gemeinsam um die Schulter von 0° (Hang) auf −90° (waagrecht, Füße nach rechts). Dauer 6 s, Endlosschleife:

| Abschnitt | Zustand |
|---|---|
| 0 bis 18 % | Hang |
| 18 bis 42 % | hochziehen |
| 42 bis 80 % | halten |
| 80 bis 100 % | ablassen |

Eine gestrichelte Ziellinie von (60, 62) bis (152, 62) ist im Hang blass und beim Halten voll sichtbar.

### Animation Klimmzug (Training, Übungsdetail)

Zeichenfläche 200 × 170. Stange bei y = 20. Hände fest bei (80, 20) und (120, 20). Unterarm und Oberarm sind je 25 Einheiten lang.

Unten: Schultern bei (88, 69,35) und (112, 69,35), Ellbogen bei (84, 44,7) und (116, 44,7). Kopf (100, 55), Rumpf bis (100, 112), Füße bei (94, 150) und (106, 150).

Der Körper hebt sich um 28,35 Einheiten. Die Ellbogen ergeben sich aus den festen Armlängen und wandern nach außen. Werte für den linken Arm, rechts gespiegelt:

| Zeitpunkt | Körper nach oben | Unterarm dreht um die Hand | Oberarm dreht um die Schulter |
|---|---|---|---|
| unten | 0 | 0° | 0° |
| Mitte | 14,2 | +40,2° | −47,4° |
| oben | 28,35 | +51,6° | −75,1° |

Dauer 3 s, Endlosschleife, gleichmäßiges Tempo zwischen den Stützpunkten: 0 bis 15 % unten, 32,5 % Mitte, 50 bis 60 % oben, 77,5 % Mitte, ab 95 % unten.

In der nativen Umsetzung ist es sauberer, den Ellbogen aus Hand, Schulter und Armlänge zu berechnen, statt die Winkel zu interpolieren.

### Posen für Listen

Zeichenfläche 48 × 48, Kopf als Kreis mit Radius 4 am angegebenen Punkt, Linien als Pfad.

| Pose | Kopf | Linien |
|---|---|---|
| Liegestütz | (9, 24) | `M13 27L40 37M16 28v10` |
| Klimmzug | (24, 14) | `M8 7h32M17 7l5 12M31 7l-5 12M24 19v13M24 32l-4 11M24 32l4 11` |
| Plank | (9, 26) | `M13 29L41 37M16 30v8h8` |
| Kniebeuge | (20, 9) | `M20 13l-2 14M18 27l13 2M31 29l-5 13M19 17l13 3` |
| Handstand | (24, 38) | `M24 33V5M24 33l-6 10M24 33l6 10` |
| Front Lever | (9, 22) | `M6 7h36M15 7v14M14 22h28` |
| Muscle-up | (24, 9) | `M8 30h32M24 13v20M24 15l-6 15M24 15l6 15M24 33v10` |
| L-Sit | (16, 11) | `M16 15v15M16 30h26M16 19v18M9 38h14` |
| Pistol Squat | (17, 11) | `M17 15v15M17 30l12-4M29 26l-5 17M17 30l25 4M17 19l14 2` |
