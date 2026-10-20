#!/usr/bin/env bash
# Installs the beadflow plugin into one project and seeds its conventions.
#
#   cd /path/to/project
#   bash <(curl -fsSL https://raw.githubusercontent.com/samdogg7/beadflow/main/install.sh)
#
# or, from a clone:  /path/to/beadflow/install.sh [project-dir]
#
# Idempotent: re-running updates nothing that already exists.
set -euo pipefail

MARKETPLACE="samdogg7"
PLUGIN="beadflow"
RAW="https://raw.githubusercontent.com/samdogg7/beadflow/main"
PROJECT="${1:-$PWD}"

say()  { printf '%s\n' "$*"; }
fail() { printf 'install: %s\n' "$*" >&2; exit 1; }

command -v claude >/dev/null || fail "claude (Claude Code CLI) is not on PATH: https://code.claude.com/docs"
command -v bd >/dev/null || fail "bd (beads) is not installed. See https://github.com/gastownhall/beads#readme, then re-run."
command -v git >/dev/null || fail "git is not on PATH"
[ -d "$PROJECT/.git" ] || fail "$PROJECT is not a git repository; the plugin installs at project scope"

cd "$PROJECT"

# Templates: next to this script when run from a clone, else fetched from GitHub.
HERE="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || true)"
template() {
  local name="$1"
  if [ -n "$HERE" ] && [ -f "$HERE/plugins/$PLUGIN/templates/$name" ]; then
    cat "$HERE/plugins/$PLUGIN/templates/$name"
  else
    curl -fsSL "$RAW/plugins/$PLUGIN/templates/$name"
  fi
}

# 1. Marketplace and plugin.
if ! claude plugin marketplace list 2>/dev/null | grep -q "$MARKETPLACE"; then
  if [ -n "$HERE" ] && [ -f "$HERE/.claude-plugin/marketplace.json" ]; then
    claude plugin marketplace add "$HERE"
  else
    claude plugin marketplace add "samdogg7/$PLUGIN"
  fi
fi
claude plugin install "$PLUGIN@$MARKETPLACE" --scope project
say "plugin: $PLUGIN@$MARKETPLACE enabled in .claude/settings.json"

# 2. beads in the project.
if [ -d .beads ]; then
  say "beads: .beads exists"
else
  say "beads: no .beads folder. Run: bd init --prefix <short-project-prefix>"
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
say "Done. Next: write one docs/design/<system>.md per system, file roadmap stubs as"
say "epics (bd create --id <prefix>-<slug> --type=epic --labels=needs-ideation),"
say "then run /beadflow:next in Claude Code."
