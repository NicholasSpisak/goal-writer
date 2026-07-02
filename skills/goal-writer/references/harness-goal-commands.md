# /goal mechanics: Claude Code and Codex CLI

How the two harnesses run a goal, what their evaluators can and cannot
see, and how the goal+rider pair maps onto each. Facts below are
accurate as of mid-2026 (Claude Code v2.1.139+, Codex CLI v0.128.0+);
check `--help` / official docs if a flag misbehaves.

## Contents

1. [The shared pattern](#the-shared-pattern)
2. [Claude Code /goal](#claude-code-goal)
3. [Codex CLI /goal](#codex-cli-goal)
4. [Writing for both evaluators at once](#writing-for-both-evaluators-at-once)

## The shared pattern

Both harnesses accept a goal of at most 4,000 characters — that is why
the goal file is capped. The handoff is the same in both:

1. Commit the goal+rider pair.
2. Paste the goal file **body** as the `/goal` argument.
3. The rider stays on disk; the goal's **Read first** section points at
   it by absolute path, so the executor loads it in its first turns.

The harness `/goal` is session-scoped and dies with the thread. The
pair is the project-scoped artifact that survives it: the slash command
is the runtime, the pair is the spec.

## Claude Code /goal

Requires Claude Code v2.1.139+. Docs: https://code.claude.com/docs/en/goal

- `/goal <condition>` sets a completion condition and starts a turn
  immediately, with the condition itself as the directive. One goal per
  session; a new one replaces the old.
- **Evaluator:** after each turn, the condition and the conversation
  are sent to the configured small fast model (defaults to Haiku),
  wrapped as a session-scoped prompt-based Stop hook. It returns yes/no
  plus a short reason; a "no" feeds the reason back as guidance for the
  next turn.
- **The evaluator never runs tools.** It cannot execute commands or
  read files — it judges only what the executing agent surfaced in the
  transcript. Every verification bullet must therefore be a command the
  agent runs whose output lands in the conversation.
- Limit: the condition can be up to 4,000 characters.
- Bounding: include a turn or time clause in the condition, e.g.
  "or stop after 20 turns."
- Status: bare `/goal` shows the condition, duration, turns evaluated,
  token spend, and the evaluator's latest reason. Clear with
  `/goal clear` (aliases: stop, off, reset, none, cancel); `/clear`
  also removes it.
- Sessions: an active goal is restored on `--resume` / `--continue`
  (counters reset). Headless: `claude -p "/goal <condition>"` runs the
  loop to completion in one invocation.
- Requires an accepted workspace trust dialog; unavailable when
  `disableAllHooks` or `allowManagedHooksOnly` is set.

Official effective-condition formula: **one measurable end state** (a
test result, a build exit code, a file count, an empty queue) + **a
stated check** ("`npm test` exits 0", "`git status` is clean") +
**constraints that matter** ("no other test file is modified").

## Codex CLI /goal

Requires Codex CLI v0.128.0+. If `/goal` isn't in the slash-command
list, run `codex features enable goals` (or set `features.goals = true`
in `~/.codex/config.toml`). Docs:
https://developers.openai.com/codex/use-cases/follow-goals

- `/goal <objective>` sets a persisted thread goal. Subcommands:
  `/goal` (view), `/goal pause`, `/goal resume`, `/goal clear`. One
  goal per thread, persisted in SQLite — it survives session resume.
- Limit: the objective must be non-empty and at most 4,000 Unicode
  characters (`MAX_THREAD_GOAL_OBJECTIVE_CHARS`). If the TUI composes
  something larger, it writes the text to
  `$CODEX_HOME/attachments/<uuid>/goal-objective.md` and stores a
  pointer instead.
- **Re-injection:** the full objective is re-injected on every
  auto-continuation turn, wrapped in `<objective>` tags, with standing
  instructions to keep the full objective intact and not "redefine
  success around a smaller or easier task."
- **Completion audit:** before the model may mark the goal complete, it
  must "derive concrete requirements from the objective and any
  referenced files," map **every explicit requirement, numbered item,
  named artifact, command, test, gate, invariant, and deliverable** to
  authoritative evidence, and "treat uncertain or indirect evidence as
  not achieved." Precise, enumerable requirements close rounds; vague
  ones stall them.
- The model reports completion via an `update_goal` tool with status
  `complete`, or `blocked` — but `blocked` only after the same blocker
  has repeated for at least three consecutive goal turns. Pause/resume
  is user-only.
- Optional token budget per goal; when exhausted the goal is marked
  budget-limited and the model wraps up with a progress summary.

Official goal-writing checklist: (1) name one objective and one
stopping condition; (2) point Codex at the files, docs, issue, logs, or
plan it must read first; (3) define the commands or artifacts that
prove progress; (4) tell it to work in checkpoints and keep a short
progress log. "A good goal is bigger than one prompt but smaller than
an open-ended backlog."

## Writing for both evaluators at once

The goal skeleton already satisfies both, by construction:

| Goal section | Claude Code evaluator | Codex completion audit |
|---|---|---|
| GOAL line + headline word | The one measurable end state | The single objective |
| Read first | Grounds the executor (evaluator sees its reads in transcript) | "Files it must read first" |
| Posture | "Constraints that matter" | Requirements the audit checks were not violated |
| Verification | The stated checks, transcript-provable | "Commands or artifacts that prove progress" |
| Stop when | The completion condition + optional turn bound | The stopping condition |

Two failure modes to design out:

- **Subjective end states** ("cleaner", "improved") — neither evaluator
  can judge them. Use exit codes, counts, greps, golden files, diffs.
- **Claims without evidence** — Claude's evaluator only sees the
  transcript, and Codex's audit rejects "intent, partial progress,
  memory of earlier work, or a plausible final answer" as proof. Write
  verification so the executor must *run* the check and show output,
  not assert success.

The phase loop's per-commit green requirement means evidence
accumulates in the transcript naturally: every phase produces test
output the evaluator can read.
