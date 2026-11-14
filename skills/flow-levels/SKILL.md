---
name: flow-levels
description: House work commands, one per request: code edit (default), clean up, build, dist, push (patch), push-minor, push-master. Follow only that command's steps, never ask, never mix. Fire on a command word, on optimising, or on wrapping up.
---

# Workflow Commands

**One command per request, only the steps the named command lists.** The command comes from the
typed word (`code edit`, `clean up`, `build`, `push`) and from nothing else.

- Do **only** the steps of the named command. A step of another command is **not** performed and
  **not** asked about: name it in one line and stop.
- Never ask whether to run another command: name the next one when you want it.
- Stop-and-report only for: a red test run, an unrelated change, a rejected push, or a required
  step that cannot be completed.

## The four commands (and their two version variants)

| Command | Typed | Steps, in order | Version | Never does |
|---|---|---|---|---|
| **code edit** (default) | `/edit` or `code edit` | **A** partial test | - | clean up, cache clear, full test, docs, commit, push, build |
| **clean up** | `/cleanup` or `clean up` | **B** clean up, **C** full test | - | docs, commit, push, build |
| **build** | `/build` or `build`, alias `/dist` | **C** full test, **D** build | - | docs, commit, push, folder build |
| **push** | `/push` or `push` | **C** full test, **E** docs, **F** push | patch | build or package, force-push, another branch |
| **push-minor** | `/push-minor` | **C** full test, **E** docs, **F** push | minor | as `push` |
| **push-master** | `/push-master` | **C** full test, **E** docs, **F** push | major | as `push` |

`code edit` is what you get when nothing is typed. A step a command does not list is left undone
and named in one line - never asked about.

## The actions

| # | Action | Steps | Detail owned by |
|---|---|---|---|
| **A** | **partial test** | run **only** the tests that cover the edited code, report the result | `flow-delivery`, *Testing* |
| **B** | **clean up** | 1 profile the hot path first, 2 optimise the measured hot spots, 3 remove dead code, 4 clear the cache set | this skill, *Clear cache set* |
| **C** | **full test** | run the **entire** suite and report pass/fail counts; a failure stops the command | `flow-delivery`, *Testing* |
| **D** | **build** | PyInstaller **one-file** exe into `dist/` | `flow-delivery`, *One-file only* |
| **E** | **docs** | match `README.md`, `CHANGELOG.md` (keep-a-changelog) and `docs/` to the code | `flow-delivery` §1, *Documentation* |
| **F** | **push** | review `git status --porcelain`, stage the intended changes, write a clear message, commit, push the branch to its upstream | this skill |

## Clear cache set

`__pycache__/`, `*.pyc`, `.pytest_cache/`, `.mypy_cache/`, `build/`, `dist/`.

## Version bumps

`VERSION` (`X.Y.Z`, one place) is bumped by the command and recorded per release in
`CHANGELOG.md` (keep-a-changelog; format owned by `flow-delivery`).

| Command | Bump | Example |
|---|---|---|
| `push` | patch | 1.0.0 -> 1.0.1 |
| `push-minor` | minor | 1.0.1 -> 1.1.0 |
| `push-master` | major | 1.1.0 -> 2.0.0 |

- Bump `VERSION` before the docs step so the changelog entry and the commit subject
  (`release vX.Y.Z: <summary>`) carry the new number.
- Tag the release commit `vX.Y.Z`. No release branches: the tag and the push go to the current
  branch and its upstream.

## What each command adds

**code edit - A**
- The **smallest correct change**, scoped to the code the user pointed at. No drive-by refactors.
- Tests: run **only** the covering tests; report the result.
- No docs, build or commit; leave the tree dirty; name what remains.

**clean up - B, C**
- Profile first: no speculative rewrites; behaviour must stay identical (the full suite is the
  proof).
- Dead code: unused imports, unreachable branches, leftover debug hooks.
- Clear the cache set **last** - deleted, never committed - never right after a build.
- Stop and report if the suite fails, or a change would alter observable behaviour.

**build - C, D**
- Full suite **before** the build: never package a red tree.
- **One-file only** (owner `flow-delivery`): a single `<App>.exe` in `dist/`; never `--onedir` or
  a folder release.
- Do **not** hand-type the version twice (`app-identity`); a version in the message
  (`/build 1.4.2`) is used for the build.
- No docs, commit or push here.
- End with the artefacts (the `.exe` path under `dist/`, plus the version used).

**push / push-minor / push-master - C, E, F**
- **Remote first**: `git remote get-url --push <remote>` (normally `origin`) — must be the
  **`benkingjo-ai`** account; missing or foreign = stop-and-report. The `pre-push` hook
  enforces the same, so a manual `git push` elsewhere is blocked too (`skill-authoring`,
  *Push remote guard*).
- Full suite **before** the commit: stop on anything failing — never commit or push a red build.
- Bump `VERSION` by the component the command names (patch / minor / major), then write the
  `CHANGELOG.md` entry for it - see *Version bumps*.
- Run C, E and F in order **without asking** - F is part of the command, not optional, so never
  ask whether to push. Tag the release commit `vX.Y.Z`.
- Stop and report if the diff contains changes unrelated to this task (they need your decision).
- Push **only** the branch just committed, to its existing upstream; never force-push and never
  push another branch. With no upstream, or a push rejected (auth, non-fast-forward), **stop and
  report** - do not force.
- No build or package: no PyInstaller, no `build.ps1`, no `dist/`.
- **Pre-flight git status (F):** run `git status --porcelain` *and* `git diff --stat` before the
  bump; abort on untracked temp/debug artefacts (named, left out), secrets (`docs/`, `tools/`,
  `*.ini`), or a failing suite — never push a red tree.