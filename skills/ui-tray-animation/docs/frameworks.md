# Applying the state model in each framework

All frameworks use the same pattern: pre-render frames, swap the icon on a timer while at least one task is running, and show a static result badge afterwards. Differences are in which thread may update the icon.

## Contents
- Python + pystray
- Windows (raw Win32 / ctypes)
- Qt (PySide6 / PyQt)
- Tk
- Electron
- macOS menu bar
- Linux

## Python + pystray

- Assign `icon.icon = <PIL.Image>` and `icon.title = "text"` at runtime; both update the live tray icon.
- Updates from a background thread work on Windows; this is what `TrayAnimator` does.
- `icon.run()` blocks; run it in a thread (or use `run_detached()`). On macOS `run()` must be on the main thread.
- Guard updates with `try/except`: assigning before the icon is shown can raise.
- Notifications: `icon.notify(message, title)`.

## Windows (raw Win32 / ctypes)

- Update with `Shell_NotifyIconW(NIM_MODIFY, ...)` and `NIF_ICON | NIF_TIP`.
- Create the new `HICON` per frame (or cache all frames as handles once), and destroy handles you no longer need.
- `szTip` is limited to 127 characters plus the terminator.
- Handle `TaskbarCreated` to re-add the icon after Explorer restarts.
- Updating from another thread is generally accepted, but posting a message to the window that owns the icon and updating there is the safest.

## Qt (PySide6 / PyQt)

- Update from the GUI thread only. Use a `QTimer` for the spinner and signals from worker threads for begin/end.

```python
class Spinner(QObject):
    def __init__(self, tray, idle, frames):
        super().__init__()
        self.tray, self.idle, self.frames, self.i = tray, idle, frames, 0
        self.timer = QTimer(self)
        self.timer.setInterval(100)
        self.timer.timeout.connect(self.tick)

    def tick(self):
        self.tray.setIcon(self.frames[self.i % len(self.frames)])
        self.i += 1

    def start(self):
        self.timer.start()

    def stop(self):
        self.timer.stop()
        self.tray.setIcon(self.idle)
```

- Build `QIcon` objects once (from `QPixmap`) and reuse them. Keep the task counter, minimum busy time and per-task errors from `TrayAnimator` in a small controller that starts and stops this timer.
- Tooltip: `tray.setToolTip(text)`.

## Tk

- Tk has no tray support. Use `pystray` in its own thread and `animator` as above.
- Any Tk widget call from the tray thread must go through `root.after(0, fn)`.

## Electron

- Update with `tray.setImage(nativeImage)` and `tray.setToolTip(text)` in the main process.
- Create `nativeImage` objects once from files; provide `@2x` files for high-DPI.

```js
let busy = 0, timer = null, i = 0;
function begin() {
  if (busy++ === 0) timer = setInterval(() => tray.setImage(frames[i++ % frames.length]), 100);
}
function end() {
  if (--busy === 0) { clearInterval(timer); tray.setImage(idle); }
}
```

- Renderer processes should ask the main process (IPC) to begin and end tasks.

## macOS menu bar

- Menu-bar images are monochrome templates (file names ending in `Template`, or `setTemplate(true)`); color is ignored. Convey state with shape: a rotating arc, a check, an exclamation mark.
- Swap frames through `NSStatusItem.button.image` on the main thread (or `rumps` `app.icon`).
- Keep the animation subtle; the menu bar is shared space.

## Linux

- StatusNotifierItem / AppIndicator support differs by desktop. GNOME needs an extension to show the icon at all.
- Updating the icon on a timer usually works; if the desktop ignores frequent updates, fall back to a static busy badge and update the tooltip text instead.
