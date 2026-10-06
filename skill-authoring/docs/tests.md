# Trigger tests

Test corpus for the 15 skill trigger descriptions. For each skill: **three requests that
should trigger it** and **two that must not**. At least one "must not" per skill is a
near-miss aimed at a sibling skill's vocabulary, to catch descriptions that are too broad.

Judge a request by its skill's `description` alone: that is the only text Cline reads
before deciding whether to load a skill.

Verdicts below were judged against the descriptions in force when this file was written:

- `ok` - the description clearly triggers, or clearly does not
- `RISK` - the description would plausibly misfire; keep an eye on it
- `MISS` - the description provably misfires as written

| verdict | count |
|---|---|
| ok | 65 |
| RISK | 9 |
| MISS | 1 |

## app-identity

| # | request | expected | near-miss of | verdict |
|---|---|---|---|---|
| 1 | Start a new app called Nimbus and create its config.py | trigger | | ok |
| 2 | Where should the log file and settings live for this app? | trigger | | ok |
| 3 | Set the version to 2.1.0 in one place | trigger | | ok |
| 4 | Lay out the folders and modules for a new project | no | app-structure | ok |
| 5 | Add a tray icon with three states | no | win-shell | ok |

## app-structure

| # | request | expected | near-miss of | verdict |
|---|---|---|---|---|
| 1 | Scaffold a new desktop app project | trigger | | ok |
| 2 | Which module should own the settings? | trigger | | ok |
| 3 | What should the entry point file be called? | trigger | | ok |
| 4 | How should the README and CHANGELOG be written? | no | flow-delivery | RISK (desc says where docs/ go) |
| 5 | Add a background worker for the network call | no | code-concurrency | ok |

## code-concurrency

| # | request | expected | near-miss of | verdict |
|---|---|---|---|---|
| 1 | The connection test freezes the UI, move it off the GUI thread | trigger | | ok |
| 2 | Add a background refresh that does not block the window | trigger | | ok |
| 3 | How do I stop the spinner safely when the window closes? | trigger | | ok |
| 4 | Save the sync token into settings.ini | no | code-persistence | ok |
| 5 | Set up the Apps Script web app endpoint | no | code-sync | ok |

## code-persistence

| # | request | expected | near-miss of | verdict |
|---|---|---|---|---|
| 1 | Write a rotating log file that never crashes the app | trigger | | ok |
| 2 | Parse the credentials file the user wrote, with url and token lines | trigger | | ok |
| 3 | Make sure the API key never appears in the log | trigger | | ok |
| 4 | Upload the settings to a shared Google Sheet | no | code-sync | ok |
| 5 | Add a Login panel with a Load then Close button | no | ui-dialogs | ok |

## code-sync

| # | request | expected | near-miss of | verdict |
|---|---|---|---|---|
| 1 | Add cloud sync through a Google Sheet | trigger | | ok |
| 2 | Deploy the Apps Script web app and guard it with a token | trigger | | ok |
| 3 | Keep the settings the same across two machines | trigger | | ok |
| 4 | Store the sync token locally under APPDATA | no | code-persistence | ok |
| 5 | Add a Login panel that registers url and token | no | ui-dialogs | MISS (desc claims the client Login panel) |

## flow-baseline

| # | request | expected | near-miss of | verdict |
|---|---|---|---|---|
| 1 | Fix the null check in the parser | trigger | | RISK (default level may not fire unprompted) |
| 2 | Rename this variable and update the callers | trigger | | RISK (same) |
| 3 | Use the normal level for this change | trigger | | ok |
| 4 | commit | no | flow-commit | ok |
| 5 | Run the full suite, update the changelog, then commit | no | flow-commit | ok |

## flow-commit

| # | request | expected | near-miss of | verdict |
|---|---|---|---|---|
| 1 | commit | trigger | | ok |
| 2 | commit this and update the changelog | trigger | | ok |
| 3 | Wrap up the work and commit it | trigger | | ok |
| 4 | release | no | flow-release | ok |
| 5 | optimize | no | flow-optimize | ok |

## flow-delivery

