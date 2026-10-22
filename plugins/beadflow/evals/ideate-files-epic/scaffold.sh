#!/usr/bin/env bash
# A roadmap stub waiting for ideation.
. "$(dirname "$0")/../lib/fixture.sh"

bd create --id t-mood --type epic --title "Villager mood" \
  --labels needs-ideation --spec-id docs/design/mood.md \
  -d "Mood decay and HUD bands." --silent >/dev/null
