---
name: win-av-behaviour
description: Keep a Windows build out of endpoint-security quarantine - the behaviours Bitdefender ATC and Defender score, what to do instead, and how to verify or report a build. Use when a build is blocked, killed or flagged.
---

# Endpoint-Security Behaviour

A behaviour-scoring product (Bitdefender **Advanced Threat Control**, Microsoft
Defender, an EDR) does not read the source. It watches what the process does and
kills or quarantines on a **shape**: an unsigned program that changes persistence,
stages files in a temporary folder, reads another application’s data and posts it
somewhere, all within seconds, is an information-stealer whatever it was written
for. Removing the behaviour is the fix; hiding it is not (section 2).

## 1. Scored behaviours

| Behaviour | Why it scores | Do this instead |
|---|---|---|
| The app writes its own autostart entry on launch | persistence written by the payload instead of by an installer | user opt-in only, through one visible control (owner: `win-shell`, *Autostart*) |
| The build unpacks and executes its runtime from `%TEMP%` | staging native code out of a writable temporary folder is the dropper shape | the release stays **one-file only** (owner: `flow-delivery`, **One-file only**); remove the scored behaviours around it instead of changing the layout |
| The app copies its own file into `%APPDATA%` every launch | a dropper copying itself into the user profile | copy only when the build has no stable folder of its own, never when it has |
| A bare TCP connect that sends nothing, seconds before a request | reads as a beacon rather than as a reachability check | let the real request answer the question; an unreachable host fails inside the call |
| A low-level keyboard hook (`WH_KEYBOARD_LL`) | the classic keylogger signature | `RegisterHotKey` only, with a re-arm watchdog and a visible failure (owner: `win-shell`, **Global hotkey**) |
| The app silently cannot write its own log or settings | a program that refuses to be audited is treated as hostile | fall back to another per-user folder and say why (owner: `code-persistence`, **Refused filenames**) |
| An unsigned exe nobody ever reported | unknown code with no reputation | sign if possible, publish a hash, report the sample (section 5) |

Read the vendor documentation instead of guessing.  Bitdefender publishes which
practices cause these detections, and its report for a rejected program reads
"creates and launches a new file" in a randomly named temporary folder.

## 2. The line cline does not cross

- No packing, obfuscation, entry-point mutation, anti-debug or product-detection code.
- No sleeping past an inspection window, and no moving one behaviour into a helper
  process to break the chain.
- Never ask the user to disable the product, and never ask for a blanket `%TEMP%`
  exclusion: it weakens every other application on that machine.
- A case that cannot be fixed by removing a behaviour is fixed by reporting the
  sample (section 5), or by telling the user which behaviour is scored and why the
  app needs it.

## 3. Verify before shipping

| Question | Check |
|---|---|
| Is a removed dependency really gone from the one-file build? | `python -m PyInstaller.utils.cliutils.archive_viewer -l dist/App.exe` and search the listing |
| Is the release really a single file? | `dist/` holds the `.exe` only - no `_internal` folder and no `--onedir` output; a one-folder build exists only as a throwaway diagnostic |
| What does the hotkey path really do? | Process Monitor filtered to the process: expect `LoadImage` from the install folder, `RegSetValue` only on an explicit opt-in, `GetClipboardData`, then a `TCP Connect` to the API host |
| Can a vendor pin this exact build? | publish a SHA-256 per artifact, or a per-file manifest for a folder build |

## 4. When the machine refuses the app’s own files

A veto can be name-specific inside one folder: the app’s own filenames refused while
other names in the same folder write normally.  Probe before working around it -
create the exact filename in each candidate folder (`%APPDATA%`, `%LOCALAPPDATA%`,
`%TEMP%`) and record which step fails (create, `os.replace`, append).  Apply the
fallback rule owned by `code-persistence` (**Refused filenames**) and report the
refusal with the operating system’s own error text.

## 5. Reporting a false positive

1. Reproduce it, and capture the detection text and a screenshot.
2. Note the detection name, attach the SHA-256, and attach the behaviour list that
   explains the app: a page naming every registry key, file path and network
   destination the app touches is what makes a report reviewable.
3. Submit through the vendor’s false-positive or sample form, category *false positive*.
4. A **path-scoped** exclusion for the installed folder is a reasonable outcome once
   the vendor holds the sample.  A blanket temporary-folder exclusion is not, and it
   is never the first answer.
