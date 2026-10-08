# Changelog

All notable changes to this skills library. Format: keep-a-changelog. The version lives in
`VERSION` - one place, bumped by the `push` commands (see the `flow-levels` skill).

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
