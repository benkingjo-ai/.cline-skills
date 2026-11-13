---
name: ui-assets
description: Build buttons, icons and tray artwork from Windows stock assets and in-memory compositing: stock icons, Segoe glyph fonts and the standard Unicode glyphs. Use when drawing buttons, icons or spinners.
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

## Stock Windows icons (the rule)

Native first. Every icon, badge and glyph is either a Windows stock asset or drawn
in memory from the brand `.ico`; the only image the project ships is its own brand
`.ico` (see `win-shell`, *stable_icon_path*). Per-state `.ico` files, `refresh-*.png`
artwork and `tools/make_icons.py` are retired.

| Stack | Call |
|---|---|
| Win32 | `SHGetStockIconInfo` / `LoadIconW` (`shell32.dll`, `user32.dll`) |
| Qt | `QStyle.StandardPixmap` |
| Tk | system bitmaps |

- Destroy every icon handle after use; never leak GDI objects.
- Colours come from palette tokens (`ui-layout-theme`), never hard-coded.

## Glyphs and fonts

- `Segoe Fluent Icons` → `Segoe MDL2 Assets` → `Segoe UI Symbol` → `Calibri` (first
  installed font wins).
- Glyphs: `\u2715` close ✕, `\u2713` verified ✓, `\u21BB` refresh ↻, `\u25cf` badge dot,
  `\u25B2`/`\u25BD` up/down.

## Tray icons

- States `idle` / `busy` / `ok` / `error` (vocabulary owned by `win-shell`).
- **Native assets**: each state is the brand `.ico` composited **in memory at startup**:
  state badge (0.75 of the frame, tinted `DIM` / `OK` / `ERROR`) on the brand icon. Render
  each size once (`16`, `22`, `24`, `32`, `48 px`) — never shrink a 256 px canvas.
- Only touch the shell when the state actually changes.

## Refresh spinner

- One arc badge drawn in memory and rotated per frame (`\u21BB` refresh ↻ or a
  270° arc, 2 px thick, `BAR_ICON_PX` × 0.85).
- 8–12 frames at 80–120 ms (see `ui-tray-animation`); never drawn per frame from disk.

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
