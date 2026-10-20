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

## Prerequisites

- [Claude Code](https://code.claude.com/docs) on your PATH as `claude`.
- [beads](https://github.com/gastownhall/beads#readme) on your PATH as `bd`.
  The skills drive it for every bit of task tracking; install it and run
  `bd init --prefix <short-prefix>` in the project first.

## Install

From the project's root:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/samdogg7/beadflow/main/install.sh)
```

Or from a clone: `/path/to/beadflow/install.sh [project-dir]`.

The script registers the marketplace, installs the plugin at project scope
(so `.claude/settings.json` carries it for anyone who clones the project),
appends the beadflow sections to `CLAUDE.md`, and seeds `docs/design/` with
the README and an empty `decisions.md`. It never overwrites a file that
exists; re-running is safe.

Afterwards:

1. Fill in the Build & Test commands in `CLAUDE.md`.
2. Write one `docs/design/<system>.md` per system, each with a status line.
3. File roadmap stubs as epics with readable IDs
   (`bd create --id <prefix>-<slug> --type=epic --labels=needs-ideation`).

Run `/beadflow:next`.

By hand, the install is two commands:

```bash
claude plugin marketplace add samdogg7/beadflow   # or a local clone's path
claude plugin install beadflow@samdogg7 --scope project
```

## Conventions the skills rely on

- `bd` with `human`-labelled decision beads, `needs-ideation` on stubs,
  `--acceptance` on tasks, readable epic IDs via `--id`.
- Commits carry `Bead: <id>`, one bead per commit.
- Design docs in `docs/design/` with a status line per file and a numbered
  `decisions.md`.
- A Build & Test section in `CLAUDE.md` with exact commands.
