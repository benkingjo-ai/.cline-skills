# Rule registry

Every shared rule, its single owner, where it lives, and who points at it. One owner per
rule. A rule with two owners is a defect; a rule with none is unmanaged.

The `rule` cell is a literal anchor that `scripts/check-skills.ps1` verifies still exists in
the owner file. Keep it verbatim. `file` is relative to the owner skill folder.

<!-- registry:start -->
| rule (literal anchor) | owner | file | referenced by |
|---|---|---|---|
| `MUTEX_NAME` | app-identity | SKILL.md | win-shell |
| `APP_VERSION` | app-identity | SKILL.md | flow-levels, flow-delivery |
| `%APPDATA%` | app-identity | SKILL.md | code-persistence, code-sync, ui-assets |
| `resource_path()` | app-identity | SKILL.md | ui-assets |
| `Colour tokens` | ui-layout-theme | SKILL.md | ui-assets, win-shell, ui-dialogs, ui-tray-animation |
| `Fonts` | ui-layout-theme | SKILL.md | - |
| `Layout metrics` | ui-layout-theme | SKILL.md | ui-assets, ui-dialogs |
| `Tray icons` | ui-assets | SKILL.md | win-shell, ui-tray-animation |
| `Refresh spinner` | ui-assets | SKILL.md | - |
| `Symbols` | ui-assets | SKILL.md | - |
| `The dialog shell` | ui-dialogs | SKILL.md | - |
| `The Login panel protocol` | ui-dialogs | SKILL.md | code-sync |
| `Auto-hide` | ui-dialogs | SKILL.md | win-shell |
| `LOGIN_CLOSE_S` | ui-dialogs | SKILL.md | ui-layout-theme, code-sync |
| `thread/poll/timer rules` | code-concurrency | SKILL.md | ui-dialogs, code-sync |
| `Spinner while in flight` | code-concurrency | SKILL.md | - |
| `Credentials file parser` | code-persistence | SKILL.md | code-sync, ui-dialogs |
| `Secret hygiene` | code-persistence | SKILL.md | ui-dialogs, code-sync |
| `The four levels` | flow-levels | SKILL.md | - |
| `Clear cache set` | flow-levels | SKILL.md | - |
| `Package (lowercase = app name)` | app-structure | SKILL.md | flow-delivery |
| `Documentation` | flow-delivery | SKILL.md | app-structure, win-shell |
| `Testing` | flow-delivery | SKILL.md | win-shell |
| `PyInstaller` | flow-delivery | SKILL.md | flow-levels |
| `Naming convention` | skill-authoring | SKILL.md | all skills |
| `Completion gate` | skill-authoring | SKILL.md | all skills |
| `State colours` | win-shell | SKILL.md | ui-assets, ui-tray-animation |
| `Autostart` | win-shell | SKILL.md | app-identity |
| `One-file only` | flow-delivery | SKILL.md | flow-levels, app-structure |
| `Refused filenames` | code-persistence | SKILL.md | win-shell |
| `POPUP_MIN_WIDTH` | ui-layout-theme | SKILL.md | ui-dialogs, win-shell |
| `Display change` | win-shell | SKILL.md | ui-layout-theme, ui-dialogs |
<!-- registry:end -->

## Flags

All resolved in the owner pass:

| rule | now owned by | was |
|---|---|---|
| Login panel | `ui-dialogs` | `code-sync` claimed it in its description, so one request fired both skills - the MISS in tests.md. The claim was removed. |
| Tray state vocabulary and colours | `win-shell` (states), `ui-layout-theme` (values) | three-way: `ui-assets` and `win-shell` both described the states. `ui-assets` now points at both instead of defining them. |
| Refresh glyph size | `ui-layout-theme` (button boxes), `ui-assets` (glyph) | no owner. The relationship (`BAR_ICON_PX` 22 gives a 19 px glyph) is now stated in `ui-layout-theme`. |

No rule in this registry is currently unowned, and none has two owners.