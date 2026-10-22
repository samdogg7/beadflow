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

Ask with `AskUserQuestion`. Its picker works on a phone, and its built-in
"Other" field takes a typed answer.

- **Blocking questions:** one per call, recorded before the next. Each
  reply can let a parked build resume, so it shouldn't wait on the rest.
- **Questions that block nothing:** up to four per call, since the picker
  takes four. The code already runs each agent's pick, so nothing waits on
  them, and a batch saves the user round trips.

```
AskUserQuestion
  header:   "Mood scale"
  question: "Should mood use a fixed 0-100 scale or named bands?
             (proj-3na.4, blocks proj-3na.2.3 Add mood decay)"
  options:
    - label: "0-100, bands as thresholds (Recommended)"
      description: "Decay subtracts from an integer; bands are ranges on it."
    - label: "Bands only"
      description: "Decay steps between content, uneasy, angry; no number."
```

- **Question:** the bead's question, then its ID and what it blocks. For a
  question that blocks nothing, name what the code does now instead
  (`in code: 0-100, from proj-3na.2.1`).
- **Options:** the options from the bead, the agent's pick first with
  "(Recommended)" on its label. Labels stay short; each description says
  what choosing it means in practice. The picker takes 2 to 4 options. If
  the bead has more, offer the four likeliest and name the rest in the
  question. If it offers only one, add the obvious alternative, so the
  picker has two.
- **Context:** if the choice needs more than the descriptions carry, send
  the two or three lines that bear on it as a message just before the call.
  The bead holds the rest.
- **Typed replies:** "Other" is where free text, "skip", and "dismiss"
  go. "skip" leaves the question open; "dismiss" means it no longer applies.

If a reply is ambiguous or contradicts an earlier answer, say so and ask
again. If `AskUserQuestion` isn't available in this session, ask the same
thing as a message with lettered options and take a letter, "yes" for the
recommended option, or free text.

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
criteria for the new behavior. Check `bd create --help` first. If the epic
is closed, `bd reopen` it after filing: build closes an epic with its last
child, and a closed epic with an open child drops out of `/beadflow:next`.
Filing first means the epic is never open with no work left in it. Build
closes it again once the fix lands. A build running that epic picks
the task up between beads.

## 4. Report

One line per question: ID, the answer in a few words, and what it
unblocked or filed. Then `bd ready`, so the user sees what can build now.
