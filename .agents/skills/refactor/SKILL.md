---
name: refactor
description: Refactor, restructure, clean up, or improve existing code. Use when the user asks to refactor code, improve code quality, extract functions, reduce duplication, simplify complex logic, or reorganize modules.
---

# Refactor

## When to use
Use this skill when asked to refactor code, clean up technical debt, extract shared logic, simplify complex functions, reorganize file structure, or improve code quality without changing behavior.

## Core Principle
**Refactoring changes structure without changing behavior.** Every step must preserve all existing tests and functionality.

## Workflow: Plan → Validate → Execute → Verify

### Step 1: Plan
Before touching any code:

```
- [ ] Identify what to refactor and why (name the specific code smell)
- [ ] Define the target state (what should the code look like after?)
- [ ] Check test coverage — can you safely change this code?
- [ ] If no tests exist, WRITE TESTS FIRST before refactoring
- [ ] Break the refactor into small, independent steps
```

### Step 2: Validate pre-conditions
```bash
# Run the full test suite to confirm everything passes BEFORE you start
pytest tests/ -v           # Python
npm test                   # Node.js
go test ./...              # Go

# Check for usages of the code you're changing
grep -rn "function_name" src/
```

### Step 3: Execute (one step at a time)
Apply ONE refactoring pattern per commit. After EACH step:

```
- [ ] Run tests — they must all pass
- [ ] Verify no behavior change (same inputs → same outputs)
- [ ] Commit the step with a descriptive message
```

**Do NOT combine multiple refactoring patterns in one step.** If you need to rename AND extract, do them as separate commits.

### Step 4: Verify
```
- [ ] All tests pass (no regressions)
- [ ] The code is measurably better (less duplication, simpler, more readable)
- [ ] No unintended public API changes
- [ ] Git diff shows the total change is understandable
```

## Common Refactoring Patterns

### Extract Function
**When**: A block of code does a distinct sub-task within a larger function.
```
Before: One 50-line function doing 3 things
After:  One 10-line function calling 3 focused helpers
```

### Rename
**When**: A name doesn't accurately describe what it does.
- Rename the symbol
- Update all references
- Run tests

### Inline
**When**: A function/variable adds indirection without adding clarity.
```
Before: temp = get_price(); return temp;
After:  return get_price();
```

### Extract Constant / Config
**When**: Magic numbers or strings appear in the code.
```
Before: if retries > 3:
After:  MAX_RETRIES = 3; if retries > MAX_RETRIES:
```

### Replace Conditional with Polymorphism
**When**: A long if/elif/switch handles different types/modes.
```
Before: if type == "pdf": ... elif type == "docx": ...
After:  processor = get_processor(type); processor.handle()
```

### Consolidate Duplicate Code
**When**: The same logic appears in 2+ places.
1. Identify the common pattern
2. Extract to a shared function
3. Replace all occurrences
4. Run tests after each replacement

### Simplify Complex Conditionals
**When**: Nested if/else is hard to follow.
- Use early returns / guard clauses
- Extract complex conditions into named booleans
- Use lookup tables instead of chains of if/elif

For a full catalog of refactoring patterns, see [references/refactor-catalog.md](references/refactor-catalog.md).

## Gotchas
- **Write tests before refactoring** if coverage is low. You need a safety net.
- **Don't refactor and add features at the same time.** Separate commits.
- **Don't refactor code you don't understand.** Read it first, add comments, THEN refactor.
- **Preserve public APIs.** If external code depends on a function signature, don't change it without a migration path.
- **Watch for side effects.** When extracting functions, ensure you're not accidentally changing when side effects (logging, metrics, DB writes) occur.
