---
name: flow-levels
description: House work levels: baseline, optimize, commit, release - follow only the named section. Fire on a level word (commit, optimize, release, normal), on wrapping up and committing, on optimizing, or on a release build.
---

# Workflow Levels

Pick **one** level from the request, then follow only that section. To move up, stop and ask.

## The four levels

| Level | Tests | Optimize perf + dead code | Clear cache | Docs | Commit | Push | Build |
|---|---|---|---|---|---|---|---|
| **baseline** (default) | affected only | - | - | - | - | - | - |
| **optimize** | full | yes | yes | - | - | - | - |
| **commit** | full | - | yes | yes | yes | yes | - |
| **release** | - | - | - | - | - | - | yes |

## Clear cache set

`__pycache__/`, `*.pyc`, `.pytest_cache/`, `.mypy_cache/`, `build/`, `dist/`.

## Baseline (level 1, the default)

Apply unless the request names another level.

| Area | Rule |
|---|---|
| Code | Smallest correct change, **scoped to the code the user pointed at**. No drive-by refactors. |
| Tests | Run **only** the tests that cover the edited code. Report the result. |
| Docs | **None** - do not write or update `README.md`, `CHANGELOG.md` or `docs/`. |
| Build | **None** - do not run PyInstaller or `build.ps1`, do not produce `dist/`. |
| Commit | **None** - leave the working tree dirty. |

If the task genuinely needs docs, a build or a commit, **stop and ask which level to enter**
instead of silently doing more than asked.

## Optimize (level 2)

| # | Step | Detail |
|---|---|---|
| 1 | **Profile first** | Identify the hot path before changing anything. No speculative rewrites. |
| 2 | **Optimize performance** | Improve the measured hot spots. Behaviour must stay identical - the full suite is the proof. |
| 3 | **Remove dead code** | Unused imports, unreachable branches, leftover debug hooks. |
| 4 | **Clear cache** | the clear-cache set above |
| 5 | **Full test run** | Run the **entire** suite, not a subset. Report pass/fail counts. |

- Do **not** write or update documentation, build, or commit - leave the working tree dirty.
- Stop and report if the full suite fails after an optimisation, or if an optimisation would
  change observable behaviour.
- If the task also needs docs, a build or a commit, stop and ask whether to move up.

## Commit (level 3)

| # | Step | Detail |
|---|---|---|
| 1 | **Remove dead code** | Unused imports, unreachable branches, leftover debug hooks. |
| 2 | **Clear cache** | the clear-cache set above |
| 3 | **Full test run** | Run the **entire** suite. **Stop and report if anything fails** - do not commit a red build. |
| 4 | **Update docs** | `README.md`, `CHANGELOG.md` (keep-a-changelog), `docs/` - match them to the code. |
| 5 | **Commit** | Stage the intended changes and write a clear message. |
| 6 | **Push** | Push the branch to its remote (`git push`) so the change leaves this machine. |

- On the word **commit**, run all six steps in order **without asking** — never ask whether to
  push: step 6 is part of the level, not optional. Stop and report only for the failure cases
  below (red suite, unrelated changes, rejected push).

- Do **not** build or package - no PyInstaller, no `build.ps1`, no `dist/`.
- Stop and report if the full suite fails, or if the diff contains changes unrelated to this
  task (they need the user's decision).
- Push **only** the branch just committed, to its existing upstream; never force-push and
  never push another branch. If there is no upstream, or the push is rejected (auth,
  non-fast-forward), **stop and report** - do not force.
- If a distributable is also wanted, stop and ask whether to move up to the release level.

## Release (level 4)

Build the distributable. **This level does only the build.**

| # | Step | Detail |
|---|---|---|
| 1 | **Build / package** | PyInstaller one-file per the `flow-delivery` skill - a `.spec` whose version resource comes from `APP_VERSION`, output in `dist/`. |

- **No** test run, docs, commit or push at this level - those belong to `commit`.
- Do **not** hand-type the version in two places (see the `app-identity` skill).
- If the message carries a version - `/release 1.4.2` or just a number - use it for the build.
- End with the artefacts produced (paths under `dist/`, plus the version used).