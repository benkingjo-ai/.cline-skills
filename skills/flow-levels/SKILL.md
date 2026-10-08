---
name: flow-levels
description: House work levels, one per request: baseline, optimize, commit, release. Follow only the named section, never ask, never mix. Fire on a level word (commit, optimize, release, normal), on wrapping up, on optimizing, or on a release build.
---

# Workflow Levels

**One level per request, and only the steps that level lists.** The level comes from the
typed word (`baseline`, `optimize`, `commit`, `release`) and from nothing else - not from what
the task seems to need.

- Do **only** the steps of the named level. A step that belongs to another level is **not**
  performed and **not** asked about: name it in one line at the end and stop.
- Never mix two levels in one pass, and never continue "helpfully" into the next step.
- Never ask whether to move up. You name the next level when you want it.
- Stop-and-report - never a question - only for: a red test run, a change unrelated to the
  task, a rejected push, or a step this level requires that cannot be completed.

## The four levels

| Level | Tests | Optimize perf + dead code | Clear cache | Docs | Commit | Push | Build |
|---|---|---|---|---|---|---|---|
| **baseline** (default) | affected only | - | - | - | - | - | - |
| **optimize** | full | yes | yes | - | - | - | - |
| **commit** | full | - | yes | yes | yes | yes | - |
| **release** | - | - | - | - | - | - | yes |

## Level boundaries

| Level | Does | Never does |
|---|---|---|
| **baseline** | the scoped fix, affected tests | full suite, cache clear, dead-code sweep, docs, commit, push, build |
| **optimize** | profile, optimize, dead code, clear cache, full suite | docs, commit, push, build |
| **commit** | dead code, clear cache, full suite, docs, commit, push | build or package |
| **release** | the one-file build | tests, docs, commit, push, cache clear, folder build |

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

A need for docs, a build or a commit does **not** change the level: leave it undone, name it
in one line, and stop - do not ask, and do not do it.

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
- Docs, a build, a package or a push are other levels' steps: leave them undone and name them
  in one line - never ask and never do them.

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
- A distributable is the `release` level's own step: leave it, name it in one line - do not
  build and do not ask.

## Release (level 4)

Build the distributable. **This level does only the build, and the only artefact is a single
file.**

| # | Step | Detail |
|---|---|---|
| 1 | **Build / package** | PyInstaller **one-file** per the `flow-delivery` skill (**One-file only**) - a `.spec` whose version resource comes from `APP_VERSION`, output in `dist/`. |

- **Never** a folder build: no `--onedir`, no directory release, no `.zip` of a folder - a
  one-folder build is a diagnostic at most and is never handed to a user.
- **No** test run, docs, commit or push at this level - those belong to `commit`.
- Do **not** hand-type the version in two places (see the `app-identity` skill).
- If the message carries a version - `/release 1.4.2` or just a number - use it for the build.
- End with the artefacts produced (the `.exe` path under `dist/`, plus the version used).