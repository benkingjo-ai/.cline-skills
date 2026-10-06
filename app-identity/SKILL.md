---
name: app-identity
description: Define a project's identity and data paths — the APP_NAME / APP_ID split, APP_VERSION living in one place, the VENDOR / TRADEMARK / COPYRIGHT block, resolving PROJECT_ROOT, the %APPDATA%\<APP_ID> rule for all user data and secrets, and _MEIPASS-aware resource paths. Use whenever naming an app, setting a version, creating config.py, computing file paths, or deciding where logs, settings and credentials are stored.
---

# App Identity & Paths

Every `config.py` opens with the same two blocks. They are the single source read by
the app, `run_app.py`, `<App>.spec` (exe Details tab), the tray tooltip, the startup task
and the first line of the log.

## 1. Identity

```python
APP_NAME    = "MyApp"      # what a person reads: window title, tray tooltip, exe Details
APP_ID      = "MyApp"      # what names things on disk and Windows: exe, %APPDATA%,
                           # scheduled task, registry value
APP_VERSION = "1.1.0"      # ONE place; the spec and the log quote it
APP_TAGLINE = "One line about the product."

VENDOR      = "Benkingjo.Inc"
TRADEMARK   = APP_NAME + "™"
COPYRIGHT   = "© 2026 Benkingjo.Inc. All rights reserved."
VENDOR_LINE = TRADEMARK + " — a " + VENDOR + " product"
```

- `APP_NAME` and `APP_ID` coincide unless the product carries a suffix.
- `MUTEX_NAME = APP_ID + "SingleInstanceMutex"` (see the win-shell skill).
- Keep **previous brand ids/names/mutexes** in a list if the app was ever rebranded, so an
  old `%APPDATA%` folder can be adopted and a mixed machine can't run two brands at once.

## 2. Paths

```python
PACKAGE_DIR  = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.dirname(PACKAGE_DIR)     # icons/, tools/ live here

APP_DIR = os.path.join(os.environ.get("APPDATA", tempfile.gettempdir()), APP_ID)
LOG_FILE      = os.path.join(APP_DIR, "<app>.log")
ENTRIES_FILE  = os.path.join(APP_DIR, "entries.json")
SETTINGS_FILE = os.path.join(APP_DIR, "settings.ini")
```

| Rule | Why |
|---|---|
| All user data under `%APPDATA%\<APP_ID>` | conventional, per-user, not synced |
| **Never** store credentials in the program folder | the program folder syncs through OneDrive — a URL/token there is copied to every machine |
| `resource_path(name)` is `_MEIPASS`-aware | PyInstaller one-file unpacks to a temp dir that is deleted on exit |
| Icons: `ICON_DIR_NAME` = `icons` / `assets/app`; `ICON_ICO_NAME` = `"<App>.ico"` | name-based lookup, bundled-copy preferred |

## 3. Standard helpers in `config.py`

- `app_dir()` — create `%APPDATA%\<APP_ID>` and return it.
- `resource_path()` / `icon_path()` — bundled resource lookup.
- `migrate_legacy()` — copy (never move) an old brand's files into `APP_DIR`, leaving a
  `migrated_from_<id>.txt` marker so it runs once per brand; never overwrite a file that
  is already there.
- `acquire_single_instance()` — see the win-shell skill.

> Autostart (Task Scheduler ONLOGON task with the HKCU Run-key fallback) is owned by the `win-shell` skill, which covers all Windows shell integration. It moved there so this file stays about identity and paths.