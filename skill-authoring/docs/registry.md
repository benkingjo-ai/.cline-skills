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
| `Colour tokens` | ui-layout-theme | SKILL.md | ui-assets, win-shell, ui-dialogs |
| `Fonts` | ui-layout-theme | SKILL.md | - |
| `Layout metrics` | ui-layout-theme | SKILL.md | ui-assets, ui-dialogs |
| `Tray icons` | ui-assets | SKILL.md | win-shell |
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
| `State colours` | win-shell | SKILL.md | ui-assets |
| `Autostart` | win-shell | SKILL.md | app-identity |
<!-- registry:end -->

## Flags - two owners

| rule | owners | problem |
|---|---|---|
| Login panel | `ui-dialogs` (owner) and `code-sync`, whose description claims "the client's Login panel that registers url/token/user" | one request fires both - this is the MISS recorded in tests.md |
| Tray state vocabulary and colours | `ui-assets` describes the states, `win-shell` describes the states, `ui-layout-theme` owns the values | three-way; only `ui-layout-theme` may define colour values |

## Flags - no owner

| rule | problem |
|---|---|
| Refresh glyph size | `ui-layout-theme` lists `REFRESH_BTN` 12 px, while `ui-assets` derives 19 px from `BAR_ICON_PX 22 x 0.85`. No file owns the relationship between the two numbers. |