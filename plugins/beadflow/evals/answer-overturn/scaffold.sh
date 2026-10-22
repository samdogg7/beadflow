#!/usr/bin/env bash
# A finished epic with a non-blocking decision already in its code, and an
# open epic with a task blocked on a question.
. "$(dirname "$0")/../lib/fixture.sh"

bd create --id t-mood --type epic --title "Villager mood" \
  --spec-id docs/design/mood.md -d "Mood decay and HUD bands." --silent >/dev/null
bd create --parent t-mood --title "Add mood value with daily decay" \
  --acceptance "Mood drops each day." --silent >/dev/null
bd close t-mood.1 >/dev/null
bd close t-mood >/dev/null
bd create --title "Decision: should mood be a 0-100 scale or named bands only?" \
  --labels human --type decision \
  -d "In code now: a 0-100 integer with bands as thresholds, landed by t-mood.1. Options: a) keep the 0-100 integer (agent's pick, in code) b) bands only, decay steps from band to band." \
  --silent >/dev/null

bd create --id t-fog --type epic --title "Fog of war" -d "Fog over unexplored tiles." --silent >/dev/null
bd create --parent t-fog --title "Add fog layer" \
  --acceptance "Unexplored tiles are hidden." --silent >/dev/null
q=$(bd create --title "Decision: should fog lift at dawn or stay until a tile is scouted?" \
  --labels human --type decision \
  -d "Blocks t-fog.1. Options: a) stays until scouted (agent's pick) b) lifts at dawn." \
  --silent)
bd dep add t-fog.1 "$q" >/dev/null
