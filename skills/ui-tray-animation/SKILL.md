---
name: ui-tray-animation
description: Use ONLY for a Windows GUI or system-tray desktop app: animate the tray icon (idle/busy/ok/error) at 8-12 FPS, stop on idle, frames drawn in memory. When a tray icon must spin while syncing, loading or uploading.
---

# Animated Tray Icons



> **Scope.** Owns the animation mechanics: the state machine, the frames, the timing and the
> threading rules. The project owns the tray vocabulary, palette, artwork and tooltip
> wording; other stacks read [docs/frameworks.md]. The frame and idle cadences below are the
> animator's. Use those names and tokens, and apply the mechanics below.

Ask only if the framework or OS is ambiguous; otherwise state the assumption in one line
and proceed.

## Screen & idle caps

- **Never faster than 80 ms / 12 FPS.** (`frame_seconds` defaults to 0.10.) An
  always-moving icon wastes CPU; idle must cost almost nothing.
- **Stop the animator the moment the state returns to `idle`** — timer cancelled,
  no redundant icon updates.
- Frames are generated **once at startup in memory**, never drawn per frame from disk.



| State | Icon | Tooltip | When |
| - | - | - | - |
| idle | Normal icon | `<name>` or `<name> - updated HH:MM` | Nothing running, no failure |
| busy | Normal icon + spinning arc badge | `<name> - <busy text>` | At least one task running |
| ok | Normal icon + check badge | `<name> - updated HH:MM` | Briefly (about 2 s) after the last task succeeded |
| error | Normal icon + exclamation badge | `<name> - error: <task names>` | A task failed; stays until that task succeeds |

Track work by **task name**, not by a single on/off flag - two jobs overlap (the spinner
runs until both end); one success must not hide another failure.

## Design rules
- Animate only while busy; badge bottom-right on a dark disc - readable on light and dark
  taskbars.
- 270 degree arc, about 2 px thick at 16 px; draw at 64x64 with 4x supersampling, OS scales
  down.
- 8-12 pre-rendered frames at about 10 fps; render once at startup, never from disk.
- Minimum busy time 0.8 s (fast calls would otherwise flash like a glitch);
  `animate=False` shows one static busy badge (reduced motion).
- Tooltips short (well under 100 characters; Windows truncates around 127); distinct shapes
  keep results readable for colour-blind and monochrome menu bars.

## Bundled files
- `scripts/tray_anim.py` - drawing (`load_base_icon`, `render`) and the `TrayAnimator`
  controller (Pillow only; works with any object that has `icon` and `title` properties).
- `scripts/preview.py` - renders every state at 64/32/16 px into one PNG.
- `scripts/demo_pystray.py` - menu items that simulate a sync, success and failure.
- `docs/frameworks.md` - other stacks (pystray, Win32, Qt, Electron, macOS, Linux), including
  threading rules.
- `docs/spec-template.md` - outline for a design document.

## Wiring (Python / pystray)

```python
from tray_anim import TrayAnimator, load_base_icon

icon = pystray.Icon("my_app", load_base_icon("icons/app.png"), "My App", menu)
anim = TrayAnimator(icon, name="My App", busy_text="syncing...")
threading.Thread(target=icon.run, daemon=True).start()
anim.start()
```

Wrap work with `begin`/`end` (or `run`): `data = anim.run("download", lambda: fetch(), is_ok=lambda r: r is not None)` or `anim.begin("upload") ... anim.end("upload", ok)`.

Constructor options: `frame_count` (12), `frame_seconds` (0.10), `min_busy_seconds` (0.8),
`ok_seconds` (2.0), `idle_poll_seconds` (0.5), `animate`, `colors`.

## Workflow
1. Collect framework/OS, tasks, icon, tooltip wording.
2. Design: state table, palette colours, busy/ok durations.
3. Implement: `begin`/`end` (or `run`) around real work; animator next to the tray icon;
   stop on quit.
4. Preview: `preview.py --icon <file> --out preview.png`, check the 16 px row.
5. Test: idle causes no icon updates; fast tasks keep the spinner for the minimum time;
   overlapping tasks keep the spinner until both end; errors clear only when the failing
   task succeeds; many threads end in idle; tray-not-ready updates do not kill the thread;
   quit stops the thread and the app exits.

## Pitfalls
- Wrong thread: GUI work runs on the GUI thread; this animator is only safe with pystray
  (see `docs/frameworks.md`).
- Hidden icon: new tray icons land in the overflow flyout; pin the icon to see it animate.
- Handle leaks: destroy the Win32 handle after each update.
- Flicker: update only when the frame or state changes.
- macOS menu-bar icons are monochrome templates: use shapes (check, exclamation).
- Linux (GNOME): use an extension or fall back to a static busy badge.
