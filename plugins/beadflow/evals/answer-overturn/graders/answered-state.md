---
type: llm
focus: { source: file, path: state.jsonl }
---

The file is a bd export, one JSON issue per line. PASS only if all of these
hold:

- Both `human`-labelled decision issues are closed with `close_reason`
  `Responded`. The mood one has a comment choosing bands only; the fog
  one has a comment choosing that fog stays until a tile is scouted. Each
  comment states the choice in words, not just a letter.
- The `t-mood` epic has status `open`.
- A new open task has a `parent-child` dependency on `t-mood`, and its
  `acceptance_criteria` describe moving mood to bands only (no 0-100
  integer).
- `t-fog.1` is open and its only remaining `blocks` dependency points at
  a closed issue.

FAIL if any of these is missing or wrong.
