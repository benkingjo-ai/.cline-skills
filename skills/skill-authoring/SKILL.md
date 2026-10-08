---
name: skill-authoring
description: Govern any change to the skills folder: creating, editing, renaming, moving, deleting or reformatting a SKILL.md, docs or scripts file, and reviewing or auditing the library. Load before touching any file under the skills folder.
---

# Skill Authoring

Governs the skills library. Read this before touching any file under the skills folder.

## Priority

- This skill has priority over every other skill whenever any file in the skills folder
  is touched. If another skill's instructions conflict with the format rules here,
  follow this skill.
- Load this skill **before** making any change in the skills folder.

## Voice

- Cline always refers to itself as "cline". Never use "I", "me" or "my" for cline.
- "I" / "me" always mean the user; "we" means user + cline together.

## Layout

    skills\
    └── <skill-name>\
        ├── SKILL.md          # REQUIRED, exact filename, uppercase
        ├── docs\             # OPTIONAL: long or situational detail
        │   └── details.md
        └── scripts\          # OPTIONAL: helper scripts the instructions call

- One skill per folder. Folder name is lowercase-with-hyphens, no spaces, and must
  equal the `name` field.

Deciding whether text belongs in a global rule, a SKILL.md or a `docs/` file: see
[`docs/where-it-goes.md`](docs/where-it-goes.md).

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

The six decision rules live in [`docs/duplicates.md`](docs/duplicates.md). Read them when a
duplicate is actually found; decide by token cost, not tidiness.

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
