# skills-governance

Before creating, editing, renaming, moving or deleting any file in
`C:\Users\<USERNAME>\.cline\skills\` (including through the OneDrive folder it links to),
use the `skill-authoring` skill first and follow it.

- Never modify, delete or overwrite an existing skill without showing me the planned
  change and getting my approval.
- After every change in that folder, run `check-skills.ps1` and report the result.
- Do not call the work complete until the Completion gate in `skill-authoring` passes.
- If the `skill-authoring` skill is missing or skills are disabled, stop and tell me
  instead of continuing.

The format, frontmatter, layout and conflict rules live in `skill-authoring`; do not repeat them.