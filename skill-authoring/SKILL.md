---
name: skill-authoring
description: Govern every change to the global Cline skills folder — creating, editing, renaming, moving, deleting or reformatting any SKILL.md, docs\ file, scripts\ file or skill folder, and reviewing, auditing or validating the skills library. Also use when writing a new skill, fixing frontmatter, splitting a long SKILL.md into docs\, or resolving conflicting or overlapping rules between skills. Always load this skill before touching anything under the skills folder.
---

# Skill Authoring

Governs the skills library. Read this before touching any file under the skills folder.

## Priority

- This skill has priority over every other skill whenever any file in the skills folder
  is touched. If another skill's instructions conflict with the format rules here,
  follow this skill.
- Load this skill **before** making any change in the skills folder.

## Layout

    skills\
    └── <skill-name>\
        ├── SKILL.md          # REQUIRED, exact filename, uppercase
        ├── docs\             # OPTIONAL: long or situational detail
        │   └── details.md
        └── scripts\          # OPTIONAL: helper scripts the instructions call

- One skill per folder. Folder name is lowercase-with-hyphens, no spaces, and must
  equal the `name` field.

## Naming convention

Every skill is named `<category>-<topic>`: lowercase, hyphens only, no spaces, 2 to 4
words, and the folder name must equal the `name` field. The topic must say what the skill
is for, so single generic words are not names.

The approved category prefixes live in [`docs/naming.md`](docs/naming.md). Read it before
naming anything; `scripts/check-skills.ps1` enforces the list.

## Creating a new skill

1. Pick the category and topic from [`docs/naming.md`](docs/naming.md) **before** writing
   anything. Reject a name that is a single generic word, joins three topics, or uses a
   prefix that is not on the approved list.
2. Create `skills\<category>-<topic>\SKILL.md` with the frontmatter above.
3. Write `description` first: WHAT it does, WHEN to use it, in the words I would type.
4. Put long or situational detail in `docs\`, helper scripts in `scripts\`.
5. Run [`scripts/check-skills.ps1`](scripts/check-skills.ps1) and satisfy the Completion
   gate.

## Frontmatter

- First line `---`, then `name:` and `description:`, then `---`.
- `name`: lowercase letters, digits and single hyphens; <=64 chars; equals the folder name.
- `description`: ONE line, <=1024 chars; says WHAT the skill does and WHEN to use it, in
  the words I would naturally type. Quote it if it contains a colon. A name whose topic is
  general needs a very specific description.
- UTF-8 **without BOM** — Cline requires `---` at byte 0; a BOM silently breaks parsing.
- Only Cline's keys: `name`, `description`, `license`, `compatibility`, `metadata`,
  `allowed-tools`.

## Content

- Keep SKILL.md under about 5,000 tokens, most important information first. Move long or
  situational detail to `docs\*.md` and link it with relative paths. Only link to files
  that exist.
- Imperative, unambiguous steps: concrete paths, commands, examples. No vague wording.
- One focused domain per skill. Split broad skills. Never duplicate content between
  skills, or between SKILL.md and `docs\`.
- No secrets or personal data. Write global skills in general terms; project-specific
  details do not belong in them.

## Conflicts and overlap

- **One rule, one owner.** When a rule (naming, path, colour, format, timing) appears in
  more than one skill with different values, name ONE owner skill and make the others
  refer to it.
- Where overlap is unavoidable, add a precedence note.
- Overlapping `description` triggers are a defect — narrow them so only one skill fires.

## Keep or merge duplicates

Cost model: `name` + `description` load on **every** task (always-on). SKILL.md loads only
when triggered (on-trigger). `docs\` and `scripts\` load only when the instructions need them
(on-demand). Estimate tokens as characters / 4. Decide by token cost, not tidiness.

When duplicates are found, apply these rules in order and state which rule applied:

1. **Same purpose** — merge into one skill. Keep the better `description` and combine only
   the unique content. This removes one always-on description.
2. **Shared rule used by many skills** — keep one owner. If the detail is over about 200
   tokens, put it in the owner's `docs\` file so it loads on demand. Other skills keep a
   one-line pointer ("follow the `<owner>` skill").
3. **Small rule (under about 50 tokens) in skills rarely loaded together** — a short copy in
   each is acceptable: a pointer would force a second load that costs more. Mark it
   `<!-- duplicate-ok: reason -->` and name the skill holding the master wording.
4. **Skills usually loaded together** — keep the content in one place only and use a pointer
   in the other, so it is not loaded twice in the same task.
5. **Large content only partly relevant** — split it: the always-needed part stays in
   SKILL.md, the situational part moves to `docs\`.
6. **Descriptions** — shorten to the minimum that still triggers correctly. Move explanation
   out of the description and into the body.

Do not split or move content so far that a task needs three or more extra reads to finish.
Balance fewer always-on tokens and fewer duplicate tokens against extra reads and lost clarity.

Report every duplicate as: locations | type (exact / near / intentional) | tokens wasted |
recommended owner | rule applied | proposed action | tokens saved. End with the total tokens
saved and the new always-on total. Never delete or merge without approval, and show a
before/after for each change.

## Completion gate

A skill change is **not** complete until all of these are done and reported:

1. Ran [`scripts/check-skills.ps1`](scripts/check-skills.ps1) and pasted its output; every
   skill shows `OK` (or the listed exceptions were approved).
2. The Token budget report shows no warnings, or I have approved the exceptions.
3. The `=== Naming ===` section reports no violations: every name is `<category>-<topic>`
   with an approved prefix, 2 to 4 words, and equals its folder.
4. Every remaining duplicate is marked intentional with a reason, or has a named owner and a
   rule applied to it.
5. The description-overlap section shows `none` for the changed skill, or the overlaps are
   explained.
6. Checked the changed rules against the other skills for conflicting values (naming, paths,
   colours, formats) and named one owner skill for each rule.
7. Confirmed every link to a `docs\` or `scripts\` file resolves, and SKILL.md is under
   about 5k tokens.
8. Gave a short change summary (what changed, which files) and the audit result.

If any item fails, fix it and re-run the audit. Do not report the task as done until the
gate passes.
