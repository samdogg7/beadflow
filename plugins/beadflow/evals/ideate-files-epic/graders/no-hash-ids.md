---
type: regex
pattern: '"id":"t-(?!mood)[a-z0-9]+"'
match: not_contains
target: { source: file, path: state.jsonl }
---
