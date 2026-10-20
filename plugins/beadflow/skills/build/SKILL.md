---
name: build
description: Implements a beads task or epic end to end: claims it, hands it to a fresh implementer subagent in its own worktree, verifies the result against the bead's acceptance criteria, commits with the bead trailer, merges, and closes the bead. Use whenever the user asks to build, implement, do, or work a bead by ID, or says "build the next one".
disable-model-invocation: true
argument-hint: <bead-id | next | all> [--all]
---

# Build

Implement one bead, or an epic's children in order. You coordinate and gate;
a subagent does the editing. Invoking this skill is the user's authority to
claim, commit, merge, and close the beads it touches. It never pushes.

Target: $ARGUMENTS

`next` means the first task in `bd ready --exclude-type=epic`. An epic ID
means its open children in dependency order, pausing after each with a
three-line report unless `--all` is given. Skip children that `bd blocked`
lists; name them in the final report. `all` means the parent epic of
that first ready task, run with `--all`: the whole next epic, no pauses.
Name the epic and its open child count before starting, since the user may
be on a phone and won't see progress until the end.

## Why this shape

The expensive version of this work is a coordinator that reads the design
docs into its own context and then edits code itself, carrying every file it
touched for the rest of the session. The cheap version is a thin coordinator
and a fresh implementer per bead. The implementer gets a self-contained brief,
works in a worktree so nothing else in the checkout can interfere, and reports
in a fixed shape you can verify without reading the whole diff.

## Per bead

### 1. Claim and brief

```bash
bd update <id> --claim
bd show <id>
bd show <parent-epic-id>
```

Read only the bead, its epic, and the design file the epic names. Not the
codebase. Write the brief from those; the implementer reads code itself. The
epic's notes hold what earlier beads landed and the decisions they proposed.

If writing the brief forces a design call the bead and docs don't settle,
make it only if it's cheap to reverse, put it in the brief, and record it in
step 6. Otherwise it's an open question (step 5).

### 2. Decide: seam or not

A seam is code other code builds against, where a mistake propagates instead
of staying local. No list stays current, so judge it from the bead and its
epic. It's seam work when any of these hold:

- `bd show` lists beads that depend on it
- the epic says it adds or changes a public type in the sim library, a file
  format, a signal, or anything another system consumes
- its acceptance criteria have no automated check, so nothing else will
  catch a mistake
- it is likely to exceed about 300 changed lines

If the project keeps an architecture doc, it may name the seams known so
far; treat those as examples, not the definition. When unsure, treat it as a seam: a wrong skip
ships a bug into something others build on; a wrong review costs tokens.

Seam work gets Opus and a code review. Everything else gets Sonnet, and
tests plus the acceptance check are the review. `/ideate` writes beads with
contracts and checkable acceptance, which is the spec Sonnet executes well,
at about a fifth of the cost.

### 3. Spawn the implementer

One `Agent` call, `subagent_type: general-purpose`, `isolation: worktree`,
`model: opus` for seam work and `model: sonnet` otherwise. The brief is the
whole prompt; the subagent has no other context. Tell it to run
`git merge --ff-only main` first, because a worktree can branch from a
stale commit:

```
You are implementing one beads task in this project.

Bead <id>: <title>
Acceptance criteria (every line must hold):
<acceptance, verbatim>

Epic <parent-id> description:
<epic description, verbatim>

Design doc for this system: <path>. Read it before you start. Read
CLAUDE.md for conventions. Read code only as the task needs.

Project conventions (every line holds; reviews caught each one twice):
<the Conventions & Patterns section of CLAUDE.md, verbatim; omit if empty>

Rules:
- Work only in the worktree you were given. Don't run bd, git commit, or
  git push; the coordinator does those.
- If the task needs a design decision the docs and bead don't settle, stop
  and put the question in your report under "Open questions" with the
  options and what you'd pick. Don't guess. A smaller call you had to make
  anyway (a default, a cap, a data layout) goes under "Decisions made".
- Don't widen scope. Anything you notice that's out of scope goes under
  "Noticed" in the report.

Report in exactly this shape, nothing else:
## Files changed
<path>: <one line>
## Commands run
<command> → <pass/fail, one line of evidence>
## Acceptance
<each criterion> → <met/not met, the test that fails if it breaks>
## Decisions made
<the call> → <why>
## Open questions
## Noticed
```

