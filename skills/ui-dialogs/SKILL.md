---
name: ui-dialogs
description: Build the borderless dialog shell, the Login panel protocol and auto-hide: always-on-top windows, red ✕ header, Esc cancels, a status line per part, connection test, 3-second auto-close. Use when creating a dialog or login panel.
---

# Dialogs — Shell, Login, Auto-hide

## 1. The dialog shell (`panel_dialog.py`)

Every modal dialog is the same window; subclasses set `DIALOG_NAME` and implement
`_build()`.

- **Borderless** (`overrideredirect`), **always-on-top**, `TASKBAR_BUTTON = False`
  (stays out of the taskbar and Alt+Tab).
- Width = the popup's width, clamped to `POPUP_MIN_WIDTH` .. `work area - 2 x margin`
  (metrics owned by the `ui-layout-theme` skill); placed at the popup's top-right slot, and
  **re-placed after a rotation, DPI or resolution change** rather than left off-screen
  (owner: the `win-shell` skill; an unplugged second monitor cannot strand it).
- **Header**: app icon + `"<App> – <Dialog>"` + red ✕; **draggable** by the header.
- **Esc** cancels; ✕ cancels; `grab_set()` for modality.
- Deliberately **not** `wm_transient` — Windows hides a transient whose owner is
  invisible; `-topmost` keeps it up instead.
- **Overlap rule**: a foreign window overlapping the panel closes/cancels it at once.
  `pause_overlap()`/`resume_overlap()` (or `child_window()`) while opening a file picker,
  so our own child never counts as an intruder.
- **Teardown**: stop every timer in `done()`/`_close()` (the timer-lifetime rule is owned by the `code-concurrency` skill) — no timer outlives the window.

## 2. The Login panel protocol

Identical in CAMonitor (Tk) and GlobalX (Qt): *"same method, same messages, not the same
toolkit."*

| Step | Behaviour |
|---|---|
| Button | **one** control, bottom-right: `Load` → relabels to `Close` after the attempt |
| Info line | explains choosing the access identity / credentials file |
| Status line | `Registered: url, token, …` (field **names** only) |
| Result lines | **one line per part** (url / token / api / user) — never merged |
| Verified | `"<part>: verified ✓"` in `OK`; failure in `ERROR` |
| File picker | points at the first `<App>.*` file, else the first `.txt` holding credentials |
| Validation | **all-or-nothing** — one bad value refuses the whole file, nothing written |
| Connection test | runs on a **background thread**; GUI polls the result (the thread/poll pattern is owned by the `code-concurrency` skill) |
| **Auto-close** | verified panel closes itself after `LOGIN_CLOSE_S = 3 s` (keeps the result); a failed one **stays** so the reason can be read |
| Esc / ✕ | cancel (does not report a cancel if the load already succeeded) |
| Security | never show or log secret values (the secret-hygiene rule is owned by the `code-persistence` skill) — only field names |

## 3. Auto-hide

| Item | Value |
|---|---|
| `HIDE_AFTER_CHOICES` | `(3, 10, 30, 60, 0)` — **0 = "Never", listed last** |
| `DEFAULT_HIDE_AFTER_S` | `10` |
| `INACTIVITY_TIMEOUT_MS` | `10_000` |
| Persisted | `settings.ini` key `hide_after_s` |

Rules:

- Re-arm the timer on activity; **throttle** re-arming (≤4×/s — `<Motion>` fires per
  pixel and each re-arm is several Tcl round-trips).
- Pointer over the window ⇒ timer off; `timeout_s <= 0` ⇒ arm nothing.
- **One choice, two surfaces**: the panel's right-click menu *and* the tray's
  **Auto-hide ▸** submenu share the same list and the same saved choice.
- Labels are pure: `delay_label()` → `"Never"` / `"3s"` / `"30s"`.
- While `Never`, refresh every 60 s (`PANEL_REFRESH_S`) so the readout never freezes;
  with a timed hide the panel hides as it always has.
- Overlap rule beats the timer: an overlapping window hides it at once.

## 4. Qt variant

`DIALOG_FLAGS = Qt.Dialog | Qt.CustomizeWindowHint | Qt.FramelessWindowHint |
Qt.NoDropShadowWindowHint`; `mono_font()` = `Consolas 9`; margins 14, spacing 8–12;
return values from `get_*()` so a cancelled dialog never leaves a half-written file.
