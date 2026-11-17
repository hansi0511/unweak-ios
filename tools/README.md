# Werkzeuge

Hilfsskripte für Inhalte, die als Daten in der App liegen. Sie laufen mit Python 3 und gehören nicht zur App.

| Ordner | Erzeugt | Aufruf (aus dem Repository-Wurzelordner) |
|---|---|---|
| `content/` | `Unweak/Resources/Catalog.json` und `Catalog.xcstrings` aus `content.py` (Übungen, Pläne, Ziele, Texte DE/EN) | `python3 tools/content/build.py tools/content .` |
| `sticky/` | `Unweak/StickyMan/StickyBodyAnimations.swift` aus den Schlüsselposen in `anims.py` | `python3 tools/sticky/gen.py tools/sticky > Unweak/StickyMan/StickyBodyAnimations.swift` |

`sticky/render.py` zeichnet jede Animation als Bildstreifen zur Kontrolle (braucht Pillow): `python3 tools/sticky/render.py tools/sticky <Zielordner> [Name …]`.

Die erzeugten Dateien nicht von Hand ändern, sondern die Quelle anpassen und neu erzeugen.