### 4. Verify

Don't trust the report. In the worktree:

- run the build and test commands from CLAUDE.md yourself; paste the final
  pass/fail line and any failing lines, not the full log
- `git diff --stat`, then read only the files an acceptance line depends on
- check each acceptance criterion against what you ran, not what the report
  said. Each line needs a test that would fail if the behaviour broke; a
  line with none goes back to the implementer
- where a test pins seeded or golden output, confirm the change runs inside
  what it pins: the pinned length reaches the change, and the scripted run
  takes the action that triggers it. A pin that never reaches the change
  passes whatever the change does

If review was decided in step 2, run `/code-review medium` on the worktree
branch now. Send its findings, and any acceptance failures, back to the same
subagent with `SendMessage`; it already holds the code in context. A fresh
subagent would re-read everything.

When a finding is the same kind as one an earlier review caught (this run, or
a `review:` entry in the epic's notes), add a one-line rule for it to
`## Conventions & Patterns` in CLAUDE.md, creating the section if it's
missing. It lands with this bead. Only rules caught twice go in, so the list
stays short enough to brief in full.

### 5. Open questions

If the report has an open question, file it as a human bead per CLAUDE.md,
block the task on it, leave the worktree in place, and stop. Report the
question to the user in one paragraph. Don't pick an answer.

### 6. Record decisions

Every design call beyond the bead and docs, from the brief or the report's
"Decisions made", goes to one of two places before the bead lands:

- **The decisions log**, if it clears the bar in `docs/design/README.md`.
  Add `proposed: <line>` to the epic note in step 7. The lines are applied at
  the end of the run.
- **A human decision bead**, if the user should own the call. Per CLAUDE.md
  it doesn't block anything when the call is already in the code; the user
  can overturn it later.

Anything else is detail the code or the acceptance criteria already pin down.

### 7. Land it

One commit per bead, carrying the code and the closed bead together:

```bash
bd close <id> --suggest-next
bd update <epic-id> --append-notes "<id>: <subject>; <test result>; review: <finding kinds>; proposed: <line>"
bd export -o <worktree>/.beads/issues.jsonl
git -C <worktree> add -A && git -C <worktree> commit -m "<subject>

<body if needed>

Bead: <id>"
git diff --quiet <branch> -- .beads/issues.jsonl && git restore --staged --worktree .beads/issues.jsonl
git merge --ff-only <branch>
git worktree remove <worktree> && git branch -d <branch>
```

Drop empty parts of the note. `bd` in a worktree uses the main checkout's
database, and its hooks export to the main checkout's `issues.jsonl`. So the
export goes into the worktree by path, and the main checkout's identical copy
is discarded before the fast-forward. If the two copies differ, beads changed
in between: re-export into the worktree and amend before merging.

If the fast-forward fails because main moved, rebase the branch and re-run
the tests before merging; on a conflict in `issues.jsonl`, take a fresh
export rather than merging the lines. Don't force anything. If the bead
can't land, `bd reopen <id>`.

### 8. Report

Three lines: what landed (commit, files), what was verified (commands and
results), what's next (`bd ready`). For an epic without `--all`, wait for the
user before the next child.

When the run ends, collect the `proposed:` lines from the epic's notes that
`docs/design/decisions.md` doesn't hold yet, and show them as a diff to it,
following its README. Apply and commit them on approval, subject "Record
decisions from <epic>".

## Fan-out

Run beads in parallel only when `bd ready` lists several with no dependency
between them and the bead text names disjoint files. One worktree each,
merged in the order they finish, tests re-run on main after the last merge.
