# Shared scaffold for beadflow eval cases: a git repo with bd initialised,
# the beadflow CLAUDE.md sections, and one design doc. Sourced by each
# case's scaffold.sh, which runs in the case's empty workspace.

set -euo pipefail

git init -q -b main .
git config user.name "beadflow eval"
git config user.email "eval@example.invalid"

bd init --prefix t --non-interactive >/dev/null 2>&1

mkdir -p docs/design
cat > docs/design/mood.md <<'EOF'
# Mood

Status: draft

Each villager has a mood that decays a little every day and recovers when
their needs are met. Mood shows on the HUD as a named band: content,
uneasy, or angry.

## Save data

Mood is saved per villager.
EOF

cat > CLAUDE.md <<'EOF'
# Project

## Build & Test

- Test: `sh test.sh`

## Design docs

Design docs live in `docs/design/`, one file per system, plus
`decisions.md`, a numbered, append-only decisions log.
EOF

printf '# Decisions\n' > docs/design/decisions.md
printf '#!/bin/sh\nexit 0\n' > test.sh

git add -A
git commit -q -m "Initial project"
