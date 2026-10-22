---
name: ideate
description: Shapes a rough feature idea, or with "next" the next ready roadmap stub, into a beads epic with child tasks through a short design interview. Use before any code is written for a new feature or system in a project tracked with bd.
disable-model-invocation: true
argument-hint: [rough feature idea | bead-id | next]
---

# Ideate

Turn a rough feature idea into a reviewed beads epic with child tasks. This is a
design conversation first and a filing step second. You never implement anything.

Seed idea: $ARGUMENTS

If the seed idea is empty, ask what the user wants to build and stop there.

If the seed is `next`, pick the stub the same way `/beadflow:next` does: the
first `bd list --label=needs-ideation --status=open` stub that `bd ready` also
lists. Claim it with `bd update <id> --claim` before reading anything else.
Another session may be building or ideating in this repo, and the claim moves
the stub out of `--status=open`, so no other picker takes it. If the claim
fails, someone else got there first; try the next ready stub. Then continue
with its ID as the seed.
If no stub is ready, list the open stubs with what blocks each one and stop.
Don't ideate a blocked stub: its design rests on work that hasn't landed.

If the seed is a bead ID, it's a stub epic filed from the roadmap. Run
`bd show <id>`, read the design file on its `Spec:` line (older stubs name
it in the description), and run the interview on that scope. Before step 1, tell the user what they're designing: the epic's title
and ID, then one or two plain sentences on what it builds, drawn from the
stub and the design file. The user may have picked it with `next` and not
know which stub came up. In step 5, fill that epic (update its description
to the confirmed design summary and drop its `needs-ideation` label) instead
of creating a new one, and file the children under it. If the stub's ID is a hash suffix
(`proj-3na.4`) and it has no children yet, rename it to a readable slug
first (`bd rename <id> <prefix>-<slug>`); rename carries dependencies and
references but not children, so it's only safe before any are filed.

## Standing rules

These hold for the whole conversation, including after the epic is filed.

- **Read-only on the project**, except design docs in step 6 and the commit
  in step 7. Don't create, edit, or delete any other project file. Another
  agent may be working in this repo at the same time.
- **bd is the only thing you change**, and only after the user approves the
  breakdown in chat. Searching and listing beads is fine at any point. The
  one exception is the claim on a stub picked by `next`. If the user drops
  the interview, release it with `bd unclaim <id>` so the stub is pickable
  again.
- **Keep the claim alive.** A claim's lease lapses 5 minutes after the last
  `bd heartbeat`, and `/beadflow:next` reopens claims whose lease lapsed
  more than 2 hours ago. While you hold the claim, run `bd heartbeat <id>`
  each time the user replies; stop once step 5 releases it. If it fails, the stub was reopened while the user was away:
  claim it again. If that fails too, another session is designing it; tell
  the user and stop.
- **Don't run `bd prime` if beads context is already in the session.** Hooks
  usually inject it. Run it only if you can't see bd workflow context.
- **Don't assume bd flags.** Run `bd create --help` and `bd dep --help` before
  filing. Flag names and supported issue types vary between bd versions.
- **Ask one question at a time.** The user is often on a phone, and two
  questions get one answered and one forgotten. Each question should force a
  choice and carry your default, so a one-word reply moves things on. Push back
  on vague or contradictory answers, and say so when an answer conflicts with an
  existing bead.
- **Ask choices with `AskUserQuestion`.** One question per call: a short
  topic as the header, your default first with "(Recommended)" on its
  label, and a description per option saying what choosing it means. Its
  picker works on a phone, and its built-in "Other" field takes typed
  answers and pushback. It takes 2 to 4 options; a question without that
  many real ones goes as a message instead of a padded picker. If the
  tool isn't available, ask every question as a message.
- **Approve with a picker too.** The design summary, the breakdown, and the
  docs diff are too long for a picker, so post each as a message, then ask
  with two options: "Approve" (Recommended) and "Revise". Revisions come
  through "Other". "Approve", or a typed "looks good", counts as approval;
  silence or a new question doesn't.
- **Read the design doc, not the codebase.** If the project keeps design docs
  (CLAUDE.md says where), read the file for the system in question before the
  first question, and the decisions log if there is one. Don't skim code up
  front. Read a specific file only when a question depends on what already
  exists, such as whether a save system or a relevant autoload is in place.
  Check the project's own config files for what exists rather than asking
  the user.

