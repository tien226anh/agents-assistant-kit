---
name: writing-plans
description: Use when creating detailed implementation plans from requirements or design documents. Triggers on phrases like "create a plan", "break this down into tasks", "plan the implementation", or when transitioning from brainstorming/requirements to execution.
---

# Writing Plans

Create bite-sized, actionable implementation plans from requirements or design documents.

## When to Use

- After `brainstorming` or `requirements-specifier` — when the "what" is clear and you need the "how"
- User asks to break work into tasks or create an implementation plan
- Before `executing-plans` — plans are the input for execution

## ⚠️ Command Safety

Read-only planning. No code changes during plan creation.

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

## Task Structure

Each task in the plan follows this format:

```markdown
### Task N: [Short, imperative title]

**Do:**
- [Specific action 1]
- [Specific action 2]

**Verify:**
- [How to confirm it works — command, test, or check]

**Commit:** [Conventional commit message]
```

## No Placeholders

Plans must contain **concrete, actionable steps** — never placeholders:

- ✅ "Create `src/auth/validate.py` with a `validate_user()` function that checks email format and password length"
- ❌ "Create the validation module [TODO: define interface]"
- ❌ "Implement the auth logic [details TBD]"

If you don't have enough information to write a concrete step, that's a sign you need more `brainstorming` or `requirements-specifier` work first.

## Planning Process

### 1. Read the Input

- If a design document exists, read it fully
- If requirements exist, read them fully
- If neither exists, suggest `brainstorming` or `requirements-specifier` first

### 2. Identify the Scope

- What files will be created or modified?
- What dependencies exist between tasks?
- What's the minimal viable order?

### 3. Break Into Tasks

- Group related work into tasks
- Order tasks by dependency (what must happen first?)
- Each task should be independently verifiable
- Include test tasks alongside implementation tasks

### 4. Write the Plan

- Start with the plan document header
- List tasks in execution order
- Each task has Do, Verify, and Commit sections
- Total tasks should be 3-8 for a typical feature

### 5. Self-Review

Before finalizing, check:
- [ ] Every task has a verification step
- [ ] No task depends on a future task
- [ ] No placeholders or TBDs
- [ ] Commit messages follow conventional commits
- [ ] The plan could be handed to someone unfamiliar with the project

## Anti-Patterns

- **Vague tasks** — "Set up the project" is not a task; "Create `package.json` with dependencies X, Y, Z" is
- **Missing verification** — Every task needs a way to confirm it worked
- **Skipping tests** — Testing tasks should be interleaved, not deferred to the end
- **Giant tasks** — If a task takes more than 10 minutes, split it
- **Assuming context** — Plans should be self-contained; don't assume the executor knows what you know

## Integration

- **Before this skill:** Use `brainstorming` to explore approaches, `requirements-specifier` to formalize requirements
- **After this skill:** Use `executing-plans` to execute the plan with review checkpoints
- **REQUIRED SUB-SKILL:** `executing-plans` — the natural next step after writing a plan