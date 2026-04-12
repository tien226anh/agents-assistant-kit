# Root Cause Tracing

Techniques for tracing bugs backward from symptom to root cause.

## The Backward Tracing Method

Start at the symptom and work backward through the call stack and data flow.

### Step 1: Define the Symptom Precisely

- What exactly is wrong? (Not "it doesn't work" — be specific)
- What is the expected behavior?
- What is the actual behavior?
- How often does it happen? (Always, sometimes, under specific conditions?)

### Step 2: Trace the Code Path

Starting from the symptom, trace backward:

```
Symptom: "User sees 500 error on /api/orders"
  ← Handler returns 500
    ← Service throws NullReferenceException
      ← Order object is null
        ← Database query returns null
          ← Query uses wrong customer ID
            ← Customer ID comes from session
              ← Session not refreshed after login
```

### Step 3: Check Each Layer

At each layer, verify:
- **Input:** Is the data coming in correct?
- **Processing:** Is the transformation correct?
- **Output:** Is the data going out correct?

### Step 4: Find the Divergence

The root cause is where actual behavior first diverges from expected behavior. Everything after that is a symptom.

## Techniques

### Binary Search Debugging

When the code path is long, use binary search:

1. Add a checkpoint in the middle of the path
2. Is the data still correct at the checkpoint?
   - Yes → The bug is after the checkpoint
   - No → The bug is before the checkpoint
3. Repeat in the affected half

### Git Bisect

When the bug appeared recently but you don't know which commit:

```bash
git bisect start
git bisect bad HEAD
git bisect good <last-known-good-commit>
# Git will check out commits. Test each one.
# Mark with: git bisect good / git bisect bad
```

### Data Flow Analysis

Trace the data, not the code:

1. What data enters the system?
2. How is it transformed at each step?
3. Where does it diverge from expectations?

### State Inspection

When state might be corrupted:

1. Log the full state at each transition point
2. Compare actual state vs expected state
3. Find the first point of divergence

## Common Root Cause Patterns

| Symptom | Likely Root Cause |
|---------|------------------|
| NullReferenceException | Missing null check or uninitialized variable |
| Intermittent failures | Race condition or timing issue |
| Works locally, fails in CI | Environment difference (config, data, timing) |
| Works for small data, fails for large | Off-by-one error or resource exhaustion |
| Works on first run, fails on repeat | State not properly reset between runs |
| Error in logs but no user impact | Error is caught and swallowed somewhere |
| User sees stale data | Cache invalidation missing or incorrect |