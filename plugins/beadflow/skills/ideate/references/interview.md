# Interview checklist

Work through these in order, one question at a time. Areas marked
**Always** apply to every idea, even a small tweak. The rest have a "Skip when"
test; skip the area when the test holds. The bullets are prompts for you, not a
script to read out.

## Contents
1. Player experience (always)
2. Core loop
3. Code touchpoints
4. Persistence
5. Tuning
6. Edge cases and failure states (always)
7. Out of scope (always)
8. Open decisions (always)

## 1. Player experience
**Always.** For infrastructure or tooling work (a sim library, a build
pipeline, a dev console) the player is the developer: ask what they do with
it, what it must never make hard later, and which seams other systems plug
into. Skip sections 2 and 4 to 5 unless they clearly apply.

- What does the player do, moment to moment, when this feature is in play?
- What should they feel? (Tense, clever, powerful, relieved.)
- Why does the product need this? What's missing or broken without it?
- How does the player learn it exists? Tutorial, discovery, UI hint?

Push back if the answer is a mechanic with no feeling attached ("it's a dash")
or a feeling with no mechanic ("it should feel juicy").

## 2. Core loop
Skip when the change is cosmetic and doesn't alter what the player does or
earns (a new particle effect, a font swap).

- Does it change moment-to-moment play, progression, or both?
- Does it make something existing easier, harder, or obsolete?
- When in a session or run does the player first meet it?
- Does it add a resource, currency, or meter the player has to track?

## 3. Code touchpoints
Skip when the change only adjusts an existing value or asset. Otherwise ask only
the parts the design needs; leave implementation to the tasks.

- **Where the logic lives:** if the project keeps simulation logic in an
  engine-independent library (CLAUDE.md or the architecture doc will say), does
  this belong there, in scenes, or split across both? Get the seam right first;
  the rest of this section is about the host side only.
- **Ownership:** new module, scene, or service, or added to an existing one?
  Which one owns the behavior?
- **Events:** what should other systems hear about? Name the signals, events,
  or messages.
- **Global state:** does this need a singleton or autoload, or can it live
  where it's used? Check the project's config before asking whether one exists.
- **Data:** is there data (items, abilities, config) that belongs in a data
  file or resource type rather than code?
- **Input and UI:** new input actions or UI surfaces? Which existing ones does
  it share or conflict with?

## 4. Persistence
Skip when nothing outlives a scene reload (a visual effect, a camera tweak). If
you skip it, the design summary must say "No save data".

- Does anything need to be saved? What exactly, and when?
- What happens to saves made before this feature exists? Default value,
  migration, or break them?
- Is there a save system yet? If not, that may be its own spike or blocker.

## 5. Tuning
Skip when there are no numbers a playtest could change (a menu reorder).

- Which numbers will need playtesting? (Speeds, cooldowns, damage, spawn rates.)
- Where should they live: exported properties on a node, or a Resource file
  designers can edit without touching code?
- Is there a starting value to try, or should a spike find one?

## 6. Edge cases and failure states
**Always.**

- What happens if the player triggers it at a bad moment: mid-air, mid-dialogue,
  while paused, during a scene change?
- What if two instances overlap or the player spams the input?
- What can go wrong, and what does the player see when it does?
- Does it interact with death, respawn, or level reload?

## 7. Out of scope
**Always.**

- What's the smallest version worth shipping?
- What related ideas came up that should be explicitly deferred?

Write these down. An agent picking up the epic later needs to know what not to
build.

## 8. Open decisions
**Always.**

- What's still undecided?
- Which of those blocks work, and which can wait for a playtest?

Blocking decisions become spikes or block specific tasks. Non-blocking ones go
in the epic description under "Open decisions".
