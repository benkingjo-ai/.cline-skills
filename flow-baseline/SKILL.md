---
name: flow-baseline
description: Default working level for house projects — make the smallest correct change, run only the tests covering it, and touch no docs, no build and no commit. This is the baseline whenever the user does not name another level such as optimize, commit or release. Apply by default on any ordinary code task that names no level. Also fire when the user types the word normal to return to the baseline after another level.
---

# Workflow Level — NORMAL

The baseline. Apply it unless the user's message contains a level word
(`flow-optimize`, `flow-commit`, `flow-release`).

> Shared definition: the four-level table and the clear-cache set at the end of this file are owned here. The `flow-optimize`, `flow-commit` and `flow-release` skills link back to this file instead of copying them.

## Do

| Area | Rule |
|---|---|
| Code | Smallest correct change, **scoped to the code the user pointed at**. No drive-by refactors. |
| Tests | Run **only** the tests that cover the edited code. Report the result. |
| Docs | **None** — do not write or update `README.md`, `CHANGELOG.md` or `docs/`. |
| Build | **None** — do not run PyInstaller or `build.ps1`, do not produce `dist/`. |
| Commit | **None** — leave the working tree dirty. |

## Escalate

If the task genuinely needs docs, a build or a commit, **stop and ask which level to
enter** instead of silently doing more than asked.

## The four levels

| Level | Tests | Optimize perf + dead code | Clear cache | Docs | Commit | Build |
|---|---|---|---|---|---|---|
| **normal** (this one) | affected only | — | — | — | — | — |
| `flow-optimize` | full | yes | yes | — | — | — |
| `flow-commit` | full | — | yes | yes | yes | — |
| `flow-release` | full | — | — | yes | yes | yes |

## Clear cache set

`__pycache__/`, `*.pyc`, `.pytest_cache/`, `.mypy_cache/`, `build/`, `dist/`.