## Flow

### 1. Check for overlap

Search open beads for anything related to the idea (`bd search`, `bd list
--status=open`). Mention matches in a line or two each: duplicate, dependency,
or conflict. Don't dwell on unrelated ones. Then list, in one line, the
interview areas that apply, so the user can see how long it will run.

When the seed is a stub, read its notes. Build appends a line there when
it lands a seam this stub consumes; design against that shape, and if the
design needs it changed, make the change a child task.

Also read the stub's siblings under the same parent. The most useful thing
the interview can settle is where this epic stops and the next one starts;
put that line in the summary so neither epic builds the other's half.

### 2. Interview

Scale depth to the idea. A small tweak gets two or three questions; a new system
gets the full pass. The checklist is in `references/interview.md`. Read it before
your first question. Some areas always apply; others have a "Skip when" test.

Before the first question, check the design doc's premises against the
milestone being built. A premise that rests on something a later milestone
adds (density stored per cell when cells come later) makes questions on it
hard to answer. Name the gap in the question that depends on it.

Prefer questions that force a choice ("Does dying drop the loot, or keep it?")
over open ones ("Any thoughts on death?"). When the user says "whatever's
standard", propose a concrete default and ask them to confirm it.

### 3. Confirm the design

Summarize the design in a few short paragraphs: what the player experiences, how
it works in the project's terms (which layer, which module), what's out of scope, and which decisions are still open.
If you skipped persistence, say "No save data" in one line so the user can catch
a wrong assumption.

Get explicit agreement before breaking it down, with the approval picker.
This summary becomes the epic
description, so write it for a coding agent who has never seen this
conversation.

If the seed was a stub with a readable slug and the interview moved its scope
so the slug no longer fits, propose a new slug in the same message and rename
on approval (`bd rename <id> <prefix>-<slug>`). Do it here, before any children
exist in step 5.

### 4. Propose the breakdown

