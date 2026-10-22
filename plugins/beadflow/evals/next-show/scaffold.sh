#!/usr/bin/env bash
# An epic with one task blocked on a question, and a second task whose build
# committed in a worktree but never merged.
. "$(dirname "$0")/../lib/fixture.sh"

bd create --id t-mood --type epic --title "Villager mood" \
  --spec-id docs/design/mood.md -d "Mood decay and HUD bands." --silent >/dev/null
bd create --parent t-mood --title "Add mood decay" \
  --acceptance "Mood drops by the configured amount each day." --silent >/dev/null
q=$(bd create --title "Decision: fixed 0-100 scale or named bands only?" \
  --labels human --type decision \
  -d "Decay needs a number to subtract from. Options: a) 0-100 integer with bands as thresholds (agent's pick), b) bands only." \
  --silent)
bd dep add t-mood.1 "$q" >/dev/null

bd create --parent t-mood --title "Show mood band on the HUD" \
  --acceptance "The HUD shows each villager's band." --silent >/dev/null
bd close t-mood.2 >/dev/null

git worktree add -q .claude/worktrees/agent-hud -b worktree-agent-hud
printf 'hud\n' > .claude/worktrees/agent-hud/hud.txt
git -C .claude/worktrees/agent-hud add hud.txt
old="$(( $(date +%s) - 3 * 3600 )) +0000"  # past next's 2-hour live-build window
GIT_COMMITTER_DATE="$old" GIT_AUTHOR_DATE="$old" \
  git -C .claude/worktrees/agent-hud commit -q -m "Show mood band on the HUD

Bead: t-mood.2"
