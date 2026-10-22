---
type: regex
pattern: '"id":"t-mood","[^\n]*"status":"open"'
target: { source: file, path: state.jsonl }
---
