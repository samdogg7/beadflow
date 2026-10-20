# beadflow

A design-to-code loop for projects that track work in [beads](https://github.com/gastownhall/beads)
(`bd`). Three skills, one coordinator, fresh implementers.

```
/beadflow:setup     once: Build & Test commands, design doc split, roadmap stubs
      │
      ▼
/beadflow:next      what's waiting on you, then straight into build or ideate (`show` to only report)
      │
      ▼
/beadflow:ideate    interview → confirmed design → epic + child tasks in bd → decisions log
      │
      ▼
/beadflow:build     per bead: claim → fresh implementer in a worktree → verify → review → land → close
```

## Why this shape

- **Docs hold the why, beads hold the what.** A design doc per system plus a
  numbered, append-only `decisions.md`. Beads carry tasks for the next milestone
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

Clone this repo, then from anywhere:

```bash
/path/to/beadflow/install.sh /path/to/project [bd-prefix]
```

The script registers the marketplace, installs the plugin at project scope
(so `.claude/settings.json` carries it for anyone who clones the project),
runs `bd init` if the project has no `.beads` folder, appends the beadflow
sections to `CLAUDE.md`, and seeds `docs/design/` with the README and an
empty `decisions.md`. It never overwrites a file that exists; re-running is
safe.

Then open Claude Code in the project and run:

```
/beadflow:setup [path or URL of an existing design doc]
```

It proposes the Build & Test commands from what the repo contains, splits
your design document into `docs/design/<system>.md` files, files the first
milestone's roadmap stubs as epics, and commits. Each step is shown before it's
written. After that, `/beadflow:next`.

## Conventions the skills rely on

- `bd` with `human`-labelled decision beads, `needs-ideation` on stubs,
  `--acceptance` on tasks, readable epic IDs via `--id`.
- Commits carry `Bead: <id>`, one bead per commit.
- Design docs in `docs/design/` with a status line per file and a numbered
  `decisions.md`.
- A Build & Test section in `CLAUDE.md` with exact commands.

## Metrics

```
scripts/metrics.py [--repo PATH] [--since YYYY-MM-DD]
```

Prints token usage per Claude Code session and subagent, by model, with the
beads whose `Bead:` commits landed during each. It reads the transcripts in
`~/.claude/projects`, so it needs no setup. A coordinator session that landed
several beads lists them all; its tokens aren't split between them.
