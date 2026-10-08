# Trigger tests

Test corpus for the 13 skill trigger descriptions. For each skill: **three requests that
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
| ok | 58 |
| RISK | 7 |
| MISS | 0 |

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
| 5 | Add a Login panel that registers url and token | no | ui-dialogs | ok (Phase 6 removed the claim) |

## flow-delivery

| # | request | expected | near-miss of | verdict |
|---|---|---|---|---|
| 1 | Write the CHANGELOG entry for this version | trigger | | ok |
| 2 | Add pytest tests for the parser | trigger | | ok |
| 3 | Build the one-file exe with PyInstaller | trigger | | ok |
| 4 | Where should the docs folder sit in the project? | no | app-structure | RISK (desc covers docs/ contents) |
| 5 | Where does the app keep its settings.ini? | no | code-persistence | ok |

## flow-levels

| # | request | expected | near-miss of | verdict |
|---|---|---|---|---|
| 1 | Fix the null check in the parser, no command named | trigger | | RISK (default command may not fire unprompted) |
| 2 | push | trigger | | ok |
| 3 | Clean up this loop, it is slow | trigger | | ok |
| 4 | Write the CHANGELOG entry for this version | no | flow-delivery | ok |
| 5 | Build the one-file exe with PyInstaller | no | flow-delivery | RISK (build is a flow-levels command word too) |

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
| 4 | Implement a dialog that closes on Esc | no | ui-dialogs | ok (Phase 6 dropped the word dialog) |
| 5 | Make the tray icon 22 px | no | win-shell | ok |

## ui-tray-animation

| # | request | expected | near-miss of | verdict |
|---|---|---|---|---|
| 1 | Make the tray icon spin while the upload runs | trigger | | ok |
| 2 | Animate a macOS menu-bar icon while syncing | trigger | | ok |
| 3 | Keep the tray icon spinning during a long refresh | trigger | | ok |
| 4 | Add a system tray icon with idle, busy and error states | no | win-shell | RISK (win-shell owns the state vocabulary) |
| 5 | Draw the tray icon artwork and badge | no | ui-assets | RISK (both describe the badge) |

## win-shell

| # | request | expected | near-miss of | verdict |
|---|---|---|---|---|
| 1 | Add a system tray icon with idle, busy and error states | trigger | | ok |
| 2 | Register Alt+Q as a global hotkey | trigger | | ok |
| 3 | Start the app automatically at logon | trigger | | ok |
| 4 | Draw the tray icon artwork and badge | no | ui-assets | RISK (both claim tray icons) |
| 5 | Create the folder layout for a new project | no | app-structure | ok |

## Notes

- No MISS remains. `code-sync` used to claim the client's Login panel, so request 5 fired
  both it and `ui-dialogs`; the Phase 6 rewrite removed that claim.
- The `win-av-behaviour` rows left with the skill; its rules now live inline in the skills
  whose behaviour they justify - `win-shell` (hotkey, autostart), `flow-delivery` (packaging)
  and `code-persistence` (refused filenames).
- The remaining RISK rows are inherent to the subject matter - docs/CHANGELOG ownership,
  tray artwork versus tray behaviour, tray states versus tray animation, the default command
  firing unprompted, and `build` being a `flow-levels` command word as well as `flow-delivery`
  vocabulary - and are not fixable by rewording.
- Re-judged after the levels-to-commands rewrite (`/edit`, `/cleanup`, `/build`, `/push`): the
  packaging probe is a RISK now, because `build` is a command word too.
- Re-judge this file after every description change, and revert any change that turns an
  `ok` into a `RISK` or `MISS`.