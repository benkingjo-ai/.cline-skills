# Where does this go?

Decide by how often the text is read, then by length.

| If the text is... | Put it in | Why | Example |
|---|---|---|---|
| always needed, and only a few lines | a global Cline rule | read on every task, so keep it tiny | `rules/skills-governance.md` (14 lines) |
| a situational procedure | a skill's SKILL.md | read only when that skill triggers | the `flow-levels` commit step table |
| long, and shared by several skills | the owner skill's `docs\` file | on-demand; read only when something needs it | `skill-authoring\docs\naming.md` |
| secret or confidential | never in the skills folder | skills are global and may be shared | an API token - keep it in `%APPDATA%` |

Rules of thumb:

- Always-on text is the most expensive thing in the library. A rule that is not needed on most
  tasks does not belong in a global rule.
- If you would write "see the `<owner>` skill", the detail belongs in that owner.
- If two skills need the same block and it is over about 200 tokens, move it to the owner's
  `docs\` file and leave a one-line pointer in both.
- Never let a task need three or more extra reads to finish.

## Worked example

"The tray badge is 0.75 of the frame."

- Always needed on every task? No - so not a global rule.
- Needed whenever trays are built? Yes - so it goes in a SKILL.md (currently `ui-assets`).
- Longer than a line or two, and shared? Not yet - if the tray geometry grows past roughly
  200 tokens, move it to `ui-assets\docs\tray-geometry.md` and leave one pointer line in
  `ui-assets` and `win-shell`.