---
name: flow-optimize
description: Performance level for house projects — improve hot paths, remove dead code, clear caches and run the FULL test suite, with no docs, no build and no commit. Fire only when the user explicitly asks for an optimization or cleanup pass. Trigger when the user sends only the word optimize with no other instruction, when a message begins with the word optimize, or when the user explicitly asks to speed something up while ruling out docs, build and commit.
---

# Workflow Level — OPTIMIZE

## Do

| # | Step | Detail |
|---|---|---|
| 1 | **Profile first** | Identify the hot path before changing anything. No speculative rewrites. |
| 2 | **Optimize performance** | Improve the measured hot spots. Behaviour must stay identical — the full suite is the proof. |
| 3 | **Remove dead code** | Unused imports, unreachable branches, leftover debug hooks. |
| 4 | **Clear cache** | the clear-cache set defined in the `flow-baseline` skill |
| 5 | **Full test run** | Run the **entire** suite, not a subset. Report pass/fail counts. |

## Never

- Do **not** write or update documentation.
- Do **not** build or package.
- Do **not** commit — leave the working tree dirty.

## Stop and report if

- The full test suite fails after an optimisation, or
- an optimisation would change observable behaviour.

## Escalate

If the task also needs docs, a build or a commit, stop and ask whether to move up to
the `flow-commit` or `flow-release` level.

## Level and cache set

Level 2 of 4: **full test run, optimize + dead code, clear cache; no docs, no build, no commit.**

The shared four-level table and the clear-cache set are defined once in the `flow-baseline` skill. Follow those definitions rather than a copy here.