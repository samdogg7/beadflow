---
name: next
description: Shows what to do next on this project in one screen, then does it: questions agents flagged for a human stop here; otherwise it continues straight into building the ready tasks or ideating the next roadmap stub. Use when the user asks what's next, what's waiting on them, or where things stand, especially at the start of a session or from a phone. Pass "show" to only report.
argument-hint: [show]
---

# Next

Answer "what should I do now?" in one screen, then do it unless a human has
to decide first. The report step is read-only: run only `bd` list and show
commands, never create, update, or close anything, and don't touch project
files. The user may be on a phone, so keep it short and skip anything empty.

Argument: `show` prints the report and stops. With no argument, the report is
followed by the handoff in "Then continue".

Run these, in this order:

1. `bd human list` — questions agents couldn't answer. These come first because
   an agent is blocked on each one.
2. `bd list --label=needs-ideation --status=open` — roadmap stubs not yet
   designed. Pick the first one that `bd ready` also lists; that's the next
   `/ideate` run. Show its ID, title, and the design file its description names.
3. `bd ready --exclude-label=needs-ideation --exclude-type=epic` — tasks
   ready to build. Epics are containers, not work, so they're excluded.
4. `bd list --status=in_progress` — what's already being worked.

## Output

Four short sections, headings only for sections with content:

```
Waiting on you
  proj-3na.4  Should mood use a fixed 0-100 scale or named bands?

Ready to ideate
  proj-3na.1  Sim library skeleton and seeded day loop  (docs/design/architecture.md)
  → /ideate proj-3na.1

Ready to build
  proj-3na.1.2  Add seeded PRNG stream per system

In progress
  proj-3na.1.1  Create Sim class library and console runner
```

End with one line naming the single thing you'd do first and why. If
everything is empty, say the project has no open work and suggest the next
item from the roadmap doc, if the project keeps one.

## Then continue

Skip this section when the argument is `show`. Otherwise, after the report,
take the first case that applies and say in one line which one:

1. **Waiting on you is non-empty.** Stop. Those questions block agents, and
   only the user can answer them (`bd human respond`).
2. **Ready to build is non-empty.** Read `../build/SKILL.md` relative to this
   skill's base directory and follow it with the argument `all`: the parent
   epic of the first ready task, every open child, no pauses. Standalone
   tasks with no epic count as one batch. Invoking `next` is the user's
   authority for everything that skill does.
3. **Ready to ideate is non-empty.** Read `../ideate/SKILL.md` relative to
   this skill's base directory and follow it with the stub's ID as the seed.
   It's an interview, so it ends at the first question, not at a filed epic.
4. **Nothing is ready.** Stop after the report.

Build before ideate, because ready tasks mean an epic is already half built
and finishing it unblocks more than a new design does. The sibling skills
carry `disable-model-invocation`, which is why they're read and followed
here rather than invoked.
