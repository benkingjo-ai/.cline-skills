import threading, time
import pystray
from tray_anim import TrayAnimator, load_base_icon


def main():
    holder = {}

    def fake_work(seconds, fail=False):
        def job():
            time.sleep(seconds)
            if fail:
                raise RuntimeError("simulated failure")
        try:
            holder["anim"].run("demo", job)
        except RuntimeError:
            pass

    def run_in_thread(*args, **kwargs):
        threading.Thread(target=fake_work, args=args, kwargs=kwargs, daemon=True).start()

    def quit_app(icon, item):
        holder["anim"].stop()
        icon.stop()

    menu = pystray.Menu(
        pystray.MenuItem("Simulate sync (3 s)", lambda i, m: run_in_thread(3)),
        pystray.MenuItem("Simulate error", lambda i, m: run_in_thread(1, fail=True)),
        pystray.MenuItem("Simulate success", lambda i, m: run_in_thread(1)),
        pystray.MenuItem("Quit", quit_app),
    )
    icon = pystray.Icon("tray_demo", load_base_icon(), "Tray demo", menu)
    holder["anim"] = TrayAnimator(icon, name="Tray demo", busy_text="syncing…")
    holder["anim"].start()
    icon.run()


if __name__ == "__main__":
    main()