Post an editable list in chat: the epic as one line (title, type, priority;
its description is the summary confirmed in step 3, so don't repeat it), then
each child task with

- title, type, priority
- one-line why, only when the title and acceptance criteria don't make the
  purpose obvious (spikes, tasks other tasks wait on). Build doesn't pass it
  to the implementer.
- acceptance criteria
- shared files it touches that another task also touches (a tuning file, a
  definitions file, golden test output)
- dependencies (by list position, since nothing has an ID yet)

Tasks that share a file can't be built in parallel, so give them a
dependency in the order they should land. When that makes tasks run one at a
time, say so in one line under the list, naming the shared file.

Mark spikes (questions to answer, not code to write) and playtest or tuning tasks
clearly. See `references/example-epic.md` for the shape. Revise until the user
approves through the approval picker.

### 5. File it

1. Check `bd create --help` and `bd dep --help`. If the seed is a stub,
   re-read its notes: build may have landed a seam it consumes during the
   interview. If one changes the breakdown, show the user the revised
   breakdown before filing.
2. Write the epic and its children as one graph plan, a JSON file in a
   temp directory outside the project (from `mktemp -d`):

   ```json
   {"nodes": [
     {"key": "epic", "id": "proj-stamina-sprint", "type": "epic",
      "title": "Stamina-limited sprint", "description": "<step 3 summary>",
      "spec_id": "docs/design/player.md"},
     {"key": "meter", "id": "proj-stamina-sprint.1", "parent_key": "epic",
      "type": "task", "priority": 2, "title": "Add Stamina node with drain and regen",
      "acceptance_criteria": "<one criterion per line>"},
     {"key": "gate", "id": "proj-stamina-sprint.2", "parent_key": "epic",
      "type": "task", "priority": 2, "title": "Gate sprint on stamina",
      "acceptance_criteria": "<...>"}
   ],
   "edges": [{"from_key": "gate", "to_key": "meter"}]}
   ```

   - **IDs:** pin every `id`. The epic gets a readable slug
     (`<prefix>-<slug>`, two or three words), and children number under it
     (`<epic-id>.1`), which reads better in commit trailers and `bd ready`
     than a hash. A plan without pinned IDs gives children flat hash IDs.
     Renaming later doesn't carry children, so settle the slug first.
   - **Fields:** `spec_id` is the design file, so build and next read it
     from a field instead of from prose. Acceptance criteria go in
     `acceptance_criteria`, not the description, so `bd show` and
     validation can find them. Spikes get `"type": "spike"`.
   - **Edges:** `from_key` waits on `to_key`. Parent links come from
     `parent_key`; don't repeat them as edges.
   - **Stubs:** leave out the epic node. Children use
     `"parent_id": "<stub-id>"` and pinned IDs `<stub-id>.1`, `<stub-id>.2`;
     without a pinned `id` they get hash IDs, parent or not.
3. Run `bd create --graph <file> --dry-run`, then without `--dry-run`. The
   plan files atomically: if it fails, nothing was created, so fix the plan
   and run it again.
4. For a stub, after the children are filed: set its description to the
   step 3 summary (`bd update <id> --body-file <file> --spec-id <design file>
   --remove-label needs-ideation`), then release the claim from `next` with
   `bd unclaim <id>`. It's an epic now, not work in progress, and
   `/beadflow:next` would otherwise list it as in progress until it closes.
5. Show the created IDs mapped to titles, then run `bd ready`.

If `bd create --help` has no `--graph`, file one bead at a time instead:
the epic with `--id` and `--spec-id`, then each child with `--parent`,
`--no-inherit-labels`, and `--acceptance`, then `bd dep add`. Leave `--id`
off the children; bd rejects it with `--parent`, and children number under
the epic on their own. Without `--no-inherit-labels`, children copy a
stub's `needs-ideation` label and never show as ready. Pass multi-line text
through a temp file outside the project, never inline. If a command fails
partway, stop and report what was created so far; a blind retry can file
duplicates.

### 6. Update the design docs

Skip this step if the project has no design docs.

The interview usually settles something the docs left open: a default
overturned, an open question answered, a contract between systems pinned down.
If that lands only in a bead, the doc is wrong the moment the bead closes.
Propose the edits as a diff: a decision with its reasoning added to the
decisions log, an open question removed, a status line changed. Follow the
log's own conventions (the design docs README describes them). Be sparing: a
decision earns a line only if an agent with the docs and the code in front of
them might still do it differently. A contract the code makes obvious, or a
detail the bead's acceptance criteria already pin down, is not a decision.
A decision usually fits one line; give it a detail file only when the
interview weighed alternatives or produced evidence that a future agent would
otherwise re-argue.
Apply the edits only after the user approves through the approval picker,
and only inside the design docs
directory. Re-read the decisions log just before writing and renumber your
entries if it gained any since you proposed them; `/build` appends to the
same log and may have landed lines during the interview. Don't rewrite the
design to match the epic; the epic already links to the doc.

### 7. Commit

Once the docs are applied (or skipped), commit the design docs and the beads
export together, trailer `Bead: <epic-id>`, subject "Ideate the <name> epic".
Stage those paths by name (`git add <design-docs-dir> .beads/issues.jsonl`),
never `git add -A` or `commit -a`, so nothing another agent left staged or
modified in the checkout ends up in this commit.
Don't push. This is the one git write the skill makes; approving the
breakdown is the authority for it, so don't ask again.

## Writing the beads

- **One task, one focused agent session.** Each should produce a diff someone
  can review in one sitting. Split anything bigger.
- **Checkable acceptance criteria.** Use automated checks where they exist: a
  test passes, a scene runs without errors or warnings. For feel and visuals,
  write a concrete manual playtest check ("Jump from the lowest ledge in
  `test_level.tscn` and land on the second platform without a run-up").
- **Stable identifiers only.** Name scenes, nodes, signals, autoloads, Resource
  types, and existing `res://` paths. No line numbers; they rot.
- **Behavior and contracts, not steps.** Say what the code must do and expose,
  not how to write it. The epic may wait weeks before anyone picks it up, and the
  code underneath will have moved.
- **Short, specific titles.** "Add stamina drain to sprint", not "Implement the
  feature".
- **The epic stands alone.** A coding agent reading only the epic must understand
  the feature, including what's out of scope and which decisions are open.
- **Link the design doc, don't repeat it.** Name the file and say what this
  epic builds from it. Repeated design text costs tokens on every read and goes
  stale when the doc changes.
