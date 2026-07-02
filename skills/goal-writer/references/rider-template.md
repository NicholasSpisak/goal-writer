# Rider document template

## Contents

1. [Path and naming](#path-and-naming)
2. [Skeleton](#skeleton)
3. [The standard 11-phase shape](#the-standard-11-phase-shape)
4. [Depth-test discipline](#depth-test-discipline)
5. [Threshold calibration notes](#threshold-calibration-notes)
6. [Section notes](#section-notes)

## Path and naming

```
<project>/docs/goals/<YYYY-MM-DD>-<HHMM>-<project-slug>-<topic>-rider.md
```

Use the **same** `<YYYY-MM-DD>-<HHMM>` prefix as the matching goal so
the pair sorts together. Author the goal first, then mirror its
timestamp on the rider — never split them across minutes.

No character cap. Typical riders run 10–35 KB; real-world corpus spans
9 KB to 51 KB.

## Skeleton

```markdown
# <project> — <Slug> Rider (<short framing>)

This rider holds the prescriptive constraints for the goal at
`<absolute path to goal>`. It supersedes nothing in prior riders
(<list dated rider filenames>) — their invariants still apply.
This rider adds <one-line summary of what's new>.

**All paths absolute.** Source `<project root>`, runtime `<runtime root>`.

## Posture (decided — do not redesign)

- **Maturity stays `<tier>`** (alpha / beta / stable; mirrors what
  the project calls the current milestone).
- **No `<struct>` schema changes** (if applicable). State lives in
  files at `<path>`.
- **<Other domain-specific invariants — be explicit>.**
- **No `git push`.** Phased local commits only.
- **No V1 / next-tier invention.** If a phase reveals a major
  architectural decision, log it in `<V1-CANDIDATES path>` (or
  equivalent) and continue.
- **Edits stay inside `<project root>`.**

## Data model (files, not fields)

<JSON schemas for any new file-based state. One block per file.
Inline-comment each field if the meaning isn't obvious.>

## <Algorithms / Mode resolution / Detection rules>

<Pseudocode for non-obvious logic. The rider IS the spec — match it
in the implementation.>

## Verb signatures

```
<verb> <args>
    [--flag]                  # description
    [--other-flag <type>]     # description
```

For each verb: refusal cases table.

## Phases (eleven)

Each phase: write the named depth test(s) **first** and watch them
fail; implement; green on
`<project's build+test+lint+fmt command, green on each commit>`;
conventional-commit local commit; one-line CHANGELOG entry.

### P1 — <name>

- <bulleted prescriptions>

Depth tests (write these first, watch them fail; in `<test path>`):
- `snake_case_descriptive_name_that_would_have_caught_the_thin_behavior`
- `another_named_test`

### P2 — <name>

...

### P11 — Architecture doc update + CHANGELOG (doc only; no depth test)

- Insert a new top-level section into `<architecture doc path>`:
  ```
  ## NN. <Section title>

  NN.1 <subsection>
  NN.2 <subsection>
  ...
  ```
- If the architecture doc has a "what's shipped vs thin" section,
  update it:
  - Add to the "shipped" side: <items this rider lands>.
  - Note explicitly whether this rider closes prior thin items or
    only adds capability.
- Append to `<CHANGELOG path>`:
  ```
  ## <Milestone name> (<tier>) — <YYYY-MM-DD>

  - <bullet>
  ```

## Integration matrix (when multi-mode or multi-verb)

| <axis> | <feature 1> | <feature 2> | … |
|---|---|---|---|
| ... | ... | ... | ... |

## Error-footer canonical pairs

| Error | `try:` |
|---|---|
| `<terse description>` | `<one specific command or fix>` |

(Parameterized over a depth test so every error case is exercised.)

## Config additions (when relevant)

```toml
[defaults]
<new_knob> = "<default>"
```

## Out of scope (explicitly not in this milestone)

- <one bullet per V1-candidate scope item>
- <…>

## Dependencies (Tier 1 / 2 / 3 policy)

Tier 1 (utility, free): <list with one-line justification each>.
Tier 2 (architectural, log to `DEPENDENCIES.md`): <list or "none expected">.
Tier 3 (blocked): same blocks as prior riders.

## Engineering invariants (do not violate)

- **No `<struct>` schema changes.**
- **One depth test before each phase implementation.** A phase whose
  tests were never red is suspect.
- **<Domain-specific invariants>.**
- **No silent expansion.** Anything beyond P1–P11 goes into
  `V1-CANDIDATES.md`.
- **<Spec-pinning invariants>**: e.g., "the preview block format is
  depth-tested; changing whitespace changes the spec."

## Process invariants

- Phased local commits only. No `git push`.
- Each phase ends with the relevant depth tests passing and a
  CHANGELOG entry naming the SHA.
- After P11, optionally capture a demo (asciinema cast / screenshots /
  short video) under `<project>/<demo-path>`. Skip when the change
  isn't user-visible.
- If a phase reveals a V1-architecture decision, stop and log it in
  `V1-CANDIDATES.md`; do not silently expand scope.
```

## The standard 11-phase shape

Adapt the names; eleven is a target, not a hard rule — nine to twelve
is fine if the structure earns it:

- **P1**: Data model / plumbing — new module / file path / frontmatter
  helpers. No behavior change yet.
- **P2–P3**: Foundation — new primitive types, base mechanism.
- **P4–P8**: Feature implementation — one phase per major slice; each
  phase ships with end-to-end depth tests.
- **P9**: Integration with prior verbs / modes / state machines.
- **P10**: Cross-cutting friendliness pass — flags like `--quiet` /
  `--plain`, error-footer routing, post-action hints, help-text
  grouping.
- **P11**: Architecture-doc update + CHANGELOG + (optional) demo
  capture (doc-only; no depth test).

Every phase yields exactly one commit (subject ends `(rider PN)`, so
`git log --grep "rider P5"` returns the commit that landed P5) and one
CHANGELOG line. Eleven phases → eleven commits → eleven CHANGELOG
lines.

## Depth-test discipline

Depth tests are named behavioral assertions, written into the rider
**before** implementation exists, then written as failing tests before
each phase's code. Names must read as assertions you could defend in
code review:

```
stallguard_kills_after_no_output_growth_in_threshold_window
stallguard_does_not_kill_during_steady_output_growth
stallguard_sigterm_then_sigkill_after_grace_period
lifecycle_fail_truncates_suffix_not_prefix_when_over_cap
```

Not `test_stallguard_5`.

Presence is mechanically enforceable — count test functions and compare
against the rider's list:

| Language | Check |
|---|---|
| Rust | `grep -c '^    fn ' tests/<file>.rs` |
| Go | `grep -c '^func Test_' <file>_test.go` |
| TypeScript | `grep -c "^  \(it\|test\)(" <file>.test.ts` |
| Python | `grep -c '^def test_' test_<file>.py` |

A typical round lands 30–80 named depth tests.

## Threshold calibration notes

When the rider pins numeric thresholds (timeouts, caps, retry counts),
add a short calibration note per number: the observed data that
produced it (p50/p95/max from logs), the false-positive vs
false-negative cost, and a commitment to recalibrate after N production
runs. Without that paragraph, the numbers look arbitrary; with it, they
are decisions. This is the antidote to voodoo constants — if you don't
know why a value is right, the executing agent won't either.

## Section notes

- **Posture** mirrors and expands the goal's posture. "Decided — do not
  redesign" in the heading is load-bearing: it stops the executor from
  re-opening settled questions.
- **Data model (files, not fields):** durable per-feature state lives
  in files inside the working tree (write `.tmp`, then atomic rename —
  single writer, single reader, no locking), not new struct or DB
  fields. Schema changes are last-resort. Skip this invariant for
  projects without persistent state structs.
- **Algorithms:** the rider is the spec. If the implementation and the
  rider disagree mid-round, either fix the implementation or update the
  rider in the same commit — no stale specs.
- **Error-footer canonical pairs:** every refusal prints a `try:` line
  with one specific recovery command. A parameterized depth test fires
  every refusal code and asserts a non-empty hint.
- **Out of scope** is the rider's local copy; `docs/V1-CANDIDATES.md`
  is the durable home. Every out-of-scope bullet is a real engineering
  decision deferred — that's what makes the round shippable in a day
  instead of a week, and it means the next goal almost writes itself.
- **Engineering vs process invariants:** engineering invariants
  constrain the code (schemas, spec-pinning); process invariants
  constrain the workflow (commit cadence, CHANGELOG, demo capture,
  the stop-and-log rule for V1 decisions).
