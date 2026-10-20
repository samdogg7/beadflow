# Design docs

These files describe why the game is the way it is. Beads describe what to do
next. Keep each where it belongs, or both go stale.

## Docs versus beads

| | Design docs | Beads |
| --- | --- | --- |
| Hold | Pillars, contracts between systems, decisions and their reasoning | Tasks for the next rung or two, acceptance criteria |
| Change | Slowly, when a decision changes | Daily; closed beads disappear from view |
| Cost | Read once per task, 500 to 1,500 tokens per file | Paid every time an agent runs `bd show` or `bd search` |

A bead that repeats the design costs tokens on every read and is wrong as soon
as the doc changes. A bead should link to the file and say what's different:
"see `people.md`; this epic builds skills and mood only".

Beads for work years out go stale as fast as docs do. File epics for the
current rung and the next one. Later rungs stay one-line entries in
`roadmap.md`.

## Keeping docs honest

1. **Docs describe the design, not the build.** Once a system ships, code and
   tests are the truth. Shrink its doc to the decisions and contracts that still
   explain why, or to a pointer. Do this when closing the epic.
2. **Every file starts with a status line:** `design, not built`, `building`, or
   `shipped`. It tells an agent how far to trust what follows.
3. **Tuning numbers and speculation stay out.** "About 30 landmarks" belongs in
   a bead or a data file. Numbers go stale first.

## Recording decisions

`decisions.md` is the index: one numbered line per decision, with its date and
the reason in a clause. That's the whole record for most decisions, and the
index stays cheap to read whole (about 20 tokens a line).

The bar for a line: an agent with the docs and the code in front of them might
still do it differently. Pillars, rejected alternatives, and contracts between
systems clear it. A detail the code makes obvious, or that a bead's acceptance
criteria already pin down, doesn't; it would only be re-stating the build.
Lines are never deleted, so the bar is applied at entry.

A decision gets a detail file in `decisions/NNNN-slug.md` only when the line
can't hold it: alternatives weighed, playtest evidence, or a tradeoff a future
agent might re-argue. If the reasoning is visible in the code or its tests, it
stays a line. Detail files use this shape so agents know where to look:

```markdown
# 0004 Leader death means succession, not game over

Date: 2026-10-17 · Status: accepted

## Context
## Decision
## Alternatives rejected
## Consequences
```

To change a decision, add a new numbered line that names what it supersedes,
and prepend `(superseded by #N)` to the old line. Never edit or delete the old
line; the index is also the history.

## How docs become beads

```
docs/design/<system>.md
        │  /ideate <idea>     reads the file, interviews, files an epic
        ▼
epic + child tasks in bd  ──▶  coding agents
        │
        ▼
decisions.md updated       (defaults overturned, open questions answered)
```

`/ideate` is the only path from a doc to an epic, and it's also how docs get
updated: a design conversation that settles a question edits `decisions.md`
with the user's approval.

Epics get readable IDs (`bd create --id <prefix>-<slug>`), and children
auto-number under them. Roadmap stubs filed by hand follow the same rule;
`bd rename` doesn't carry children, so the slug is chosen at creation.

## Files

| File | What's in it |
| --- | --- |
| `overview.md` | Pitch, pillars, structure, the day, the arc |
| `people.md` | Survivors and the leader |
| `settlement.md` | Holding landmarks, building, assignments, economy |
| `region.md` | Density, noise, hordes, fog of war, world generation, seasons |
| `events.md` | Event data model, resolvers, authoring |
| `factions.md` | AI settlements and inherited settlements |
| `presentation.md` | Camera, art, UI readability |
| `architecture.md` | Foundational commitments: sim library, determinism, components |
| `roadmap.md` | Scope ladder: the rungs and their order |
| `decisions.md` | Open questions, defaults taken, decisions and why |
