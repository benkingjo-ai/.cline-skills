---
name: flow-commit
description: Cleanup-and-ship level for house projects — remove dead code, clear caches, run the FULL test suite, update the docs and create a commit, with no build. Fire only when the user explicitly asks to commit. Trigger when the user sends only the word commit with no other instruction, when a message begins with the word commit, or when the user explicitly asks to wrap the work up and commit it.
---

# Workflow Level — COMMIT

## Do

| # | Step | Detail |
|---|---|---|
| 1 | **Remove dead code** | Unused imports, unreachable branches, leftover debug hooks. |
| 2 | **Clear cache** | the clear-cache set defined in the `flow-baseline` skill |
| 3 | **Full test run** | Run the **entire** suite. **Stop and report if anything fails** — do not commit a red build. |
| 4 | **Update docs** | `README.md`, `CHANGELOG.md` (keep-a-changelog), `docs/` — match them to the code. |
| 5 | **Commit** | Stage the intended changes and write a clear message. |

## Never

- Do **not** build or package — no PyInstaller, no `build.ps1`, no `dist/`.
- Do **not** commit when the full suite is failing.

## Stop and report if

- The full test suite fails, or
- the diff contains changes unrelated to this task (they need the user's decision).

## Escalate

If a distributable is also wanted, stop and ask whether to move up to the `flow-release`
level.

## Level and cache set

Level 3 of 4: **full test run, clear cache, update docs, commit; no build.**

The shared four-level table and the clear-cache set are defined once in the `flow-baseline` skill. Follow those definitions rather than a copy here.