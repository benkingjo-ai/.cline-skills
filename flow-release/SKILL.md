---
name: flow-release
description: Release level for house projects — run the FULL test suite, update the docs, create the commit and then build the distributable, in that order. Fire only when the user explicitly asks for a release or a release build. Trigger when the user sends only the word release with no other instruction, when a message begins with the word release, or when the user explicitly asks to produce a release or a distributable exe. A version passed by the user, for example /release 1.4.2, must be applied to APP_VERSION and the CHANGELOG.md heading.
---

# Workflow Level — RELEASE

Run these steps **in order**. Do not skip, reorder or parallelise them.

| # | Step | Detail |
|---|---|---|
| 1 | **Full test run** | The **entire** suite. **Stop immediately on the first failure** and report it — nothing below runs on a red suite. |
| 2 | **Update docs** | `README.md`, `CHANGELOG.md` (keep-a-changelog), `docs/` — match them to the code. |
| 3 | **Commit** | Stage the intended changes and write a clear message. |
| 4 | **Build / package** | PyInstaller one-file per the `flow-delivery` skill — a `.spec` whose version resource comes from `APP_VERSION`, output in `dist/`. |

## Never

- Do **not** build or commit before the full test suite passes.
- Do **not** hand-type the version in two places (see the `app-identity` skill).

## Report

End with the artefacts produced (paths under `dist/`, plus the version used).

## If a version was passed

If the message carries a version — `/release 1.4.2`, `release 1.4.2` or just a version
number — use it, and make sure `APP_VERSION` and the `CHANGELOG.md` heading both carry it.

## Level summary

Level 4 of 4: **full test run, update docs, commit, build. Never skip, reorder or parallelise.**

The shared four-level table is defined once in the `flow-baseline` skill. The version rule is owned by the `app-identity` skill (APP_VERSION lives in one place, `config.py`).