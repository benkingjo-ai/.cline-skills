---
name: code-persistence
description: Store settings, credentials and logs: a rotating %APPDATA% logger that never raises, merged settings.ini, a tolerant credentials parser, secret hygiene (names, never values). Use when persisting config, reading secrets or handling API keys.
---

# Persistence & Logging

> Ownership: the credentials parser (sect. 3) and secret hygiene (sect. 4) are defined here; `ui-dialogs` and `code-sync` link back. Data placement (`%APPDATA%\<APP_ID>`, never the program folder) is owned by the `app-identity` skill.

## 1. Logger (`logger.py`)

```python
def log(*args):
    try:
        line = (" ".join(str(a) for a in args)) + "\n"
        _rotate_if_needed()
        with open(LOG_FILE, "a", encoding="utf-8") as f:
            f.write(line)
    except Exception:
        pass                     # a log that cannot be written must never stop the app
```

| Property | Rule |
|---|---|
| Location | `%APPDATA%\<APP_ID>\<app>.log`, else the first folder that accepts it (section 5) |
| Format | timestamped — `[%Y-%m-%d %H:%M:%S] msg` (or a leading stamp) |
| Cap | `LOG_MAX_BYTES` (256 KB or 512 KB) |
| Rotation | rotate **before** a line would pass the cap → `log.1` (only two files kept) |
| Cost | check size every N messages, not every line |
| Run bracketing | `announce_start()` (names build + frozen/exe), `announce_stop()` |
| Failures | best-effort: **never raise** |

Log with `[SECTION] message` tags (`[LOGIN]`, `[SETTINGS]`, `[POPUP]`, `[HOOK]`, `[APPID]`).

## 2. `settings.ini`

- `%APPDATA%\<APP_ID>\settings.ini` — **never** in the program folder (OneDrive) - see the `app-identity` skill.
- `configparser`, one section (e.g. `[sync]`); read legacy sections if the app was
  rebranded, but only ever write your own.
- `save()` **merges** — keys the caller didn't mention are preserved.
- `get()` falls back to environment variables (`APP_URL`, `APP_TOKEN`, `API_KEY` …).
- `describe()` returns **which** fields are set — names only.
- Validators: `valid_url()` (deployed `/exec` web-app URL only), `valid_token()`,
  `valid_api()`, `valid_user()` (one `@`, a domain with a `.`).

## 3. Credentials file parser (`credentials.py`)

Accept whatever the user wrote down — **read only, never move/change/copy**:

- `$url = "…"`, `name = value`, `name: value`, optional `export`, any capitalisation,
  single/double quotes, `#` or `//` comments skipped.
- Canonical fields + aliases: `url`, `token`, `api`, `user`
  (aliases: `sync_url`, `webapp_url`, `endpoint`, `secret`, `api_key`, `email`,
  `account`, `username`, …).
- File discovery: first `<App>.*` in the usual folders, else the first `.txt` that really
  holds credentials; cap the scan (`TXT_SCAN_MAX = 50`).
- **All or nothing** — a bad value refuses the whole file; nothing is written.

## 4. Secret hygiene (non-negotiable)

1. Never show or log a secret **value** — only the field **names** that were registered.
2. `SECRET_PATTERNS` (Apps Script deployment id `AKfycb…`, `sk-`/`cline-` API keys, JWT,
   `ya29.` OAuth, long hex) + `looks_like_placeholder()` keep specs' samples out of the way.
3. Reuse them in `tests/test_secrets.py` (nothing in the repo may match) and
   `tools/release_check.py` (nothing inside the built exe may match).
4. Plain-text storage is an accepted, documented level of protection — say so in the
   settings docstring.

## 5. Refused filenames

Measured on a managed endpoint: `%APPDATA%\<APP_ID>\settings.ini` and the log
beside it were refused, `[Errno 13] Permission denied` on create and `[WinError 5]`
on `os.replace`, while `plain.ini`, `plain.log` and `x.txt` in that same folder
wrote normally - and so did the same two filenames in `%LOCALAPPDATA%` and `%TEMP%`.
The veto was on the app’s **own filenames in one folder**, not on the extension and
not on the folder’s permissions.

- Ask each folder in turn (`%APPDATA%`, then `%LOCALAPPDATA%`, then `%TEMP%`) and
  write to the first that accepts the file; read the newest copy that exists, so a
  leftover file in an earlier folder cannot shadow the live one.
- Write to the file that was read first, then the rest of the list: a read path and
  a write path that disagree make a saved setting look lost.
- Keep the same filename and format - a sanctioned per-user location, not a rename -
  and report which file is in use (`--debug`, or the panel that failed).
- Record the failure reason (the path plus the system’s own words) and show it.  A log
  that cannot be written must never leave the app silent about why.
