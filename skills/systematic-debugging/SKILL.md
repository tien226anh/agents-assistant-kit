---
name: systematic-debugging
description: Use when debugging hard or persistent bugs that resist normal troubleshooting. Triggers on phrases like "can't find the root cause", "bug keeps coming back", "traced the error but still stuck", or when the debug-assistant workflow has not resolved the issue after multiple attempts.
---

# Systematic Debugging

Deep-dive debugging techniques for hard bugs that resist normal troubleshooting. Use this when `debug-assistant` hasn't resolved the issue.

## When to Use

- You've tried `debug-assistant` but the bug persists
- The root cause is elusive — symptoms don't match obvious causes
- The bug is intermittent or only appears under specific conditions
- You need to trace through complex systems to find where things go wrong

## ⚠️ Command Safety

Read-only investigation commands only. Never modify production data or configuration during debugging.

## Workflow

### Step 1: Root Cause Tracing

Trace the bug backward from symptom to cause:

1. **Start at the symptom** — What exactly is going wrong? Be precise.
2. **Trace backward** — What code path leads to this symptom?
3. **Check each layer** — At each layer, ask: "Is the input correct? Is the output correct?"
4. **Find the divergence** — Where does the actual behavior diverge from expected?
5. **Verify the root cause** — Can you reproduce the bug by intentionally causing the divergence?

See [references/root-cause-tracing.md](references/root-cause-tracing.md) for detailed techniques.

### Step 2: Defense in Depth

If root cause tracing alone doesn't resolve it, add validation at multiple layers:

1. **Input validation** — Add checks at the entry point
2. **Intermediate assertions** — Add assertions at each processing step
3. **Output verification** — Verify the final output matches expectations
4. **Logging** — Add strategic logging to narrow down where things go wrong

See [references/defense-in-depth.md](references/defense-in-depth.md) for patterns.

### Step 3: Condition-Based Waiting

For timing-related or intermittent bugs, replace arbitrary timeouts with condition checks:

1. **Identify the condition** — What must be true for the bug to not occur?
2. **Replace `sleep(N)` with condition polling** — Wait for the condition, not for time
3. **Add a timeout** — Fail explicitly if the condition isn't met within a reasonable time
4. **Log the wait duration** — Helps identify performance issues

See [references/condition-based-waiting.md](references/condition-based-waiting.md) for patterns.

### Step 4: Fix and Verify

1. **Make the minimal fix** — Change only what's necessary
2. **Add a regression test** — Write a test that would have caught this bug
3. **Verify the fix** — Run the test suite and confirm the original symptom is gone
4. **Check for similar issues** — Search for the same pattern elsewhere in the codebase

## Anti-Patterns

- **Changing random things** — Every change should be a hypothesis, not a guess
- **Adding print statements everywhere** — Strategic logging > flooding the console
- **Fixing symptoms** — Always trace to the root cause before fixing
- **Skipping the regression test** — If you don't write a test, the bug will come back
- **Assuming it's fixed** — Verify with the original reproduction steps

## Integration

- **Before this skill:** Use `debug-assistant` for straightforward bugs
- **After this skill:** Use `test-writer` to add regression tests
- **Complementary skills:** `problem-solving` for creative debugging approaches, `bug-analyzer` for generating diagnostic reports