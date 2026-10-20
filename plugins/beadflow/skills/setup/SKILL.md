---
name: setup
description: Finishes setting up beadflow in a project after install.sh: proposes the Build & Test commands for CLAUDE.md from what the repo contains, splits an existing design document into docs/design/ files with status lines, and files roadmap stubs as readable-ID epics. Use once per project, right after installing the plugin, or when a project has the plugin but empty docs.
disable-model-invocation: true
argument-hint: [path or URL of an existing design doc, optional]
---

# Setup

Turn a freshly installed project into one `/beadflow:next` can drive. Three
steps, each proposed in chat and written only after approval. Ask one question
at a time; the user may be on a phone.

Design doc source: $ARGUMENTS

## Standing rules

- Write only `CLAUDE.md`, files under `docs/design/`, and beads. Nothing else.
- Don't run `bd prime` if beads context is already in the session.
- Check `bd create --help` before filing; don't assume flags.
- Skip any step whose result already exists, and say so in one line.

## 1. Build & Test

Find how the project builds and tests: `package.json` scripts, a solution or
project file, `Makefile`, `Cargo.toml`, `pyproject.toml`, a `project.godot`
plus a C# project, CI config under `.github/workflows`. Run the candidate
commands to confirm they work, and note what a passing result looks like.

Propose the `Build & Test` block for `CLAUDE.md` as a fenced snippet: one
build command, one test command, and any smoke check with how to read its
result (an output line to look for, not an exit code, if the exit code lies).
Write it into the section `install.sh` left in `CLAUDE.md` after approval.

## 2. Design docs

Skip if `docs/design/` already holds more than `README.md` and
`decisions.md`.

Ask where the design lives if `$ARGUMENTS` is empty: a file, a URL, a pasted
document, or nothing yet. With nothing, write `docs/design/overview.md` from a
short interview (what it is, three to five pillars, the first milestone) and
stop this step.

With a document: read it whole, then propose a split into one file per
system, listing each file's name and the headings it takes. Keep the
author's words; don't rewrite. Each file starts with
`Status: design, not built.` Pull anything phrased as a settled decision
with a reason into `decisions.md` as numbered lines dated today, and
anything phrased as a question into its open-questions list. Add a
`roadmap.md` if the document has a list of milestones. Show the
file index for the README's table. Write after approval.

## 3. Roadmap stubs

Skip if any open epic carries the `needs-ideation` label.

From `roadmap.md` (or the interview), propose the first milestone's epics: a
two- or three-word slug, a title, and the design file each builds from.
Milestones beyond the next stay as lines in `roadmap.md`. After approval, file
each as `bd create --id <prefix>-<slug> --type=epic --labels=needs-ideation`
with a one-line description naming the design file, and a milestone epic as the
parent if the roadmap has milestones. Add dependencies between stubs only where
one plainly can't start before another.

## 4. Commit

Commit `CLAUDE.md`, `docs/design/` and `.beads/issues.jsonl` (run
`bd export -o .beads/issues.jsonl` first if no hook does it) with the
subject "Set up beadflow". Don't push. End with the one line
`/beadflow:next` prints first: what to do now.
