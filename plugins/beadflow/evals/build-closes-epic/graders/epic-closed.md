---
type: regex
pattern: '"id":"t-greet","[^\n]*"status":"closed"'
target: { source: file, path: state.jsonl }
---
