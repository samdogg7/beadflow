---
name: next
description: Shows what to do next on this project in one screen: questions agents flagged for a human, the next roadmap stub to ideate, tasks ready to build, and work in progress. Use when the user asks what's next, what's waiting on them, or where things stand, especially at the start of a session or from a phone.
argument-hint:
---

# Next

Answer "what should I do now?" in one screen. Read-only: run only `bd` list
and show commands, never create, update, or close anything, and don't touch
project files. The user may be on a phone, so keep it short and skip anything
empty.

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
