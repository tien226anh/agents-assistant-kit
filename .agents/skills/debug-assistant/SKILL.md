---
name: debug-assistant
description: Systematically debug errors, investigate bugs, and fix unexpected behavior. Use when the user reports a bug, encounters an error, sees unexpected output, or needs help troubleshooting an issue.
---

# Debug Assistant

## When to use
Use this skill when the user reports a bug, encounters an error or exception, observes unexpected behavior, or needs help diagnosing an issue.

## Workflow: Reproduce → Isolate → Hypothesize → Fix → Verify

### Step 1: Reproduce
Confirm the issue exists and is reproducible.

```
- [ ] Get the exact error message or unexpected behavior description
- [ ] Identify the steps to reproduce
- [ ] Run the reproduction steps and confirm the issue
- [ ] Note the environment (OS, language version, dependency versions)
```

If you cannot reproduce, check:
- Is it environment-specific? (different OS, config, data)
- Is it timing-dependent? (race condition, timeout)
- Is it data-dependent? (specific input triggers it)

### Step 2: Isolate
Narrow down where the bug lives.

```bash
# Check recent changes that might have introduced the bug
git log --oneline -10
git diff HEAD~5 -- <suspected-file>

# Search for the error message in source code
grep -rn "error message text" src/

# Check logs
tail -100 logs/app.log  # or wherever logs live
```

Key questions:
- **Where** does it happen? (which file, function, line)
- **When** does it happen? (always, sometimes, only with specific input)
- **What changed** recently? (deps, config, code)

### Step 3: Hypothesize
Form a specific, testable hypothesis about the root cause.

Bad: "Something is wrong with the database."
Good: "The `user_id` column is NULL when creating a session because the auth middleware isn't setting it for the `/api/v2/` routes."

For each hypothesis:
1. State what you expect to see if the hypothesis is correct
2. Write a quick check to validate (add a log line, run a query, inspect a value)
3. If wrong, refine and try the next hypothesis

### Step 4: Fix
Apply the minimum change that fixes the root cause, not the symptom.

```
- [ ] Fix addresses the root cause, not just the symptom
- [ ] No unrelated changes mixed in
- [ ] Error handling covers the edge case that caused the bug
- [ ] Related code is checked for the same class of bug
```

### Step 5: Verify
Confirm the fix works and doesn't break anything else.

```
- [ ] Original reproduction steps no longer trigger the bug
- [ ] Existing tests still pass
- [ ] New test added to prevent regression
- [ ] Edge cases are covered (empty input, null, large values)
```

```bash
# Run the relevant test suite
pytest tests/ -v          # Python
npm test                  # Node.js
go test ./...             # Go

# Run the specific reproduction case
<reproduction-command>
```

## Gotchas
- Don't fix the symptom. If a function returns NULL unexpectedly, don't just add a null check at the call site — find out why it returns NULL.
- Check for multiple instances. If a bug is in one place, the same pattern might appear elsewhere.
- Read the stack trace bottom-to-top. The root cause is usually near the bottom (the oldest frame).
- Time-dependent bugs: add timestamps to debug logs to understand ordering.

For common bug patterns by language/framework, see [references/common-patterns.md](references/common-patterns.md).
