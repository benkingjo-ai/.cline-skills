---
name: win-shell
description: Use ONLY for a Windows GUI or system-tray desktop app: tray states, Alt+Q via RegisterHotKey, re-armed by watchdog, single-instance mutex, AUMID toasts, autostart, borderless windows. When adding tray integration or shortcuts.
---

# Win32 Shell

## 1. System tray

- One icon, three states: `idle`, `busy`, `error` (icons `tray-sleep.ico` / `tray-sync.ico` / `tray-error.ico` as shipped; see the `ui-assets` skill). State colours are the palette tokens `DIM` / `OK` / `ERROR` (values owned by the `ui-layout-theme` skill).
- State colours come from the palette; badge = tinted glyph on a dark disc
  (see `ui-assets`).
- Update the shell **only when the state actually changes**.
- A right-click (and often a left-click) shows the menu:
  **`Add ▸` / `Remove ▸` / `Auto-hide ▸` / `Login` / `Quit`**.
- Tk cannot be called from a Win32 window procedure → **queue requests** and pump them
  with a short timer (`TRAY_POLL_MS` 120 ms visible / 400 ms idle).

## 2. Global hotkey — **Alt+Q**

`RegisterHotKey` **only**. There is no `WH_KEYBOARD_LL` hook: a global low-level keyboard
hook is the keylogger signature an endpoint product scores, and this app never needs one.

| Step | Call | Notes |
|---|---|---|
| Register | `RegisterHotKey(hwnd, HOTKEY_ID, MOD_ALT, VK_Q)` | its own thread with its own `GetMessage`/`DispatchMessage` pump — a message pump is not a hook |
| Re-arm | `UnregisterHotKey`, then register again | after resume (`WM_POWERBROADCAST` / `PBT_APMRESUMEAUTOMATIC`), `WTS_SESSION_UNLOCK`, `WM_DISPLAYCHANGE`, and every `HOTKEY_RETRY_S` (30 s) while the last attempt failed |
| Handle | `WM_HOTKEY` on that thread | sets a flag the GUI pump reads — the handler never touches the toolkit |

- **A lost registration is never silent**: `ERROR_HOTKEY_ALREADY_REGISTERED` (another
  process owns the chord) or a failed re-arm is reported in the tray menu and the log, so a
  dead shortcut is visible instead of unexplained.
- `active` must check the **thread is alive and the last register succeeded** — Windows
  silently drops a registration across sleep/resume.

## Teardown (normal or abnormal exit)

- `UnregisterHotKey(hwnd, HOTKEY_ID)` and `CloseHandle` on the single-instance mutex —
  via `atexit` / `try…finally`. A crashed instance must still release the mutex so a
  second launch can acquire it.

## 3. Single-instance guard

```python
def acquire_single_instance() -> bool:
    handle = kernel32.CreateMutexW(None, True, MUTEX_NAME)
    return ctypes.GetLastError() != 183        # ERROR_ALREADY_EXISTS
```

- Call at startup; a second launch exits immediately.
- Also take every **previous brand's** mutex so mixed builds can't both run.
- Windows-only; expose it as a function, not an import side effect, so tools/tests can
  import the module while the app runs.
- `MUTEX_NAME` (= `APP_ID + "SingleInstanceMutex"`) is defined by the `app-identity` skill.

## 4. Toast notifications (AppUserModelID)

1. `claim()` → `SetCurrentProcessExplicitAppUserModelID(APP_NAME)` **before any window
   exists** (the shell reads it once at startup).
2. `register()` → write `DisplayName` + `IconUri` under
   `HKCU\Software\Classes\AppUserModelId\<AUMID>` — idempotent, by value.
3. `stable_icon_path()` copies the `.ico` into `%APPDATA%` **only** when the build unpacks
   to a temporary folder (a released one-file build always does); it is the **one** self-copy
   the app makes - written only when the file is missing or stale, never on every launch - and
   a machine that refuses that filename is reported instead of fought (the fallback rule is
   owned by the `code-persistence` skill).
4. Send the toast through the same AUMID with a `ToastGeneric` XML payload.
5. `init_apartment()` once per process (STA, fall back to MTA) before the first WinRT call.
6. **Best-effort and quiet**: a failure logs `[APPID] …` and never stops the app starting
   or speaking.

## 5. Native popup menus

- `CreatePopupMenu` + `AppendMenuW` + `TrackPopupMenu(TPM_RETURNCMD | TPM_RIGHTBUTTON |
  TPM_RIGHTALIGN)`.
- A menu that is shown but never activated **blocks Tk** → start a guard thread that posts
  `WM_CANCELMODE` after ~10 s.
- Menu construction (`entries`, labels, check marks) should be **pure** so it is
  unit-testable without a GUI (the GUI-free testing rationale is owned by the `flow-delivery` skill).

## 6. Windows & ctypes hygiene

- Borderless tool windows (`WS_EX_TOOLWINDOW`), `-topmost`, out of taskbar/Alt+Tab;
  re-assert topmost every ~2 s.
- **Display change — re-place**: on `WM_DISPLAYCHANGE`, `WM_SETTINGCHANGE`, `WM_DPICHANGED`
  or session unlock, recompute the tray and work-area rect, place the popup at its top-right
  slot again and re-assert topmost. Never reuse a cached work rect across those messages
  (values owned by the `ui-layout-theme` skill, *Screen rotation & scaling*).
- Always declare `argtypes`/`restype` (an undeclared pointer is marshalled as 32-bit
  `c_int`) and use `use_last_error=True`.


## 7. Autostart (moved here from the `app-identity` skill)

- `startup.py` (`python -m <pkg>.startup` / `--remove`): a Task Scheduler `ONLOGON` task with a short delay, falling back to the `HKCU\...\CurrentVersion\Run` key.
- Both are scoped to the current user; no elevation is required.
- **User opt-in only**: a launch never writes the entry itself - self-registering
  persistence is one of the behaviours an endpoint product scores.
