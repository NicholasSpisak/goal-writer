# Goal document template

## Contents

1. [Path and naming](#path-and-naming)
2. [The 4,000-character cap](#the-4000-character-cap)
3. [Skeleton](#skeleton)
4. [Section-by-section rules](#section-by-section-rules)
5. [Making the goal /goal-compatible](#making-the-goal-goal-compatible)
6. [Trim priority when over budget](#trim-priority-when-over-budget)
7. [Worked example](#worked-example)

## Path and naming

```
<project>/docs/goals/<YYYY-MM-DD>-<HHMM>-<project-slug>-<topic>-goal.md
```

- `<HHMM>` is the local 24-hour clock time when the file is created
  (e.g., `1444` for 2:44 PM). It makes `ls docs/goals/` sort in true
  authoring order rather than alphabetical by topic.
- The matching rider uses the **same** timestamp. Author the goal
  first, then mirror its timestamp on the rider — never split the pair
  across minutes. Two pairs in the same minute tiebreak alphabetically;
  that's fine.
- Real example: `2026-05-17-2130-findunmet-run-liveness-goal.md`.

## The 4,000-character cap

`wc -c <goal-file>` must be ≤ 4000. Re-check after every edit pass.

Where the number comes from: Codex CLI caps `/goal` objectives at
`MAX_THREAD_GOAL_OBJECTIVE_CHARS = 4_000` (Unicode characters); Claude
Code's `/goal` condition has the same 4,000-character limit. `wc -c`
counts bytes; bytes ≥ characters, so a `wc -c` pass guarantees both
harnesses accept the text inline. If Codex is handed something larger,
it doesn't bounce it — the TUI materializes the text to
`$CODEX_HOME/attachments/<uuid>/goal-objective.md` and stores a pointer
("read this file before continuing"), which costs the executor an extra
indirection every turn. Put long instructions in the rider instead —
that is exactly what the rider is for.

Working precedents cluster in the high 3,900s. A draft that keeps
landing above 4,000 is a sign the goal is doing work that belongs in
the rider. Each internal rider reference costs ~5 chars for the
`-HHMM-` insert, so leave a small buffer when riders cross-cite.

The cap matters because it forces you to decide what the goal *is*
before you write it. If you can't get under the cap, narrow scope —
the narrowing is the point.

## Skeleton

Fill each section, cut to fit:

```markdown
GOAL: <one-sentence headline>. <one paragraph: current pain → what the
goal lands → headline word (Friendliness / Multi-agent /
Self-documenting / Default mode / …)>.

**Read first.**

- `<absolute path to project architecture doc>` — substrate; one line.
- `<absolute path to the rider being written>` — schemas, signatures, depth tests.
- `<absolute paths to exemplars or research reports>` — grounding.
- Prior riders in `<absolute path to docs/goals/>` — invariants hold.

**Posture.** Stays `<tier>`. No `<struct>` schema changes (if
applicable). No `git push`. Edits inside `<project root>`. Major
architectural decisions → `<V1-CANDIDATES path>`.

<DOMAIN BODY — one or two of these, depending on the goal:>

**<N> modes / verbs / artifacts, auto-resolved.**

- **`<name>`** — <one line of behavior>.

**New verbs.**

- `<verb> <args>` — <one line>.

**Friendliness as a verifiable contract.**

- Auto-detect, don't ask (the obvious case is the default).
- Preflight + preview before any state change.
- Refuse with `try: <command>` lines.
- Rollback is one command.
- Lifecycle hints after every action.

**Phases.** Eleven (P1–P11) in the rider. Each: depth test first →
implement → `<project's build+test+lint+fmt command>` green →
conventional-commit → CHANGELOG. P11 adds a `<new section>` to the
project architecture doc.

**Verification.**

- Commands green every commit; every rider depth test present and passing.
- <Smoke 1>: <verifiable command + assertion>.
- <Smoke 2>: <verifiable command + assertion>.
- No edits outside `<project>`. No `git push`. No schema changes.

**Stop when** verification passes, AS-BUILT updated, CHANGELOG has a
"<Milestone name> (<tier>)" section, committed locally — or stop after
<N> turns and report what remains.
```

## Section-by-section rules

**GOAL line.** Starts with a verb ("Detect and recover…", "Make every
user-facing surface…"), not "we should consider improving." Name the
current pain with concrete file paths and function names (`cmd.Wait()`,
`refund-run.mjs`) so the agent grounds itself in HEAD, not in an
abstract description. End with the headline word — one word naming the
end-state after the round. If you can't pick one word, you're writing
two rounds.

**Read first.** Non-negotiable. Absolute paths only. If you cannot
point at the documents that ground the round, the round is not ready to
start. Always includes the rider being written.

**Posture.** Where most goal-engineering bugs hide. It is a list of
things the round will *not* do — mostly negations: "No DB schema
changes. No new runner deps. No sandbox template rebuild. No `git
push`." An autonomous agent under pressure will invent solutions;
posture is the fence that keeps it from inventing one outside this
round.

**Domain body.** What to build: modes, verbs, contracts. When the
round must *preserve* behavior (an editorial/refactor pass), list the
things that must survive — the flourish list is the agent's permission
slip: change everything except these. Otherwise an editorial agent
eventually deletes the thing you loved because removing it improves
the metric.

**Phases.** One line. The detail lives in the rider.

**Verification.** Observable commands and assertions — the exit
criteria. Every bullet is a command the executing agent runs whose
output lands in the transcript, plus the expected result. See the next
section.

**Stop when.** A single sentence tying verification to a final commit,
plus an explicit turn cap. The official guidance pairs a precise
completion condition with a bound — "stop after 5 tries" — so end this
line with "or stop after `<N>` turns and report what remains." The
condition tells the agent when it is done; the cap tells it when to give
up, and keeps a stalled loop from burning tokens indefinitely. Default
to including it; drop it only when a hard external stop already bounds
the run. Never "stop when it feels done."

## Making the goal /goal-compatible

The goal file body doubles as the `/goal` argument in both Claude Code
and Codex.

Claude Code's official effective-condition formula:

1. **One measurable end state** — a test result, a build exit code, a
   file count, an empty queue.
2. **A stated check** — how the agent proves it: "`npm test` exits 0",
   "`git status` is clean", "`grep -c '^### P' rider.md` prints 11".
3. **Constraints that matter** — what must not change on the way:
   "no other test file is modified", "no schema changes". These block
   shortcut paths (deleting tests, hardcoding outputs).
4. **An explicit bound** (recommended) — "or stop after 20 turns."

Codex's official goal checklist adds three requirements the skeleton
also covers: point the agent at the **files it must read first**
(Read first), name the **commands or artifacts that prove progress**
(Verification), and have it **work in checkpoints with a short
progress log** (the phase loop: one commit + one CHANGELOG line per
phase is exactly that log).

Claude Code's evaluator is a small fast model reading the transcript;
**it never runs commands or reads files**. Write every verification
bullet as something the executing agent's own output can demonstrate.
Codex re-injects the objective every continuation turn and runs a
completion audit that maps every explicit requirement, named artifact,
command, test, gate, and deliverable to real evidence — so vague
requirements stall the round, and precise ones close it.

Subjective end states ("cleaner", "more maintainable", "improved UX")
are unjudgeable by both. Convert them to counts, exit codes, greps,
golden files, and diffs.

## Trim priority when over budget

1. Drop parenthetical detail that's already in the rider.
2. Shorten Read-first descriptions to bare absolute paths.
3. Compress Posture to one or two lines.
4. Cut verification smoke bullets to two.
5. Drop cross-rider "do not preempt" notes; those live in the rider.

## Worked example

A condensed real-world goal (the "Liveness" round, 3,991 chars in the
original; abbreviated here to show shape, not length):

```markdown
GOAL: Detect and recover every way a findunmet run can silently die.
Today a claude subprocess can write its output and never exit — the
runner blocks in cmd.Wait() forever, the E2B sandbox burns credits,
and mornings start with manual refund-run.mjs calls. This round lands
stage heartbeats, an output-stall kill, diagnosable failure reasons,
and guaranteed sandbox cleanup. Headline: Liveness.

**Read first.**

- /Users/gdc/findunmet/docs/AS-BUILT-ARCHITECTURE.md — substrate.
- /Users/gdc/findunmet/docs/goals/2026-05-17-2130-findunmet-run-liveness-rider.md
  — schemas, thresholds, depth tests.
- Prior riders in /Users/gdc/findunmet/docs/goals/ — invariants hold.

**Posture.** Alpha. No DB schema changes — heartbeats reuse
system_log{phase,heartbeat:true}. No new runner deps. No sandbox
template rebuild. Edits inside /Users/gdc/findunmet/. No git push.

**Four-layer liveness contract.**

- **Stage heartbeats** — every stage emits
  system_log{phase,heartbeat:true,elapsed_ms} every 30s.
- **Output-stall kill** — runClaudeWithStallGuard samples stdout every
  10s; no growth past the per-stage threshold → SIGTERM, 5s grace,
  SIGKILL.
- **Diagnosable failure_reason** — every terminal write matches
  ^(seed|fetch|rank|report|entrypoint|watchdog|provision|unknown): .+
- **Sandbox cleanup** — every terminal status calls
  killSandbox(sandbox_id) exactly once.

**Phases.** Twelve in the rider. Each: depth test first → implement →
make check green → conventional commit (rider PN) → CHANGELOG line.

**Verification.**

- make check green every commit; all 47 rider depth tests present and
  passing (grep -c '^func Test_' matches the rider's list).
- Kill -STOP a fetch subprocess in a test harness: run ends failed with
  failure_reason "fetch: output stalled 180s", sandbox killed once.

**Stop when** verification passes, AS-BUILT §20 added, CHANGELOG has a
"Run liveness (alpha)" section, committed locally — or stop after 25
turns and report what remains.
```

Note what makes this work: the pain is named with real symbols
(`cmd.Wait()`, `refund-run.mjs`), the posture is five negations, every
verification bullet is a command plus an observable assertion, and the
stop condition ties to a commit with a turn bound as a safety valve.
