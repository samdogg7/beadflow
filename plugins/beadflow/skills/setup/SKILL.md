---
name: setup
description: Finishes setting up beadflow in a project after install.sh: proposes the Build & Test commands for CLAUDE.md from what the repo contains, writes docs/design/ files with status lines from an existing design document, the codebase, or both, and files roadmap stubs as readable-ID epics. Use once per project, right after installing the plugin, or when a project has the plugin but empty docs.
disable-model-invocation: true
argument-hint: [path or URL of an existing design doc, optional]
---

# Setup

Turn a freshly installed project into one `/beadflow:next` can drive. Three
steps, each proposed in chat and written only after approval. Ask one question
at a time; the user may be on a phone.

## Asking

Ask with `AskUserQuestion`; its picker notifies the phone of a user who is
away from the keyboard, and its built-in "Other" field takes typed answers.

- **Approvals:** post the proposal as a message (it's too long for a
  picker), then ask with "Approve" (Recommended) and "Revise". Revisions
  come through "Other". Silence doesn't count as approval.
- **Choices:** a short header, your default first with "(Recommended)" on its
  label, and a description per option. The picker takes 2 to 4 options.
- **Open-ended questions** (a path, a URL, a pasted document) go as a
  message, since there are no options to pick from.

If the tool isn't available, ask every question as a message.

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

If `$ARGUMENTS` is empty, ask where the design lives with a picker: "File or URL",
"Pasted document", or "Nothing yet". The first two follow with a message asking
for the path or text.

Then take the path that fits. Step 1 already showed whether the repo holds
source code beyond config and scaffolding.

### No code, no document

Write `docs/design/overview.md` from a short interview (what it is, three to
five pillars, the first milestone) and stop this step.

### No code, a document

Read it whole, then propose a split into one file per system, listing each
file's name and the headings it takes. Keep the author's words; don't
rewrite. Each file starts with `Status: design, not built.` Pull anything
phrased as a settled decision with a reason into `decisions.md` as numbered
lines dated today, and anything phrased as a question into its
open-questions list. Add a `roadmap.md` if the document has a list of
milestones. Show the file index for the README's table. Write after
approval.

### Code, with or without a document

The code is the record of what exists, so map it first. A document, if
there is one, is checked against the map; it may be years behind.

1. **Map the systems.** Read the directory layout, entry points, scene or
   module boundaries, public interfaces, and test names. Don't read every
   file; in a large repo, hand the sweep to an `Explore` agent and keep only
   its map. A system is a part other code builds against or a player would
   name: "combat", "save system", "world generation".
2. **Place the document.** Read it whole and sort each section against the
   map: *built* (the code does this), *drifted* (the code does it
   differently), or *not built* (no code for it yet).
3. **Propose the files**, one per system, each with its status line and the
   code paths it covers:
   - `Status: shipped.` for a built system. Following the README, the file
     holds only what the code can't say: the contracts other systems rely
     on, the decisions that explain why, and pointers to the code. Don't
     describe what the code does.
   - `Status: building.` for a system that's partly there. Shipped parts as
     above; the unbuilt parts keep the document's words.
   - `Status: design, not built.` for a section with no code. The
     document's words, unchanged.
4. **List the drift** in the proposal: one line per difference, doc's
   version against the code's. The code's version stands by default. Each
   one the user wants back the doc's way becomes an open question in
   `decisions.md`, so `/ideate` takes it up.
5. **Decisions.** From the document, settled decisions with a reason, as
   above, unless the code overturned them. From the code, only choices that
   clear the README's bar, such as the engine, the save format, or a
   simulation model. Take the reason from a README, a comment, or a commit
   message; with none, write `reason not recorded` so the user can supply
   it at approval. Never invent a reason.
6. **Roadmap.** Milestones from the document, dropping what's built. With no
   document, or none left, ask what the next milestone is.

Show the file index for the README's table and the drift list with the
proposal. Write after approval.

## 3. Roadmap stubs

Skip if any open epic carries the `needs-ideation` label.

From `roadmap.md` (or the interview), propose the first milestone's epics: a
two- or three-word slug, a title, and the design file each builds from.
Milestones beyond the next stay as lines in `roadmap.md`. After approval, file
each as `bd create --id <prefix>-<slug> --type=epic --labels=needs-ideation
--spec-id <design file>` with a one-line description of its scope, and a milestone epic as the
parent if the roadmap has milestones. Add dependencies between stubs only where
one plainly can't start before another.

## 4. Commit

Commit `CLAUDE.md`, `docs/design/` and `.beads/issues.jsonl` (run
`bd export -o .beads/issues.jsonl` first if no hook does it) with the
subject "Set up beadflow". Don't push. End with the one line
`/beadflow:next` prints first: what to do now.
