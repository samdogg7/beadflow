---
type: llm
focus: { source: file, path: state.jsonl }
---

The file is a bd export, one JSON issue per line. PASS only if all of these
hold:

- `t-mood` is an epic with status `open`, no `assignee`, no
  `needs-ideation` label, `spec_id` `docs/design/mood.md`, and a
  description that summarises the mood design (0-100 value, daily decay
  and recovery, three bands, HUD).
- `t-mood.1` has `issue_type` `spike`; `t-mood.2` and `t-mood.3` are tasks.
- Each of the three children has a non-empty `acceptance_criteria` field,
  a `parent-child` dependency on `t-mood`, and no `needs-ideation` label.
- `t-mood.2` has a `blocks` dependency on `t-mood.1`, and `t-mood.3` has a
  `blocks` dependency on `t-mood.2`.

FAIL if any of these is missing or wrong, or if there are issues other
than these four.
