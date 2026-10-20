# beadflow

A design-to-code loop for projects that track work in [beads](https://github.com/gastownhall/beads)
(`bd`). Three skills, one coordinator, fresh implementers.

```
/beadflow:next      what's waiting on you, next stub to ideate, ready to build, in progress
      │
      ▼
/beadflow:ideate    interview → confirmed design → epic + child tasks in bd → decisions log
      │
      ▼
/beadflow:build     per bead: claim → fresh implementer in a worktree → verify → review → land → close
```

## Why this shape

- **Docs hold the why, beads hold the what.** A design doc per system plus a
  numbered, append-only `decisions.md`. Beads carry tasks for the next rung
  or two with checkable acceptance criteria. `templates/design-README.md` is
  the convention.
- **One question at a time.** `/ideate` interviews with a default on every
  question, so a one-word reply from a phone moves it on.
- **Thin coordinator, fresh implementer.** `/build` never edits code. It
  writes a self-contained brief, spawns an implementer in its own worktree,
  verifies by running the build and tests itself, and lands the commit with a
  `Bead:` trailer.
- **Seam or not.** Work other code builds against gets a stronger model and a
  code review; everything else gets a cheaper model with tests as the review.
  Judged per bead by property, not by a list.
- **Humans decide.** An implementer that hits a design question files a
  `human`-labelled bead and moves on. `/next` surfaces them first.

## Install

```bash
claude plugin marketplace add /path/to/beadflow
claude plugin install beadflow@samdogg7 --scope project
```

Then, in the project:

1. Append `plugins/beadflow/templates/CLAUDE-snippet.md` to `CLAUDE.md` and
   fill in the Build & Test commands.
2. Create `docs/design/` with `plugins/beadflow/templates/design-README.md`
   as its `README.md`, one file per system, and a `decisions.md`.
3. File roadmap stubs as epics with readable IDs
   (`bd create --id <prefix>-<slug> --type=epic --labels=needs-ideation`).

Run `/beadflow:next`.

## Conventions the skills rely on

- `bd` with `human`-labelled decision beads, `needs-ideation` on stubs,
  `--acceptance` on tasks, readable epic IDs via `--id`.
- Commits carry `Bead: <id>`, one bead per commit.
- Design docs in `docs/design/` with a status line per file and a numbered
  `decisions.md`.
- A Build & Test section in `CLAUDE.md` with exact commands.
