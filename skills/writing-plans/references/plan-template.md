# Plan Template

Use this template when writing implementation plans. Adapt sections as needed.

---

```markdown
# [Feature Name] Implementation Plan

**Goal:** [One sentence describing what this builds]
**Architecture:** [2-3 sentences about approach]
**Tech Stack:** [Key technologies/libraries]

---

## Task 1: [Short, imperative title]

**Do:**
- [Specific action 1 — include file paths, function names, exact changes]
- [Specific action 2]

**Verify:**
- [Command to run or check to perform]
- [Expected output]

**Commit:** `type(scope): description`

---

## Task 2: [Short, imperative title]

**Do:**
- [Specific action 1]
- [Specific action 2]

**Verify:**
- [Command to run or check to perform]

**Commit:** `type(scope): description`

---

## Task 3: [Short, imperative title]

**Do:**
- [Specific action 1]
- [Specific action 2]

**Verify:**
- [Command to run or check to perform]

**Commit:** `type(scope): description`

---

[Continue for each task...]

---

## Task N: Integration & Final Verification

**Do:**
- Run the full test suite
- Verify all acceptance criteria from the requirements
- Check for any linting or type errors

**Verify:**
- All tests pass
- No lint errors
- Feature works end-to-end

**Commit:** `feat(scope): complete [feature name] implementation`
```

## Tips

- Number tasks sequentially — they represent execution order
- Each task should be completable in 2-5 minutes
- Include exact file paths and function names where possible
- Verification steps should be commands someone can copy-paste
- Commit messages should follow conventional commits format
- The final task should always be integration verification