---
name: flow-delivery
description: Follow the house conventions for documentation, testing and release — README linking a single product doc, keep-a-changelog CHANGELOG with the version in config.py, docs/ARCHITECTURE.md module map, docs/plans and RELEASE notes, pytest tests kept GUI-free, tools/spike_*.py probes, verify/release_check scripts, and PyInstaller packaging with a .spec whose version resource matches APP_VERSION. Use whenever writing docs, tests, spikes, changelogs, or building and releasing an exe.
---

# Docs, Testing & Packaging

> Ownership: this skill defines the conventions for docs, tests, tools and packaging. The `app-structure` skill maps where these folders live and links back here.

## 1. Documentation

| File | Rule |
|---|---|
| `README.md` | short product pitch + quick start; **points at** the docs, never duplicates them |
| `CHANGELOG.md` | keep-a-changelog (`### Added` / `### Changed`); states *"the version lives in one place, `<pkg>/config.py` (`APP_VERSION`)"* |
| `docs/<App>.md` | **one** product document: part 1 manual, parts 2–4 requirement specs |
| `docs/ARCHITECTURE.md` | the module map |
| `docs/plans/*.md` | feature plans, one per feature |
| `docs/RELEASE-x.y.z.md` | artefact checksum, restore recipes, everything deliberately outside Git |
| `docs/Code.gs` | the Apps Script to paste into the sheet (see `code-sync`) |
| `docs/*.skill` | bundled skills (folder with `SKILL.md` + `references/`) |

Voice: describe **behaviour and the reason for it**; cite the spec/manual section it comes
from (e.g. *"manual 11.1"*, *"Sheets spec 14.3"*).

## 2. Testing

- `tests/test_*.py` with **pytest**; `tests/unit`, `tests/integration`, `tests/gui` when
  the project grows (EchoAI).
- Test **pure logic without a GUI** — that is why palette/formatter/menu builders live in
  `theme.py` / `panel_menu.py` as plain functions.
- Inject the impure dependencies into dialogs (file picker, connection tester, settings
  path) so a test can drive them without a network or a real file dialog.
- Keep hard numbers under test: colours, font sizes, bar geometry, menu label lists,
  secret patterns.
- Pytest config (`pythonpath`, `testpaths`, markers such as `gui` and `slow`) lives in
  `pyproject.toml`.

## 3. Tools

| Script | Purpose |
|---|---|
| `tools/spike_*.py` | one-off manual probe — tray menu, hotkey loss, AUMID toast, login picker |
| `tools/verify_app.py` | run the app through its checks |
| `tools/release_check.py` | scan the built exe for leaked secrets |
| `tools/make_icons.py` | bake `.ico` frames from `art/<App> master.png` at 2× |
| `tools/drive_*.py` / `grab_popup.py` | drive the GUI for live checks |

## 4. Packaging & release

- **PyInstaller** one-file; `<App>.spec` reads `APP_VERSION` for the exe Details tab —
  never hand-type the version in two places.
- `build.ps1` (or `run.cmd`) builds; output in `dist/`.
- `release/` holds `<App>-<ver>.bundle.sha256.txt`.
- **Put the venv outside the repo** — PySide6/PyQt unpacks deeply nested paths and
  Windows' 260-char limit breaks pip under a long OneDrive checkout (e.g. `D:\gv`).
- Python 3.11 (64-bit) unless a wheel forces otherwise; check with `py -0p`.
- New project → `.gitignore`, `README.md`, `CHANGELOG.md`, `requirements.txt` (or
  `pyproject.toml`) first.
