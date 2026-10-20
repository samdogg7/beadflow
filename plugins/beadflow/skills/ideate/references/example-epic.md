# Example breakdown

A mid-sized feature for a 2D platformer: a stamina meter that limits sprinting.
This is the shape to post in chat at step 4, with the epic reduced to one line.
Adapt the fields to the project; the content is illustrative.

## Epic: Stamina-limited sprint

**Type:** epic · **Priority:** P2 · Description: the design summary confirmed
in step 3 (below, for reference only; don't repost it at step 4).

**Step 3 summary, which becomes the description:**

> Sprinting drains a stamina meter, so the player has to choose when to run
> instead of holding sprint everywhere. The goal is tension in chase sections
> and a reason to learn routes.
>
> Stamina lives on the player scene as a `Stamina` child node exposing
> `current`, `max`, and a `changed(current, max)` signal. Sprinting drains it
> per second; standing or walking regenerates it after a short delay. At zero,
> sprint cuts out until the meter refills past a threshold, so the player can't
> stutter-sprint at 1%. A HUD bar listens to `changed`. Drain, regen, delay, and
> threshold live in a `StaminaConfig` Resource so they can be tuned without code
> changes.
>
> No save data. Stamina resets to full on respawn and level load.
>
> **Out of scope:** stamina upgrades, other actions that cost stamina (jump,
> attack), sound effects.
>
> **Open decisions:** whether the HUD bar hides when full (decide after the
> first playtest; doesn't block work).

## Children

1. **Add Stamina node with drain and regen** · task · P2
   - Acceptance:
     - `Stamina` node exposes `current`, `max`, and emits `changed(current, max)`.
     - Drain, regen rate, regen delay, and recovery threshold read from a
       `StaminaConfig` Resource.
     - A test in the project's test framework covers drain, regen after delay,
       and the recovery threshold.
   - Depends on: none

2. **Gate sprint on stamina in the player controller** · task · P2
   - Acceptance:
     - Holding the sprint action drains stamina; at zero, the player drops to
       walk speed until stamina passes the threshold.
     - Stamina resets to full on respawn.
     - The player scene runs without errors or warnings.
   - Depends on: 1

3. **Add stamina bar to the HUD** · task · P3
   - Acceptance:
     - Bar updates from the `changed` signal only; it doesn't poll the player.
     - Manual check: sprint to empty and watch the bar drain, pause, then refill.
   - Depends on: 1

4. **Playtest and tune stamina values** · task · P3 · **PLAYTEST**
   - Acceptance:
     - Manual check: the longest chase section can be finished by a player who
       manages stamina, and can't be by one who holds sprint the whole time.
     - Final values committed to the `StaminaConfig` resource file.
     - Decision recorded on whether the HUD bar hides when full.
   - Depends on: 2, 3

## Spike example

When a decision blocks work, file it as a spike (or the closest type bd
supports) that produces an answer, not code:

- **Decide save format before adding persistent upgrades** · spike · P1 · **SPIKE**
  - Why: upgrades need saving and no save system exists yet.
  - Acceptance: a comment on this bead recommends a format and location, with
    one rejected alternative and why. No code merged.
  - Blocks: any task that writes save data.
