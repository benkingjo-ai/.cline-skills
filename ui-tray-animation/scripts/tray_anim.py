import threading, time
from datetime import datetime
from PIL import Image, ImageDraw

SIZE = 64
SUPERSAMPLE = 4
COLORS = {
    "badge_bg": (18, 18, 18, 255),
    "busy": (90, 160, 255, 255),
    "ok": (166, 227, 161, 255),
    "error": (255, 77, 77, 255),
}


def load_base_icon(path=None, size=SIZE, color="#C0C8D8"):
    if path:
        try:
            return Image.open(path).convert("RGBA").resize((size, size), Image.LANCZOS)
        except Exception:
            pass
    big = size * SUPERSAMPLE
    img = Image.new("RGBA", (big, big), (0, 0, 0, 0))
    m = big // 16
    ImageDraw.Draw(img).ellipse((m, m, big - m, big - m), fill=color)
    return img.resize((size, size), Image.LANCZOS)


def render(base, kind, angle=0, colors=None):
    c = {**COLORS, **(colors or {})}
    size = base.size[0]
    s = size * SUPERSAMPLE
    img = base.resize((s, s), Image.LANCZOS).convert("RGBA")
    if kind == "idle":
        return img.resize((size, size), Image.LANCZOS)
    d = ImageDraw.Draw(img)
    x0, y0, x1, y1 = int(s * 0.44), int(s * 0.44), int(s * 0.99), int(s * 0.99)
    cx, cy, r = (x0 + x1) / 2, (y0 + y1) / 2, (x1 - x0) / 2
    if kind == "busy":
        d.ellipse((x0, y0, x1, y1), fill=c["badge_bg"])
        w = max(2, int(s * 0.09))
        pad = w * 0.9
        d.arc((x0 + pad, y0 + pad, x1 - pad, y1 - pad), start=angle, end=angle + 270, fill=c["busy"], width=w)
    elif kind == "ok":
        d.ellipse((x0, y0, x1, y1), fill=c["ok"])
        d.line([(cx - 0.45 * r, cy + 0.02 * r), (cx - 0.12 * r, cy + 0.38 * r), (cx + 0.5 * r, cy - 0.34 * r)],
               fill=c["badge_bg"], width=max(2, int(s * 0.07)), joint="curve")
    elif kind == "error":
        d.ellipse((x0, y0, x1, y1), fill=c["error"])
        d.line([(cx, cy - 0.52 * r), (cx, cy + 0.12 * r)], fill="white", width=max(2, int(s * 0.07)))
        dot = 0.12 * r
        d.ellipse((cx - dot, cy + 0.42 * r - dot, cx + dot, cy + 0.42 * r + dot), fill="white")
    return img.resize((size, size), Image.LANCZOS)


class TrayAnimator:
    def __init__(self, icon, base=None, name="App", busy_text="working…", frame_count=12,
                 frame_seconds=0.10, idle_poll_seconds=0.5, min_busy_seconds=0.8, ok_seconds=2.0,
                 animate=True, colors=None):
        self.icon = icon
        self.name = name
        self.busy_text = busy_text
        self.animate = animate
        self.frame_seconds = frame_seconds
        self.idle_poll_seconds = idle_poll_seconds
        self.min_busy_seconds = min_busy_seconds
        self.ok_seconds = ok_seconds
        base = base or load_base_icon()
        count = frame_count if animate else 1
        self.frames = [render(base, "busy", i * 360 // count, colors) for i in range(count)]
        self.static = {k: render(base, k, 0, colors) for k in ("idle", "ok", "error")}
        self._lock = threading.Lock()
        self._busy = set()
        self._errors = {}
        self._busy_until = 0.0
        self._ok_until = 0.0
        self._last_ok = None
        self._last = None
        self._wake = threading.Event()
        self._stop = threading.Event()
        self._thread = threading.Thread(target=self._run, daemon=True)

    def start(self):
        self._thread.start()

    def stop(self):
        self._stop.set()
        self._wake.set()

    def begin(self, task):
        with self._lock:
            self._busy.add(task)
            self._busy_until = max(self._busy_until, time.monotonic() + self.min_busy_seconds)
        self._wake.set()

    def end(self, task, ok=True):
        with self._lock:
            self._busy.discard(task)
            self._errors[task] = not ok
            if ok:
                self._last_ok = datetime.now()
                self._ok_until = max(self._ok_until, time.monotonic() + self.min_busy_seconds + self.ok_seconds)
        self._wake.set()

    def run(self, task, fn, is_ok=lambda result: True):
        self.begin(task)
        ok = False
        try:
            result = fn()
            ok = bool(is_ok(result))
            return result
        finally:
            self.end(task, ok)

    def _state(self):
        now = time.monotonic()
        with self._lock:
            failed = sorted(t for t, bad in self._errors.items() if bad)
            if self._busy or now < self._busy_until:
                return "busy", failed
            if failed:
                return "error", failed
            if now < self._ok_until:
                return "ok", failed
            return "idle", failed

    def _tooltip(self, state, failed):
        if state == "busy":
            return f"{self.name} – {self.busy_text}"
        if state == "error":
            return f"{self.name} – error: {', '.join(failed)}"
        if self._last_ok:
            return f"{self.name} – updated {self._last_ok:%H:%M}"
        return self.name

    def _run(self):
        n = 0
        while not self._stop.is_set():
            state, failed = self._state()
            if state == "busy":
                i = n % len(self.frames)
                key, image = ("busy", i), self.frames[i]
                n += 1
            else:
                key, image = (state, 0), self.static[state]
            if key != self._last:
                self._last = key
                try:
                    self.icon.icon = image
                    self.icon.title = self._tooltip(state, failed)
                except Exception:
                    pass
            spinning = state == "busy" and self.animate
            self._wake.wait(self.frame_seconds if spinning else self.idle_poll_seconds)
            self._wake.clear()
