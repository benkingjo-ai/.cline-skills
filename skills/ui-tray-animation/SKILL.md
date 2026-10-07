---
name: ui-tray-animation
description: Animate a tray or menu-bar icon while background work runs: idle/busy/ok/error states with a spinning badge, a success check and a sticky error mark. Use when a tray icon must spin while syncing, loading or uploading.
---

# Animated Tray Icons

Produce a design and working code for a tray icon that animates while background work runs,
then settles into a clear result (ok or error). The bundled Python module is the reference
implementation; the [framework notes](docs/frameworks.md) cover the other stacks.

> **Scope.** This skill owns the animation mechanics: the state machine, the frames, the
> timing and the threading rules. Which states a *particular* app shows, and their colours,
> artwork and tooltip wording, belong to that project - in this house the tray state
> vocabulary and palette are owned by the `win-shell` and `ui-layout-theme` skills, and the
> tray artwork by `ui-assets`. Its own tray poll cadence (`TRAY_POLL_MS`) also stays with
> `win-shell`; the frame and idle cadences below are the animator's. Use those names and
> tokens, and apply the mechanics below.

## Decide what to deliver

- **Code**: copy `scripts/tray_anim.py` into the project and wire it in (see "Wiring").
  Default stack is Python with Pillow and `pystray`. For other stacks (Qt, Electron, Win32,
  macOS, Linux) use the same state model and read the [framework notes](docs/frameworks.md).
- **Spec or design document**: follow the [spec template](docs/spec-template.md). Keep it
  free of product names unless the user supplies them; use their task names, tooltip text
  and icon file.
- **Both**: write the spec first, then the code, and keep the numbers (frame rate, durations)
  identical in both.

Ask a question only if the framework or OS is unclear and cannot be inferred from the
project. Otherwise state the assumption in one line and proceed.

## State model

Use four states. They map to what users need to know at a glance.

| State | Icon | Tooltip | When |
| - | - | - | - |
| idle | Normal icon | `<name>` or `<name> - updated HH:MM` | Nothing running, no failure |
| busy | Normal icon + spinning arc badge | `<name> - <busy text>` | At least one task running |
| ok | Normal icon + check badge | `<name> - updated HH:MM` | Briefly (about 2 s) after the last task succeeded |
| error | Normal icon + exclamation badge | `<name> - error: <task names>` | A task failed; stays until that task succeeds |

Track work by **task name**, not by a single on/off flag. Reasons: two jobs often overlap
(the spinner must continue until both finish), and one job succeeding must not hide another
job's failure.

## Design rules and why

- **Animate only while busy.** An always-moving icon is distracting and wastes CPU; idle must
  cost almost nothing (no redundant icon updates).
- **Badge in the bottom-right corner on a dark disc.** The icon stays recognizable, and the
  badge stays readable on light and dark taskbars.
- **Simple shapes.** Icons render at 16x16 px (32x32 on high-DPI). Use a 270 degree arc about
  2 px thick at 16 px; thin strokes or small text vanish. Draw at 64x64 with 4x supersampling,
  then let the OS scale down.
- **8-12 pre-rendered frames at about 10 fps.** Render once at startup; never draw per frame.
  Smooth enough, cheap enough.
- **Minimum busy time (about 0.8 s).** Fast calls would otherwise flash too briefly to notice,
  which looks like a glitch.
- **Offer a way to turn motion off** (`animate=False` shows one static busy badge) for users
  who prefer reduced motion.

<!-- duplicate-ok: the tooltip-length and shape-over-colour advice is the master wording in the `ui-assets` skill; it is repeated here only as it applies to the badges this skill draws. -->
- **Keep tooltips short** (well under 100 characters; Windows truncates around 127) and do not
  rely on colour alone: the check and exclamation shapes keep results readable for colour-blind
  users and on monochrome menu bars.

## Bundled files

- [scripts/tray_anim.py](scripts/tray_anim.py) - drawing (`load_base_icon`, `render`) and the
  `TrayAnimator` controller. Needs only Pillow. Works with any object that has `icon` and
  `title` properties, so it is not tied to `pystray`.
- [scripts/preview.py](scripts/preview.py) - renders every state at 64, 32 and 16 px into one
  PNG for a visual check.
- [scripts/demo_pystray.py](scripts/demo_pystray.py) - small tray app with menu items that
  simulate a sync, success and failure.
- [docs/frameworks.md](docs/frameworks.md) - how to apply the same idea in pystray, Win32, Qt,
  Electron, macOS and Linux, including threading rules.
- [docs/spec-template.md](docs/spec-template.md) - outline for a design document.

## Wiring (Python / pystray)

```python
from tray_anim import TrayAnimator, load_base_icon

icon = pystray.Icon("my_app", load_base_icon("icons/app.png"), "My App", menu)
anim = TrayAnimator(icon, name="My App", busy_text="syncing...")
threading.Thread(target=icon.run, daemon=True).start()
anim.start()
```

Wrap each real piece of work with a task name. `run` marks the task busy, then ok or failed
(an exception counts as failure and is re-raised):

```python
data = anim.run("download", lambda: fetch(), is_ok=lambda r: r is not None)
```

or, when the code is structured differently:

```python
anim.begin("upload")
try:
    ok = upload()
finally:
    anim.end("upload", ok)
```

On quit call `anim.stop()` before `icon.stop()`.

Constructor options: `frame_count` (12), `frame_seconds` (0.10), `min_busy_seconds` (0.8),
`ok_seconds` (2.0), `idle_poll_seconds` (0.5), `animate` (True), `colors` (override `busy`,
`ok`, `error`, `badge_bg`), `name`, `busy_text`.

## Workflow

1. **Collect**: framework and OS, the background tasks (give each a short task name), the app
   icon file if any, tooltip wording.
2. **Design**: fill in the state table, choose colors from the app palette, confirm the
   minimum busy time and ok duration.
3. **Implement**: copy the module, call `begin`/`end` (or `run`) around real work, create the
   animator next to the tray icon, stop it on quit.
4. **Preview**: run `python scripts/preview.py --icon <file> --out preview.png` and look at the
   16 px row. If the arc is unreadable, thicken it or enlarge the badge.
5. **Test**: check the cases below. Do not claim the animation was tested on a real tray unless
   it was; say what was verified (logic with a fake icon, drawing in the preview) and what must
   be checked on the target machine.

Test cases that matter:

- Idle app causes no icon updates.
- A very fast task still shows the spinner for the minimum time.
- Two overlapping tasks: one continuous spinner until both end.
- One task fails while another succeeds: the error badge stays.
- The failed task succeeds later: the error clears and the ok badge shows.
- Many threads calling `begin`/`end` at once end in the idle state.
- An icon update that raises (tray not ready) does not kill the animation thread.
- Quit stops the thread and the app exits.

## Pitfalls

- **Wrong thread.** Qt and Tk tray/GUI updates must happen on the GUI thread; the animator's
  own thread is only safe with libraries that accept updates from other threads (pystray
  does). See the [framework notes](docs/frameworks.md).
- **Hidden icon.** Windows puts new tray icons in the overflow flyout; the user must pin the
  icon to see it animate.
- **Icon handle leaks.** When using raw Win32, destroy the previous icon handle after each
  update.
- **Flicker.** Update the icon only when the frame or state changes.
- **Menu-bar icons on macOS are monochrome templates.** Use shapes (check, exclamation), not
  color, to convey state.
- **Linux trays vary.** GNOME needs an extension for status icons; test on the target desktop
  and fall back to a static busy badge if updates are ignored.
