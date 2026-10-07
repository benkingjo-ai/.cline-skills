# Keep or merge duplicates

Loaded from `SKILL.md` only when a duplicate is actually found, so authoring does not pay
for it on every change. Decide by token cost, not tidiness, and state which rule applied.

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
