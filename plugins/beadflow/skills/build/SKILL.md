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
three-line report unless `--all` is given. `all` means the parent epic of
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
codebase. Write the brief from those; the implementer reads code itself.

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

Rules:
- Work only in the worktree you were given. Don't run bd, git commit, or
  git push; the coordinator does those.
- If the task needs a design decision the docs and bead don't settle, stop
  and put the question in your report under "Open questions" with the
  options and what you'd pick. Don't guess.
- Don't widen scope. Anything you notice that's out of scope goes under
  "Noticed" in the report.

Report in exactly this shape, nothing else:
## Files changed
<path>: <one line>
## Commands run
<command> → <pass/fail, one line of evidence>
## Acceptance
<each criterion> → <met/not met, evidence>
## Open questions
## Noticed
```

### 4. Verify

Don't trust the report. In the worktree:

- run the build and test commands from CLAUDE.md yourself; paste the result,
  not a summary
- `git diff --stat`, then read only the files an acceptance line depends on
- check each acceptance criterion against what you ran, not what the report
  said

If review was decided in step 2, run `/code-review medium` on the worktree
branch now. Send its findings, and any acceptance failures, back to the same
subagent with `SendMessage`; it already holds the code in context. A fresh
subagent would re-read everything.

### 5. Open questions

If the report has an open question, file it as a human bead per CLAUDE.md,
block the task on it, leave the worktree in place, and stop. Report the
question to the user in one paragraph. Don't pick an answer.

### 6. Land it

```bash
git -C <worktree> add -A && git -C <worktree> commit -m "<subject>

<body if needed>

Bead: <id>"
git merge --ff-only <branch>
git worktree remove <worktree> && git branch -d <branch>
bd close <id> --suggest-next
```

Include `.beads/issues.jsonl` in the commit if it changed. If the
fast-forward fails because main moved, rebase the branch and re-run the
tests before merging; don't force anything.

### 7. Report

Three lines: what landed (commit, files), what was verified (commands and
results), what's next (`bd ready`). For an epic without `--all`, wait for the
user before the next child.

## Fan-out

Run beads in parallel only when `bd ready` lists several with no dependency
between them and the bead text names disjoint files. One worktree each,
merged in the order they finish, tests re-run on main after the last merge.
