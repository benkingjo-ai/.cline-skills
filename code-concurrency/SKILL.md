---
name: code-concurrency
description: Run slow work off the GUI thread: a daemon worker that only records its result, a GUI poller that collects it, bounded timeouts, timers tied to the widget. Use when adding a network call, refresh or spinner that must not block the UI.
---

# Concurrency Discipline

Every slow operation (network test, refresh, quota fetch) follows one shape, in **all**
projects:

```
GUI thread                worker thread (daemon)
─────────                 ──────────────────────
self._result = None
start worker ──────────►  try:  self._result = fn(...)
poll with after()/QTimer  except: self._result = (False, str(exc))
  └─ when not None:        (touches NO widget)
       collect + repaint
```

> Ownership: the thread/poll/timer rules below are defined once, here. The `ui-dialogs` and `code-sync` skills link back to this file instead of restating them.

## Rules

| # | Rule |
|---|---|
| 1 | Work runs on `threading.Thread(target=work, daemon=True)` — never on the GUI thread. |
| 2 | The worker **only records its result**; it never touches a widget, never calls Tk/Qt. |
| 3 | The GUI polls (`after(...)` in Tk, `QTimer` in Qt) and is the only place widgets change. |
| 4 | Init the result to `None` before starting; the worker must always set it (catch every exception) so the poller can never spin forever. |
| 5 | A single-winner poller: stop the timer the moment the result lands. |
| 6 | **Bound every call** — explicit timeout and a retry cap, so a black-holed connection can't hang or bill. |
| 7 | Disable the action button while in flight; re-enable when the answer lands. |
| 8 | **No timer outlives its window**: stop/cancel them in `done()`, `_close()` or `<Destroy>`, and guard `winfo_exists()` / `isinstance` before touching a widget. |
| 9 | Never trust the last event: re-read hard evidence (pointer position, foreground window, window existence) **at the moment it matters**, not from a remembered event. |
| 10 | Anything unreadable counts as the **safe side** (hide, don't show; skip, don't send). |

> Precedence: rule 10 above is the general principle; the `ui-dialogs` overlap rule (a foreign window closes the panel at once) is its application. When they agree, follow both.

## Spinner while in flight

- `spin()` is idempotent; `stop_spin()` is the only end; the widget's own `<Destroy>`
  stops it.
- Called by the panel when the answer lands **and** when the panel hides.

## Logging from threads

The file logger appends a line and rotates — safe enough to call from any thread; the
GUI work, however, must still wait for the poller.
