#!/usr/bin/env bash
# validate_pair.sh — mechanical checks for a goal+rider document pair.
#
# Usage: validate_pair.sh <goal-file> <rider-file>
#
# Checks:
#   1. Goal is <= 4000 bytes (wc -c; bytes >= Unicode chars, so this is
#      conservative for both Claude Code and Codex /goal limits).
#   2. Rider has phase headers (### P1..### PN). 11 is the target;
#      other counts warn (eleven is a target, not a rule); zero fails.
#   3. Rider has the six standard top-level sections.
#   4. Goal and rider cite each other's filenames.
#   5. Both files share the same <YYYY-MM-DD>-<HHMM> timestamp prefix.
#
# Exit 0 = pair valid (warnings allowed). Exit 1 = at least one failure.

set -u

if [ $# -ne 2 ]; then
  echo "usage: $(basename "$0") <goal-file> <rider-file>" >&2
  exit 1
fi

GOAL=$1
RIDER=$2
FAIL=0

fail() { echo "FAIL: $*"; FAIL=1; }
warn() { echo "warn: $*"; }
pass() { echo "ok:   $*"; }

for f in "$GOAL" "$RIDER"; do
  if [ ! -s "$f" ]; then
    fail "$f is missing or empty"
  fi
done
[ "$FAIL" -eq 1 ] && exit 1

# 1. Goal size cap
GOAL_BYTES=$(wc -c < "$GOAL" | tr -d ' ')
if [ "$GOAL_BYTES" -le 4000 ]; then
  pass "goal is $GOAL_BYTES bytes (cap 4000)"
else
  fail "goal is $GOAL_BYTES bytes; cap is 4000. Trim priority: drop detail already in the rider, shorten Read-first to bare paths, compress Posture, cut smokes to two."
fi

# 2. Phase headers
PHASES=$(grep -c '^### P[0-9]' "$RIDER")
if [ "$PHASES" -eq 11 ]; then
  pass "rider has 11 phase headers"
elif [ "$PHASES" -ge 1 ]; then
  warn "rider has $PHASES phase headers (target 11; fewer or more is fine if the structure earns it)"
else
  fail "rider has no phase headers (### P1 .. ### PN) — the phase plan is the rider's spine"
fi

# 3. Standard top-level sections
for section in "Posture" "Phases" "Out of scope" "Dependencies" \
               "Engineering invariants" "Process invariants"; do
  if grep -q "^## $section" "$RIDER"; then
    pass "rider has section: $section"
  else
    fail "rider is missing top-level section: ## $section"
  fi
done

# 4. Mutual citation (by filename, so absolute-vs-relative both count)
GOAL_NAME=$(basename "$GOAL")
RIDER_NAME=$(basename "$RIDER")
if grep -qF "$RIDER_NAME" "$GOAL"; then
  pass "goal references the rider"
  if ! grep -qF "/$RIDER_NAME" "$GOAL"; then
    warn "goal cites the rider by bare filename; use an absolute path so an executor launched from any cwd can find it"
  fi
else
  fail "goal does not reference the rider ($RIDER_NAME) — add it under **Read first.**"
fi
if grep -qF "$GOAL_NAME" "$RIDER"; then
  pass "rider references the goal"
else
  fail "rider does not reference the goal ($GOAL_NAME) — cite it in the rider's opening paragraph"
fi

# 5. Shared timestamp prefix (YYYY-MM-DD-HHMM)
GOAL_TS=$(basename "$GOAL"  | grep -oE '^[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]{4}' || true)
RIDER_TS=$(basename "$RIDER" | grep -oE '^[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]{4}' || true)
if [ -z "$GOAL_TS" ] || [ -z "$RIDER_TS" ]; then
  warn "filenames do not start with <YYYY-MM-DD>-<HHMM>; chronological sort in docs/goals/ will not work"
elif [ "$GOAL_TS" = "$RIDER_TS" ]; then
  pass "pair shares timestamp $GOAL_TS"
else
  fail "timestamp mismatch: goal=$GOAL_TS rider=$RIDER_TS — the pair must share one timestamp"
fi

echo
if [ "$FAIL" -eq 0 ]; then
  echo "PAIR VALID. Stage it: git add \"$GOAL\" \"$RIDER\""
  exit 0
else
  echo "PAIR INVALID. Fix the failures above and re-run."
  exit 1
fi
