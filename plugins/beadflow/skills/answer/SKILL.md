---
name: answer
description: Walks through the questions agents filed for a human (bd human list) one at a time and records each reply, so blocked tasks become ready. Use when the user wants to answer, review, or clear waiting questions, including while a build runs in another session.
argument-hint: [bead-id]
---

# Answer

Put each waiting question to the user, one at a time, and record the reply
in bd. A build running in another session picks up the tasks this unblocks
between beads, so the user can answer mid-run, often from a phone.

Argument: $ARGUMENTS

A bead ID means that question only. Otherwise, every open one.

## Standing rules

- **bd is the only thing you change.** Don't edit project files, and don't
  run git. A build may be landing commits in this checkout right now.
- **The user's reply is the authority** for the writes it implies: closing
  the question and, when a reply overturns a decision already in the code,
  filing the fix task. Don't ask again before making them.
- **Never answer for the user.** "Whatever you think" is a reply; record the
  agent's pick and say that's what was chosen. Silence or a new topic isn't.

## 1. Gather

```bash
bd human list
bd blocked
```

`bd show` each question. A question blocks work when `bd blocked` lists a
task waiting on it. Order blocking questions first, then the rest; within
each group, oldest first.

If there are none, say so in one line and stop. Otherwise say in one line
how many there are and how many block work.

## 2. Ask

One question per message:

```
proj-3na.4 · blocks proj-3na.2.3 (Add mood decay)
Should mood use a fixed 0-100 scale or named bands?

Decay needs a number to subtract from; the design doc names bands
(content, uneasy, angry) but no scale under them.

  a) 0-100 integer, bands as thresholds   ← agent's pick
  b) bands only, decay steps between them
```

For a question that blocks nothing, replace the "blocks" part with what
the code does now: `in code: a` and the task that landed it.

Keep the context to the two or three lines that bear on the choice; the
bead holds the rest. Take a letter, "yes" for the agent's pick, or free
text. If a reply is ambiguous or contradicts an earlier answer, say so and
ask again. "skip" leaves the question open; "dismiss" means it no longer
applies.

## 3. Record

```bash
bd human respond <id> -r "<the reply>"
bd human dismiss <id> "<why>"   # on "dismiss"
```

Write the reply so an implementer who reads only it can act: the chosen
option in full, not a letter, plus any condition the user added.

When the question blocked nothing and the reply overturns what the code
does now, the code is wrong until someone changes it. File a task for that
under the same epic as the task that made the call, with acceptance
criteria for the new behavior. Check `bd create --help` first. A build
running that epic picks it up between beads.

## 4. Report

One line per question: ID, the answer in a few words, and what it
unblocked or filed. Then `bd ready`, so the user sees what can build now.
