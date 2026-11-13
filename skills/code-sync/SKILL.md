---
name: code-sync
description: Use ONLY when integrating a Google Apps Script (Code.gs) backend: /exec contract, constant-time token check, script lock, one row per setting, timeout and retry. When adding cloud sync or cross-machine settings.
---

# Sync Backend

Used by **CAMonitor** and **GlobalX** — the same method, the same `docs/Code.gs`.

## Shape

```
client  ──POST {token, values}──►  deployed Apps Script web app (/exec)
                                    │  constant-time token check
                                    │  script lock around the write
                                    ▼
                                 Google Sheet
                              one row per setting
```

- **Deployed web app URL only** — a `/dev` or Library link is rejected; the validator
  matches `^https://script.google.com/(a/macros/[^/]+/s/|macros/s/)[A-Za-z0-9_-]{10,}/exec$`.
- Token checked in **constant time**; `setup()` mints it once.
- **Merge rule: last write wins per setting** — a PC that only moved one slider cannot
  undo a watchlist edit made elsewhere.
- Reads and writes happen on the background worker; the GUI never blocks (see
  `code-concurrency`).

## Client side

| Piece | Rule |
|---|---|
| `settings.ini` | holds `sync_url`, `sync_token`, `user` in `%APPDATA%` |
| Credentials | parsed by the credentials parser owned by the `code-persistence` skill; recognised fields include `$url`, `$token`, `$api`, `$user` |
| **Login** panel | the panel protocol owned by the `ui-dialogs` skill. `Load` the file → validate all-or-nothing → test connection → report field **names** → auto-close after `LOGIN_CLOSE_S` (owned by the `ui-dialogs` skill) |
| HTTP calls | every `Code.gs` request uses `requests.post(..., timeout=(5, 15))`, bounded retry/backoff |
| | (3 tries, 1/2/4 s); transient drops are retried, never swallowed |
| Offline | without credentials nothing is fetched and nothing is announced |
| Errors | one toast per outage and one per recovery; a second failure inside the same outage only reaches the log |

## Contract notes (worth recording in `docs/`)

- Ship `docs/Code.gs` in the repo — the exact script to paste into a live sheet.
- Document the transport version (e.g. *contract v3*) and the columns it uses.
- The transport never stores secrets in the repo or logs them; percentages / counters are
  not secrets, tokens are.
