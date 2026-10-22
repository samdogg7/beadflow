#!/usr/bin/env bash
# An epic with one small task, ready to build.
. "$(dirname "$0")/../lib/fixture.sh"

cat > docs/design/greeting.md <<'EOF'
# Greeting

Status: draft

The project greets the player with a `hello.txt` file at the repo root.
EOF
printf '#!/bin/sh\ngrep -qx hello hello.txt\n' > test.sh
git add -A
git commit -q -m "Add greeting design and test"

bd create --id t-greet --type epic --title "Greeting" \
  --spec-id docs/design/greeting.md -d "Add the greeting file." --silent >/dev/null
bd create --parent t-greet --title "Create hello.txt" \
  --acceptance "hello.txt at the repo root holds the single line hello; sh test.sh passes." \
  --silent >/dev/null
bd export -o .beads/issues.jsonl >/dev/null
git add -A
git commit -q -m "File the greeting epic"
