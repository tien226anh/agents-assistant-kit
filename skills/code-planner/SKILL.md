---
name: code-planner
description: Use when planning step-by-step implementation before writing code. Generates phased execution plans across multiple files for complex features, refactoring strategies, or architecture roadmaps. Include keywords: plan, implementation, strategy, phased, breakdown, architecture, roadmap.
---

# Code Planner Workflow

## When to use
Use this skill to bridge the gap between requirements and execution. When faced with a multi-file feature, a large refactor, or complex integration, generate a phased implementation plan instead of generating chaotic, immediate code changes.

## ⚠️ Command Safety
You are in planning mode. **Do not run formatting, linting, or modification scripts.** You may use code search (`grep_search`) and read tools to analyze the repository, but you must not alter the source code during the planning phase.

## Plan Document Header

Every plan MUST start with this header:

```markdown
# [Feature Name] Implementation Plan

**Goal:** [One sentence describing what this builds]
**Architecture:** [2-3 sentences about approach]
**Tech Stack:** [Key technologies/libraries]

---
```

## Bite-Sized Task Granularity

Each task step should be **one action (2-5 minutes)**:

- ✅ "Write the failing test for user validation"
- ✅ "Run it to make sure it fails"
- ✅ "Implement the minimal code to make the test pass"
- ✅ "Run the tests and make sure they pass"
- ✅ "Commit with message 'feat: add user validation'"
- ❌ "Implement the entire user module" (too large)
- ❌ "Set up the project" (too vague)

## Planning Process

### 1. Repository Context Gathering
- Identify the existing architecture (e.g., is this an MVC app, a serverless architecture, a CLI tool?).
- Locate the files that will be affected by the proposed changes.
- Check for existing utility functions or established patterns that should be reused instead of reinvented.

### 2. Phase Breakdown
Break the implementation down into logical, testable phases. Commits should ideally be made after each phase. The structure should generally follow:
1. **Data Layer** (Schema, models, migrations)
2. **Core Logic** (Services, controllers, business logic)
3. **API / Routing** (Endpoints, middleware)
4. **Presentation** (UI components, CLI prompts)
5. **Testing** (Unit/Integration tests)

### 3. Draft the Implementation Plan
Draft the plan formatted specifically for the user to review.

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
```

## No Placeholders

Plans must contain **concrete, actionable steps** — never placeholders:

- ✅ "Create `src/auth/validate.py` with a `validate_user()` function that checks email format and password length"
- ❌ "Create the validation module [TODO: define interface]"
- ❌ "Implement the auth logic [details TBD]"

If you don't have enough information to write a concrete step, that's a sign you need more context first.

## Anti-Patterns
- **Do not write the actual code in the plan:** The plan should contain instructions (e.g., "Add a `validate_email` function"), not the 50 lines of Python code for it.
- **Do not create giant monolithic phases:** If a phase touches more than 5 files, it is too large. Break it down.
- **Do not skip verification:** Every task needs a way to confirm it worked.
- **Do not defer all testing to the end:** Testing tasks should be interleaved with implementation tasks.
- **Do not use placeholders or TBDs:** If you can't be specific, gather more context first.

## Integration

- **Before this skill:** Use `brainstorming` to explore approaches, `requirements-specifier` to formalize requirements
- **After this skill:** Use `executing-plans` to execute the plan with review checkpoints, or `writing-plans` for more granular task breakdown
- **Complementary skills:** `brainstorming`, `requirements-specifier`, `executing-plans`, `writing-plans`
