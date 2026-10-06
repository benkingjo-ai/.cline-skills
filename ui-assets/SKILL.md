---
name: ui-assets
description: Build buttons, icon glyphs and system-tray artwork the house way — the red ✕ CloseButton, flat/primary buttons, the spinning refresh control with its baked frames, tray state icons with tinted badges, app icon files, and the standard Unicode symbols (✓ check, ✕ close, en dash). Use whenever drawing a close button, an icon button, a refresh/spinner control, tray icons or badges, or choosing button symbols and glyph characters.
---

# Assets — Buttons, Icons, Symbols

## Buttons

| Button | Implementation | Appearance |
|---|---|---|
| Close ✕ | `widgets.CloseButton` (Tk canvas round-rect) | 18 px, `CLOSE` + hover (palette tokens, see `ui-layout-theme`), white glyph `\u2715` |
| Default | `widgets.FlatButton` | `BTN` (see `ui-layout-theme`) |
| Primary | `FlatButton(primary=True)` | `PRIMARY` (see `ui-layout-theme`) — used by **Add** / **Load** / **Confirm** |
| Dialog actions | Cancel / Confirm, right-aligned, Confirm is default | min width 90 px |

Rule: Add and Cancel are built with the same width and padding, so the pair always
aligns.

## Refresh spinner

- White circular arrow = an open arc + a small arrow head.
- **8 frames, 45° apart, 90 ms per frame** (`REFRESH_SPIN_FRAMES`, `REFRESH_SPIN_MS`).
- Tk cannot rotate a `PhotoImage`, so the frames are baked and swapped; when no artwork
  ships, the arc's start angle is rotated instead as a fallback.
- Shipped assets: `refresh.png` (rest face) + `refresh-1..7.png` + `refresh.ico`,
  generated at 2× by `tools/make_icons.py` from `art/<App> master.png`.
- Derived size: refresh glyph = icon size × 0.85 (e.g. `BAR_ICON_PX=22` → 19 px).

## Tray icons

- One `.ico` per state: `tray-sleep.ico` (idle), `tray-sync.ico` (busy), `tray-error.ico` (error). The canonical state vocabulary is `idle` / `busy` / `error` (see the `win-shell` skill); the filenames stay as shipped.
- State colours are the palette tokens `DIM` (idle) / `OK` (busy) / `ERROR` (error). Values are owned by the `ui-layout-theme` skill, not new colour names.
- Badge = the tinted refresh glyph on the `BG` disc (palette token, see `ui-layout-theme`), occupying **0.75** of the frame
  (`TRAY_BADGE_FRACTION`), rendered at sizes `(16, 22, 24, 32, 48)` — each size drawn
  independently, never a shrunk 256 px canvas.
- Only touch the shell when the state actually changes.
- Tooltips short (Windows truncates ~127 chars); prefer shapes over colour so state
  survives colour-blind users and monochrome menu bars.

## App icon files

- `<App>.ico` + `<App>.png` in `icons/` (or `assets/app`, `assets/icons`).
- `resource_path()` / `icon_path()` are the PyInstaller `_MEIPASS`-aware path helpers, owned by the `app-identity` skill.
- Copy the icon into `%APPDATA%` (`stable_icon_path()`, see `app-identity`) so it survives a one-file build's
  temporary unpack.

## Symbols (used verbatim across projects)

| Purpose | Glyph | Constant |
|---|---|---|
| Verified | `✓` `\u2713` | `CHECK` |
| Close | `✕` `\u2715` | — |
| Panel title separator | `–` (en dash) | `DASH` |
| Direction up/down | triangle | `TRI_UP`, `TRI_DN` |
| No direction | blank | `TRI_NONE` |

Icons load like text in labels (`text="✕"`) and colours come from the palette, never
hard-coded per widget.
