---
type: regex
pattern: '"close_reason":"Responded"'
match: "count:2"
target: { source: file, path: state.jsonl }
---
