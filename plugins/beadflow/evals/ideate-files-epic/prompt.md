---
allowed_tools: [Read, Glob, Grep, Skill, Bash, Write, Edit]
---

/beadflow:ideate t-mood

I'm away from the keyboard and can't use the picker, so here are all my
replies up front. Take them as my answers and don't wait on me.

The design: mood is a 0-100 integer per villager, saved per villager. It
drops by a configured amount each day and recovers by a configured amount
on days the villager's needs are met. Bands are thresholds on it: content
60-100, uneasy 30-59, angry 0-29. The HUD shows the band name. Out of
scope: mood changing villager behaviour. I approve the summary.

The breakdown, approved as written:

1. Decide the daily decay and recovery amounts. Spike, P1. Acceptance: a
   comment on this bead recommends both amounts with a reason.
2. Add the mood value with daily decay and recovery. Task, P2. Acceptance:
   a test shows mood dropping on a day with unmet needs and recovering on
   a day with met needs. Depends on 1.
3. Show the mood band on the HUD. Task, P3. Acceptance: the HUD shows
   content, uneasy, or angry for the selected villager. Depends on 2.

No design doc changes. Commit as the skill says.
