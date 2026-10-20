## Decisions you can't make

When a task needs a design decision the docs and the bead don't settle, don't
guess. File the question as a bead with the `human` label, block the task on
it, and move to other work:

```bash
bd create --title="Decision: <the question>" --labels=human --type=decision \
  -d "<context, the options, and what you'd pick if forced>"
bd dep add <task-id> <question-id>
```

The user reviews these with `/beadflow:next` (`bd human list`), often from a
phone, and answers with `bd human respond`.

## Commits

End every commit that does work for a bead with a trailer naming it, so
`git log --grep` can trace a change back to its task and epic:

```
Add stamina drain to sprint

Bead: <prefix>-stamina-sprint.2
```

One bead per commit. If a change serves none, say why in the body instead.

## Build & Test

Run these from the repo root. `/beadflow:build` runs them to verify every
bead before landing it, so keep them exact.

```bash
# build
# test
# any smoke check, and how to read its result
```

## Architecture Overview

Design docs live in `docs/design/`, one file per system. Read
`docs/design/README.md` first: it says what belongs in a doc versus a bead and
how `/beadflow:ideate` turns one into the other.
