#!/usr/bin/env bash
# Installs the beadflow plugin into one project and seeds its conventions.
# Run from a clone of this repo:
#
#   /path/to/beadflow/install.sh [project-dir] [bd-prefix]
#
# Idempotent: re-running changes nothing that already exists. Afterwards, run
# /beadflow:setup in Claude Code to fill in Build & Test, split a design doc
# into docs/design/, and file roadmap stubs.
set -euo pipefail

MARKETPLACE="samdogg7"
PLUGIN="beadflow"
PROJECT="${1:-$PWD}"
PREFIX="${2:-$(basename "$PROJECT" | tr '[:upper:]' '[:lower:]' | tr -c 'a-z0-9\n' '-')}"

say()  { printf '%s\n' "$*"; }
fail() { printf 'install: %s\n' "$*" >&2; exit 1; }

command -v claude >/dev/null || fail "claude (Claude Code CLI) is not on PATH: https://code.claude.com/docs"
command -v bd >/dev/null || fail "bd (beads) is not installed. See https://github.com/gastownhall/beads#readme, then re-run."
command -v git >/dev/null || fail "git is not on PATH"
[ -d "$PROJECT/.git" ] || fail "$PROJECT is not a git repository; the plugin installs at project scope"

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ -f "$HERE/.claude-plugin/marketplace.json" ] || fail "run this script from a clone of the beadflow repo"

cd "$PROJECT"

template() { cat "$HERE/plugins/$PLUGIN/templates/$1"; }

# 1. Marketplace and plugin.
if ! claude plugin marketplace list 2>/dev/null | grep -q "$MARKETPLACE"; then
  claude plugin marketplace add "$HERE"
fi
claude plugin install "$PLUGIN@$MARKETPLACE" --scope project
say "plugin: $PLUGIN@$MARKETPLACE enabled in .claude/settings.json"

# 2. beads in the project.
if [ -d .beads ]; then
  say "beads: .beads exists"
else
  bd init --prefix "$PREFIX"
  say "beads: initialised with prefix '$PREFIX' (pass a second argument to choose another)"
fi

# 3. CLAUDE.md conventions.
if [ -f CLAUDE.md ] && grep -q "^## Decisions you can't make" CLAUDE.md; then
  say "CLAUDE.md: conventions already present"
else
  { [ -f CLAUDE.md ] && printf '\n'; template CLAUDE-snippet.md; } >> CLAUDE.md
  say "CLAUDE.md: appended the beadflow sections; fill in Build & Test"
fi

# 4. Design docs.
mkdir -p docs/design
if [ -f docs/design/README.md ]; then
  say "docs/design/README.md: exists, left alone"
else
  template design-README.md > docs/design/README.md
  say "docs/design/README.md: created"
fi
if [ ! -f docs/design/decisions.md ]; then
  cat > docs/design/decisions.md <<'MD'
# Decisions

Status: design, not built.

## Open questions and defaults taken

## Decisions and why

One numbered line each, with the date and the reason. Never delete a line; to
change a decision add a new line and mark the old one `(superseded by #N)`.
See `README.md`.

MD
  say "docs/design/decisions.md: created"
fi

say ""
say "Done. Open Claude Code in $PROJECT and run /beadflow:setup."
