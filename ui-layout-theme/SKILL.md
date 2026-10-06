---
name: ui-layout-theme
description: Apply the house dark-theme design system to any GUI — the exact colour palette (backgrounds, panels, text, accent, error, close, primary button, progress bar), the Calibri font family and its sizes, and the shared layout metrics (padding, button widths, header heights, window alpha). Use whenever styling a window, panel, dialog or button, choosing colours or font sizes, creating a theme.py, or building a progress bar or form layout.
---

# Layout — Colour, Font, Size

The palette and fonts are **byte-identical** across CAMonitor, GlobalX and VerbaPro.
VerbaPro's `theme.py` carries the comment *"CAMonitor's dialog colours, so the Login
panel matches"*. Copy them verbatim; centralise them in `theme.py` (or `config.py`).

## Colour tokens

| Token | Value | Role |
|---|---|---|
| `BG` | `#121212` | window / header background |
| `PANEL` | `#1E1E1E` | panel / dialog background |
| `DLG_HEADER` | `#181818` | dialog header background |
| `FG` | `#E6E6E6` | primary text |
| `TITLE` | `#C0C0C0` | title text in dialog header |
| `FG_DIM` / `DIM` | `#9AA0A6` | secondary / placeholder / hint text |
| `ACCENT` | `#5AA0FF` | suggestion / progress fill (not the settled verified line) |
| `ERROR` | `#FF4D4D` | rejected / invalid / quota red |
| `OK` / `CHECK_OK` | `#A6E3A1` | verified result line |
| `CLOSE` | `#C74C4C` | close button (hover `#FF5F57`) |
| `BTN` | `#2A2A2A` | normal button (hover `#343434`, pressed `#4A4A4A`) |
| `PRIMARY` | `#003366` | primary button (hover `#004080`, fg `#B0C4DE`) |
| `BAR_TRACK` / `BAR_FILL` / `BAR_EDGE` | `#2A2A2A` / `#5AA0FF` / `#3A3A3A` | progress bar |
| `SEL` / `SCROLL_THUMB` | `#333333` | text selection, scrollbar thumb |
| `EDGE` | `#3A3A3A` | hairline joining a field and its stepper |
| `HEADING` / `QUOTA_AMBER` | `#F9E2AF` | headings, quota 70–90% |
| `HL` | `#2D3A54` | highlight panel |

## Fonts

| Token | Value |
|---|---|
| `FONT_FAMILY` | `"Calibri"` |
| `FONT_BODY`, `FONT_TITLE` | 10 pt |
| `FONT_SMALL` (dialog body / status) | 9 pt |
| `FONT_PLACE` (placeholder copy) | 8 pt |
| `FONT_TINY` (colophon) | 7 pt |
| `FONT_HEADING` | 11 pt bold |
| Qt mono (`mono_font()`) | `"Consolas", 9` |

## Layout metrics

| Token | Value |
|---|---|
| `GRID_PAD`, `ROW_PAD` | 6 px |
| `BTN_CHARS`, `BTN_PAD_Y` | 10 chars, 2 px |
| `ICON_BTN` (✕) / `REFRESH_BTN` | 18 px / 12 px |
| `HEADER_HEIGHT` / `DLG_HEADER_HEIGHT` | 32 / 36 px |
| `HEADER_ICON_SIZE` | 18 px |
| `TRAY_ICON_SIZE` | 22 px |
| `WINDOW_ALPHA` | 0.90 |
| `POPUP_WIDTH_FRACTION` | 1/5 |
| `POPUP_EDGE_MARGIN_MM` | 1.5 mm from the right edge |
| `TASKBAR_BUTTON` | `False` (borderless tool windows) |
| `BAR_HEIGHT` / `BAR_BORDER` / `BAR_MIN_WIDTH` | 13 / 1 / 60 px |
| `LOGIN_CLOSE_S` | 3 s | login auto-close delay, owned by the `ui-dialogs` skill |

## Code

Tk — put in `theme.py` / `config.py` and read it everywhere:

```python
BG    = "#121212"
PANEL = "#1e1e1e"
FG    = "#E6E6E6"
DIM   = "#9AA0A6"
FONT_FAMILY = "Calibri"
FONT_BODY  = (FONT_FAMILY, 10)
FONT_SMALL = (FONT_FAMILY, 9)
FONT_TINY  = (FONT_FAMILY, 7)
```

## Rules

- **One place for colour** — a theme tweak is a single edit, not a hunt.
- Palette must be readable on a dark desktop; the overlay additionally samples screen
  luminance to pick light/dark text.
- Bars use **cell grids** (24 cells for hours, 10 cells = 10% for quotas), not smooth
  fills.