| # | request | expected | near-miss of | verdict |
|---|---|---|---|---|
| 1 | Write the CHANGELOG entry for this version | trigger | | ok |
| 2 | Add pytest tests for the parser | trigger | | ok |
| 3 | Build the one-file exe with PyInstaller | trigger | | ok |
| 4 | Where should the docs folder sit in the project? | no | app-structure | RISK (desc covers docs/ contents) |
| 5 | Where does the app keep its settings.ini? | no | code-persistence | ok |

## flow-optimize

| # | request | expected | near-miss of | verdict |
|---|---|---|---|---|
| 1 | Optimize this loop, it is slow | trigger | | ok |
| 2 | Do a cleanup pass on this module | trigger | | ok |
| 3 | Speed up the refresh, no docs and no commit | trigger | | ok |
| 4 | Commit the cleanup | no | flow-commit | RISK (desc says cleanup pass) |
| 5 | Profile it and then produce a release build | no | flow-release | ok |

## flow-release

| # | request | expected | near-miss of | verdict |
|---|---|---|---|---|
| 1 | release | trigger | | ok |
| 2 | /release 1.4.2 | trigger | | ok |
| 3 | Build the distributable for a release | trigger | | RISK (flow-delivery also claims exe builds) |
| 4 | commit | no | flow-commit | ok |
| 5 | Optimize the caching, no build | no | flow-optimize | ok |

## skill-authoring

| # | request | expected | near-miss of | verdict |
|---|---|---|---|---|
| 1 | Add a new skill for handling PDFs | trigger | | ok |
| 2 | Rename the ui-assets skill | trigger | | ok |
| 3 | Audit my skills library | trigger | | ok |
| 4 | Add a system tray icon with states | no | win-shell | ok |
| 5 | Write pytest tests for the parser | no | flow-delivery | ok |

## ui-assets

| # | request | expected | near-miss of | verdict |
|---|---|---|---|---|
| 1 | Draw the red ✕ close button | trigger | | ok |
| 2 | Bake the refresh spinner frames | trigger | | ok |
| 3 | Which Unicode glyph means verified? | trigger | | ok |
| 4 | What is the accent colour token? | no | ui-layout-theme | ok |
| 5 | Show a toast when the sync fails | no | win-shell | ok |

## ui-dialogs

| # | request | expected | near-miss of | verdict |
|---|---|---|---|---|
| 1 | Add a settings dialog with a header and a close button | trigger | | RISK (ui-assets also claims close button) |
| 2 | Build the login panel that loads a credentials file | trigger | | ok |
| 3 | Auto-hide the panel after 30 seconds | trigger | | ok |
| 4 | Parse a credentials file with url = value lines | no | code-persistence | ok |
| 5 | Cancel the timer when the window is destroyed | no | code-concurrency | ok |

## ui-layout-theme

| # | request | expected | near-miss of | verdict |
|---|---|---|---|---|
| 1 | What colour should the panel background be? | trigger | | ok |
| 2 | Create theme.py with the house palette and fonts | trigger | | ok |
| 3 | What padding should rows use? | trigger | | ok |
| 4 | Implement a dialog that closes on Esc | no | ui-dialogs | RISK (desc says styling a dialog) |
| 5 | Make the tray icon 22 px | no | win-shell | ok |

## win-shell

| # | request | expected | near-miss of | verdict |
|---|---|---|---|---|
| 1 | Add a system tray icon with idle, busy and error states | trigger | | ok |
| 2 | Register Alt+Q as a global hotkey | trigger | | ok |
| 3 | Start the app automatically at logon | trigger | | ok |
| 4 | Draw the tray icon artwork and badge | no | ui-assets | RISK (both claim tray icons) |
| 5 | Create the folder layout for a new project | no | app-structure | ok |

## Notes

- MISS: `code-sync` claims "the client's Login panel that registers url/token/user", which
  request 5 for `code-sync` deliberately aims at `ui-dialogs`. Both descriptions will fire.
- RISK rows are over-broad descriptions, not broken ones. Each is a candidate for rule 6
  (shorten the description) in Phase 6.
- Re-judge this file after every description change in Phase 6, and revert any change that
  turns an `ok` into a `RISK` or `MISS`.