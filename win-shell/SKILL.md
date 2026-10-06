---
name: win-shell
description: Integrate with the Windows shell: tray icon states, Alt+Q hotkey with a hook fallback, single-instance mutex, AUMID toasts, autostart, borderless tool windows. Use when adding tray behaviour, global shortcuts, toasts or autostart.
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

Two independent paths, because `RegisterHotKey` is first-come-first-served and Windows
drops it across sleep/resume:

| Path | Module | Notes |
|---|---|---|
| Primary | `RegisterHotKey` | quick, normal case |
| Fallback | `WH_KEYBOARD_LL` hook | keeps Alt+Q working after sleep/resume or contention |

Hook rules (non-negotiable):

- Runs on **its own thread with its own message pump** (`GetMessage`/`DispatchMessage`).
- The hook procedure **never touches the toolkit** — it sets a flag the GUI pump reads.
- Treat down/up so it behaves like `NOREPEAT`; re-arm on release.
- `active` must check the **thread is alive** — Windows silently removes a slow hook.

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
3. `stable_icon_path()` copies the `.ico` into `%APPDATA%` so `IconUri` outlives the
   one-file unpack.
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
- Always declare `argtypes`/`restype` (an undeclared pointer is marshalled as 32-bit
  `c_int`) and use `use_last_error=True`.


## 7. Autostart (moved here from the `app-identity` skill)

- `startup.py` (`python -m <pkg>.startup` / `--remove`): a Task Scheduler `ONLOGON` task with a short delay, falling back to the `HKCU\...\CurrentVersion\Run` key.
- Both are scoped to the current user; no elevation is required.