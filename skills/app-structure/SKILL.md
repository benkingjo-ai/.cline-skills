---
name: app-structure
description: Lay out a new Windows Python desktop app the house way: package folder names, which module owns what, and where docs/, tests/, tools/ and icons/ go. Use when scaffolding a project, adding a module, or naming files or entry points.
---

# Project Structure

Follow this layout for every new project. It is common to **CAMonitor**, **GlobalX**,
**VerbaPro**, **EchoAI** and **Parleyra**.

## Root

| File / folder | Type | Notes |
|---|---|---|
| `README.md` | product doc entry point | links to `docs/<App>.md` or `docs/ARCHITECTURE.md` |
| `CHANGELOG.md` | keep-a-changelog | version lives in `config.py` |
| `requirements.txt` | pip deps | one line per dependency; no version pins unless a wheel forces otherwise |
| `.gitignore` | baseline | `__pycache__/`, `*.pyc`, `.pytest_cache/`, `.mypy_cache/`, `build/`, `dist/`, `build/*.spec`, `settings.ini`, `*.ini`, `*.log`, `desktop.ini` |
| `run_app.py` | launch from source | Parleyra uses `main.py`; packages use `__main__.py` |
| `<App>.spec` | PyInstaller spec | one-file |
| `build.ps1` / `run.cmd` | build/run script | |
| `.gitignore` | | |
| `<App>.code-workspace` | VS Code workspace | optional |

## Package (lowercase = app name)

`camonitor/`, `globalx/`, `verba/`, `echoai/` (src layout), `app/` (Parleyra).

| Module | Responsibility |
|---|---|
| `__init__.py`, `__main__.py` | package markers / `-m` entry |
| `config.py` | **single source of truth**: identity, paths, palette, fonts, metrics, timings |
| `theme.py` | palette + fonts split out for GUI-free unit tests (GlobalX, VerbaPro) |
| `logger.py` | rotating file logger |
| `settings.py` | `%APPDATA%` `settings.ini` persistence |
| `credentials.py` | recognise the user's credentials file |
| `widgets.py` | shared widgets (`CloseButton`, `FlatButton`, spinner) |
| `panel_dialog.py` | the borderless dialog shell (subclass + `_build()`) |
| `login_dialog.py` | the Login panel |
| `dialogs.py` | other modal dialogs |
| `popup.py` / `overlay.py` | the main panel / overlay window |
| `tray.py`, `hotkey.py` | system tray, Alt+Q |
| `notify.py`, `appid.py` | toasts, AppUserModelID |
| `app.py` | wiring / startup |
| `utils.py`, `winapi.py` | shared helpers, Win32 declarations |
| `sheets.py` / `sync.py` / `client.py` | transport / API |

## Sibling folders

| Folder | Contents |
|---|---|
| `docs/` | `<App>.md` (single product doc), `ARCHITECTURE.md`, `plans/*.md`, `RELEASE-x.y.z.md`, `Code.gs` - contents conventions owned by the `flow-delivery` skill |
| `tests/` | `test_*.py` (pytest) |
| `tools/` | `spike_*.py`, `verify_app.py`, `release_check.py`, `make_icons.py`, `drive_*.py` - conventions owned by the `flow-delivery` skill |
| `icons/` or `assets/app`, `assets/icons` | shipped `.ico` / `.png` |
| `art/` | source artwork master (brand icon only; per-state assets are generated in memory — see `ui-assets`) |
| `scripts/` | `*.ps1` setup/run scripts |
| `dist/`, `build/`, `release/` | build output, release bundles |

## Rules

- **Baseline .gitignore** — the excludes in the table above; copy them into every new project.
- **One concern per module**; a module that grows unreadable is split into mixins
  (e.g. `popup_timers.py`) rather than allowed to sprawl.
- **Constants never scattered** — a magic number belongs in `config.py`/`theme.py`.
- **Packages import from the package** (`from camonitor.config import …`), not relatively.

## Project profiles

- **Profile A - Standard desktop GUI app (default):** the full stack applies - app-identity,
  app-structure, the ui-* skills, win-shell, code-concurrency, code-persistence, flow-*.
- **Profile B - CLI / automation script / library:** no GUI entry point, or the user says
  CLI/script/tool. **Skip ui-* and win-shell entirely**; enforce only app-identity,
  code-persistence (when stateful) and flow-*. The ui-* and win-shell descriptions say
  "Use ONLY for a Windows GUI...", which is how Profile B skips them.
- **code-sync** applies only when docs/Code.gs exists or sync is requested.
- **Ask once** when the profile is not obvious from the code; otherwise assume A.