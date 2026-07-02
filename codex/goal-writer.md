---
description: Draft a goal+rider pair (≤4000-char goal + phased rider) for the next round of agentic work
argument-hint: "<topic for the new goal>"
---

Use the goal-writer skill for this task. Read
`.agents/skills/goal-writer/SKILL.md` in the current repository if it
exists, otherwise `~/.agents/skills/goal-writer/SKILL.md`, in full and
follow it exactly — including its pre-work, the goal and rider
templates it references, and its validation script — to draft a
goal+rider document pair for:

$ARGUMENTS

If neither skill file exists, tell the user to install it:
https://github.com/NicholasSpisak/goal-writer (`./install.sh --codex`).
