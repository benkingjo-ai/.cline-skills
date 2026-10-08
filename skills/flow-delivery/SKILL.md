---
name: flow-delivery
description: House conventions for docs, tests, tools and packaging: README linking one product doc, keep-a-changelog, pytest tests kept GUI-free, tools/ probes, and PyInstaller one-file builds. Use when writing docs or tests, or building a release exe.
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

Skills never live in a project: a skill belongs in the global library (see the `skill-authoring`
skill). Do not keep a `*.skill` bundle, a `SKILL.md` or a `references/` folder under `docs/`.

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

- **One-file only**: the release artefact is a single `<App>.exe`; `<App>.spec` reads
  `APP_VERSION` for the exe Details tab — never hand-type the version in two places. A
  one-folder build (`--onedir`) is **never** released or handed to a user - at most it is a
  temporary diagnostic against a scanning endpoint. A one-file build unpacks its runtime into `%TEMP%\_MEIxxxxxx`
  and executes from there. That staging shape is what a behaviour-scoring endpoint product
  reads as a dropper, so keep the rest of the ship-out free of scored behaviour rather than
  change the layout. Give the build script switches for the interpreter and the output
  folder, and clear a held previous build by hydrating its placeholder files before
  retrying: a synced folder such as OneDrive leaves read-only placeholders that
  refuse deletion.
- `build.ps1` (or `run.cmd`) builds; output in `dist/`.
- `release/` holds `<App>-<ver>.bundle.sha256.txt`.
- **Put the venv outside the repo** — PySide6/PyQt unpacks deeply nested paths and
  Windows' 260-char limit breaks pip under a long OneDrive checkout (e.g. `D:\gv`).
- Python 3.14 (64-bit) unless a wheel forces otherwise; check with `py -0p`.
- New project → `.gitignore`, `README.md`, `CHANGELOG.md`, `requirements.txt` (or
  `pyproject.toml`) first.
