# goal-writer

A portable agent skill that drafts **goal+rider document pairs** — the
two-file briefing system for autonomous coding agents — fully aligned
with the official `/goal` best practices of **Claude Code** and
**OpenAI Codex CLI**.

Invoke it as `/goal-writer` in Claude Code, or `$goal-writer` in Codex.

## The two-file system

One round of agent work gets two committed markdown files in your
project's `docs/goals/`:

| File | Budget | Carries |
|---|---|---|
| `<date>-<time>-<project>-<topic>-goal.md` | **≤ 4,000 characters** | The spine: GOAL line + headline word, read-first paths, posture (what must NOT change), verification commands, stop condition |
| `<date>-<time>-<project>-<topic>-rider.md` | Unbounded (typically 10–35 KB) | The prescriptive detail: data schemas, algorithms, verb signatures, 11 phases with named depth tests, integration matrix, out-of-scope list, invariants |

The 4,000-character cap is not arbitrary: it is Codex CLI's
`MAX_THREAD_GOAL_OBJECTIVE_CHARS`, matched by Claude Code's `/goal`
condition limit. The goal file body pastes directly into `/goal` in
either harness; the rider stays on disk, referenced by absolute path.
The same pair briefs Claude Code, Codex, Cursor, or a human reviewer
without modification.

The pattern is Greg Ceccarelli's
[goal engineering](https://www.gregceccarelli.com/goal-engineering):
*"The cap forces decisions. The rider forces precision. The phases
force sequencing. The depth tests force testability."*

## What the skill does

When you ask for a goal (`/goal-writer add rate limiting to the API`),
it:

1. **Reads your project first** — architecture doc, prior goal+rider
   pairs, recent commits, source at HEAD. It asks rather than invents.
2. **Scopes one round** — one feature, 2–5 files, half a day to a day
   of agent runtime, named by a single headline word.
3. **Drafts the goal** under the 4,000-char cap, with verification
   written to satisfy *both* harnesses' evaluators: Claude Code's
   tool-less transcript evaluator and Codex's evidence-based
   completion audit.
4. **Drafts the rider** — phased plan with named depth tests written
   before implementation, posture invariants, error footers,
   out-of-scope list.
5. **Validates mechanically** with the bundled
   [`validate_pair.sh`](skills/goal-writer/scripts/validate_pair.sh)
   (size cap, phase count, required sections, mutual citation, shared
   timestamp) and commits the pair.

## Install

```bash
git clone https://github.com/NicholasSpisak/goal-writer.git
cd goal-writer
./install.sh              # both harnesses, user-level
```

Options:

```bash
./install.sh --claude         # Claude Code only  → ~/.claude/skills/goal-writer
./install.sh --codex          # Codex only        → ~/.agents/skills/goal-writer
./install.sh --project        # current repo      → .claude/skills + .agents/skills
./install.sh --codex-prompt   # optional /prompts:goal-writer command for Codex
```

Manual install: copy `skills/goal-writer/` to
`~/.claude/skills/goal-writer` (Claude Code) and/or
`~/.agents/skills/goal-writer` (Codex). Restart the harness.

> Note: Claude Code and Codex read different skill directories, so the
> installer copies to both. Codex's older `~/.codex/skills` path is
> deprecated; this installer uses the current `~/.agents/skills`.

## Use

**Claude Code**

```
/goal-writer harden the webhook handler against replay attacks
```

**Codex CLI**

```
$goal-writer harden the webhook handler against replay attacks
```

(or `/skills` to browse; or `/prompts:goal-writer <topic>` if you
installed the prompt shim). Codex also auto-selects the skill when a
request matches its description.

Then start the round in either harness by pasting the drafted goal
file's body:

```
/goal <goal file body>
```

Claude Code keeps working until its evaluator confirms the condition
from the transcript. Codex re-injects the objective every turn and
runs a completion audit before accepting "done." (Codex: enable once
with `codex features enable goals` if `/goal` isn't listed.)

## Repository layout

```
skills/goal-writer/
├── SKILL.md                              # the skill (agentskills.io standard)
├── references/
│   ├── goal-template.md                  # goal skeleton + worked example
│   ├── rider-template.md                 # rider skeleton + depth-test rules
│   └── harness-goal-commands.md          # /goal mechanics in both harnesses
└── scripts/
    └── validate_pair.sh                  # 5 mechanical pair checks
codex/goal-writer.md                      # optional Codex custom-prompt shim
install.sh
```

## When not to use it

A five-line CSS tweak doesn't need eleven phases. Skip the pair for
hot-fixes and 15-minute polish; the overhead amortizes only against
rounds that would otherwise run hours of agent time. The pattern also
wants a real architecture doc, a CHANGELOG, and a fast (~30 s) test
lane — the skill offers to bootstrap the missing pieces first.

## Credits

- **Pattern & original skill:** the goal-engineering method and the
  `goal-rider-author` skill are by
  [Greg Ceccarelli](https://www.gregceccarelli.com/goal-engineering)
  / SpecStory, Inc., published under Apache-2.0. This skill is a
  derivative work — restructured for progressive disclosure and
  extended with the official Claude Code and Codex `/goal`
  documentation (evaluator constraints, completion-audit alignment,
  dual-harness install).
- **This skill:** Nick Spisak.

## License

[Apache-2.0](LICENSE). See [NOTICE](NOTICE) for attribution.
