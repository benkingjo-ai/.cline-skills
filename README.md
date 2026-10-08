# Access Lib — Agentic AI Skills

Reusable skills distilled from the shared conventions of the existing projects
(**CAMonitor**, **GlobalX**, **VerbaPro**, **EchoAI**, **Parleyra**, **IMU ILI**).

Each folder under `skills/` holds one `SKILL.md` with YAML frontmatter (`name` and
`description`, and nothing else), plus optional `docs/` and `scripts/`, so it can be
dropped into a skills directory and invoked when a new project is opened. Only
**common** conventions are recorded here — anything unique to a single project was
deliberately excluded.

The 14 skills are named `<category>-<topic>` with approved prefixes `app-`, `ui-`,
`code-`, `win-`, `flow-` and `skill-`. Most trigger automatically when the topic comes
up; `flow-levels` is the one you select with a word you type.

The lineages: CAMonitor → GlobalX → VerbaPro explicitly cross-reference each other's
code and reuse the same palette, dialogs and Win32 shell behaviour.

## Skills

| # | Skill folder | Covers |
|---|--------------|--------|
| 1 | `app-identity/` | APP_NAME / APP_ID / APP_VERSION, vendor block, paths & `%APPDATA%` rules, `_MEIPASS` resources |
| 2 | `app-structure/` | Repo layout: package folder + module names, sibling `docs/` `tests/` `tools/` `icons/`, entry points |
| 3 | `ui-layout-theme/` | Dark-theme colour palette, Calibri fonts, shared layout metrics (padding, header heights, alpha), popup minimum width and rotation/DPI clamping |
| 4 | `ui-assets/` | Close ✕ / flat / primary buttons, refresh spinner, tray state icons + badges, glyph symbols |
| 5 | `ui-dialogs/` | Borderless dialog shell, the Login panel protocol, auto-hide behaviour |
| 6 | `ui-tray-animation/` | Animated tray icon (idle / busy / ok / error) with a spinning badge, plus framework notes |
| 7 | `win-shell/` | Tray, Alt+Q hotkey (no hook), single-instance mutex, AUMID toasts, popup menus, autostart, display-change re-placement |
| 8 | `win-av-behaviour/` | Endpoint-security behaviour: the shapes an AV/EDR scores, what to do instead, how to verify a build and report a false positive |
| 9 | `code-concurrency/` | Background worker + GUI polling discipline (never touch widgets off-thread) |
| 10 | `code-persistence/` | `settings.ini`, credentials parsing, secret hygiene, file logging |
| 11 | `code-sync/` | Google Apps Script web-app contract (`docs/Code.gs`) |
| 12 | `flow-delivery/` | README/CHANGELOG conventions, GUI-free pytest tests, `tools/` probes, PyInstaller one-file packaging |
| 13 | `flow-levels/` | The four work levels: baseline, optimize, commit, release |
| 14 | `skill-authoring/` | Governs this library: naming, frontmatter, rule registry, `check-skills.ps1` |

## Workflow levels

`flow-levels` sets *how much* work to do on a given request instead of *what* to do. It
is the only skill here that is triggered by a word you type: pick **one** level, and only
that level's steps run — never mixed, and never escalated by asking.

| Level | Trigger | Tests | Optimize perf + dead code | Clear cache | Docs | Commit | Push | Build |
|---|---|---|---|---|---|---|---|---|
| **baseline** | *(default — nothing typed)* | affected only | — | — | — | — | — | — |
| **optimize** | `/optimize` or say `optimize` | full | yes | yes | — | — | — | — |
| **commit** | `/commit` or say `commit` | full | — | yes | yes | yes | yes | — |
| **release** | `/release [version]` or say `release` | — | — | — | — | — | — | one file |

`baseline` is what you get when no level word is typed (the skill historically called it
`normal`). **One level per request**: cline does only that level's steps. Moving up is never
asked for — anything another level owns is left undone and named in one line.

Clear-cache set for all levels: `__pycache__/`, `*.pyc`, `.pytest_cache/`,
`.mypy_cache/`, `build/`, `dist/`.

## How to use

### Available in every project (recommended)

Install the folders once into Cline's global skill roots and they load automatically in
any folder you open, with no per-project setup:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "<Access Lib>\tools\install-skills.ps1"
```

The script locates the repository itself (no path to edit) and junctions all 14 skills
into **both** roots Cline scans globally:

| Root | Read by |
|------|---------|
| `~/.cline/skills/` | Cline |
| `~/.agents/skills/` | Cline, VS Code Copilot, other Agent-Skills runtimes |

Junctions (not copies) keep this folder the single source of truth — edit a `SKILL.md`
here and every project picks it up. Re-running is safe: it creates what is missing,
retargets stale links and leaves everything else alone. Cline does **not** scan
`~/.claude/skills`, so add `-PruneClaude` to retire an older install there, or `-Remove`
to uninstall everything it placed.

Validate the frontmatter before committing:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "<Access Lib>\tools\validate-skills.ps1"
```

Then reload VS Code and open Cline's **Skills** tab (the scale icon left of the model
selector) to confirm all 14 skills are listed and enabled.

### On this machine

- `link-cline-skills.bat` (next to this README) creates the `~/.cline\skills` junction
  onto this `skills\` folder, backing up anything already there.
- `skills\bootstrap.ps1` finishes setup: it **verifies** that junction (it never creates
  it), installs the pre-commit hook, runs `skills\check.bat`, and prints the Cline
  settings you still have to set by hand. Pass `-DryRun` to print every action first.

### Editing the library

Every change under `skills/` is governed by the **`skill-authoring`** skill and the
`skills-governance` global rule: never change a skill without showing the planned change
and getting approval first. Then run the checker and satisfy its Completion gate:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "<Access Lib>\skills\skill-authoring\scripts\check-skills.ps1"
```

`skills\check.bat` wraps the same script. It reports token budgets, duplicates,
description overlap, naming against the approved prefixes, and verifies every rule in the
registry still exists in its owner file.

### One project only

1. Copy the folder you need into the new project's `.cline/skills/` (or `.agents/skills/`).
2. The `description` frontmatter triggers automatically when the topic comes up, or invoke
   the skill by name.
3. The palette/font/metric tables in `ui-layout-theme` and the dialogs protocol in
   `ui-dialogs` are the parts every new GUI project inherits verbatim.

### Triggering a workflow level

| You type | Result |
|---|---|
| nothing | `baseline` — fix the affected code, affected tests only, no docs/build/commit |
| `/optimize` or `optimize` | optimize + dead-code cleanup + cache clear + full tests |
| `/commit` or `commit` | cleanup + cache clear + full tests + docs + commit + push |
| `/release` or `release` | build only — one file: the single exe is the only artefact (no folder build) |

The slash form is deterministic; the bare word relies on the trigger phrases folded into
the skill's `description`, so check the Skills tab if a bare word ever fails to fire.
