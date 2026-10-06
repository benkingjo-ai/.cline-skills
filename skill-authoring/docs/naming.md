# Naming convention

Format: `<category>-<topic>`, lowercase, hyphens only, no spaces, 2 to 4 words, and the
folder name must equal the `name` field.

The topic must say what the skill is for. Single generic words are not allowed as names on
their own: the trigger words I type belong in `description`, not in the name.

One skill covers one topic. A name that needs "and", or that joins three topics, is a
signal to split, but only split when each part is large enough or is used separately, and
weigh the extra always-on description.

## Approved prefixes

`scripts/check-skills.ps1` reads this list. Add one prefix per bullet, backticked, at the
start of the bullet.

<!-- prefixes:start -->
- `app-` application identity, structure, packaging
- `ui-` layout, theme, dialogs, icons and assets
- `code-` concurrency, persistence, logging, backend sync, performance
- `win-` Windows and shell specifics
- `flow-` workflows such as commit, release, testing, optimize
- `skill-` skills about skills (only `skill-authoring`)
<!-- prefixes:end -->

To add a prefix, edit only the list above.