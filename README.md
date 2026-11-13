# Access Lib — Agentic AI Skills

Reusable skills distilled from the shared conventions of the existing projects
(**CAMonitor**, **GlobalX**, **VerbaPro**, **EchoAI**, **Parleyra**, **IMU ILI**).

Each folder under `skills/` holds one `SKILL.md` with YAML frontmatter (`name` and
`description`, and nothing else), plus optional `docs/` and `scripts/`, so it can be
dropped into a skills directory and invoked when a new project is opened. Only
**common** conventions are recorded here — anything unique to a single project was
deliberately excluded.

The 13 skills are named `<category>-<topic>` with approved prefixes `app-`, `ui-`,
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
| 4 | `ui-assets/` | Native Windows icons, Segoe glyph fonts, glyph symbols |
| 5 | `ui-dialogs/` | Borderless dialog shell, the Login panel protocol, auto-hide behaviour |
| 6 | `ui-tray-animation/` | Animated tray icon (idle / busy / ok / error) with a spinning badge, plus framework notes |
| 7 | `win-shell/` | Tray, Alt+Q hotkey (no hook), single-instance mutex, AUMID toasts, popup menus, autostart, display-change re-placement, deterministic teardown |
| 8 | `code-concurrency/` | Background worker + GUI polling discipline (never touch widgets off-thread) |
| 9 | `code-persistence/` | `settings.ini`, credentials parsing, secret hygiene, file logging |
| 10 | `code-sync/` | Google Apps Script web-app contract (`docs/Code.gs`) |
| 11 | `flow-delivery/` | README/CHANGELOG conventions, GUI-free pytest tests, `tools/` probes, PyInstaller one-file packaging |
| 12 | `flow-levels/` | The four work commands: code edit, clean up, build, push (+ `push-minor` / `push-master`), version bumps |
| 13 | `skill-authoring/` | Governs this library: naming, frontmatter, rule registry, `check-skills.ps1` |

## Workflow commands

`flow-levels` sets *how much* work to do on a given request instead of *what* to do. It
is the only skill here that is triggered by a word you type: pick **one** command, and only
that command's steps run — never mixed, and never escalated by asking.

| Command | Typed | Steps, in order | Version | Never does |
|---|---|---|---|---|
| **code edit** *(default — nothing typed)* | `/edit` or `code edit` | **A** partial test | — | clean up, full test, docs, commit, push, build |
| **clean up** | `/cleanup` or `clean up` | **B** clean up, **C** full test | — | docs, commit, push, build |
| **build** | `/build` or `build`, alias `/dist` | **C** full test, **D** build | — | docs, commit, push, folder build |
| **push** | `/push` or `push` | **C** full test, **E** docs, **F** push | patch | build or package, force-push |
| **push-minor** | `/push-minor` | **C** full test, **E** docs, **F** push | minor | as `push` |
| **push-master** | `/push-master` | **C** full test, **E** docs, **F** push | major | as `push` |

`code edit` is what you get when no command word is typed. **One command per request**: cline
does only that command's steps. Moving on is never asked for — anything another command owns is
left undone and named in one line. The actions are **A** partial test, **B** clean up, **C**
full test, **D** build, **E** docs, **F** push.

Clear-cache set (action **B**, step 4): `__pycache__/`, `*.pyc`, `.pytest_cache/`,
`.mypy_cache/`, `build/`, `dist/`.

### Versioning

The library version lives in `VERSION` (single source of truth) and every release is recorded
in `CHANGELOG.md` (keep-a-changelog). The push commands bump one component:

| Command | Bump | Example |
|---|---|---|
| `push` | patch | 1.0.0 → 1.0.1 |
| `push-minor` | minor | 1.0.1 → 1.1.0 |
| `push-master` | major | 1.1.0 → 2.0.0 |

Each release is tagged `vX.Y.Z` on its commit; there is one branch (`main`) and no release
branches. Pushes go **only** to the `benkingjo-ai` account: the push step checks the remote URL
first, and `skills/skill-authoring/scripts/pre-push` — installed as `.git/hooks/pre-push` by
`skills/bootstrap.ps1` (or `install-hook.ps1` directly) — refuses any other remote, including a
manual `git push`.

## How to use

### Available in every project (recommended)

Install the folders once into Cline's global skill roots and they load automatically in
any folder you open, with no per-project setup:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "<Access Lib>\tools\install-skills.ps1"
```

The script locates the repository itself (no path to edit) and junctions all 13 skills
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
selector) to confirm all 13 skills are listed and enabled.

### On this machine

- `link-cline-skills.bat` (next to this README) creates the `~/.cline\skills` junction
  onto this `skills\` folder, backing up anything already there.
- `skills\bootstrap.ps1` finishes setup: it **verifies** that junction (it never creates
  it), **activates the tracked `.githooks/` hooks** (`core.hooksPath`): `pre-commit` runs the
  skills audit and blocks a dirty commit, `pre-push` refuses any remote but `benkingjo-ai`;
  runs `skills\check.bat`, and prints the Cline settings you still have to set by hand.

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

### Triggering a workflow command

| You type | Result |
|---|---|
| nothing | `code edit` — the scoped fix, affected tests only (**A**) |
| `/cleanup` or `clean up` | profile, optimise, dead-code sweep, cache clear, full tests (**B**, **C**) |
| `/build` or `build` (`/dist`) | full tests then the one-file exe — no docs, commit or push (**C**, **D**) |
| `/push` or `push` | full tests, docs, **patch** bump, then commit + push (**C**, **E**, **F**) |
| `/push-minor` | the same, bumping the **minor** version |
| `/push-master` | the same, bumping the **major** version |

The slash form is deterministic; the bare word relies on the trigger phrases folded into
the skill's `description`, so check the Skills tab if a bare word ever fails to fire.
