---
name: next
description: Shows what to do next on this project in one screen, then does it: it stops for questions agents flagged for a human only when one blocks work and nothing is ready to build; otherwise it continues straight into building the ready tasks or ideating the next roadmap stub. Use when the user asks what's next, what's waiting on them, or where things stand, especially at the start of a session or from a phone. Pass "show" to only report.
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

1. `bd human list` — questions agents couldn't answer. If any, `bd blocked`
   shows which tasks each one blocks; a question it doesn't list blocks
   nothing.
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
  proj-3na.4  Should mood use a fixed 0-100 scale or named bands?  (blocks proj-3na.2.3)
  proj-3na.7  Should fog lift at dawn or stay until scouted?  (blocks nothing)

Ready to ideate
  proj-3na.1  Sim library skeleton and seeded day loop  (docs/design/architecture.md)
  → /beadflow:ideate next

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

1. **Ready to build is non-empty.** Read `../build/SKILL.md` relative to this
   skill's base directory and follow it with the argument `all`: the parent
   epic of the first ready task, every open child, no pauses. Standalone
   tasks with no epic count as one batch. Invoking `next` is the user's
   authority for everything that skill does. Waiting questions don't hold
   this up: a task they block isn't ready, and build skips it.
2. **A waiting question blocks a task.** Read `../answer/SKILL.md`
   relative to this skill's base directory and follow it. Answering is
   what unblocks the next build. When it finishes, take the first case that
   applies again.
3. **Ready to ideate is non-empty.** Read `../ideate/SKILL.md` relative to
   this skill's base directory and follow it with `next` as the seed, so it
   claims the stub before another session can pick it.
   It's an interview, so it waits on the user at each question rather than
   running through to a filed epic.
4. **Nothing is ready.** Stop after the report.

Build before ideate, because ready tasks mean an epic is already half built
and finishing it unblocks more than a new design does. Build and ideate
carry `disable-model-invocation`, which is why they're read and followed
here rather than invoked.
