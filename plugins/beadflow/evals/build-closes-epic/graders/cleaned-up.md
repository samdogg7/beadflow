---
type: regex
pattern: '\n\S'
match: not_contains
target: { source: file, path: worktrees.txt }
---
