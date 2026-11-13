# Changelog

All notable changes to this skills library. Format: keep-a-changelog. The version lives in
`VERSION` - one place, bumped by the `push` commands (see the `flow-levels` skill).

## [2.0.0] - 2026-11-13

### Breaking

- **Assets are native.** `ui-assets` now builds chrome from Windows stock icons
  (`SHGetStockIconInfo` / `LoadIconW` / `QStyle.StandardPixmap`), the Segoe glyph font stack
  (`Segoe Fluent Icons` -> `Segoe MDL2 Assets` -> `Segoe UI Symbol`) and Unicode escapes;
  tray state badges are composited in memory. Per-state `.ico` files, `refresh-*.png` frames,
  the `art/` master pipeline and `tools/make_icons.py` are retired - the brand `.ico` is the
  only image a project ships.
- **Git hooks moved** into the tracked `.githooks/` folder, activated by `core.hooksPath`
  (`install-hook.ps1`). Nothing is copied into `.git` any more.

### Added

- `app-identity`: ready-to-copy `resource_path(rel)` (`_MEIPASS`) and `app_dir()` bodies.
- `app-structure`: **Baseline .gitignore** and minimal `requirements.txt` conventions.
- `code-concurrency`: `threading.Event` stop-event plus queue-based polling in the shape.
- `code-persistence`: **Atomic save** (`*.tmp` + `os.replace`, with the measured
  `[WinError 5]` fallback) and `RotatingFileHandler(maxBytes, backupCount=1)`.
- `code-sync`: explicit timeout (15 s) and bounded retry/backoff (3 tries, 1/2/4 s).
- `flow-delivery`: `--exclude-module` for unused heavy packages in the one-file build.
- `flow-levels`: **Pre-flight git status** before a version bump.
- `ui-dialogs`: monitor-bounds clamping pointer for an unplugged second display.
- `ui-tray-animation`: 80 ms / 12 FPS floor, stop the animator on idle, frames generated in
  memory at startup.
- `win-shell`: **Teardown** section - `UnregisterHotKey` + `CloseHandle` via
  `atexit`/`try...finally`, on normal and abnormal exit.
- `skill-authoring`: **Git hooks** section documenting the two tracked hooks.

### Changed

- `flow-levels` lists all six commands (`push` / `push-minor` / `push-master`) with their
  version bumps, tags and the `benkingjo-ai` remote guard.
- Rule registry now holds 39 rules.

## [2.1.0] - 2026-11-13

### Added

- Token optimisation: SKILL.md files rewritten to dense telegraphic bullets/tables
  (ui-tray-animation 2022 to 1114, flow-levels 1600 to 1470, skill-authoring 1405 to 1379,
  ui-layout-theme 1076 to 1045, code-concurrency 640 to 628; follow-up trims: win-shell 1315
  to 1280, app-identity 829 to 823, ui-assets 656 to 636, flow-delivery 939 to 913).
- Trigger scoping: `Use ONLY ...` description prefixes on ui-layout-theme, ui-assets,
  ui-dialogs, ui-tray-animation, win-shell and code-sync.
- Project profiles in `app-structure`: Profile A (GUI desktop app, full stack) vs Profile B
  (CLI / automation script / library: skip ui-* and win-shell).
- Skill rules: native-only ui-assets, 8-12 FPS and idle stop in ui-tray-animation,
  deterministic win-shell teardown, atomic settings.ini save, RotatingFileHandler,
  PyInstaller --noupx / --exclude-module, safe-push pre-flight.
- `snippet.md` merged into this entry, then deleted.

### Changed

- VERSION 2.0.0 to 2.1.0 (minor: new feature set, backwards compatible).
- Always-on token budget 747 to 738.

## [1.0.1] - 2026-10-08

### Fixed

- `flow-levels`: the push remote check now reads `git remote get-url --push <remote>`. The
  previous wording omitted the remote name, so the command printed git usage instead of the
  URL.

### Changed

- Patch bump; no other content change since 1.0.0.

## [1.0.0] - 2026-10-08

### Added

- 13 skills: `app-identity`, `app-structure`, `ui-layout-theme`, `ui-assets`, `ui-dialogs`,
  `ui-tray-animation`, `win-shell`, `code-concurrency`, `code-persistence`, `code-sync`,
  `flow-delivery`, `flow-levels`, `skill-authoring`.
- Four action commands in `flow-levels`: **code edit** (the default), **clean up**,
  **build**, **push** - each with a fixed step list, never mixing and never asking.
- Actions A-F: partial test, clean up (profile, optimise, dead code, clear cache), full
  test, build (one-file exe), docs, push.
- The versioned push family: `push` (patch), `push-minor`, `push-master`, locked to the
  `benkingjo-ai` remote by a `pre-push` guard.

### Changed

- The level vocabulary (baseline / optimize / commit / release) is replaced by commands.
- The `win-av-behaviour` skill was folded into the skills whose rules it justified.
- Hotkeys are `RegisterHotKey` only - the `WH_KEYBOARD_LL` hook is gone.
- The popup has a minimum width and re-places itself on a rotation or DPI change.
- The release artefact is one file only; a folder build is never shipped.
